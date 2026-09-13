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

    this.before('PATCH', Reports.drafts, req => {
        const inputChanged = Object.keys(req.data).some(field => [
            'equipment_equipmentID',
            'observedSymptoms',
            'faultCode',
            'checksAlreadyPerformed',
            'machineStopped'
        ].includes(field));

        if (inputChanged) {
            req.data.guidanceIsCurrent = false;
        }
    });
};
