'use strict';

const cds = require('@sap/cds');
const {
    Client,
    StreamableHTTPClientTransport
} = require('@modelcontextprotocol/client');
const { SELECT } = cds.ql;

module.exports = async function () {
    const gpt = await cds.connect.to('GPT');

    this.on('ask', async req => {
        if (!req.data.question?.trim()) {
            return req.reject(400, 'Please enter a question');
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
                    description: tool.description,
                    parameters,
                    strict: false
                };
            });
            const input = [{
                role: 'user',
                content: req.data.question
            }];

            let response;

            for (let round = 0; round < 4; round++) {
                response = await gpt.post('/v1/responses', {
                    model: 'gpt-5.6-luna',
                    store: false,
                    instructions: 'You are a supplier self-service assistant. Answer invoice and purchase-order questions only from the available tools. Always use a tool before stating business data. Never ask for or accept a supplier ID because CAP derives the allowed suppliers from the authenticated user. If no matching data is returned, say so clearly. Keep answers concise.',
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
