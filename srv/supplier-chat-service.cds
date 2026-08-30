/**
 * Stateless supplier chat endpoint used by the future portal UI.
 * Business data is read through SupplierMCPService so CAP remains
 * responsible for supplier isolation.
 */
@path: 'supplier-chat'
@requires: 'authenticated-user'
service SupplierChatService {

    type SupplierProfile {
        fullName : String(150);
    }

    type ChatPresentation : String enum {
        text               = 'text';
        purchaseOrderTable = 'purchaseOrderTable';
        invoiceTable       = 'invoiceTable';
    }

    type ChatPurchaseOrder {
        purchaseOrder     : String(10);
        purchaseOrderDate : Date;
        companyCode       : String(4);
        documentCurrency  : String(3);
    }

    type ChatInvoice {
        reqNumber      : String;
        documentNumber : String;
        documentDate   : Date;
        dueDate        : Date;
        grossAmount    : Decimal(15,2);
        currency       : String(3);
        status         : String;
    }

    type ChatResponse {
        text           : LargeString;
        presentation   : ChatPresentation;
        totalCount     : Integer;
        purchaseOrders : many ChatPurchaseOrder;
        invoices       : many ChatInvoice;
    }

    /**
     * Returns the display name of the authenticated supplier contact.
     */
    function getProfile() returns SupplierProfile;

    /**
     * Answers a supplier question using the read-only Supplier MCP tools.
     */
    action ask(
        question : LargeString,
        history  : LargeString
    ) returns ChatResponse;

}
