using RemoteService as remoteService from '../../srv/remote-service';
using { Attachments } from '@cap-js/attachments';
using {
    managed, cuid
} from '@sap/cds/common';

namespace intelliinvoice;


context invoice {

type InvoiceStatus : String enum {
    DRAFT;
    IN_APPROVAL;
    APPROVED;
    REJECTED;
    POSTED;
}

type ProcessingType : String enum {
    PO;
    NON_PO = 'Non-PO';
}
    

entity Invoices : cuid, managed {
    reqNumber                  : String;
    documentNumber             : String;
    documentDate               : Date;
    dueDate                    : Date;

    grossAmount                : Decimal(15,2);
    netAmount                  : Decimal(15,2);
    taxAmount                  : Decimal(15,2);
    currency                   : String(3);

    senderName                 : String;
    senderAddress              : String;
    invoicingParty             : String;

    supplier                   : String(10);
    purchaseOrder              : Association to remoteService.PurchaseOrder;

    glAccount                  : Association to masterdata.GLAccounts;
    costCenter                 : Association to masterdata.CostCenters;

    items : Composition of many InvoiceItems
        on items.invoice = $self;

    // App-specific fields
    processingType             : ProcessingType;
    status                     : InvoiceStatus default #DRAFT;

    suggestedGLAccount         : String;
    suggestedCostCenter        : String;
    aiConfidence               : Decimal(5,2);
    aiReason                   : LargeString;
    attachments: Composition of many Attachments;
    virtual hasAttachments     : Boolean;
}

entity InvoiceItems : cuid {
    invoice     : Association to Invoices;
    poItems     : String(5);

    netAmount   : Decimal(15,2);
    quantity    : Decimal(15,3);
    unitPrice   : Decimal(15,2);
    productCode : String;
    description : String;
}
}

context masterdata {
    entity GLAccounts {
    key code        : String(10);
        name        : String(100);
        description : String(255);
        companyCode : String(4);
        isActive    : Boolean default true;
}

entity CostCenters {
    key code        : String(10);
        name        : String(100);
        description : String(255);
        companyCode : String(4);
        isActive    : Boolean default true;
}

entity SupplierContacts : managed {
    key email      : String(255);
    key supplier   : String(10);
        fullName   : String(150);
        isActive   : Boolean default true;
}
}
