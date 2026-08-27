using { intelliinvoice.invoice as invoice } from '../db/schema/inv-schema';
using { RemoteService as remoteService } from './remote-service';

/**
 * Read-only business data for the supplier self-service assistant.
 * Every request must be restricted in CAP to the suppliers assigned to the authenticated user.
 */
@title: 'Supplier Self-Service'
@description: 'Supplier-facing invoice and purchase-order information for answering status and document-summary questions.'
@mcp: 'supplier'
@mcp.instructions: 'Always use describe before query. Use Invoices for invoice status, amounts, due dates, counts, and invoices needing attention. Use PurchaseOrders for purchase-order status, lookup, and counts. Never ask for or guess a supplier ID; CAP determines the allowed suppliers from the authenticated user. This service is read-only.'
@requires: 'authenticated-user'
@cds.query.limit: {
    default: 20,
    max    : 100
}
service SupplierMCPService {

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
        /** Related purchase order for PO invoices; empty for Non-PO invoices. */
            purchaseOrder,
        /** Whether the invoice follows the PO or Non-PO process. */
            processingType,
        /** Workflow status: DRAFT, IN_APPROVAL, APPROVED, REJECTED, or POSTED. */
            status
    };


    /**
     * Purchase-order headers visible to the authenticated supplier.
     * Use for purchase-order status, lookup, counts, dates, company codes, suppliers, and currencies.
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
        /** SAP purchasing-document processing state; this does not by itself determine invoiceability. */
            processingStatus
    };

    /**
     * Returns purchase-order headers belonging to the authenticated user's
     * assigned suppliers where at least one non-deleted item is expected
     * to be invoiced and has not been finally invoiced
     */
    function getOpenPurchaseOrders() returns many PurchaseOrders;

}
