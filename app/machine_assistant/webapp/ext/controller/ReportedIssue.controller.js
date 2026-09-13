sap.ui.define([
    "sap/base/Log",
    "sap/ui/core/ValueState",
    "sap/ui/core/mvc/ControllerExtension",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Log, ValueState, ControllerExtension, Filter, FilterOperator, JSONModel, MessageToast) {
    "use strict";

    return ControllerExtension.extend("machineassistant.ext.controller.ReportedIssue", {
        override: {
            onInit: function () {
                this.base.getView().setModel(new JSONModel({
                    searchText: "",
                    equipment: null,
                    equipmentValueState: ValueState.None,
                    symptomsValueState: ValueState.None,
                    checksExpanded: false,
                    busy: false,
                    error: ""
                }), "reportedIssue");
            },
            routing: {
                onAfterBinding: async function (oBindingContext) {
                    const oIssueModel = this.base.getView().getModel("reportedIssue");

                    oIssueModel.setProperty("/equipmentValueState", ValueState.None);
                    oIssueModel.setProperty("/symptomsValueState", ValueState.None);
                    oIssueModel.setProperty("/checksExpanded", false);
                    oIssueModel.setProperty("/error", "");

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
                    } catch (oError) {
                        Log.error("Unable to load the selected equipment", oError?.message);
                    }
                }
            }
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

        onToggleChecks: function () {
            const oIssueModel = this.base.getView().getModel("reportedIssue");

            oIssueModel.setProperty(
                "/checksExpanded",
                !oIssueModel.getProperty("/checksExpanded")
            );
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
                MessageToast.show("Guidance is ready for review.");
            } catch (oError) {
                Log.error("Unable to retrieve guidance", oError?.message);
                oIssueModel.setProperty("/error", "Guidance could not be retrieved. Please review the inputs and try again.");
            } finally {
                oIssueModel.setProperty("/busy", false);
            }
        },

        onDismissError: function () {
            this.base.getView().getModel("reportedIssue").setProperty("/error", "");
        }
    });
});
