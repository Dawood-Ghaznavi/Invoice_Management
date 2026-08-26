sap.ui.define([
    "sap/base/Log",
    "sap/ui/core/mvc/ControllerExtension",
    "sap/ui/model/json/JSONModel",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator"
], function (Log, ControllerExtension, JSONModel, Filter, FilterOperator) {
    "use strict";

    return ControllerExtension.extend("invmanagement.ext.controller.AIRecommendation", {
        override: {
            onInit: function () {
                this.base.getView().setModel(new JSONModel(), "ai");
            },
            routing: {
                onAfterBinding: async function (oBindingContext) {
                    await this._refreshAIModel(oBindingContext);
                }
            },
            editFlow: {
                onAfterActionExecution: async function () {
                    const oBindingContext = this.base.getView().getBindingContext();

                    if (oBindingContext) {
                        await this._refreshAIModel(oBindingContext);
                    }
                }
            }
        },

        onApplyAiRecommendation: async function (oEvent) {
            const oButton = oEvent.getSource();
            const oBindingContext = oButton.getBindingContext();

            if (!oBindingContext) {
                return;
            }

            oButton.setBusy(true);

            try {
                await this.base.editFlow.invokeAction("InvoiceService.adopt", {
                    contexts: [oBindingContext],
                    model: oBindingContext.getModel(),
                    skipParameterDialog: true
                });
            } finally {
                oButton.setBusy(false);
            }
        },

        _refreshAIModel: async function (oBindingContext) {
            const oAIModel = this.base.getView().getModel("ai");

            try {
                const [
                    sProcessingType,
                    sGLAccount,
                    sCostCenter,
                    vConfidence,
                    sReason
                ] = await Promise.all([
                    oBindingContext.requestProperty("processingType"),
                    oBindingContext.requestProperty("suggestedGLAccount"),
                    oBindingContext.requestProperty("suggestedCostCenter"),
                    oBindingContext.requestProperty("aiConfidence"),
                    oBindingContext.requestProperty("aiReason")
                ]);

                const bHasRecommendation = sProcessingType === "Non-PO" &&
                    Boolean(sGLAccount) &&
                    Boolean(sCostCenter) &&
                    vConfidence !== null &&
                    vConfidence !== undefined;
                let sGLAccountDescription = "";
                let sCostCenterDescription = "";

                if (bHasRecommendation) {
                    const oModel = oBindingContext.getModel();
                    const oGLAccountBinding = oModel.bindList("/GLAccounts", null, null, [
                        new Filter("code", FilterOperator.EQ, sGLAccount),
                        new Filter("isActive", FilterOperator.EQ, true)
                    ]);
                    const oCostCenterBinding = oModel.bindList("/CostCenters", null, null, [
                        new Filter("code", FilterOperator.EQ, sCostCenter),
                        new Filter("isActive", FilterOperator.EQ, true)
                    ]);
                    const [aGLAccountContexts, aCostCenterContexts] = await Promise.all([
                        oGLAccountBinding.requestContexts(0, 1),
                        oCostCenterBinding.requestContexts(0, 1)
                    ]);
                    const oGLAccount = aGLAccountContexts[0]?.getObject();
                    const oCostCenter = aCostCenterContexts[0]?.getObject();

                    sGLAccountDescription = oGLAccount?.name || oGLAccount?.description || sGLAccount;
                    sCostCenterDescription = oCostCenter?.name || oCostCenter?.description || sCostCenter;
                }

                oAIModel.setData({
                    hasRecommendation: bHasRecommendation,
                    glAccount: sGLAccount || "",
                    glAccountDescription: sGLAccountDescription,
                    costCenter: sCostCenter || "",
                    costCenterDescription: sCostCenterDescription,
                    confidence: Number(vConfidence || 0),
                    reason: sReason || ""
                });
            } catch (oError) {
                oAIModel.setData({
                    hasRecommendation: false,
                    glAccount: "",
                    glAccountDescription: "",
                    costCenter: "",
                    costCenterDescription: "",
                    confidence: 0,
                    reason: ""
                });
                Log.error("Unable to load AI recommendation", oError?.message);
            }
        }
    });
});
