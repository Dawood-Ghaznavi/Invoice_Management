sap.ui.define([
    "sap/m/BusyDialog"
], function (BusyDialog) {
    "use strict";

    return {
        extract: async function (oContext) {
            if (!oContext) {
                return;
            }

            const oBusyDialog = new BusyDialog({
                title: "Extracting Invoice",
                text: "Analyzing the uploaded document..."
            });

            oBusyDialog.open();

            try {
                await this.editFlow.invokeAction("InvoiceService.extract", {
                    contexts: [oContext],
                    model: oContext.getModel(),
                    skipParameterDialog: true
                });
            } finally {
                oBusyDialog.close();
                oBusyDialog.destroy();
            }
        },

        fetchRecommendation: async function (oContext) {
            if (!oContext) {
                return;
            }

            const oBusyDialog = new BusyDialog({
                title: "Generating AI Recommendation",
                text: "Evaluating the most suitable accounting assignment…"
            });

            oBusyDialog.open();

            try {
                await this.editFlow.invokeAction("InvoiceService.fetchRec", {
                    contexts: [oContext],
                    model: oContext.getModel(),
                    skipParameterDialog: true
                });
            } finally {
                oBusyDialog.close();
                oBusyDialog.destroy();
            }
        }
    };
});
