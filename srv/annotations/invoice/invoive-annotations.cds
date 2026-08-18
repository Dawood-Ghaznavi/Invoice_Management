using InvoiceService as service from '../../invoice-service';

// =============================================================================
// General property list
// =============================================================================

annotate service.Invoices with {
    ID                         @UI.Hidden;
    documentNumber             @(title: 'Invoice Number');
    documentDate               @(title: 'Invoice Date');
    dueDate                    @(title: 'Due Date');

    grossAmount                @(
        title               : 'Gross Amount',
        Measures.ISOCurrency: currency
    );
    netAmount                  @(
        title               : 'Net Amount',
        Measures.ISOCurrency: currency
    );
    taxAmount                  @(
        title               : 'Tax Amount',
        Measures.ISOCurrency: currency
    );
    currency                   @(title: 'Currency');

    senderName                 @(title: 'Supplier');
    senderAddress              @(title: 'Supplier Address');
    invoicingParty             @(title: 'Invoicing Party');

    purchaseOrder              @(title: 'Purchase Order');
    glAccount                  @(title: 'G/L Account');
    costCenter                 @(title: 'Cost Center');
    items                      @(title: 'Invoice Items');

    processingType             @(title: 'Processing Type');
    matchResult                @(title: 'Match Result');
    status                     @(title: 'Status');

    suggestedGLAccount         @(title: 'Suggested G/L Account');
    suggestedCostCenter        @(title: 'Suggested Cost Center');
    aiConfidence               @(title: 'AI Confidence');
    aiReason                   @(title: 'AI Recommendation Reason');

    createdAt                  @(title: 'Created At');
    createdBy                  @(title: 'Created By');
    modifiedAt                 @(title: 'Modified At');
    modifiedBy                 @(title: 'Modified By');
}

annotate service.InvoiceItems with {
    ID          @UI.Hidden;
    invoice     @UI.Hidden;

    poItems     @(title: 'PO Item');
    productCode @(title: 'Product Code');
    description @(title: 'Description');
    quantity    @(title: 'Quantity');
    unitPrice   @(
        title               : 'Unit Price',
        Measures.ISOCurrency: invoice.currency
    );
    netAmount   @(
        title               : 'Net Amount',
        Measures.ISOCurrency: invoice.currency
    );
    taxAmount   @(
        title               : 'Tax Amount',
        Measures.ISOCurrency: invoice.currency
    );
}

// =============================================================================
// List Report
// =============================================================================

annotate service.Invoices with @(
    UI.SelectionFields: [
        documentNumber,
        senderName,
        documentDate,
        processingType,
        status,
        purchaseOrder.purchaseOrder
    ],
    UI.LineItem       : [
        {
            $Type         : 'UI.DataField',
            Value         : documentNumber,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : senderName,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : documentDate,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : grossAmount,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : processingType,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : purchaseOrder.purchaseOrder,
            Label         : 'Purchase Order',
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : matchResult,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : status,
            @UI.Importance: #High
        }
    ]
);

// =============================================================================
// Object Page
// =============================================================================

annotate service.Invoices with @(
    UI.HeaderInfo     : {
        TypeName      : 'Invoice',
        TypeNamePlural: 'Invoices',
        Title         : {
            $Type: 'UI.DataField',
            Value: documentNumber
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: senderName
        }
    },
    UI.Identification: [
        {
            $Type: 'UI.DataField',
            Value: documentNumber
        },
        {
            $Type: 'UI.DataField',
            Value: senderName
        },
        {
            $Type: 'UI.DataField',
            Value: grossAmount
        },
        {
            $Type: 'UI.DataField',
            Value: status
        }
    ],
    UI.Facets        : [
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'InvoiceDetails',
            Label : 'Invoice Details',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'GeneralInformation',
                    Label : 'General Information',
                    Target: '@UI.FieldGroup#GeneralInformation'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'Amounts',
                    Label : 'Amounts',
                    Target: '@UI.FieldGroup#Amounts'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'Processing',
                    Label : 'Processing',
                    Target: '@UI.FieldGroup#Processing'
                }
            ]
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'InvoiceItems',
            Label : 'Line Items',
            Target: 'items/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'PurchaseOrderVerification',
            Label : 'Purchase Order Verification',
            Target: '@UI.FieldGroup#PurchaseOrderVerification'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'AccountingAssignment',
            Label : 'Accounting Assignment',
            Target: '@UI.FieldGroup#AccountingAssignment'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'AIRecommendation',
            Label : 'AI Recommendation',
            Target: '@UI.FieldGroup#AIRecommendation'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'AdministrativeData',
            Label : 'Administrative Data',
            Target: '@UI.FieldGroup#AdministrativeData'
        }
    ],
    UI.FieldGroup #GeneralInformation      : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: documentNumber
            },
            {
                $Type: 'UI.DataField',
                Value: documentDate
            },
            {
                $Type: 'UI.DataField',
                Value: dueDate
            },
            {
                $Type: 'UI.DataField',
                Value: senderName
            },
            {
                $Type: 'UI.DataField',
                Value: senderAddress
            },
            {
                $Type: 'UI.DataField',
                Value: invoicingParty
            },
            {
                $Type: 'UI.DataField',
                Value: currency
            }
        ]
    },
    UI.FieldGroup #Amounts                 : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: netAmount
            },
            {
                $Type: 'UI.DataField',
                Value: taxAmount
            },
            {
                $Type: 'UI.DataField',
                Value: grossAmount
            }
        ]
    },
    UI.FieldGroup #Processing              : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: processingType
            },
            {
                $Type: 'UI.DataField',
                Value: matchResult
            },
            {
                $Type: 'UI.DataField',
                Value: status
            }
        ]
    },
    UI.FieldGroup #PurchaseOrderVerification: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: purchaseOrder.purchaseOrder,
                Label: 'Purchase Order'
            },
            {
                $Type: 'UI.DataField',
                Value: purchaseOrder.purchaseOrderDate,
                Label: 'Purchase Order Date'
            },
            {
                $Type: 'UI.DataField',
                Value: purchaseOrder.supplier,
                Label: 'PO Supplier'
            },
            {
                $Type: 'UI.DataField',
                Value: purchaseOrder.companyCode,
                Label: 'Company Code'
            },
            {
                $Type: 'UI.DataField',
                Value: purchaseOrder.documentCurrency,
                Label: 'PO Currency'
            }
        ]
    },
    UI.FieldGroup #AccountingAssignment    : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: glAccount.code,
                Label: 'G/L Account'
            },
            {
                $Type: 'UI.DataField',
                Value: glAccount.name,
                Label: 'G/L Account Name'
            },
            {
                $Type: 'UI.DataField',
                Value: costCenter.code,
                Label: 'Cost Center'
            },
            {
                $Type: 'UI.DataField',
                Value: costCenter.name,
                Label: 'Cost Center Name'
            }
        ]
    },
    UI.FieldGroup #AIRecommendation        : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: suggestedGLAccount
            },
            {
                $Type: 'UI.DataField',
                Value: suggestedCostCenter
            },
            {
                $Type: 'UI.DataField',
                Value: aiConfidence
            },
            {
                $Type: 'UI.DataField',
                Value: aiReason
            }
        ]
    },
    UI.FieldGroup #AdministrativeData      : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: createdBy
            },
            {
                $Type: 'UI.DataField',
                Value: createdAt
            },
            {
                $Type: 'UI.DataField',
                Value: modifiedBy
            },
            {
                $Type: 'UI.DataField',
                Value: modifiedAt
            }
        ]
    }
);

annotate service.InvoiceItems with @(UI.LineItem: [
    {
        $Type         : 'UI.DataField',
        Value         : poItems,
        @UI.Importance: #High
    },
    {
        $Type         : 'UI.DataField',
        Value         : productCode,
        @UI.Importance: #High
    },
    {
        $Type         : 'UI.DataField',
        Value         : description,
        @UI.Importance: #High
    },
    {
        $Type         : 'UI.DataField',
        Value         : quantity,
        @UI.Importance: #High
    },
    {
        $Type         : 'UI.DataField',
        Value         : unitPrice,
        @UI.Importance: #High
    },
    {
        $Type         : 'UI.DataField',
        Value         : netAmount,
        @UI.Importance: #High
    },
    {
        $Type         : 'UI.DataField',
        Value         : taxAmount,
        @UI.Importance: #Medium
    }
]);
