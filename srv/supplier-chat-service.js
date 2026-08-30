'use strict';

const cds = require('@sap/cds');
const {
    Client,
    StreamableHTTPClientTransport
} = require('@modelcontextprotocol/client');
const { performance } = require('node:perf_hooks');
const { SELECT } = cds.ql;
const LOG = cds.log('supplier-chat');
const MAX_HISTORY_CHARACTERS = 16000;

let mcpToolDefinitionsPromise;

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
        const askStartedAt = performance.now();
        const timings = {
            openAI: [],
            mcpTools: []
        };

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

            const cappedHistory = [];
            let historyCharacters = 0;

            for (let index = history.length - 1; index >= 0; index--) {
                if (historyCharacters + history[index].content.length > MAX_HISTORY_CHARACTERS) {
                    break;
                }

                cappedHistory.unshift(history[index]);
                historyCharacters += history[index].content.length;
            }

            history = cappedHistory;
        }

        timings.questionCharacters = question.length;
        timings.historyMessages = history.length;
        timings.historyCharacters = history.reduce(
            (total, message) => total + message.content.length,
            0
        );

        if (!req.headers.authorization) {
            return req.reject(401, 'Authentication is required');
        }

        const supplierLookupStartedAt = performance.now();
        const supplierContact = await SELECT.one
            .from('intelliinvoice.masterdata.SupplierContacts')
            .columns('supplier')
            .where({ email: req.user.id, isActive: true });
        timings.supplierLookupMs = Number(
            (performance.now() - supplierLookupStartedAt).toFixed(1)
        );

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
            const mcpConnectStartedAt = performance.now();
            await client.connect(transport);
            timings.mcpConnectMs = Number(
                (performance.now() - mcpConnectStartedAt).toFixed(1)
            );

            const toolMetadataStartedAt = performance.now();
            timings.toolMetadataCacheHit = Boolean(mcpToolDefinitionsPromise);

            if (!mcpToolDefinitionsPromise) {
                mcpToolDefinitionsPromise = client.listTools()
                    .then(availableTools => {
                        const allowedToolNames = [
                            'describe',
                            'query',
                            'getOpenPurchaseOrders',
                            'getInvoiceCountForOpenPurchaseOrders'
                        ];
                        const mcpTools = availableTools.tools.filter(tool =>
                            allowedToolNames.includes(tool.name)
                        );
                        const tools = mcpTools.map(tool => {
                            const parameters = JSON.parse(
                                JSON.stringify(tool.inputSchema)
                            );
                            delete parameters.$schema;

                            return {
                                type: 'function',
                                name: tool.name,
                                description: tool.name === 'query'
                                    ? 'Query supplier-visible entities in SupplierMCPService using CAP CQL. Available entities and fields: Invoices { reqNumber, documentNumber, documentDate, dueDate, grossAmount, netAmount, taxAmount, currency, senderName, purchaseOrderNumber, processingType, status }; PurchaseOrders { purchaseOrder, purchaseOrderDate, companyCode, invoicingParty, documentCurrency, processingStatus }. Invoices.purchaseOrderNumber is a scalar string; use it for direct PO-number selection and filtering. Use PurchaseOrders only for direct header lookups such as a specific PO number, status, date, currency, or supplier-visible header information. Never use generic PurchaseOrders data to decide whether a PO is open or to list, count, filter, or compare open POs. Use describe only as a fallback when these field descriptions are insufficient.'
                                    : tool.name === 'getOpenPurchaseOrders'
                                        ? (tool.description || '') + ' This is the single source of truth for whether purchase orders are open and for every open-PO list, count, filter, or comparison. Omit includeAll or set it to false for normal counts and sample lists because totalCount covers the complete population. Set includeAll to true when the user explicitly asks for all results or when an exact comparison or calculation needs fields from every open PO, such as oldest, newest, earliest, or latest. When includeAll is used only for a comparison, return only the requested answer rather than the full list.'
                                        : tool.name === 'getInvoiceCountForOpenPurchaseOrders'
                                            ? (tool.description || '') + ' Use this directly for the exact invoice count across all open purchase orders. Do not derive that count from the five-record getOpenPurchaseOrders sample.'
                                            : (tool.description || '') + ' Fallback only: use this when the provided entity and field descriptions are insufficient to construct a query. Do not call describe routinely before query.',
                                parameters,
                                strict: false
                            };
                        });

                        return { mcpTools, tools };
                    })
                    .catch(error => {
                        mcpToolDefinitionsPromise = undefined;
                        throw error;
                    });
            }

            const { mcpTools, tools } = await mcpToolDefinitionsPromise;
            timings.toolMetadataMs = Number(
                (performance.now() - toolMetadataStartedAt).toFixed(1)
            );

            if (!mcpTools.length) {
                mcpToolDefinitionsPromise = undefined;
                return req.reject(502, 'The Supplier MCP service did not expose any supported tools');
            }

            const input = [...history, {
                role: 'user',
                content: question
            }];

            const instructions = [
                'You are a supplier self-service assistant. Answer invoice and purchase-order questions only from the available tools.',
                'Always use a tool before stating business data. Never ask for or accept a supplier ID because CAP derives the allowed suppliers from the authenticated user.',
                'Use generic query on PurchaseOrders only for direct PO header lookups such as a specific PO number, status, date, currency, or supplier-visible header information.',
                'For every question about whether POs are open, listing open POs, counting open POs, filtering by open status, or comparing open POs, always use getOpenPurchaseOrders.',
                'For getOpenPurchaseOrders, omit includeAll or set it to false for normal count and sample-list questions because totalCount covers the complete open-PO population. Set includeAll to true when the user explicitly asks for all, every, the full list, or the complete list, and also when an exact comparison or calculation requires fields from every open PO, such as oldest, newest, earliest, or latest. If includeAll is used only to calculate an answer, do not return the complete list unless the user requested it.',
                'For the exact number of authorized invoices associated with all open POs, use getInvoiceCountForOpenPurchaseOrders directly. Never calculate that number from the five-record getOpenPurchaseOrders sample or by sending the complete PO list to the model.',
                'Never infer that a PO is open from processingStatus, PurchasingProcessingStatus, or generic PurchaseOrders data. getOpenPurchaseOrders is the single source of truth for the business definition of an open PO.',
                'Use describe only as a fallback when the entity and field descriptions supplied with query are insufficient. Do not call describe before every query.',
                'If an open-PO result is large, state the total count and show only the first five by default. Return the complete list only when the user explicitly asks for all, every, the full list, or the complete list.',
                'Respond in concise, natural plain text only. Do not use Markdown syntax, bold markers, headings, backticks, or Markdown tables.',
                'For a purchase-order list query, select purchaseOrder, purchaseOrderDate, companyCode, and documentCurrency. For an invoice list query, select reqNumber, documentNumber, documentDate, dueDate, grossAmount, currency, and status.',
                'For a list request returning multiple purchase orders or invoices, write only a short introduction or count summary and do not enumerate or repeat the individual records because the UI renders them separately.',
                'For a single record, count, or comparison question, answer normally in text.',
                'If no matching data is returned, say so clearly.'
            ].join(' ');
            let response;
            let presentation = 'text';
            let totalCount = 0;
            let purchaseOrders = [];
            let invoices = [];
            let openPurchaseOrderTable = false;
            const shortAnswerRequest = /\b(how many|count|number of|oldest|newest|earliest|latest|which one|average|sum|total|minimum|maximum)\b/i.test(question);
            const singleRecordRequest = /\b(first|second|third|fourth|fifth|sixth|seventh|eighth|ninth|tenth|last)\s+(one|po|purchase order|invoice)\b/i.test(question) ||
                /\b(this|that)\s+(one|po|purchase order|invoice)\b/i.test(question) ||
                /\b(REQ|INV|NCS)-[A-Z0-9-]+\b/i.test(question) ||
                /\b\d{10}\b/.test(question);
            const explicitListRequest = /\b(show|list|display|find|which|what are|give me|all)\b/i.test(question);
            const pluralListRequest = /\bwhat\b.{0,80}\b(pos|purchase orders|invoices)\b/i.test(question);
            const tableRequest = !shortAnswerRequest &&
                !singleRecordRequest &&
                (explicitListRequest || pluralListRequest);

            for (let round = 0; round < 4; round++) {
                const openAIStartedAt = performance.now();
                response = await gpt.post('/v1/responses', {
                    model: 'gpt-5.6-luna',
                    store: false,
                    instructions,
                    input,
                    tools,
                    parallel_tool_calls: false
                });
                timings.openAI.push({
                    round: round + 1,
                    durationMs: Number(
                        (performance.now() - openAIStartedAt).toFixed(1)
                    )
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

                    if ([
                        'query',
                        'getOpenPurchaseOrders',
                        'getInvoiceCountForOpenPurchaseOrders'
                    ].includes(toolCall.name)) {
                        presentation = 'text';
                        totalCount = 0;
                        purchaseOrders = [];
                        invoices = [];
                        openPurchaseOrderTable = false;
                    }

                    const mcpToolStartedAt = performance.now();
                    const result = await client.callTool({
                        name: toolCall.name,
                        arguments: args
                    });
                    timings.mcpTools.push({
                        name: toolCall.name,
                        durationMs: Number(
                            (performance.now() - mcpToolStartedAt).toFixed(1)
                        ),
                        isError: Boolean(result.isError)
                    });

                    if (!result.isError &&
                        ['query', 'getOpenPurchaseOrders'].includes(toolCall.name)) {
                        const structuredContent = result.structuredContent || {};

                        if (toolCall.name === 'getOpenPurchaseOrders') {
                            const toolResult = structuredContent.result || {};
                            const records = Array.isArray(toolResult.purchaseOrders)
                                ? toolResult.purchaseOrders
                                : [];

                            totalCount = Number(toolResult.totalCount ?? records.length);

                            if (tableRequest && records.length > 1) {
                                presentation = 'purchaseOrderTable';
                                openPurchaseOrderTable = true;
                                purchaseOrders = records.map(record => ({
                                    purchaseOrder: record.purchaseOrder ?? null,
                                    purchaseOrderDate: record.purchaseOrderDate ?? null,
                                    companyCode: record.companyCode ?? null,
                                    documentCurrency: record.documentCurrency ?? null
                                }));
                            }
                        } else {
                            const records = Array.isArray(structuredContent.data)
                                ? structuredContent.data
                                : [];
                            const cql = typeof args.cql === 'string' ? args.cql : '';

                            totalCount = Number(structuredContent.count ?? records.length);

                            if (tableRequest && records.length > 1 &&
                                /\bfrom\s+(?:SupplierMCPService\.)?PurchaseOrders\b/i.test(cql)) {
                                presentation = 'purchaseOrderTable';
                                purchaseOrders = records.map(record => ({
                                    purchaseOrder: record.purchaseOrder ?? null,
                                    purchaseOrderDate: record.purchaseOrderDate ?? null,
                                    companyCode: record.companyCode ?? null,
                                    documentCurrency: record.documentCurrency ?? null
                                }));
                            } else if (tableRequest && records.length > 1 &&
                                /\bfrom\s+(?:SupplierMCPService\.)?Invoices\b/i.test(cql)) {
                                presentation = 'invoiceTable';
                                invoices = records.map(record => ({
                                    reqNumber: record.reqNumber ?? null,
                                    documentNumber: record.documentNumber ?? null,
                                    documentDate: record.documentDate ?? null,
                                    dueDate: record.dueDate ?? null,
                                    grossAmount: record.grossAmount ?? null,
                                    currency: record.currency ?? null,
                                    status: record.status ?? null
                                }));
                            }
                        }
                    }

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

            if (response?.output?.some(output => output.type === 'function_call')) {
                const finalSynthesisStartedAt = performance.now();
                response = await gpt.post('/v1/responses', {
                    model: 'gpt-5.6-luna',
                    store: false,
                    instructions: instructions + ' The necessary tool calls have already completed. Produce the final answer now from their outputs without requesting another tool.',
                    input
                });
                timings.openAI.push({
                    round: timings.openAI.length + 1,
                    durationMs: Number(
                        (performance.now() - finalSynthesisStartedAt).toFixed(1)
                    ),
                    finalSynthesis: true
                });
            }

            const answer = response?.output
                ?.find(output => output.type === 'message')
                ?.content?.find(content => content.type === 'output_text')
                ?.text;

            if (!answer) {
                return req.reject(502, 'The supplier assistant could not generate a response');
            }

            let responseText = answer;

            if (presentation === 'invoiceTable') {
                responseText = `You have ${totalCount} invoices:`;
            } else if (presentation === 'purchaseOrderTable') {
                if (openPurchaseOrderTable && totalCount > purchaseOrders.length) {
                    const shownCount = purchaseOrders.length === 5
                        ? 'five'
                        : purchaseOrders.length;

                    responseText = `You have ${totalCount} open purchase orders. Here are the first ${shownCount}:`;
                } else if (openPurchaseOrderTable) {
                    responseText = `You have ${totalCount} open purchase orders:`;
                } else {
                    responseText = `You have ${totalCount} purchase orders:`;
                }
            }

            return {
                text: responseText,
                presentation,
                totalCount,
                purchaseOrders,
                invoices
            };
        } finally {
            const mcpCloseStartedAt = performance.now();
            await client.close().catch(() => {});
            timings.mcpCloseMs = Number(
                (performance.now() - mcpCloseStartedAt).toFixed(1)
            );
            timings.totalMs = Number((performance.now() - askStartedAt).toFixed(1));

            LOG.info('ask timing', {
                requestId: req.id,
                ...timings
            });
        }
    });
};
