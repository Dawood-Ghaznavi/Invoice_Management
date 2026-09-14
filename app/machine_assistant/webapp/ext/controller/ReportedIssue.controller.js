sap.ui.define([
    "sap/base/Log",
    "sap/ui/core/library",
    "sap/ui/core/mvc/ControllerExtension",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/ui/model/Sorter",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast",
    "sap/m/PDFViewer"
], function (Log, coreLibrary, ControllerExtension, Filter, FilterOperator, Sorter, JSONModel, MessageToast, PDFViewer) {
    "use strict";

    const {ValueState} = coreLibrary;

    return ControllerExtension.extend("machineassistant.ext.controller.ReportedIssue", {
        override: {
            onInit: function () {
                this.base.getView().setModel(new JSONModel({
                    searchText: "",
                    equipment: null,
                    equipmentValueState: ValueState.None,
                    symptomsValueState: ValueState.None,
                    busy: false,
                    error: "",
                    guidanceWarnings: [],
                    guidancePrimary: [],
                    guidanceMore: [],
                    hasGuidanceWarnings: false,
                    hasGuidancePrimary: false,
                    hasGuidanceMore: false
                }), "reportedIssue");
            },
            routing: {
                onAfterBinding: async function (oBindingContext) {
                    const oIssueModel = this.base.getView().getModel("reportedIssue");

                    oIssueModel.setProperty("/equipmentValueState", ValueState.None);
                    oIssueModel.setProperty("/symptomsValueState", ValueState.None);
                    oIssueModel.setProperty("/error", "");
                    oIssueModel.setProperty("/guidanceWarnings", []);
                    oIssueModel.setProperty("/guidancePrimary", []);
                    oIssueModel.setProperty("/guidanceMore", []);
                    oIssueModel.setProperty("/hasGuidanceWarnings", false);
                    oIssueModel.setProperty("/hasGuidancePrimary", false);
                    oIssueModel.setProperty("/hasGuidanceMore", false);

                    try {
                        const sEquipmentID = await oBindingContext.requestProperty("equipment_equipmentID");

                        if (!sEquipmentID) {
                            oIssueModel.setProperty("/searchText", "");
                            oIssueModel.setProperty("/equipment", null);
                            return;
                        }

                        const oEquipmentBinding = oBindingContext.getModel().bindList(
                            "/Equipment",
                            null,
                            null,
                            [new Filter("equipmentID", FilterOperator.EQ, sEquipmentID)],
                            {$expand: "model"}
                        );
                        const aEquipmentContexts = await oEquipmentBinding.requestContexts(0, 1);
                        const oEquipment = aEquipmentContexts[0]?.getObject();

                        if (oEquipment) {
                            oIssueModel.setProperty("/searchText", oEquipment.name || oEquipment.equipmentID);
                            oIssueModel.setProperty("/equipment", {
                                equipmentID: oEquipment.equipmentID,
                                name: oEquipment.name,
                                modelName: oEquipment.model?.name || oEquipment.model_modelID || "",
                                location: oEquipment.location
                            });
                        }

                        if (await oBindingContext.requestProperty("guidanceIsCurrent")) {
                            await this._loadGuidancePresentation(oBindingContext);
                        }
                    } catch (oError) {
                        Log.error("Unable to load the selected equipment", oError?.message);
                    }
                }
            }
        },

        _loadGuidancePresentation: async function (oReportContext) {
            const oModel = oReportContext.getModel();
            const oIssueModel = this.base.getView().getModel("reportedIssue");
            const oBundle = this.base.getView().getModel("i18n").getResourceBundle();
            const oItemsBinding = oModel.bindList(
                "guidanceItems",
                oReportContext,
                [new Sorter("sequence", false)],
                null,
                {$select: "ID,type,sequence,text,source_ID"}
            );
            const oSourcesBinding = oModel.bindList(
                "guidanceSources",
                oReportContext,
                [new Sorter("relevanceScore", true)],
                null,
                {
                    $select: "ID,manualDocument_ID,pageNumber,excerpt,relevanceScore",
                    $expand: "manualDocument($select=ID,documentNumber,title,version,fileName)"
                }
            );
            const [aItemContexts, aSourceContexts] = await Promise.all([
                oItemsBinding.requestContexts(0, 100),
                oSourcesBinding.requestContexts(0, 100)
            ]);
            const mSourcesByID = new Map(aSourceContexts.map(oContext => {
                const oSource = oContext.getObject();
                return [oSource.ID, oSource];
            }));
            const mTypePresentation = {
                Prerequisite: {
                    label: oBundle.getText("guidanceTypePrerequisite"),
                    state: "Warning",
                    icon: "sap-icon://pending"
                },
                "Possible Cause": {
                    label: oBundle.getText("guidanceTypePossibleCause"),
                    state: "Information",
                    icon: "sap-icon://inspection"
                },
                "Recommended Check": {
                    label: oBundle.getText("guidanceTypeRecommendedCheck"),
                    state: "Information",
                    icon: "sap-icon://activity-items"
                },
                General: {
                    label: oBundle.getText("guidanceTypeGeneral"),
                    state: "None",
                    icon: "sap-icon://hint"
                }
            };
            const aItems = aItemContexts.map(oContext => {
                const oItem = oContext.getObject();
                const oSource = mSourcesByID.get(oItem.source_ID) || {};
                const oDocument = oSource.manualDocument || {};
                const oPresentation = mTypePresentation[oItem.type] || mTypePresentation.General;
                const iPageNumber = oSource.pageNumber;

                return {
                    type: oItem.type,
                    typeLabel: oItem.type === "Warning"
                        ? oBundle.getText("guidanceTypeWarning")
                        : oPresentation.label,
                    state: oItem.type === "Warning" ? "Error" : oPresentation.state,
                    icon: oItem.type === "Warning" ? "sap-icon://alert" : oPresentation.icon,
                    text: oItem.text,
                    sourceDocumentID: oSource.manualDocument_ID,
                    pageNumber: iPageNumber,
                    citationLabel: oBundle.getText(
                        "manualCitation",
                        [iPageNumber || oBundle.getText("unknownPage")]
                    ),
                    citationTooltip: [
                        oDocument.title || oDocument.fileName || oBundle.getText("equipmentManual"),
                        oDocument.version
                            ? oBundle.getText("manualVersion", [oDocument.version])
                            : ""
                    ].filter(Boolean).join(" · ")
                };
            });
            const aWarnings = aItems.filter(oItem =>
                ["Warning", "Prerequisite"].includes(oItem.type)
            );
            const aPossibleCauses = aItems.filter(oItem =>
                oItem.type === "Possible Cause"
            );
            const aRecommendedChecks = aItems.filter(oItem =>
                oItem.type === "Recommended Check"
            );
            const aPrimary = [
                ...aPossibleCauses.slice(0, 1),
                ...aRecommendedChecks.slice(0, 2)
            ];

            if (!aPrimary.length) {
                aPrimary.push(...aItems.filter(oItem =>
                    !["Warning", "Prerequisite"].includes(oItem.type)
                ).slice(0, 2));
            }

            const oPrimaryItems = new Set(aPrimary);
            const aMore = aItems.filter(oItem =>
                !["Warning", "Prerequisite"].includes(oItem.type) &&
                !oPrimaryItems.has(oItem)
            );

            oIssueModel.setProperty("/guidanceWarnings", aWarnings);
            oIssueModel.setProperty("/guidancePrimary", aPrimary);
            oIssueModel.setProperty("/guidanceMore", aMore);
            oIssueModel.setProperty("/hasGuidanceWarnings", aWarnings.length > 0);
            oIssueModel.setProperty("/hasGuidancePrimary", aPrimary.length > 0);
            oIssueModel.setProperty("/hasGuidanceMore", aMore.length > 0);
        },

        onEquipmentSuggest: function (oEvent) {
            const sValue = oEvent.getParameter("suggestValue");
            const oBinding = oEvent.getSource().getBinding("suggestionRows");
            const aFilters = [new Filter("isActive", FilterOperator.EQ, true)];

            if (sValue) {
                aFilters.push(new Filter({
                    filters: [
                        new Filter("name", FilterOperator.Contains, sValue),
                        new Filter("equipmentID", FilterOperator.Contains, sValue),
                        new Filter("location", FilterOperator.Contains, sValue)
                    ],
                    and: false
                }));
            }

            oBinding.filter(aFilters);
        },

        onEquipmentSelected: async function (oEvent) {
            const oSelectedRow = oEvent.getParameter("selectedRow");

            if (!oSelectedRow) {
                return;
            }

            const oEquipment = oSelectedRow.getBindingContext().getObject();
            const oReportContext = oEvent.getSource().getBindingContext();
            const oIssueModel = this.base.getView().getModel("reportedIssue");

            try {
                await oReportContext.setProperty("equipment_equipmentID", oEquipment.equipmentID);
                oIssueModel.setProperty("/searchText", oEquipment.name || oEquipment.equipmentID);
                oIssueModel.setProperty("/equipment", {
                    equipmentID: oEquipment.equipmentID,
                    name: oEquipment.name,
                    modelName: oEquipment.model?.name || oEquipment.model_modelID || "",
                    location: oEquipment.location
                });
                oIssueModel.setProperty("/equipmentValueState", ValueState.None);
                oIssueModel.setProperty("/error", "");
            } catch (oError) {
                Log.error("Unable to select equipment", oError?.message);
                oIssueModel.setProperty("/error", "The equipment selection could not be saved. Please try again.");
            }
        },

        onEquipmentLiveChange: async function (oEvent) {
            const sValue = oEvent.getParameter("value");
            const oIssueModel = this.base.getView().getModel("reportedIssue");
            const oSelectedEquipment = oIssueModel.getProperty("/equipment");

            oIssueModel.setProperty("/searchText", sValue);
            oIssueModel.setProperty("/equipmentValueState", ValueState.None);

            if (oSelectedEquipment && sValue !== oSelectedEquipment.name) {
                try {
                    await oEvent.getSource().getBindingContext().setProperty("equipment_equipmentID", null);
                    oIssueModel.setProperty("/equipment", null);
                } catch (oError) {
                    Log.error("Unable to clear equipment", oError?.message);
                }
            }
        },

        onMachineStoppedChange: async function (oEvent) {
            const sKey = oEvent.getSource().getSelectedKey();
            const vMachineStopped = sKey === "yes" ? true : sKey === "no" ? false : null;

            try {
                await oEvent.getSource().getBindingContext().setProperty("machineStopped", vMachineStopped);
            } catch (oError) {
                Log.error("Unable to save the reported operating state", oError?.message);
            }
        },

        onFindGuidance: async function (oEvent) {
            const oButton = oEvent.getSource();
            const oReportContext = oButton.getBindingContext();
            const oIssueModel = this.base.getView().getModel("reportedIssue");
            const [sEquipmentID, sSymptoms] = await Promise.all([
                oReportContext.requestProperty("equipment_equipmentID"),
                oReportContext.requestProperty("observedSymptoms")
            ]);

            oIssueModel.setProperty(
                "/equipmentValueState",
                sEquipmentID ? ValueState.None : ValueState.Error
            );
            oIssueModel.setProperty(
                "/symptomsValueState",
                sSymptoms && sSymptoms.trim() ? ValueState.None : ValueState.Error
            );

            if (!sEquipmentID || !sSymptoms || !sSymptoms.trim()) {
                oIssueModel.setProperty("/error", "Select equipment and describe the observed symptoms before finding guidance.");
                return;
            }

            oIssueModel.setProperty("/busy", true);
            oIssueModel.setProperty("/error", "");

            try {
                await this.base.editFlow.invokeAction("BreakdownService.findGuidance", {
                    contexts: [oReportContext],
                    model: oReportContext.getModel(),
                    skipParameterDialog: true
                });
                await oReportContext.requestSideEffects([
                    {$PropertyPath: "guidanceIsCurrent"},
                    {$PropertyPath: "reportedConcern"},
                    {$PropertyPath: "missingInformation"},
                    {$PropertyPath: "suggestedShortDescription"},
                    {$PropertyPath: "suggestedDetailedDescription"},
                    {$PropertyPath: "suggestionAdoptedAt"},
                    {$NavigationPropertyPath: "guidanceItems"},
                    {$NavigationPropertyPath: "guidanceSources"}
                ]);
                await this._loadGuidancePresentation(oReportContext);
                MessageToast.show("Guidance is ready for review.");
            } catch (oError) {
                Log.error("Unable to retrieve guidance", oError?.message);
                oIssueModel.setProperty("/error", "Guidance could not be retrieved. Please review the inputs and try again.");
            } finally {
                oIssueModel.setProperty("/busy", false);
            }
        },

        onUseSuggestedReport: async function (oEvent) {
            const oButton = oEvent.getSource();
            const oReportContext = oButton.getBindingContext();

            oButton.setBusy(true);

            try {
                await this.base.editFlow.invokeAction("BreakdownService.useSuggestedReport", {
                    contexts: [oReportContext],
                    model: oReportContext.getModel(),
                    skipParameterDialog: true
                });
                await oReportContext.requestSideEffects([
                    {"$PropertyPath": "shortDescription"},
                    {"$PropertyPath": "detailedDescription"},
                    {"$PropertyPath": "suggestionAdoptedAt"}
                ]);
                MessageToast.show(
                    this.base.getView().getModel("i18n").getResourceBundle().getText("guidanceAppliedMessage")
                );
            } catch (oError) {
                Log.error("Unable to use the suggested report", oError?.message);
            } finally {
                oButton.setBusy(false);
            }
        },

        onOpenGuidanceSource: function (oEvent) {
            const oSource = oEvent.getSource()
                .getBindingContext("reportedIssue")
                ?.getObject();
            const sDocumentID = oSource?.sourceDocumentID ||
                oSource?.manualDocumentID;
            const iPageNumber = oSource?.pageNumber;

            if (!sDocumentID) {
                MessageToast.show(
                    this.base.getView().getModel("i18n").getResourceBundle().getText("guidanceSourceUnavailable")
                );
                return;
            }

            const sServiceUrl = this.base.getView().getModel().getServiceUrl();
            const sDocumentUrl = sServiceUrl + "ManualDocuments(ID=" +
                encodeURIComponent(sDocumentID) + ")/content/$value" +
                (iPageNumber ? "#page=" + iPageNumber : "");

            if (!this._oGuidancePdfViewer) {
                this._oGuidancePdfViewer = new PDFViewer({
                    showDownloadButton: true,
                    isTrustedSource: true
                });
                this.base.getView().addDependent(this._oGuidancePdfViewer);
            }

            this._oGuidancePdfViewer.setTitle(
                oSource.citationTooltip ||
                this.base.getView().getModel("i18n").getResourceBundle().getText("equipmentManual")
            );
            this._oGuidancePdfViewer.setSource(sDocumentUrl);
            this._oGuidancePdfViewer.open();
        },

        onDismissError: function () {
            this.base.getView().getModel("reportedIssue").setProperty("/error", "");
        }
    });
});
