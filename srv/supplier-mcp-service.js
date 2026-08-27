'use strict';

const cds = require('@sap/cds');
const { SELECT } = cds.ql;

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

    this.on('READ', PurchaseOrders, req =>
        purchaseOrderService.tx(req).run(req.query)
    );

    this.on('getOpenPurchaseOrders', async req => {
        const supplierContacts = await SELECT.from('intelliinvoice.masterdata.SupplierContacts')
            .columns('supplier')
            .where({ email: req.user.id, isActive: true });

        if (!supplierContacts.length) {
            return req.reject(403, 'No active supplier assignment found for the logged-in user');
        }

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

        return purchaseOrders
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
    });
};
