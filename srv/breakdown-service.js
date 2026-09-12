'use strict';

const cds = require('@sap/cds');

module.exports = function () {
    const { Reports } = this.entities;

    this.before('NEW', Reports.drafts, async req => {
        const [number] = await cds.tx(req).run(
            'SELECT "machinebreakdown_reportNumber".NEXTVAL AS "nextNumber" FROM DUMMY'
        );

        req.data.reportNumber = `BR-${String(number.nextNumber).padStart(6, '0')}`;
    });
};
