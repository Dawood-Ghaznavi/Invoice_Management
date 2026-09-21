sap.ui.define([], function () {
    "use strict";

    return {
        isPredictionMissing: function (value) {
            return value === null || value === undefined;
        },

        hasPrediction: function (value) {
            return value !== null && value !== undefined;
        }
    };
});
