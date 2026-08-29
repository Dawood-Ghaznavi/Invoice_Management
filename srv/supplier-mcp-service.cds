using { intelliinvoice.invoice as invoice } from '../db/schema/inv-schema';
using { RemoteService as remoteService } from './remote-service';

/**
 * Read-only business data for the supplier self-service assistant.
 * Every request must be restricted in CAP to the suppliers assigned to the authenticated user.
 */
@title: 'Supplier Self-Service'
@description: 'Supplier-facing invoice and purchase-order information for answering status and document-summary questions.'
@mcp: 'supplier'
@mcp.instructions: 'Use describe only as a fallback when the available entity and field descriptions are insufficient to construct a query; do not call it routinely before query. Use Invoices for invoice status, amounts, due dates, counts, and invoices needing attention. Use generic query on PurchaseOrders only for direct PO header lookups such as a specific PO number, status, date, currency, or supplier-visible header information. For every question about whether POs are open, listing open POs, counting open POs, filtering by open status, or comparing open POs, always use getOpenPurchaseOrders. For normal counts and sample lists, omit includeAll or set it to false because totalCount covers the complete population. Set includeAll to true when the user explicitly asks for every result or when an exact comparison or calculation requires fields from the complete open-PO population, such as oldest, newest, earliest, or latest. Using includeAll for a comparison does not mean the full list should be returned to the user. Use getInvoiceCountForOpenPurchaseOrders for the exact number of authorized invoices associated with all open POs; never calculate that count from the sampled open-PO list. Never infer open status from PurchasingProcessingStatus, processingStatus, or generic PurchaseOrders data. getOpenPurchaseOrders is the single source of truth for the business definition of an open PO. Never ask for or guess a supplier ID; CAP determines the allowed suppliers from the authenticated user. This service is read-only.'
@requires: 'authenticated-user'
@cds.query.limit: {
    default: 20,
    max    : 100
}
service SupplierMCPService {

    type OpenPurchaseOrder {
        purchaseOrder     : String(10);
        purchaseOrderDate : Date;
        companyCode       : String(4);
        supplier          : String(10);
        invoicingParty    : String(10);
        documentCurrency  : String(3);
        processingStatus  : String(2);
    }

    type OpenPurchaseOrdersResult {
        /** Total number of open purchase orders before response sampling. */
        totalCount     : Integer;
        /** First five open purchase orders by default, or every result when includeAll is true. */
        purchaseOrders : many OpenPurchaseOrder;
    }

    type OpenPurchaseOrderInvoiceCountResult {
        /** Total number of open purchase orders for the authenticated supplier. */
        openPurchaseOrderCount : Integer;
        /** Number of authorized invoices associated with those open purchase orders. */
        invoiceCount           : Integer;
    }

    /**
     * Supplier-visible invoice headers.
     * Use for invoice status, invoice lookup, amounts, dates, and lists of invoices requiring attention.
     * DRAFT and REJECTED invoices generally need attention; return the stored status without inventing a new one.
     */
    @title: 'Invoices'
    @readonly
    entity Invoices as projection on invoice.Invoices {
        /** Internal invoice identifier. Prefer reqNumber or documentNumber when speaking to a supplier. */
        key ID,
        /** Supplier-facing request number, for example REQ-000001. */
            reqNumber,
        /** Invoice number shown on the supplier document. */
            documentNumber,
        /** Date printed on the invoice. */
            documentDate,
        /** Date by which the invoice is due. */
            dueDate,
        /** Total invoice amount including tax. */
            grossAmount,
        /** Invoice amount before tax. */
            netAmount,
        /** Total tax amount for the invoice. */
            taxAmount,
        /** ISO transaction currency code. */
            currency,
        /** Supplier name extracted from or recorded for the invoice. */
            senderName,
        /** SAP supplier identifier used by CAP to enforce supplier isolation. */
            supplier,
        /** Internal association retained only so CAP can resolve its managed foreign key. */
        @cds.api.ignore
            purchaseOrder,
        /** Scalar SAP purchase-order number for PO invoices; empty for Non-PO invoices. */
        virtual purchaseOrderNumber : String(10),
        /** Whether the invoice follows the PO or Non-PO process. */
            processingType,
        /** Workflow status: DRAFT, IN_APPROVAL, APPROVED, REJECTED, or POSTED. */
            status
    };


    /**
     * Purchase-order headers visible to the authenticated supplier.
     * Use generic query on this entity only for direct PO header lookups such as a specific
     * PO number, status, date, company code, supplier-visible information, or currency.
     * Never use this entity to decide whether POs are open or to list, count, or filter open POs.
     * Use getOpenPurchaseOrders for every open-PO question.
     */
    @title: 'Purchase Orders'
    @readonly
    entity PurchaseOrders as projection on remoteService.PurchaseOrder {
        /** SAP purchase-order number. */
        key purchaseOrder,
        /** Date on which the purchase order was created. */
            purchaseOrderDate,
        /** Company code that owns the purchase order. */
            companyCode,
        /** SAP supplier identifier. CAP uses this value for supplier isolation. */
            supplier,
        /** Party authorized to submit invoices when different from the supplier. */
            invoicingParty,
        /** ISO document currency code. */
            documentCurrency,
        /** SAP purchasing-document processing state. Never use this value to determine whether a PO is open. */
            processingStatus
    };

    /**
     * Single source of truth for the business definition of an open purchase order.
     * Always use this function to determine whether POs are open and to list, count,
     * or filter open POs. A PO is returned when at least one assigned-supplier item
     * is non-deleted, expected to be invoiced, and not finally invoiced.
     */
    function getOpenPurchaseOrders(
        /** Set to true for an explicit complete list or an exact comparison/calculation requiring every open PO; otherwise false. */
        includeAll : Boolean
    ) returns OpenPurchaseOrdersResult;

    /**
     * Returns the exact number of authorized invoices associated with all open purchase orders.
     * The complete open-PO set is processed inside CAP and is never returned to the caller.
     * Use for questions such as "How many invoices do I have against my open POs?"
     */
    function getInvoiceCountForOpenPurchaseOrders()
        returns OpenPurchaseOrderInvoiceCountResult;

}
