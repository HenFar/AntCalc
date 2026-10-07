Get["AntennaPipeline.wl"];

ClearAll[
  makeRuntimeBuildRRatioReport,
  makeTargetPatchedIngredients,
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

makeTargetPatchedIngredients[ingredients_Association, which_String] :=
  Module[{patched, a31Targets, a22Targets},
    patched = Association[ingredients];
    a31Targets = A31IntegratedAntennaTargets[0];
    a22Targets = A22TTermTargets[0];
    Switch[which,
      "A31",
        patched["intA31"] = a31Targets[[1]];
        patched["intTildeA31"] = a31Targets[[2]];
        patched["intHatA31"] = a31Targets[[3]];
      ,
      "A22",
        patched["intA22"] = a22Targets[[1]];
        patched["intTildeA22"] = a22Targets[[2]];
        patched["intHatA22"] = a22Targets[[3]];
        patched["intBreveA22"] = a22Targets[[4]];
      ,
      "A31A22",
        patched["intA31"] = a31Targets[[1]];
        patched["intTildeA31"] = a31Targets[[2]];
        patched["intHatA31"] = a31Targets[[3]];
        patched["intA22"] = a22Targets[[1]];
        patched["intTildeA22"] = a22Targets[[2]];
        patched["intHatA22"] = a22Targets[[3]];
        patched["intBreveA22"] = a22Targets[[4]];
      ,
      _,
        Null
    ];
    patched
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
    a31PatchedExpression,
    a22PatchedExpression,
    bothPatchedExpression
  },
  {runtimeExpression, diagnostics} = makeRuntimeBuildRRatioReport[];
  ingredients = Lookup[diagnostics, "Ingredients", Missing["NoIngredients"]];
  If[!AssociationQ[ingredients],
    Print["No ingredient association was available in diagnostics."];
    Abort[]
  ];

  runtimeSummary = poleSummary[runtimeExpression];
  a31PatchedExpression =
    AssembleSMQCDRRatio[
      makeTargetPatchedIngredients[ingredients, "A31"]
    ]["FinalExpression"];
  a22PatchedExpression =
    AssembleSMQCDRRatio[
      makeTargetPatchedIngredients[ingredients, "A22"]
    ]["FinalExpression"];
  bothPatchedExpression =
    AssembleSMQCDRRatio[
      makeTargetPatchedIngredients[ingredients, "A31A22"]
    ]["FinalExpression"];

  Print["Runtime summary:"];
  Print[runtimeSummary];
  Print["A31-target-substituted summary:"];
  Print[poleSummary[a31PatchedExpression]];
  Print["A22-target-substituted summary:"];
  Print[poleSummary[a22PatchedExpression]];
  Print["A31+A22-target-substituted summary:"];
  Print[poleSummary[bothPatchedExpression]];
];
