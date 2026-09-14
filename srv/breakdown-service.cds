using { machinebreakdown as breakdown } from '../db/schema/breakdown-schema';

@path: '/machine-breakdown'
service BreakdownService {
    @odata.draft.enabled
    entity Reports as projection on breakdown.BreakdownReports actions {
        action findGuidance();
        action useSuggestedReport();
    };

    @readonly
    entity Equipment as projection on breakdown.Equipment;

    @readonly
    entity EquipmentModels as projection on breakdown.EquipmentModels;

    @readonly
    entity ManualDocuments as projection on breakdown.ManualDocuments
        excluding { chunks };

    @cds.api.ignore
    entity ManualChunks as projection on breakdown.ManualChunks;

    entity GuidanceItems as projection on breakdown.GuidanceItems;
    entity GuidanceSources as projection on breakdown.GuidanceSources;
}

annotate BreakdownService.ManualDocuments with {
    content  @Core.MediaType                   : mimeType
             @Core.ContentDisposition.Filename: fileName
             @Core.ContentDisposition.Type    : 'inline';
    mimeType @Core.IsMediaType;
};
