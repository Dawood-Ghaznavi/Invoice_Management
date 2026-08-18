'use strict';

const cds = require('@sap/cds');
const { SELECT } = cds.ql;

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
        PurchaseOrder,
        PurchaseOrderItem,
        MaterialDocumentHeader,
        MaterialDocumentItem
    } = this.entities;

    const purchaseOrderService = await cds.connect.to('CE_PURCHASEORDER_0001');
    const materialDocumentService = await cds.connect.to('API_MATERIAL_DOCUMENT_SRV');

    const invoiceTargets = Invoices.drafts ? [Invoices, Invoices.drafts] : [Invoices];

    this.on('READ', invoiceTargets, async (req, next) => {
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
