namespace restaurantforecast;

/**
 * Historical restaurant demand observations used as context and
 * held-out evaluation data for visitor predictions.
 */
entity VisitorHistory {
    key visitDate        : Date
                           @title: 'Visit Date';
    key restaurantID     : String(40)
                           @title: 'Restaurant ID';

        dayOfWeek        : String(10) not null
                           @title: 'Day of Week';
        holiday          : Boolean not null default false
                           @title: 'Holiday';
        reservedVisitors : Integer not null default 0
                           @title: 'Reserved Visitors';
        actualVisitors   : Integer not null
                           @title: 'Actual Visitors';
        predictedVisitors: Integer
                           @title: 'Predicted Visitors';
}
