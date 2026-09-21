using RestaurantForecastService as service from '../../restaurant-forecast-service';

// =============================================================================
// General properties
// =============================================================================

annotate service.VisitorHistory with {
    visitDate        @(title: 'Visit Date');
    restaurantID     @(title: 'Restaurant ID');
    dayOfWeek        @(title: 'Day of Week');
    holiday          @(title: 'Holiday');
    reservedVisitors @(title: 'Reserved Visitors');
    actualVisitors   @(title: 'Actual Visitors');
    predictedVisitors @(title: 'Predicted Visitors');
}

// =============================================================================
// List Report
// =============================================================================

annotate service.VisitorHistory with @(
    UI.SelectionFields: [
        visitDate,
        restaurantID,
        dayOfWeek,
        holiday
    ],
    UI.LineItem       : [
        {
            $Type         : 'UI.DataField',
            Value         : visitDate,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : dayOfWeek,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : reservedVisitors,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : predictedVisitors,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : actualVisitors,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Value         : holiday,
            @UI.Importance: #Medium
        },
        {
            $Type         : 'UI.DataField',
            Value         : restaurantID,
            @UI.Importance: #Low
        }
    ],
    UI.PresentationVariant: {
        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : visitDate,
            Descending: true
        }],
        Visualizations: ['@UI.LineItem']
    },
    UI.HeaderInfo     : {
        TypeName      : 'Visitor Record',
        TypeNamePlural: 'Visitor History',
        Title         : {Value: visitDate},
        Description   : {Value: restaurantID}
    },
    Capabilities.FilterRestrictions: {
        FilterExpressionRestrictions: [{
            Property          : visitDate,
            AllowedExpressions: 'SingleRange'
        }]
    }
);
