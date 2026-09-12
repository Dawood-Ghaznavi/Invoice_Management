sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"machineassistant/test/integration/pages/ReportsList.gen",
	"machineassistant/test/integration/pages/ReportsObjectPage.gen"
], function (JourneyRunner, ReportsListGenerated, ReportsObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('machineassistant') + '/test/flp.html#app-preview',
        pages: {
			onTheReportsListGenerated: ReportsListGenerated,
			onTheReportsObjectPageGenerated: ReportsObjectPageGenerated
        },
        async: true
    });

    return runner;
});

