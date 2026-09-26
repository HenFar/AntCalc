Get["AntennaPipeline.wl"];
Get[FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]], "dev",
  "a22_literature_reference.wl"}]];

ClearAll[
  makeRuntimeBuildRRatioReport,
  makeTargetReferenceIngredients,
  poleSummary
];

makeRuntimeBuildRRatioReport[] :=
  Module[{result, diagnostics},
    result =
      BuildRRatio[
        SMQCD,
        ResultForm -> "RawDimRegSeries",
        ReturnDiagnostics -> True,
        UseStoredResults -> False,
        StoreResults -> False,
        RefreshStoredResults -> False
      ];
    If[!MatchQ[result, {_, _Association}],
      Print["BuildRRatio did not return {result, diagnostics}."];
      Abort[]
    ];
    {result[[1]], result[[2]]}
  ];

makeTargetReferenceIngredients[ingredients_Association, which_String] :=
  Module[{referenceIngredients, a31Targets, a22Targets},
    referenceIngredients = Association[ingredients];
    a31Targets = A31IntegratedAntennaTargets[0];
    a22Targets = A22LiteratureReferenceTargets[0];
    Switch[which,
      "A31",
        referenceIngredients["intA31"] = a31Targets[[1]];
        referenceIngredients["intTildeA31"] = a31Targets[[2]];
        referenceIngredients["intHatA31"] = a31Targets[[3]];
      ,
      "A22",
        referenceIngredients["intA22"] = a22Targets[[1]];
        referenceIngredients["intTildeA22"] = a22Targets[[2]];
        referenceIngredients["intHatA22"] = a22Targets[[3]];
        referenceIngredients["intBreveA22"] = a22Targets[[4]];
      ,
      "A31A22",
        referenceIngredients["intA31"] = a31Targets[[1]];
        referenceIngredients["intTildeA31"] = a31Targets[[2]];
        referenceIngredients["intHatA31"] = a31Targets[[3]];
        referenceIngredients["intA22"] = a22Targets[[1]];
        referenceIngredients["intTildeA22"] = a22Targets[[2]];
        referenceIngredients["intHatA22"] = a22Targets[[3]];
        referenceIngredients["intBreveA22"] = a22Targets[[4]];
      ,
      _,
        Null
    ];
    referenceIngredients
  ];

poleSummary[expr_] :=
  <|
    "Poles" -> RRatioPoleCoefficientAssociation[expr],
    "FiniteResidual" ->
      SafeIntegratedResidualSimplify[
        RRatioFiniteCoefficient[expr] - BuildRRatioSMQCDReferenceFiniteExpression[NNLO]
      ]
  |>;

Module[
  {
    runtimeExpression,
    diagnostics,
    ingredients,
    runtimeSummary,
    a31ReferenceExpression,
    a22ReferenceExpression,
    bothReferenceExpression
  },
  {runtimeExpression, diagnostics} = makeRuntimeBuildRRatioReport[];
  ingredients = Lookup[diagnostics, "Ingredients", Missing["NoIngredients"]];
  If[!AssociationQ[ingredients],
    Print["No ingredient association was available in diagnostics."];
    Abort[]
  ];

  runtimeSummary = poleSummary[runtimeExpression];
  a31ReferenceExpression =
    AssembleSMQCDRRatio[
      makeTargetReferenceIngredients[ingredients, "A31"]
    ]["FinalExpression"];
  a22ReferenceExpression =
    AssembleSMQCDRRatio[
      makeTargetReferenceIngredients[ingredients, "A22"]
    ]["FinalExpression"];
  bothReferenceExpression =
    AssembleSMQCDRRatio[
      makeTargetReferenceIngredients[ingredients, "A31A22"]
    ]["FinalExpression"];

  Print["Runtime summary:"];
  Print[runtimeSummary];
  Print["A31-target-substituted summary:"];
  Print[poleSummary[a31ReferenceExpression]];
  Print["A22-target-substituted summary:"];
  Print[poleSummary[a22ReferenceExpression]];
  Print["A31+A22-target-substituted summary:"];
  Print[poleSummary[bothReferenceExpression]];
];
