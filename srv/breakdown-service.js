'use strict';

const crypto = require('node:crypto');
const cds = require('@sap/cds');
const {SELECT, UPDATE, INSERT, DELETE} = cds.ql;

module.exports = async function () {
    const {
        Reports,
        Equipment,
        EquipmentModels,
        ManualDocuments,
        GuidanceItems,
        GuidanceSources
    } = this.entities;
    const db = await cds.connect.to('db');
    const ManualChunks = db.entities['machinebreakdown.ManualChunks'];
    const gpt = await cds.connect.to('GPT');
    const log = cds.log('breakdown-guidance');

    this.before('NEW', Reports.drafts, async req => {
        const [number] = await cds.tx(req).run(
            'SELECT "machinebreakdown_reportNumber".NEXTVAL AS "nextNumber" FROM DUMMY'
        );

        req.data.reportNumber = 'BR-' + String(number.nextNumber).padStart(6, '0');
    });

    this.before('PATCH', Reports.drafts, req => {
        const inputChanged = Object.keys(req.data).some(field => [
            'equipment_equipmentID',
            'observedSymptoms',
            'faultCode',
            'checksAlreadyPerformed',
            'machineStopped'
        ].includes(field));

        if (inputChanged) {
            req.data.guidanceIsCurrent = false;
        }
    });

    this.on('findGuidance', Reports.drafts, async req => {
        const startedAt = performance.now();
        const {ID} = req.params[0];
        const report = await db.run(
            SELECT.one.from(Reports.drafts)
                .columns(
                    'ID',
                    'DraftAdministrativeData_DraftUUID',
                    'reportNumber',
                    'equipment_equipmentID',
                    'observedSymptoms',
                    'faultCode',
                    'checksAlreadyPerformed',
                    'machineStopped'
                )
                .where({ID})
        );

        if (!report) {
            return req.error({status: 404, message: 'Breakdown report draft not found'});
        }

        const observedSymptoms = report.observedSymptoms?.trim();
        const faultCode = report.faultCode?.trim().toUpperCase() || '';
        const checksAlreadyPerformed = report.checksAlreadyPerformed?.trim() || '';
        const machineStopped = report.machineStopped === true
            ? true
            : report.machineStopped === false
                ? false
                : null;

        if (!report.equipment_equipmentID) {
            return req.error({status: 400, message: 'Select equipment before finding guidance'});
        }

        if (!observedSymptoms) {
            return req.error({status: 400, message: 'Describe the observed symptoms before finding guidance'});
        }

        const equipment = await db.run(
            SELECT.one.from(Equipment)
                .columns(
                    'equipmentID',
                    'name',
                    'model_modelID',
                    'controllerModel',
                    'configuration',
                    'location',
                    'isActive'
                )
                .where({equipmentID: report.equipment_equipmentID})
        );

        if (!equipment || equipment.isActive === false) {
            return req.error({status: 400, message: 'The selected equipment is not available'});
        }

        const equipmentModel = equipment.model_modelID
            ? await db.run(
                SELECT.one.from(EquipmentModels)
                    .columns('modelID', 'name', 'manufacturer')
                    .where({modelID: equipment.model_modelID})
            )
            : null;
        const currentDate = new Date().toISOString().slice(0, 10);
        const manualDocuments = await db.run(
            SELECT.from(ManualDocuments)
                .columns(
                    'ID',
                    'documentNumber',
                    'title',
                    'version',
                    'fileName',
                    'model_modelID',
                    'equipment_equipmentID',
                    'controllerModel',
                    'configuration',
                    'validFrom',
                    'validTo',
                    'isCurrent'
                )
                .where({isCurrent: true})
        );
        const applicableDocuments = manualDocuments.filter(document => {
            const appliesToEquipment =
                document.equipment_equipmentID === equipment.equipmentID;
            const appliesToModel =
                !document.equipment_equipmentID &&
                document.model_modelID === equipment.model_modelID;
            const controllerMatches =
                !document.controllerModel ||
                document.controllerModel === equipment.controllerModel;
            const configurationMatches =
                !document.configuration ||
                document.configuration === equipment.configuration;
            const versionIsEffective =
                (!document.validFrom || document.validFrom <= currentDate) &&
                (!document.validTo || document.validTo >= currentDate);

            return (appliesToEquipment || appliesToModel) &&
                controllerMatches &&
                configurationMatches &&
                versionIsEffective;
        });

        if (!applicableDocuments.length) {
            return req.error({
                status: 400,
                message: 'No current manual is available for the selected equipment configuration'
            });
        }

        const inputForHash = {
            equipmentID: equipment.equipmentID,
            observedSymptoms,
            faultCode,
            checksAlreadyPerformed,
            machineStopped
        };
        const guidanceInputHash = crypto
            .createHash('sha256')
            .update(JSON.stringify(inputForHash))
            .digest('hex');
        const retrievalQuery = [
            'Equipment: ' + equipment.name + ' (' + equipment.equipmentID + ')',
            'Model: ' + (equipmentModel?.name || equipment.model_modelID || 'Unknown'),
            'Controller: ' + (equipment.controllerModel || 'Unknown'),
            'Configuration: ' + (equipment.configuration || 'Unknown'),
            'Location: ' + (equipment.location || 'Unknown'),
            'Reported symptoms: ' + observedSymptoms,
            'Fault code: ' + (faultCode || 'Not provided'),
            'Machine stopped: ' + (
                machineStopped === true ? 'Yes' : machineStopped === false ? 'No' : 'Unknown'
            ),
            'Checks already performed: ' +
                (checksAlreadyPerformed || 'None reported'),
            'Retrieve applicable safety warnings, prerequisites, documented possible causes, recommended checks and reporting guidance.'
        ].join('\n');

        let queryEmbedding;

        try {
            const embeddingResponse = await gpt.post('/v1/embeddings', {
                model: 'text-embedding-3-small',
                input: retrievalQuery
            });

            queryEmbedding = embeddingResponse.data?.[0]?.embedding;
        } catch (error) {
            log.error('Embedding request failed', error.message);
            return req.error({status: 502, message: 'Guidance retrieval could not be started'});
        }

        if (!Array.isArray(queryEmbedding) ||
            queryEmbedding.length !== 1536 ||
            !queryEmbedding.every(Number.isFinite)) {
            return req.error({status: 502, message: 'The embedding service returned an invalid response'});
        }

        const documentIDs = applicableDocuments.map(document => document.ID);
        const queryVector = JSON.stringify(queryEmbedding);
        const similarity = {
            func: 'cosine_similarity',
            args: [
                {ref: ['embedding']},
                {
                    func: 'to_real_vector',
                    args: [{val: queryVector}]
                }
            ]
        };
        const chunkColumns = [
            'ID',
            'document_ID',
            'pageNumber',
            'chunkNumber',
            'faultCode',
            'content'
        ];
        const semanticChunks = await db.run(
            SELECT.from(ManualChunks)
                .columns(...chunkColumns, {...similarity, as: 'relevanceScore'})
                .where({document_ID: {in: documentIDs}})
                .orderBy({ref: ['relevanceScore'], sort: 'desc'})
                .limit(8)
        );
        const exactFaultChunks = faultCode
            ? await db.run(
                SELECT.from(ManualChunks)
                    .columns(...chunkColumns, {...similarity, as: 'relevanceScore'})
                    .where({
                        document_ID: {in: documentIDs},
                        faultCode
                    })
                    .orderBy({ref: ['relevanceScore'], sort: 'desc'})
                    .limit(4)
            )
            : [];
        const retrievedChunks = [];

        for (const chunk of [...exactFaultChunks, ...semanticChunks]) {
            if (!retrievedChunks.some(retrieved => retrieved.ID === chunk.ID)) {
                retrievedChunks.push(chunk);
            }

            if (retrievedChunks.length === 8) {
                break;
            }
        }

        if (!retrievedChunks.length) {
            return req.error({
                status: 400,
                message: 'The applicable manual has not been indexed for guidance retrieval'
            });
        }

        const documentsByID = new Map(
            applicableDocuments.map(document => [document.ID, document])
        );
        const retrievedContext = retrievedChunks.map(chunk => {
            const document = documentsByID.get(chunk.document_ID);

            return {
                sourceChunkId: chunk.ID,
                documentNumber: document.documentNumber,
                documentTitle: document.title,
                documentVersion: document.version,
                pageNumber: chunk.pageNumber,
                faultCode: chunk.faultCode,
                relevanceScore: Number(chunk.relevanceScore || 0),
                content: chunk.content
            };
        });
        const allowedChunkIDs = retrievedChunks.map(chunk => chunk.ID);
        const allowedGuidanceTypes = [
            'General',
            'Prerequisite',
            'Warning',
            'Possible Cause',
            'Recommended Check'
        ];
        let response;

        try {
            response = await gpt.post('/v1/responses', {
                model: 'gpt-5.6-luna',
                store: false,
                instructions: [
                    'Prepare grounded maintenance guidance and factual breakdown-report wording.',
                    'Use only the supplied retrieved manual passages and reported issue.',
                    'Never claim to diagnose the machine automatically.',
                    'Return reportedSymptomSummary as a short symptom phrase ending in reported, for example: Sparking and smoke reported.',
                    'Never put equipment details, identifiers, fault codes, report numbers or the full narrative in reportedSymptomSummary.',
                    'Keep observations, documented possible causes, recommended checks and confirmed findings distinct.',
                    'A possible cause must remain explicitly possible and must never be written as a confirmed failure.',
                    'A recommended check must never be described as already completed.',
                    'Only say the machine is stopped when machineStopped is true.',
                    'When machineStopped is false, it may be described only as reported running.',
                    'When machineStopped is null, omit the operating state; never infer stopped from wording such as not working.',
                    'Include checks already performed only when the supplied value is non-empty, and identify them as user-reported checks.',
                    'Do not invent part numbers, fault meanings, measurements, procedures or references.',
                    'Preserve relevant safety prerequisites and warnings.',
                    'Consolidate overlapping safety wording into one Warning item when one source supports the precautions; use a second Warning item only when a distinct precaution requires a different direct citation.',
                    'Do not repeat the same restriction in multiple Warning items and do not add introductory safety filler.',
                    'Each guidance item must cite exactly one supplied sourceChunkId.',
                    'Write each non-warning guidance item as one concise sentence. Keep safety wording complete even when it needs more space.',
                    'Return no more than one Possible Cause item; summarize documented possibilities while keeping them explicitly unconfirmed.',
                    'Return only the most relevant recommended checks. Do not force the guidance into an arbitrary number of steps.',
                    'Omit equipment-name explanations and generic applicability text unless they materially help the technician.',
                    'Order guidance items as warnings, prerequisites, possible causes, recommended checks, then any essential general context.',
                    'The suggested short description must be a brief factual report title, not guidance or a diagnosis.',
                    'The suggested detailed description must be one to three short sentences containing only reported facts: equipment name, explicitly supplied operating state, displayed fault code, observed symptoms, supplied completed checks, and that the cause is not confirmed.',
                    'Never put report numbers, equipment IDs, model, controller, configuration, location, manual interpretation, safety instructions, recommended checks, unanswered questions or inventories of missing details in the suggested report.',
                    'CAP has already validated document applicability for the selected equipment, model, controller, configuration and validity dates; never ask the user to reconfirm it.',
                    'Use materialLimitation reason NONE unless the retrieved manual evidence is insufficient or conflicting in a way that changes what guidance can reasonably be given.',
                    'Optional occurrence time, recurrence, recent operating changes and other unsupplied context are never a material limitation by themselves.',
                    'For reason NONE return an empty consequence. Otherwise give one brief sentence explaining the consequence, without asking questions or listing missing details.',
                    'Keep the result concise and practical for maintenance review.'
                ].join(' '),
                input: JSON.stringify({
                    reportedIssue: {
                        equipment: {
                            equipmentID: equipment.equipmentID,
                            name: equipment.name,
                            model: equipmentModel?.name || equipment.model_modelID,
                            controllerModel: equipment.controllerModel,
                            configuration: equipment.configuration,
                            location: equipment.location
                        },
                        observedSymptoms,
                        faultCode: faultCode || null,
                        checksAlreadyPerformed:
                            checksAlreadyPerformed || null,
                        machineStopped
                    },
                    retrievedManualPassages: retrievedContext
                }),
                text: {
                    format: {
                        type: 'json_schema',
                        name: 'machine_breakdown_guidance',
                        strict: true,
                        schema: {
                            type: 'object',
                            properties: {
                                guidanceItems: {
                                    type: 'array',
                                    minItems: 1,
                                    maxItems: 7,
                                    items: {
                                        type: 'object',
                                        properties: {
                                            type: {
                                                type: 'string',
                                                enum: allowedGuidanceTypes
                                            },
                                            text: {
                                                type: 'string'
                                            },
                                            sourceChunkId: {
                                                type: 'string',
                                                enum: allowedChunkIDs
                                            }
                                        },
                                        required: ['type', 'text', 'sourceChunkId'],
                                        additionalProperties: false
                                    }
                                },
                                reportedSymptomSummary: {
                                    type: 'string',
                                    maxLength: 100
                                },
                                materialLimitation: {
                                    type: 'object',
                                    properties: {
                                        reason: {
                                            type: 'string',
                                            enum: [
                                                'NONE',
                                                'INSUFFICIENT_MANUAL_EVIDENCE',
                                                'CONFLICTING_MANUAL_EVIDENCE'
                                            ]
                                        },
                                        consequence: {
                                            type: 'string'
                                        }
                                    },
                                    required: ['reason', 'consequence'],
                                    additionalProperties: false
                                },
                                suggestedShortDescription: {
                                    type: 'string',
                                    maxLength: 160
                                },
                                suggestedDetailedDescription: {
                                    type: 'string',
                                    maxLength: 600
                                }
                            },
                            required: [
                                'guidanceItems',
                                'reportedSymptomSummary',
                                'materialLimitation',
                                'suggestedShortDescription',
                                'suggestedDetailedDescription'
                            ],
                            additionalProperties: false
                        }
                    }
                }
            });
        } catch (error) {
            log.error('Guidance generation failed', error.message);
            return req.error({status: 502, message: 'Guidance could not be generated'});
        }

        const outputText = response.output
            ?.find(output => output.type === 'message')
            ?.content?.find(content => content.type === 'output_text')
            ?.text;

        if (!outputText) {
            return req.error({status: 502, message: 'Guidance generation returned no result'});
        }

        let generatedGuidance;

        try {
            generatedGuidance = JSON.parse(outputText);
        } catch {
            return req.error({status: 502, message: 'Guidance generation returned an invalid result'});
        }

        const allowedLimitationReasons = [
            'NONE',
            'INSUFFICIENT_MANUAL_EVIDENCE',
            'CONFLICTING_MANUAL_EVIDENCE'
        ];
        const materialLimitation = generatedGuidance.materialLimitation;
        const reportedSymptomSummary =
            generatedGuidance.reportedSymptomSummary?.trim();
        const suggestedShortDescription =
            generatedGuidance.suggestedShortDescription?.trim();
        const suggestedDetailedDescription =
            generatedGuidance.suggestedDetailedDescription?.trim();
        const materialConsequence =
            materialLimitation?.consequence?.trim() || '';
        const concernSummaryContainsIdentifier = [
            equipment.name,
            equipment.equipmentID,
            faultCode,
            report.reportNumber
        ].filter(Boolean).some(value =>
            reportedSymptomSummary?.toLowerCase().includes(value.toLowerCase())
        );
        const reportedConcern = reportedSymptomSummary
            ? [
                equipment.name,
                faultCode,
                reportedSymptomSummary.replace(/[.!?]+$/, '') + '.'
            ].filter(Boolean).join(' · ')
            : null;
        const reportContainsEquipmentMetadata = [
            report.reportNumber,
            equipment.equipmentID,
            equipment.model_modelID,
            equipment.controllerModel,
            equipment.configuration,
            equipment.location
        ].filter(Boolean).some(value =>
            (suggestedShortDescription + ' ' + suggestedDetailedDescription)
                .includes(value)
        );
        const reportContainsMissingDetailInventory =
            /\b(?:not provided|not supplied|not reported|needs clarification|missing information|details? (?:is|are) unknown)\b/i
                .test(suggestedDetailedDescription || '');
        const operatingStateWasInvented =
            (machineStopped !== true &&
                /\bstopped\b/i.test(suggestedDetailedDescription || '')) ||
            (machineStopped !== false &&
                /\brunning\b/i.test(suggestedDetailedDescription || ''));

        if (!Array.isArray(generatedGuidance.guidanceItems) ||
            !generatedGuidance.guidanceItems.length ||
            generatedGuidance.guidanceItems.some(item =>
                !allowedGuidanceTypes.includes(item.type) ||
                !allowedChunkIDs.includes(item.sourceChunkId) ||
                !item.text?.trim()
            ) ||
            !reportedSymptomSummary ||
            !/\breported[.!?]?$/i.test(reportedSymptomSummary) ||
            concernSummaryContainsIdentifier ||
            !reportedConcern ||
            !materialLimitation ||
            !allowedLimitationReasons.includes(materialLimitation.reason) ||
            (materialLimitation.reason !== 'NONE' && !materialConsequence) ||
            !suggestedShortDescription ||
            !suggestedDetailedDescription ||
            reportContainsEquipmentMetadata ||
            reportContainsMissingDetailInventory ||
            operatingStateWasInvented) {
            return req.error({status: 502, message: 'Guidance generation returned unsupported content'});
        }

        const missingInformation = materialLimitation.reason === 'NONE'
            ? null
            : materialConsequence;

        const currentReport = await db.run(
            SELECT.one.from(Reports.drafts)
                .columns(
                    'equipment_equipmentID',
                    'observedSymptoms',
                    'faultCode',
                    'checksAlreadyPerformed',
                    'machineStopped'
                )
                .where({ID})
        );
        const currentInputHash = currentReport
            ? crypto
                .createHash('sha256')
                .update(JSON.stringify({
                    equipmentID: currentReport.equipment_equipmentID,
                    observedSymptoms: currentReport.observedSymptoms?.trim(),
                    faultCode: currentReport.faultCode?.trim().toUpperCase() || '',
                    checksAlreadyPerformed:
                        currentReport.checksAlreadyPerformed?.trim() || '',
                    machineStopped: currentReport.machineStopped === true
                        ? true
                        : currentReport.machineStopped === false
                            ? false
                            : null
                }))
                .digest('hex')
            : null;

        if (currentInputHash !== guidanceInputHash) {
            return req.error({
                status: 409,
                message: 'The reported issue changed while guidance was being generated. Run Find guidance again.'
            });
        }

        const citedChunkIDs = [
            ...new Set(generatedGuidance.guidanceItems.map(item => item.sourceChunkId))
        ];
        const sourceIDsByChunk = new Map();
        const technicalDraftFields = {
            IsActiveEntity: false,
            HasActiveEntity: false,
            HasDraftEntity: false,
            DraftAdministrativeData_DraftUUID:
                report.DraftAdministrativeData_DraftUUID
        };
        const sourceRows = citedChunkIDs.map(chunkID => {
            const chunk = retrievedChunks.find(retrieved => retrieved.ID === chunkID);
            const sourceID = cds.utils.uuid();

            sourceIDsByChunk.set(chunkID, sourceID);

            return {
                ID: sourceID,
                report_ID: ID,
                manualDocument_ID: chunk.document_ID,
                manualChunk_ID: chunk.ID,
                pageNumber: chunk.pageNumber,
                excerpt: chunk.content,
                relevanceScore: Number(Number(chunk.relevanceScore || 0).toFixed(5)),
                ...technicalDraftFields
            };
        });
        const guidanceItemRows = generatedGuidance.guidanceItems.map((item, index) => ({
            ID: cds.utils.uuid(),
            report_ID: ID,
            type: item.type,
            sequence: index + 1,
            text: item.text.trim(),
            source_ID: sourceIDsByChunk.get(item.sourceChunkId),
            ...technicalDraftFields
        }));

        await db.tx(async tx => {
            await tx.run(
                DELETE.from(GuidanceItems.drafts).where({report_ID: ID})
            );
            await tx.run(
                DELETE.from(GuidanceSources.drafts).where({report_ID: ID})
            );
            await tx.run(
                INSERT.into(GuidanceSources.drafts).entries(sourceRows)
            );
            await tx.run(
                INSERT.into(GuidanceItems.drafts).entries(guidanceItemRows)
            );
            await tx.run(
                UPDATE(Reports.drafts).set({
                    reportedConcern,
                    missingInformation,
                    suggestedShortDescription:
                        suggestedShortDescription,
                    suggestedDetailedDescription:
                        suggestedDetailedDescription,
                    guidanceGeneratedAt: new Date().toISOString(),
                    guidanceInputHash,
                    guidanceIsCurrent: true,
                    suggestionAdoptedAt: null
                }).where({ID})
            );
        });

        log.info('findGuidance completed', {
            reportID: ID,
            applicableDocuments: applicableDocuments.length,
            exactFaultChunks: exactFaultChunks.length,
            retrievedChunks: retrievedChunks.length,
            guidanceItems: guidanceItemRows.length,
            durationMs: Number((performance.now() - startedAt).toFixed(1))
        });
    });
};
