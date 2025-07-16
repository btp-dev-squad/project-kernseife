using AnalyticsService as service from '../../srv/analytics-service';

annotate service.DevelopmentObjects with @(
    UI.Chart #cleanCoreScore              : {
        $Type              : 'UI.ChartDefinitionType',
        Title              : '{i18n>cleanCoreScore}',
        ChartType          : #Column,
        Dimensions         : [cleanCoreScore],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: cleanCoreScore,
            Role     : #Category
        }],
        Measures           : [objectCount],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: objectCount,
            Role   : #Axis1,
        }]
    },
    UI.PresentationVariant #cleanCoreScore: {

        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : cleanCoreScore,
            Descending: true
        }],
        Visualizations: ['@UI.Chart#cleanCoreScore']
    },
    UI.DataPoint #cleanCoreScore          : {
        $Type: 'UI.DataPointType',
        Value: cleanCoreScore,
        Title: '{i18n>cleanCoreScore}',
    },

    UI.Identification #cleanCoreScore     : [{
        $Type         : 'UI.DataFieldForIntentBasedNavigation',
        SemanticObject: 'DevelopmentObjects',
        Action        : 'manage',
    }, ]
);


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
