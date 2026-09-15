using { machinebreakdown as breakdown } from '../db/schema/breakdown-schema';

/**
 * Read-only application service for the maintenance technician workspace.
 * Jobs are local demo records and are restricted to the authenticated
 * technician assigned to them.
 */
@path: '/technician-assistant'
@requires: 'authenticated-user'
service TechnicianAssistantService {

    type ChatCitation {
        manualDocumentID : UUID;
        manualChunkID    : UUID;
        documentNumber   : String(40);
        manualTitle      : String(180);
        manualVersion    : String(30);
        pageNumber       : Integer;
        excerpt          : LargeString;
    }

    type ChatResponse {
        text      : LargeString;
        citations : many ChatCitation;
    }

    @readonly
    @restrict: [{
        grant: ['READ', 'ask'],
        where: 'assignedTechnician = $user'
    }]
    entity Jobs as projection on breakdown.MaintenanceJobs actions {
        /**
         * Answers a technician question using the selected authorized job,
         * validated conversation history and applicable manual passages.
         */
        action ask(
            question : LargeString,
            history  : LargeString
        ) returns ChatResponse;
    };

    @readonly
    entity Equipment as projection on breakdown.Equipment;

    @readonly
    entity EquipmentModels as projection on breakdown.EquipmentModels;

    @readonly
    entity ManualDocuments as projection on breakdown.ManualDocuments
        excluding { chunks };
}

annotate TechnicianAssistantService.ManualDocuments with {
    content  @Core.MediaType                   : mimeType
             @Core.ContentDisposition.Filename: fileName
             @Core.ContentDisposition.Type    : 'inline';
    mimeType @Core.IsMediaType;
};
