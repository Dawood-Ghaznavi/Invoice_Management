sap.ui.define(
    [
        "sap/fe/core/PageController",
        "sap/ui/model/json/JSONModel"
    ],
    function(PageController, JSONModel) {
        "use strict";

        return PageController.extend("technicianassistant.ext.view.Main", {
            onInit: function () {
                PageController.prototype.onInit.apply(this, arguments);
                this.getView().setModel(new JSONModel({
                    selectedJobId: "",
                    activeJobId: "",
                    hasSelection: false,
                    showSelectionPrompt: true,
                    isSelectingJob: true,
                    showSelectedJob: false,
                    draftMessage: ""
                }), "view");
            },

            onJobSelectionChange: function (event) {
                const selectedItem = event.getSource().getSelectedItem();
                const stateModel = this.getView().getModel("view");

                if (!selectedItem) {
                    return;
                }

                this.getView().setBindingContext(selectedItem.getBindingContext());
                stateModel.setProperty("/selectedJobId", selectedItem.getKey());
                stateModel.setProperty("/activeJobId", selectedItem.getKey());
                stateModel.setProperty("/hasSelection", true);
                stateModel.setProperty("/showSelectionPrompt", false);
                stateModel.setProperty("/isSelectingJob", false);
                stateModel.setProperty("/showSelectedJob", true);
                stateModel.setProperty("/draftMessage", "");
            },

            onChangeJob: function () {
                const stateModel = this.getView().getModel("view");

                stateModel.setProperty("/selectedJobId", stateModel.getProperty("/activeJobId"));
                stateModel.setProperty("/isSelectingJob", true);
                stateModel.setProperty("/showSelectedJob", false);

                setTimeout(() => {
                    const selector = this.byId("jobSelector");
                    selector.focus();
                    selector.open();
                }, 0);
            },

            onCancelJobSelection: function () {
                const stateModel = this.getView().getModel("view");

                stateModel.setProperty("/selectedJobId", stateModel.getProperty("/activeJobId"));
                stateModel.setProperty("/isSelectingJob", false);
                stateModel.setProperty("/showSelectedJob", true);
            },

            onSuggestionPress: function (event) {
                this.getView().getModel("view").setProperty("/draftMessage", event.getSource().getText());
            },

            formatJobOption: function (jobNumber, equipmentName) {
                return [jobNumber, equipmentName].filter(Boolean).join(" · ");
            },

            formatEquipmentDetails: function (equipmentID, modelName) {
                return [equipmentID, modelName].filter(Boolean).join(" · ");
            },

            formatChatContext: function (jobNumber, equipmentName) {
                return [jobNumber, equipmentName].filter(Boolean).join(" · ");
            },

            formatOptionalValue: function (value) {
                return value || "Not reported";
            },

            formatJobStatusState: function (status) {
                switch (status) {
                    case "In Progress":
                        return "Warning";
                    case "On Hold":
                        return "Error";
                    default:
                        return "Information";
                }
            },

            formatPriorityState: function (priority) {
                switch (priority) {
                    case "Critical":
                        return "Error";
                    case "High":
                        return "Warning";
                    case "Medium":
                        return "Information";
                    default:
                        return "None";
                }
            },

            formatOperatingState: function (machineStopped) {
                if (machineStopped === true) {
                    return "Reported stopped";
                }
                if (machineStopped === false) {
                    return "Reported running";
                }
                return "Status not confirmed";
            },

            formatOperatingStateState: function (machineStopped) {
                if (machineStopped === true) {
                    return "Error";
                }
                if (machineStopped === false) {
                    return "Success";
                }
                return "None";
            },

            formatReportedAt: function (reportedAt) {
                if (!reportedAt) {
                    return "Not reported";
                }

                return new Intl.DateTimeFormat(undefined, {
                    dateStyle: "medium",
                    timeStyle: "short"
                }).format(new Date(reportedAt));
            },

            formatTechnicianGreeting: function (assignedTechnician) {
                const identity = String(assignedTechnician || "").trim();
                const firstName = identity
                    .split("@")[0]
                    .split(/[.\s_-]/)[0];
                const displayName = firstName
                    ? firstName.charAt(0).toUpperCase() + firstName.slice(1)
                    : "there";

                return this.getView().getModel("i18n").getResourceBundle()
                    .getText("chatGreeting", [displayName]);
            },

            formatFaultPrompt: function (faultCode) {
                return faultCode ? "What does " + faultCode + " mean?" : "What does this fault code mean?";
            }
        });
    }
);
