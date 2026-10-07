(*************************************************)

(*
  Public R-ratio driver.
  This layer assembles the validated integrated antenna ingredients into the
  symbolic NNLO R-ratio combination used in the thesis notebook package.
*)

(*************************************************)

BuildRRatio::usage =
  "BuildRRatio[model, ...] builds the public symbolic R-ratio driver output for the selected model shell.";

CollectRRatioIntermediateSteps::usage =
  "CollectRRatioIntermediateSteps[ingredientCalls, ingredients, assemblyExpression, finalExpression, diagnostics, steps] collects the requested driver-side intermediate stages.";

RRatioFailureResult::usage =
  "RRatioFailureResult[result, diagnostics, intermediateSteps, returnDiagnostics] formats a failing R-ratio evaluation in the public return shape.";

RRatioModelShellFailure::usage =
  "RRatioModelShellFailure[model, returnDiagnostics, intermediateSteps] returns the standard placeholder failure for an unimplemented model shell.";

FormatFreshRRatioReturn::usage =
  "FormatFreshRRatioReturn[result, diagnostics, returnDiagnostics, requestedSteps, printSteps] formats a fresh R-ratio evaluation in the public return shape.";

RRatioIngredientCallFailedQ::usage =
  "RRatioIngredientCallFailedQ[result] tests whether one nested ingredient call failed.";

RRatioProgressPrint::usage =
  "RRatioProgressPrint[label, status] prints the lightweight progress messages used by fresh BuildRRatio evaluations.";

EvaluateRRatioIngredient::usage =
  "EvaluateRRatioIngredient[label, expr] evaluates one nested ingredient call with fresh-run progress logging.";

EvaluateRRatioStoredIngredient::usage =
  "EvaluateRRatioStoredIngredient[label, expr] evaluates one nested ingredient call while preserving the shorter stored-result logging path.";

BuildRRatioIngredientCallAssociation::usage =
  "BuildRRatioIngredientCallAssociation[masslessQuarkMass] returns the named nested ingredient requests used by the massless SMQCD driver.";

BuildRRatioIngredientCacheOptions::usage =
  "BuildRRatioIngredientCacheOptions[options] resolves the cache behavior passed from the top-level driver to its nested ingredient calls.";

BuildRRatioStoredResultKey::usage =
  "BuildRRatioStoredResultKey[model, options] builds the cache key for a BuildRRatio request.";

BuildRRatioStoredResultLabel::usage =
  "BuildRRatioStoredResultLabel[model, options] builds the human-readable cache label for a BuildRRatio request.";

BuildRRatioSMQCDIngredients::usage =
  "BuildRRatioSMQCDIngredients[masslessQuarkMass, options] collects the validated integrated antenna ingredients used by the massless SMQCD driver.";

AssembleSMQCDRRatio::usage =
  "AssembleSMQCDRRatio[ingredients] assembles the final symbolic massless SMQCD R-ratio expression from the validated antenna ingredients.";

Options[BuildRRatio] = {quarkMass -> 0, ReturnDiagnostics -> False,
   IntermediateSteps -> {}, PrintIntermediateSteps -> False,
   UseStoredResults -> False, StoreResults -> False,
   ResultsCacheRoot -> Automatic, RefreshStoredResults -> False};

BuildRRatio::unsupportedModel =
  "Unsupported R-ratio model `1`. Supported model shells are SMQCD, SUSY, and HiggsEFT.";

BuildRRatio::masslessOnly =
  "BuildRRatio[`1`] currently supports only quarkMass -> 0.";

BuildRRatio::ingredientFailure =
  "BuildRRatio[`1`] could not build the required ingredient `2` through the public antenna routes.";

CollectRRatioIntermediateSteps[ingredientCalls_, ingredients_,
   assemblyExpression_, finalExpression_, diagnostics_, steps_List] :=
  Module[{collected = <||>},
    If[RequestedIntermediateStepQ[steps, "IngredientCalls"],
      collected = Join[collected, <|"IngredientCalls" -> ingredientCalls|>]
    ];
    If[RequestedIntermediateStepQ[steps, "Ingredients"],
      collected = Join[collected, <|"Ingredients" -> ingredients|>]
    ];
    If[RequestedIntermediateStepQ[steps, "AssemblyExpression"],
      collected = Join[collected, <|"AssemblyExpression" -> assemblyExpression|>]
    ];
    If[RequestedIntermediateStepQ[steps, "FinalExpression"],
      collected = Join[collected, <|"FinalExpression" -> finalExpression|>]
    ];
    If[RequestedIntermediateStepQ[steps, "DriverDiagnostics"],
      collected = Join[collected, <|"DriverDiagnostics" -> diagnostics|>]
    ];
    collected
  ];

RRatioFailureResult[result_, diagnostics_, intermediateSteps_, returnDiagnostics_] :=
  Module[{diagnosticsWithSteps = diagnostics},
    If[Length[intermediateSteps] > 0,
      diagnosticsWithSteps =
        Join[diagnosticsWithSteps, <|"IntermediateSteps" -> intermediateSteps|>]
    ];
    If[TrueQ[returnDiagnostics],
      {result, diagnosticsWithSteps}
      ,
      If[Length[intermediateSteps] > 0,
        {result, intermediateSteps}
        ,
        result
      ]
    ]
  ];

RRatioModelShellFailure[model_Symbol, returnDiagnostics_, intermediateSteps_] :=
  Module[{modelName, diagnostics, collectedSteps},
    modelName = SymbolName[Unevaluated[model]];
    Print[
      "BuildRRatio[", modelName,
      ", ...] is not implemented yet. The public model shell exists, but the ",
      modelName, " R-ratio driver is still a placeholder."
    ];
    diagnostics = <|"Failed" -> True, "Reason" -> "RRatioModelNotImplemented",
      "Model" -> modelName|>;
    collectedSteps = CollectRRatioIntermediateSteps[<||>, <||>,
      Missing["NotAvailable"], $Failed, diagnostics, intermediateSteps];
    RRatioFailureResult[$Failed, diagnostics, collectedSteps,
      returnDiagnostics]
  ];

FormatFreshRRatioReturn[result_, diagnostics_, returnDiagnostics_,
   requestedSteps_List, printSteps_] :=
  Module[{selectedSteps},
    selectedSteps = Lookup[diagnostics, "IntermediateSteps", <||>];
    If[TrueQ[printSteps] && AssociationQ[selectedSteps] && Length[
        selectedSteps] > 0,
      PrintIntermediateStepsAssociation[selectedSteps]
    ];
    If[TrueQ[returnDiagnostics],
      {result, diagnostics}
      ,
      If[Length[requestedSteps] > 0,
        {result, selectedSteps}
        ,
        result
      ]
    ]
  ];

RRatioIngredientCallFailedQ[result_] :=
  result === $Failed ||
    MatchQ[result, {$Failed, _Association}] ||
    MatchQ[result, {$Failed, _}];

RRatioProgressPrint[label_String, status_String] :=
  Print[
    "[", DateString[{"ISODate", " ", "Time"}], "] ",
    "BuildRRatio[SMQCD]: ", status, " ", label
  ];

SetAttributes[EvaluateRRatioIngredient, HoldAll];

EvaluateRRatioIngredient[label_String, expr_] :=
  Module[{result},
    RRatioProgressPrint[label, "starting"];
    result = Quiet[expr, IntegrateAntenna::heavy];
    RRatioProgressPrint[label, "finished"];
    result
  ];

EvaluateRRatioStoredIngredient[label_String, expr_] :=
  Module[{result},
    RRatioProgressPrint[label, "starting"];
    result =
      Block[{$AntennaPipelineBypassStoredResults = False},
        Quiet[expr, IntegrateAntenna::heavy]
      ];
    RRatioProgressPrint[label, "finished"];
    result
  ];

SetAttributes[EvaluateRRatioStoredIngredient, HoldAll];

BuildRRatioIngredientCallAssociation[masslessQuarkMass_] :=
  <|
    "intA21" -> HoldForm[
      BuildAndIntegrateAntenna[A, 2, 1, quarkMass -> masslessQuarkMass,
        ReturnDiagnostics -> True]
    ],
    "intA30" -> HoldForm[
      BuildAndIntegrateAntenna[A, 3, 0, quarkMass -> masslessQuarkMass,
        ReturnDiagnostics -> True, ExpansionOrder -> 2]
    ],
    "A31Components" -> HoldForm[
      BuildAndIntegrateAntenna[A, 3, 1, quarkMass -> masslessQuarkMass,
        ReturnDiagnostics -> True, ExpansionOrder -> 0]
    ],
    "A22Components" -> HoldForm[
      BuildAndIntegrateAntenna[A, 2, 2, quarkMass -> masslessQuarkMass,
        ReturnDiagnostics -> True, ExpansionOrder -> 0]
    ],
    "intA40" -> HoldForm[
      BuildAndIntegrateAntenna[A, 4, 0, Component -> Leading,
        quarkMass -> masslessQuarkMass, ReturnDiagnostics -> True,
        ExpansionOrder -> 0]
    ],
    "intTildeA40" -> HoldForm[
      BuildAndIntegrateAntenna[A, 4, 0, Component -> Subleading,
        quarkMass -> masslessQuarkMass, ReturnDiagnostics -> True,
        ExpansionOrder -> 0]
    ],
    "intB40" -> HoldForm[
      BuildAndIntegrateAntenna[B, 4, 0, quarkMass -> masslessQuarkMass,
        ReturnDiagnostics -> True, ExpansionOrder -> 0]
    ],
    "intC40" -> HoldForm[
      BuildAndIntegrateAntenna[C, 4, 0, quarkMass -> masslessQuarkMass,
        ReturnDiagnostics -> True, ExpansionOrder -> 0]
    ]
  |>;

BuildRRatioIngredientCacheOptions[options_Association] :=
  Module[{useStored, storeStored, refreshStored, cacheRoot},
    useStored = TrueQ[Lookup[options, "UseStoredResults", False]];
    storeStored = TrueQ[Lookup[options, "StoreResults", False]];
    refreshStored = TrueQ[Lookup[options, "RefreshStoredResults", False]];
    cacheRoot = Lookup[options, "ResultsCacheRoot", Automatic];
    <|
      "UseStoredResults" -> (useStored || storeStored || refreshStored),
      "StoreResults" -> storeStored,
      "RefreshStoredResults" -> False,
      "ResultsCacheRoot" -> cacheRoot
    |>
  ];

BuildRRatioStoredResultKey[model_Symbol, options_Association] :=
  StoredResultKeyAssociation[
    "BuildRRatio",
    <|
      "Model" -> SymbolName[Unevaluated[model]],
      "quarkMass" -> Lookup[options, "quarkMass", 0]
    |>
  ];

BuildRRatioStoredResultLabel[model_Symbol, options_Association] :=
  StringJoin[
    "BuildRRatio-",
    ToLowerCase[SymbolName[Unevaluated[model]]], "-",
    StringReplace[ToString[Lookup[options, "quarkMass", 0], InputForm],
      {" " -> "", "." -> "-", "/" -> "-"}]
  ];

BuildRRatioSMQCDIngredients[masslessQuarkMass_, options_Association:<||>] :=
  Module[{cacheOptions, a21Result, a30Result, a31Result, a22Result,
     a40LeadResult, a40SubResult, b40Result, c40Result, ingredients,
     ingredientDiagnostics},
    cacheOptions = BuildRRatioIngredientCacheOptions[options];
    a21Result =
      EvaluateRRatioStoredIngredient["intA21",
        BuildAndIntegrateAntenna[A, 2, 1, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True,
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a30Result =
      EvaluateRRatioStoredIngredient["intA30",
        BuildAndIntegrateAntenna[A, 3, 0, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True, ExpansionOrder -> 2,
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a31Result =
      EvaluateRRatioStoredIngredient["A31 components",
        BuildAndIntegrateAntenna[A, 3, 1, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True, ExpansionOrder -> 0,
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a22Result =
      EvaluateRRatioStoredIngredient["A22 components",
        BuildAndIntegrateAntenna[A, 2, 2, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True, ExpansionOrder -> 0,
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a40LeadResult =
      EvaluateRRatioStoredIngredient["intA40",
        BuildAndIntegrateAntenna[A, 4, 0, Component -> Leading,
          quarkMass -> masslessQuarkMass, ReturnDiagnostics -> True,
          ExpansionOrder -> 0,
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a40SubResult =
      EvaluateRRatioStoredIngredient["intTildeA40",
        BuildAndIntegrateAntenna[A, 4, 0, Component -> Subleading,
          quarkMass -> masslessQuarkMass, ReturnDiagnostics -> True,
          ExpansionOrder -> 0,
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    b40Result =
      EvaluateRRatioStoredIngredient["intB40",
        BuildAndIntegrateAntenna[B, 4, 0, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True, ExpansionOrder -> 0,
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    c40Result =
      EvaluateRRatioStoredIngredient["intC40",
        BuildAndIntegrateAntenna[C, 4, 0, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True, ExpansionOrder -> 0,
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    If[RRatioIngredientCallFailedQ[a21Result],
      Return[<|"Failed" -> True, "Reason" -> "IngredientRouteFailed",
        "FailedIngredient" -> "intA21"|>]
    ];
    If[RRatioIngredientCallFailedQ[a30Result],
      Return[<|"Failed" -> True, "Reason" -> "IngredientRouteFailed",
        "FailedIngredient" -> "intA30"|>]
    ];
    If[RRatioIngredientCallFailedQ[a31Result],
      Return[<|"Failed" -> True, "Reason" -> "IngredientRouteFailed",
        "FailedIngredient" -> "A31Components"|>]
    ];
    If[RRatioIngredientCallFailedQ[a22Result],
      Return[<|"Failed" -> True, "Reason" -> "IngredientRouteFailed",
        "FailedIngredient" -> "A22Components"|>]
    ];
    If[RRatioIngredientCallFailedQ[a40LeadResult],
      Return[<|"Failed" -> True, "Reason" -> "IngredientRouteFailed",
        "FailedIngredient" -> "intA40"|>]
    ];
    If[RRatioIngredientCallFailedQ[a40SubResult],
      Return[<|"Failed" -> True, "Reason" -> "IngredientRouteFailed",
        "FailedIngredient" -> "intTildeA40"|>]
    ];
    If[RRatioIngredientCallFailedQ[b40Result],
      Return[<|"Failed" -> True, "Reason" -> "IngredientRouteFailed",
        "FailedIngredient" -> "intB40"|>]
    ];
    If[RRatioIngredientCallFailedQ[c40Result],
      Return[<|"Failed" -> True, "Reason" -> "IngredientRouteFailed",
        "FailedIngredient" -> "intC40"|>]
    ];
    If[!And @@ (MatchQ[#, {_, _Association}]& /@ {a21Result, a30Result,
        a31Result, a22Result, a40LeadResult, a40SubResult, b40Result,
        c40Result}),
      Return[<|"Failed" -> True, "Reason" -> "UnexpectedIngredientReturnShape",
        "FailedIngredient" -> "Unknown"|>]
    ];
    ingredients = <|
      "intA21" -> a21Result[[1]],
      "intA30" -> a30Result[[1]],
      "intA31" -> a31Result[[1, 1]],
      "intTildeA31" -> a31Result[[1, 2]],
      "intHatA31" -> a31Result[[1, 3]],
      "intA22" -> a22Result[[1, 1]],
      "intTildeA22" -> a22Result[[1, 2]],
      "intHatA22" -> a22Result[[1, 3]],
      "intBreveA22" -> a22Result[[1, 4]],
      "intA40" -> a40LeadResult[[1]],
      "intTildeA40" -> a40SubResult[[1]],
      "intB40" -> b40Result[[1]],
      "intC40" -> c40Result[[1]]
    |>;
    ingredientDiagnostics = <|
      "intA21" -> a21Result[[2]],
      "intA30" -> a30Result[[2]],
      "A31Components" -> a31Result[[2]],
      "A22Components" -> a22Result[[2]],
      "intA40" -> a40LeadResult[[2]],
      "intTildeA40" -> a40SubResult[[2]],
      "intB40" -> b40Result[[2]],
      "intC40" -> c40Result[[2]]
    |>;
    <|"Failed" -> False, "Ingredients" -> ingredients,
      "IngredientDiagnostics" -> ingredientDiagnostics|>
  ];

AssembleSMQCDRRatio[ingredients_Association] :=
  Module[{eps, alphaS, n, nf, Tqq2, Tqq4, Tqqg4, Tqq6, Tqqg6,
     Tqqqqprime6, Tqqqq6, Tqqgg6, cLO, cNLO, cNNLO, rLO, rNLO, rNNLO,
     assemblyExpression, finalExpression},
    eps = FeynCalc`Epsilon;
    alphaS = SMP["alpha_s"];
    n = SUNN;
    nf = Nf;
    Tqq2 = 4 n (1 - eps) q2;
    Tqq4 = (n - 1 / n) Tqq2 ingredients["intA21"];
    Tqqg4 = (n - 1 / n) Tqq2 ingredients["intA30"];
    Tqq6 =
      (n - 1 / n) Tqq2 (n ingredients["intA22"] +
        1 / n ingredients["intTildeA22"] + nf ingredients["intHatA22"]) +
      Tqq2 (n - 1 / n)^2 ingredients["intBreveA22"];
    Tqqg6 =
      (n - 1 / n) Tqq2 (
        n (ingredients["intA31"] +
          ingredients["intA21"] ingredients["intA30"]) -
        1 / n (ingredients["intTildeA31"] +
          ingredients["intA21"] ingredients["intA30"]) +
        nf ingredients["intHatA31"]
      );
    Tqqqqprime6 =
      (n - 1 / n) Tqq2 (nf - 1) ingredients["intB40"];
    Tqqqq6 =
      1 / (nf - 1) Tqqqqprime6 -
      Tqq2 (n - 1 / n) 1 / n ingredients["intC40"];
    Tqqgg6 =
      (n - 1 / n) Tqq2 (
        n ingredients["intA40"] -
        1 / n ingredients["intTildeA40"]
      );
    cLO = 1;
    rLO = 1;
    cNLO = alphaS / (2 Pi);
    rNLO =
      FullSimplify[
        (n - 1 / n) (ingredients["intA21"] + ingredients["intA30"])
      ];
    cNNLO = cNLO^2;
    rNNLO =
      FullSimplify[
        (n - 1 / n) (
          n ingredients["intA22"] +
          1 / n ingredients["intTildeA22"] +
          nf ingredients["intHatA22"] +
          (n - 1 / n) ingredients["intBreveA22"] +
          n (ingredients["intA31"] +
            ingredients["intA21"] ingredients["intA30"]) -
          1 / n (ingredients["intTildeA31"] +
            ingredients["intA21"] ingredients["intA30"]) +
          nf ingredients["intHatA31"] +
          nf ingredients["intB40"] -
          1 / n ingredients["intC40"] +
          n ingredients["intA40"] -
          1 / n ingredients["intTildeA40"]
        )
      ];
    assemblyExpression = cLO rLO + cNLO rNLO + cNNLO rNNLO;
    finalExpression =
      Collect[assemblyExpression, alphaS, FullSimplify];
    <|"AssemblyExpression" -> assemblyExpression,
      "FinalExpression" -> finalExpression,
      "TFactors" -> <|"Tqq2" -> Tqq2, "Tqq4" -> Tqq4, "Tqqg4" -> Tqqg4,
        "Tqq6" -> Tqq6, "Tqqg6" -> Tqqg6,
        "Tqqqqprime6" -> Tqqqqprime6, "Tqqqq6" -> Tqqqq6,
        "Tqqgg6" -> Tqqgg6|>,
      "Ratios" -> <|"cLO" -> cLO, "rLO" -> rLO, "cNLO" -> cNLO,
        "rNLO" -> rNLO, "cNNLO" -> cNNLO, "rNNLO" -> rNNLO|>|>
  ];

BuildRRatio[SMQCD, OptionsPattern[]] :=
  Module[{masslessQuarkMass, intermediateSteps, ingredientCalls,
     ingredientResult, ingredients, ingredientDiagnostics, assemblyResult,
     assemblyExpression, finalExpression, diagnostics, collectedSteps,
     useStored, storeStored, refreshStored, cacheKey, cacheLabel, cacheRoot,
     loaded, computed, computedResult, computedDiagnostics, optionsAssoc},
    masslessQuarkMass = OptionValue[quarkMass];
    intermediateSteps = NormalizeIntermediateSteps[OptionValue[
      IntermediateSteps]];
    useStored = TrueQ[OptionValue["UseStoredResults"]];
    storeStored = TrueQ[OptionValue["StoreResults"]];
    refreshStored = TrueQ[OptionValue["RefreshStoredResults"]];
    optionsAssoc = <|
      "quarkMass" -> masslessQuarkMass,
      "UseStoredResults" -> useStored,
      "StoreResults" -> storeStored,
      "RefreshStoredResults" -> refreshStored,
      "ResultsCacheRoot" -> OptionValue["ResultsCacheRoot"]
    |>;
    ingredientCalls = BuildRRatioIngredientCallAssociation[masslessQuarkMass];
    If[masslessQuarkMass =!= 0,
      Message[BuildRRatio::masslessOnly, "SMQCD"];
      diagnostics = <|"Failed" -> True, "Reason" -> "NonzeroQuarkMassUnsupported",
        "Model" -> "SMQCD", "quarkMass" -> masslessQuarkMass|>;
      collectedSteps = CollectRRatioIntermediateSteps[ingredientCalls, <||>,
        Missing["NotAvailable"], $Failed, diagnostics, intermediateSteps];
      If[TrueQ[OptionValue[PrintIntermediateSteps]] && Length[
          collectedSteps] > 0,
        PrintIntermediateStepsAssociation[collectedSteps]
      ];
      Return[
        RRatioFailureResult[$Failed, diagnostics, collectedSteps,
          OptionValue[ReturnDiagnostics]]
      ]
    ];
    If[!TrueQ[$AntennaPipelineBypassStoredResults] &&
        StoredResultsEnabledQ[useStored, storeStored, refreshStored],
      cacheKey = BuildRRatioStoredResultKey[SMQCD, optionsAssoc];
      cacheLabel = BuildRRatioStoredResultLabel[SMQCD, optionsAssoc];
      cacheRoot = OptionValue["ResultsCacheRoot"];
      If[!refreshStored && useStored,
        loaded = LoadStoredResultEntry["BuildRRatio", cacheKey, cacheRoot,
          cacheLabel];
        If[AssociationQ[loaded],
          PrintStoredResultHit[cacheLabel];
          Return[
            FormatStoredResultReturn[loaded["Result"],
              loaded["Diagnostics"], loaded, OptionValue[
                "ReturnDiagnostics"], intermediateSteps, OptionValue[
                "PrintIntermediateSteps"]]
          ]
        ]
      ];
      computed =
        Block[{$AntennaPipelineBypassStoredResults = True},
          BuildRRatio[SMQCD,
            quarkMass -> masslessQuarkMass,
            ReturnDiagnostics -> True,
            IntermediateSteps -> OptionValue["IntermediateSteps"],
            PrintIntermediateSteps -> False,
            UseStoredResults -> True,
            StoreResults -> False,
            ResultsCacheRoot -> cacheRoot,
            RefreshStoredResults -> False]
        ];
      If[!MatchQ[computed, {_, _Association}],
        Return[computed]
      ];
      {computedResult, computedDiagnostics} = computed;
      If[computedResult =!= $Failed && (storeStored || refreshStored),
        StoreStoredResultEntry["BuildRRatio", cacheKey, cacheRoot,
          cacheLabel, computedResult, computedDiagnostics]
      ];
      Return[
        FormatFreshRRatioReturn[computedResult, computedDiagnostics,
          OptionValue["ReturnDiagnostics"], intermediateSteps, OptionValue[
            "PrintIntermediateSteps"]]
      ]
    ];
    ingredientResult = BuildRRatioSMQCDIngredients[masslessQuarkMass,
      optionsAssoc];
    If[TrueQ[Lookup[ingredientResult, "Failed", False]],
      Message[BuildRRatio::ingredientFailure, "SMQCD",
        Lookup[ingredientResult, "FailedIngredient", "Unknown"]];
      diagnostics =
        Join[ingredientResult, <|"Model" -> "SMQCD",
          "quarkMass" -> masslessQuarkMass|>];
      collectedSteps = CollectRRatioIntermediateSteps[ingredientCalls, <||>,
        Missing["NotAvailable"], $Failed, diagnostics, intermediateSteps];
      If[TrueQ[OptionValue[PrintIntermediateSteps]] && Length[
          collectedSteps] > 0,
        PrintIntermediateStepsAssociation[collectedSteps]
      ];
      Return[
        RRatioFailureResult[$Failed, diagnostics, collectedSteps,
          OptionValue[ReturnDiagnostics]]
      ]
    ];
    ingredients = ingredientResult["Ingredients"];
    ingredientDiagnostics = ingredientResult["IngredientDiagnostics"];
    assemblyResult = AssembleSMQCDRRatio[ingredients];
    assemblyExpression = assemblyResult["AssemblyExpression"];
    finalExpression = assemblyResult["FinalExpression"];
    diagnostics = <|
      "Model" -> "SMQCD",
      "quarkMass" -> masslessQuarkMass,
      "AssemblySource" -> "ThesisNotebookFormula",
      "Ingredients" -> ingredients,
      "IngredientDiagnostics" -> ingredientDiagnostics,
      "TFactors" -> assemblyResult["TFactors"],
      "Ratios" -> assemblyResult["Ratios"],
      "AssemblyExpression" -> assemblyExpression
    |>;
    collectedSteps = CollectRRatioIntermediateSteps[ingredientCalls,
      ingredients, assemblyExpression, finalExpression, diagnostics,
      intermediateSteps];
    diagnostics =
      If[Length[collectedSteps] > 0,
        Join[diagnostics, <|"IntermediateSteps" -> collectedSteps|>],
        diagnostics
      ];
    FormatFreshRRatioReturn[finalExpression, diagnostics,
      OptionValue["ReturnDiagnostics"], intermediateSteps, OptionValue[
        "PrintIntermediateSteps"]]
  ];

BuildRRatio[SUSY, OptionsPattern[]] :=
  Module[{intermediateSteps},
    intermediateSteps = NormalizeIntermediateSteps[OptionValue[
      IntermediateSteps]];
    RRatioModelShellFailure[SUSY, OptionValue[ReturnDiagnostics],
      intermediateSteps]
  ];

BuildRRatio[HiggsEFT, OptionsPattern[]] :=
  Module[{intermediateSteps},
    intermediateSteps = NormalizeIntermediateSteps[OptionValue[
      IntermediateSteps]];
    RRatioModelShellFailure[HiggsEFT, OptionValue[ReturnDiagnostics],
      intermediateSteps]
  ];

BuildRRatio[model_, OptionsPattern[]] :=
  Module[{modelName, intermediateSteps, diagnostics, collectedSteps},
    modelName = ToString[Unevaluated[model], InputForm];
    intermediateSteps = NormalizeIntermediateSteps[OptionValue[
      IntermediateSteps]];
    Message[BuildRRatio::unsupportedModel, modelName];
    diagnostics = <|"Failed" -> True, "Reason" -> "UnsupportedRRatioModel",
      "Model" -> modelName|>;
    collectedSteps = CollectRRatioIntermediateSteps[<||>, <||>,
      Missing["NotAvailable"], $Failed, diagnostics, intermediateSteps];
    RRatioFailureResult[$Failed, diagnostics, collectedSteps,
      OptionValue[ReturnDiagnostics]]
  ];
