sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"technicianassistant/test/integration/pages/JobsMain.gen"
], function (JourneyRunner, JobsMainGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('technicianassistant') + '/test/flp.html#app-preview',
        pages: {
			onTheJobsMainGenerated: JobsMainGenerated
        },
        async: true
    });

    return runner;
});

