/* checksum : c7e5fc4e4a384ecee1998f832e064b4a */
@cds.external : true
@CodeList.CurrencyCodes.Url : '../../../../default/iwbep/common/0001/$metadata'
@CodeList.CurrencyCodes.CollectionPath : 'Currencies'
@CodeList.UnitsOfMeasure.Url : '../../../../default/iwbep/common/0001/$metadata'
@CodeList.UnitsOfMeasure.CollectionPath : 'UnitsOfMeasure'
@Common.ApplyMultiUnitBehaviorForSortingAndFiltering : true
@Capabilities.FilterFunctions : [
  'eq',
  'ne',
  'gt',
  'ge',
  'lt',
  'le',
  'and',
  'or',
  'contains',
  'startswith',
  'endswith',
  'any',
  'all'
]
@SAP__support.TechnicalInfoLinks.Url : '../../../../default/iwbep/common/0001/$metadata'
@SAP__support.TechnicalInfoLinks.FunctionImport : 'GetTechnicalInfoLinks'
@Capabilities.SupportedFormats : [ 'application/json', 'application/pdf' ]
@PDF.Features.DocumentDescriptionReference : '../../../../default/iwbep/common/0001/$metadata'
@PDF.Features.DocumentDescriptionCollection : 'MyDocumentDescriptions'
@PDF.Features.ArchiveFormat : true
@PDF.Features.Border : true
@PDF.Features.CoverPage : true
@PDF.Features.FitToPage : true
@PDF.Features.FontName : true
@PDF.Features.FontSize : true
@PDF.Features.HeaderFooter : true
@PDF.Features.IANATimezoneFormat : true
@PDF.Features.Margin : true
@PDF.Features.Padding : true
@PDF.Features.ResultSizeDefault : 20000
@PDF.Features.ResultSizeMaximum : 20000
@PDF.Features.Signature : true
@PDF.Features.TextDirectionLayout : true
@PDF.Features.Treeview : true
@PDF.Features.UploadToFileShare : true
@Capabilities.BatchSupport.SupportedFormats : [ 'application/json', 'multipart/mixed' ]
@Capabilities.KeyAsSegmentSupported : true
@Capabilities.AsynchronousRequestsSupported : true
service CE_PURCHASEORDER_0001 {
  @cds.external : true
  type D_PurOrdGetOutputBinaryDataR {
    @Common.Label : 'MIME type'
    @Common.Heading : 'MIME typ'
    @Common.QuickInfo : 'HTML content type'
    MimeType : String(128) not null;
    @Common.Label : 'Output Data'
    OutputBinaryData : LargeBinary not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Channel'
    @Common.Heading : 'Output Channel'
    @Common.QuickInfo : 'Output Channel'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=APOC_CHANNEL'
    OutputChannel : String(5) not null;
    @Common.Label : 'Document Name'
    OutputDocumentName : String(120) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Recipient'
    @Common.QuickInfo : 'Recipient ID'
    Recipient : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Role'
    @Common.QuickInfo : 'Role Code'
    RecipientRole : String(2) not null;
  };

  @cds.external : true
  type SAP__Message {
    code : String not null;
    message : String not null;
    target : String;
    additionalTargets : many String not null;
    transition : Boolean not null;
    @odata.Type : 'Edm.Byte'
    numericSeverity : Integer not null;
    longtextUrl : String;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Subcontracting Components'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderItem,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _ScheduleLine,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableProperties : [ 'BaseUnit' ]
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrder', '_PurchaseOrderItem', '_ScheduleLine' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: RequiredQuantity, AllowedExpressions: 'MultiValue' },
    { Property: QuantityInEntryUnit, AllowedExpressions: 'MultiValue' },
    { Property: VariableSizeItemQuantity, AllowedExpressions: 'MultiValue' },
    {
      Property: VariableSizeComponentQuantity,
      AllowedExpressions: 'MultiValue'
    },
    { Property: Size1, AllowedExpressions: 'MultiValue' },
    { Property: Size2, AllowedExpressions: 'MultiValue' },
    { Property: Size3, AllowedExpressions: 'MultiValue' },
    { Property: WithdrawnQuantity, AllowedExpressions: 'MultiValue' }
  ]
  entity POSubcontractingComponent {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Document'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Purchasing Document Item'
    key PurchaseOrderItem : String(5) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Schedule Line'
    @Common.Heading : 'Schd.'
    @Common.QuickInfo : 'Delivery Schedule Line Counter'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EETEN'
    key ScheduleLine : String(4) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Reservation Item'
    key ReservationItem : String(4) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Reservation Record Type'
    key RecordType : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material'
    @Common.QuickInfo : 'Material Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MATNR'
    Material : String(18) not null;
    IsMaterialProvision : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material Provision Type'
    MaterialProvisionType : String(1) not null;
    @Common.Label : 'Numerator'
    @Common.Heading : 'Numer.'
    @Common.QuickInfo : 'Numerator for Conversion to Base Units of Measure'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UMREZ'
    MaterialQtyToBaseQtyNmrtr : Decimal(precision: 5) not null;
    @Common.Label : 'Denominator'
    @Common.Heading : 'Denom.'
    @Common.QuickInfo : 'Denominator for conversion to base units of measure'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UMREN'
    MaterialQtyToBaseQtyDnmntr : Decimal(precision: 5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Revision Level'
    MaterialRevisionLevel : String(2) not null;
    @Common.Label : 'Variable-Sized Item'
    @Common.QuickInfo : 'Variable-Sized Item Indicator'
    MaterialCompIsVariableSized : Boolean not null;
    @Common.Label : 'Phantom Item'
    @Common.QuickInfo : 'Phantom Item Indicator'
    MaterialComponentIsPhantomItem : Boolean not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Reservation'
    @Common.Heading : 'Reserv.no.'
    @Common.QuickInfo : 'Number of reservation/dependent requirements'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RSNUM'
    Reservation : String(10) not null;
    @Core.Computed : true
    @Measures.Unit : BaseUnit
    @Common.Label : 'Requirement Quantity'
    @Common.Heading : 'Reqmnt qty'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BDMNG'
    RequiredQuantity : Decimal(13, 3) not null;
    @Common.Label : 'Requirement Date'
    @Common.QuickInfo : 'Material Component Requirement Date'
    RequirementDate : Date;
    @Common.Label : 'Requirement Time'
    @Common.QuickInfo : 'Material Component Requirement Time'
    RequirementTime : Time not null;
    @Common.Label : 'Final Issue'
    @Common.Heading : 'FIs'
    @Common.QuickInfo : 'Final Issue for Reservation'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZEAR'
    ReservationIsFinallyIssued : Boolean not null;
    @Common.IsUnit : true
    @Core.Immutable : true
    @Common.Label : 'Base Unit of Measure'
    @Common.Heading : 'BUn'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MEINS'
    BaseUnit : String(3) not null;
    @Measures.Unit : EntryUnit
    @Common.Label : 'Quantity in Unit of Entry'
    QuantityInEntryUnit : Decimal(13, 3) not null;
    @Common.IsUnit : true
    @Common.Label : 'Unit of Entry'
    @Common.Heading : 'EUn'
    @Common.QuickInfo : 'Unit of entry'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ERFME'
    EntryUnit : String(3) not null;
    @Measures.Unit : VariableSizeItemUnit
    @Common.Label : 'Number of Variable-Size Components'
    VariableSizeItemQuantity : Decimal(13, 3) not null;
    @Common.IsUnit : true
    @Common.Label : 'Variable-Size Item Unit'
    @Common.QuickInfo : 'Variable-Size Item Unit of Measure'
    VariableSizeItemUnit : String(3) not null;
    @Common.IsUnit : true
    @Common.Label : 'Variable-Size Component Unit'
    @Common.QuickInfo : 'Unit of Measure for Variable-Size Components'
    VariableSizeComponentUnit : String(3) not null;
    @Measures.Unit : VariableSizeComponentUnit
    @Common.Label : 'VSI Quantity'
    @Common.QuickInfo : 'Variable-Size Item Quantity per PC'
    VariableSizeComponentQuantity : Decimal(13, 3) not null;
    @Common.IsUnit : true
    @Common.Label : 'Size unit'
    @Common.Heading : 'SzUn'
    @Common.QuickInfo : 'Unit of measure for sizes 1 to 3'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ROMEI'
    UnitOfMeasureForSize1To3 : String(3) not null;
    @Measures.Unit : UnitOfMeasureForSize1To3
    @Common.Label : 'Size 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ROMS1'
    Size1 : Decimal(13, 3) not null;
    @Measures.Unit : UnitOfMeasureForSize1To3
    @Common.Label : 'Size 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ROMS2'
    Size2 : Decimal(13, 3) not null;
    @Measures.Unit : UnitOfMeasureForSize1To3
    @Common.Label : 'Size 3'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ROMS3'
    Size3 : Decimal(13, 3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Plant'
    @Common.Heading : 'Plnt'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WERKS_D'
    Plant : String(4) not null;
    @Common.Label : 'Latest Requirement Date'
    LatestRequirementDate : Date;
    @Common.IsDigitSequence : true
    @Common.Label : 'Order level'
    @Common.Heading : 'OLvl'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AUFST'
    OrderLevelValue : String(2) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Order path'
    @Common.Heading : 'Path'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AUFWG'
    OrderPathValue : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Bill Of Material Item Number'
    BillOfMaterialItemNumber : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Sort String'
    @Common.Heading : 'SortStrng'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SORTP'
    MatlCompFreeDefinedAttribute : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'BOM Item Category'
    @Common.QuickInfo : 'Bill of Material Item Category'
    BOMItemCategory : String(1) not null;
    @Common.Label : 'Bulk Material'
    @Common.Heading : 'Bulk'
    @Common.QuickInfo : 'Indicator: Bulk Material'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SCHGT'
    IsBulkMaterialComponent : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Account Assignment Category'
    AccountAssignmentCategory : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Special Stock Type'
    @Common.Heading : 'Sp. Stock'
    @Common.QuickInfo : 'Inventory Special Stock Type'
    InventorySpecialStockType : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Consumption Posting'
    ConsumptionPosting : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Special Stock Valuation Type'
    @Common.QuickInfo : 'Inventory Special Stock Valuation Type'
    InventorySpecialStockValnType : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Sales Order'
    @Common.Heading : 'SO No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CO_KDAUF'
    SalesOrder : String(10) not null;
    @Core.Computed : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Sales Order Item'
    @Common.Heading : 'SO Itm'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CO_KDPOS'
    SalesOrderItem : String(6) not null;
    @Core.Computed : true
    @Common.IsDigitSequence : true
    @Common.Label : 'WBS Internal ID'
    @Common.Heading : 'WBS Elem'
    @Common.QuickInfo : 'WBS Element'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PS_S4_PSPNR'
    WBSElementInternalID : String(8) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Debit Credit Code'
    @Common.QuickInfo : 'Debit/Credit Code'
    DebitCreditCode : String(1) not null;
    @Core.Computed : true
    @Measures.Unit : BaseUnit
    @Common.Label : 'Withdrawn Quantity'
    WithdrawnQuantity : Decimal(13, 3) not null;
    @Common.Label : 'Quantity is fixed'
    @Common.Heading : 'Fix'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FMENG'
    QuantityIsFixed : Boolean not null;
    @Common.Label : 'Component Scrap (%)'
    @Common.Heading : 'C.scrap'
    @Common.QuickInfo : 'Component Scrap in Percent'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KAUSF'
    ComponentScrapInPercent : Decimal(5, 2) not null;
    @Common.Label : 'Operation Scrap in %'
    @Common.Heading : 'OpScrap'
    @Common.QuickInfo : 'Operation Scrap'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AVOAU'
    OperationScrapInPercent : Decimal(5, 2) not null;
    @Common.Label : 'Net Scrap Indicator'
    @Common.Heading : 'Net ID'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=NETAU'
    IsNetScrap : Boolean not null;
    @Common.Label : 'Lead-Time Offset'
    LeadTimeOffset : Decimal(precision: 3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Distribution Key'
    @Common.Heading : 'DKey'
    @Common.QuickInfo : 'MRP Distribution Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SA_VERTL'
    QuantityDistributionKey : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'VSI Formula'
    @Common.Heading : 'Formula'
    @Common.QuickInfo : 'Formula Key for Variable-Size Items'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RFORM'
    FormulaKey : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Storage Location'
    StorageLocation : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Production Supply Area'
    ProductionSupplyArea : String(10) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Batch'
    @Common.QuickInfo : 'Batch Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CHARG_D'
    Batch : String(10) not null;
    @Core.Computed : true
    @Common.Label : 'Item Text'
    @Common.Heading : 'Item Text Line 1'
    @Common.QuickInfo : 'BOM Item Text (Line 1)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=POTX1'
    BOMItemDescription : String(40) not null;
    @Common.Label : 'Item Text 2'
    @Common.Heading : 'Item Text Line 2'
    @Common.QuickInfo : 'BOM Item Text (Line 2)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=POTX2'
    BOMItemText2 : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Change Number'
    @Common.Heading : 'Change No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AENNR'
    ChangeNumber : String(12) not null;
    SAP__Messages : many SAP__Message not null;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
    _PurchaseOrderItem : Association to one PurchaseOrderItem {  };
    _ScheduleLine : Association to one PurchaseOrderScheduleLine on _ScheduleLine.ScheduleLine = ScheduleLine;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Purchase Order'
  @Common.SemanticKey : [ 'PurchaseOrder' ]
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrderItem,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _PurchaseOrderNote,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _PurchaseOrderPartner,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _SupplierAddress,
      InsertRestrictions: { Insertable: true }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_PurchaseOrderItem',
    '_PurchaseOrderNote',
    '_PurchaseOrderPartner',
    '_SupplierAddress'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [ { Property: DownPaymentAmount, AllowedExpressions: 'MultiValue' } ]
  entity PurchaseOrder {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchase Order'
    @Common.Heading : 'Purchase Order Number'
    @Common.QuickInfo : 'Purchase Order Number'
    key PurchaseOrder : String(10) not null;
    @Common.FieldControl : #Mandatory
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Doc. Type'
    @Common.Heading : 'Type'
    @Common.QuickInfo : 'Purchasing Document Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ESART'
    PurchaseOrderType : String(4) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Control indicator'
    @Common.Heading : 'Ctl'
    @Common.QuickInfo : 'Control indicator for purchasing document type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BSAKZ'
    PurchaseOrderSubtype : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Status'
    @Common.Heading : 'S'
    @Common.QuickInfo : 'Status of Purchasing Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ESTAK'
    PurchasingDocumentOrigin : String(1) not null;
    @Common.SAPObjectNodeTypeReference : 'PurchasingDocumentProcessCode'
    @Common.IsUpperCase : true
    @Common.Label : 'Process Indicator'
    @Common.QuickInfo : 'Process Indicator for Purchase Order'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_PROCESS_INDICATOR'
    PurchasingDocumentProcessCode : String(3) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Created By'
    @Common.QuickInfo : 'User of person who created a purchasing document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_ERNAM'
    CreatedByUser : String(12) not null;
    @Core.Computed : true
    @Common.Label : 'Created On'
    @Common.Heading : 'Created'
    @Common.QuickInfo : 'Creation Date of Purchasing Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_ERDAT'
    CreationDate : Date;
    @Common.Label : 'Purchase Order Date'
    @Common.Heading : 'PO Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BEDAT'
    PurchaseOrderDate : Date;
    @odata.Precision : 7
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Last Changed'
    @Common.QuickInfo : 'Change Time Stamp'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CHANGEDATETIME'
    LastChangeDateTime : Timestamp;
    @Common.Label : 'Validity Per. Start'
    @Common.Heading : 'VP Start'
    @Common.QuickInfo : 'Start of Validity Period'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KDATB'
    ValidityStartDate : Date;
    @Common.Label : 'Validity Period End'
    @Common.Heading : 'VPer.End'
    @Common.QuickInfo : 'End of Validity Period'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KDATE'
    ValidityEndDate : Date;
    @Common.Label : 'Message on Goods Receipt requested'
    MsgOnGoodsReceiptIsRequested : Boolean not null;
    @Common.Label : 'Language Key'
    @Common.Heading : 'Language'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SPRAS'
    Language : String(2) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Deletion Code'
    @Common.Heading : 'Purchase Order Deletion Code'
    @Common.QuickInfo : 'Purchase Order Deletion Code'
    PurchaseOrderDeletionCode : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Subject to Release'
    @Common.Heading : 'R'
    @Common.QuickInfo : 'Release Not Yet Completely Effected'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FRGRL'
    ReleaseIsNotCompleted : Boolean not null;
    @Common.Label : 'Incomplete'
    @Common.Heading : 'I'
    @Common.QuickInfo : 'Purchase order not yet complete'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MEMER'
    PurchasingCompletenessStatus : Boolean not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Proc. State'
    @Common.Heading : 'Purchasing Doc. Processing State'
    @Common.QuickInfo : 'Purchasing Document Processing State'
    PurchasingProcessingStatus : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Release Status'
    @Common.Heading : 'Release'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FRGZU'
    PurgReleaseSequenceStatus : String(8) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Release indicator'
    @Common.Heading : 'Rel'
    @Common.QuickInfo : 'Release Indicator: Purchasing Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FRGKE'
    ReleaseCode : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Release Strategy'
    @Common.Heading : 'Strat'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FRGSX'
    PurchasingReleaseStrategy : String(2) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Reason for Canc.'
    @Common.Heading : 'Reas. Canc.'
    @Common.QuickInfo : 'Reason for Cancellation'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ABSGR'
    PurgReasonForDocCancellation : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Company Code'
    @Common.Heading : 'CoCd'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BUKRS'
    CompanyCode : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purch. Organization'
    @Common.Heading : 'POrg'
    @Common.QuickInfo : 'Purchasing Organization'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EKORG'
    PurchasingOrganization : String(4) not null;
    @Common.SAPObjectNodeTypeReference : 'PurchasingGroup'
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Group'
    @Common.Heading : 'PGr'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BKGRP'
    PurchasingGroup : String(3) not null;
    @Common.FieldControl : #Mandatory
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier'
    Supplier : String(10) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    ManualSupplierAddressID : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    SupplierAddressID : String(10) not null;
    @Common.Label : 'Salesperson'
    @Common.QuickInfo : 'Responsible Salesperson at Supplier''s Office'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EVERK'
    SupplierRespSalesPersonName : String(30) not null;
    @Common.Label : 'Supplier Phone'
    @Common.QuickInfo : 'Supplier''s Phone Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TELFNR0'
    SupplierPhoneNumber : String(16) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Goods Supplier'
    @Common.Heading : 'Goods Supp'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LLIEF'
    SupplyingSupplier : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Supplying Plant'
    @Common.Heading : 'SPlt'
    @Common.QuickInfo : 'Supplying (issuing) plant in case of stock transport order'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RESWK'
    SupplyingPlant : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Invoicing Party'
    @Common.Heading : 'Inv. Pty'
    @Common.QuickInfo : 'Different Invoicing Party'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LIFRE'
    InvoicingParty : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Customer'
    @Common.QuickInfo : 'Customer Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KUNNR'
    Customer : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Outline Agreement'
    @Common.Heading : 'Agmt.'
    @Common.QuickInfo : 'Number of principal purchase agreement'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KONNR'
    PurchaseContract : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Quotation'
    @Common.QuickInfo : 'Quotation Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ANGNR'
    SupplierQuotationExternalID : String(10) not null;
    @Common.Label : 'Quotation Date'
    @Common.Heading : 'Quot. Date'
    @Common.QuickInfo : 'Quotation Submission Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=IHRAN'
    QuotationSubmissionDate : Date;
    @Common.IsDigitSequence : true
    @Common.Label : 'Subitem Interval'
    @Common.Heading : 'SIInt'
    @Common.QuickInfo : 'Item Number Interval for Subitems'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UPINC'
    ItemNumberIntervalForSubItems : String(5) not null;
    @Common.SAPObjectNodeTypeReference : 'PaymentTerms'
    @Common.IsUpperCase : true
    @Common.Label : 'Payment Terms'
    @Common.Heading : 'PayT'
    @Common.QuickInfo : 'Terms of Payment Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FARP_DZTERM'
    PaymentTerms : String(4) not null;
    @Common.Label : 'Days 1'
    @Common.Heading : 'Day1'
    @Common.QuickInfo : 'Cash Discount Days 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=DZBD1T'
    CashDiscount1Days : Decimal(precision: 3) not null;
    @Common.Label : 'Days 2'
    @Common.Heading : 'Day2'
    @Common.QuickInfo : 'Cash Discount Days 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=DZBD2T'
    CashDiscount2Days : Decimal(precision: 3) not null;
    @Common.Label : 'Days Net'
    @Common.Heading : 'Net'
    @Common.QuickInfo : 'Net Payment Terms Period'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=DZBD3T'
    NetPaymentDays : Decimal(precision: 3) not null;
    @Common.Label : 'CD Percentage 1'
    @Common.Heading : 'CD P.1'
    @Common.QuickInfo : 'Cash Discount Percentage 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=DZBD1P'
    CashDiscount1Percent : Decimal(5, 3) not null;
    @Common.Label : 'CD Percentage 2'
    @Common.Heading : 'CD P.2'
    @Common.QuickInfo : 'Cash Discount Percentage 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=DZBD2P'
    CashDiscount2Percent : Decimal(5, 3) not null;
    @Common.SAPObjectNodeTypeReference : 'DownPaymentType'
    @Common.IsUpperCase : true
    @Common.Label : 'Down Payment'
    @Common.QuickInfo : 'Down Payment Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ME_DPTYP'
    DownPaymentType : String(4) not null;
    @Common.Label : 'Down Payment %'
    @Common.Heading : 'Down Payt Percentage'
    @Common.QuickInfo : 'Down Payment Percentage'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ME_DPPCNT'
    DownPaymentPercentageOfTotAmt : Decimal(5, 2) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Down Payment Amount'
    @Common.QuickInfo : 'Down Payment Amount in Document Currency'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ME_DPAMNT'
    DownPaymentAmount : Decimal(precision: 11) not null;
    @Common.Label : 'Due Date for DP'
    @Common.Heading : 'Due Date for Down Payment'
    @Common.QuickInfo : 'Due Date for Down Payment'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ME_DPDDAT'
    DownPaymentDueDate : Date;
    @Common.SAPObjectNodeTypeReference : 'IncotermsClassification'
    @Common.IsUpperCase : true
    @Common.Label : 'Incoterms'
    @Common.Heading : 'IncoT'
    @Common.QuickInfo : 'Incoterms (Part 1)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INCO1'
    IncotermsClassification : String(3) not null;
    @Common.Label : 'Incoterms (Part 2)'
    @Common.Heading : 'Inco. 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INCO2'
    IncotermsTransferLocation : String(28) not null;
    @Common.SAPObjectNodeTypeReference : 'IncotermsVersion'
    @Common.IsUpperCase : true
    @Common.Label : 'Incoterms Version'
    @Common.Heading : 'IncoV'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INCOV'
    IncotermsVersion : String(4) not null;
    @Common.Label : 'Incoterms Location 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INCO2_L'
    IncotermsLocation1 : String(70) not null;
    @Common.Label : 'Incoterms Location 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INCO3_L'
    IncotermsLocation2 : String(70) not null;
    @Common.Label : 'Intrastat Relevance'
    @Common.Heading : 'relevant for Intrastat'
    @Common.QuickInfo : 'Relevant for Intrastat Reporting'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INTRA_REL'
    IsIntrastatReportingRelevant : Boolean not null;
    @Common.Label : 'Intrastat Exclusion'
    @Common.Heading : 'exclude from Intrastat'
    @Common.QuickInfo : 'Exclude from Intrastat Reporting'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INTRA_EXCL'
    IsIntrastatReportingExcluded : Boolean not null;
    @Common.Label : 'Your Reference'
    @Common.Heading : 'Your Ref.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=IHREZ'
    CorrespncExternalReference : String(12) not null;
    @Common.Label : 'Our Reference'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UNSEZ'
    CorrespncInternalReference : String(12) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Doc. Condition No.'
    @Common.Heading : 'Doc.Cond.'
    @Common.QuickInfo : 'Number of the Document Condition'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KNUMV'
    PricingDocument : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Procedure'
    @Common.Heading : 'Proc.'
    @Common.QuickInfo : 'Procedure (Pricing, Output Control, Acct. Det., Costing,...)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KALSM_D'
    PricingProcedure : String(6) not null;
    @Common.SAPObjectNodeTypeReference : 'Currency'
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Currency'
    @Common.Heading : 'Crcy'
    @Common.QuickInfo : 'Currency Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WAERS'
    DocumentCurrency : String(3) not null;
    @Common.Label : 'Exchange Rate'
    ExchangeRate : Decimal(9, 5) not null;
    @Common.Label : 'Fixed Exchange Rate'
    @Common.Heading : 'Fix'
    @Common.QuickInfo : 'Indicator for Fixed Exchange Rate'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KUFIX'
    ExchangeRateIsFixed : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Reporting C/R'
    @Common.Heading : 'TR'
    @Common.QuickInfo : 'Country/Region for Tax Report'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1_STML'
    TaxReturnCountry : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/R. of VAT ID'
    @Common.Heading : 'VCR'
    @Common.QuickInfo : 'Country/Region of VAT Registration Number (VAT ID)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=STCEG_L'
    VATRegistrationCountry : String(3) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier Check Sts'
    @Common.Heading : 'Supplier Ck Sts'
    @Common.QuickInfo : 'Product Compliance Supplier Check Status (All Items)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_PC_TOTAL_STATUS_PCS'
    PurgAggrgdProdCmplncSuplrSts : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Prod. Marktablty Sts'
    @Common.Heading : 'ProdMarktabltyS'
    @Common.QuickInfo : 'Product Marketability Status (All Items)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_PC_TOTAL_STATUS_PMA'
    PurgAggrgdProdMarketabilitySts : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Sfty Data Sheet Sts'
    @Common.Heading : 'SftyDataSheetS'
    @Common.QuickInfo : 'Safety Data Sheet Status (All Items)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_PC_TOTAL_STATUS_SDS'
    PurgAggrgdSftyDataSheetStatus : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Dangerous Goods Sts'
    @Common.Heading : 'Dngrs Goods Sts'
    @Common.QuickInfo : 'Dangerous Goods Status (All Items)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_PC_TOTAL_STATUS_DG'
    PurgProdCmplncTotDngrsGoodsSts : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Collective Number'
    @Common.Heading : 'Coll. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SUBMI'
    PurchasingCollectiveNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Retention'
    @Common.QuickInfo : 'Retention Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RETTP'
    RetentionType : String(1) not null;
    @Common.Label : 'Retention %'
    @Common.Heading : 'Retention in Percent'
    @Common.QuickInfo : 'Retention in Percent'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RETPZ'
    PurOrdHdrInvcRtntnPct : Decimal(5, 2) not null;
    SAP__Messages : many SAP__Message not null;
    @Common.Composition : true
    _PurchaseOrderItem : Composition of many PurchaseOrderItem on _PurchaseOrderItem._PurchaseOrder = $self;
    @Common.Composition : true
    _PurchaseOrderNote : Composition of many PurchaseOrderNote on _PurchaseOrderNote._PurchaseOrder = $self;
    @Common.Composition : true
    _PurchaseOrderPartner : Composition of many PurchaseOrderPartner on _PurchaseOrderPartner._PurchaseOrderTP = $self;
    @Common.Composition : true
    _SupplierAddress : Composition of one PurchaseOrderSupplierAddress on _SupplierAddress._PurchaseOrderTP = $self;
  } actions {
    function GetOutputBinaryData() returns D_PurOrdGetOutputBinaryDataR not null;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Account Assignment'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrder', '_PurchaseOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: Quantity, AllowedExpressions: 'MultiValue' },
    { Property: PurgDocNetAmount, AllowedExpressions: 'MultiValue' },
    {
      Property: NonDeductibleInputTaxAmount,
      AllowedExpressions: 'MultiValue'
    }
  ]
  entity PurchaseOrderAccountAssignment {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Document'
    @Common.Heading : 'Pur. Doc.'
    @Common.QuickInfo : 'Purchasing Document Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EBELN'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Item'
    @Common.QuickInfo : 'Item Number of Purchasing Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EBELP'
    key PurchaseOrderItem : String(5) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Account Assgmt No.'
    @Common.Heading : 'SAA'
    @Common.QuickInfo : 'Sequential Number of Account Assignment'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=DZEKKN'
    key AccountAssignmentNumber : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Cost Center'
    @Common.Heading : 'Cost Ctr'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KOSTL'
    CostCenter : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Asset'
    @Common.QuickInfo : 'Main Asset Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ANLN1'
    MasterFixedAsset : String(12) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Network'
    @Common.QuickInfo : 'Network Number for Account Assignment'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=NPLNR'
    ProjectNetwork : String(12) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Oper./Act.'
    @Common.Heading : 'Operation/Activity Number'
    @Common.QuickInfo : 'Operation/Activity Number'
    NetworkActivity : String(4) not null;
    @Common.IsUnit : true
    @Common.Label : 'Order Unit'
    @Common.Heading : 'OUn'
    @Common.QuickInfo : 'Purchase Order Unit of Measure'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BSTME'
    OrderQuantityUnit : String(3) not null;
    @Measures.Unit : OrderQuantityUnit
    @Common.Label : 'Quantity'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MENGE_D'
    Quantity : Decimal(13, 3) not null;
    @Common.Label : 'Distribution (%)'
    @Common.Heading : 'Percent'
    @Common.QuickInfo : 'Distribution percentage in the case of multiple acct assgt'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VPROZ'
    MultipleAcctAssgmtDistrPercent : Decimal(3, 1) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Currency'
    @Common.Heading : 'Crcy'
    @Common.QuickInfo : 'Currency Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WAERS'
    DocumentCurrency : String(3) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Net Order Value'
    @Common.Heading : 'Net Value'
    @Common.QuickInfo : 'Net Order Value in PO Currency'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BWERT'
    PurgDocNetAmount : Decimal(precision: 13) not null;
    @Core.Computed : true
    @Common.Label : 'Deletion Indicator'
    @Common.Heading : 'D'
    @Common.QuickInfo : 'Deletion Indicator: Purchasing Document Account Assignment'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KLOEK'
    IsDeleted : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'G/L Account'
    @Common.Heading : 'G/L Acct'
    @Common.QuickInfo : 'G/L Account Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SAKNR'
    GLAccount : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Business Area'
    @Common.Heading : 'BusA'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=GSBER'
    BusinessArea : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'SD Document'
    @Common.Heading : 'Document'
    @Common.QuickInfo : 'Sales and Distribution Document Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VBELN_CO'
    SalesOrder : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Item'
    @Common.QuickInfo : 'Sales Document Item'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=POSNR_CO'
    SalesOrderItem : String(6) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Schedule Line Number'
    @Common.Heading : 'SLNo'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ETENR'
    SalesOrderScheduleLine : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Subnumber'
    @Common.Heading : 'SNo.'
    @Common.QuickInfo : 'Asset Subnumber'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ANLN2'
    FixedAsset : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Order'
    @Common.QuickInfo : 'Order Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AUFNR'
    OrderID : String(12) not null;
    @Common.Label : 'Unloading Point'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ABLAD'
    UnloadingPointName : String(25) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Controlling Area'
    @Common.Heading : 'COAr'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KOKRS'
    ControllingArea : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Cost Object'
    @Common.Heading : 'CostObject'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KSTRG'
    CostObject : String(12) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Profit Center'
    @Common.Heading : 'Profit Ctr'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PRCTR'
    ProfitCenter : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'WBS Internal ID'
    @Common.Heading : 'WBS Elem'
    @Common.QuickInfo : 'WBS Element'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PS_S4_PSPNR'
    WBSElementInternalID : String(8) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'WBS Element'
    @Common.QuickInfo : 'Work Breakdown Structure Element (WBS Element) Edited'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PS_POSID_EDIT'
    WBSElementExternalID : String(24) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Opertn Task List No.'
    @Common.Heading : 'Routing Number for Operations'
    @Common.QuickInfo : 'Routing Number of Operations in the Order'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CO_AUFPL'
    ProjectNetworkInternalID : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Commitment Item Short ID'
    CommitmentItemShortID : String(14) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Funds Center'
    @Common.Heading : 'Funds Ctr'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FISTL'
    FundsCenter : String(16) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Fund'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BP_GEBER'
    Fund : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Functional Area'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FKBER'
    FunctionalArea : String(16) not null;
    @Common.Label : 'Goods Recipient'
    @Common.Heading : 'Recipient'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WEMPF'
    GoodsRecipientName : String(12) not null;
    @Common.Label : 'Final Invoice'
    @Common.Heading : 'FIn'
    @Common.QuickInfo : 'Final Invoice Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EREKZ'
    IsFinallyInvoiced : Boolean not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Counter'
    @Common.QuickInfo : 'Internal counter'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CIM_COUNT'
    NetworkActivityInternalID : String(8) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Partner'
    @Common.QuickInfo : 'Partner account number'
    PartnerAccountNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Recovery Indicator'
    @Common.Heading : 'RI'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=JV_RECIND'
    JointVentureRecoveryCode : String(2) not null;
    @Common.Label : 'Reference Date'
    @Common.Heading : 'Ref date'
    @Common.QuickInfo : 'Reference date for settlement'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=DABRBEZ'
    SettlementReferenceDate : Date;
    @Common.IsDigitSequence : true
    @Common.Label : 'Opertn Task List No.'
    @Common.Heading : 'Routing Number for Operations'
    @Common.QuickInfo : 'Routing Number of Operations in the Order'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CO_AUFPL'
    OrderInternalID : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Counter'
    @Common.QuickInfo : 'General counter for order'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CO_APLZL'
    OrderIntBillOfOperationsItem : String(8) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Tax Code'
    @Common.Heading : 'Tx'
    @Common.QuickInfo : 'Tax on Sales/Purchases Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MWSKZ'
    TaxCode : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Tax Jurisdiction'
    @Common.Heading : 'Tax Jur.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TXJCD'
    TaxJurisdiction : String(15) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Non-deductible'
    @Common.QuickInfo : 'Non-deductible input tax'
    NonDeductibleInputTaxAmount : Decimal(precision: 13) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Activity Type'
    @Common.Heading : 'ActTyp'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LSTAR'
    CostCtrActivityType : String(6) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Business Process'
    @Common.Heading : 'Bus. Process'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CO_PRZNR'
    BusinessProcess : String(12) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Grant'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=GM_GRANT_NBR'
    GrantID : String(20) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Budget Period'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FM_BUDGET_PERIOD'
    BudgetPeriod : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Earmarked Funds'
    @Common.Heading : 'Earm. Fnds'
    @Common.QuickInfo : 'Document Number for Earmarked Funds'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KBLNR'
    EarmarkedFundsDocument : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Document Item'
    @Common.Heading : 'Itm'
    @Common.QuickInfo : 'Earmarked Funds: Document Item'
    EarmarkedFundsDocumentItem : String(3) not null;
    ValidityDate : Date;
    @Common.IsUpperCase : true
    @Common.Label : 'Chart of Accounts'
    ChartOfAccounts : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Service Doc. Type'
    @Common.Heading : 'Service Document Type'
    @Common.QuickInfo : 'Service Document Type'
    ServiceDocumentType : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Service Document'
    @Common.QuickInfo : 'Service Document ID'
    ServiceDocument : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Service Doc. Item'
    @Common.Heading : 'Service Document Item'
    @Common.QuickInfo : 'Service Document Item ID'
    ServiceDocumentItem : String(6) not null;
    @Common.Label : 'Created On'
    @Common.QuickInfo : 'Record Creation Date'
    CreationDate : Date;
    @Common.Label : 'Final AA'
    @Common.Heading : 'Final AA Indicator'
    @Common.QuickInfo : 'Final Account Assignment Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AA_FINAL_IND'
    IsAcctLineFinal : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Final AA Reason'
    @Common.QuickInfo : 'Final Account Assignment Reason Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AA_FINAL_REASON'
    AcctLineFinalReason : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Company Code'
    @Common.Heading : 'CoCd'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BUKRS'
    CompanyCode : String(4) not null;
    SAP__Messages : many SAP__Message not null;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
    _PurchaseOrderItem : Association to one PurchaseOrderItem on _PurchaseOrderItem.PurchaseOrderItem = PurchaseOrderItem;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Invoicing Plan'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _POInvoicingPlanItem,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_POInvoicingPlanItem', '_PurchaseOrder', '_PurchaseOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  entity PurchaseOrderInvoicingPlan {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchase Order'
    @Common.Heading : 'Purchase Order Number'
    @Common.QuickInfo : 'Purchase Order Number'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Purchase Order Item'
    @Common.Heading : 'Item Number of Purchase Order'
    @Common.QuickInfo : 'Item Number of Purchase Order'
    key PurchaseOrderItem : String(5) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Bill. Plan No.'
    @Common.Heading : 'Bill. Plan'
    @Common.QuickInfo : 'Billing/Invoicing Plan Number'
    key InvoicingPlan : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Billing Plan Type'
    @Common.Heading : 'BT'
    @Common.QuickInfo : 'Billing/Invoicing Plan Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FPART'
    InvoicingPlanType : String(2) not null;
    @Common.Label : 'Start Date'
    @Common.QuickInfo : 'Start Date of Billing/Invoicing Plan'
    InvoicingPlanStartDate : Date;
    @Common.Label : 'End Date'
    @Common.QuickInfo : 'End Date of Billing/Invoicing Plan'
    InvoicingPlanEndDate : Date;
    @Common.IsUpperCase : true
    @Common.Label : 'Next Billing Date'
    @Common.Heading : 'ND'
    @Common.QuickInfo : 'Rule for Origin of Next Billing/Invoice Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PERIO_FP'
    InvoicingPlanNextInvcDateRule : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purch. Organization'
    @Common.Heading : 'POrg'
    @Common.QuickInfo : 'Purchasing Organization'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EKORG'
    PurchasingOrganization : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Group'
    @Common.Heading : 'PGr'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BKGRP'
    PurchasingGroup : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Doc. Type'
    @Common.Heading : 'Type'
    @Common.QuickInfo : 'Purchasing Document Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ESART'
    PurchaseOrderType : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Plant'
    @Common.Heading : 'Plnt'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EWERK'
    Plant : String(4) not null;
    SAP__Messages : many SAP__Message not null;
    @Common.Composition : true
    _POInvoicingPlanItem : Composition of many PurchaseOrderInvoicingPlanItem on _POInvoicingPlanItem._PurchaseOrderInvoicingPlan = $self;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
    _PurchaseOrderItem : Association to one PurchaseOrderItem on _PurchaseOrderItem.PurchaseOrderItem = PurchaseOrderItem;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Invoicing Plan Item'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderInvoicingPlan,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrder', '_PurchaseOrderInvoicingPlan', '_PurchaseOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [ { Property: InvoicingPlanAmount, AllowedExpressions: 'MultiValue' } ]
  entity PurchaseOrderInvoicingPlanItem {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchase Order'
    @Common.Heading : 'Purchase Order Number'
    @Common.QuickInfo : 'Purchase Order Number'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Purchase Order Item'
    @Common.Heading : 'Item Number of Purchase Order'
    @Common.QuickInfo : 'Item Number of Purchase Order'
    key PurchaseOrderItem : String(5) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Item'
    @Common.QuickInfo : 'Item for billing plan/invoice plan/payment cards'
    key InvoicingPlanItem : String(6) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Bill. Plan No.'
    @Common.Heading : 'Bill. Plan'
    @Common.QuickInfo : 'Billing/Invoicing Plan Number'
    key InvoicingPlan : String(10) not null;
    @Common.Label : 'Settlement Start Date'
    @Common.QuickInfo : 'Settlement Start Date of Billing/Invoicing Date'
    InvoicingPlanSettlementFromDte : Date;
    @Common.Label : 'Settlement End Date'
    @Common.QuickInfo : 'Settlement End Date of Billing/Invoicing Date'
    InvoicingPlanSettlementToDte : Date;
    @Common.Label : 'Billing Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FKDAT'
    InvoicingPlanInvoicingDate : Date;
    @Measures.ISOCurrency : TransactionCurrency
    @Common.Label : 'Billing Value'
    @Common.QuickInfo : 'Value to be billed/calc. on date in billing/invoice plan'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FAKWR'
    InvoicingPlanAmount : Decimal(precision: 15) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Currency'
    @Common.Heading : 'Crcy'
    @Common.QuickInfo : 'Currency Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WAERS'
    TransactionCurrency : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purch. Organization'
    @Common.Heading : 'POrg'
    @Common.QuickInfo : 'Purchasing Organization'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EKORG'
    PurchasingOrganization : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Group'
    @Common.Heading : 'PGr'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BKGRP'
    PurchasingGroup : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Doc. Type'
    @Common.Heading : 'Type'
    @Common.QuickInfo : 'Purchasing Document Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ESART'
    PurchaseOrderType : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Plant'
    @Common.Heading : 'Plnt'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EWERK'
    Plant : String(4) not null;
    SAP__Messages : many SAP__Message not null;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
    _PurchaseOrderInvoicingPlan : Association to one PurchaseOrderInvoicingPlan on _PurchaseOrderInvoicingPlan.InvoicingPlan = InvoicingPlan;
    _PurchaseOrderItem : Association to one PurchaseOrderItem {  };
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Purchase Order Item'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _DeliveryAddress,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderInvoicingPlan,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _PurchaseOrderItemNote,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _PurchaseOrderScheduleLineTP,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _PurOrdAccountAssignment,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _PurOrdPricingElement,
      InsertRestrictions: { Insertable: true }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_DeliveryAddress',
    '_PurchaseOrder',
    '_PurchaseOrderInvoicingPlan',
    '_PurchaseOrderItemNote',
    '_PurchaseOrderScheduleLineTP',
    '_PurOrdAccountAssignment',
    '_PurOrdPricingElement'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: ProductPurchasePointsQty, AllowedExpressions: 'MultiValue' },
    { Property: NetPriceQuantity, AllowedExpressions: 'MultiValue' },
    { Property: NetAmount, AllowedExpressions: 'MultiValue' },
    { Property: GrossAmount, AllowedExpressions: 'MultiValue' },
    { Property: EffectiveAmount, AllowedExpressions: 'MultiValue' },
    { Property: Subtotal1Amount, AllowedExpressions: 'MultiValue' },
    { Property: Subtotal2Amount, AllowedExpressions: 'MultiValue' },
    { Property: Subtotal3Amount, AllowedExpressions: 'MultiValue' },
    { Property: Subtotal4Amount, AllowedExpressions: 'MultiValue' },
    { Property: Subtotal5Amount, AllowedExpressions: 'MultiValue' },
    { Property: Subtotal6Amount, AllowedExpressions: 'MultiValue' },
    { Property: OrderQuantity, AllowedExpressions: 'MultiValue' },
    { Property: NetPriceAmount, AllowedExpressions: 'MultiValue' },
    { Property: ItemVolume, AllowedExpressions: 'MultiValue' },
    { Property: ItemGrossWeight, AllowedExpressions: 'MultiValue' },
    { Property: ItemNetWeight, AllowedExpressions: 'MultiValue' },
    {
      Property: NonDeductibleInputTaxAmount,
      AllowedExpressions: 'MultiValue'
    },
    { Property: DownPaymentAmount, AllowedExpressions: 'MultiValue' },
    {
      Property: ExpectedOverallLimitAmount,
      AllowedExpressions: 'MultiValue'
    },
    { Property: OverallLimitAmount, AllowedExpressions: 'MultiValue' }
  ]
  entity PurchaseOrderItem {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchase Order'
    @Common.Heading : 'Purchase Order Number'
    @Common.QuickInfo : 'Purchase Order Number'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Purchase Order Item'
    @Common.Heading : 'Item Number of Purchase Order'
    @Common.QuickInfo : 'Item Number of Purchase Order'
    key PurchaseOrderItem : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purch. Doc. Category'
    @Common.Heading : 'Cat'
    @Common.QuickInfo : 'Purchasing Document Category'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BSTYP'
    PurchaseOrderCategory : String(1) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Currency'
    @Common.Heading : 'Crcy'
    @Common.QuickInfo : 'Currency Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WAERS'
    DocumentCurrency : String(3) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Deletion Indicator'
    @Common.Heading : 'D'
    @Common.QuickInfo : 'Deletion Indicator in Purchasing Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ELOEK'
    PurchasingDocumentDeletionCode : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material Group'
    @Common.Heading : 'Matl Group'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MATKL'
    MaterialGroup : String(9) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material'
    @Common.QuickInfo : 'Material Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MATNR'
    Material : String(18) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material Type'
    @Common.Heading : 'MTyp'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MTART'
    MaterialType : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier Mat. No.'
    @Common.Heading : 'Supplier Material Number'
    @Common.QuickInfo : 'Material Number Used by Supplier'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=IDNLF'
    SupplierMaterialNumber : String(35) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier Subrange'
    @Common.Heading : 'SSR'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LTSNR'
    SupplierSubrange : String(6) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Mfr. Part Number'
    @Common.Heading : 'MPN'
    @Common.QuickInfo : 'Manufacturer Part Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MFRPN'
    ManufacturerPartNmbr : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Manufacturer'
    @Common.Heading : 'Manufact.'
    @Common.QuickInfo : 'Number of a Manufacturer'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MFRNR'
    Manufacturer : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material'
    @Common.QuickInfo : 'Material number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EMATNR'
    ManufacturerMaterial : String(18) not null;
    @Common.Label : 'Short Text'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TXZ01'
    PurchaseOrderItemText : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Product Type Group'
    @Common.Heading : 'Product Type Grp'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PRODUCT_TYPE'
    ProductTypeCode : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Company Code'
    @Common.Heading : 'CoCd'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BUKRS'
    CompanyCode : String(4) not null;
    @Common.FieldControl : #Mandatory
    @Common.IsUpperCase : true
    @Common.Label : 'Plant'
    @Common.Heading : 'Plnt'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EWERK'
    Plant : String(4) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Address'
    @Common.QuickInfo : 'Manual address number in purchasing document item'
    ManualDeliveryAddressID : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address'
    @Common.QuickInfo : 'Number of delivery address'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ADRN2'
    ReferenceDeliveryAddressID : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Customer'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EKUNNR'
    Customer : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier'
    @Common.QuickInfo : 'Supplier to be Supplied/Who is to Receive Delivery'
    Subcontractor : String(10) not null;
    @Common.Label : 'SC Supplier'
    @Common.Heading : 'S'
    @Common.QuickInfo : 'Subcontracting Supplier'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LBLKZ'
    SupplierIsSubcontractor : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Cross-plant CM'
    @Common.QuickInfo : 'Cross-Plant Configurable Material'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SATNR'
    CrossPlantConfigurableProduct : String(18) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material Category'
    @Common.Heading : 'Ct'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ATTYP'
    ArticleCategory : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Kanban Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KBNKZ'
    PlndOrderReplnmtElmntType : String(1) not null;
    @Common.IsUnit : true
    @Common.Label : 'Points Unit'
    @Common.Heading : 'PUn'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PUNEI'
    ProductPurchasePointsQtyUnit : String(3) not null;
    @Measures.Unit : ProductPurchasePointsQtyUnit
    @Common.Label : 'Points'
    @Common.QuickInfo : 'Number of Points'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ANZPU'
    ProductPurchasePointsQty : Decimal(13, 3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Storage Location'
    StorageLocation : String(4) not null;
    @Common.IsUnit : true
    @Common.Label : 'Order Unit'
    @Common.Heading : 'OUn'
    @Common.QuickInfo : 'Purchase Order Unit of Measure'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BSTME'
    PurchaseOrderQuantityUnit : String(3) not null;
    @Common.Label : 'Equal To'
    @Common.Heading : 'Eq. To'
    @Common.QuickInfo : 'Numerator for Conversion of Order Unit to Base Unit'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UMBSZ'
    OrderItemQtyToBaseQtyNmrtr : Decimal(precision: 5) not null;
    @Common.Label : 'Denominator'
    @Common.Heading : 'Denom.'
    @Common.QuickInfo : 'Denominator for Conversion of Order Unit to Base Unit'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UMBSN'
    OrderItemQtyToBaseQtyDnmntr : Decimal(precision: 5) not null;
    @Measures.Unit : OrderPriceUnit
    @Common.Label : 'Price Unit'
    @Common.Heading : 'Per'
    NetPriceQuantity : Decimal(precision: 5) not null;
    @Common.Label : 'Delivery Completed'
    @Common.Heading : 'DCI'
    @Common.QuickInfo : '"Delivery Completed" Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ELIKZ'
    IsCompletelyDelivered : Boolean not null;
    @Common.Label : 'Final Invoice'
    @Common.Heading : 'FIn'
    @Common.QuickInfo : 'Final Invoice Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EREKZ'
    IsFinallyInvoiced : Boolean not null;
    @Common.Label : 'Goods Receipt'
    @Common.Heading : 'GR'
    @Common.QuickInfo : 'Goods Receipt Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WEPOS'
    GoodsReceiptIsExpected : Boolean not null;
    @Common.Label : 'Invoice Receipt'
    @Common.Heading : 'IR'
    @Common.QuickInfo : 'Invoice Receipt Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REPOS'
    InvoiceIsExpected : Boolean not null;
    @Common.Label : 'Acknowledgment Reqd.'
    @Common.Heading : 'ARq'
    @Common.QuickInfo : 'Order Acknowledgment Requirement'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZABS'
    IsOrderAcknRqd : Boolean not null;
    @Common.Label : 'GR-Based Inv. Verif.'
    @Common.Heading : 'GR-IV'
    @Common.QuickInfo : 'Indicator: GR-Based Invoice Verification'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WEBRE'
    InvoiceIsGoodsReceiptBased : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Outline Agreement'
    @Common.Heading : 'Agmt.'
    @Common.QuickInfo : 'Number of principal purchase agreement'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KONNR'
    PurchaseContract : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Agreement Item'
    @Common.Heading : 'Item'
    @Common.QuickInfo : 'Item Number of Principal Purchase Agreement'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KTPNR'
    PurchaseContractItem : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purchase Requisition'
    @Common.Heading : 'Purch.Req.'
    @Common.QuickInfo : 'Purchase Requisition Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BANFN'
    PurchaseRequisition : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Item of requisition'
    @Common.Heading : 'Item'
    @Common.QuickInfo : 'Item Number of Purchase Requisition'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BNFPO'
    PurchaseRequisitionItem : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Req. Tracking Number'
    @Common.Heading : 'TrackingNo'
    @Common.QuickInfo : 'Requirement Tracking Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BEDNR'
    RequirementTracking : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'RFQ'
    @Common.QuickInfo : 'RFQ Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ANFNR'
    SupplierQuotation : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Item'
    @Common.QuickInfo : 'Item Number of RFQ'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ANFPS'
    SupplierQuotationItem : String(5) not null;
    @Common.Label : 'Eval. Receipt Sett.'
    @Common.Heading : 'E'
    @Common.QuickInfo : 'Evaluated Receipt Settlement (ERS)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=XERSY'
    EvaldRcptSettlmtIsAllowed : Boolean not null;
    @Common.Label : 'Unltd Overdelivery'
    @Common.Heading : 'Unlimited'
    @Common.QuickInfo : 'Unlimited Overdelivery Allowed'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UEBTK'
    UnlimitedOverdeliveryIsAllowed : Boolean not null;
    @Common.Label : 'Overdeliv. Tolerance'
    @Common.Heading : 'Overdel. Tol.'
    @Common.QuickInfo : 'Overdelivery Tolerance'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UEBTO'
    OverdelivTolrtdLmtRatioInPct : Decimal(3, 1) not null;
    @Common.Label : 'Underdel. Tolerance'
    @Common.Heading : 'Underdel.Tol.'
    @Common.QuickInfo : 'Underdelivery Tolerance'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UNTTO'
    UnderdelivTolrtdLmtRatioInPct : Decimal(3, 1) not null;
    @Common.Label : 'Requisitioner'
    @Common.Heading : 'Requisnr.'
    @Common.QuickInfo : 'Name of requisitioner/requester'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AFNAM'
    RequisitionerName : String(12) not null;
    @Common.Label : 'Planned Deliv. Time'
    @Common.Heading : 'PTm'
    @Common.QuickInfo : 'Planned Delivery Time in Days'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EPLIF'
    PlannedDeliveryDurationInDays : Decimal(precision: 3) not null;
    @Common.Label : 'GR processing time'
    @Common.Heading : 'GRT'
    @Common.QuickInfo : 'Goods receipt processing time in days'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WEBAZ'
    GoodsReceiptDurationInDays : Decimal(precision: 3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Partial Deliv./Item'
    @Common.Heading : 'PD'
    @Common.QuickInfo : 'Partial Delivery at Item Level (Stock Transfer)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZTUL'
    PartialDeliveryIsAllowed : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Consumption'
    @Common.Heading : 'Cns'
    @Common.QuickInfo : 'Consumption posting'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZVBR'
    ConsumptionPosting : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Service Performer'
    @Common.Heading : 'SrvPrfm'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SERVICEPERFORMER'
    ServicePerformer : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Package number'
    @Common.Heading : 'Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PACKNO'
    ServicePackage : String(10) not null;
    @Common.IsUnit : true
    @Common.Label : 'Base Unit of Measure'
    @Common.Heading : 'BUn'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAGME'
    BaseUnit : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Item Category'
    @Common.Heading : 'I'
    @Common.QuickInfo : 'Item category in purchasing document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PSTYP'
    PurchaseOrderItemCategory : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Profit Center'
    @Common.Heading : 'Profit Ctr'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PRCTR'
    ProfitCenter : String(10) not null;
    @Common.IsUnit : true
    @Common.Label : 'Order Price Unit'
    @Common.Heading : 'OPU'
    @Common.QuickInfo : 'Order Price Unit (Purchasing)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BBPRM'
    OrderPriceUnit : String(3) not null;
    @Common.IsUnit : true
    @Common.Label : 'Volume Unit'
    @Common.Heading : 'VUn'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VOLEH'
    ItemVolumeUnit : String(3) not null;
    @Common.IsUnit : true
    @Common.Label : 'Unit of Weight'
    @Common.Heading : 'Un'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EGEWE'
    ItemWeightUnit : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Distribut. Indicator'
    @Common.Heading : 'D'
    @Common.QuickInfo : 'Distribution Indicator for Multiple Account Assignment'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VRTKZ'
    MultipleAcctAssgmtDistribution : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Partial invoice'
    @Common.Heading : 'PIn'
    @Common.QuickInfo : 'Partial invoice indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TWRKZ'
    PartialInvoiceDistribution : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Pricing Date Control'
    @Common.Heading : 'C'
    @Common.QuickInfo : 'Price Determination (Pricing) Date Control'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MEPRF'
    PricingDateControl : String(1) not null;
    @Common.Label : 'Statistical'
    @Common.Heading : 'S'
    @Common.QuickInfo : 'Item is statistical'
    IsStatisticalItem : Boolean not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Higher-Level Item'
    @Common.Heading : 'HLIt'
    @Common.QuickInfo : 'Higher-Level Item in Purchasing Documents'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UEBPO'
    PurchasingParentItem : String(5) not null;
    @Common.Label : 'Latest GR Date'
    @Common.Heading : 'GR Date'
    @Common.QuickInfo : 'Latest Possible Goods Receipt'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LEWED'
    GoodsReceiptLatestCreationDate : Date;
    @Common.Label : 'Returns Item'
    @Common.Heading : 'R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RETPO'
    IsReturnsItem : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Reason for Ordering'
    @Common.Heading : 'OrRea'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BSGRU'
    PurchasingOrderReason : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Incoterms'
    @Common.Heading : 'IncoT'
    @Common.QuickInfo : 'Incoterms (Part 1)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INCO1'
    IncotermsClassification : String(3) not null;
    @Common.Label : 'Incoterms (Part 2)'
    @Common.Heading : 'Inco. 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INCO2'
    IncotermsTransferLocation : String(28) not null;
    @Common.Label : 'Incoterms Location 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INCO2_L'
    IncotermsLocation1 : String(70) not null;
    @Common.Label : 'Incoterms Location 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INCO3_L'
    IncotermsLocation2 : String(70) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Prior Supplier'
    @Common.Heading : 'Prior Spp.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KOLIF'
    PriorSupplier : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'EAN/UPC'
    @Common.QuickInfo : 'International Article Number (EAN/UPC)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EAN11'
    InternationalArticleNumber : String(18) not null;
    @Common.Label : 'Intrastat Srvc. Code'
    @Common.Heading : 'Intrastat Service Code'
    @Common.QuickInfo : 'Intrastat Service Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSAPSLL%2FISVCO'
    IntrastatServiceCode : String(30) not null;
    @Common.Label : 'Commodity Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSAPSLL%2FCOMCO'
    CommodityCode : String(30) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material Freight Grp'
    @Common.Heading : 'MatFrtGp'
    @Common.QuickInfo : 'Material Freight Group'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MFRGR'
    MaterialFreightGroup : String(8) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Qual.f.FreeGoodsDis.'
    @Common.Heading : 'DiK'
    @Common.QuickInfo : 'Material qualifies for discount in kind'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=NRFHG'
    DiscountInKindEligibility : String(1) not null;
    @Common.Label : 'Shipping block'
    @Common.QuickInfo : 'Item blocked for SD delivery'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=NOVET'
    PurgItemIsBlockedForDelivery : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Confirmation Control'
    @Common.Heading : 'Ctr.'
    @Common.QuickInfo : 'Confirmation Control Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BSTAE'
    SupplierConfirmationControlKey : String(4) not null;
    @Common.Label : 'Order Acknowledgment'
    @Common.Heading : 'Acknowledgment'
    @Common.QuickInfo : 'Order Acknowledgment Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LABNR'
    PurgDocOrderAcknNumber : String(20) not null;
    @Common.Label : 'Print Price'
    @Common.Heading : 'P'
    @Common.QuickInfo : 'Price Printout'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PRSDR'
    PriceIsToBePrinted : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Acct Assignment Cat.'
    @Common.Heading : 'A'
    @Common.QuickInfo : 'Account Assignment Category'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KNTTP'
    AccountAssignmentCategory : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Info Rec.'
    @Common.Heading : 'Info Rec.'
    @Common.QuickInfo : 'Purchasing Info Record Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INFNR'
    PurchasingInfoRecord : String(10) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Net Order Value'
    @Common.Heading : 'Net Value'
    @Common.QuickInfo : 'Net Order Value in PO Currency'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BWERT'
    NetAmount : Decimal(precision: 13) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Gross order value'
    @Common.Heading : 'Gross value'
    @Common.QuickInfo : 'Gross order value in PO currency'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BBWERT'
    GrossAmount : Decimal(precision: 13) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Effective value'
    @Common.QuickInfo : 'Effective value of item'
    EffectiveAmount : Decimal(precision: 13) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Subtotal 1'
    @Common.QuickInfo : 'Subtotal 1 from Pricing Procedure for Price Element'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZWI1'
    Subtotal1Amount : Decimal(precision: 13) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Subtotal 2'
    @Common.QuickInfo : 'Subtotal 2 from Pricing Procedure for Price Element'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZWI2'
    Subtotal2Amount : Decimal(precision: 13) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Subtotal 3'
    @Common.QuickInfo : 'Subtotal 3 from Pricing Procedure for Price Element'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZWI3'
    Subtotal3Amount : Decimal(precision: 13) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Subtotal 4'
    @Common.QuickInfo : 'Subtotal 4 from Pricing Procedure for Price Element'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZWI4'
    Subtotal4Amount : Decimal(precision: 13) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Subtotal 5'
    @Common.QuickInfo : 'Subtotal 5 from Pricing Procedure for Price Element'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZWI5'
    Subtotal5Amount : Decimal(precision: 13) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Subtotal 6'
    @Common.QuickInfo : 'Subtotal 6 from Pricing Procedure for Price Element'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZWI6'
    Subtotal6Amount : Decimal(precision: 13) not null;
    @Measures.Unit : PurchaseOrderQuantityUnit
    @Common.Label : 'Order Quantity'
    @Common.Heading : 'PO Quantity'
    @Common.QuickInfo : 'Purchase Order Quantity'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BSTMG'
    OrderQuantity : Decimal(13, 3) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Net Order Price'
    @Common.Heading : 'Net Price'
    @Common.QuickInfo : 'Net Price in Purchasing Document (in Document Currency)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BPREI'
    NetPriceAmount : Decimal(precision: 11) not null;
    @Measures.Unit : ItemVolumeUnit
    @Common.Label : 'Volume'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VOLUM'
    ItemVolume : Decimal(13, 3) not null;
    @Measures.Unit : ItemWeightUnit
    @Common.Label : 'Gross Weight'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BRGEW'
    ItemGrossWeight : Decimal(13, 3) not null;
    @Measures.Unit : ItemWeightUnit
    @Common.Label : 'Net Weight'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ENTGE'
    ItemNetWeight : Decimal(13, 3) not null;
    @Common.Label : 'Quantity Conversion'
    @Common.Heading : 'Conv.'
    @Common.QuickInfo : 'Numerator for Conversion of Order Price Unit into Order Unit'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BPUMZ'
    OrderPriceUnitToOrderUnitNmrtr : Decimal(precision: 5) not null;
    @Common.Label : 'Quantity Conversion'
    @Common.Heading : 'Conv.'
    @Common.QuickInfo : 'Denominator for Conv. of Order Price Unit into Order Unit'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BPUMN'
    OrdPriceUnitToOrderUnitDnmntr : Decimal(precision: 5) not null;
    @Common.Label : 'GR Non-Valuated'
    @Common.Heading : 'N'
    @Common.QuickInfo : 'Goods Receipt, Non-Valuated'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WEUNB'
    GoodsReceiptIsNonValuated : Boolean not null;
    @Common.Label : 'Origin Acceptance'
    @Common.Heading : 'OA'
    @Common.QuickInfo : 'Acceptance At Origin'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WEORA'
    IsToBeAcceptedAtOrigin : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Tax Code'
    @Common.Heading : 'Tx'
    @Common.QuickInfo : 'Tax on Sales/Purchases Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MWSKZ'
    TaxCode : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Tax Jurisdiction'
    @Common.Heading : 'Tax Jur.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TXJCD'
    TaxJurisdiction : String(15) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Tax Ctry/Reg.'
    @Common.Heading : 'Tax Country/Region'
    @Common.QuickInfo : 'Tax Reporting Country/Region'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FOT_TAX_COUNTRY'
    TaxCountry : String(3) not null;
    @Common.Label : 'Tax Date'
    @Common.QuickInfo : 'Date for Determining Tax Rates'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TXDAT'
    TaxDeterminationDate : Date;
    @Common.IsUpperCase : true
    @Common.Label : 'Shipping Instruction'
    @Common.Heading : 'SI'
    @Common.QuickInfo : 'Shipping Instructions'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EVERS'
    ShippingInstruction : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Revision Level'
    MaterialRevisionLevel : String(2) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Non-deductible'
    @Common.QuickInfo : 'Non-deductible input tax'
    NonDeductibleInputTaxAmount : Decimal(precision: 13) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Stock Type'
    @Common.Heading : 'T'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=INSMK'
    StockType : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Valuation Type'
    @Common.Heading : 'Val. Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BWTAR_D'
    ValuationType : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Valuation Category'
    @Common.Heading : 'ValCat'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BWTTY_D'
    ValuationCategory : String(1) not null;
    @Common.Label : 'Rejection Indicator'
    @Common.Heading : 'R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ABSKZ'
    ItemIsRejectedBySupplier : Boolean not null;
    @Common.Label : 'Price Date'
    @Common.QuickInfo : 'Date of Price Determination'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PREDT'
    PurgDocPriceDate : Date;
    @Common.IsUpperCase : true
    @Common.Label : 'Info Record Update'
    @Common.Heading : 'I'
    @Common.QuickInfo : 'Indicator: Update Info Record'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SPINF'
    PurchasingInfoRecordUpdateCode : String(1) not null;
    @Common.Label : 'Estimated Price'
    @Common.Heading : 'E'
    @Common.QuickInfo : 'Indicator: Estimated Price'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SCHPR'
    PurchasingPriceIsEstimated : Boolean not null;
    @Common.Label : 'Srv.-Based Inv. Ver.'
    @Common.Heading : 'Service-Based Invoice Verification'
    @Common.QuickInfo : 'Indicator for Service-Based Invoice Verification'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LEBRE'
    InvoiceIsMMServiceEntryBased : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Special Stock'
    @Common.Heading : 'S'
    @Common.QuickInfo : 'Special Stock Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SOBKZ'
    InventorySpecialStockType : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Del. Type f. Returns'
    @Common.Heading : 'Del. Type Returns'
    @Common.QuickInfo : 'Delivery Type for Returns to Supplier'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LFRET'
    DeliveryDocumentType : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Issuing Storage Loc.'
    @Common.Heading : 'IStLoc'
    @Common.QuickInfo : 'Issuing Storage Location for Stock Transport Order'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RESLO'
    IssuingStorageLocation : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Allocation Table'
    @Common.Heading : 'Alloc.Tab.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ABELN'
    AllocationTable : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Item'
    @Common.Heading : 'Itm'
    @Common.QuickInfo : 'Allocation Table Item'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ABELP'
    AllocationTableItem : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Retail Promotion'
    @Common.Heading : 'Promotion'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WAKTION'
    RetailPromotion : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Hierarchy Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EXLIN'
    PurgConfigurableItemNumber : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Sub-items'
    @Common.Heading : 'S'
    @Common.QuickInfo : 'Subitems Exist'
    PurgDocAggrgdSubitemCategory : String(1) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'External Sort No.'
    @Common.Heading : 'External Sort Number'
    @Common.QuickInfo : 'External Sort Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EXSNR'
    PurgExternalSortNumber : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Batch'
    @Common.QuickInfo : 'Batch Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CHARG_D'
    Batch : String(10) not null;
    @Common.Label : 'Free of Charge'
    @Common.Heading : 'Free'
    @Common.QuickInfo : 'Free Item'
    PurchasingItemIsFreeOfCharge : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Down Payment'
    @Common.QuickInfo : 'Down Payment Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ME_DPTYP'
    DownPaymentType : String(4) not null;
    @Common.Label : 'Down Payment %'
    @Common.Heading : 'Down Payt Percentage'
    @Common.QuickInfo : 'Down Payment Percentage'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ME_DPPCNT'
    DownPaymentPercentageOfTotAmt : Decimal(5, 2) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Down Payment Amount'
    @Common.QuickInfo : 'Down Payment Amount in Document Currency'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ME_DPAMNT'
    DownPaymentAmount : Decimal(precision: 11) not null;
    @Common.Label : 'Due Date for DP'
    @Common.Heading : 'Due Date for Down Payment'
    @Common.QuickInfo : 'Due Date for Down Payment'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ME_DPDDAT'
    DownPaymentDueDate : Date;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Expected Value'
    @Common.QuickInfo : 'Expected Value of Overall Limit'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=COMMITMENT'
    ExpectedOverallLimitAmount : Decimal(precision: 13) not null;
    @Measures.ISOCurrency : DocumentCurrency
    @Common.Label : 'Overall Limit'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SUMLIMIT'
    OverallLimitAmount : Decimal(precision: 13) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Contract for Limit'
    @Common.QuickInfo : 'Purchase Contract for Enhanced Limit'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CTR_FOR_LIMIT'
    PurContractForOverallLimit : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'PurCon Itm for Limit'
    @Common.Heading : 'Purchase Contract Reference Item for Enhanced Limit Itm'
    @Common.QuickInfo : 'Purchase Contract Reference Item for Enhanced Limit Item'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CTR_ITEM_FOR_LIMIT'
    PurContractItemForOverallLimit : String(5) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier Check Sts'
    @Common.Heading : 'Supplier Ck Sts'
    @Common.QuickInfo : 'Product Compliance Supplier Check Status (Item)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_PC_STATUS_PCS'
    PurgProdCmplncSupplierStatus : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Prod. Marktablty Sts'
    @Common.Heading : 'ProdMarktabltyS'
    @Common.QuickInfo : 'Product Marketability Status (Item)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_PC_STATUS_PMA'
    PurgProductMarketabilityStatus : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Sfty Data Sheet Sts'
    @Common.Heading : 'SftyDataSheetS'
    @Common.QuickInfo : 'Safety Data Sheet Status (Item)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_PC_STATUS_SDS'
    PurgSafetyDataSheetStatus : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Dangerous Goods Sts'
    @Common.Heading : 'Dngrs Goods Sts'
    @Common.QuickInfo : 'Dangerous Goods Status (Item)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_PC_STATUS_DG'
    PurgProdCmplncDngrsGoodsStatus : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material Origin'
    @Common.Heading : 'O'
    @Common.QuickInfo : 'Origin of the material'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=J_1BMATORG'
    BR_MaterialOrigin : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Material Usage'
    @Common.QuickInfo : 'Usage of the material'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=J_1BMATUSE'
    BR_MaterialUsage : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Matl. CFOP Category'
    @Common.Heading : 'Material CFOP Category'
    @Common.QuickInfo : 'Material CFOP Category'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=J_1BINDUS3'
    BR_CFOPCategory : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'NCM Code'
    @Common.QuickInfo : 'Brazilian NCM Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=J_1BNBMCO1'
    BR_NCM : String(16) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'HSN/SAC Code'
    @Common.QuickInfo : 'HSN or SAC Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=J_1IG_HSN_SAC'
    ConsumptionTaxCtrlCode : String(16) not null;
    @Common.Label : 'In-House Production'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=J_1BOWNPRO'
    BR_IsProducedInHouse : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Season Year'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FSH_SAISJ'
    ProductSeasonYear : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Season'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FSH_SAISO'
    ProductSeason : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Collection'
    @Common.QuickInfo : 'Fashion Collection'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FSH_COLLECTION'
    ProductCollection : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Theme'
    @Common.QuickInfo : 'Fashion Theme'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FSH_THEME'
    ProductTheme : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Season Comp.Ind'
    @Common.Heading : 'Season Completeness Indicator'
    @Common.QuickInfo : 'Season Completeness Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RFM_SCC_INDICATOR'
    SeasonCompletenessStatus : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PSST Grouping Rule'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RFM_PSST_RULE'
    ShippingGroupRule : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PSST Group'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RFM_PSST_GROUP_ID'
    ShippingGroupNumber : String(10) not null;
    @Common.Label : 'Characteristic 1'
    @Common.Heading : 'Characteristic Value 1'
    @Common.QuickInfo : 'Characteristic Value 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WRF_CHARSTC1'
    ProductCharacteristic1 : String(18) not null;
    @Common.Label : 'Characteristic 2'
    @Common.Heading : 'Characteristic Value 2'
    @Common.QuickInfo : 'Characteristic Value 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WRF_CHARSTC2'
    ProductCharacteristic2 : String(18) not null;
    @Common.Label : 'Characteristic 3'
    @Common.Heading : 'Characteristic Value 3'
    @Common.QuickInfo : 'Characteristic Value 3'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WRF_CHARSTC3'
    ProductCharacteristic3 : String(18) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Subitem Category'
    @Common.Heading : 'S'
    @Common.QuickInfo : 'Subitem Category, Purchasing Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=UPTYP'
    PurgDocSubitemCategory : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Diversion Status'
    @Common.Heading : 'Status of Diversion process'
    @Common.QuickInfo : 'Status of Diversion process'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RFM_DIVERSION_STATUS'
    DiversionStatus : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Reference Document'
    @Common.Heading : 'Reference Document for PO Traceability'
    @Common.QuickInfo : 'Reference Document number for PO Traceability'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RFM_REF_DOC'
    ReferenceDocumentNumber : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Reference Item'
    @Common.Heading : 'Reference Item for PO'
    @Common.QuickInfo : 'Reference Item number for PO Traceability'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RFM_REF_ITEM'
    ReferenceDocumentItem : String(6) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Reference Action'
    @Common.Heading : 'Reference Split Action in PO'
    @Common.QuickInfo : 'Action for Traceability in  PO'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RFM_REF_ACTION'
    PurchaseOrderReferenceType : String(1) not null;
    @Common.Label : 'VAS Relevant'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FSH_VAS_REL'
    ItemHasValueAddedService : Boolean not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Item'
    @Common.QuickInfo : 'Item Number of Purchasing Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EBELP'
    ValAddedSrvcParentItmNumber : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Stock Segment'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SGT_SCAT'
    StockSegment : String(40) not null;
    @Common.Label : 'Retention %'
    @Common.Heading : 'Retention in Percent'
    @Common.QuickInfo : 'Retention in Percent'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=RETPZ'
    PurOrdItmInvcRtntnPct : Decimal(5, 2) not null;
    SAP__Messages : many SAP__Message not null;
    @Common.Composition : true
    _DeliveryAddress : Composition of one PurOrderItemDeliveryAddress on _DeliveryAddress._PurchaseOrderItem = $self;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
    @Common.Composition : true
    @Validation.MaxItems : 1
    _PurchaseOrderInvoicingPlan : Composition of many PurchaseOrderInvoicingPlan on _PurchaseOrderInvoicingPlan._PurchaseOrderItem = $self;
    @Common.Composition : true
    _PurchaseOrderItemNote : Composition of many PurchaseOrderItemNote on _PurchaseOrderItemNote._PurchaseOrderItem = $self;
    @Common.Composition : true
    _PurchaseOrderScheduleLineTP : Composition of many PurchaseOrderScheduleLine on _PurchaseOrderScheduleLineTP._PurchaseOrderItem = $self;
    @Common.Composition : true
    _PurOrdAccountAssignment : Composition of many PurchaseOrderAccountAssignment on _PurOrdAccountAssignment._PurchaseOrderItem = $self;
    @Common.Composition : true
    _PurOrdPricingElement : Composition of many PurOrderItemPricingElement on _PurOrdPricingElement._PurchaseOrderItem = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Item Notes'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.FilterRestrictions.Filterable : true
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [ { Property: PlainLongText, AllowedExpressions: 'SearchExpression' } ]
  @Capabilities.SortRestrictions.NonSortableProperties : [ 'PlainLongText' ]
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrder', '_PurchaseOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  entity PurchaseOrderItemNote {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchase Order'
    @Common.Heading : 'Purchase Order Number'
    @Common.QuickInfo : 'Purchase Order Number'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Purchase Order Item'
    @Common.Heading : 'Item Number of Purchase Order'
    @Common.QuickInfo : 'Item Number of Purchase Order'
    key PurchaseOrderItem : String(5) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Text ID'
    @Common.Heading : 'ID'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TDID'
    key TextObjectType : String(4) not null;
    @Core.ComputedDefaultValue : true
    @Common.Label : 'Language Key'
    @Common.Heading : 'Language'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SPRAS'
    key Language : String(2) not null;
    @Common.Label : 'Long Text'
    PlainLongText : String not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Document Item'
    @Common.Heading : 'Item'
    @Common.QuickInfo : 'Concatenation of EBELN and EBELP'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PURCHASINGDOCUMENTITEMUNIQUEID'
    PurchaseOrderItemUniqueID : String(15) not null;
    SAP__Messages : many SAP__Message not null;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
    _PurchaseOrderItem : Association to one PurchaseOrderItem on _PurchaseOrderItem.PurchaseOrderItem = PurchaseOrderItem;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Header Notes'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.FilterRestrictions.Filterable : true
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [ { Property: PlainLongText, AllowedExpressions: 'SearchExpression' } ]
  @Capabilities.SortRestrictions.NonSortableProperties : [ 'PlainLongText' ]
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrder' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  entity PurchaseOrderNote {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchase Order'
    @Common.Heading : 'Purchase Order Number'
    @Common.QuickInfo : 'Purchase Order Number'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Text ID'
    @Common.Heading : 'ID'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TDID'
    key TextObjectType : String(4) not null;
    @Core.ComputedDefaultValue : true
    @Common.Label : 'Language Key'
    @Common.Heading : 'Language'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SPRAS'
    key Language : String(2) not null;
    @Common.Label : 'Long Text'
    PlainLongText : String not null;
    SAP__Messages : many SAP__Message not null;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Partner'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrderTP,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.ReadRestrictions.Readable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrderTP' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  entity PurchaseOrderPartner {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Document'
    @Common.Heading : 'Pur. Doc.'
    @Common.QuickInfo : 'Purchasing Document Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EBELN'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Function'
    @Common.Heading : 'PartF'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PARVW_UNV'
    key PartnerFunction : String(2) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier Subrange'
    @Common.Heading : 'SSR'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LTSNR'
    SupplierSubrange : String(6) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Plant'
    @Common.Heading : 'Plnt'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WERKS_D'
    Plant : String(4) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purch. Organization'
    @Common.Heading : 'POrg'
    @Common.QuickInfo : 'Purchasing Organization'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EKORG'
    PurchasingOrganization : String(4) not null;
    @Core.Computed : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Partner counter'
    @Common.Heading : 'ParC'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PARZA'
    PartnerCounter : String(3) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Created By'
    @Common.QuickInfo : 'Name of Person Responsible for Creating the Object'
    CreatedByUser : String(12) not null;
    @Core.Computed : true
    @Common.Label : 'Created On'
    @Common.QuickInfo : 'Record Creation Date'
    CreationDate : Date;
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Type'
    @Common.Heading : 'NoTy.'
    @Common.QuickInfo : 'Type of partner number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=NRART'
    PurchasingDocumentPartnerType : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier'
    @Common.QuickInfo : 'Account Number of Supplier'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LIFNR'
    Supplier : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Hierarchy Cat.'
    @Common.Heading : 'Hierarchy Category Supplier'
    @Common.QuickInfo : 'Hierarchy Category: Supplier Hierarchy'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=HITYP_LH'
    SupplierHierarchyCategory : String(1) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Contact Person'
    @Common.Heading : 'Partner'
    @Common.QuickInfo : 'Number of Contact Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PARNR'
    SupplierContact : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Personnel Number'
    @Common.Heading : 'Pers.No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PERNR_D'
    PersonWorkAgreement : String(8) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Personnel Number'
    @Common.Heading : 'Pers.No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PERNR_D'
    EmploymentInternalID : String(8) not null;
    @Core.Computed : true
    @Common.Label : 'Default Partner'
    @Common.Heading : 'D'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=DEFPA'
    DefaultPartner : Boolean not null;
    _PurchaseOrderTP : Association to one PurchaseOrder on _PurchaseOrderTP.PurchaseOrder = PurchaseOrder;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Schedule Lines'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderItem,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _SubcontractingComponent,
      InsertRestrictions: { Insertable: true }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrder', '_PurchaseOrderItem', '_SubcontractingComponent' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: ScheduleLineOrderQuantity, AllowedExpressions: 'MultiValue' },
    { Property: OpenPurchaseOrderQuantity, AllowedExpressions: 'MultiValue' }
  ]
  entity PurchaseOrderScheduleLine {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Document'
    @Common.Heading : 'Pur. Doc.'
    @Common.QuickInfo : 'Purchasing Document Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EBELN'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Item'
    @Common.QuickInfo : 'Item Number of Purchasing Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EBELP'
    key PurchaseOrderItem : String(5) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Schedule Line'
    @Common.Heading : 'Schd.'
    @Common.QuickInfo : 'Delivery Schedule Line Counter'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EETEN'
    key ScheduleLine : String(4) not null;
    @Common.Label : 'Delivery Date'
    @Common.Heading : 'Deliv. Date'
    @Common.QuickInfo : 'Item Delivery Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EINDT'
    ScheduleLineDeliveryDate : Date;
    @Common.Label : 'Stat.-Rel. Del. Date'
    @Common.Heading : 'StatDelD'
    @Common.QuickInfo : 'Statistics-Relevant Delivery Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SLFDT'
    SchedLineStscDeliveryDate : Date;
    @Common.Label : 'Start Date'
    @Common.QuickInfo : 'Start Date for Period of Performance'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_SERVPROC_PERIOD_START'
    PerformancePeriodStartDate : Date;
    @Common.Label : 'End Date'
    @Common.QuickInfo : 'End Date for Period of Performance'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MMPUR_SERVPROC_PERIOD_END'
    PerformancePeriodEndDate : Date;
    @Common.Label : 'Time'
    @Common.QuickInfo : 'Delivery Date Time-Spot'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LZEIT'
    ScheduleLineDeliveryTime : Time not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Batch'
    @Common.QuickInfo : 'Batch Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CHARG_D'
    Batch : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier Batch'
    @Common.QuickInfo : 'Supplier Batch Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LICHN'
    BatchBySupplier : String(15) not null;
    @Measures.Unit : PurchaseOrderQuantityUnit
    @Common.Label : 'Scheduled Quantity'
    @Common.Heading : 'Scheduled Qty'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ETMEN'
    ScheduleLineOrderQuantity : Decimal(13, 3) not null;
    @Measures.Unit : PurchaseOrderQuantityUnit
    OpenPurchaseOrderQuantity : Decimal(14, 3) not null;
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Order Unit'
    @Common.Heading : 'OUn'
    @Common.QuickInfo : 'Purchase Order Unit of Measure'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BSTME'
    PurchaseOrderQuantityUnit : String(3) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Currency'
    @Common.Heading : 'Crcy'
    @Common.QuickInfo : 'Currency Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WAERS'
    Currency : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Purchase Requisition'
    @Common.Heading : 'Purch.Req.'
    @Common.QuickInfo : 'Purchase Requisition Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BANFN'
    PurchaseRequisition : String(10) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Item of requisition'
    @Common.Heading : 'Item'
    @Common.QuickInfo : 'Item Number of Purchase Requisition'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BNFPO'
    PurchaseRequisitionItem : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Deliv. date category'
    @Common.Heading : 'C'
    @Common.QuickInfo : 'Category of delivery date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LPEIN'
    DelivDateCategory : String(1) not null;
    @Common.Label : 'Purchase Order Date'
    @Common.Heading : 'Order date'
    @Common.QuickInfo : 'Order date of schedule line'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=ETBDT'
    ScheduleLineOrderDate : Date;
    @Common.Label : 'Material Avail. Date'
    @Common.Heading : 'Mat.Av.Dt.'
    @Common.QuickInfo : 'Material Staging/Availability Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MBDAT'
    ProductAvailabilityDate : Date;
    @Common.Label : 'Loading Date'
    @Common.Heading : 'Loadg Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LDDAT'
    LoadingDate : Date;
    @Common.Label : 'Loading Time'
    @Common.Heading : 'Loadg Time'
    @Common.QuickInfo : 'Loading Time (Local Time Relating to a Shipping Point)'
    LoadingTime : Time not null;
    @Common.Label : 'Transptn Plang Date'
    @Common.Heading : 'TrpPlanDt'
    @Common.QuickInfo : 'Transportation Planning Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TDDAT_D'
    TransportationPlanningDate : Date;
    @Common.Label : 'Transp. Plan. Time'
    @Common.Heading : 'TP Time'
    @Common.QuickInfo : 'Transp. Planning Time (Local, Relating to a Shipping Point)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TDUHR'
    TransportationPlanningTime : Time not null;
    @Common.Label : 'Goods Issue Date'
    @Common.Heading : 'GI Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WADAT'
    GoodsIssueDate : Date;
    @Common.Label : 'Goods Issue Time'
    @Common.Heading : 'GI Time'
    @Common.QuickInfo : 'Time of Goods Issue (Local, Relating to a Plant)'
    GoodsIssueTime : Time not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Route Schedule'
    @Common.Heading : 'RSch'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AULWE'
    RouteSchedule : String(10) not null;
    @Common.Label : 'Matl Staging Time'
    @Common.Heading : 'Stag. Time'
    @Common.QuickInfo : 'Material Staging Time (Local, Relating to a Plant)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MBUHR'
    ProductAvailabilityTime : Time not null;
    SAP__Messages : many SAP__Message not null;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
    _PurchaseOrderItem : Association to one PurchaseOrderItem on _PurchaseOrderItem.PurchaseOrderItem = PurchaseOrderItem;
    @Common.Composition : true
    _SubcontractingComponent : Composition of many POSubcontractingComponent on _SubcontractingComponent._ScheduleLine = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Supplier Address'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrderTP,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.ReadRestrictions.Readable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrderTP' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  entity PurchaseOrderSupplierAddress {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    key SupplierAddressID : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchase Order'
    @Common.Heading : 'Purchase Order Number'
    @Common.QuickInfo : 'Purchase Order Number'
    key PurchaseOrder : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Person Number'
    @Common.Heading : 'Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PERSNUM'
    AddressPersonID : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Version'
    @Common.Heading : 'Version'
    @Common.QuickInfo : 'Version ID for International Addresses'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NATION'
    AddressRepresentationCode : String(1) not null;
    @Common.Label : 'Language Key'
    @Common.Heading : 'Language'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SPRAS'
    CorrespondenceLanguage : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Comm. Method'
    @Common.QuickInfo : 'Communication Method (Key) (Business Address Services)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_COMM'
    PrfrdCommMediumType : String(3) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'Name'
    @Common.QuickInfo : 'Name 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAME1'
    OrganizationName1 : String(40) not null;
    @Common.Label : 'Name 2'
    OrganizationName2 : String(40) not null;
    @Common.Label : 'Name 3'
    OrganizationName3 : String(40) not null;
    @Common.Label : 'Name 4'
    OrganizationName4 : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Search Term 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SORT1'
    AddressSearchTerm1 : String(20) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Search Term 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SORT2'
    AddressSearchTerm2 : String(20) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.Label : 'District'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY2'
    DistrictName : String(40) not null;
    @Common.Label : 'Different City'
    @Common.Heading : 'City (Diff. from Postal City)'
    @Common.QuickInfo : 'City (different from postal city)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY3'
    VillageName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Company Postal Code'
    @Common.Heading : 'Postl Code'
    @Common.QuickInfo : 'Company Postal Code (for Large Customers)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD3'
    CompanyPostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'Street 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STRSPP1'
    StreetPrefixName1 : String(40) not null;
    @Common.Label : 'Street 3'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STRSPP2'
    StreetPrefixName2 : String(40) not null;
    @Common.Label : 'Street 4'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STRSPP3'
    StreetSuffixName1 : String(40) not null;
    @Common.Label : 'Street 5'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_LCTN'
    StreetSuffixName2 : String(40) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.Label : 'Supplement'
    @Common.QuickInfo : 'House number supplement'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM2'
    HouseNumberSupplementText : String(10) not null;
    @Common.Label : 'Building Code'
    @Common.Heading : 'Building'
    @Common.QuickInfo : 'Building (Number or Code)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_BLDNG'
    Building : String(20) not null;
    @Common.Label : 'Floor'
    @Common.QuickInfo : 'Floor in Building'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_FLOOR'
    Floor : String(10) not null;
    @Common.Label : 'Room Number'
    @Common.Heading : 'Room No.'
    @Common.QuickInfo : 'Room or Apartment Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ROOMNUM'
    RoomNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Title Key'
    @Common.Heading : 'Key'
    @Common.QuickInfo : 'Form-of-Address Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TITLE'
    FormOfAddress : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Tax Jurisdiction'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TXJCD'
    TaxJurisdiction : String(15) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Zone'
    @Common.Heading : 'TranspZone'
    @Common.QuickInfo : 'Transportation zone to or from which the goods are delivered'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LZONE'
    TransportZone : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PO Box'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBX'
    POBox : String(10) not null;
    @Common.Label : 'PO Box w/o No.'
    @Common.Heading : 'PO'
    @Common.QuickInfo : 'Flag: PO Box Without Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBXNUM'
    POBoxIsWithoutNumber : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PO Box Postal Code'
    @Common.Heading : 'Postl Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD2'
    POBoxPostalCode : String(10) not null;
    @Common.Label : 'PO Box Lobby'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PO_BOX_LBY'
    POBoxLobbyName : String(40) not null;
    @Common.Label : 'PO Box City'
    @Common.QuickInfo : 'PO Box city'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBXLOC'
    POBoxDeviatingCityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PO Box Region'
    @Common.Heading : 'PO Region'
    @Common.QuickInfo : 'Region for PO Box (Country/Region, State, Province, ...)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBXREG'
    POBoxDeviatingRegion : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PO Box Ctry/Region'
    @Common.Heading : 'PO C/R'
    @Common.QuickInfo : 'PO Box of Country/Region'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBXCTY'
    POBoxDeviatingCountry : String(3) not null;
    @Common.Label : 'c/o'
    @Common.Heading : 'c/o name'
    @Common.QuickInfo : 'c/o name'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAME_CO'
    CareOfName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Delvry Serv Type'
    @Common.QuickInfo : 'Type of Delivery Service'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_DELIVERY_SERVICE_TYPE'
    DeliveryServiceTypeCode : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Delivery Service No.'
    @Common.Heading : 'Delivery Service Number'
    @Common.QuickInfo : 'Number of Delivery Service'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_DELIVERY_SERVICE_NUMBER'
    DeliveryServiceNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Time Zone'
    @Common.Heading : 'Zone'
    @Common.QuickInfo : 'Address Time Zone'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TZONE'
    AddressTimeZone : String(6) not null;
    @Common.Label : 'Email Address'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SMTPADR'
    EmailAddress : String(241) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Test Stat./City File'
    @Common.Heading : 'Status'
    @Common.QuickInfo : 'City File Test Status'
    RegionalStructureCheckStatus : String(1) not null;
    _PurchaseOrderTP : Association to one PurchaseOrder on _PurchaseOrderTP.PurchaseOrder = PurchaseOrder;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Item Delivery Address'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.ReadRestrictions.Readable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrder', '_PurchaseOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  entity PurOrderItemDeliveryAddress {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Document'
    @Common.Heading : 'Pur. Doc.'
    @Common.QuickInfo : 'Purchasing Document Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EBELN'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Purchase Order Item'
    @Common.Heading : 'Item Number of Purchase Order'
    @Common.QuickInfo : 'Item Number of Purchase Order'
    key PurchaseOrderItem : String(5) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Address'
    @Common.QuickInfo : 'Manual address number in purchasing document item'
    key DeliveryAddressID : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Person Number'
    @Common.Heading : 'Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PERSNUM'
    AddressPersonID : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Version'
    @Common.Heading : 'Version'
    @Common.QuickInfo : 'Version ID for International Addresses'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NATION'
    AddressRepresentationCode : String(1) not null;
    @Common.Label : 'Language Key'
    @Common.Heading : 'Language'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SPRAS'
    CorrespondenceLanguage : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Comm. Method'
    @Common.QuickInfo : 'Communication Method (Key) (Business Address Services)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_COMM'
    PrfrdCommMediumType : String(3) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'Name'
    @Common.QuickInfo : 'Name 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAME1'
    OrganizationName1 : String(40) not null;
    @Common.Label : 'Name 2'
    OrganizationName2 : String(40) not null;
    @Common.Label : 'Name 3'
    OrganizationName3 : String(40) not null;
    @Common.Label : 'Name 4'
    OrganizationName4 : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Search Term 1'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SORT1'
    AddressSearchTerm1 : String(20) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Search Term 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SORT2'
    AddressSearchTerm2 : String(20) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.Label : 'District'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY2'
    DistrictName : String(40) not null;
    @Common.Label : 'Different City'
    @Common.Heading : 'City (Diff. from Postal City)'
    @Common.QuickInfo : 'City (different from postal city)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY3'
    VillageName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Company Postal Code'
    @Common.Heading : 'Postl Code'
    @Common.QuickInfo : 'Company Postal Code (for Large Customers)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD3'
    CompanyPostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'Street 2'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STRSPP1'
    StreetPrefixName1 : String(40) not null;
    @Common.Label : 'Street 3'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STRSPP2'
    StreetPrefixName2 : String(40) not null;
    @Common.Label : 'Street 4'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STRSPP3'
    StreetSuffixName1 : String(40) not null;
    @Common.Label : 'Street 5'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_LCTN'
    StreetSuffixName2 : String(40) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.Label : 'Supplement'
    @Common.QuickInfo : 'House number supplement'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM2'
    HouseNumberSupplementText : String(10) not null;
    @Common.Label : 'Building Code'
    @Common.Heading : 'Building'
    @Common.QuickInfo : 'Building (Number or Code)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_BLDNG'
    Building : String(20) not null;
    @Common.Label : 'Floor'
    @Common.QuickInfo : 'Floor in Building'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_FLOOR'
    Floor : String(10) not null;
    @Common.Label : 'Room Number'
    @Common.Heading : 'Room No.'
    @Common.QuickInfo : 'Room or Apartment Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ROOMNUM'
    RoomNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Title Key'
    @Common.Heading : 'Key'
    @Common.QuickInfo : 'Form-of-Address Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TITLE'
    FormOfAddress : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Tax Jurisdiction'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TXJCD'
    TaxJurisdiction : String(15) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Zone'
    @Common.Heading : 'TranspZone'
    @Common.QuickInfo : 'Transportation zone to or from which the goods are delivered'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LZONE'
    TransportZone : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PO Box'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBX'
    POBox : String(10) not null;
    @Common.Label : 'PO Box w/o No.'
    @Common.Heading : 'PO'
    @Common.QuickInfo : 'Flag: PO Box Without Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBXNUM'
    POBoxIsWithoutNumber : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PO Box Postal Code'
    @Common.Heading : 'Postl Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD2'
    POBoxPostalCode : String(10) not null;
    @Common.Label : 'PO Box Lobby'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PO_BOX_LBY'
    POBoxLobbyName : String(40) not null;
    @Common.Label : 'PO Box City'
    @Common.QuickInfo : 'PO Box city'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBXLOC'
    POBoxDeviatingCityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PO Box Region'
    @Common.Heading : 'PO Region'
    @Common.QuickInfo : 'Region for PO Box (Country/Region, State, Province, ...)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBXREG'
    POBoxDeviatingRegion : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'PO Box Ctry/Region'
    @Common.Heading : 'PO C/R'
    @Common.QuickInfo : 'PO Box of Country/Region'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_POBXCTY'
    POBoxDeviatingCountry : String(3) not null;
    @Common.Label : 'c/o'
    @Common.Heading : 'c/o name'
    @Common.QuickInfo : 'c/o name'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAME_CO'
    CareOfName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Delvry Serv Type'
    @Common.QuickInfo : 'Type of Delivery Service'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_DELIVERY_SERVICE_TYPE'
    DeliveryServiceTypeCode : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Delivery Service No.'
    @Common.Heading : 'Delivery Service Number'
    @Common.QuickInfo : 'Number of Delivery Service'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_DELIVERY_SERVICE_NUMBER'
    DeliveryServiceNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Time Zone'
    @Common.Heading : 'Zone'
    @Common.QuickInfo : 'Address Time Zone'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TZONE'
    AddressTimeZone : String(6) not null;
    @Common.Label : 'Email Address'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SMTPADR'
    EmailAddress : String(241) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Test Stat./City File'
    @Common.Heading : 'Status'
    @Common.QuickInfo : 'City File Test Status'
    RegionalStructureCheckStatus : String(1) not null;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
    _PurchaseOrderItem : Association to one PurchaseOrderItem on _PurchaseOrderItem.PurchaseOrderItem = PurchaseOrderItem;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Pricing Element'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _PurchaseOrder,
      InsertRestrictions: { Insertable: false },
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _PurchaseOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_PurchaseOrder', '_PurchaseOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: ConditionRateRatio, AllowedExpressions: 'MultiValue' },
    { Property: ConditionQuantity, AllowedExpressions: 'MultiValue' },
    { Property: CndnRoundingOffDiffAmount, AllowedExpressions: 'MultiValue' },
    { Property: ConditionAmount, AllowedExpressions: 'MultiValue' },
    {
      Property: ConditionAmountInLocalCrcy,
      AllowedExpressions: 'MultiValue'
    },
    { Property: ConditionAdjustedQuantity, AllowedExpressions: 'MultiValue' }
  ]
  entity PurOrderItemPricingElement {
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Purchasing Document'
    @Common.Heading : 'Pur. Doc.'
    @Common.QuickInfo : 'Purchasing Document Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EBELN'
    key PurchaseOrder : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Item'
    @Common.QuickInfo : 'Item Number of Purchasing Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=EBELP'
    key PurchaseOrderItem : String(5) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsUpperCase : true
    @Common.Label : 'Doc. Condition No.'
    @Common.Heading : 'Doc.Cond.'
    @Common.QuickInfo : 'Number of the Document Condition'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KNUMV'
    key PricingDocument : String(10) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Item'
    @Common.Heading : 'ItemNo'
    @Common.QuickInfo : 'Condition item number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KPOSN'
    key PricingDocumentItem : String(6) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Step Number'
    @Common.Heading : 'Step'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=STUNR'
    key PricingProcedureStep : String(3) not null;
    @Core.ComputedDefaultValue : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Counter'
    @Common.Heading : 'Cntr'
    @Common.QuickInfo : 'Condition Counter'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_COND_COUNT'
    key PricingProcedureCounter : String(3) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Application'
    @Common.Heading : 'App'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KAPPL'
    ConditionApplication : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Condition Type'
    @Common.Heading : 'CnTy'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KSCHA'
    ConditionType : String(4) not null;
    @Core.Computed : true
    @Common.Label : 'Condition Pricing Date'
    PriceConditionDeterminationDte : Date;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Calculation Type'
    @Common.Heading : 'CalTy'
    @Common.QuickInfo : 'Calculation Type for Condition'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KRECH_LONG'
    ConditionCalculationType : String(3) not null;
    @Measures.ISOCurrency : TransactionCurrency
    @Common.Label : 'Cndn Bs Amt'
    @Common.Heading : 'Condition Basis Amount'
    @Common.QuickInfo : 'Amount of the Condition Basis'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_BASE_AMOUNT'
    ConditionBaseAmount : Decimal(24, 9) not null;
    @Core.Computed : true
    @Common.Label : 'Condition Basis'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_ELEMENT_BASE_VALUE'
    ConditionBaseValue : Decimal(24, 9) not null;
    @Measures.ISOCurrency : ConditionCurrency
    @Common.Label : 'Condition Amount'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_RATE_AMOUNT'
    ConditionRateAmount : Decimal(24, 9) not null;
    @Measures.Unit : ConditionRateRatioUnit
    @Common.Label : 'Ratio'
    @Common.QuickInfo : 'Condition Ratio (in Percent or Per Mille)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_ELEMENT_RATIO'
    ConditionRateRatio : Decimal(24, 9) not null;
    @Common.IsUnit : true
    @Common.Label : 'Internal UoM'
    @Common.Heading : 'MU'
    @Common.QuickInfo : 'Unit of Measurement'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MSEHI'
    ConditionRateRatioUnit : String(3) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Currency'
    @Common.Heading : 'Crcy'
    @Common.QuickInfo : 'Currency Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WAERS'
    ConditionCurrency : String(3) not null;
    @Core.Computed : true
    @Common.Label : 'Exchange Rate'
    @Common.Heading : 'Exch.Rate'
    @Common.QuickInfo : 'Exchange Rate for Price Determination'
    PriceDetnExchangeRate : Decimal(9, 5) not null;
    @Measures.Unit : ConditionQuantityUnit
    @Common.Label : 'Pricing Unit'
    @Common.Heading : 'per'
    @Common.QuickInfo : 'Condition Pricing Unit'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KPEIN'
    ConditionQuantity : Decimal(precision: 5) not null;
    @Common.IsUnit : true
    @Common.Label : 'Condition Unit'
    @Common.Heading : 'UoM'
    @Common.QuickInfo : 'Condition Unit in the Document'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KVMEI'
    ConditionQuantityUnit : String(3) not null;
    @Common.Label : 'Numerator'
    @Common.QuickInfo : 'Numerator for Converting to Base UoM'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_NUMERATOR'
    ConditionToBaseQtyNmrtr : Decimal(precision: 10) not null;
    @Common.Label : 'Denominator'
    @Common.QuickInfo : 'Denominator for Converting to Base UoM'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_DENOMINATOR'
    ConditionToBaseQtyDnmntr : Decimal(precision: 10) not null;
    @Core.Computed : true
    @Common.Label : 'Condition Category'
    @Common.Heading : 'CdCat'
    @Common.QuickInfo : 'Condition Category (Examples: Tax, Freight, Price, Cost)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KNTYP'
    ConditionCategory : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Statistical'
    @Common.Heading : 'Stat'
    @Common.QuickInfo : 'Condition is used for statistics'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KSTAT'
    ConditionIsForStatistics : Boolean not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Scale Type'
    @Common.Heading : 'S'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=STFKZ'
    PricingScaleType : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Accruals'
    @Common.Heading : 'Accr.'
    @Common.QuickInfo : 'Condition is Relevant for Accrual  (e.g. Freight)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KRUEK'
    IsRelevantForAccrual : Boolean not null;
    @Core.Computed : true
    @Common.Label : 'Invoice List Cond.'
    @Common.Heading : 'InLiC'
    @Common.QuickInfo : 'Condition for Invoice List'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KRELI'
    CndnIsRelevantForInvoiceList : Boolean not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Condition Origin'
    @Common.Heading : 'Orig'
    @Common.QuickInfo : 'Origin of the Condition'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KHERK'
    ConditionOrigin : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Group Condition'
    @Common.Heading : 'GrC'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KGRPE'
    IsGroupCondition : Boolean not null;
    @Core.Computed : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Access'
    @Common.Heading : 'AcNo'
    @Common.QuickInfo : 'Access sequence - Access number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KOLNR'
    AccessNumberOfAccessSequence : String(3) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Condition Record No.'
    @Common.Heading : 'CondRecNo.'
    @Common.QuickInfo : 'Number of Condition Record'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KNUMH'
    ConditionRecord : String(10) not null;
    @Core.Computed : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Sequent.No. of Cond.'
    @Common.Heading : 'No'
    @Common.QuickInfo : 'Sequential Number of the Condition'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KOPOS_LONG'
    ConditionSequentialNumber : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Account Key'
    @Common.Heading : 'ActKy'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KVSL1'
    AccountKeyForGLAccount : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'G/L Account'
    @Common.Heading : 'G/L Acct'
    @Common.QuickInfo : 'G/L Account Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SAKNR'
    GLAccount : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Tax Code'
    @Common.Heading : 'Tx'
    @Common.QuickInfo : 'Tax on Sales/Purchases Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MWSKZ'
    TaxCode : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'AcctKey Accruals'
    @Common.Heading : 'Accrls'
    @Common.QuickInfo : 'Account Key - Accruals / Provisions'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KVSL2'
    AcctKeyForAccrualsGLAccount : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Accruals Account'
    @Common.Heading : 'Accrs.Acc.'
    @Common.QuickInfo : 'Number of Accruals Account'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=SAKNR_ACCR'
    AccrualsGLAccount : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'W/Tax Code'
    @Common.Heading : 'WTx'
    @Common.QuickInfo : 'Withholding Tax Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WT_WITHCD'
    WithholdingTaxCode : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier'
    @Common.QuickInfo : 'Account Number of Supplier'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LIFNR'
    FreightSupplier : String(10) not null;
    @Measures.ISOCurrency : TransactionCurrency
    @Common.Label : 'Condition Rounding Difference'
    @Common.QuickInfo : 'Rounding-Off Difference of a Condition'
    CndnRoundingOffDiffAmount : Decimal(precision: 5) not null;
    @Core.Computed : true
    @Measures.ISOCurrency : TransactionCurrency
    @Common.Label : 'Condition Value'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_ELEMENT_VALUE'
    ConditionAmount : Decimal(precision: 15) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Document Currency'
    @Common.Heading : 'Crcy'
    @Common.QuickInfo : 'SD Document Currency'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=WAERK'
    TransactionCurrency : String(3) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Condition Control'
    @Common.Heading : 'Ctrl'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KSTEU'
    ConditionControl : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Inactive Condition'
    @Common.Heading : 'Inact'
    @Common.QuickInfo : 'Condition is Inactive'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KINAK'
    ConditionInactiveReason : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Condition Class'
    @Common.Heading : 'CCl'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KOAID'
    ConditionClass : String(1) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Counter'
    @Common.Heading : 'Cntr'
    @Common.QuickInfo : 'Condition Counter (Header)'
    PrcgProcedureCounterForHeader : String(3) not null;
    @Core.Computed : true
    @Common.Label : 'Condition Factor'
    @Common.Heading : 'Factor'
    @Common.QuickInfo : 'Factor for Condition Base Value'
    FactorForConditionBasisValue : Double not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Structure Condition'
    @Common.Heading : 'StrucC'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KDUPL'
    StructureCondition : String(1) not null;
    @Common.Label : 'Condition Factor'
    @Common.Heading : 'Factor'
    @Common.QuickInfo : 'Factor for Condition Basis (Period)'
    PeriodFactorForCndnBasisValue : Double not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Scale Basis'
    @Common.Heading : 'ScBas'
    @Common.QuickInfo : 'Scale Basis Indicator'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KZBZG_LONG'
    PricingScaleBasis : String(3) not null;
    @Core.Computed : true
    @Common.Label : 'Scale Base Val.'
    @Common.Heading : 'Scale Base Value'
    @Common.QuickInfo : 'Scale Base Value'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFRPC_SCALE_BASE_VALUE'
    ConditionScaleBasisValue : Decimal(24, 9) not null;
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Scale Unit of Meas.'
    @Common.Heading : 'UoM'
    @Common.QuickInfo : 'Condition Scale Unit of Measure'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KONMS'
    ConditionScaleBasisUnit : String(3) not null;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Scale Currency'
    @Common.Heading : 'ScCur'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KONWS'
    ConditionScaleBasisCurrency : String(3) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Condition Currency'
    @Common.Heading : 'CnC'
    @Common.QuickInfo : 'Condition Currency (for Cumulation Fields)'
    ConditionAlternativeCurrency : String(3) not null;
    @Measures.ISOCurrency : ConditionAlternativeCurrency
    @Common.Label : 'Condition Value'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_ELEMENT_VALUE'
    ConditionAmountInLocalCrcy : Decimal(precision: 15) not null;
    @Core.Computed : true
    @Common.Label : 'Intercomp.Billing'
    @Common.Heading : 'ICB'
    @Common.QuickInfo : 'Condition for Intercompany Billing'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KFKIV'
    CndnIsRelevantForIntcoBilling : Boolean not null;
    @Core.Computed : true
    @Common.Label : 'Changed Manually'
    @Common.Heading : 'Man'
    @Common.QuickInfo : 'Condition Changed Manually'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KMPRS'
    ConditionIsManuallyChanged : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Price Source'
    @Common.Heading : 'PrSc'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PRSQU1'
    BillingPriceSource : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Jurisdiction level'
    @Common.QuickInfo : 'Tax jurisdiction code level'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TXJCD_LEVEL'
    TaxJurisdictionLevel : String(1) not null;
    @Common.Label : 'BitEncryptFlags'
    @Common.Heading : 'BFlg'
    @Common.QuickInfo : 'Bit encrypted flags in Pricing'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KBFLAG'
    ConditionByteSequence : Binary(2) not null;
    @Core.Computed : true
    @Common.Label : 'Condition Update'
    @Common.Heading : 'CdUpd'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KOUPD'
    CndnIsRelevantForLimitValue : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Maximum Basis Value'
    @Common.Heading : 'MxBV'
    @Common.QuickInfo : 'Indicator for Maximum Condition Basis Value'
    ConditionBasisLimitExceeded : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Maximum Amount'
    @Common.Heading : 'MxAm'
    @Common.QuickInfo : 'Indicator for Maximum Condition Amount'
    ConditionAmountLimitExceeded : String(1) not null;
    @Common.Label : 'Condition Basis'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFPRC_ELEMENT_BASE_VALUE'
    CumulatedConditionBasisValue : Decimal(24, 9) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Customer'
    @Common.QuickInfo : 'Customer number (rebate recipient)'
    CustomerRebateRecipient : String(10) not null;
    @Core.Computed : true
    @Common.Label : 'UsedforVariantConfig'
    @Common.Heading : 'Var.'
    @Common.QuickInfo : 'Condition Used for Variant Configuration'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KVARC'
    ConditionIsForConfiguration : Boolean not null;
    @Common.Label : 'Variant Key'
    @Common.Heading : 'Variant'
    @Common.QuickInfo : 'Variant Condition Key'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VARCOND'
    VariantCondition : String(26) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Rel. for Acct Assigt'
    @Common.Heading : 'AcRel'
    @Common.QuickInfo : 'Relevance for Account Assignment'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KTREL'
    ConditionAcctAssgmtRelevance : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Matrix Maintenance'
    @Common.Heading : 'MM'
    @Common.QuickInfo : 'Indicator: Matrix Maintenance'
    ConditionMatrixMaintRelevance : String(1) not null;
    @Common.Label : 'Form. ID in Document'
    @Common.Heading : 'Formula. ID in Document'
    @Common.QuickInfo : 'Identifier of CPF Formula in Document'
    ConfigblParametersAndFormulas : UUID;
    @Measures.Unit : ConditionQuantityUnit
    @Common.Label : 'Adjusted Qty.'
    @Common.Heading : 'Adj. Qty.'
    @Common.QuickInfo : 'Adjusted Quantity'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KAQTY'
    ConditionAdjustedQuantity : Decimal(31, 14) not null;
    @Common.Label : 'Description'
    ConditionTypeName : String(30) not null;
    @Core.Computed : true
    @Common.Label : 'Condition Unit'
    @Common.Heading : 'Unit'
    @Common.QuickInfo : 'Condition Unit (Currency, Sales Unit, or %)'
    ConditionBaseValueIntlUnit : String(5) not null;
    @Core.Computed : true
    @Common.Label : 'Condition Unit'
    @Common.Heading : 'Unit'
    @Common.QuickInfo : 'Condition Unit (Currency, Sales Unit, or %)'
    ConditionBaseValueUnit : String(5) not null;
    @Core.Computed : true
    @Common.Label : 'Condition Unit'
    @Common.Heading : 'Unit'
    @Common.QuickInfo : 'Condition Unit (Currency, Sales Unit, or %)'
    ConditionRateValueIntlUnit : String(5) not null;
    @Core.Computed : true
    @Common.Label : 'Condition Unit'
    @Common.Heading : 'Unit'
    @Common.QuickInfo : 'Condition Unit (Currency, Sales Unit, or %)'
    ConditionRateValueUnit : String(5) not null;
    @Common.Label : 'Tax Code Description'
    TaxCodeName : String(50) not null;
    ConditionIsDeletable : Boolean not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Procedure'
    @Common.Heading : 'Proc.'
    @Common.QuickInfo : 'Procedure (Pricing, Output Control, Acct. Det., Costing,...)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=KALSM_D'
    PricingProcedure : String(6) not null;
    SuperordinateDocument : String(32) not null;
    SuperordinateDocumentItem : String(70) not null;
    SAP__Messages : many SAP__Message not null;
    _PurchaseOrder : Association to one PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder;
    _PurchaseOrderItem : Association to one PurchaseOrderItem on _PurchaseOrderItem.PurchaseOrderItem = PurchaseOrderItem;
  };
};

