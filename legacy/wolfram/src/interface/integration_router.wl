(*************************************************)

(*
  Public integration interface.
  Communicates with:
    - src/interface/build_router.wl for AntennaObject creation and run-record
      helpers.
    - src/routes/integration_workflows.wl for route orchestration.
    - src/routes/massive_a30_integrated.wl for the heavy A30 bibliography
      bridge.
    - src/engines/integration_pave.wl, src/engines/integration_ibp.wl, and
      src/engines/integrated_antenna_extraction.wl for backend and post-
      integration mechanics.

  Why this file exists:
    Integration has the richest public contract in the package: it may return a
    series result, T-terms, a master combination, or a stitched multi-branch
    object, and it may do so from either a direct backend call or a built
    AntennaObject.  This file keeps those public choices uniform.

  Integration router placeholder.
  The public integration layer should eventually mirror BuildAntenna:
  user-facing calls dispatch through antenna/integration profiles while the
  backend-specific PaVe or IBP details remain hidden inside this router.

  The main contract in this file is:
    AntennaObject + integration options
      -> backend-specific raw integrated expression
      -> normalized final integrated expression
      -> optional component selection / A22 branch stitching
      -> diagnostics, intermediate steps, and cache metadata

  Keeping that contract explicit is important because the PaVe and IBP backends
  return very different internal structures even though the public API is meant
  to look uniform.
*)

(*************************************************)

IntegrateAntenna::usage =
  "IntegrateAntenna[obj, ...] integrates an AntennaObject through the appropriate PaVe or IBP backend.";

BuildAndIntegrateAntenna::usage =
  "BuildAndIntegrateAntenna[type, numFinalParticles, loopOrder, ...] is the one-shot public route that builds and integrates an antenna in one call.";

LegacyIntegrateAntenna::usage =
  "LegacyIntegrateAntenna[type, numFinalParticles, loopOrder, ...] is compatibility sugar that delegates to BuildAndIntegrateAntenna.";

IntegratedResidualListZeroQ::usage =
  "IntegratedResidualListZeroQ[residuals] tests whether every entry in a diagnostic residual list is exactly zero.";

CollectIntegrationIntermediateSteps::usage =
  "CollectIntegrationIntermediateSteps[antenna, rawIntegrated, tTerms, finalIntegrated, selectedIntegrated, backendDiagnostics, diagnostics, steps] collects the requested integration-side stages.";

HeavyIntegrationRouteQ::usage =
  "HeavyIntegrationRouteQ[key, component, contribution] identifies routes that should warn users about a long-running integration backend.";

HeavyIntegrationRouteLabel::usage =
  "HeavyIntegrationRouteLabel[key, component, contribution] formats the human-readable heavy-route label used in warnings.";

MaybeWarnHeavyIntegrationRoute::usage =
  "MaybeWarnHeavyIntegrationRoute[key, component, contribution] emits the one-time heavy-route warning when a selected route is known to be expensive.";

IntegrateAntennaStoredResultKey::usage =
  "IntegrateAntennaStoredResultKey[obj, options] builds the cache key for an IntegrateAntenna request.";

IntegrateAntennaStoredResultLabel::usage =
  "IntegrateAntennaStoredResultLabel[obj, options] builds the human-readable cache label for an IntegrateAntenna request.";

FormatFreshIntegrationReturn::usage =
  "FormatFreshIntegrationReturn[result, diagnostics, returnDiagnostics, returnRecord, requestedSteps, printSteps, routeKind, recordStages, metadata] formats a fresh integration result in the public return shape.";

ResolveIntegrationPublicResult::usage =
  "ResolveIntegrationPublicResult[result, diagnostics, returnMasterCombination, routeLabel] rewrites the public return value into the requested integration result kind without changing the stored backend stages.";

MasterCombinationView::usage =
  "MasterCombinationView[diagnostics] returns the stable provenance object for an unreplaced runtime master combination. It records the displayed expression, basis metadata, and the declared bridge status without substituting master values.";

AttachMasterCombinationView::usage =
  "AttachMasterCombinationView[diagnostics] adds the stable MasterCombinationView field to integration diagnostics.";

MasterCombinationBasisSummary::usage =
  "MasterCombinationBasisSummary[expr, diagnostics] inspects every LiteRed basis occurring in a master combination and returns its runtime propagator, cut, used-master, and exact display-alias metadata.";

PrintMasterCombinationBasisSummary::usage =
  "PrintMasterCombinationBasisSummary[expr, diagnostics] prints the data-driven LiteRed basis legend for a returned master combination without changing the expression.";

MasterBasisPropagatorAlias::usage =
  "MasterBasisPropagatorAlias[denominator, profile] derives a display-only external-momentum or invariant alias when it follows exactly from the route momentum rules.";

MasterCombinationNormalForm::usage =
  "MasterCombinationNormalForm[expr] collects an unreplaced LiteRed expression into an explicit linear combination of its master integrals without applying master-value substitutions.";

PublicMasterCombinationDisplayForm::usage =
  "PublicMasterCombinationDisplayForm[expr] applies AntCalc's public d = 4 - 2 Epsilon dictionary and eps = Epsilon spelling to an unreplaced runtime-master combination without changing the raw LiteRed backend payload.";

A22CombineIntegratedResults::usage =
  "A22CombineIntegratedResults[treeResult, breveResult] stitches the public four-component A22 integrated result from its tree/two-loop and one-loop/self branches.";

A22CombineIntegratedComponentDiagnostics::usage =
  "A22CombineIntegratedComponentDiagnostics[treeDiagnostics, breveDiag, finalIntegrated, selectedComponent, returnTTerms] merges the stitched A22 diagnostics into one public association.";

IntegratedAntennaDiagnostics::usage =
  "IntegratedAntennaDiagnostics[key, rawIntegrated, tTerms, finalIntegrated, selectedIntegrated, backendDiagnostics, ...] constructs the standard diagnostics association for integrated routes.";

LoadMassiveA30IntegratedProvenance::usage =
  "LoadMassiveA30IntegratedProvenance[] loads the massive A30 integrated provenance layer on demand for the public massive integration routes.";

MassiveA30IntegratedRouteData::usage =
  "MassiveA30IntegratedRouteData[qm, order, normalizeScale, profile] returns the package-shaped integrated-result bundle used by the public massive A30 integration routes.";

MassiveA30DefaultMasterEndpointResult::usage =
  "MassiveA30DefaultMasterEndpointResult[obj, options, routeKind, integratedFallback, diagnostics, routeLabel] returns the closed massive A30 result together with its derived-MX30 diagnostics.";

Options[IntegrateAntenna] = {ApplyFeynCalcMS -> True, quarkMass -> 0,
   ExpansionOrder -> Automatic, KinematicScale -> q2, NormalizeKinematicScale ->
    True, ReturnDiagnostics -> False, ReturnRecord -> False,
   ReturnMasterCombination -> False,
   LoopMomentum -> l, ApplyDimReg -> True, BasisFamily -> Automatic, BasisRoot -> Automatic,
   GenerateMissingBases -> False,
   ReturnTTerms -> False, Component -> All,
   IntermediateSteps -> {}, PrintIntermediateSteps -> False,
   PrintComponentLegend -> Automatic,
   DetailedTimingDiagnostics -> False,
   UseStoredResults -> False, StoreResults -> False,
   ResultsCacheRoot -> Automatic, RefreshStoredResults -> False};

IntegrateAntenna::heavy =
  "This route uses a heavy integration backend and may take a long time: `1`.";

IntegrateAntenna::nomaster =
  "Master-combination form is not available for `1`.";

IntegrateAntenna::mx30endpoint =
  "Massive A30 with nonzero quarkMass currently stops at the MX30 master-integral linear combination. Returning that expression for `1`.";

IntegratedResidualListZeroQ[residuals_] :=
  ListQ[residuals] && And @@ (TrueQ[# === 0]& /@ residuals);

(* CollectIntegrationIntermediateSteps[...]
   ========================================
   Collect only the integration stages explicitly requested by the caller. *)
CollectIntegrationIntermediateSteps[antenna_, rawIntegrated_, tTerms_,
   finalIntegrated_, selectedIntegrated_, backendDiagnostics_, diagnostics_,
   steps_List] :=
  Module[{collected = <||>},
    (* Intermediate-step capture is intentionally opt-in because some of these
       objects can be very large.  The router keeps the stage names stable so
       notebooks, tests, and future tooling can request them predictably. *)
    If[RequestedIntermediateStepQ[steps, "InputAntenna"],
      collected = Join[collected, <|"InputAntenna" -> antenna|>]
    ];
    If[RequestedIntermediateStepQ[steps, "RawIntegrated"],
      collected = Join[collected, <|"RawIntegrated" -> rawIntegrated|>]
    ];
    If[RequestedIntermediateStepQ[steps, "TTerms"],
      collected = Join[collected, <|"TTerms" -> tTerms|>]
    ];
    If[RequestedIntermediateStepQ[steps, "FinalIntegrated"],
      collected = Join[collected, <|"FinalIntegrated" -> finalIntegrated|>]
    ];
    If[RequestedIntermediateStepQ[steps, "SelectedIntegrated"],
      collected = Join[collected, <|"SelectedIntegrated" -> selectedIntegrated|>]
    ];
    If[RequestedIntermediateStepQ[steps, "BackendDiagnostics"],
      collected = Join[collected, <|"BackendDiagnostics" -> backendDiagnostics|>]
    ];
    If[RequestedIntermediateStepQ[steps, "IntegrationDiagnostics"],
      collected = Join[collected, <|"IntegrationDiagnostics" -> diagnostics|>]
    ];
    collected
  ];

(*************************************************)

(* src public wrappers: thin interface over route-owned workflows. *)

(*************************************************)

LegacyIntegrateAntennaBackendDirect[antenna_, integrationMethod:(PaVe | IBP),
   OptionsPattern[]] :=
  IntegrateBackendDirectRoute[
    antenna,
    integrationMethod,
    <|
      "ApplyFeynCalcMS" -> OptionValue["ApplyFeynCalcMS"],
      "quarkMass" -> OptionValue["quarkMass"],
      "IntermediateSteps" -> OptionValue["IntermediateSteps"],
      "KinematicScale" -> OptionValue["KinematicScale"],
      "ExpansionOrder" -> OptionValue["ExpansionOrder"],
      "ReturnMasterCombination" -> OptionValue["ReturnMasterCombination"],
      "PaVeEvaluation" -> OptionValue["PaVeEvaluation"],
      "NormalizeKinematicScale" -> OptionValue["NormalizeKinematicScale"],
      "LoopMomentum" -> OptionValue["LoopMomentum"],
      "ApplyDimReg" -> OptionValue["ApplyDimReg"],
      "BasisFamily" -> OptionValue["BasisFamily"],
      "BasisRoot" -> OptionValue["BasisRoot"],
      "GenerateMissingBases" -> OptionValue["GenerateMissingBases"],
      "ReturnDiagnostics" -> OptionValue["ReturnDiagnostics"],
      "DetailedTimingDiagnostics" -> OptionValue["DetailedTimingDiagnostics"],
      "Component" -> OptionValue["Component"],
      "PrintIntermediateSteps" -> OptionValue["PrintIntermediateSteps"]
    |>
  ];

LegacyIntegrateAntennaObjectEntry[obj_AntennaObject, OptionsPattern[]] :=
  IntegrateRouteObject[
    obj,
    <|
      "ApplyFeynCalcMS" -> OptionValue["ApplyFeynCalcMS"],
      "quarkMass" -> OptionValue["quarkMass"],
      "ExpansionOrder" -> OptionValue["ExpansionOrder"],
      "KinematicScale" -> OptionValue["KinematicScale"],
      "NormalizeKinematicScale" -> OptionValue["NormalizeKinematicScale"],
      "ReturnDiagnostics" -> OptionValue["ReturnDiagnostics"],
      "ReturnRecord" -> OptionValue["ReturnRecord"],
      "ReturnMasterCombination" -> OptionValue["ReturnMasterCombination"],
      "LoopMomentum" -> OptionValue["LoopMomentum"],
      "ApplyDimReg" -> OptionValue["ApplyDimReg"],
      "BasisFamily" -> OptionValue["BasisFamily"],
      "BasisRoot" -> OptionValue["BasisRoot"],
      "GenerateMissingBases" -> OptionValue["GenerateMissingBases"],
      "ReturnTTerms" -> OptionValue["ReturnTTerms"],
      "IntermediateSteps" -> OptionValue["IntermediateSteps"],
      "PrintIntermediateSteps" -> OptionValue["PrintIntermediateSteps"],
      "PrintComponentLegend" -> OptionValue["PrintComponentLegend"],
      "DetailedTimingDiagnostics" -> OptionValue["DetailedTimingDiagnostics"],
      "UseStoredResults" -> OptionValue["UseStoredResults"],
      "StoreResults" -> OptionValue["StoreResults"],
      "ResultsCacheRoot" -> OptionValue["ResultsCacheRoot"],
      "RefreshStoredResults" -> OptionValue["RefreshStoredResults"],
      "Component" -> OptionValue["Component"],
      "RouteKind" -> "IntegrateAntenna"
    |>
  ];

BuildAndIntegrateAntenna[type_, numFinalParticles_Integer, loopOrder_Integer,
   OptionsPattern[]] :=
  BuildAndIntegrateRouteResult[
    type,
    numFinalParticles,
    loopOrder,
    <|
      "ApplyFeynCalcMS" -> OptionValue["ApplyFeynCalcMS"],
      "quarkMass" -> OptionValue["quarkMass"],
      "ExpansionOrder" -> OptionValue["ExpansionOrder"],
      "KinematicScale" -> OptionValue["KinematicScale"],
      "NormalizeKinematicScale" -> OptionValue["NormalizeKinematicScale"],
      "ReturnDiagnostics" -> OptionValue["ReturnDiagnostics"],
      "ReturnRecord" -> OptionValue["ReturnRecord"],
      "ReturnMasterCombination" -> OptionValue["ReturnMasterCombination"],
      "LoopMomentum" -> OptionValue["LoopMomentum"],
      "ApplyDimReg" -> OptionValue["ApplyDimReg"],
      "BasisFamily" -> OptionValue["BasisFamily"],
      "BasisRoot" -> OptionValue["BasisRoot"],
      "GenerateMissingBases" -> OptionValue["GenerateMissingBases"],
      "ReturnTTerms" -> OptionValue["ReturnTTerms"],
      "IntermediateSteps" -> OptionValue["IntermediateSteps"],
      "PrintIntermediateSteps" -> OptionValue["PrintIntermediateSteps"],
      "PrintComponentLegend" -> OptionValue["PrintComponentLegend"],
      "DetailedTimingDiagnostics" -> OptionValue["DetailedTimingDiagnostics"],
      "UseStoredResults" -> OptionValue["UseStoredResults"],
      "StoreResults" -> OptionValue["StoreResults"],
      "ResultsCacheRoot" -> OptionValue["ResultsCacheRoot"],
      "RefreshStoredResults" -> OptionValue["RefreshStoredResults"],
      "Component" -> OptionValue["Component"]
    |>
  ];

If[!ValueQ[$AntennaPipelineHeavyRouteNotices],
  $AntennaPipelineHeavyRouteNotices = <||>;
];

HeavyIntegrationRouteQ[key_, component_, contribution_] :=
  Module[{componentName, contributionName},
    componentName = CanonicalAntennaComponentName[component];
    contributionName = CanonicalAntennaComponentName[contribution];
    MemberQ[{{A, 3, 1}, {A, 2, 2}, {A, 4, 0}, {B, 4, 0}, {C, 4, 0}},
        key] &&
      MemberQ[{"All", "TwoLoopTree", "OneLoopSelf"}, contributionName]
  ];

HeavyIntegrationRouteLabel[key_, component_, contribution_] :=
  StringJoin[
    ToString[key, InputForm],
    " with Component -> ",
    CanonicalAntennaComponentName[component]
  ];

MaybeWarnHeavyIntegrationRoute[key_, component_, contribution_] :=
  Module[{noticeKey, label, componentName},
    If[!HeavyIntegrationRouteQ[key, component, contribution],
      Return[Null]
    ];
    componentName = CanonicalAntennaComponentName[component];
    (* The warning is only emitted for the all-components view, because the
       selected-component routes are the recommended way to probe expensive
       families incrementally. *)
    If[componentName =!= "All",
      Return[Null]
    ];
    noticeKey = StringJoin[
      ToString[key, InputForm],
      "::",
      componentName,
      "::",
      CanonicalAntennaComponentName[contribution]
    ];
    If[TrueQ[Lookup[$AntennaPipelineHeavyRouteNotices, noticeKey, False]],
      Return[Null]
    ];
    label = HeavyIntegrationRouteLabel[key, component, contribution];
    Message[IntegrateAntenna::heavy, label];
    AssociateTo[$AntennaPipelineHeavyRouteNotices, noticeKey -> True];
  ];

heavyIntegrationProgressPrint[routeKind_String, key_, component_,
   contribution_, current_Integer, total_Integer, label_String] :=
  Print[
    "[", DateString[{"ISODate", " ", "Time"}], "] ",
    routeKind, " [", current, "/", total, "]: ", label, " ",
    HeavyIntegrationRouteLabel[key, component, contribution]
  ];

(* IntegrateAntennaStoredResultKey[obj, options]
   =============================================
   Build a cache key that captures both the selected AntennaObject view and the
   runtime integration options. *)
IntegrateAntennaStoredResultKey[obj_AntennaObject, options_Association] :=
  Module[{data},
    data = AntennaObjectData[obj];
    (* Cache keys include both the object selection and the runtime options so
       reused results remain valid across component slicing, backend settings,
       and convention-changing options such as ExpansionOrder or quarkMass. *)
    StoredResultKeyAssociation[
      "IntegrateAntenna",
      <|
        "AntennaKey" -> Lookup[data, "Key", Missing["UnknownKey"]],
        "ObjectComponent" -> Lookup[data, "SelectedComponent", All],
        "ContributionsUsed" -> Lookup[data, "ContributionsUsed",
          Missing["NotApplicable"]],
        "ApplyFeynCalcMS" -> Lookup[options, "ApplyFeynCalcMS", True],
        "quarkMass" -> Lookup[options, "quarkMass", 0],
        "PaVeEvaluation" -> Lookup[options, "PaVeEvaluation",
          "PaXEvaluate"],
        "ExpansionOrder" -> Lookup[options, "ExpansionOrder", Automatic],
        "KinematicScale" -> Lookup[options, "KinematicScale", q2],
        "NormalizeKinematicScale" -> Lookup[options,
          "NormalizeKinematicScale", True],
        "LoopMomentum" -> Lookup[options, "LoopMomentum", l],
        "ApplyDimReg" -> Lookup[options, "ApplyDimReg", True],
        "BasisFamily" -> Lookup[options, "BasisFamily", Automatic],
        "BasisRoot" -> Lookup[options, "BasisRoot", Automatic],
        "GenerateMissingBases" -> Lookup[options, "GenerateMissingBases",
          False],
        "ReturnTTerms" -> Lookup[options, "ReturnTTerms", False],
        "ReturnMasterCombination" -> Lookup[options,
          "ReturnMasterCombination", False],
        "Component" -> Lookup[options, "Component", All],
        "DetailedTimingDiagnostics" -> Lookup[options,
          "DetailedTimingDiagnostics", False]
      |>
    ]
  ];

IntegrateAntennaStoredResultLabel[obj_AntennaObject, options_Association] :=
  Module[{data, key},
    data = AntennaObjectData[obj];
    key = Lookup[data, "Key", Missing["UnknownKey"]];
    StringJoin[
      "IntegrateAntenna-",
      StoredResultTypeLabel[First[key]], "-",
      ToString[key[[2]]], "-",
      ToString[key[[3]]], "-",
      CanonicalAntennaComponentName[Lookup[options, "Component", All]]
    ]
  ];

(* FormatFreshIntegrationReturn[result, diagnostics, ...]
   ======================================================
   Convert one freshly computed integration result into the requested public
   return shape. *)
FormatFreshIntegrationReturn[result_, diagnostics_, returnDiagnostics_,
   returnRecord_, requestedSteps_List, printSteps_,
   routeKind_String:"IntegrateAntenna", recordStages_:Automatic,
   recordMetadata_Association:<||>] :=
  Module[{selectedSteps, stages, record, diagnosticsWithMasterView},
    diagnosticsWithMasterView = AttachMasterCombinationView[diagnostics];
    selectedSteps = Lookup[diagnosticsWithMasterView, "IntermediateSteps", <||>];
    If[TrueQ[returnRecord],
      stages =
        If[AssociationQ[recordStages],
          recordStages
          ,
          If[AssociationQ[selectedSteps], selectedSteps, <||>]
        ];
      record = IntegrationRunRecord[routeKind, result, diagnosticsWithMasterView, stages,
        recordMetadata];
      If[TrueQ[printSteps] && AssociationQ[record["IntermediateSteps"]] &&
          Length[record["IntermediateSteps"]] > 0,
        PrintIntermediateStepsAssociation[record["IntermediateSteps"]]
      ];
      Return[record]
    ];
    If[TrueQ[printSteps] && AssociationQ[selectedSteps] && Length[
        selectedSteps] > 0,
      PrintIntermediateStepsAssociation[selectedSteps]
    ];
    MaybePrintComponentLegend[result, returnRecord, recordMetadata];
    If[TrueQ[returnDiagnostics],
      {result, diagnosticsWithMasterView}
      ,
      If[Length[requestedSteps] > 0,
        {result, selectedSteps}
        ,
        result
      ]
    ]
  ];

MasterCombinationNormalForm[expr_] :=
  Module[{masters},
    masters = DeleteDuplicates @ Cases[expr,
      HoldPattern[LiteRed`j[___]], Infinity];
    If[Length[masters] === 0, Return[expr]];
    Collect[expr, masters, Simplify]
  ];

(* This is deliberately a return-boundary skin. The raw LiteRed reduction
   remains in BackendDiagnostics["RawLiteRedCombination"] with its native d
   and eps symbols for provenance and backend debugging. *)
PublicMasterCombinationDisplayForm[expr_] :=
  MasterCombinationNormalForm[
    expr /. {
      d -> 4 - 2 Epsilon,
      eps -> Epsilon,
      FeynCalc`Epsilon -> Epsilon
    }
  ];

MasterCombinationView[diagnostics_Association] :=
  Module[{backendDiagnostics, profile, key, combination, rawCombination, masters,
     basisFamily, genericDefinitions, massiveA30Q},
    backendDiagnostics = Lookup[diagnostics, "BackendDiagnostics", <||>];
    If[!AssociationQ[backendDiagnostics], backendDiagnostics = <||>];
    profile = Lookup[diagnostics, "Profile",
      Lookup[backendDiagnostics, "Profile", <||>]];
    If[!AssociationQ[profile], profile = <||>];
    key = Lookup[profile, "Key", Missing["NotAvailable"]];
    basisFamily = Lookup[profile, "BasisFamily",
      Lookup[backendDiagnostics, "BasisFamily", Missing["NotAvailable"]]];
    massiveA30Q =
      MassiveA30ResolvedRouteQ[key, <|"quarkMass" ->
        Lookup[profile, "MassSymbol", Lookup[diagnostics, "quarkMass", 0]]|>] ||
      MemberQ[{"MX30", "MX30Basis123"}, basisFamily];
    rawCombination = BackendMasterCombination[backendDiagnostics];
    rawCombination = MasterCombinationNormalForm[rawCombination];
    combination = PublicMasterCombinationDisplayForm[rawCombination];
    If[MatchQ[combination, Missing[__]],
      Return[<|
        "SchemaVersion" -> 1,
        "Availability" -> "NotAvailable",
        "Expression" -> combination,
        "RawExpression" -> rawCombination,
        "BasisFamily" -> basisFamily,
        "AntennaKey" -> key,
        "MasterDefinitions" -> <||>,
        "SubstitutionStatus" -> "NoRuntimeMasterCombinationExposed"
      |>]
    ];
    If[massiveA30Q,
      Return[<|
        "SchemaVersion" -> 1,
        "Availability" -> "Available",
        "Expression" -> combination,
        "RawExpression" -> rawCombination,
        "DimensionConvention" -> "d = 4 - 2 Epsilon; eps = Epsilon",
        "Stage" -> "PublicMasterCombinationDisplay",
        "RawStage" -> "RawMasterCombination",
        "BasisFamily" -> "MX30Basis123",
        "AntennaKey" -> key,
        "MasterDefinitions" -> <|
          "J11100" -> <|
            "Symbol" -> HoldForm[LiteRed`j[MX30Basis123, 1, 1, 1, 0, 0]],
            "Family" -> "MX30Basis123", "Indices" -> {1, 1, 1, 0, 0},
            "Role" -> "Undotted runtime master",
            "PaperRelation" -> "Related to the paper I1^(m,0,m) master by the declared common cut-measure conversion."|>,
          "J21100" -> <|
            "Symbol" -> HoldForm[LiteRed`j[MX30Basis123, 2, 1, 1, 0, 0]],
            "Family" -> "MX30Basis123", "Indices" -> {2, 1, 1, 0, 0},
            "Role" -> "Dotted runtime master",
            "PaperRelation" -> "Dotted runtime representative related to the paper numerator master I2^(m,0,m) through its explicit MX30 reduction."|>
        |>,
        "PaperMasterDefinitions" -> <|
          "I1" -> "Paper phase-space master I1^(m,0,m).",
          "I2" -> "Paper numerator master I2^(m,0,m)."
        |>,
        "SubstitutionStatus" -> "UnreplacedRuntimeBasis",
        "BridgeStatus" -> "DerivedMX30MasterClosure",
        "BridgeNote" -> "This view exposes the runtime dotted-master combination and its derived paper-to-runtime mapping."
      |>]
    ];
    masters = DeleteDuplicates @ Cases[combination,
      HoldPattern[LiteRed`j[family_, indices___]], Infinity];
    genericDefinitions = Association @ MapIndexed[
      ("Master" <> ToString[First[#2]] -> <|
        "Symbol" -> #1,
        "Definition" -> "LiteRed runtime-basis representative; family and propagator powers are encoded by the displayed j[...] expression."|>)&,
      masters
    ];
    <|
      "SchemaVersion" -> 1,
      "Availability" -> "Available",
      "Expression" -> combination,
      "RawExpression" -> rawCombination,
      "DimensionConvention" -> "d = 4 - 2 Epsilon; eps = Epsilon",
      "Stage" -> "PublicMasterCombinationDisplay",
      "RawStage" -> "RawMasterCombination",
      "BasisFamily" -> basisFamily,
      "AntennaKey" -> key,
      "MasterDefinitions" -> genericDefinitions,
      "SubstitutionStatus" -> "UnreplacedRuntimeBasis",
      "BridgeStatus" -> "NoPaperBasisBridgeAsserted"
    |>
  ];

AttachMasterCombinationView[diagnostics_Association] :=
  If[KeyExistsQ[diagnostics, "MasterCombinationView"] &&
      AssociationQ[diagnostics["MasterCombinationView"]] &&
      KeyExistsQ[diagnostics["MasterCombinationView"], "RawExpression"], diagnostics,
    Join[diagnostics, <|"MasterCombinationView" ->
      MasterCombinationView[diagnostics]|>]];

AttachMasterCombinationView[diagnostics_] := diagnostics;

MasterBasisMomentumDefinitions[profile_Association] :=
  Module[{rules, external},
    rules = Lookup[profile, "MomentumRules", {}];
    external = Cases[rules,
      HoldPattern[_[index_Integer] -> momentum_] :> {index, momentum}];
    SortBy[external, First]
  ];

MasterBasisSquaredMomentumLabel[momentum_, external_List] :=
  Module[{single, pairs},
    single = SelectFirst[external,
      TrueQ[Simplify[Expand[momentum - #[[2]]]] === 0] ||
        TrueQ[Simplify[Expand[momentum + #[[2]]]] === 0]&,
      Missing["NotFound"]];
    If[!MissingQ[single], Return["p" <> ToString[single[[1]]] <> "^2"]];
    pairs = Subsets[external, {2}];
    SelectFirst[pairs,
      TrueQ[Simplify[Expand[momentum - (#[[1, 2]] + #[[2, 2]])]] === 0] ||
        TrueQ[Simplify[Expand[momentum + #[[1, 2]] + #[[2, 2]]]] === 0]&,
      Missing["NotFound"]] /. {
        pair_List :> "s" <> ToString[pair[[1, 1]]] <> ToString[pair[[2, 1]]],
        _Missing :> Missing["NotFound"]
      }
  ];

MasterBasisPropagatorAlias[denominator_, profile_Association:<||>] :=
  Module[{external, squaredTerms, squared, coefficient, remainder, label,
     remainderLabel},
    external = MasterBasisMomentumDefinitions[profile];
    If[Length[external] === 0, Return[Missing["NoMomentumRules"]]];
    (* Generated LiteRed bases can restore the scalar-product head in a
       context that is not stable across LiteRed versions.  Recognise its
       displayed sp[_,_] structure rather than a hard-coded symbol context. *)
    squaredTerms = Cases[denominator,
      scalar_ /; StringStartsQ[ToString[scalar, InputForm], "sp["] :>
        With[{arguments = List @@ scalar},
          If[Length[arguments] === 2 &&
              TrueQ[Simplify[Expand[arguments[[1]] - arguments[[2]]]] === 0],
            arguments[[1]], Nothing]],
      {0, Infinity}];
    If[Length[squaredTerms] =!= 1, Return[Missing["NoUniqueSquaredMomentum"]]];
    squared = SelectFirst[Cases[denominator,
        scalar_ /; StringStartsQ[ToString[scalar, InputForm], "sp["] :> scalar,
        {0, Infinity}],
      TrueQ[Simplify[Expand[(List @@ #)[[1]] - squaredTerms[[1]]]] === 0]&];
    coefficient = Quiet[Check[Coefficient[denominator, squared], $Failed]];
    If[coefficient === $Failed || !MemberQ[{1, -1}, coefficient],
      Return[Missing["UnsupportedPropagatorForm"]]
    ];
    label = MasterBasisSquaredMomentumLabel[squaredTerms[[1]], external];
    If[MissingQ[label], Return[label]];
    remainder = Simplify[denominator - coefficient squared];
    remainderLabel = ToString[remainder, TraditionalForm];
    Which[
      TrueQ[remainder === 0] && coefficient === 1, label,
      coefficient === -1 && TrueQ[remainder =!= 0], remainderLabel <> " - " <> label,
      coefficient === 1 && TrueQ[remainder =!= 0], remainderLabel <> " + " <> label,
      True, Missing["UnsupportedPropagatorForm"]
    ]
  ];

MasterCombinationBasisSummary[expr_, diagnostics_Association:<||>] :=
  Module[{occurrences, bases, basisSummary, denominators, cutVector,
     cutPositions, masters, activePositions, dottedPositions, profile,
     backendProfile},
    backendProfile = Lookup[Lookup[diagnostics, "BackendDiagnostics", <||>],
      "Profile", <||>];
    profile = Lookup[diagnostics, "Profile", <||>];
    If[!AssociationQ[profile] || !KeyExistsQ[profile, "MomentumRules"],
      profile = backendProfile
    ];
    If[!AssociationQ[profile], profile = <||>];
    occurrences = DeleteDuplicates @ Cases[expr,
      HoldPattern[LiteRed`j[basis_, indices__]] :> {basis, {indices}},
      Infinity];
    bases = DeleteDuplicates[occurrences[[All, 1]] /. {} -> {}];
    Association @ Table[
      denominators = Quiet[Check[LiteRed`Ds[basis], Missing["NotAvailable"]]];
      cutVector = Quiet[Check[LiteRed`CutDs[basis], Missing["NotAvailable"]]];
      cutPositions =
        If[ListQ[cutVector], Flatten@Position[cutVector, 1],
          Missing["NotAvailable"]];
      masters = Select[occurrences, First[#] === basis&][[All, 2]];
      masters = DeleteDuplicates[masters];
      basisSummary = Association @ MapIndexed[
        (
          activePositions = Flatten@Position[#1, _?(# > 0&)];
          dottedPositions = Flatten@Position[#1, _?(# > 1&)];
          "j[" <> ToString[basis, InputForm] <> "," <>
            StringRiffle[ToString /@ #1, ","] <> "]" -> <|
              "Indices" -> #1,
              "ActivePropagators" -> activePositions,
              "DottedPropagators" -> dottedPositions
            |>
        )&,
        masters
      ];
      ToString[basis, InputForm] -> <|
        "BasisSymbol" -> basis,
        "Propagators" -> denominators,
        "PropagatorDisplayAliases" ->
          If[ListQ[denominators],
            MasterBasisPropagatorAlias[#, profile]& /@ denominators,
            Missing["NotAvailable"]],
        "CutVector" -> cutVector,
        "CutPropagatorPositions" -> cutPositions,
        "MastersOccurring" -> basisSummary
      |>,
      {basis, bases}
    ]
  ];

PrintMasterCombinationBasisSummary[expr_, diagnostics_Association:<||>] :=
  Module[{summary, entries, data, cutLabel, masterEntries, masterData,
     aliases},
    summary = MasterCombinationBasisSummary[expr, diagnostics];
    If[Length[summary] === 0, Return[Null]];
    Print["[AntCalc] Master bases used: ", StringRiffle[Keys[summary], ", "]];
    KeyValueMap[
      (
        data = #2;
        Print["  ", #1];
        If[ListQ[data["Propagators"]],
          aliases = data["PropagatorDisplayAliases"];
          MapIndexed[
            Print["    D", First[#2], " = ", #1,
              If[ListQ[aliases] && !MissingQ[aliases[[First[#2]]]],
                " = " <> aliases[[First[#2]]], ""]]&,
            data["Propagators"]],
          Print["    Propagators: unavailable from loaded LiteRed basis metadata."]
        ];
        cutLabel = If[ListQ[data["CutPropagatorPositions"]],
          If[Length[data["CutPropagatorPositions"]] === 0, "none",
            StringRiffle[("D" <> ToString[#])& /@
              data["CutPropagatorPositions"], ", "]],
          "unavailable"];
        Print["    Cut propagators: ", cutLabel];
        Print["    Masters occurring:"];
        KeyValueMap[
          (
            masterData = #2;
            Print["      ", #1, "  active: ",
              If[Length[masterData["ActivePropagators"]] === 0, "none",
                StringRiffle[("D" <> ToString[#])& /@
                  masterData["ActivePropagators"], ", "]],
              If[Length[masterData["DottedPropagators"]] === 0, "",
                "; dotted: " <> StringRiffle[("D" <> ToString[#])& /@
                  masterData["DottedPropagators"], ", "]]
            ]
          )&,
          data["MastersOccurring"]
        ]
      )&,
      summary
    ];
    Null
  ];

(* ResolveIntegrationPublicResult[result, diagnostics, returnMasterCombination, routeLabel]
   =======================================================================================
   Rewrite the public return value when the caller asks for the master-
   combination representation instead of the final integrated series. *)
ResolveIntegrationPublicResult[result_, diagnostics_,
   returnMasterCombination_, routeLabel_:Automatic] :=
  Module[{backendDiagnostics, masterCombination, label, reason,
     diagnosticsWithMasterView},
    diagnosticsWithMasterView = AttachMasterCombinationView[diagnostics];
    If[!TrueQ[returnMasterCombination],
      Return[{result, diagnosticsWithMasterView}]
    ];
    If[AssociationQ[diagnosticsWithMasterView] &&
        Lookup[diagnosticsWithMasterView, "RequestedResultKind", Missing["Absent"]] ===
          "MasterCombination",
      Return[{result, diagnosticsWithMasterView}]
    ];
    backendDiagnostics =
      Lookup[diagnosticsWithMasterView, "BackendDiagnostics", Missing["NotAvailable"]];
    masterCombination = BackendMasterCombination[backendDiagnostics];
    masterCombination = PublicMasterCombinationDisplayForm[masterCombination];
    label =
      If[routeLabel === Automatic,
        "this route"
        ,
        routeLabel
      ];
    Which[
      MatchQ[masterCombination, Missing[__]],
        {
          Missing["MasterCombinationNotAvailable", label],
          Join[diagnosticsWithMasterView, <|
            "RequestedResultKind" -> "MasterCombination",
            "MasterCombinationAvailable" -> False,
            "MasterCombinationRequestFailed" -> False,
            "MasterCombinationRequestReason" -> "NotAvailable"
          |>]
        }
      ,
      masterCombination === $Failed,
        reason =
          Which[
            AssociationQ[backendDiagnostics] &&
              KeyExistsQ[backendDiagnostics, "OpenMasterRouteSucceeded"] &&
              TrueQ[backendDiagnostics["OpenMasterRouteSucceeded"]] === False,
              "OpenMasterRouteFailed"
            ,
            AssociationQ[backendDiagnostics] &&
              Lookup[backendDiagnostics, "RemainingTojSpOrDotQ", False] === True,
              "ReductionPipelineIncomplete"
            ,
            True,
              "MasterCombinationFailed"
          ];
        {
          $Failed,
          Join[diagnosticsWithMasterView, <|
            "RequestedResultKind" -> "MasterCombination",
            "MasterCombinationRequestFailed" -> True,
            "MasterCombinationRequestReason" -> reason
          |>]
        }
      ,
      True,
        {
          masterCombination,
          Join[diagnosticsWithMasterView, <|"RequestedResultKind" -> "MasterCombination"|>]
        }
    ]
  ];

MassiveA30DefaultMasterEndpointResult[obj_AntennaObject,
   options_Association, routeKind_String, integratedFallback_,
   diagnostics_Association, routeLabel_String] :=
  {
    integratedFallback,
    Join[
      diagnostics,
      <|
        "RequestedResultKind" -> "ClosedDerivedMX30Result",
        "MassiveA30EndpointReached" -> False,
        "MassiveA30ClosedMX30Result" -> True
      |>
    ]
  };

LoadMassiveA30IntegratedProvenance[] :=
  Null;

PrintMassiveA30ClosedBridgeNotice[] :=
  Print[
    StringRiffle[
      {
        "Massive A30 beta-route notice:",
        "The current integrated closed form follows the derived MX30 master closure.",
        "The package MX30 master-combination stage remains available for diagnostics.",
        "Fresh-kernel checks qualify ExpansionOrder through 2; deeper epsilon orders remain outside the beta claim in both BuildAndIntegrateAntenna and IntegrateAntenna.",
        "To inspect the failure diagnostics of the forced open-master route through BuildAndIntegrateAntenna, evaluate:",
        "Block[{$MassiveA30ForceIBPMasterRoute = True},",
        "  Last[BuildAndIntegrateAntenna[A, 3, 0, quarkMass -> mQ, ReturnDiagnostics -> True]]",
        "]",
        "",
        "To inspect the analogous forced-route diagnostics through IntegrateAntenna, evaluate:",
        "Block[{$MassiveA30ForceIBPMasterRoute = True},",
        "  Last[IntegrateAntenna[",
        "    BuildAntennaObject[A, 3, 0, quarkMass -> mQ],",
        "    quarkMass -> mQ,",
        "    ReturnDiagnostics -> True",
        "  ]]",
        "]"
      },
      "\n"
    ]
  ];

MassiveA30OpenMasterRouteRecord[obj_AntennaObject, options_Association,
   routeKind_String:"IntegrateAntenna"] :=
  Module[{forced},
    forced =
      Block[
        {
          $MassiveA30ForceIBPMasterRoute = True,
          $AntennaPipelineBypassStoredResults = True
        },
        IntegrateRouteObject[
          obj,
          Join[
            options,
            <|
              "ReturnDiagnostics" -> True,
              "ReturnRecord" -> True,
              "IntermediateSteps" -> {},
              "PrintIntermediateSteps" -> False,
              "UseStoredResults" -> False,
              "StoreResults" -> False,
              "RefreshStoredResults" -> False,
              "RouteKind" -> routeKind
            |>
          ]
        ]
      ];
    If[AntennaRunRecordQ[forced], forced, Missing["NotAvailable"]]
  ];

MassiveA30OpenMasterBackendDiagnostics[obj_AntennaObject,
   options_Association, routeKind_String:"IntegrateAntenna"] :=
  Module[{record, data, diagnostics, backendDiagnostics, forced},
    (* A normal massive A30 call is the closed literature-backed route.
       Launching a second, forced MX30 reduction merely to decorate its
       diagnostics can dominate the call time.  Reserve that developer
       diagnostic for an explicit master-combination request. *)
    If[!TrueQ[Lookup[options, "ReturnMasterCombination", False]],
      Return[<||>]
    ];
    record = MassiveA30OpenMasterRouteRecord[obj, options, routeKind];
    If[AntennaRunRecordQ[record],
      data = AntennaRunRecordData[record];
      diagnostics = Lookup[data, "Diagnostics", <||>];
      backendDiagnostics =
        Lookup[data, "BackendDiagnostics",
          Lookup[diagnostics, "BackendDiagnostics", <||>]];
      If[!AssociationQ[backendDiagnostics],
        backendDiagnostics = <||>
      ];
      Return[
        <|
          "OpenMasterRouteAvailable" -> True,
          "OpenMasterRouteSucceeded" -> Lookup[data, "Result",
            Missing["NotAvailable"]] =!= $Failed,
          "RawLiteRedCombination" -> Lookup[backendDiagnostics,
            "RawLiteRedCombination",
            Missing["NotAvailable"]],
          "MasterMappedExpression" -> Lookup[backendDiagnostics,
            "MasterMappedExpression",
            Missing["NotAvailable"]],
          "RawMasterCombination" -> Lookup[backendDiagnostics,
            "RawMasterCombination",
            Missing["NotAvailable"]],
          "OpenMasterSubstitutedExpression" -> Lookup[backendDiagnostics,
            "MasterSubstitutedExpression", Missing["NotAvailable"]],
          "OpenMasterSeriesResult" -> Lookup[backendDiagnostics,
            "SeriesResult", Missing["NotAvailable"]],
          "OpenMasterRouteDiagnostics" -> diagnostics
        |>
      ]
    ];
    forced =
      Block[
        {
          $MassiveA30ForceIBPMasterRoute = True,
          $AntennaPipelineBypassStoredResults = True
        },
        IntegrateRouteObject[
          obj,
          Join[
            options,
            <|
              "ReturnDiagnostics" -> True,
              "ReturnRecord" -> False,
              "IntermediateSteps" -> {},
              "PrintIntermediateSteps" -> False,
              "UseStoredResults" -> False,
              "StoreResults" -> False,
              "RefreshStoredResults" -> False,
              "RouteKind" -> routeKind
            |>
          ]
        ]
      ];
    If[!MatchQ[forced, {_, _Association}],
      Return[<||>]
    ];
    backendDiagnostics =
      Lookup[forced[[2]], "BackendDiagnostics", <||>];
    If[!AssociationQ[backendDiagnostics],
      backendDiagnostics = <||>
    ];
    <|
      "OpenMasterRouteAvailable" -> True,
      "OpenMasterRouteSucceeded" -> forced[[1]] =!= $Failed,
      "RawLiteRedCombination" -> Lookup[backendDiagnostics,
        "RawLiteRedCombination", Missing["NotAvailable"]],
      "MasterMappedExpression" -> Lookup[backendDiagnostics,
        "MasterMappedExpression", Missing["NotAvailable"]],
      "RawMasterCombination" -> Lookup[backendDiagnostics,
        "RawMasterCombination", Missing["NotAvailable"]],
      "OpenMasterSubstitutedExpression" -> Lookup[backendDiagnostics,
        "MasterSubstitutedExpression", Missing["NotAvailable"]],
      "OpenMasterSeriesResult" -> Lookup[backendDiagnostics,
        "SeriesResult", Missing["NotAvailable"]],
      "OpenMasterRouteDiagnostics" -> forced[[2]]
    |>
  ];

MassiveA30IntegratedRouteData[qm_, order_, normalizeScale_,
   profile_Association] :=
  Module[{closed, normalized, result, source, bridgeReport, sourceFormQ,
     backendDiagnostics, diagnostics},
    LoadMassiveA30IntegratedProvenance[];
    closed = MassiveA30IntegratedRuntimeClosedExpression[qm];
    (* The literature result is a closed epsilon-dependent expression.  Keep
       that form for the default public route so it remains directly
       comparable to the source.  An epsilon series is an opt-in derived
       representation, requested only by supplying ExpansionOrder explicitly. *)
    sourceFormQ = order === Automatic;
    normalized =
      If[sourceFormQ,
        closed
        ,
        If[TrueQ[normalizeScale],
        closed /. q2 -> 1
        ,
        closed
        ]
      ];
    result =
      If[sourceFormQ,
        closed,
        MassiveA30IntegratedRuntimeSeries[qm, order, normalizeScale]
      ];
    source = MassiveA30IntegratedSource[];
    bridgeReport = MassiveA30IntegratedBridgeReport[];
    backendDiagnostics =
      <|
        "Profile" -> profile,
        "OpenMasterValuesQ" -> False,
        "IntegratedResultKind" -> If[sourceFormQ,
          "ClosedDerivedMX30Expression", "ClosedDerivedMX30Series"],
        "RawLiteRedCombination" -> Missing["NotAvailable"],
        "MasterMappedExpression" -> Missing["NotAvailable"],
        "RawMasterCombination" -> Missing["NotAvailable"],
        "MasterSubstitutedExpression" -> closed,
        "NormalizedBeforeSeries" -> normalized,
        "SeriesResult" -> result,
        "MassiveA30Source" -> source,
        "MassiveA30BridgeReport" -> bridgeReport
      |>;
    diagnostics =
      <|
        "IntegratedResidualIsZero" -> Missing["NotAvailable"],
        "IntegratedResidual" -> Missing["NotAvailable"],
        "Profile" -> profile,
        "Experimental" -> False,
        "Unfinished" -> False,
        "ReleaseGuarantee" -> "Beta",
        "ImplementationStatus" -> "DerivedMX30ClosedRoute",
        "BackendDiagnostics" -> backendDiagnostics,
        "MassiveA30Route" -> True,
        "MassiveA30Source" -> source,
        "MassiveA30BridgeReport" -> bridgeReport
      |>;
    <|
      "RawIntegrated" -> result,
      "TTerms" -> result,
      "FinalIntegrated" -> result,
      "SelectedIntegrated" -> result,
      "BackendDiagnostics" -> backendDiagnostics,
      "Diagnostics" -> diagnostics
    |>
  ];

A22CombineIntegratedResults[treeResult_List, breveResult_] :=
  (* The public A22 result is defined as the stitched four-component object:
     the first three entries come from the tree/two-loop branch and breveA22
     comes from the one-loop/self branch. *)
  Join[treeResult, {breveResult}];

(* A22CombineIntegratedComponentDiagnostics[...]
   =============================================
   Merge diagnostics from the separate A22 branches into one public
   association. *)
A22CombineIntegratedComponentDiagnostics[treeComponentDiags_Association,
   breveDiag_Association, finalIntegrated_List, selectedComponent_,
   returnTTerms_] :=
  Module[{treeOrder, rawIntegrated, tTerms, tResiduals, antennaResiduals,
     expansionOrder},
    treeOrder = {"Leading", "Subleading", "Nf"};
    expansionOrder =
      Lookup[Lookup[treeComponentDiags, "Leading", <||>], "ExpansionOrder",
        Lookup[breveDiag, "ExpansionOrder", 0]];
    rawIntegrated =
      Join[
        Lookup[Lookup[treeComponentDiags, #, <||>], "RawIntegrated",
          Missing["NotAvailable"]]& /@ treeOrder,
        {Lookup[breveDiag, "RawIntegrated", Missing["NotAvailable"]]}
      ];
    tTerms =
      Join[
        Lookup[Lookup[treeComponentDiags, #, <||>], "TTerms",
          Missing["NotAvailable"]]& /@ treeOrder,
        {Lookup[breveDiag, "TTerms", Missing["NotAvailable"]]}
      ];
    tResiduals = A22TTermResiduals[tTerms, expansionOrder];
    antennaResiduals =
      If[TrueQ[returnTTerms],
        Missing["NotAvailable"]
        ,
        A22IntegratedResiduals[finalIntegrated, expansionOrder]
      ];
    <|"A22ContributionStitchingQ" -> True,
      "ContributionsUsed" -> AntennaContributionsUsed[{A, 2, 2},
        selectedComponent],
      "SelectedComponent" -> selectedComponent,
      "BuildComponent" -> All,
      "RawIntegrated" -> rawIntegrated,
      "TTerms" -> tTerms,
      "TTermResiduals" -> tResiduals,
      "TTermResidualsAreZero" -> IntegratedResidualListZeroQ[tResiduals],
      "IntegratedAntennaResiduals" -> antennaResiduals,
      "IntegratedAntennaResidualsAreZero" ->
        IntegratedResidualListZeroQ[antennaResiduals],
      "FinalAntennaExtractionImplemented" -> True,
      "ContributionDiagnostics" -> <|"TwoLoopTree" -> treeComponentDiags,
        "OneLoopSelf" -> breveDiag|>|>
  ];

LegacyIntegrateAntennaBackendDirectRoute[antenna_, integrationMethod:(PaVe | IBP),
   OptionsPattern[]] :=
  IntegrateBackendDirectRoute[
    antenna,
    integrationMethod,
    <|
      "ApplyFeynCalcMS" -> OptionValue["ApplyFeynCalcMS"],
      "quarkMass" -> OptionValue["quarkMass"],
      "IntermediateSteps" -> OptionValue["IntermediateSteps"],
      "KinematicScale" -> OptionValue["KinematicScale"],
      "ExpansionOrder" -> OptionValue["ExpansionOrder"],
      "ReturnMasterCombination" -> OptionValue["ReturnMasterCombination"],
      "PaVeEvaluation" -> OptionValue["PaVeEvaluation"],
      "NormalizeKinematicScale" -> OptionValue["NormalizeKinematicScale"],
      "LoopMomentum" -> OptionValue["LoopMomentum"],
      "ApplyDimReg" -> OptionValue["ApplyDimReg"],
      "BasisFamily" -> OptionValue["BasisFamily"],
      "BasisRoot" -> OptionValue["BasisRoot"],
      "GenerateMissingBases" -> OptionValue["GenerateMissingBases"],
      "ReturnDiagnostics" -> OptionValue["ReturnDiagnostics"],
      "DetailedTimingDiagnostics" -> OptionValue["DetailedTimingDiagnostics"],
      "Component" -> OptionValue["Component"],
      "PrintIntermediateSteps" -> OptionValue["PrintIntermediateSteps"]
    |>
  ];

Options[BuildAndIntegrateAntenna] =
  Options[IntegrateAntenna];

(* IntegrateAntenna[obj_AntennaObject, ...]
   ========================================
   Legacy implementation retained temporarily for reference while the public
   entry point delegates to IntegrateRouteObject below. *)
LegacyIntegrateAntennaObjectImplementation[obj_AntennaObject, OptionsPattern[]] :=
  Module[{data, key, profile, contributionInput, contribution,
     componentInput, componentName, storedComponent, backend, antenna,
     diagnostics, output, ibpResult,
     backendDiagnostics = <||>, rawIntegrated, tTerms, finalIntegrated,
     selectedIntegrated, expansionOrder, leadingCall, subleadingCall,
     nfCall, breveCall, leadingResult, subleadingResult, nfResult,
     breveResult, leadingDiag, subleadingDiag, nfDiag, breveDiag,
     treeDiags, intermediateSteps, collectedSteps, useStored, storeStored,
     refreshStored, cacheKey, cacheLabel, cacheRoot, loaded, computed,
     computedResult, computedDiagnostics, optionsAssoc, recordStages,
     recordMetadata, diagnosticsWithMetadata, ibpNeedsDiagnostics,
     quarkMassOpt, publicResult, publicDiagnostics},
    Return[
      IntegrateRouteObject[
        obj,
        <|
          "ApplyFeynCalcMS" -> OptionValue["ApplyFeynCalcMS"],
          "quarkMass" -> OptionValue["quarkMass"],
          "PaVeEvaluation" -> OptionValue["PaVeEvaluation"],
          "ExpansionOrder" -> OptionValue["ExpansionOrder"],
          "KinematicScale" -> OptionValue["KinematicScale"],
          "NormalizeKinematicScale" -> OptionValue["NormalizeKinematicScale"],
          "ReturnDiagnostics" -> OptionValue["ReturnDiagnostics"],
          "ReturnRecord" -> OptionValue["ReturnRecord"],
          "ReturnMasterCombination" -> OptionValue["ReturnMasterCombination"],
          "LoopMomentum" -> OptionValue["LoopMomentum"],
          "ApplyDimReg" -> OptionValue["ApplyDimReg"],
          "BasisFamily" -> OptionValue["BasisFamily"],
          "BasisRoot" -> OptionValue["BasisRoot"],
          "GenerateMissingBases" -> OptionValue["GenerateMissingBases"],
          "ReturnTTerms" -> OptionValue["ReturnTTerms"],
          "IntermediateSteps" -> OptionValue["IntermediateSteps"],
          "PrintIntermediateSteps" -> OptionValue["PrintIntermediateSteps"],
          "DetailedTimingDiagnostics" -> OptionValue[
            "DetailedTimingDiagnostics"],
          "UseStoredResults" -> OptionValue["UseStoredResults"],
          "StoreResults" -> OptionValue["StoreResults"],
          "ResultsCacheRoot" -> OptionValue["ResultsCacheRoot"],
          "RefreshStoredResults" -> OptionValue["RefreshStoredResults"],
          "Component" -> OptionValue["Component"],
          "RouteKind" -> "IntegrateAntenna"
        |>
      ]
    ];
    If[!AntennaObjectQ[obj],
      diagnostics = <|"Failed" -> True, "Reason" -> "InvalidAntennaObject"|>;
      Return[
        FormatFreshIntegrationReturn[$Failed, diagnostics, OptionValue[
            "ReturnDiagnostics"], OptionValue["ReturnRecord"], {}, False,
          "IntegrateAntenna",
          CollectIntegrationRecordStages[Missing["NotAvailable"], $Failed,
            $Failed, $Failed, $Failed, <||>, diagnostics]]
      ]
    ];
    data = AntennaObjectData[obj];
    intermediateSteps = NormalizeIntermediateSteps[OptionValue[
      "IntermediateSteps"]];
    useStored = TrueQ[OptionValue["UseStoredResults"]];
    storeStored = TrueQ[OptionValue["StoreResults"]];
    refreshStored = TrueQ[OptionValue["RefreshStoredResults"]];
    optionsAssoc = <|
      "ApplyFeynCalcMS" -> OptionValue["ApplyFeynCalcMS"],
      "quarkMass" -> OptionValue["quarkMass"],
      "PaVeEvaluation" -> OptionValue["PaVeEvaluation"],
      "ExpansionOrder" -> OptionValue["ExpansionOrder"],
      "KinematicScale" -> OptionValue["KinematicScale"],
      "NormalizeKinematicScale" -> OptionValue["NormalizeKinematicScale"],
      "LoopMomentum" -> OptionValue["LoopMomentum"],
      "ApplyDimReg" -> OptionValue["ApplyDimReg"],
      "BasisFamily" -> OptionValue["BasisFamily"],
      "BasisRoot" -> OptionValue["BasisRoot"],
      "GenerateMissingBases" -> OptionValue["GenerateMissingBases"],
      "ReturnTTerms" -> OptionValue["ReturnTTerms"],
      "ReturnMasterCombination" -> OptionValue["ReturnMasterCombination"],
      "Component" -> OptionValue["Component"],
      "Contribution" -> OptionValue["Contribution"],
      "DetailedTimingDiagnostics" -> OptionValue[
        "DetailedTimingDiagnostics"]
    |>;
    key = Lookup[data, "Key", Missing["UnknownKey"]];
    recordMetadata =
      <|"Key" -> key, "SelectedComponent" -> OptionValue["Component"],
        "Contribution" -> OptionValue["Contribution"], "SourceObject" -> obj,
        "AntennaObject" -> obj|>;
    If[key === Missing["UnknownKey"],
      diagnostics = <|"Failed" -> True,
        "Reason" -> "MissingAntennaObjectKey", "SourceObject" -> obj,
        "AntennaObject" -> obj|>;
      Return[
        FormatFreshIntegrationReturn[$Failed, diagnostics, OptionValue[
            "ReturnDiagnostics"], OptionValue["ReturnRecord"], {}, False,
          "IntegrateAntenna",
          CollectIntegrationRecordStages[obj, $Failed, $Failed, $Failed,
            $Failed, <||>, diagnostics], recordMetadata]
      ]
    ];
    If[!TrueQ[$AntennaPipelineBypassStoredResults] &&
        StoredResultsEnabledQ[useStored, storeStored, refreshStored],
      cacheKey = IntegrateAntennaStoredResultKey[obj, optionsAssoc];
      cacheLabel = IntegrateAntennaStoredResultLabel[obj, optionsAssoc];
      cacheRoot = OptionValue["ResultsCacheRoot"];
      If[!refreshStored && useStored,
        loaded = LoadStoredResultEntry["IntegrateAntenna", cacheKey,
          cacheRoot, cacheLabel];
        If[AssociationQ[loaded],
          PrintStoredResultHit[cacheLabel];
          {publicResult, publicDiagnostics} =
            ResolveIntegrationPublicResult[
              loaded["Result"],
              loaded["Diagnostics"],
              OptionValue["ReturnMasterCombination"],
              ToString[key, InputForm]
            ];
          Return[
            FormatStoredResultReturn[publicResult,
              publicDiagnostics, loaded, OptionValue[
                "ReturnDiagnostics"], OptionValue["ReturnRecord"],
              intermediateSteps, OptionValue["PrintIntermediateSteps"],
              "IntegrateAntenna", recordMetadata]
          ]
        ]
      ];
      computed =
        Block[{$AntennaPipelineBypassStoredResults = True},
          IntegrateAntenna[obj,
            ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
            quarkMass -> OptionValue["quarkMass"],
            PaVeEvaluation -> OptionValue["PaVeEvaluation"],
            ExpansionOrder -> OptionValue["ExpansionOrder"],
            KinematicScale -> OptionValue["KinematicScale"],
            NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
            ReturnDiagnostics -> True,
            LoopMomentum -> OptionValue["LoopMomentum"],
            ApplyDimReg -> OptionValue["ApplyDimReg"],
            BasisFamily -> OptionValue["BasisFamily"],
            BasisRoot -> OptionValue["BasisRoot"],
            GenerateMissingBases -> OptionValue["GenerateMissingBases"],
            ReturnTTerms -> OptionValue["ReturnTTerms"],
            IntermediateSteps -> IntegrationRecordStepLabels[],
            PrintIntermediateSteps -> OptionValue["PrintIntermediateSteps"],
            DetailedTimingDiagnostics -> OptionValue[
              "DetailedTimingDiagnostics"],
            UseStoredResults -> False,
            StoreResults -> False,
            ResultsCacheRoot -> cacheRoot,
            RefreshStoredResults -> False,
            Component -> OptionValue["Component"],
            Contribution -> OptionValue["Contribution"]]
        ];
      If[!MatchQ[computed, {_, _Association}],
        Return[computed]
      ];
      {computedResult, computedDiagnostics} = computed;
      If[computedResult =!= $Failed && (storeStored || refreshStored),
        StoreStoredResultEntry["IntegrateAntenna", cacheKey, cacheRoot,
          cacheLabel, computedResult, computedDiagnostics]
      ];
      {publicResult, publicDiagnostics} =
        ResolveIntegrationPublicResult[
          computedResult,
          computedDiagnostics,
          OptionValue["ReturnMasterCombination"],
          ToString[key, InputForm]
        ];
      Return[
        FormatFreshIntegrationReturn[publicResult, publicDiagnostics,
          OptionValue["ReturnDiagnostics"], OptionValue["ReturnRecord"],
          intermediateSteps, OptionValue["PrintIntermediateSteps"],
          "IntegrateAntenna", Automatic, recordMetadata]
      ]
    ];
    quarkMassOpt = OptionValue["quarkMass"];
    MaybeWarnHeavyIntegrationRoute[key, Lookup[data, "SelectedComponent", All],
      Lookup[data, "Contribution", All]];
    profile = AntennaIntegrationProfile[key];
    If[MassiveA30ResolvedRouteQ[key, <|"quarkMass" -> quarkMassOpt|>],
      profile = Join[profile, <|"BasisFamily" -> "MX30",
        "MassSymbol" -> quarkMassOpt|>]
    ];
    contributionInput =
      If[OptionValue["Contribution"] === All,
        Lookup[data, "Contribution", All]
        ,
        OptionValue["Contribution"]
      ];
    contribution = CanonicalAntennaComponentName[contributionInput];
    componentInput =
      If[OptionValue["Component"] === All,
        Lookup[data, "SelectedComponent", All]
        ,
        OptionValue["Component"]
      ];
    componentName = CanonicalAntennaComponentName[componentInput];
    If[MatchQ[key, {a_Symbol /; SymbolName[a] === "A", 2, 2}] &&
        contribution === "OneLoopSelf",
      profile = Join[profile, <|"BasisFamily" -> "A22OneLoopSelf",
          "ImplementationStatus" -> "ExperimentalOneLoopSelfOnly"|>]
    ];
    If[MatchQ[key, {a_Symbol /; SymbolName[a] === "A", 2, 2}] &&
        contribution === "TwoLoopTree",
      profile = Join[profile, <|"BasisFamily" -> "A22TwoLoopTree",
          "ImplementationStatus" -> "ExperimentalTwoLoopTree"|>]
    ];
    expansionOrder =
      If[OptionValue["ExpansionOrder"] === Automatic,
        Lookup[profile, "ExpansionOrder", 2]
        ,
        OptionValue["ExpansionOrder"]
      ];
    If[MassiveA30ResolvedRouteQ[key, <|"quarkMass" -> quarkMassOpt|>] &&
        TrueQ[OptionValue["ReturnMasterCombination"]] &&
        !TrueQ[$MassiveA30ForceIBPMasterRoute],
      Return[
        Block[
          {
            $MassiveA30ForceIBPMasterRoute = True,
            $AntennaPipelineBypassStoredResults = True
          },
          IntegrateAntenna[obj,
            ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
            quarkMass -> OptionValue["quarkMass"],
            PaVeEvaluation -> OptionValue["PaVeEvaluation"],
            ExpansionOrder -> OptionValue["ExpansionOrder"],
            KinematicScale -> OptionValue["KinematicScale"],
            NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
            ReturnDiagnostics -> OptionValue["ReturnDiagnostics"],
            ReturnRecord -> OptionValue["ReturnRecord"],
            ReturnMasterCombination -> True,
            LoopMomentum -> OptionValue["LoopMomentum"],
            ApplyDimReg -> OptionValue["ApplyDimReg"],
            BasisFamily -> OptionValue["BasisFamily"],
            BasisRoot -> OptionValue["BasisRoot"],
            GenerateMissingBases -> OptionValue["GenerateMissingBases"],
            ReturnTTerms -> OptionValue["ReturnTTerms"],
            IntermediateSteps -> OptionValue["IntermediateSteps"],
            PrintIntermediateSteps -> OptionValue["PrintIntermediateSteps"],
            DetailedTimingDiagnostics -> OptionValue[
              "DetailedTimingDiagnostics"],
            UseStoredResults -> False,
            StoreResults -> False,
            ResultsCacheRoot -> OptionValue["ResultsCacheRoot"],
            RefreshStoredResults -> False,
            Component -> OptionValue["Component"],
            Contribution -> OptionValue["Contribution"]]
        ]
      ]
    ];
    If[MassiveA30ResolvedRouteQ[key, <|"quarkMass" -> quarkMassOpt|>] &&
        !TrueQ[$MassiveA30ForceIBPMasterRoute],
      Module[{routeData, antennaLocal, openMasterBackendDiagnostics},
        antennaLocal = Lookup[data, "Antenna", $Failed];
        routeData =
          MassiveA30IntegratedRouteData[
            quarkMassOpt,
            expansionOrder,
            OptionValue["NormalizeKinematicScale"],
            profile
          ];
        rawIntegrated = routeData["RawIntegrated"];
        tTerms = routeData["TTerms"];
        finalIntegrated = routeData["FinalIntegrated"];
        selectedIntegrated = routeData["SelectedIntegrated"];
        backendDiagnostics = routeData["BackendDiagnostics"];
        diagnostics = routeData["Diagnostics"];
        openMasterBackendDiagnostics =
          MassiveA30OpenMasterBackendDiagnostics[obj, optionsAssoc,
            "IntegrateAntenna"];
        If[AssociationQ[openMasterBackendDiagnostics] &&
            Length[openMasterBackendDiagnostics] > 0,
          backendDiagnostics = Join[backendDiagnostics,
            openMasterBackendDiagnostics];
          diagnostics = Join[diagnostics, <|
              "BackendDiagnostics" -> backendDiagnostics,
              "OpenMasterRouteAvailable" -> True|>]
        ];
        collectedSteps = CollectIntegrationIntermediateSteps[antennaLocal,
          rawIntegrated, tTerms, finalIntegrated, selectedIntegrated,
          backendDiagnostics, diagnostics, intermediateSteps];
        diagnosticsWithMetadata =
          Join[diagnostics, <|"SelectedComponent" -> componentInput,
              "BuildComponent" -> storedComponent, "RawIntegrated" ->
               rawIntegrated, "TTerms" -> tTerms, "SourceObject" -> obj,
              "AntennaObject" -> obj|>,
            If[Length[collectedSteps] > 0,
              <|"IntermediateSteps" -> collectedSteps|>,
              <||>
            ]];
        recordStages = CollectIntegrationRecordStages[antennaLocal,
          rawIntegrated, tTerms, finalIntegrated, selectedIntegrated,
          backendDiagnostics, diagnosticsWithMetadata];
        {publicResult, publicDiagnostics} =
          If[TrueQ[OptionValue["ReturnMasterCombination"]],
            ResolveIntegrationPublicResult[
              selectedIntegrated,
              diagnosticsWithMetadata,
              True,
              ToString[key, InputForm]
            ]
            ,
            MassiveA30DefaultMasterEndpointResult[
              obj,
              optionsAssoc,
              "IntegrateAntenna",
              selectedIntegrated,
              diagnosticsWithMetadata,
              ToString[key, InputForm]
            ]
          ];
        Return[
          FormatFreshIntegrationReturn[publicResult,
            publicDiagnostics, OptionValue["ReturnDiagnostics"],
            OptionValue["ReturnRecord"], intermediateSteps, OptionValue[
              "PrintIntermediateSteps"], "IntegrateAntenna", recordStages,
            recordMetadata]
        ]
      ]
    ];
    If[MatchQ[key, {a_Symbol /; SymbolName[a] === "A", 2, 2}] &&
        contribution === "All",
      Switch[componentName,
        "Leading" | "Subleading" | "Nf",
          Return[
            IntegrateAntenna[
              AntennaObjectWithSelection[obj, componentInput, TwoLoopTree],
              ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
              quarkMass -> OptionValue["quarkMass"],
              PaVeEvaluation -> OptionValue["PaVeEvaluation"],
              ExpansionOrder -> OptionValue["ExpansionOrder"],
              KinematicScale -> OptionValue["KinematicScale"],
              NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
              ReturnDiagnostics -> OptionValue["ReturnDiagnostics"],
              ReturnRecord -> OptionValue["ReturnRecord"],
              LoopMomentum -> OptionValue["LoopMomentum"],
              ApplyDimReg -> OptionValue["ApplyDimReg"],
              BasisFamily -> OptionValue["BasisFamily"],
              BasisRoot -> OptionValue["BasisRoot"],
              GenerateMissingBases -> OptionValue["GenerateMissingBases"],
              ReturnTTerms -> OptionValue["ReturnTTerms"],
              IntermediateSteps -> OptionValue["IntermediateSteps"],
              PrintIntermediateSteps -> OptionValue["PrintIntermediateSteps"],
              DetailedTimingDiagnostics -> OptionValue[
                "DetailedTimingDiagnostics"],
              Component -> All,
              Contribution -> TwoLoopTree]
          ]
        ,
        "Breve",
          Return[
            IntegrateAntenna[
              AntennaObjectWithSelection[obj, Breve, OneLoopSelf],
              ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
              quarkMass -> OptionValue["quarkMass"],
              PaVeEvaluation -> OptionValue["PaVeEvaluation"],
              ExpansionOrder -> OptionValue["ExpansionOrder"],
              KinematicScale -> OptionValue["KinematicScale"],
              NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
              ReturnDiagnostics -> OptionValue["ReturnDiagnostics"],
              ReturnRecord -> OptionValue["ReturnRecord"],
              LoopMomentum -> OptionValue["LoopMomentum"],
              ApplyDimReg -> OptionValue["ApplyDimReg"],
              BasisFamily -> OptionValue["BasisFamily"],
              BasisRoot -> OptionValue["BasisRoot"],
              GenerateMissingBases -> OptionValue["GenerateMissingBases"],
              ReturnTTerms -> OptionValue["ReturnTTerms"],
              IntermediateSteps -> OptionValue["IntermediateSteps"],
              PrintIntermediateSteps -> OptionValue["PrintIntermediateSteps"],
              DetailedTimingDiagnostics -> OptionValue[
                "DetailedTimingDiagnostics"],
              Component -> All,
              Contribution -> OneLoopSelf]
          ]
        ,
        "All",
          leadingCall =
            IntegrateAntenna[
              AntennaObjectWithSelection[obj, Leading, TwoLoopTree],
              ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
              quarkMass -> OptionValue["quarkMass"],
              PaVeEvaluation -> OptionValue["PaVeEvaluation"],
              ExpansionOrder -> OptionValue["ExpansionOrder"],
              KinematicScale -> OptionValue["KinematicScale"],
              NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
              ReturnDiagnostics -> True,
              LoopMomentum -> OptionValue["LoopMomentum"],
              ApplyDimReg -> OptionValue["ApplyDimReg"],
              BasisFamily -> OptionValue["BasisFamily"],
              BasisRoot -> OptionValue["BasisRoot"],
              GenerateMissingBases -> OptionValue["GenerateMissingBases"],
              ReturnTTerms -> OptionValue["ReturnTTerms"],
              IntermediateSteps -> OptionValue["IntermediateSteps"],
              PrintIntermediateSteps -> OptionValue["PrintIntermediateSteps"],
              DetailedTimingDiagnostics -> OptionValue[
                "DetailedTimingDiagnostics"],
              Component -> All,
              Contribution -> TwoLoopTree];
          subleadingCall =
            IntegrateAntenna[
              AntennaObjectWithSelection[obj, Subleading, TwoLoopTree],
              ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
              quarkMass -> OptionValue["quarkMass"],
              PaVeEvaluation -> OptionValue["PaVeEvaluation"],
              ExpansionOrder -> OptionValue["ExpansionOrder"],
              KinematicScale -> OptionValue["KinematicScale"],
              NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
              ReturnDiagnostics -> True,
              LoopMomentum -> OptionValue["LoopMomentum"],
              ApplyDimReg -> OptionValue["ApplyDimReg"],
              BasisFamily -> OptionValue["BasisFamily"],
              BasisRoot -> OptionValue["BasisRoot"],
              GenerateMissingBases -> OptionValue["GenerateMissingBases"],
              ReturnTTerms -> OptionValue["ReturnTTerms"],
              IntermediateSteps -> OptionValue["IntermediateSteps"],
              PrintIntermediateSteps -> OptionValue["PrintIntermediateSteps"],
              DetailedTimingDiagnostics -> OptionValue[
                "DetailedTimingDiagnostics"],
              Component -> All,
              Contribution -> TwoLoopTree];
          nfCall =
            IntegrateAntenna[
              AntennaObjectWithSelection[obj, Nf, TwoLoopTree],
              ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
              quarkMass -> OptionValue["quarkMass"],
              PaVeEvaluation -> OptionValue["PaVeEvaluation"],
              ExpansionOrder -> OptionValue["ExpansionOrder"],
              KinematicScale -> OptionValue["KinematicScale"],
              NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
              ReturnDiagnostics -> True,
              LoopMomentum -> OptionValue["LoopMomentum"],
              ApplyDimReg -> OptionValue["ApplyDimReg"],
              BasisFamily -> OptionValue["BasisFamily"],
              BasisRoot -> OptionValue["BasisRoot"],
              GenerateMissingBases -> OptionValue["GenerateMissingBases"],
              ReturnTTerms -> OptionValue["ReturnTTerms"],
              IntermediateSteps -> OptionValue["IntermediateSteps"],
              PrintIntermediateSteps -> OptionValue["PrintIntermediateSteps"],
              DetailedTimingDiagnostics -> OptionValue[
                "DetailedTimingDiagnostics"],
              Component -> All,
              Contribution -> TwoLoopTree];
          breveCall =
            IntegrateAntenna[
              AntennaObjectWithSelection[obj, Breve, OneLoopSelf],
              ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
              quarkMass -> OptionValue["quarkMass"],
              PaVeEvaluation -> OptionValue["PaVeEvaluation"],
              ExpansionOrder -> OptionValue["ExpansionOrder"],
              KinematicScale -> OptionValue["KinematicScale"],
              NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
              ReturnDiagnostics -> True,
              LoopMomentum -> OptionValue["LoopMomentum"],
              ApplyDimReg -> OptionValue["ApplyDimReg"],
              BasisFamily -> OptionValue["BasisFamily"],
              BasisRoot -> OptionValue["BasisRoot"],
              GenerateMissingBases -> OptionValue["GenerateMissingBases"],
              ReturnTTerms -> OptionValue["ReturnTTerms"],
              IntermediateSteps -> OptionValue["IntermediateSteps"],
              PrintIntermediateSteps -> OptionValue["PrintIntermediateSteps"],
              DetailedTimingDiagnostics -> OptionValue[
                "DetailedTimingDiagnostics"],
              Component -> All,
              Contribution -> OneLoopSelf];
          {leadingResult, leadingDiag} = leadingCall;
          {subleadingResult, subleadingDiag} = subleadingCall;
          {nfResult, nfDiag} = nfCall;
          {breveResult, breveDiag} = breveCall;
          If[MemberQ[{leadingResult, subleadingResult, nfResult, breveResult},
              $Failed],
            diagnosticsWithMetadata =
              <|"Failed" -> True,
                "Reason" -> "A22CombinedContributionIntegrationFailed",
                "ComponentDiagnostics" -> <|"TwoLoopTree" -> <|
                    "Leading" -> leadingDiag,
                    "Subleading" -> subleadingDiag,
                    "Nf" -> nfDiag|>,
                  "OneLoopSelf" -> breveDiag|>, "SourceObject" -> obj,
                "AntennaObject" -> obj|>;
            Return[
              FormatFreshIntegrationReturn[$Failed, diagnosticsWithMetadata,
                OptionValue["ReturnDiagnostics"], OptionValue[
                  "ReturnRecord"], intermediateSteps, OptionValue[
                  "PrintIntermediateSteps"], "IntegrateAntenna",
                CollectIntegrationRecordStages[Lookup[data, "Antenna",
                    $Failed], $Failed, $Failed, $Failed, $Failed,
                  <|"TwoLoopTree" -> <|"Leading" -> leadingDiag,
                      "Subleading" -> subleadingDiag, "Nf" -> nfDiag|>,
                    "OneLoopSelf" -> breveDiag|>, diagnosticsWithMetadata],
                recordMetadata]
            ]
          ];
          finalIntegrated = A22CombineIntegratedResults[
            {leadingResult, subleadingResult, nfResult}, breveResult];
          treeDiags = <|"Leading" -> leadingDiag,
            "Subleading" -> subleadingDiag, "Nf" -> nfDiag|>;
          diagnostics = A22CombineIntegratedComponentDiagnostics[
            treeDiags, breveDiag, finalIntegrated, componentInput,
            OptionValue["ReturnTTerms"]];
          diagnosticsWithMetadata =
            Join[diagnostics, <|"SourceObject" -> obj,
                "AntennaObject" -> obj|>];
          recordStages = CollectIntegrationRecordStages[
            Lookup[data, "Antenna", $Failed],
            Lookup[diagnostics, "RawIntegrated", Missing["NotAvailable"]],
            Lookup[diagnostics, "TTerms", Missing["NotAvailable"]],
            finalIntegrated, finalIntegrated,
            <|"TwoLoopTree" -> treeDiags, "OneLoopSelf" -> breveDiag|>,
            diagnosticsWithMetadata];
          {publicResult, publicDiagnostics} =
            ResolveIntegrationPublicResult[
              finalIntegrated,
              diagnosticsWithMetadata,
              OptionValue["ReturnMasterCombination"],
              ToString[key, InputForm]
            ];
          Return[
            FormatFreshIntegrationReturn[publicResult,
              publicDiagnostics, OptionValue["ReturnDiagnostics"],
              OptionValue["ReturnRecord"], intermediateSteps, OptionValue[
                "PrintIntermediateSteps"], "IntegrateAntenna", recordStages,
              recordMetadata]
          ]
      ]
    ];
    If[Lookup[profile, "ImplementationStatus", "Implemented"] ===
        "ScaffoldOnly" &&
        Lookup[profile, "BasisFamily", Missing["NoFamily"]] =!= "MX30",
      diagnostics = <|"Failed" -> True,
        "Reason" -> "IntegratedAntennaNotImplemented",
        "Profile" -> profile, "Contribution" -> contributionInput|>;
      Return[
        FormatFreshIntegrationReturn[$Failed,
          Join[diagnostics, <|"SourceObject" -> obj,
              "AntennaObject" -> obj|>], OptionValue[
            "ReturnDiagnostics"], OptionValue["ReturnRecord"],
          intermediateSteps, OptionValue["PrintIntermediateSteps"],
          "IntegrateAntenna",
          CollectIntegrationRecordStages[Lookup[data, "Antenna", $Failed],
            $Failed, $Failed, $Failed, $Failed, <||>, diagnostics],
          recordMetadata]
      ]
    ];
    backend = profile["DefaultBackend"];
    storedComponent = Lookup[data, "SelectedComponent", All];
    antenna = Lookup[data, "IntegrationAntenna", Lookup[data, "Antenna", $Failed]];
    ibpNeedsDiagnostics =
      TrueQ[OptionValue["ReturnDiagnostics"]] ||
      TrueQ[OptionValue["ReturnRecord"]] ||
      TrueQ[OptionValue["ReturnMasterCombination"]];
    rawIntegrated =
      Switch[backend,
        PaVe,
          IntegrateViaPaVe[antenna, profile, True, OptionValue[
            "ApplyFeynCalcMS"], OptionValue[
            "quarkMass"], PaVeEvaluation -> OptionValue["PaVeEvaluation"],
            ExpansionOrder -> expansionOrder, KinematicScale -> Lookup[
             profile, "KinematicScale", OptionValue["KinematicScale"]],
            NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"
             ], LoopMomentum -> OptionValue["LoopMomentum"], ApplyDimReg ->
             OptionValue["ApplyDimReg"]]
        ,
        IBP,
          ibpResult =
            IntegrateViaIBP[antenna, NumFinalParticles -> key[[2]],
              NumLoops -> key[[3]], BasisFamily -> If[OptionValue[
               "BasisFamily"] === Automatic, Lookup[profile, "BasisFamily",
                Automatic], OptionValue["BasisFamily"]], BasisRoot ->
               OptionValue["BasisRoot"], GenerateMissingBases -> OptionValue[
                "GenerateMissingBases"], ExpansionOrder -> expansionOrder,
              ReturnDiagnostics -> ibpNeedsDiagnostics,
              DetailedTimingDiagnostics -> OptionValue[
                "DetailedTimingDiagnostics"], MassSymbol -> Lookup[profile,
                "MassSymbol", Automatic], ApplyFeynCalcMS ->
               OptionValue["ApplyFeynCalcMS"], KinematicScale -> Lookup[
                profile, "KinematicScale", OptionValue["KinematicScale"]],
               NormalizeKinematicScale ->
               OptionValue["NormalizeKinematicScale"]];
          If[TrueQ[ibpNeedsDiagnostics],
            backendDiagnostics = ibpResult[[2]];
            ibpResult[[1]]
            ,
            backendDiagnostics = <||>;
            ibpResult
          ]
        ,
        _,
          Print["Unsupported integration backend for antenna ", key, ": ",
             backend, ". Aborting..."];
          $Failed
      ];
    tTerms =
      If[rawIntegrated === $Failed,
        $Failed
        ,
        IntegratedAntennaTTerms[key, rawIntegrated, ExpansionOrder ->
          expansionOrder, Component -> storedComponent]
      ];
    finalIntegrated =
      If[rawIntegrated === $Failed,
        $Failed
        ,
        If[OptionValue["ReturnTTerms"] === True,
          tTerms
          ,
          ExtractIntegratedAntenna[key, tTerms, ExpansionOrder ->
            expansionOrder]
        ]
      ];
    selectedIntegrated =
      SelectAntennaComponent[finalIntegrated, key,
        If[storedComponent === All, componentInput, All]];
    diagnostics = Join[
      IntegratedAntennaDiagnostics[key, antenna, finalIntegrated, profile,
        <|"RawIntegrated" -> rawIntegrated, "TTerms" -> tTerms,
          "ReturnTTerms" -> OptionValue["ReturnTTerms"],
          "ExpansionOrder" -> expansionOrder, "SelectedComponent" ->
           componentInput, "BuildComponent" -> storedComponent|>],
      If[rawIntegrated === $Failed && AssociationQ[backendDiagnostics] &&
          KeyExistsQ[backendDiagnostics, "Reason"],
        <|"Failed" -> True, "Reason" -> backendDiagnostics["Reason"]|>
        ,
        <||>
      ],
      If[AssociationQ[backendDiagnostics] && Length[backendDiagnostics] >
          0,
        <|"BackendDiagnostics" -> backendDiagnostics|>
        ,
        <||>
      ]
    ];
    collectedSteps = CollectIntegrationIntermediateSteps[antenna,
      rawIntegrated, tTerms, finalIntegrated, selectedIntegrated,
      backendDiagnostics, diagnostics, intermediateSteps];
    diagnosticsWithMetadata =
      Join[diagnostics, <|"SelectedComponent" -> componentInput,
          "BuildComponent" -> storedComponent, "RawIntegrated" ->
           rawIntegrated, "TTerms" -> tTerms, "SourceObject" -> obj,
          "AntennaObject" -> obj|>,
        If[Length[collectedSteps] > 0,
          <|"IntermediateSteps" -> collectedSteps|>,
          <||>
        ]];
    recordStages = CollectIntegrationRecordStages[antenna, rawIntegrated,
      tTerms, finalIntegrated, selectedIntegrated, backendDiagnostics,
      diagnosticsWithMetadata];
    {publicResult, publicDiagnostics} =
      ResolveIntegrationPublicResult[
        selectedIntegrated,
        diagnosticsWithMetadata,
        OptionValue["ReturnMasterCombination"],
        ToString[key, InputForm]
      ];
    output = FormatFreshIntegrationReturn[publicResult,
      publicDiagnostics, OptionValue["ReturnDiagnostics"], OptionValue[
        "ReturnRecord"], intermediateSteps, OptionValue[
        "PrintIntermediateSteps"], "IntegrateAntenna", recordStages,
      recordMetadata];
    output
  ];

(* BuildAndIntegrateAntenna[type, n, loopOrder, ...]
   =================================================
   One-shot public route that builds an antenna object and integrates it in one
   call. *)
BuildAndIntegrateAntenna[type_, numFinalParticles_Integer, loopOrder_Integer,
   OptionsPattern[]] :=
  BuildAndIntegrateRouteResult[
    type,
    numFinalParticles,
    loopOrder,
    <|
      "ApplyFeynCalcMS" -> OptionValue["ApplyFeynCalcMS"],
      "quarkMass" -> OptionValue["quarkMass"],
      "ExpansionOrder" -> OptionValue["ExpansionOrder"],
      "KinematicScale" -> OptionValue["KinematicScale"],
      "NormalizeKinematicScale" -> OptionValue["NormalizeKinematicScale"],
      "ReturnDiagnostics" -> OptionValue["ReturnDiagnostics"],
      "ReturnRecord" -> OptionValue["ReturnRecord"],
      "ReturnMasterCombination" -> OptionValue["ReturnMasterCombination"],
      "LoopMomentum" -> OptionValue["LoopMomentum"],
      "ApplyDimReg" -> OptionValue["ApplyDimReg"],
      "BasisFamily" -> OptionValue["BasisFamily"],
      "BasisRoot" -> OptionValue["BasisRoot"],
      "GenerateMissingBases" -> OptionValue["GenerateMissingBases"],
      "ReturnTTerms" -> OptionValue["ReturnTTerms"],
      "IntermediateSteps" -> OptionValue["IntermediateSteps"],
      "PrintIntermediateSteps" -> OptionValue["PrintIntermediateSteps"],
      "PrintComponentLegend" -> OptionValue["PrintComponentLegend"],
      "DetailedTimingDiagnostics" -> OptionValue["DetailedTimingDiagnostics"],
      "UseStoredResults" -> OptionValue["UseStoredResults"],
      "StoreResults" -> OptionValue["StoreResults"],
      "ResultsCacheRoot" -> OptionValue["ResultsCacheRoot"],
      "RefreshStoredResults" -> OptionValue["RefreshStoredResults"],
      "Component" -> OptionValue["Component"]
    |>
  ];

Options[LegacyIntegrateAntenna] =
  Options[BuildAndIntegrateAntenna];

LegacyIntegrateAntenna[type_, numFinalParticles_Integer, loopOrder_Integer,
   OptionsPattern[]] :=
  BuildAndIntegrateAntenna[type, numFinalParticles, loopOrder,
    ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
    quarkMass -> OptionValue["quarkMass"],
    PaVeEvaluation -> OptionValue["PaVeEvaluation"],
    ExpansionOrder -> OptionValue["ExpansionOrder"],
    KinematicScale -> OptionValue["KinematicScale"],
    NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
    ReturnDiagnostics -> OptionValue["ReturnDiagnostics"],
    ReturnMasterCombination -> OptionValue["ReturnMasterCombination"],
    LoopMomentum -> OptionValue["LoopMomentum"],
    ApplyDimReg -> OptionValue["ApplyDimReg"],
    BasisFamily -> OptionValue["BasisFamily"],
    BasisRoot -> OptionValue["BasisRoot"],
    GenerateMissingBases -> OptionValue["GenerateMissingBases"],
    ReturnTTerms -> OptionValue["ReturnTTerms"],
    IntermediateSteps -> OptionValue["IntermediateSteps"],
    PrintIntermediateSteps -> OptionValue["PrintIntermediateSteps"],
    DetailedTimingDiagnostics -> OptionValue["DetailedTimingDiagnostics"],
    UseStoredResults -> OptionValue["UseStoredResults"],
    StoreResults -> OptionValue["StoreResults"],
    ResultsCacheRoot -> OptionValue["ResultsCacheRoot"],
    RefreshStoredResults -> OptionValue["RefreshStoredResults"],
    Component -> OptionValue["Component"]];

(* IntegratedAntennaDiagnostics[key, unintegrated, integrated, profile, context]
   =============================================================================
   Construct the standard diagnostics association for integrated routes,
   including paper checks where reliable targets are available. *)
IntegratedAntennaDiagnostics[key_, unintegrated_, integrated_, profile_Association,
   context_:<||>] :=
  Module[{paVeTarget, integratedTarget, integratedResidual, diagnostics,
     expansionOrder, tTerms, tTargets, antennaTargets, tResiduals,
     antennaResiduals, tTargetComparisons, antennaTargetComparisons,
     a22Component, a22ComponentName},
    expansionOrder = Lookup[context, "ExpansionOrder", Lookup[profile,
       "ExpansionOrder", 2]];
    diagnostics =
      Switch[key,
        {a_Symbol /; SymbolName[a] === "A", 2, 1},
          paVeTarget = A21PaperPaVe /. D -> 4 - 2 Epsilon;
          (* The public result is deliberately truncated at the requested
             expansion order.  Compare it to the target in that same
             convention; comparing an O(eps^0) route to the target through
             O(eps^2) would turn omitted higher-order terms into a false
             validation failure. *)
          integratedTarget = IntegratedAntennaSeries[A21IntegratedPaper,
            expansionOrder];
          integratedResidual =
            integrated - integratedTarget //
            FunctionExpand //
            FullSimplify;
          <|"PaVeResidualIsZero" -> TrueQ[Simplify[unintegrated -
              paVeTarget] === 0], "IntegratedResidualIsZero" -> TrueQ[
             integratedResidual === 0], "IntegratedResidual" ->
            integratedResidual, "Profile" -> profile|>
        ,
        {a_Symbol /; SymbolName[a] === "A", 3, 0},
          (* The public A30 route may return a deeper series, but the external
             reference retained here is published/encoded only through the
             finite term. Compare at that evidence depth rather than treating
             unreferenced positive-epsilon coefficients as a disagreement. *)
          integratedTarget = 1/FeynCalc`Epsilon^2 + 3/(2 FeynCalc`Epsilon
            ) + 19/4 - 7 Pi^2/12;
          integratedResidual =
            IntegratedAntennaSeries[integrated, 0] - integratedTarget //
            FunctionExpand //
            FullSimplify;
          <|"IntegratedResidualIsZero" -> TrueQ[integratedResidual ===
             0], "IntegratedResidual" -> integratedResidual,
            "ReturnedExpansionOrder" -> expansionOrder,
            "ValidationExpansionOrder" -> 0,
            "Profile" -> profile|>
        ,
        {a_Symbol /; SymbolName[a] === "A", 4, 0},
          <|"IntegratedBackendAvailable" -> True,
            "FinalAntennaExtractionImplemented" -> True,
            "IntegratedComponentOrder" -> {Leading, Subleading},
            "PaperCheckAvailable" -> False,
            "Profile" -> profile|>
        ,
        {b_Symbol /; SymbolName[b] === "B", 4, 0},
          <|"IntegratedBackendAvailable" -> True,
            "FinalAntennaExtractionImplemented" -> True,
            "PaperCheckAvailable" -> False,
            "Profile" -> profile|>
        ,
        {c_Symbol /; SymbolName[c] === "C", 4, 0},
          <|"IntegratedBackendAvailable" -> True,
            "FinalAntennaExtractionImplemented" -> True,
            "PaperCheckAvailable" -> False,
            "Profile" -> profile|>
        ,
        {a_Symbol /; SymbolName[a] === "A", 3, 1},
          tTerms = Lookup[context, "TTerms", Missing["NotAvailable"]];
          tTargets = A31TTermTargets[expansionOrder];
          antennaTargets = A31IntegratedAntennaTargets[expansionOrder];
          tResiduals =
            If[ListQ[tTerms],
              A31IntegratedResiduals[tTerms, tTargets]
              ,
              If[tTerms === Missing["NotAvailable"],
                Missing["NotAvailable"]
                ,
                SafeIntegratedResidualSimplify[
                  tTerms - A31TTermTargetForComponent[
                    Lookup[context, "BuildComponent",
                      Lookup[context, "SelectedComponent", All]],
                    expansionOrder
                  ]
                ]
              ]
            ];
          tTargetComparisons =
            If[ListQ[tTerms],
              AssociationThread[
                {"Leading", "Subleading", "Nf"},
                A31TargetResidualAssociation[#, tTargets]& /@ tTerms
              ]
              ,
              If[tTerms === Missing["NotAvailable"],
                Missing["NotAvailable"]
                ,
                A31TargetResidualAssociation[tTerms, tTargets]
              ]
            ];
          antennaResiduals =
            If[Lookup[context, "ReturnTTerms", False] === True,
              Missing["NotAvailable"]
              ,
              If[ListQ[integrated],
                A31IntegratedResiduals[integrated, antennaTargets]
                ,
                SafeIntegratedResidualSimplify[
                  integrated - A31IntegratedAntennaTargetForComponent[
                    Lookup[context, "BuildComponent",
                      Lookup[context, "SelectedComponent", All]],
                    expansionOrder
                  ]
                ]
              ]
            ];
          antennaTargetComparisons =
            If[Lookup[context, "ReturnTTerms", False] === True,
              Missing["NotAvailable"]
              ,
              If[ListQ[integrated],
                AssociationThread[
                  {"Leading", "Subleading", "Nf"},
                  A31TargetResidualAssociation[#, antennaTargets]& /@
                    integrated
                ]
                ,
                A31TargetResidualAssociation[integrated, antennaTargets]
              ]
            ];
          <|"TTermResiduals" -> tResiduals, "TTermResidualsAreZero" ->
            IntegratedResidualListZeroQ[tResiduals],
            "TTermTargetComparisonResiduals" -> tTargetComparisons,
            "IntegratedAntennaResiduals" -> antennaResiduals,
            "IntegratedTargetComparisonResiduals" ->
              antennaTargetComparisons,
            "IntegratedAntennaResidualsAreZero" ->
              IntegratedResidualListZeroQ[antennaResiduals],
            "Profile" -> profile|>
        ,
        {a_Symbol /; SymbolName[a] === "A", 2, 2},
          tTerms = Lookup[context, "TTerms", Missing["NotAvailable"]];
          (* A selected A22 AntennaObject retains the full build payload.  Its
             unavailable sibling contributions must not be compared to public
             targets when the caller requested one component. *)
          a22Component = Lookup[context, "BuildComponent",
            Lookup[context, "SelectedComponent", All]];
          a22ComponentName = CanonicalAntennaComponentName[a22Component];
          tResiduals =
            If[ListQ[tTerms] && a22ComponentName =!= "All",
              A22TTermResiduals[
                SelectAntennaComponent[tTerms, key, a22Component],
                a22Component, expansionOrder]
              ,
              If[ListQ[tTerms],
                A22TTermResiduals[tTerms, expansionOrder]
                ,
                If[tTerms === Missing["NotAvailable"],
                  Missing["NotAvailable"]
                  ,
                  A22TTermResiduals[tTerms, a22Component, expansionOrder]
                ]
              ]
            ];
          antennaResiduals =
            If[Lookup[context, "ReturnTTerms", False] === True,
              Missing["NotAvailable"]
              ,
              If[ListQ[integrated] && a22ComponentName =!= "All",
                A22IntegratedResiduals[
                  SelectAntennaComponent[integrated, key, a22Component],
                  a22Component, expansionOrder]
                ,
                If[ListQ[integrated],
                  A22IntegratedResiduals[integrated, expansionOrder]
                  ,
                  A22IntegratedResiduals[integrated, a22Component,
                    expansionOrder]
                ]
              ]
            ];
          <|"TTermResiduals" -> tResiduals,
            "TTermResidualsAreZero" ->
              (TrueQ[tResiduals === 0] || IntegratedResidualListZeroQ[tResiduals]),
            "TTermResidualIsZero" -> TrueQ[tResiduals === 0],
            "IntegratedAntennaResiduals" -> antennaResiduals,
            "IntegratedAntennaResidualsAreZero" ->
              (TrueQ[antennaResiduals === 0] || IntegratedResidualListZeroQ[antennaResiduals]),
            "IntegratedAntennaResidualIsZero" -> TrueQ[antennaResiduals === 0],
            "FinalAntennaExtractionImplemented" -> True,
            "Profile" -> profile|>
        ,
        _,
          <|"PaperCheckAvailable" -> False, "Profile" -> profile|>
      ];
    diagnostics
  ];

(*************************************************)
(* Canonical object integration boundary

   This definition deliberately appears after the legacy implementation above.
   The route-owned IntegrateRouteObject workflow is the authoritative public
   implementation for AntennaObject input.  In particular it retains the
   backend diagnostics from which ReturnMasterCombination is resolved.

   BuildAndIntegrateAntenna delegates to that same workflow after its
   BuildAntenna[..., IntegrableForm -> True] stage. *)
IntegrateAntenna[input:(_AntennaObject | {___AntennaObject}), OptionsPattern[]] :=
  With[
    {options = <|
      "ApplyFeynCalcMS" -> OptionValue["ApplyFeynCalcMS"],
      "quarkMass" -> OptionValue["quarkMass"],
      "ExpansionOrder" -> OptionValue["ExpansionOrder"],
      "KinematicScale" -> OptionValue["KinematicScale"],
      "NormalizeKinematicScale" -> OptionValue["NormalizeKinematicScale"],
      "ReturnDiagnostics" -> OptionValue["ReturnDiagnostics"],
      "ReturnRecord" -> OptionValue["ReturnRecord"],
      "ReturnMasterCombination" -> OptionValue["ReturnMasterCombination"],
      "LoopMomentum" -> OptionValue["LoopMomentum"],
      "ApplyDimReg" -> OptionValue["ApplyDimReg"],
      "BasisFamily" -> OptionValue["BasisFamily"],
      "BasisRoot" -> OptionValue["BasisRoot"],
      "GenerateMissingBases" -> OptionValue["GenerateMissingBases"],
      "ReturnTTerms" -> OptionValue["ReturnTTerms"],
      "IntermediateSteps" -> OptionValue["IntermediateSteps"],
      "PrintIntermediateSteps" -> OptionValue["PrintIntermediateSteps"],
      "PrintComponentLegend" -> OptionValue["PrintComponentLegend"],
      "DetailedTimingDiagnostics" -> OptionValue["DetailedTimingDiagnostics"],
      "UseStoredResults" -> OptionValue["UseStoredResults"],
      "StoreResults" -> OptionValue["StoreResults"],
      "ResultsCacheRoot" -> OptionValue["ResultsCacheRoot"],
      "RefreshStoredResults" -> OptionValue["RefreshStoredResults"],
      "Component" -> OptionValue["Component"],
      "RouteKind" -> "IntegrateAntenna"
    |>},
    If[ListQ[input],
      IntegrateRouteObject[#, options]& /@ input,
      IntegrateRouteObject[input, options]
    ]
  ];
