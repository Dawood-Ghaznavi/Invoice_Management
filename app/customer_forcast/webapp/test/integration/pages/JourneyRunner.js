sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"customerforcast/test/integration/pages/VisitorHistoryList.gen",
	"customerforcast/test/integration/pages/VisitorHistoryObjectPage.gen"
], function (JourneyRunner, VisitorHistoryListGenerated, VisitorHistoryObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('customerforcast') + '/test/flp.html#app-preview',
        pages: {
			onTheVisitorHistoryListGenerated: VisitorHistoryListGenerated,
			onTheVisitorHistoryObjectPageGenerated: VisitorHistoryObjectPageGenerated
        },
        async: true
    });

    return runner;
});

