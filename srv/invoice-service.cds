using { intelliinvoice.invoice as invoice } from '../db/schema/inv-schema';
using { intelliinvoice.masterdata as masterdata } from '../db/schema/inv-schema';
using { RemoteService as remoteService } from './remote-service';

service InvoiceService {
    @odata.draft.enabled
    entity Invoices as projection on invoice.Invoices actions {
        action extract();
        action submit();
        action fetchRec();
        action adopt();
    };
    entity InvoiceItems as projection on invoice.InvoiceItems;

    entity GLAccounts as projection on masterdata.GLAccounts;
    entity CostCenters as projection on masterdata.CostCenters;

    entity PurchaseOrder as projection on remoteService.PurchaseOrder;
    entity PurchaseOrderItem as projection on remoteService.PurchaseOrderItem;
    entity MaterialDocumentHeader as projection on remoteService.MaterialDocumentHeader;
    entity MaterialDocumentItem as projection on remoteService.MaterialDocumentItem;
}
