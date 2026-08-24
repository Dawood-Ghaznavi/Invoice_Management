'use strict';

const { current_transaction_isolation_level } = require('@cap-js/hana/lib/cql-functions');
const cds = require('@sap/cds');
const FormData = require('form-data');
const { SELECT, UPDATE, INSERT, DELETE } = cds.ql;

const removeExpand = (select, association) => {
    const index = select.columns?.findIndex(column =>
        column.expand && column.ref?.[0] === association
    );

    if (index === undefined || index < 0) return false;

    select.columns.splice(index, 1);
    return true;
};

module.exports = async function () {
    const {
        Invoices,
        InvoiceItems,
        GLAccounts,
        CostCenters,
        PurchaseOrder,
        PurchaseOrderItem,
        MaterialDocumentHeader,
        MaterialDocumentItem
    } = this.entities;

    const purchaseOrderService = await cds.connect.to('CE_PURCHASEORDER_0001');
    const materialDocumentService = await cds.connect.to('API_MATERIAL_DOCUMENT_SRV');
    const documentService = await cds.connect.to('Document');
    const gpt = await cds.connect.to('GPT');

    const Attachments = this.entities['Invoices.attachments'];

    this.before('PATCH', Invoices.drafts, req => {
        if (!Object.prototype.hasOwnProperty.call(req.data, 'purchaseOrder_purchaseOrder')) {
            delete req.data.processingType;
            return;
        }

        const purchaseOrderNumber = req.data.purchaseOrder_purchaseOrder?.trim();
        req.data.purchaseOrder_purchaseOrder = purchaseOrderNumber || null;
        req.data.processingType = purchaseOrderNumber ? 'PO' : 'Non-PO';
    });

    this.before(['CREATE', 'UPDATE'], Invoices, req => {
        if (!Object.prototype.hasOwnProperty.call(req.data, 'purchaseOrder_purchaseOrder')) {
            delete req.data.processingType;
            return;
        }

        const purchaseOrderNumber = req.data.purchaseOrder_purchaseOrder?.trim();
        req.data.purchaseOrder_purchaseOrder = purchaseOrderNumber || null;
        req.data.processingType = purchaseOrderNumber ? 'PO' : 'Non-PO';
    });

    this.on('extract', Invoices.drafts, async req => {
        const { ID } = req.params[0];
        const attachments = await SELECT.from(Attachments.drafts)
            .columns('filename', 'mimeType', 'content')
            .where({ up__ID: ID });

        if (!attachments.length || !attachments[0].content) {
            return req.error({ message: 'No invoice attachment found', status: 404 });
        }

        let fileContent = attachments[0].content;

        if (!Buffer.isBuffer(fileContent)) {
            const chunks = [];

            for await (const chunk of fileContent) {
                chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
            }

            fileContent = Buffer.concat(chunks);
        }

        const invoiceDraft = await SELECT.one.from(Invoices.drafts)
            .columns('DraftAdministrativeData_DraftUUID')
            .where({ ID });

        if (!invoiceDraft) {
            return req.error({ message: 'Invoice draft not found', status: 404 });
        }

        const schemas = await documentService.tx(req).get('/schemas?clientId=default&documentType=invoice');
        const schemaId = schemas?.schemas[0]?.id;

        if (!schemaId) {
            return req.error({ message: 'No invoice schema found', status: 404 });
        }

        const formData = new FormData();
        formData.append('file', fileContent, {
            filename: attachments[0].filename || 'invoice.pdf',
            contentType: attachments[0].mimeType || 'application/pdf'
        });
        formData.append('options', JSON.stringify({
            clientId: 'default',
            documentType: 'invoice',
            schemaId
        }));

        const job = await documentService.tx(req).post('/document/jobs', formData, {
            ...formData.getHeaders(),
            'content-length': formData.getLengthSync()
        });

        if (!job?.id) {
            return req.error({ message: 'Document extraction job could not be created', status: 502 });
        }

        let extractionResult;

        for (let attempt = 0; attempt < 40; attempt++) {
            await new Promise(resolve => setTimeout(resolve, 1500));
            extractionResult = await documentService.tx(req).get(`/document/jobs/${job.id}`);

            if (extractionResult?.status === 'DONE') break;

            if (extractionResult?.status === 'FAILED') {
                return req.error({ message: 'Document extraction failed', status: 502 });
            }
        }

        if (extractionResult?.status !== 'DONE') {
            return req.error({ message: 'Document extraction timed out', status: 504 });
        }

        const headerFields = Object.fromEntries(
            (extractionResult.extraction?.headerFields || []).map(field => [
                field.name,
                field.value ?? field.rawValue
            ])
        );

        const lineItems = (extractionResult.extraction?.lineItems || []).map(lineItem =>
            Object.fromEntries(lineItem.map(field => [
                field.name,
                field.value ?? field.rawValue
            ]))
        );

        const invoiceData = {
            documentNumber: headerFields.documentNumber,
            documentDate: headerFields.documentDate,
            dueDate: headerFields.dueDate,
            grossAmount: headerFields.grossAmount,
            netAmount: headerFields.netAmount,
            taxAmount: headerFields.taxAmount,
            currency: headerFields.currencyCode,
            senderName: headerFields.senderName,
            senderAddress: headerFields.senderAddress,
            invoicingParty: headerFields.invoicingParty,
            purchaseOrder_purchaseOrder: headerFields.purchaseOrderNumber?.trim() || null,
            processingType: headerFields.purchaseOrderNumber?.trim() ? 'PO' : 'Non-PO'
        };

        for (const field in invoiceData) {
            if (invoiceData[field] === undefined) {
                delete invoiceData[field];
            }
        }

        await UPDATE(Invoices.drafts).set(invoiceData).where({ ID });
        await DELETE.from(InvoiceItems.drafts).where({ invoice_ID: ID });
console.log(" *** " , lineItems)
        if (lineItems.length) {
            await INSERT.into(InvoiceItems.drafts).entries(lineItems.map((lineItem, index) => ({
                ID: cds.utils.uuid(),
                invoice_ID: ID,
                poItems: String((index + 1) * 10).padStart(4, '0'),
                netAmount: lineItem.netAmount,
                quantity: lineItem.quantity,
                unitPrice: lineItem.unitPrice,
                productCode:  lineItem.materialNumber,
                description: lineItem.description,
                IsActiveEntity: false,
                HasActiveEntity: false,
                HasDraftEntity: false,
                DraftAdministrativeData_DraftUUID: invoiceDraft.DraftAdministrativeData_DraftUUID
            })));
        }

        req.notify('Invoice extracted successfully');
    });

    this.on('submit', Invoices, async req => {
        const { ID } = req.params[0];
        const invoice = await SELECT.one.from(Invoices)
            .columns(
                'status',
                'processingType',
                'purchaseOrder_purchaseOrder',
                'glAccount_code',
                'costCenter_code'
            )
            .where({ ID });

        if (!invoice) {
            return req.error({ message: 'Invoice not found', status: 404 });
        }

        if (invoice.status !== 'DRAFT') {
            return req.error({ message: 'Only draft invoices can be submitted', status: 400 });
        }

        if (invoice.processingType === 'PO') {
            if (!invoice.purchaseOrder_purchaseOrder) {
                return req.error({ message: 'A Purchase Order is required before submitting a PO invoice', status: 400 });
            }

            const purchaseOrder = await purchaseOrderService.tx(req).run(
                SELECT.one.from(PurchaseOrder)
                    .columns('purchaseOrder')
                    .where({ purchaseOrder: invoice.purchaseOrder_purchaseOrder })
            );

            if (!purchaseOrder) {
                return req.error({
                    message: `Purchase Order ${invoice.purchaseOrder_purchaseOrder} was not found`,
                    status: 400
                });
            }
        } else if (invoice.processingType === 'Non-PO') {
            if (!invoice.glAccount_code || !invoice.costCenter_code) {
                return req.error({ message: 'G/L Account and Cost Center are required before submitting a Non-PO invoice', status: 400 });
            }

            const glAccount = await SELECT.one.from(GLAccounts)
                .columns('code')
                .where({ code: invoice.glAccount_code, isActive: true });
            const costCenter = await SELECT.one.from(CostCenters)
                .columns('code')
                .where({ code: invoice.costCenter_code, isActive: true });

            if (!glAccount || !costCenter) {
                return req.error({ message: 'The selected G/L Account or Cost Center is no longer active', status: 400 });
            }
        } else {
            return req.error({ message: 'Invoice processing type is missing', status: 400 });
        }

        await UPDATE(Invoices).set({ status: 'IN_APPROVAL' }).where({ ID });
        req.notify('Invoice submitted for approval');
    });

    this.on('fetchRec', Invoices.drafts, async req => {
        const { ID } = req.params[0];
        const invoice = await SELECT.one.from(Invoices.drafts)
            .columns(
                'documentNumber',
                'documentDate',
                'grossAmount',
                'netAmount',
                'taxAmount',
                'currency',
                'senderName',
                'senderAddress',
                'invoicingParty',
                'processingType',
                'status'
            )
            .where({ ID });

        if (!invoice) {
            return req.error({ message: 'Invoice draft not found', status: 404 });
        }

        if (invoice.processingType !== 'Non-PO' || invoice.status !== 'DRAFT') {
            return req.error({ message: 'AI recommendations are only available for draft Non-PO invoices', status: 400 });
        }

        const lineItems = await SELECT.from(InvoiceItems.drafts)
            .columns('poItems', 'productCode', 'description', 'quantity', 'unitPrice', 'netAmount')
            .where({ invoice_ID: ID });
        const glAccounts = await SELECT.from(GLAccounts)
            .columns('code', 'name', 'description', 'companyCode')
            .where({ isActive: true });
        const costCenters = await SELECT.from(CostCenters)
            .columns('code', 'name', 'description', 'companyCode')
            .where({ isActive: true });

        if (!glAccounts.length || !costCenters.length) {
            return req.error({ message: 'No active G/L accounts or cost centers are available', status: 400 });
        }

        const response = await gpt.post('/v1/responses', {
            model: 'gpt-5.6-luna',
            store: false,
            instructions: 'Recommend the best accounting assignment for this Non-PO invoice. Choose only from the supplied G/L accounts and cost centers. Base the recommendation on the supplier, invoice amounts and line-item descriptions. Give a concise reason and a confidence from 0 to 100.',
            input: JSON.stringify({
                invoice,
                lineItems,
                glAccounts,
                costCenters
            }),
            text: {
                format: {
                    type: 'json_schema',
                    name: 'invoice_account_assignment',
                    strict: true,
                    schema: {
                        type: 'object',
                        properties: {
                            glAccount: {
                                type: 'string',
                                enum: glAccounts.map(account => account.code)
                            },
                            costCenter: {
                                type: 'string',
                                enum: costCenters.map(costCenter => costCenter.code)
                            },
                            confidence: {
                                type: 'number',
                                minimum: 0,
                                maximum: 100
                            },
                            reason: {
                                type: 'string'
                            }
                        },
                        required: ['glAccount', 'costCenter', 'confidence', 'reason'],
                        additionalProperties: false
                    }
                }
            }
        });

        const outputText = response.output
            ?.find(output => output.type === 'message')
            ?.content?.find(content => content.type === 'output_text')
            ?.text;

        if (!outputText) {
            return req.error({ message: 'AI recommendation could not be generated', status: 502 });
        }

        let recommendation;

        try {
            recommendation = JSON.parse(outputText);
        } catch {
            return req.error({ message: 'AI recommendation returned an invalid response', status: 502 });
        }

        if (!glAccounts.some(account => account.code === recommendation.glAccount) ||
            !costCenters.some(costCenter => costCenter.code === recommendation.costCenter)) {
            return req.error({ message: 'AI recommendation returned an invalid account assignment', status: 502 });
        }

        await UPDATE(Invoices.drafts).set({
            suggestedGLAccount: recommendation.glAccount,
            suggestedCostCenter: recommendation.costCenter,
            aiConfidence: recommendation.confidence,
            aiReason: recommendation.reason
        }).where({ ID });

        req.notify('AI recommendation generated successfully');
    });

    this.on('adopt', Invoices.drafts, async req => {
        const { ID } = req.params[0];
        const invoice = await SELECT.one.from(Invoices.drafts)
            .columns('processingType', 'status', 'suggestedGLAccount', 'suggestedCostCenter')
            .where({ ID });

        if (!invoice) {
            return req.error({ message: 'Invoice draft not found', status: 404 });
        }

        if (invoice.processingType !== 'Non-PO' || invoice.status !== 'DRAFT') {
            return req.error({ message: 'AI recommendations can only be adopted for draft Non-PO invoices', status: 400 });
        }

        if (!invoice.suggestedGLAccount || !invoice.suggestedCostCenter) {
            return req.error({ message: 'No AI recommendation is available to adopt', status: 400 });
        }

        const glAccount = await SELECT.one.from(GLAccounts)
            .columns('code')
            .where({ code: invoice.suggestedGLAccount, isActive: true });
        const costCenter = await SELECT.one.from(CostCenters)
            .columns('code')
            .where({ code: invoice.suggestedCostCenter, isActive: true });

        if (!glAccount || !costCenter) {
            return req.error({ message: 'The recommended account assignment is no longer available', status: 400 });
        }

        await UPDATE(Invoices.drafts).set({
            glAccount_code: glAccount.code,
            costCenter_code: costCenter.code
        }).where({ ID });

        req.notify('AI recommendation adopted successfully');
    });

    this.after('READ', [Invoices.drafts, Invoices], async (result, req) => {
        if (!req.query.SELECT?.one || !result) return;

        const invoice = Array.isArray(result) ? result[0] : result;
        if (!invoice) return;

        const attachment = await SELECT.one
            .from(req.target === Invoices.drafts ? Attachments.drafts : Attachments)
            .columns('ID')
            .where({ up__ID: invoice.ID });

        invoice.hasAttachments = Boolean(attachment);
    });

    this.on('READ', [Invoices.drafts , Invoices], async (req, next) => {
        const select = req.query.SELECT;
        if (!select) return next();

        const expandPurchaseOrder = removeExpand(select, 'purchaseOrder');

        let addedPurchaseOrderKey = false;
        if (expandPurchaseOrder && select.columns) {
            const hasWildcard = select.columns.some(column => column === '*' || column.ref?.[0] === '*');
            const hasPurchaseOrderKey = select.columns.some(column =>
                column.ref?.[0] === 'purchaseOrder_purchaseOrder'
            );

            if (!hasWildcard && !hasPurchaseOrderKey) {
                select.columns.push({ ref: ['purchaseOrder_purchaseOrder'] });
                addedPurchaseOrderKey = true;
            }
        }

        const result = await next();
        if (!result || !expandPurchaseOrder) return result;

        const invoices = Array.isArray(result) ? result : [result];

        await Promise.all(invoices.map(async invoice => {
            const purchaseOrderNumber = invoice.purchaseOrder_purchaseOrder;

            if (purchaseOrderNumber) {
                invoice.purchaseOrder = await purchaseOrderService.tx(req).run(
                    SELECT.one.from(PurchaseOrder).where({ purchaseOrder: purchaseOrderNumber })
                ) || null;
            } else {
                invoice.purchaseOrder = null;
            }

            if (addedPurchaseOrderKey) delete invoice.purchaseOrder_purchaseOrder;
        }));

        return result;
    });

    this.on('READ', [PurchaseOrder, PurchaseOrderItem], req =>
        purchaseOrderService.tx(req).run(req.query)
    );

    this.on('READ', [MaterialDocumentHeader, MaterialDocumentItem], req =>
        materialDocumentService.tx(req).run(req.query)
    );
};
