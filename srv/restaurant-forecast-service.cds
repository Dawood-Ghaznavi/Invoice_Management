using { restaurantforecast as forecast } from '../db/schema/restaurant-forecast-schema';

/**
 * Historical restaurant visitor data and prediction operations for the RPT
 * forecasting demo.
 */
@path: '/restaurant-forecast'
service RestaurantForecastService {

    @readonly
    entity VisitorHistory as projection on forecast.VisitorHistory;

    type PredictionResult {
        restaurantID      : String(40);
        visitDate         : Date;
        dayOfWeek         : String(10);
        predictedVisitors : Integer;
        actualVisitors    : Integer;
        accuracy          : Decimal(7, 2);
    }

    type PredictionResponse {
        contextRecordCount : Integer;
        results            : many PredictionResult;
    }

    type PredictionToSave {
        restaurantID      : String(40);
        visitDate         : Date;
        predictedVisitors : Integer;
    }

    action predictVisitors(
        fromDate : Date,
        toDate   : Date
    ) returns PredictionResponse;

    action savePredictions(
        predictions : many PredictionToSave
    ) returns Integer;
}
