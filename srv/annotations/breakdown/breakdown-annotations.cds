using BreakdownService as service from '../../breakdown-service';

// =============================================================================
// General properties
// =============================================================================

annotate service.Reports with {
    reportNumber @(
        title              : 'Report Number',
        Common.FieldControl: #ReadOnly
    );

    equipment      @(title: 'Equipment');
    businessStatus @(title: 'Status');
}

annotate service.Equipment with {
    equipmentID @(
        title                 : 'Equipment',
        Common.Text           : name,
        Common.TextArrangement: #TextFirst
    );
    name     @(title: 'Equipment Name');
    location @(title: 'Location');
}

// =============================================================================
// List Report and Object Page header
// =============================================================================

annotate service.Reports with @(
    UI.LineItem : [
        {
            $Type         : 'UI.DataField',
            Value         : reportNumber,
            @UI.Importance: #High
        }
    ],
    UI.HeaderInfo: {
        TypeName      : 'Breakdown Report',
        TypeNamePlural: 'Breakdown Reports',
        Title         : {Value: reportNumber},
        Description   : {Value: businessStatus}
    },
    UI.HeaderFacets: [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'EquipmentHeaderFacet',
            Label : 'Equipment',
            Target: '@UI.FieldGroup#EquipmentHeader'
        }
    ],
    UI.FieldGroup #EquipmentHeader: {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: equipment.equipmentID,
            Label: ''
        }]
    }
);
