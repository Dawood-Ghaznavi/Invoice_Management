sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/Fragment",
    "sap/m/MessageBox",
    "sap/m/MessageToast"
], function (
    ControllerExtension,
    JSONModel,
    Fragment,
    MessageBox,
    MessageToast
) {
    "use strict";

    return ControllerExtension.extend(
        "customerforcast.ext.controller.ListReportExt",
        {
            override: {
                onInit: function () {
                    this.base.getView().setModel(
                        new JSONModel({
                            fromDate: "",
                            toDate: "",
                            calendarFocusDate: new Date(2017, 2, 31),
                            results: [],
                            hasResults: false,
                            busy: false,
                            contextSummary: ""
                        }),
                        "prediction"
                    );
                },

                onExit: function () {
                    if (this._predictionDialog) {
                        this._predictionDialog.destroy();
                        this._predictionDialog = null;
                    }
                }
            },

            onOpenPredictionDialog: async function () {
                const view = this.base.getView();
                const predictionModel = view.getModel("prediction");

                predictionModel.setData({
                    fromDate: "",
                    toDate: "",
                    calendarFocusDate: new Date(2017, 2, 31),
                    results: [],
                    hasResults: false,
                    busy: false,
                    contextSummary: ""
                });

                if (!this._predictionDialog) {
                    this._predictionDialog = await Fragment.load({
                        id: view.getId(),
                        name: "customerforcast.ext.PredictionDialog",
                        controller: this
                    });
                    view.addDependent(this._predictionDialog);
                }

                this._predictionDialog.open();
            },

            onRunPrediction: async function () {
                const view = this.base.getView();
                const predictionModel = view.getModel("prediction");
                const fromDate = predictionModel.getProperty("/fromDate");
                const toDate = predictionModel.getProperty("/toDate");

                if (!fromDate || !toDate) {
                    MessageBox.warning(
                        this._getText("predictionSelectDates")
                    );
                    return;
                }

                if (fromDate > toDate) {
                    MessageBox.warning(
                        this._getText("predictionDateOrder")
                    );
                    return;
                }

                predictionModel.setProperty("/busy", true);
                predictionModel.setProperty("/hasResults", false);
                predictionModel.setProperty("/results", []);

                const action = view.getModel().bindContext(
                    "/predictVisitors(...)"
                );

                try {
                    action.setParameter("fromDate", fromDate);
                    action.setParameter("toDate", toDate);
                    await action.execute("$direct");

                    const response =
                        action.getBoundContext().getObject();
                    const results = response.results || [];

                    predictionModel.setProperty("/results", results);
                    predictionModel.setProperty(
                        "/contextSummary",
                        this._getText("predictionContextSummary", [
                            results.length,
                            response.contextRecordCount
                        ])
                    );
                    predictionModel.setProperty(
                        "/hasResults",
                        results.length > 0
                    );
                } catch (error) {
                    this._showError(error);
                } finally {
                    predictionModel.setProperty("/busy", false);
                    action.destroy();
                }
            },

            onSavePredictions: async function () {
                const view = this.base.getView();
                const predictionModel = view.getModel("prediction");
                const results =
                    predictionModel.getProperty("/results") || [];

                if (!results.length) {
                    return;
                }

                predictionModel.setProperty("/busy", true);

                const action = view.getModel().bindContext(
                    "/savePredictions(...)"
                );

                try {
                    action.setParameter(
                        "predictions",
                        results.map(function (result) {
                            return {
                                restaurantID: result.restaurantID,
                                visitDate: result.visitDate,
                                predictedVisitors:
                                    result.predictedVisitors
                            };
                        })
                    );
                    await action.execute("$direct");

                    MessageToast.show(
                        this._getText("predictionSaved", [
                            results.length
                        ])
                    );
                    this._predictionDialog.close();
                    predictionModel.setProperty("/results", []);
                    predictionModel.setProperty("/hasResults", false);
                    await this.base.getExtensionAPI().refresh();
                } catch (error) {
                    this._showError(error);
                } finally {
                    predictionModel.setProperty("/busy", false);
                    action.destroy();
                }
            },

            onClosePredictionDialog: function () {
                const predictionModel =
                    this.base.getView().getModel("prediction");

                predictionModel.setProperty("/results", []);
                predictionModel.setProperty("/hasResults", false);
                predictionModel.setProperty("/contextSummary", "");
                this._predictionDialog.close();
            },

            formatAccuracy: function (accuracy) {
                return accuracy === null || accuracy === undefined
                    ? "–"
                    : Number(accuracy).toFixed(1) + "%";
            },

            formatAccuracyState: function (accuracy) {
                if (accuracy === null || accuracy === undefined) {
                    return "None";
                }
                if (Number(accuracy) >= 80) {
                    return "Success";
                }
                if (Number(accuracy) >= 60) {
                    return "Warning";
                }
                return "Error";
            },

            _getText: function (key, parameters) {
                return this.base.getView()
                    .getModel("i18n")
                    .getResourceBundle()
                    .getText(key, parameters);
            },

            _showError: function (error) {
                MessageBox.error(
                    error.message ||
                    this._getText("predictionError")
                );
            }
        }
    );
});
