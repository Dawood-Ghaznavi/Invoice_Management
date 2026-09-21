using RestaurantForecastService as service from '../../restaurant-forecast-service';

// =============================================================================
// General properties
// =============================================================================

annotate service.VisitorHistory with {
    visitDate        @(title: 'Date');
    restaurantID     @(title: 'Restaurant ID');
    dayOfWeek        @(title: 'Day');
    holiday          @(title: 'Is Holiday?');
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
        dayOfWeek,
        holiday
    ],
    UI.LineItem       : [
        {
            $Type         : 'UI.DataField',
            Label         : 'Date',
            Value         : visitDate,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Label         : 'Day',
            Value         : dayOfWeek,
            @UI.Importance: #High
        },
        {
            $Type         : 'UI.DataField',
            Label         : 'Is Holiday?',
            Value         : holiday,
            @UI.Importance: #Medium
        },
        {
            $Type         : 'UI.DataField',
            Label         : 'Reserved Visitors',
            Value         : reservedVisitors,
            @UI.Importance: #High
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
