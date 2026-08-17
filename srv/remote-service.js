'use strict';

const cds = require('@sap/cds');

module.exports = async function () {
    const {
        PurchaseOrder,
        PurchaseOrderItem,
        MaterialDocumentHeader,
        MaterialDocumentItem
    } = this.entities;

    const purchaseOrderService = await cds.connect.to('CE_PURCHASEORDER_0001');
    const materialDocumentService = await cds.connect.to('API_MATERIAL_DOCUMENT_SRV');

    this.on('READ', [PurchaseOrder, PurchaseOrderItem], req =>
        purchaseOrderService.tx(req).run(req.query)
    );

    this.on('READ', [MaterialDocumentHeader, MaterialDocumentItem], req =>
        materialDocumentService.tx(req).run(req.query)
    );
}