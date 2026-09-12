using {
    cuid,
    managed
} from '@sap/cds/common';

namespace machinebreakdown;

type ReportStatus : String enum {
    IN_PROGRESS = 'In Progress';
    PREPARED    = 'Prepared';
}

type ManualType : String enum {
    OPERATION_MANUAL = 'Operation Manual';
    SERVICE_MANUAL   = 'Service Manual';
    SAFETY_BULLETIN  = 'Safety Bulletin';
}

type GuidanceType : String enum {
    GENERAL           = 'General';
    PREREQUISITE      = 'Prerequisite';
    WARNING           = 'Warning';
    POSSIBLE_CAUSE    = 'Possible Cause';
    RECOMMENDED_CHECK = 'Recommended Check';
}

entity EquipmentModels : managed {
    key modelID      : String(40);
        name         : String(120);
        manufacturer : String(120);
        isDemoData   : Boolean default true;
}

entity Equipment : managed {
    key equipmentID : String(40);
        name        : String(120);
        model       : Association to EquipmentModels;
        controllerModel : String(40);
        configuration   : String(40);
        location    : String(160);
        isActive    : Boolean default true;
        isDemoData  : Boolean default true;
}

@assert.unique.documentVersion: [documentNumber, version]
entity ManualDocuments : cuid, managed {
    documentNumber : String(40) not null;
    title          : String(180);
    manualType     : ManualType;
    version        : String(30) not null;
    model          : Association to EquipmentModels;
    equipment      : Association to Equipment;
    validFrom      : Date;
    controllerModel: String(40);
    configuration  : String(40);
    validTo        : Date;
    isCurrent      : Boolean default true;
    fileName       : String(255);
    mimeType       : String(100);
    content        : LargeBinary;
    isDemoData     : Boolean default true;

    chunks : Composition of many ManualChunks
        on chunks.document = $self;
}

@assert.unique.documentChunk: [document, chunkNumber]
entity ManualChunks : cuid {
    document    : Association to ManualDocuments;
    pageNumber  : Integer;
    chunkNumber : Integer;
    faultCode   : String(40);
    content     : LargeString;

    @cds.api.ignore
    embedding : Vector(1536);
}

@assert.unique.reportNumber: [reportNumber]
entity BreakdownReports : cuid, managed {
    reportNumber           : String(20) not null;
    businessStatus         : ReportStatus default #IN_PROGRESS;
    equipment              : Association to Equipment;

    observedSymptoms       : LargeString;
    faultCode              : String(40);
    checksAlreadyPerformed : LargeString;
    machineStopped         : Boolean;

    missingInformation          : LargeString;
    suggestedShortDescription   : String(160);
    suggestedDetailedDescription: LargeString;
    guidanceGeneratedAt         : Timestamp;
    guidanceInputHash           : String(64);
    guidanceIsCurrent           : Boolean default false;
    suggestionAdoptedAt         : Timestamp;

    shortDescription            : String(160);
    detailedDescription         : LargeString;
    guidanceItems : Composition of many GuidanceItems
        on guidanceItems.report = $self;
    guidanceSources : Composition of many GuidanceSources
        on guidanceSources.report = $self;
}

entity GuidanceSources : cuid {
    report          : Association to BreakdownReports;
    manualDocument  : Association to ManualDocuments;
    manualChunk     : Association to ManualChunks;
    pageNumber      : Integer;
    excerpt         : LargeString;
    relevanceScore  : Decimal(6,5);
}

entity GuidanceItems : cuid {
    report      : Association to BreakdownReports;
    type        : GuidanceType;
    sequence    : Integer;
    text        : LargeString;
    source      : Association to GuidanceSources;
}
