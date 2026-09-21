'use strict';

const cds = require('@sap/cds');
const {SELECT, UPDATE} = cds.ql;

const MAX_PREDICTION_ROWS = 31;
const MIN_CONTEXT_ROWS = 10;

module.exports = async function () {
    const db = await cds.connect.to('db');
    const rpt = await cds.connect.to('RPT');
    const VisitorHistory =
        db.entities['restaurantforecast.VisitorHistory'];
    const log = cds.log('restaurant-forecast');

    this.on('predictVisitors', async req => {
        const {fromDate, toDate} = req.data;

        if (!/^\d{4}-\d{2}-\d{2}$/.test(fromDate || '') ||
            !/^\d{4}-\d{2}-\d{2}$/.test(toDate || '')) {
            return req.reject(400, 'Select a valid From and To date');
        }

        if (fromDate > toDate) {
            return req.reject(
                400,
                'The From date must be on or before the To date'
            );
        }

        const history = await db.run(
            SELECT.from(VisitorHistory)
                .columns(
                    'restaurantID',
                    'visitDate',
                    'dayOfWeek',
                    'holiday',
                    'reservedVisitors',
                    'actualVisitors'
                )
                .orderBy('visitDate')
        );
        const targetRows = history.filter(row =>
            row.visitDate >= fromDate && row.visitDate <= toDate
        );

        if (!targetRows.length) {
            return req.reject(
                404,
                'No historical visitor records exist in the selected period'
            );
        }

        if (targetRows.length > MAX_PREDICTION_ROWS) {
            return req.reject(
                400,
                'Select a period containing no more than 31 visitor records'
            );
        }

        const restaurantIDs = new Set(
            targetRows.map(row => row.restaurantID)
        );
        const contextRows = history.filter(row =>
            restaurantIDs.has(row.restaurantID) &&
            row.visitDate < fromDate
        );

        if (contextRows.length < MIN_CONTEXT_ROWS) {
            return req.reject(
                400,
                'The selected period does not have enough earlier history'
            );
        }

        const rows = contextRows.map(row => ({
            recordID: row.restaurantID + '|' + row.visitDate,
            restaurantID: row.restaurantID,
            visitDate: row.visitDate,
            dayOfWeek: row.dayOfWeek,
            holiday: row.holiday,
            reservedVisitors: row.reservedVisitors,
            actualVisitors: row.actualVisitors
        }));

        rows.push(...targetRows.map(row => ({
            recordID: row.restaurantID + '|' + row.visitDate,
            restaurantID: row.restaurantID,
            visitDate: row.visitDate,
            dayOfWeek: row.dayOfWeek,
            holiday: row.holiday,
            reservedVisitors: row.reservedVisitors,
            actualVisitors: '[PREDICT]'
        })));

        let response;

        try {
            response = await rpt.tx(req).post('/api/predict', {
                index_column: 'recordID',
                rows
            });
        } catch (error) {
            log.error('RPT prediction failed', {
                requestId: req.id,
                message: error.message,
                status: error.reason?.response?.status ||
                    error.response?.status ||
                    error.cause?.response?.status,
                response: error.reason?.response?.body ||
                    error.response?.data ||
                    error.cause?.response?.data
            });
            return req.reject(
                502,
                'Visitor prediction could not be completed'
            );
        }

        const predictions =
            response?.prediction?.predictions || response?.predictions;

        if (!Array.isArray(predictions)) {
            return req.reject(
                502,
                'RPT returned an unsupported prediction response'
            );
        }

        const predictionsByID = new Map();

        for (const prediction of predictions) {
            const predictionValue = Array.isArray(
                prediction.actualVisitors
            )
                ? prediction.actualVisitors[0]?.prediction
                : prediction.actualVisitors?.prediction ??
                    prediction.actualVisitors;
            const numericPrediction = Number(predictionValue);

            if (!prediction.recordID ||
                !Number.isFinite(numericPrediction)) {
                return req.reject(
                    502,
                    'RPT returned an invalid visitor prediction'
                );
            }

            predictionsByID.set(
                prediction.recordID,
                Math.max(0, Math.round(numericPrediction))
            );
        }

        const results = targetRows.map(row => {
            const recordID = row.restaurantID + '|' + row.visitDate;
            const predictedVisitors = predictionsByID.get(recordID);

            if (predictedVisitors === undefined) {
                return null;
            }

            const accuracy = row.actualVisitors === 0
                ? null
                : Number((
                    100 -
                    Math.abs(
                        predictedVisitors - row.actualVisitors
                    ) / row.actualVisitors * 100
                ).toFixed(2));

            return {
                restaurantID: row.restaurantID,
                visitDate: row.visitDate,
                dayOfWeek: row.dayOfWeek,
                predictedVisitors,
                actualVisitors: row.actualVisitors,
                accuracy
            };
        });

        if (results.some(result => !result)) {
            return req.reject(
                502,
                'RPT did not return every requested visitor prediction'
            );
        }

        log.info('Visitor prediction completed', {
            requestId: req.id,
            contextRows: contextRows.length,
            predictedRows: results.length,
            fromDate,
            toDate
        });

        return {
            contextRecordCount: contextRows.length,
            results
        };
    });

    this.on('savePredictions', async req => {
        const predictions = req.data.predictions;

        if (!Array.isArray(predictions) ||
            !predictions.length ||
            predictions.length > MAX_PREDICTION_ROWS) {
            return req.reject(400, 'No valid predictions were provided');
        }

        const normalizedPredictions = [];
        const predictionKeys = new Set();

        for (const prediction of predictions) {
            const restaurantID = prediction.restaurantID?.trim();
            const visitDate = prediction.visitDate;
            const predictedVisitors =
                Number(prediction.predictedVisitors);
            const key = restaurantID + '|' + visitDate;

            if (!restaurantID ||
                !/^\d{4}-\d{2}-\d{2}$/.test(visitDate || '') ||
                !Number.isInteger(predictedVisitors) ||
                predictedVisitors < 0 ||
                predictionKeys.has(key)) {
                return req.reject(400, 'A prediction value is invalid');
            }

            predictionKeys.add(key);
            normalizedPredictions.push({
                restaurantID,
                visitDate,
                predictedVisitors
            });
        }

        const existingRows = await db.run(
            SELECT.from(VisitorHistory)
                .columns('restaurantID', 'visitDate')
        );
        const existingKeys = new Set(existingRows.map(row =>
            row.restaurantID + '|' + row.visitDate
        ));

        if (normalizedPredictions.some(prediction =>
            !existingKeys.has(
                prediction.restaurantID + '|' + prediction.visitDate
            )
        )) {
            return req.reject(
                404,
                'A visitor record selected for saving no longer exists'
            );
        }

        await db.tx(async tx => {
            for (const prediction of normalizedPredictions) {
                await tx.run(
                    UPDATE(VisitorHistory)
                        .set({
                            predictedVisitors:
                                prediction.predictedVisitors
                        })
                        .where({
                            restaurantID: prediction.restaurantID,
                            visitDate: prediction.visitDate
                        })
                );
            }
        });

        return normalizedPredictions.length;
    });
};
