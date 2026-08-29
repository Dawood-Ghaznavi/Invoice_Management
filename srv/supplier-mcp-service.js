'use strict';

const cds = require('@sap/cds');
const { performance } = require('node:perf_hooks');
const { SELECT } = cds.ql;
const LOG = cds.log('supplier-mcp');

module.exports = async function () {
    const { Invoices, PurchaseOrders } = this.entities;
    const purchaseOrderService = await cds.connect.to('CE_PURCHASEORDER_0001');

    this.before('READ', [Invoices, PurchaseOrders], async req => {
        const supplierContacts = await SELECT.from('intelliinvoice.masterdata.SupplierContacts')
            .columns('supplier')
            .where({ email: req.user.id, isActive: true });

        if (!supplierContacts.length) {
            return req.reject(403, 'No active supplier assignment found for the logged-in user');
        }

        req.query.where({
            supplier: { in: supplierContacts.map(contact => contact.supplier) }
        });
    });

    this.on('READ', Invoices, async (req, next) => {
        const select = req.query.SELECT;
        if (!select) return next();

        const projectedColumns = [
            { ref: ['ID'] },
            { ref: ['reqNumber'] },
            { ref: ['documentNumber'] },
            { ref: ['documentDate'] },
            { ref: ['dueDate'] },
            { ref: ['grossAmount'] },
            { ref: ['netAmount'] },
            { ref: ['taxAmount'] },
            { ref: ['currency'] },
            { ref: ['senderName'] },
            { ref: ['supplier'] },
            {
                ref: ['purchaseOrder_purchaseOrder'],
                as: 'purchaseOrderNumber'
            },
            { ref: ['processingType'] },
            { ref: ['status'] }
        ];

        if (!select.columns) {
            select.columns = projectedColumns;
        } else {
            select.columns = select.columns.flatMap(column =>
                column === '*' || column.ref?.[0] === '*'
                    ? projectedColumns
                    : [column]
            );

            for (const column of select.columns) {
                if (column.ref?.length === 1 &&
                    column.ref[0] === 'purchaseOrderNumber') {
                    column.ref[0] = 'purchaseOrder_purchaseOrder';
                    column.as ||= 'purchaseOrderNumber';
                }
            }
        }

        const queryParts = [
            select.columns,
            select.where,
            select.having,
            select.groupBy,
            select.orderBy
        ].filter(Boolean);

        while (queryParts.length) {
            const part = queryParts.pop();

            if (Array.isArray(part)) {
                queryParts.push(...part);
                continue;
            }

            if (!part || typeof part !== 'object') continue;

            if (Array.isArray(part.ref)) {
                part.ref = part.ref.map(segment =>
                    segment === 'purchaseOrderNumber'
                        ? 'purchaseOrder_purchaseOrder'
                        : segment
                );
            }

            queryParts.push(...Object.values(part));
        }

        return next();
    });

    this.on('READ', PurchaseOrders, req =>
        purchaseOrderService.tx(req).run(req.query)
    );

    this.on('getOpenPurchaseOrders', async req => {
        const requestStartedAt = performance.now();
        const supplierLookupStartedAt = performance.now();
        const supplierContacts = await SELECT.from('intelliinvoice.masterdata.SupplierContacts')
            .columns('supplier')
            .where({ email: req.user.id, isActive: true });
        const supplierLookupMs = Number(
            (performance.now() - supplierLookupStartedAt).toFixed(1)
        );

        if (!supplierContacts.length) {
            return req.reject(403, 'No active supplier assignment found for the logged-in user');
        }

        const sapRequestStartedAt = performance.now();
        const purchaseOrders = await purchaseOrderService.tx(req).run(
            SELECT.from('CE_PURCHASEORDER_0001.PurchaseOrder').columns(
                'PurchaseOrder',
                'PurchaseOrderDate',
                'CompanyCode',
                'Supplier',
                'InvoicingParty',
                'DocumentCurrency',
                'PurchasingProcessingStatus',
                {
                    ref: [{
                        id: '_PurchaseOrderItem',
                        where: [
                            { ref: ['InvoiceIsExpected'] }, '=', { val: true }, 'and',
                            { ref: ['IsFinallyInvoiced'] }, '=', { val: false }, 'and',
                            { ref: ['PurchasingDocumentDeletionCode'] }, '=', { val: '' }
                        ]
                    }],
                    expand: [{ ref: ['PurchaseOrderItem'] }]
                }
            ).where({
                Supplier: { in: supplierContacts.map(contact => contact.supplier) }
            })
        );

        const sapRequestMs = Number(
            (performance.now() - sapRequestStartedAt).toFixed(1)
        );
        const transformStartedAt = performance.now();
        const openPurchaseOrders = purchaseOrders
            .filter(order => order._PurchaseOrderItem?.length)
            .map(order => ({
                purchaseOrder: order.PurchaseOrder,
                purchaseOrderDate: order.PurchaseOrderDate,
                companyCode: order.CompanyCode,
                supplier: order.Supplier,
                invoicingParty: order.InvoicingParty,
                documentCurrency: order.DocumentCurrency,
                processingStatus: order.PurchasingProcessingStatus
            }));
        const transformMs = Number(
            (performance.now() - transformStartedAt).toFixed(1)
        );
        const includeAll = req.data.includeAll === true;
        const returnedPurchaseOrders = includeAll
            ? openPurchaseOrders
            : openPurchaseOrders.slice(0, 5);

        LOG.info('getOpenPurchaseOrders timing', {
            requestId: req.id,
            supplierLookupMs,
            sapRequestMs,
            transformMs,
            totalMs: Number((performance.now() - requestStartedAt).toFixed(1)),
            sourceCount: purchaseOrders.length,
            resultCount: openPurchaseOrders.length,
            returnedCount: returnedPurchaseOrders.length,
            includeAll
        });

        return {
            totalCount: openPurchaseOrders.length,
            purchaseOrders: returnedPurchaseOrders
        };
    });

    this.on('getInvoiceCountForOpenPurchaseOrders', async req => {
        const requestStartedAt = performance.now();
        const supplierContacts = await SELECT.from('intelliinvoice.masterdata.SupplierContacts')
            .columns('supplier')
            .where({ email: req.user.id, isActive: true });

        if (!supplierContacts.length) {
            return req.reject(403, 'No active supplier assignment found for the logged-in user');
        }

        const openPurchaseOrdersStartedAt = performance.now();
        const openPurchaseOrderResult = await this.send({
            event: 'getOpenPurchaseOrders',
            data: { includeAll: true },
            user: req.user,
            headers: req.headers
        });
        const openPurchaseOrdersMs = Number(
            (performance.now() - openPurchaseOrdersStartedAt).toFixed(1)
        );
        const purchaseOrderNumbers = openPurchaseOrderResult.purchaseOrders
            .map(order => order.purchaseOrder);

        let invoiceCount = 0;
        let invoiceCountMs = 0;

        if (purchaseOrderNumbers.length) {
            const invoiceCountStartedAt = performance.now();
            const result = await SELECT.one
                .from('intelliinvoice.invoice.Invoices')
                .columns('count(*) as invoiceCount')
                .where({
                    supplier: {
                        in: supplierContacts.map(contact => contact.supplier)
                    },
                    purchaseOrder_purchaseOrder: {
                        in: purchaseOrderNumbers
                    }
                });

            invoiceCountMs = Number(
                (performance.now() - invoiceCountStartedAt).toFixed(1)
            );
            invoiceCount = Number(result?.invoiceCount || 0);
        }

        LOG.info('getInvoiceCountForOpenPurchaseOrders timing', {
            requestId: req.id,
            openPurchaseOrdersMs,
            invoiceCountMs,
            totalMs: Number((performance.now() - requestStartedAt).toFixed(1)),
            openPurchaseOrderCount: openPurchaseOrderResult.totalCount,
            invoiceCount
        });

        return {
            openPurchaseOrderCount: openPurchaseOrderResult.totalCount,
            invoiceCount
        };
    });
};
