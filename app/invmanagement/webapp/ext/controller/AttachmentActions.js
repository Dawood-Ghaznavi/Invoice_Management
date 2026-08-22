sap.ui.define([], function () {
    "use strict";

    return {
        extract: async function (oContext) {
            if (!oContext) {
                return;
            }

            await this.editFlow.invokeAction("InvoiceService.extract", {
                contexts: [oContext],
                model: oContext.getModel(),
                skipParameterDialog: true
            });
        }
    };
});
