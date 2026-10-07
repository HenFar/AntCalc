(*************************************************)

(*
  Public R-ratio driver.
  Communicates with:
    - src/interface/integration_router.wl, which supplies the validated
      integrated antenna ingredients.
    - src/interface/build_router.wl for shared intermediate-step formatting.
    - src/core/result_cache.wl for top-level and nested ingredient reuse.

  Why this file exists:
    The package ultimately serves observable construction, not just isolated
    antenna functions.  This file shows how the integrated building blocks are
    combined into a physics-facing symbolic driver while preserving provenance.

  This layer assembles the validated integrated antenna ingredients into the
  symbolic NNLO R-ratio combination used in the thesis notebook package.
*)

(*************************************************)

BuildRRatio::usage =
  "BuildRRatio[model, ...] builds the public symbolic R-ratio driver output for the selected model shell.";

TObject::usage =
  "TObject[order, finalParticles, ...] returns the symbolic paper-level T object for the selected perturbative order and final state, expressed in terms of integrated antennae.";

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

TObjectStoredResultKey::usage =
  "TObjectStoredResultKey[order, finalState, options] builds the cache key for a TObject request.";

TObjectStoredResultLabel::usage =
  "TObjectStoredResultLabel[order, finalState, options] builds the human-readable cache label for a TObject request.";

NormalizeTObjectFinalState::usage =
  "NormalizeTObjectFinalState[finalState] normalizes the public TObject final-state selector.";

TObjectIngredientOrders::usage =
  "TObjectIngredientOrders[order] returns the ingredient expansion orders needed to build one public TObject expression.";

NormalizePublicTObjectExpression::usage =
  "NormalizePublicTObjectExpression[expr] rewrites internal colour symbols into the public TObject output convention.";

BuildRRatioSMQCDIngredients::usage =
  "BuildRRatioSMQCDIngredients[masslessQuarkMass, options] collects the validated integrated antenna ingredients used by the massless SMQCD driver.";

TObjectRequiredIngredientNames::usage =
  "TObjectRequiredIngredientNames[order, finalState] returns the minimal integrated-antenna ingredients needed by one TObject request.";

BuildSMQCDTObjectIngredients::usage =
  "BuildSMQCDTObjectIngredients[masslessQuarkMass, order, finalState, options] evaluates only the integrated ingredients needed by one public TObject expression.";

AssembleSMQCDTObject::usage =
  "AssembleSMQCDTObject[ingredients, order, finalState] assembles one symbolic massless-SMQCD T object from the validated integrated antenna ingredients.";

AssembleSMQCDRRatio::usage =
  "AssembleSMQCDRRatio[ingredients] assembles the final symbolic massless SMQCD R-ratio expression from the validated antenna ingredients.";

SMQCDRRatioObservableConventionLedger::usage =
  "SMQCDRRatioObservableConventionLedger[] returns the explicit package-to-observable convention map used by the SMQCD R-ratio assembler.";

ApplySMQCDRRatioObservableConvention::usage =
  "ApplySMQCDRRatioObservableConvention[ingredients] maps public integrated ingredients into the convention required by the NNLO SMQCD R-ratio channel sum.";

NormalizeBuildRRatioResultForm::usage =
  "NormalizeBuildRRatioResultForm[resultForm] normalizes the public BuildRRatio result-form selector.";

BuildRRatioSMQCDReferenceFiniteExpression::usage =
  "BuildRRatioSMQCDReferenceFiniteExpression[maxOrder] returns the encoded massless-SMQCD finite reference target through the requested perturbative order. It is a comparison target, not an antenna-derived result.";

NormalizeBuildRRatioMaxOrder::usage =
  "NormalizeBuildRRatioMaxOrder[maxOrder] normalizes the public BuildRRatio perturbative-order selector.";

Options[BuildRRatio] = {quarkMass -> 0, ReturnDiagnostics -> False,
   IntermediateSteps -> {}, PrintIntermediateSteps -> False,
   UseStoredResults -> False, StoreResults -> False,
   ResultsCacheRoot -> Automatic, RefreshStoredResults -> False,
   ResultForm -> "ComputedFiniteCoefficient", maxOrder -> NNLO};

Options[TObject] = {quarkMass -> 0, ExpansionOrder -> Automatic,
   ReturnDiagnostics -> False, UseStoredResults -> False,
   StoreResults -> False, ResultsCacheRoot -> Automatic,
   RefreshStoredResults -> False};

BuildRRatio::unsupportedModel =
  "Unsupported R-ratio model `1`. Supported model shells are SMQCD, SUSY, and HiggsEFT.";

BuildRRatio::masslessOnly =
  "BuildRRatio[`1`] currently supports only quarkMass -> 0.";

BuildRRatio::ingredientFailure =
  "BuildRRatio[`1`] could not build the required ingredient `2` through the public antenna routes.";

BuildRRatio::unsupportedResultForm =
  "Unsupported ResultForm `1`. Supported forms are \"RawDimRegSeries\", \"ComputedFiniteCoefficient\", and \"ReferenceFiniteMSBar\".";

BuildRRatio::unsupportedMaxOrder =
  "Unsupported maxOrder `1`. Supported perturbative orders are LO, NLO, and NNLO (or the corresponding uppercase strings).";

TObject::masslessOnly =
  "TObject currently supports only quarkMass -> 0.";

TObject::unsupportedOrder =
  "Unsupported TObject order `1`. Supported perturbative orders are 2, 4, and 6.";

TObject::unsupportedFinalState =
  "Unsupported TObject final state `1`. Supported final states are qqbar, qqbarg, qqbarqprimeqprimebar, qqbarqqbar, and qqbargg.";

TObject::ingredientFailure =
  "TObject[`1`, `2`] could not build the required ingredient `3` through the public antenna routes.";

NormalizeBuildRRatioResultForm[resultForm_] :=
  Module[{normalized},
    normalized = ToString[resultForm, InputForm];
    Switch[normalized,
      "\"RawDimRegSeries\"" | "RawDimRegSeries",
        "RawDimRegSeries"
      ,
      "\"ComputedFiniteCoefficient\"" | "ComputedFiniteCoefficient",
        "ComputedFiniteCoefficient"
      ,
      "\"ReferenceFiniteMSBar\"" | "ReferenceFiniteMSBar",
        "ReferenceFiniteMSBar"
      ,
      _,
        $Failed
    ]
  ];

NormalizeBuildRRatioMaxOrder[maxOrder_] :=
  Module[{normalized},
    normalized = ToString[Unevaluated[maxOrder], InputForm];
    Switch[normalized,
      "LO" | "\"LO\"", LO,
      "NLO" | "\"NLO\"", NLO,
      "NNLO" | "\"NNLO\"", NNLO,
      _, $Failed
    ]
  ];

NormalizeTObjectParticleToken[token_] :=
  Module[{normalized},
    normalized =
      ToLowerCase[
        StringReplace[
          ToString[Unevaluated[token], InputForm],
          {" " -> "", "\"" -> "", "-" -> "", "_" -> ""}
        ]
      ];
    Switch[normalized,
      "q" | "quark",
        "q"
      ,
      "qbar" | "antiquark",
        "qbar"
      ,
      "g" | "gluon",
        "g"
      ,
      "qprime" | "qp" | "quarkprime",
        "qprime"
      ,
      "qprimebar" | "qpbar" | "antiquarkprime",
        "qprimebar"
      ,
      _,
        normalized
    ]
  ];

NormalizeTObjectFinalState[finalState_List] :=
  NormalizeTObjectFinalState[
    StringRiffle[NormalizeTObjectParticleToken /@ finalState, ","]
  ];

NormalizeTObjectFinalState[finalState_String] :=
  Module[{normalized},
    normalized =
      ToLowerCase[
        StringReplace[finalState, {" " -> "", "\"" -> "", "-" -> "",
          "_" -> ""}]
      ];
    Switch[normalized,
      "qqbar" | "q,qbar",
        "qqbar"
      ,
      "qqbarg" | "q,qbar,g",
        "qqbarg"
      ,
      "qqbarqprimeqprimebar" | "qqbarqqprimebar" | "q,qbar,qprime,qprimebar",
        "qqbarqprimeqprimebar"
      ,
      "qqbarqqbar" | "q,qbar,q,qbar",
        "qqbarqqbar"
      ,
      "qqbargg" | "q,qbar,g,g",
        "qqbargg"
      ,
      _,
        normalized
    ]
  ];

NormalizeTObjectFinalState[finalState_] :=
  NormalizeTObjectFinalState[ToString[Unevaluated[finalState], InputForm]];

TObjectStoredResultKey[order_Integer, finalState_, options_Association] :=
  StoredResultKeyAssociation[
    "TObject",
    <|
      "ImplementationVersion" -> 3,
      "Order" -> order,
      "FinalState" -> NormalizeTObjectFinalState[finalState],
      "quarkMass" -> Lookup[options, "quarkMass", 0],
      "ExpansionOrder" -> Lookup[options, "ExpansionOrder", Automatic],
      "NestedBuildAndIntegrateDefaults" ->
        BuildRRatioNestedBuildAndIntegrateDefaults[]
    |>
  ];

TObjectStoredResultLabel[order_Integer, finalState_, options_Association] :=
  StringJoin[
    "TObject-",
    ToString[order], "-",
    NormalizeTObjectFinalState[finalState], "-",
    StringReplace[ToString[Lookup[options, "quarkMass", 0], InputForm],
      {" " -> "", "." -> "-", "/" -> "-"}], "-",
    ToLowerCase[ToString[Lookup[options, "ExpansionOrder", Automatic], InputForm]]
  ];

TObjectIngredientOrders[order_Integer] :=
  Module[{dependencyOrder},
    dependencyOrder = order + 1;
    <|
      "intA21" -> dependencyOrder,
      "intA30" -> dependencyOrder,
      "A31Components" -> order,
      "A22Components" -> order,
      "intA40" -> order,
      "intTildeA40" -> order,
      "intB40" -> order,
      "intC40" -> order
    |>
  ];

TObjectIngredientOrders[_] :=
  <|
    "intA21" -> Automatic,
    "intA30" -> Automatic,
    "A31Components" -> Automatic,
    "A22Components" -> Automatic,
    "intA40" -> Automatic,
    "intTildeA40" -> Automatic,
    "intB40" -> Automatic,
    "intC40" -> Automatic
  |>;

FinalizeTObjectExpression[expr_, order_] :=
  If[IntegerQ[order],
    IntegratedAntennaSeries[expr, order],
    expr
  ];

NormalizePublicTObjectExpression[expr_] :=
  expr /. SUNN -> System`N;

BuildRRatioSMQCDReferenceFiniteExpression[maxOrder_:NNLO] :=
  Module[{alphaS, n, nf},
    alphaS = SMP["alpha_s"];
    n = SUNN;
    nf = Nf;
    Switch[maxOrder,
      LO, 1,
      NLO, 1 + alphaS / (2 Pi) ((n^2 - 1) / (2 n)) (3 / 2),
      NNLO,
        1 +
          alphaS / (2 Pi) ((n^2 - 1) / (2 n)) (3 / 2) +
          (alphaS / (2 Pi))^2 ((n^2 - 1) / (2 n)) (
            n (243 / 16 - 11 Zeta[3]) +
            3 / (16 n) +
            nf (-11 / 4 + 2 Zeta[3])
          ),
      _, $Failed
    ]
  ];

(* The public component conventions are intentionally preserved for direct
   literature comparison.  The inclusive observable uses the corresponding
   channel conventions from hep-ph/0403057, including the self-interference
   single-pole term required by the closed NNLO channel sum. *)
SMQCDRRatioObservableConventionLedger[] :=
  <|
    "Source" -> "hep-ph/0403057",
    "ConventionStatus" -> "ClosureNormalizedObservableAdapter",
    "A22PublicContract" -> "DirectPaperTqq6Components",
    "A22OneLoopSelfPoleShift" -> -7 Zeta[3]/(3 FeynCalc`Epsilon),
    "A40LeadingMultiplier" -> 1,
    "A40SubleadingMultiplier" -> 1/2,
    "B40Multiplier" -> 1,
    "C40Multiplier" -> 2,
    "Note" -> "The adapter is applied only to the observable assembly. The public A40 subleading entry is tilde A4^0 itself; its minus sign is supplied by the colour coefficient in the qqbargg assembly. The self-interference shift is the closure-normalized convention required by the complete NNLO channel sum."
  |>;

ApplySMQCDRRatioObservableConvention[ingredients_Association] :=
  Module[{ledger, observableIngredients},
    ledger = SMQCDRRatioObservableConventionLedger[];
    observableIngredients = Association[ingredients];
    observableIngredients["intBreveA22"] =
      ingredients["intBreveA22"] + ledger["A22OneLoopSelfPoleShift"];
    observableIngredients["intA40"] =
      ledger["A40LeadingMultiplier"] ingredients["intA40"];
    observableIngredients["intTildeA40"] =
      ledger["A40SubleadingMultiplier"] ingredients["intTildeA40"];
    observableIngredients["intB40"] =
      ledger["B40Multiplier"] ingredients["intB40"];
    observableIngredients["intC40"] =
      ledger["C40Multiplier"] ingredients["intC40"];
    <|"Ingredients" -> observableIngredients, "Ledger" -> ledger|>
  ];

(* CollectRRatioIntermediateSteps[...]
   ===================================
   Collect the driver-side stages explicitly requested by the caller. *)
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

(* RRatioFailureResult[result, diagnostics, intermediateSteps, returnDiagnostics]
   ==============================================================================
   Format a failing driver evaluation in the same public return style used for
   successful runs. *)
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

(* FormatFreshRRatioReturn[result, diagnostics, ...]
   ================================================
   Convert a fresh driver evaluation into the requested public return shape. *)
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

(* BuildRRatioIngredientCallAssociation[masslessQuarkMass]
   =======================================================
   Declare the public antenna calls that furnish the massless SMQCD R-ratio
   ingredients. *)
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

(* BuildRRatioIngredientCacheOptions[options]
   ==========================================
   Translate top-level cache preferences into the nested ingredient-call cache
   policy. *)
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

BuildRRatioNestedBuildAndIntegrateDefaults[] :=
  Module[{routeDefaults},
    routeDefaults =
      NormalizeStoredResultOptionAssociation[
        Association[Options[BuildAndIntegrateAntenna]]
      ];
    <|
      "ApplyFeynCalcMS" -> Lookup[routeDefaults, "ApplyFeynCalcMS", True],
      "KinematicScale" -> Lookup[routeDefaults, "KinematicScale", q2],
      "NormalizeKinematicScale" -> Lookup[routeDefaults,
        "NormalizeKinematicScale", True],
      "ApplyDimReg" -> Lookup[routeDefaults, "ApplyDimReg", True],
      "ReductionBackend" -> Lookup[routeDefaults, "ReductionBackend",
        Automatic],
      "LoopMomentum" -> Lookup[routeDefaults, "LoopMomentum", l],
      "BasisFamily" -> Lookup[routeDefaults, "BasisFamily", Automatic],
      "BasisRoot" -> Lookup[routeDefaults, "BasisRoot", Automatic],
      "GenerateMissingBases" -> Lookup[routeDefaults,
        "GenerateMissingBases", False]
    |>
  ];

BuildRRatioStoredResultKey[model_Symbol, options_Association] :=
  StoredResultKeyAssociation[
    "BuildRRatio",
    <|
      "ImplementationVersion" -> 7,
      "Model" -> SymbolName[Unevaluated[model]],
      "quarkMass" -> Lookup[options, "quarkMass", 0],
      "NestedBuildAndIntegrateDefaults" ->
        BuildRRatioNestedBuildAndIntegrateDefaults[],
      "ResultForm" -> NormalizeBuildRRatioResultForm[
        Lookup[options, "ResultForm", "ComputedFiniteCoefficient"]],
      "maxOrder" -> NormalizeBuildRRatioMaxOrder[
        Lookup[options, "maxOrder", NNLO]]
    |>
  ];

BuildRRatioStoredResultLabel[model_Symbol, options_Association] :=
  StringJoin[
    "BuildRRatio-",
    ToLowerCase[SymbolName[Unevaluated[model]]], "-",
    StringReplace[ToString[Lookup[options, "quarkMass", 0], InputForm],
      {" " -> "", "." -> "-", "/" -> "-"}], "-",
    ToLowerCase @ NormalizeBuildRRatioResultForm[
      Lookup[options, "ResultForm", "ComputedFiniteCoefficient"]], "-",
    ToLowerCase @ ToString[
      NormalizeBuildRRatioMaxOrder[Lookup[options, "maxOrder", NNLO]],
      InputForm]
  ];

(* BuildRRatioSMQCDIngredients[masslessQuarkMass, options]
   =======================================================
   Evaluate and validate the integrated antenna ingredients needed by the
   massless SMQCD driver. *)
BuildRRatioSMQCDIngredients[masslessQuarkMass_, options_Association:<||>] :=
  Module[{cacheOptions, ingredientOrders, a21Result, a30Result, a31Result,
     a22Result, a40LeadResult, a40SubResult, b40Result, c40Result,
     ingredients, ingredientDiagnostics, requestedMaxOrder, virtualResult,
     realResult},
    cacheOptions = BuildRRatioIngredientCacheOptions[options];
    requestedMaxOrder = Lookup[options, "maxOrder", NNLO];
    (* LO needs no integrated antenna.  At NLO, deliberately request only the
       two antennae that enter rNLO.  NNLO retains the established named
       ingredient path below, where the higher epsilon depth of A30 is needed
       by the one-loop/tree product. *)
    If[requestedMaxOrder === LO,
      Return[<|"Failed" -> False, "Ingredients" -> <||>,
        "IngredientDiagnostics" -> <||>|>]
    ];
    If[requestedMaxOrder === NLO,
      virtualResult = BuildSMQCDTObjectIngredients[masslessQuarkMass, 4,
        "qqbar", options];
      If[TrueQ[Lookup[virtualResult, "Failed", False]], Return[virtualResult]];
      realResult = BuildSMQCDTObjectIngredients[masslessQuarkMass, 4,
        "qqbarg", options];
      If[TrueQ[Lookup[realResult, "Failed", False]], Return[realResult]];
      Return[<|"Failed" -> False,
        "Ingredients" -> Join[virtualResult["Ingredients"],
          realResult["Ingredients"]],
        "IngredientDiagnostics" -> Join[virtualResult["IngredientDiagnostics"],
          realResult["IngredientDiagnostics"]]|>]
    ];
    ingredientOrders =
      If[KeyExistsQ[options, "ExpansionOrder"],
        TObjectIngredientOrders[Lookup[options, "ExpansionOrder", Automatic]]
        ,
        <|
          "intA21" -> Automatic,
          "intA30" -> 2,
          "A31Components" -> 0,
          "A22Components" -> 0,
          "intA40" -> 0,
          "intTildeA40" -> 0,
          "intB40" -> 0,
          "intC40" -> 0
        |>
      ];
    a21Result =
      EvaluateRRatioStoredIngredient["intA21",
        BuildAndIntegrateAntenna[A, 2, 1, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True,
          ExpansionOrder -> ingredientOrders["intA21"],
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a30Result =
      EvaluateRRatioStoredIngredient["intA30",
        BuildAndIntegrateAntenna[A, 3, 0, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True,
          ExpansionOrder -> ingredientOrders["intA30"],
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a31Result =
      EvaluateRRatioStoredIngredient["A31 components",
        BuildAndIntegrateAntenna[A, 3, 1, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True,
          ExpansionOrder -> ingredientOrders["A31Components"],
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a22Result =
      EvaluateRRatioStoredIngredient["A22 components",
        BuildAndIntegrateAntenna[A, 2, 2, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True,
          ExpansionOrder -> ingredientOrders["A22Components"],
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a40LeadResult =
      EvaluateRRatioStoredIngredient["intA40",
        BuildAndIntegrateAntenna[A, 4, 0, Component -> Leading,
          quarkMass -> masslessQuarkMass, ReturnDiagnostics -> True,
          ExpansionOrder -> ingredientOrders["intA40"],
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    a40SubResult =
      EvaluateRRatioStoredIngredient["intTildeA40",
        BuildAndIntegrateAntenna[A, 4, 0, Component -> Subleading,
          quarkMass -> masslessQuarkMass, ReturnDiagnostics -> True,
          ExpansionOrder -> ingredientOrders["intTildeA40"],
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    b40Result =
      EvaluateRRatioStoredIngredient["intB40",
        BuildAndIntegrateAntenna[B, 4, 0, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True,
          ExpansionOrder -> ingredientOrders["intB40"],
          UseStoredResults -> cacheOptions["UseStoredResults"],
          StoreResults -> cacheOptions["StoreResults"],
          RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
          ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
      ];
    c40Result =
      EvaluateRRatioStoredIngredient["intC40",
        BuildAndIntegrateAntenna[C, 4, 0, quarkMass -> masslessQuarkMass,
          ReturnDiagnostics -> True,
          ExpansionOrder -> ingredientOrders["intC40"],
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

TObjectRequiredIngredientNames[2, "qqbar"] := {};

TObjectRequiredIngredientNames[4, "qqbar"] := {"intA21"};

TObjectRequiredIngredientNames[4, "qqbarg"] := {"intA30"};

TObjectRequiredIngredientNames[6, "qqbar"] := {"A22Components"};

TObjectRequiredIngredientNames[6, "qqbarg"] :=
  {"intA21", "intA30", "A31Components"};

TObjectRequiredIngredientNames[6, "qqbarqprimeqprimebar"] := {"intB40"};

TObjectRequiredIngredientNames[6, "qqbarqqbar"] := {"intB40", "intC40"};

TObjectRequiredIngredientNames[6, "qqbargg"] := {"intA40", "intTildeA40"};

TObjectRequiredIngredientNames[_, _] := $Failed;

BuildSMQCDTObjectIngredients[masslessQuarkMass_, order_Integer,
   finalState_, options_Association:<||>] :=
  Module[{cacheOptions, ingredientOrders, required, rawResults, fetchResult,
     result, ingredients, ingredientDiagnostics},
    cacheOptions = BuildRRatioIngredientCacheOptions[options];
    ingredientOrders =
      TObjectIngredientOrders[Lookup[options, "ExpansionOrder", Automatic]];
    required = TObjectRequiredIngredientNames[order, finalState];
    If[required === $Failed,
      Return[<|"Failed" -> True,
        "Reason" -> "UnsupportedTObjectIngredientRequest"|>]
    ];
    rawResults = <||>;
    fetchResult[name_String] :=
      Switch[name,
        "intA21",
          EvaluateRRatioStoredIngredient["intA21",
            BuildAndIntegrateAntenna[A, 2, 1, quarkMass -> masslessQuarkMass,
              ReturnDiagnostics -> True,
              ExpansionOrder -> ingredientOrders["intA21"],
              UseStoredResults -> cacheOptions["UseStoredResults"],
              StoreResults -> cacheOptions["StoreResults"],
              RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
              ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
          ]
        ,
        "intA30",
          EvaluateRRatioStoredIngredient["intA30",
            BuildAndIntegrateAntenna[A, 3, 0, quarkMass -> masslessQuarkMass,
              ReturnDiagnostics -> True,
              ExpansionOrder -> ingredientOrders["intA30"],
              UseStoredResults -> cacheOptions["UseStoredResults"],
              StoreResults -> cacheOptions["StoreResults"],
              RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
              ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
          ]
        ,
        "A31Components",
          EvaluateRRatioStoredIngredient["A31 components",
            BuildAndIntegrateAntenna[A, 3, 1, quarkMass -> masslessQuarkMass,
              ReturnDiagnostics -> True,
              ExpansionOrder -> ingredientOrders["A31Components"],
              UseStoredResults -> cacheOptions["UseStoredResults"],
              StoreResults -> cacheOptions["StoreResults"],
              RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
              ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
          ]
        ,
        "A22Components",
          EvaluateRRatioStoredIngredient["A22 components",
            BuildAndIntegrateAntenna[A, 2, 2, quarkMass -> masslessQuarkMass,
              ReturnDiagnostics -> True,
              ExpansionOrder -> ingredientOrders["A22Components"],
              UseStoredResults -> cacheOptions["UseStoredResults"],
              StoreResults -> cacheOptions["StoreResults"],
              RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
              ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
          ]
        ,
        "intA40",
          EvaluateRRatioStoredIngredient["intA40",
            BuildAndIntegrateAntenna[A, 4, 0, Component -> Leading,
              quarkMass -> masslessQuarkMass, ReturnDiagnostics -> True,
              ExpansionOrder -> ingredientOrders["intA40"],
              UseStoredResults -> cacheOptions["UseStoredResults"],
              StoreResults -> cacheOptions["StoreResults"],
              RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
              ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
          ]
        ,
        "intTildeA40",
          EvaluateRRatioStoredIngredient["intTildeA40",
            BuildAndIntegrateAntenna[A, 4, 0, Component -> Subleading,
              quarkMass -> masslessQuarkMass, ReturnDiagnostics -> True,
              ExpansionOrder -> ingredientOrders["intTildeA40"],
              UseStoredResults -> cacheOptions["UseStoredResults"],
              StoreResults -> cacheOptions["StoreResults"],
              RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
              ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
          ]
        ,
        "intB40",
          EvaluateRRatioStoredIngredient["intB40",
            BuildAndIntegrateAntenna[B, 4, 0, quarkMass -> masslessQuarkMass,
              ReturnDiagnostics -> True,
              ExpansionOrder -> ingredientOrders["intB40"],
              UseStoredResults -> cacheOptions["UseStoredResults"],
              StoreResults -> cacheOptions["StoreResults"],
              RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
              ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
          ]
        ,
        "intC40",
          EvaluateRRatioStoredIngredient["intC40",
            BuildAndIntegrateAntenna[C, 4, 0, quarkMass -> masslessQuarkMass,
              ReturnDiagnostics -> True,
              ExpansionOrder -> ingredientOrders["intC40"],
              UseStoredResults -> cacheOptions["UseStoredResults"],
              StoreResults -> cacheOptions["StoreResults"],
              RefreshStoredResults -> cacheOptions["RefreshStoredResults"],
              ResultsCacheRoot -> cacheOptions["ResultsCacheRoot"]]
          ]
        ,
        _,
          $Failed
      ];
    Do[
      result = fetchResult[name];
      If[RRatioIngredientCallFailedQ[result],
        Return[<|"Failed" -> True, "Reason" -> "IngredientRouteFailed",
          "FailedIngredient" -> name|>]
      ];
      If[!MatchQ[result, {_, _Association}],
        Return[<|"Failed" -> True, "Reason" -> "UnexpectedIngredientReturnShape",
          "FailedIngredient" -> name|>]
      ];
      rawResults[name] = result;
      ,
      {name, required}
    ];
    ingredients = <||>;
    ingredientDiagnostics = <||>;
    If[KeyExistsQ[rawResults, "intA21"],
      ingredients["intA21"] = rawResults["intA21"][[1]];
      ingredientDiagnostics["intA21"] = rawResults["intA21"][[2]];
    ];
    If[KeyExistsQ[rawResults, "intA30"],
      ingredients["intA30"] = rawResults["intA30"][[1]];
      ingredientDiagnostics["intA30"] = rawResults["intA30"][[2]];
    ];
    If[KeyExistsQ[rawResults, "A31Components"],
      ingredients["intA31"] = rawResults["A31Components"][[1, 1]];
      ingredients["intTildeA31"] = rawResults["A31Components"][[1, 2]];
      ingredients["intHatA31"] = rawResults["A31Components"][[1, 3]];
      ingredientDiagnostics["A31Components"] = rawResults["A31Components"][[2]];
    ];
    If[KeyExistsQ[rawResults, "A22Components"],
      ingredients["intA22"] = rawResults["A22Components"][[1, 1]];
      ingredients["intTildeA22"] = rawResults["A22Components"][[1, 2]];
      ingredients["intHatA22"] = rawResults["A22Components"][[1, 3]];
      ingredients["intBreveA22"] = rawResults["A22Components"][[1, 4]];
      ingredientDiagnostics["A22Components"] = rawResults["A22Components"][[2]];
    ];
    If[KeyExistsQ[rawResults, "intA40"],
      ingredients["intA40"] = rawResults["intA40"][[1]];
      ingredientDiagnostics["intA40"] = rawResults["intA40"][[2]];
    ];
    If[KeyExistsQ[rawResults, "intTildeA40"],
      ingredients["intTildeA40"] = rawResults["intTildeA40"][[1]];
      ingredientDiagnostics["intTildeA40"] = rawResults["intTildeA40"][[2]];
    ];
    If[KeyExistsQ[rawResults, "intB40"],
      ingredients["intB40"] = rawResults["intB40"][[1]];
      ingredientDiagnostics["intB40"] = rawResults["intB40"][[2]];
    ];
    If[KeyExistsQ[rawResults, "intC40"],
      ingredients["intC40"] = rawResults["intC40"][[1]];
      ingredientDiagnostics["intC40"] = rawResults["intC40"][[2]];
    ];
    <|"Failed" -> False, "Ingredients" -> ingredients,
      "IngredientDiagnostics" -> ingredientDiagnostics|>
  ];

AssembleSMQCDTObject[ingredients_Association, perturbativeOrder_Integer,
   finalState_, expansionOrder_] :=
  Module[{eps, n, nf, normalizedFinalState, tqq2, tObjects},
    eps = FeynCalc`Epsilon;
    n = SUNN;
    nf = Nf;
    normalizedFinalState = NormalizeTObjectFinalState[finalState];
    tqq2 = 4 n (1 - eps);
    tObjects = <|
      "qqbar" -> FinalizeTObjectExpression[tqq2, expansionOrder],
      "qqbar4" -> FinalizeTObjectExpression[
        (n - 1 / n) tqq2 ingredients["intA21"],
        expansionOrder
      ],
      "qqbarg" -> FinalizeTObjectExpression[
        (n - 1 / n) tqq2 ingredients["intA30"],
        expansionOrder
      ],
      "qqbar6" -> FinalizeTObjectExpression[
        (n - 1 / n) tqq2 (
          n ingredients["intA22"] +
          1 / n ingredients["intTildeA22"] +
          nf ingredients["intHatA22"] +
          (n - 1 / n) ingredients["intBreveA22"]
        ),
        expansionOrder
      ],
      "qqbarg6" -> FinalizeTObjectExpression[
        (n - 1 / n) tqq2 (
          n (ingredients["intA31"] +
            ingredients["intA21"] ingredients["intA30"]) -
          1 / n (ingredients["intTildeA31"] +
            ingredients["intA21"] ingredients["intA30"]) +
          nf ingredients["intHatA31"]
        ),
        expansionOrder
      ],
      "qqbarqprimeqprimebar" -> FinalizeTObjectExpression[
        (n - 1 / n) tqq2 (nf - 1) ingredients["intB40"],
        expansionOrder
      ],
      "qqbarqqbar" -> FinalizeTObjectExpression[
        (n - 1 / n) tqq2 (ingredients["intB40"] -
          1 / n ingredients["intC40"]),
        expansionOrder
      ],
      "qqbargg" -> FinalizeTObjectExpression[
        (n - 1 / n) tqq2 (
          n ingredients["intA40"] -
          1 / n ingredients["intTildeA40"]
        ),
        expansionOrder
      ]
    |>;
    Switch[perturbativeOrder,
      2,
        If[normalizedFinalState === "qqbar",
          <|"Expression" -> tObjects["qqbar"],
            "TObjects" -> <|"Tqq2" -> tObjects["qqbar"]|>|>,
          $Failed
        ]
      ,
      4,
        Switch[normalizedFinalState,
          "qqbar",
            <|"Expression" -> tObjects["qqbar4"],
              "TObjects" -> <|"Tqq4" -> tObjects["qqbar4"]|>|>
          ,
          "qqbarg",
            <|"Expression" -> tObjects["qqbarg"],
              "TObjects" -> <|"Tqqg4" -> tObjects["qqbarg"]|>|>
          ,
          _,
            $Failed
        ]
      ,
      6,
        Switch[normalizedFinalState,
          "qqbar",
            <|"Expression" -> tObjects["qqbar6"],
              "TObjects" -> <|"Tqq6" -> tObjects["qqbar6"]|>|>
          ,
          "qqbarg",
            <|"Expression" -> tObjects["qqbarg6"],
              "TObjects" -> <|"Tqqg6" -> tObjects["qqbarg6"]|>|>
          ,
          "qqbarqprimeqprimebar",
            <|"Expression" -> tObjects["qqbarqprimeqprimebar"],
              "TObjects" -> <|"Tqqqqprime6" ->
                  tObjects["qqbarqprimeqprimebar"]|>|>
          ,
          "qqbarqqbar",
            <|"Expression" -> tObjects["qqbarqqbar"],
              "TObjects" -> <|"Tqqqq6" -> tObjects["qqbarqqbar"]|>|>
          ,
          "qqbargg",
            <|"Expression" -> tObjects["qqbargg"],
              "TObjects" -> <|"Tqqgg6" -> tObjects["qqbargg"]|>|>
          ,
          _,
            $Failed
        ]
      ,
      _,
        $Failed
    ]
  ];

AssembleSMQCDRRatio[ingredients_Association, requestedMaxOrder_:NNLO] :=
  Module[{eps, alphaS, n, nf, Tqq2, Tqq4, Tqqg4, Tqq6, Tqqg6,
     Tqqqqprime6, Tqqqq6, Tqqgg6, cLO, cNLO, cNNLO, rLO, rNLO, rNNLO,
     assemblyExpression, finalExpression, convention, observableIngredients},
    eps = FeynCalc`Epsilon;
    alphaS = SMP["alpha_s"];
    n = SUNN;
    nf = Nf;
    convention =
      If[requestedMaxOrder === NNLO,
        ApplySMQCDRRatioObservableConvention[ingredients],
        <|"Ingredients" -> ingredients,
          "Ledger" -> <|"ConventionStatus" ->
            "NotNeededBelowNNLO"|>|>
      ];
    observableIngredients = convention["Ingredients"];
    Tqq2 = 4 n (1 - eps) q2;
    Tqq4 = If[requestedMaxOrder =!= LO,
      (n - 1 / n) Tqq2 observableIngredients["intA21"],
      Missing["NotIncluded"]];
    Tqqg4 = If[requestedMaxOrder =!= LO,
      (n - 1 / n) Tqq2 observableIngredients["intA30"],
      Missing["NotIncluded"]];
    Tqq6 = If[requestedMaxOrder === NNLO,
      (n - 1 / n) Tqq2 (n observableIngredients["intA22"] +
        1 / n observableIngredients["intTildeA22"] +
        nf observableIngredients["intHatA22"]) +
      Tqq2 (n - 1 / n)^2 observableIngredients["intBreveA22"],
      Missing["NotIncluded"]];
    Tqqg6 = If[requestedMaxOrder === NNLO,
      (n - 1 / n) Tqq2 (
        n (observableIngredients["intA31"] +
          observableIngredients["intA21"] observableIngredients["intA30"]) -
        1 / n (observableIngredients["intTildeA31"] +
          observableIngredients["intA21"] observableIngredients["intA30"]) +
        nf observableIngredients["intHatA31"]
      ), Missing["NotIncluded"]];
    Tqqqqprime6 = If[requestedMaxOrder === NNLO,
      (n - 1 / n) Tqq2 (nf - 1) observableIngredients["intB40"],
      Missing["NotIncluded"]];
    Tqqqq6 = If[requestedMaxOrder === NNLO,
      1 / (nf - 1) Tqqqqprime6 -
      Tqq2 (n - 1 / n) 1 / n observableIngredients["intC40"],
      Missing["NotIncluded"]];
    Tqqgg6 = If[requestedMaxOrder === NNLO,
      (n - 1 / n) Tqq2 (
        n observableIngredients["intA40"] -
        1 / n observableIngredients["intTildeA40"]
      ), Missing["NotIncluded"]];
    cLO = 1;
    rLO = 1;
    cNLO = alphaS / (2 Pi);
    rNLO = If[requestedMaxOrder =!= LO,
      FullSimplify[
        (n - 1 / n) (observableIngredients["intA21"] +
          observableIngredients["intA30"])
      ], Missing["NotIncluded"]];
    cNNLO = cNLO^2;
    rNNLO = If[requestedMaxOrder === NNLO,
      FullSimplify[
        (n - 1 / n) (
          n observableIngredients["intA22"] +
          1 / n observableIngredients["intTildeA22"] +
          nf observableIngredients["intHatA22"] +
          (n - 1 / n) observableIngredients["intBreveA22"] +
          n (observableIngredients["intA31"] +
            observableIngredients["intA21"] observableIngredients["intA30"]) -
          1 / n (observableIngredients["intTildeA31"] +
            observableIngredients["intA21"] observableIngredients["intA30"]) +
          nf observableIngredients["intHatA31"] +
          nf observableIngredients["intB40"] -
          1 / n observableIngredients["intC40"] +
          n observableIngredients["intA40"] -
          1 / n observableIngredients["intTildeA40"]
        )
      ], Missing["NotIncluded"]];
    assemblyExpression = Switch[requestedMaxOrder,
      LO, cLO rLO,
      NLO, cLO rLO + cNLO rNLO,
      NNLO, cLO rLO + cNLO rNLO + cNNLO rNNLO
    ];
    finalExpression =
      Collect[assemblyExpression, alphaS, FullSimplify];
    <|"AssemblyExpression" -> assemblyExpression,
      "FinalExpression" -> finalExpression,
      "ObservableIngredients" -> observableIngredients,
      "TFactors" -> <|"Tqq2" -> Tqq2, "Tqq4" -> Tqq4, "Tqqg4" -> Tqqg4,
        "Tqq6" -> Tqq6, "Tqqg6" -> Tqqg6,
        "Tqqqqprime6" -> Tqqqqprime6, "Tqqqq6" -> Tqqqq6,
        "Tqqgg6" -> Tqqgg6|>,
      "Ratios" -> <|"cLO" -> cLO, "rLO" -> rLO, "cNLO" -> cNLO,
        "rNLO" -> rNLO, "cNNLO" -> cNNLO, "rNNLO" -> rNNLO|>,
      "ObservableConvention" -> convention["Ledger"]|>
  ];

BuildRRatio[SMQCD, OptionsPattern[]] :=
  Module[{masslessQuarkMass, intermediateSteps, ingredientCalls,
     ingredientResult, ingredients, ingredientDiagnostics, assemblyResult,
     assemblyExpression, finalExpression, diagnostics, collectedSteps,
     useStored, storeStored, refreshStored, cacheKey, cacheLabel, cacheRoot,
     loaded, computed, computedResult, computedDiagnostics, optionsAssoc,
     rawFinalExpression, resultForm, requestedMaxOrder, referenceTarget,
     referenceResidual, referenceAgreementQ, includedIngredients,
     skippedIngredients, computedFiniteCoefficient},
    masslessQuarkMass = OptionValue[quarkMass];
    intermediateSteps = NormalizeIntermediateSteps[OptionValue[
      IntermediateSteps]];
    useStored = TrueQ[OptionValue["UseStoredResults"]];
    storeStored = TrueQ[OptionValue["StoreResults"]];
    refreshStored = TrueQ[OptionValue["RefreshStoredResults"]];
    resultForm =
      NormalizeBuildRRatioResultForm[OptionValue[ResultForm]];
    requestedMaxOrder = NormalizeBuildRRatioMaxOrder[OptionValue[maxOrder]];
    If[resultForm === $Failed,
      Message[BuildRRatio::unsupportedResultForm, OptionValue[ResultForm]];
      Return[$Failed]
    ];
    If[requestedMaxOrder === $Failed,
      Message[BuildRRatio::unsupportedMaxOrder, OptionValue[maxOrder]];
      Return[$Failed]
    ];
    optionsAssoc = <|
      "quarkMass" -> masslessQuarkMass,
      "UseStoredResults" -> useStored,
      "StoreResults" -> storeStored,
      "RefreshStoredResults" -> refreshStored,
      "ResultsCacheRoot" -> OptionValue["ResultsCacheRoot"],
      "ResultForm" -> resultForm,
      "maxOrder" -> requestedMaxOrder
    |>;
    ingredientCalls = BuildRRatioIngredientCallAssociation[masslessQuarkMass];
    includedIngredients = Switch[requestedMaxOrder,
      LO, {}, NLO, {"intA21", "intA30"}, NNLO, Keys[ingredientCalls]];
    skippedIngredients = Complement[Keys[ingredientCalls], includedIngredients];
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
    (* This is intentionally a direct, named reference lookup.  It must not
       be confused with an antenna-derived result or silently replace one. *)
    If[resultForm === "ReferenceFiniteMSBar",
      referenceTarget = BuildRRatioSMQCDReferenceFiniteExpression[
        requestedMaxOrder];
      diagnostics = <|
        "Model" -> "SMQCD", "quarkMass" -> masslessQuarkMass,
        "ResultForm" -> resultForm, "RequestedMaxOrder" -> requestedMaxOrder,
        "ResultOrigin" -> "EncodedReferenceTarget",
        "ReferenceTarget" -> referenceTarget,
        "ReferenceAgreementQ" -> Missing["NotComputedForReferenceTarget"],
        "ReferenceResidual" -> Missing["NotComputedForReferenceTarget"],
        "IncludedIngredients" -> {},
        "SkippedIngredients" -> Keys[ingredientCalls],
        "PresentedExpression" -> referenceTarget|>;
      collectedSteps = CollectRRatioIntermediateSteps[ingredientCalls, <||>,
        Missing["NotComputedForReferenceTarget"], referenceTarget,
        diagnostics, intermediateSteps];
      diagnostics = If[Length[collectedSteps] > 0,
        Join[diagnostics, <|"IntermediateSteps" -> collectedSteps|>],
        diagnostics];
      Return[FormatFreshRRatioReturn[referenceTarget, diagnostics,
        OptionValue[ReturnDiagnostics], intermediateSteps, OptionValue[
          PrintIntermediateSteps]]]
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
                "ReturnDiagnostics"], False, intermediateSteps, OptionValue[
                "PrintIntermediateSteps"], "BuildRRatio"]
          ]
        ]
      ];
      computed =
        Block[{$AntennaPipelineBypassStoredResults = True},
          BuildRRatio[SMQCD,
            quarkMass -> masslessQuarkMass,
            ReturnDiagnostics -> True,
            ResultForm -> OptionValue[ResultForm],
            maxOrder -> requestedMaxOrder,
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
    assemblyResult = AssembleSMQCDRRatio[ingredients, requestedMaxOrder];
    assemblyExpression = assemblyResult["AssemblyExpression"];
    rawFinalExpression = assemblyResult["FinalExpression"];
    computedFiniteCoefficient = RRatioFiniteCoefficient[rawFinalExpression];
    finalExpression =
      Switch[resultForm,
        "RawDimRegSeries",
          rawFinalExpression
        ,
        "ComputedFiniteCoefficient",
          computedFiniteCoefficient
      ];
    referenceTarget = BuildRRatioSMQCDReferenceFiniteExpression[
      requestedMaxOrder];
    referenceResidual = FullSimplify[
      computedFiniteCoefficient - referenceTarget];
    referenceAgreementQ = TrueQ[referenceResidual === 0];
    diagnostics = <|
      "Model" -> "SMQCD",
      "quarkMass" -> masslessQuarkMass,
      "ResultForm" -> resultForm,
      "RequestedMaxOrder" -> requestedMaxOrder,
      "ResultOrigin" -> If[resultForm === "RawDimRegSeries",
        "ComputedFromIntegratedIngredientsRawSeries",
        "ComputedFromIntegratedIngredients"],
      "ReferenceTarget" -> referenceTarget,
      "ReferenceAgreementQ" -> referenceAgreementQ,
      "ReferenceResidual" -> referenceResidual,
      "ComputedFiniteCoefficient" -> computedFiniteCoefficient,
      "IncludedIngredients" -> includedIngredients,
      "SkippedIngredients" -> skippedIngredients,
      "Ingredients" -> ingredients,
      "ObservableIngredients" -> assemblyResult["ObservableIngredients"],
      "IngredientDiagnostics" -> ingredientDiagnostics,
      "TFactors" -> assemblyResult["TFactors"],
      "Ratios" -> assemblyResult["Ratios"],
      "ObservableConvention" -> assemblyResult["ObservableConvention"],
      "AssemblyExpression" -> assemblyExpression,
      "RawFinalExpression" -> rawFinalExpression,
      "PresentedExpression" -> finalExpression
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

TObject[order_Integer, finalState_, OptionsPattern[]] :=
  Module[{masslessQuarkMass, expansionOrder, normalizedFinalState, useStored,
     storeStored, refreshStored, cacheKey, cacheLabel, cacheRoot, loaded,
     computed, computedResult, computedDiagnostics, optionsAssoc,
     ingredientResult, ingredients, ingredientDiagnostics, assembled,
     diagnostics},
    masslessQuarkMass = OptionValue[quarkMass];
    expansionOrder = OptionValue["ExpansionOrder"];
    normalizedFinalState = NormalizeTObjectFinalState[finalState];
    useStored = TrueQ[OptionValue["UseStoredResults"]];
    storeStored = TrueQ[OptionValue["StoreResults"]];
    refreshStored = TrueQ[OptionValue["RefreshStoredResults"]];
    optionsAssoc = <|
      "quarkMass" -> masslessQuarkMass,
      "ExpansionOrder" -> expansionOrder,
      "UseStoredResults" -> useStored,
      "StoreResults" -> storeStored,
      "RefreshStoredResults" -> refreshStored,
      "ResultsCacheRoot" -> OptionValue["ResultsCacheRoot"]
    |>;
    If[!MemberQ[{2, 4, 6}, order],
      Message[TObject::unsupportedOrder, order];
      diagnostics = <|"Failed" -> True, "Reason" -> "UnsupportedTObjectOrder",
        "Order" -> order, "FinalState" -> normalizedFinalState|>;
      Return[
        RRatioFailureResult[$Failed, diagnostics, <||>,
          OptionValue["ReturnDiagnostics"]]
      ]
    ];
    If[!MemberQ[{"qqbar", "qqbarg", "qqbarqprimeqprimebar", "qqbarqqbar",
         "qqbargg"}, normalizedFinalState],
      Message[TObject::unsupportedFinalState,
        ToString[Unevaluated[finalState], InputForm]];
      diagnostics = <|"Failed" -> True,
        "Reason" -> "UnsupportedTObjectFinalState", "Order" -> order,
        "FinalState" -> normalizedFinalState|>;
      Return[
        RRatioFailureResult[$Failed, diagnostics, <||>,
          OptionValue["ReturnDiagnostics"]]
      ]
    ];
    If[!MemberQ[{{2, "qqbar"}, {4, "qqbar"}, {4, "qqbarg"},
         {6, "qqbar"}, {6, "qqbarg"}, {6, "qqbarqprimeqprimebar"},
         {6, "qqbarqqbar"}, {6, "qqbargg"}}, {order, normalizedFinalState}],
      Message[TObject::unsupportedFinalState,
        ToString[Unevaluated[finalState], InputForm]];
      diagnostics = <|"Failed" -> True,
        "Reason" -> "UnsupportedTObjectOrderFinalStateCombination",
        "Order" -> order, "FinalState" -> normalizedFinalState|>;
      Return[
        RRatioFailureResult[$Failed, diagnostics, <||>,
          OptionValue["ReturnDiagnostics"]]
      ]
    ];
    If[masslessQuarkMass =!= 0,
      Message[TObject::masslessOnly];
      diagnostics = <|"Failed" -> True, "Reason" -> "NonzeroQuarkMassUnsupported",
        "Order" -> order, "FinalState" -> normalizedFinalState,
        "quarkMass" -> masslessQuarkMass|>;
      Return[
        RRatioFailureResult[$Failed, diagnostics, <||>,
          OptionValue["ReturnDiagnostics"]]
      ]
    ];
    If[!TrueQ[$AntennaPipelineBypassStoredResults] &&
        StoredResultsEnabledQ[useStored, storeStored, refreshStored],
      cacheKey = TObjectStoredResultKey[order, normalizedFinalState,
        optionsAssoc];
      cacheLabel = TObjectStoredResultLabel[order, normalizedFinalState,
        optionsAssoc];
      cacheRoot = OptionValue["ResultsCacheRoot"];
      If[!refreshStored && useStored,
        loaded = LoadStoredResultEntry["TObject", cacheKey, cacheRoot,
          cacheLabel];
        If[AssociationQ[loaded],
          PrintStoredResultHit[cacheLabel];
          Return[
            FormatStoredResultReturn[loaded["Result"],
              loaded["Diagnostics"], loaded, OptionValue[
                "ReturnDiagnostics"], False, {}, False, "TObject"]
          ]
        ]
      ];
      computed =
        Block[{$AntennaPipelineBypassStoredResults = True},
          TObject[order, normalizedFinalState,
            quarkMass -> masslessQuarkMass,
            ExpansionOrder -> expansionOrder,
            ReturnDiagnostics -> True,
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
        StoreStoredResultEntry["TObject", cacheKey, cacheRoot, cacheLabel,
          computedResult, computedDiagnostics]
      ];
      Return[
        If[TrueQ[OptionValue["ReturnDiagnostics"]],
          {computedResult, computedDiagnostics},
          computedResult
        ]
      ]
    ];
    ingredientResult = BuildSMQCDTObjectIngredients[masslessQuarkMass,
      order, normalizedFinalState, optionsAssoc];
    If[TrueQ[Lookup[ingredientResult, "Failed", False]],
      Message[TObject::ingredientFailure, order, normalizedFinalState,
        Lookup[ingredientResult, "FailedIngredient", "Unknown"]];
      diagnostics =
        Join[ingredientResult, <|"Order" -> order,
          "FinalState" -> normalizedFinalState,
          "quarkMass" -> masslessQuarkMass,
          "ExpansionOrder" -> expansionOrder|>];
      Return[
        RRatioFailureResult[$Failed, diagnostics, <||>,
          OptionValue["ReturnDiagnostics"]]
      ]
    ];
    ingredients = ingredientResult["Ingredients"];
    ingredientDiagnostics = ingredientResult["IngredientDiagnostics"];
    assembled = AssembleSMQCDTObject[ingredients, order,
      normalizedFinalState, expansionOrder];
    If[assembled === $Failed,
      diagnostics = <|"Failed" -> True,
        "Reason" -> "UnsupportedTObjectAssemblyRequest",
        "Order" -> order, "FinalState" -> normalizedFinalState|>;
      Return[
        RRatioFailureResult[$Failed, diagnostics, <||>,
          OptionValue["ReturnDiagnostics"]]
      ]
    ];
    diagnostics = <|
      "Order" -> order,
      "FinalState" -> normalizedFinalState,
      "quarkMass" -> masslessQuarkMass,
      "ExpansionOrder" -> expansionOrder,
      "AssemblySource" -> "ThesisNotebookFormula",
      "Ingredients" -> ingredients,
      "IngredientDiagnostics" -> ingredientDiagnostics,
      "TObjects" -> Map[NormalizePublicTObjectExpression,
        assembled["TObjects"]],
      "PresentedExpression" ->
        NormalizePublicTObjectExpression[assembled["Expression"]]
    |>;
    If[TrueQ[OptionValue["ReturnDiagnostics"]],
      {NormalizePublicTObjectExpression[assembled["Expression"]],
        diagnostics},
      NormalizePublicTObjectExpression[assembled["Expression"]]
    ]
  ];
