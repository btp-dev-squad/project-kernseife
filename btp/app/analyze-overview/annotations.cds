using AnalyticsService as service from '../../srv/analytics-service';


annotate service.DevelopmentObjects with @(
    UI.Chart #languageVersionShare               : {
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
    UI.PresentationVariant #languageVersionShare : {
        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : languageVersion_code,
            Descending: true
        }],
        Visualizations: ['@UI.Chart#languageVersionShare']
    },
    UI.DataPoint #languageVersionShare           : {
        $Type: 'UI.DataPointType',
        Value: objectCount,
        Title: '{i18n>languageVersionShare}',
    },

    UI.Identification #languageVersionShare      : [{
        $Type         : 'UI.DataFieldForIntentBasedNavigation',
        SemanticObject: 'DevelopmentObjects',
        Action        : 'manage',
    }, ],


    UI.Chart #levelShare                         : {
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
            Role   : #Axis1,
        }]
    },
    UI.PresentationVariant #levelShare           : {
        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : level,
            Descending: false,

        }],
        Visualizations: ['@UI.Chart#levelShare']
    },
    UI.DataPoint #levelShare                     : {
        $Type: 'UI.DataPointType',
        Value: objectCount,
        Title: '{i18n>levelShare }',

    },

    UI.Identification #levelShare                : [{
        $Type         : 'UI.DataFieldForIntentBasedNavigation',
        SemanticObject: 'DevelopmentObjects',
        Action        : 'manage',
    }, ]

    ,
    UI.Chart #scoreShare                         : {
        $Type              : 'UI.ChartDefinitionType',
        Title              : '{i18n>scoreShare}',
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
            Measure: score,
            Role   : #Axis1
        }]
    },
    UI.PresentationVariant #scoreShare           : {
        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : level,
            Descending: false,

        }],
        Visualizations: ['@UI.Chart#levelShare']
    },
    UI.DataPoint #scoreShare                     : {
        $Type: 'UI.DataPointType',
        Value: score,
        Title: '{i18n>scoreShare }',

    },

    UI.Identification #scoreShare                : [{
        $Type         : 'UI.DataFieldForIntentBasedNavigation',
        SemanticObject: 'DevelopmentObjects',
        Action        : 'manage',
    }, ],
    UI.LineItem #topDevelopmentObjects           : [
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>objectType}',
            ![@UI.Importance]: #High,
            Value            : objectType
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>objectName}',
            ![@UI.Importance]: #High,
            Value            : objectName,

        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>devClass}',
            ![@UI.Importance]: #Low,
            Value            : devClass
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>level}',
            ![@UI.Importance]: #Low,
            Value            : level
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>score}',
            ![@UI.Importance]: #Low,
            Value            : score
        }
    ],
    UI.PresentationVariant #topDevelopmentObjects: {SortOrder: [{
        Property  : score,
        Descending: true
    }, ]},
);

annotate service.Classifications with @(
    UI.Chart #ratingShare              : {
        $Type              : 'UI.ChartDefinitionType',
        Title              : '{i18n>ratingShare}',
        ChartType          : #Column,
        Dimensions         : [rating_code],

        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: rating_code,
            Role     : #Category
        }],
        Measures           : [objectCount],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: objectCount,
            Role   : #Axis1,
        }]
    },
    UI.PresentationVariant #ratingShare: {
        MaxItems      : 8,
        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : objectCount,
            Descending: true,

        }],
        Visualizations: ['@UI.Chart#ratingShare']
    },
    UI.DataPoint #ratingShare          : {
        $Type      : 'UI.DataPointType',
        Value      : objectCount,
        Title      : '{i18n>ratingShare}',
        Description: '{i18n>objectCount}',
    },

    UI.Identification #ratingShare     : [{
        $Type         : 'UI.DataFieldForIntentBasedNavigation',
        SemanticObject: 'Classifications',
        Action        : 'manage',
    }, ]


);


annotate service.DevClasses with @(

    UI.LineItem #topPackagesByScoreSum              : [
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>devClass}',
            ![@UI.Importance]: #High,
            Value            : devClass,
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>level}',
            ![@UI.Importance]: #Low,
            Value            : level
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>score}',
            ![@UI.Importance]: #High,
            Value            : score
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>objectCount}',
            ![@UI.Importance]: #Low,
            Value            : objectCount
        },
        {
            $Type            : 'UI.DataFieldForAnnotation',
            Target           : '@UI.DataPoint#AverageScore',
            Label            : '{i18n>averageScore}',
            ![@UI.Importance]: #Low,
        }
    ],
    UI.LineItem #topPackagesByScoreAvg              : [
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>devClass}',
            ![@UI.Importance]: #High,
            Value            : devClass,
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>level}',
            ![@UI.Importance]: #Low,
            Value            : level
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>objectCount}',
            ![@UI.Importance]: #Low,
            Value            : objectCount
        },
        {
            $Type            : 'UI.DataFieldForAnnotation',
            Target           : '@UI.DataPoint#AverageScore',
            Label            : '{i18n>averageScore}',
            ![@UI.Importance]: #High,
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>score}',
            ![@UI.Importance]: #Low,
            Value            : score
        }
    ],
    UI.LineItem #topPackagesByObjectCount           : [
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>devClass}',
            ![@UI.Importance]: #High,
            Value            : devClass,
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>level}',
            ![@UI.Importance]: #Low,
            Value            : level
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>objectCount}',
            ![@UI.Importance]: #High,
            Value            : objectCount
        },
        {
            $Type            : 'UI.DataFieldForAnnotation',
            Target           : '@UI.DataPoint#AverageScore',
            Label            : '{i18n>averageScore}',
            ![@UI.Importance]: #Low,
        },
        {
            $Type            : 'UI.DataField',
            Label            : '{i18n>score}',
            ![@UI.Importance]: #Low,
            Value            : score
        }
    ],
    UI.DataPoint #AverageScore                      : {
        $Type      : 'UI.DataPointType',
        Title      : '{i18n>averageScore}',
        Value      : averageScore,
        ValueFormat: {
            NumberOfFractionalDigits: 0,
            ScaleFactor             : 1,
        }
    },

    UI.PresentationVariant #topPackagesByScoreSum   : {SortOrder: [{
        Property  : score,
        Descending: true,

    }, ], },
    UI.PresentationVariant #topPackagesByScoreAvg   : {SortOrder: [{
        Property  : averageScore,
        Descending: true
    }, ]},
    UI.PresentationVariant #topPackagesByObjectCount: {SortOrder: [{
        Property  : objectCount,
        Descending: true
    }, ]},


);
