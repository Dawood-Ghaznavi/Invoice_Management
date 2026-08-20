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
        PurchaseOrder,
        PurchaseOrderItem,
        MaterialDocumentHeader,
        MaterialDocumentItem
    } = this.entities;

    const purchaseOrderService = await cds.connect.to('CE_PURCHASEORDER_0001');
    const materialDocumentService = await cds.connect.to('API_MATERIAL_DOCUMENT_SRV');
    const documentService = await cds.connect.to('Document');

    const Attachments = this.entities['Invoices.attachments'];

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
            purchaseOrder_purchaseOrder: headerFields.purchaseOrderNumber || null,
            processingType: headerFields.purchaseOrderNumber ? 'PO' : 'NON_PO'
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
            await INSERT.into(InvoiceItems.drafts).entries(lineItems.map(lineItem => ({
                ID: cds.utils.uuid(),
                invoice_ID: ID,
                poItems: lineItem.purchaseOrderItemNumber,
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
