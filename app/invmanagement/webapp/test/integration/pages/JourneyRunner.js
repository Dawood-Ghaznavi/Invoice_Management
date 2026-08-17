sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"invmanagement/test/integration/pages/InvoicesList.gen",
	"invmanagement/test/integration/pages/InvoicesObjectPage.gen"
], function (JourneyRunner, InvoicesListGenerated, InvoicesObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('invmanagement') + '/test/flp.html#app-preview',
        pages: {
			onTheInvoicesListGenerated: InvoicesListGenerated,
			onTheInvoicesObjectPageGenerated: InvoicesObjectPageGenerated
        },
        async: true
    });

    return runner;
});

