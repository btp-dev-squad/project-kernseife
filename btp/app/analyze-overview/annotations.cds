using AnalyticsService as service from '../../srv/analytics-service';

annotate service.DevelopmentObjects with @(
    UI.Chart #languageVersionShare              : {
        $Type              : 'UI.ChartDefinitionType',
        Title              : '{i18n>languageVersionShare}',
        ChartType          : #Donut,
        Dimensions         : [languageVersion_code],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: languageVersion_code,
            Role     : #Category
        }],
        Measures           : [objectCount],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: objectCount,
            Role   : #Axis1,
        }]
    },
    UI.PresentationVariant #languageVersionShare: {
        MaxItems      : 3,
        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : languageVersion_code,
            Descending: true
        }],
        Visualizations: ['@UI.Chart#languageVersionShare']
    },
    UI.DataPoint #languageVersionShare          : {
        $Type: 'UI.DataPointType',
        Value: objectCount,
        Title: '{i18n>languageVersionShare}',
    },

    UI.Identification #languageVersionShare     : [{
        $Type         : 'UI.DataFieldForIntentBasedNavigation',
        SemanticObject: 'DevelopmentObjects',
        Action        : 'manage',
    }, ]
);

annotate service.DevelopmentObjects with @(


    UI.Chart #levelShare              : {
        $Type              : 'UI.ChartDefinitionType',
        Title              : '{i18n>levelShare}',
        ChartType          : #Donut,
        Dimensions         : [level],

        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: level,
            Role     : #Category
        }],
        Measures           : [objectCount],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: objectCount,
            Role   : #Axis1
        }]
    },
    UI.PresentationVariant #levelShare: {
        MaxItems      : 3,
        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : level,
            Descending: false,

        }],
        Visualizations: ['@UI.Chart#levelShare']
    },
    UI.DataPoint #levelShare          : {
        $Type: 'UI.DataPointType',
        Value: objectCount,
        Title: '{i18n>levelShare }',

    },

    UI.Identification #levelShare     : [{
        $Type         : 'UI.DataFieldForIntentBasedNavigation',
        SemanticObject: 'DevelopmentObjects',
        Action        : 'manage',
    }, ]
);
