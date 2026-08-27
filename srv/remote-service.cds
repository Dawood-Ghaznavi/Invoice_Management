using {API_MATERIAL_DOCUMENT_SRV} from './external/API_MATERIAL_DOCUMENT_SRV';
using {CE_PURCHASEORDER_0001} from './external/CE_PURCHASEORDER_0001';

service RemoteService {
    entity PurchaseOrder as
        projection on CE_PURCHASEORDER_0001.PurchaseOrder {
            key PurchaseOrder       as purchaseOrder,
                PurchaseOrderDate   as purchaseOrderDate,
                CompanyCode         as companyCode,
                Supplier            as supplier,
                InvoicingParty      as invoicingParty,
                DocumentCurrency    as documentCurrency,
                PurchasingProcessingStatus as processingStatus
        };

    entity PurchaseOrderItem as
        projection on CE_PURCHASEORDER_0001.PurchaseOrderItem {
            key PurchaseOrder               as purchaseOrder,
            key PurchaseOrderItem           as purchaseOrderItem,
                PurchaseOrderItemText       as description,
                Material                    as material,
                CompanyCode                 as companyCode,
                DocumentCurrency            as documentCurrency,
                OrderQuantity               as orderQuantity,
                PurchaseOrderQuantityUnit   as orderQuantityUnit,
                NetPriceAmount              as netPriceAmount,
                NetPriceQuantity            as netPriceQuantity,
                OrderPriceUnit              as orderPriceUnit,
                NetAmount                   as netAmount,
                GoodsReceiptIsExpected      as goodsReceiptIsExpected,
                InvoiceIsGoodsReceiptBased  as invoiceIsGoodsReceiptBased,
                IsCompletelyDelivered       as isCompletelyDelivered
        };

    entity MaterialDocumentHeader as
        projection on API_MATERIAL_DOCUMENT_SRV.A_MaterialDocumentHeader {
            key MaterialDocumentYear        as materialDocumentYear,
            key MaterialDocument            as materialDocument,
                DocumentDate                as documentDate,
                PostingDate                 as postingDate,
                ReferenceDocument           as referenceDocument,
                GoodsMovementCode           as goodsMovementCode
        };

    entity MaterialDocumentItem as
        projection on API_MATERIAL_DOCUMENT_SRV.A_MaterialDocumentItem {
            key MaterialDocumentYear        as materialDocumentYear,
            key MaterialDocument            as materialDocument,
            key MaterialDocumentItem        as materialDocumentItem,
                Material                    as material,
                Plant                       as plant,
                GoodsMovementType           as goodsMovementType,
                Supplier                    as supplier,
                PurchaseOrder               as purchaseOrder,
                PurchaseOrderItem           as purchaseOrderItem,
                QuantityInBaseUnit          as quantityInBaseUnit,
                MaterialBaseUnit            as baseUnit,
                QuantityInEntryUnit         as quantityInEntryUnit,
                EntryUnit                   as entryUnit,
                DebitCreditCode             as debitCreditCode
        };

};
