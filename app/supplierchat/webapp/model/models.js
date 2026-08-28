sap.ui.define([
    "sap/ui/Device",
    "sap/ui/model/BindingMode",
    "sap/ui/model/json/JSONModel"
], function (Device, BindingMode, JSONModel) {
    "use strict";

    return {
        createDeviceModel: function () {
            const model = new JSONModel(Device);
            model.setDefaultBindingMode(BindingMode.OneWay);
            return model;
        }
    };
});
