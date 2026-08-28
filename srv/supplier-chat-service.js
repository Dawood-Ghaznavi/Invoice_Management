'use strict';

const cds = require('@sap/cds');
const {
    Client,
    StreamableHTTPClientTransport
} = require('@modelcontextprotocol/client');
const { SELECT } = cds.ql;

module.exports = async function () {
    const gpt = await cds.connect.to('GPT');

    this.on('getProfile', async req => {
        const supplierContact = await SELECT.one
            .from('intelliinvoice.masterdata.SupplierContacts')
            .columns('fullName')
            .where({ email: req.user.id, isActive: true });

        if (!supplierContact) {
            return req.reject(403, 'No active supplier assignment found for the logged-in user');
        }

        return {
            fullName: supplierContact.fullName
        };
    });

    this.on('ask', async req => {
        if (!req.data.question?.trim()) {
            return req.reject(400, 'Please enter a question');
        }

        const question = req.data.question.trim();

        if (question.length > 4000) {
            return req.reject(400, 'The question is too long');
        }

        let history = [];

        if (req.data.history) {
            if (typeof req.data.history !== 'string') {
                return req.reject(400, 'Conversation history must be serialized JSON');
            }

            try {
                history = JSON.parse(req.data.history);
            } catch {
                return req.reject(400, 'Conversation history is not valid JSON');
            }

            if (!Array.isArray(history)) {
                return req.reject(400, 'Conversation history must be an array');
            }

            if (history.some(message =>
                !message ||
                typeof message !== 'object' ||
                !['user', 'assistant'].includes(message.role) ||
                typeof message.content !== 'string' ||
                !message.content.trim() ||
                Object.prototype.hasOwnProperty.call(message, 'loading') ||
                Object.prototype.hasOwnProperty.call(message, 'error')
            )) {
                return req.reject(400, 'Conversation history contains an unsupported message');
            }

            history = history.slice(-12).map(message => ({
                role: message.role,
                content: message.content.trim().slice(0, 4000)
            }));
        }

        if (!req.headers.authorization) {
            return req.reject(401, 'Authentication is required');
        }

        const supplierContact = await SELECT.one
            .from('intelliinvoice.masterdata.SupplierContacts')
            .columns('supplier')
            .where({ email: req.user.id, isActive: true });

        if (!supplierContact) {
            return req.reject(403, 'No active supplier assignment found for the logged-in user');
        }

        const client = new Client({
            name: 'invoice-management-supplier-chat',
            version: '1.0.0'
        });
        const transport = new StreamableHTTPClientTransport(
            new URL(process.env.SUPPLIER_MCP_INTERNAL_URL || `http://127.0.0.1:${process.env.PORT || 4004}/mcp/supplier`),
            {
                requestInit: {
                    headers: {
                        Authorization: req.headers.authorization
                    }
                }
            }
        );

        try {
            await client.connect(transport);

            const availableTools = await client.listTools();
            const allowedToolNames = ['describe', 'query', 'getOpenPurchaseOrders'];
            const mcpTools = availableTools.tools.filter(tool =>
                allowedToolNames.includes(tool.name)
            );

            if (!mcpTools.length) {
                return req.reject(502, 'The Supplier MCP service did not expose any supported tools');
            }

            const tools = mcpTools.map(tool => {
                const parameters = JSON.parse(JSON.stringify(tool.inputSchema));
                delete parameters.$schema;

                return {
                    type: 'function',
                    name: tool.name,
                    description: tool.name === 'query'
                        ? tool.description + ' Use PurchaseOrders only for direct header lookups such as a specific PO number, status, date, currency, or supplier-visible header information. Never use generic PurchaseOrders data to decide whether a PO is open or to list, count, or filter open POs.'
                        : tool.name === 'getOpenPurchaseOrders'
                            ? tool.description + ' This is the single source of truth for whether purchase orders are open and for every open-PO list, count, or filter.'
                            : tool.description,
                    parameters,
                    strict: false
                };
            });
            const input = [...history, {
                role: 'user',
                content: question
            }];

            let response;

            for (let round = 0; round < 4; round++) {
                response = await gpt.post('/v1/responses', {
                    model: 'gpt-5.6-luna',
                    store: false,
                    instructions: [
                        'You are a supplier self-service assistant. Answer invoice and purchase-order questions only from the available tools.',
                        'Always use a tool before stating business data. Never ask for or accept a supplier ID because CAP derives the allowed suppliers from the authenticated user.',
                        'Use generic query on PurchaseOrders only for direct PO header lookups such as a specific PO number, status, date, currency, or supplier-visible header information.',
                        'For every question about whether POs are open, listing open POs, counting open POs, or filtering by open status, always use getOpenPurchaseOrders.',
                        'Never infer that a PO is open from processingStatus, PurchasingProcessingStatus, or generic PurchaseOrders data. getOpenPurchaseOrders is the single source of truth for the business definition of an open PO.',
                        'If an open-PO result is large, state the total count and show only the first five by default. Return the complete list only when the user explicitly asks for all, every, the full list, or the complete list.',
                        'Respond in concise, natural plain text only. Do not use Markdown syntax, bold markers, headings, backticks, or Markdown tables.',
                        'If no matching data is returned, say so clearly.'
                    ].join(' '),
                    input,
                    tools,
                    parallel_tool_calls: false
                });

                const toolCalls = response.output?.filter(output =>
                    output.type === 'function_call'
                ) || [];

                if (!toolCalls.length) break;

                input.push(...response.output);

                for (const toolCall of toolCalls) {
                    if (!mcpTools.some(tool => tool.name === toolCall.name)) {
                        input.push({
                            type: 'function_call_output',
                            call_id: toolCall.call_id,
                            output: JSON.stringify({ error: 'Tool is not allowed' })
                        });
                        continue;
                    }

                    let args;

                    try {
                        args = JSON.parse(toolCall.arguments);
                    } catch {
                        args = {};
                    }

                    const result = await client.callTool({
                        name: toolCall.name,
                        arguments: args
                    });
                    const sanitizedResult = JSON.stringify(
                        result.isError
                            ? { error: 'The requested business query could not be completed' }
                            : result.structuredContent ?? { message: 'The tool returned no structured data' },
                        (key, value) => ['ID', 'supplier', '_meta', 'email'].includes(key)
                            ? undefined
                            : value
                    );

                    input.push({
                        type: 'function_call_output',
                        call_id: toolCall.call_id,
                        output: sanitizedResult || JSON.stringify({ error: 'No result returned' })
                    });
                }
            }

            const answer = response?.output
                ?.find(output => output.type === 'message')
                ?.content?.find(content => content.type === 'output_text')
                ?.text;

            if (!answer) {
                return req.reject(502, 'The supplier assistant could not generate a response');
            }

            return answer;
        } finally {
            await client.close().catch(() => {});
        }
    });
};
