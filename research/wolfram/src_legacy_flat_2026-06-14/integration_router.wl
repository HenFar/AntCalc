(*************************************************)

(*
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

BuildAndIntegrateStoredResultKey::usage =
  "BuildAndIntegrateStoredResultKey[type, numFinalParticles, loopOrder, options] builds the cache key for a BuildAndIntegrateAntenna request.";

BuildAndIntegrateStoredResultLabel::usage =
  "BuildAndIntegrateStoredResultLabel[type, numFinalParticles, loopOrder, options] builds the human-readable cache label for a BuildAndIntegrateAntenna request.";

FormatFreshIntegrationReturn::usage =
  "FormatFreshIntegrationReturn[result, diagnostics, returnDiagnostics, returnRecord, requestedSteps, printSteps, routeKind, recordStages, metadata] formats a fresh integration result in the public return shape.";

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

Options[IntegrateAntenna] = {ApplyFeynCalcMS -> True, quarkMass -> 0,
   PaVeEvaluation -> "PaXEvaluate",
   ExpansionOrder -> Automatic, KinematicScale -> q2, NormalizeKinematicScale ->
    True, ReturnDiagnostics -> False, ReturnRecord -> False,
   LoopMomentum -> l, ApplyDimReg -> True, BasisFamily -> Automatic, BasisRoot -> Automatic,
   GenerateMissingBases -> False,
   ReturnTTerms -> False, Component -> All, Contribution -> All,
   IntermediateSteps -> {}, PrintIntermediateSteps -> False,
   DetailedTimingDiagnostics -> False,
   UseStoredResults -> False, StoreResults -> False,
   ResultsCacheRoot -> Automatic, RefreshStoredResults -> False};

IntegrateAntenna::heavy =
  "This route uses a heavy integration backend and may take a long time: `1`.";

IntegratedResidualListZeroQ[residuals_] :=
  ListQ[residuals] && And @@ (TrueQ[# === 0]& /@ residuals);

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

If[!ValueQ[$AntennaPipelineHeavyRouteNotices],
  $AntennaPipelineHeavyRouteNotices = <||>;
];

HeavyIntegrationRouteQ[key_, component_, contribution_] :=
  Module[{componentName, contributionName},
    componentName = CanonicalAntennaComponentName[component];
    contributionName = CanonicalAntennaComponentName[contribution];
    (* The warning is only emitted for the all-components view, because the
       selected-component routes are the recommended way to probe expensive
       families incrementally. *)
    componentName === "All" &&
      MemberQ[{{A, 3, 1}, {A, 2, 2}, {A, 4, 0}, {B, 4, 0}, {C, 4, 0}},
        key] &&
      MemberQ[{"All", "TwoLoopTree", "OneLoopSelf"}, contributionName]
  ];

HeavyIntegrationRouteLabel[key_, component_, contribution_] :=
  StringJoin[
    ToString[key, InputForm],
    " with Component -> ",
    CanonicalAntennaComponentName[component],
    ", Contribution -> ",
    CanonicalAntennaComponentName[contribution]
  ];

MaybeWarnHeavyIntegrationRoute[key_, component_, contribution_] :=
  Module[{noticeKey, label},
    If[!HeavyIntegrationRouteQ[key, component, contribution],
      Return[Null]
    ];
    noticeKey = StringJoin[
      ToString[key, InputForm],
      "::",
      CanonicalAntennaComponentName[component],
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
        "ObjectContribution" -> Lookup[data, "Contribution", All],
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
        "Component" -> Lookup[options, "Component", All],
        "Contribution" -> Lookup[options, "Contribution", All],
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
      CanonicalAntennaComponentName[Lookup[options, "Component", All]], "-",
      CanonicalAntennaComponentName[Lookup[options, "Contribution", All]]
    ]
  ];

BuildAndIntegrateStoredResultKey[type_, numFinalParticles_, loopOrder_,
   options_Association] :=
  StoredResultKeyAssociation[
    "BuildAndIntegrateAntenna",
    <|
      "Type" -> type,
      "NumFinalParticles" -> numFinalParticles,
      "LoopOrder" -> loopOrder,
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
      "Component" -> Lookup[options, "Component", All],
      "Contribution" -> Lookup[options, "Contribution", All],
      "DetailedTimingDiagnostics" -> Lookup[options,
        "DetailedTimingDiagnostics", False]
    |>
  ];

BuildAndIntegrateStoredResultLabel[type_, numFinalParticles_, loopOrder_,
   options_Association] :=
  StringJoin[
    "BuildAndIntegrateAntenna-",
    StoredResultTypeLabel[type], "-",
    ToString[numFinalParticles], "-",
    ToString[loopOrder], "-",
    CanonicalAntennaComponentName[Lookup[options, "Component", All]], "-",
    CanonicalAntennaComponentName[Lookup[options, "Contribution", All]]
  ];

FormatFreshIntegrationReturn[result_, diagnostics_, returnDiagnostics_,
   returnRecord_, requestedSteps_List, printSteps_,
   routeKind_String:"IntegrateAntenna", recordStages_:Automatic,
   recordMetadata_Association:<||>] :=
  Module[{selectedSteps, stages, record},
    selectedSteps = Lookup[diagnostics, "IntermediateSteps", <||>];
    If[TrueQ[returnRecord],
      stages =
        If[AssociationQ[recordStages],
          recordStages
          ,
          If[AssociationQ[selectedSteps], selectedSteps, <||>]
        ];
      record = IntegrationRunRecord[routeKind, result, diagnostics, stages,
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

LoadMassiveA30IntegratedProvenance[] :=
  Null;

MassiveA30IntegratedRouteData[qm_, order_Integer, normalizeScale_,
   profile_Association] :=
  Module[{closed, normalized, series, source, bridgeReport,
     backendDiagnostics, diagnostics},
    LoadMassiveA30IntegratedProvenance[];
    closed = MassiveA30IntegratedRuntimeClosedExpression[qm];
    normalized =
      If[TrueQ[normalizeScale],
        closed /. q2 -> 1
        ,
        closed
      ] // Together // FullSimplify;
    series = MassiveA30IntegratedRuntimeSeries[qm, order, normalizeScale];
    source = MassiveA30IntegratedSource[];
    bridgeReport = MassiveA30IntegratedBridgeReport[];
    backendDiagnostics =
      <|
        "Profile" -> profile,
        "OpenMasterValuesQ" -> False,
        "IntegratedResultKind" -> "ClosedBibliographyBridgeSeries",
        "RawLiteRedCombination" -> Missing["NotAvailable"],
        "MasterMappedExpression" -> Missing["NotAvailable"],
        "RawMasterCombination" -> Missing["NotAvailable"],
        "MasterSubstitutedExpression" -> closed,
        "NormalizedBeforeSeries" -> normalized,
        "SeriesResult" -> series,
        "MassiveA30Source" -> source,
        "MassiveA30BridgeReport" -> bridgeReport
      |>;
    diagnostics =
      <|
        "IntegratedResidualIsZero" -> Missing["NotAvailable"],
        "IntegratedResidual" -> Missing["NotAvailable"],
        "Profile" -> profile,
        "BackendDiagnostics" -> backendDiagnostics,
        "MassiveA30Route" -> True,
        "MassiveA30Source" -> source,
        "MassiveA30BridgeReport" -> bridgeReport
      |>;
    <|
      "RawIntegrated" -> series,
      "TTerms" -> series,
      "FinalIntegrated" -> series,
      "SelectedIntegrated" -> series,
      "BackendDiagnostics" -> backendDiagnostics,
      "Diagnostics" -> diagnostics
    |>
  ];

A22CombineIntegratedResults[treeResult_List, breveResult_] :=
  (* The public A22 result is defined as the stitched four-component object:
     the first three entries come from the tree/two-loop branch and breveA22
     comes from the one-loop/self branch. *)
  Join[treeResult, {breveResult}];

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
    <|"CombinedA22ContributionQ" -> True,
      "Contribution" -> "All",
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
      "ComponentDiagnostics" -> <|"TwoLoopTree" -> treeComponentDiags,
        "OneLoopSelf" -> breveDiag|>|>
  ];

IntegrateAntenna[antenna_, integrationMethod:(PaVe | IBP),
   OptionsPattern[]] :=
  Module[{ApplyFeynCalcOpt, quarkMassOpt, profile, output,
     intermediateSteps, collectedSteps},
    ApplyFeynCalcOpt = OptionValue["ApplyFeynCalcMS"];
    quarkMassOpt = OptionValue["quarkMass"];
    intermediateSteps = NormalizeIntermediateSteps[OptionValue[
      "IntermediateSteps"]];
    profile = <|"DefaultBackend" -> integrationMethod, "PaVeFamily" ->
       "MasslessTwoPartonVertex", "KinematicScale" -> OptionValue[
        "KinematicScale"], "ExpansionOrder" -> If[OptionValue[
        "ExpansionOrder"] === Automatic, 2, OptionValue["ExpansionOrder"]]
        |>;
    output =
      Switch[integrationMethod,
        PaVe,
          IntegrateViaPaVe[antenna, profile, True,
            ApplyFeynCalcOpt, quarkMassOpt, PaVeEvaluation -> OptionValue[
             "PaVeEvaluation"], ExpansionOrder -> profile["ExpansionOrder"],
            KinematicScale -> OptionValue["KinematicScale"],
            NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"
             ], LoopMomentum -> OptionValue["LoopMomentum"], ApplyDimReg ->
             OptionValue["ApplyDimReg"]]
        ,
        IBP,
          IntegrateViaIBP[antenna, ExpansionOrder -> profile[
            "ExpansionOrder"], BasisFamily -> OptionValue["BasisFamily"],
            BasisRoot -> OptionValue["BasisRoot"], GenerateMissingBases ->
             OptionValue["GenerateMissingBases"], ReturnDiagnostics ->
             OptionValue["ReturnDiagnostics"], DetailedTimingDiagnostics ->
             OptionValue["DetailedTimingDiagnostics"]]
        ,
        _,
          Print["Unsupported integration backend: ", integrationMethod,
            ". Aborting..."];
          $Failed
      ];
    output = SelectAntennaComponent[output, Missing["DirectIntegratedObject"],
      OptionValue["Component"]];
    collectedSteps = CollectIntegrationIntermediateSteps[antenna,
      Missing["NotAvailable"], Missing["NotAvailable"], output, output,
      <||>, <||>, intermediateSteps];
    If[TrueQ[OptionValue["PrintIntermediateSteps"]] && Length[
        collectedSteps] > 0,
      PrintIntermediateStepsAssociation[collectedSteps]
    ];
    If[Length[collectedSteps] > 0,
      {output, collectedSteps}
      ,
      output
    ]
  ];

Options[BuildAndIntegrateAntenna] =
  Options[IntegrateAntenna];

IntegrateAntenna[obj_AntennaObject, OptionsPattern[]] :=
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
     quarkMassOpt},
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
          Return[
            FormatStoredResultReturn[loaded["Result"],
              loaded["Diagnostics"], loaded, OptionValue[
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
            PrintIntermediateSteps -> False,
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
      Return[
        FormatFreshIntegrationReturn[computedResult, computedDiagnostics,
          OptionValue["ReturnDiagnostics"], OptionValue["ReturnRecord"],
          intermediateSteps, OptionValue["PrintIntermediateSteps"],
          "IntegrateAntenna", Automatic, recordMetadata]
      ]
    ];
    quarkMassOpt = OptionValue["quarkMass"];
    MaybeWarnHeavyIntegrationRoute[key, Lookup[data, "SelectedComponent", All],
      Lookup[data, "Contribution", All]];
    profile = AntennaIntegrationProfile[key];
    If[MatchQ[key, {a_Symbol /; SymbolName[a] === "A", 3, 0}] &&
        quarkMassOpt =!= 0,
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
        Lookup[profile, "ExpansionOrder", 0]
        ,
        OptionValue["ExpansionOrder"]
      ];
    If[MatchQ[key, {a_Symbol /; SymbolName[a] === "A", 3, 0}] &&
        quarkMassOpt =!= 0 &&
        !TrueQ[$MassiveA30ForceIBPMasterRoute],
      Module[{routeData, antennaLocal},
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
        Return[
          FormatFreshIntegrationReturn[selectedIntegrated,
            diagnosticsWithMetadata, OptionValue["ReturnDiagnostics"],
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
          Return[
            FormatFreshIntegrationReturn[finalIntegrated,
              diagnosticsWithMetadata, OptionValue["ReturnDiagnostics"],
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
    antenna = Lookup[data, "Antenna", $Failed];
    ibpNeedsDiagnostics =
      TrueQ[OptionValue["ReturnDiagnostics"]] ||
      TrueQ[OptionValue["ReturnRecord"]];
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
                "DetailedTimingDiagnostics"]];
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
    output = FormatFreshIntegrationReturn[selectedIntegrated,
      diagnosticsWithMetadata, OptionValue["ReturnDiagnostics"], OptionValue[
        "ReturnRecord"], intermediateSteps, OptionValue[
        "PrintIntermediateSteps"], "IntegrateAntenna", recordStages,
      recordMetadata];
    output
  ];

BuildAndIntegrateAntenna[type_, numFinalParticles_Integer, loopOrder_Integer,
   OptionsPattern[]] :=
  Module[{key, profile, contribution, componentName, antennaObject,
     buildComponent, selectionComponent,
     diagnostics, expansionOrder,
     intermediateSteps, useStored, storeStored, refreshStored, cacheKey,
     cacheLabel, cacheRoot, loaded, computed, computedResult,
     computedDiagnostics, optionsAssoc, recordMetadata, quarkMassOpt,
     integrationResult, integrationDiagnostics},
    key = {type, numFinalParticles, loopOrder};
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
      "Component" -> OptionValue["Component"],
      "Contribution" -> OptionValue["Contribution"],
      "DetailedTimingDiagnostics" -> OptionValue[
        "DetailedTimingDiagnostics"]
    |>;
    recordMetadata =
      <|"Key" -> key, "SelectedComponent" -> OptionValue["Component"],
        "Contribution" -> OptionValue["Contribution"]|>;
    If[!TrueQ[$AntennaPipelineBypassStoredResults] &&
        StoredResultsEnabledQ[useStored, storeStored, refreshStored],
      cacheKey = BuildAndIntegrateStoredResultKey[type,
        numFinalParticles, loopOrder, optionsAssoc];
      cacheLabel = BuildAndIntegrateStoredResultLabel[type,
        numFinalParticles, loopOrder, optionsAssoc];
      cacheRoot = OptionValue["ResultsCacheRoot"];
      If[!refreshStored && useStored,
        loaded = LoadStoredResultEntry["BuildAndIntegrateAntenna", cacheKey,
          cacheRoot, cacheLabel];
        If[AssociationQ[loaded],
          PrintStoredResultHit[cacheLabel];
          Return[
            FormatStoredResultReturn[loaded["Result"],
              loaded["Diagnostics"], loaded, OptionValue[
                "ReturnDiagnostics"], OptionValue["ReturnRecord"],
              intermediateSteps, OptionValue["PrintIntermediateSteps"],
              "BuildAndIntegrateAntenna", recordMetadata]
          ]
        ]
      ];
      computed =
        Block[{$AntennaPipelineBypassStoredResults = True},
          BuildAndIntegrateAntenna[type, numFinalParticles, loopOrder,
            ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
            quarkMass -> OptionValue["quarkMass"],
            PaVeEvaluation -> OptionValue["PaVeEvaluation"],
            ExpansionOrder -> OptionValue["ExpansionOrder"],
            KinematicScale -> OptionValue["KinematicScale"],
            NormalizeKinematicScale -> OptionValue[
              "NormalizeKinematicScale"],
            ReturnDiagnostics -> True,
            LoopMomentum -> OptionValue["LoopMomentum"],
            ApplyDimReg -> OptionValue["ApplyDimReg"],
            BasisFamily -> OptionValue["BasisFamily"],
            BasisRoot -> OptionValue["BasisRoot"],
            GenerateMissingBases -> OptionValue["GenerateMissingBases"],
            ReturnTTerms -> OptionValue["ReturnTTerms"],
            IntermediateSteps -> IntegrationRecordStepLabels[],
            PrintIntermediateSteps -> False,
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
        StoreStoredResultEntry["BuildAndIntegrateAntenna", cacheKey,
          cacheRoot, cacheLabel, computedResult, computedDiagnostics]
      ];
      Return[
        FormatFreshIntegrationReturn[computedResult, computedDiagnostics,
          OptionValue["ReturnDiagnostics"], OptionValue["ReturnRecord"],
          intermediateSteps, OptionValue["PrintIntermediateSteps"],
          "BuildAndIntegrateAntenna", Automatic, recordMetadata]
      ]
    ];
    MaybeWarnHeavyIntegrationRoute[key, OptionValue["Component"],
      OptionValue["Contribution"]];
    quarkMassOpt = OptionValue["quarkMass"];
    profile = AntennaIntegrationProfile[key];
    If[MatchQ[key, {a_Symbol /; SymbolName[a] === "A", 3, 0}] &&
        quarkMassOpt =!= 0,
      profile = Join[profile, <|"BasisFamily" -> "MX30",
        "MassSymbol" -> quarkMassOpt|>]
    ];
    contribution = CanonicalAntennaComponentName[OptionValue[
       "Contribution"]];
    componentName = CanonicalAntennaComponentName[OptionValue["Component"]];
    If[MatchQ[key, {a_Symbol /; SymbolName[a] === "A", 2, 2}] && contribution === "OneLoopSelf",
      profile = Join[profile, <|"BasisFamily" -> "A22OneLoopSelf",
          "ImplementationStatus" -> "ExperimentalOneLoopSelfOnly"|>]
    ];
    If[MatchQ[key, {a_Symbol /; SymbolName[a] === "A", 2, 2}] && contribution === "TwoLoopTree",
      profile = Join[profile, <|"BasisFamily" -> "A22TwoLoopTree",
          "ImplementationStatus" -> "ExperimentalTwoLoopTree"|>]
    ];
    expansionOrder =
      If[OptionValue["ExpansionOrder"] === Automatic,
        Lookup[profile, "ExpansionOrder", 0]
        ,
        OptionValue["ExpansionOrder"]
      ];
    If[Lookup[profile, "ImplementationStatus", "Implemented"] ===
        "ScaffoldOnly" &&
        Lookup[profile, "BasisFamily", Missing["NoFamily"]] =!= "MX30",
      diagnostics = <|"Failed" -> True,
        "Reason" -> "IntegratedAntennaNotImplemented",
        "Profile" -> profile, "Contribution" -> OptionValue[
          "Contribution"]|>;
      Return[
        FormatFreshIntegrationReturn[$Failed, diagnostics, OptionValue[
            "ReturnDiagnostics"], OptionValue["ReturnRecord"],
          intermediateSteps, OptionValue["PrintIntermediateSteps"],
          "BuildAndIntegrateAntenna",
          CollectIntegrationRecordStages[Missing["NotAvailable"], $Failed,
            $Failed, $Failed, $Failed, <||>, diagnostics], recordMetadata]
      ]
    ];
    buildComponent =
      If[OptionValue["Component"] === All,
        All
        ,
        OptionValue["Component"]
      ];
    selectionComponent =
      If[buildComponent === All,
        OptionValue["Component"]
        ,
        All
      ];
    antennaObject = BuildAntennaObject[type, numFinalParticles, loopOrder,
      quarkMass -> OptionValue["quarkMass"],
      ApplyDimReg -> OptionValue["ApplyDimReg"],
      LoopMomentum -> OptionValue["LoopMomentum"],
      Component -> buildComponent, Contribution -> OptionValue[
       "Contribution"]];
    If[antennaObject === $Failed,
      Return[
        FormatFreshIntegrationReturn[$Failed,
          <|"Failed" -> True, "Reason" -> "InvalidComponentSelection",
            "SelectedComponent" -> OptionValue["Component"],
            "Contribution" -> OptionValue["Contribution"]|>, OptionValue[
            "ReturnDiagnostics"], OptionValue["ReturnRecord"],
          intermediateSteps, OptionValue["PrintIntermediateSteps"],
          "BuildAndIntegrateAntenna",
          CollectIntegrationRecordStages[Missing["NotAvailable"], $Failed,
            $Failed, $Failed, $Failed, <||>,
            <|"Failed" -> True, "Reason" -> "InvalidComponentSelection",
              "SelectedComponent" -> OptionValue["Component"],
              "Contribution" -> OptionValue["Contribution"]|>],
          recordMetadata]
      ]
    ];
    {integrationResult, integrationDiagnostics} =
      IntegrateAntenna[antennaObject,
      ApplyFeynCalcMS -> OptionValue["ApplyFeynCalcMS"],
      quarkMass -> OptionValue["quarkMass"],
      PaVeEvaluation -> OptionValue["PaVeEvaluation"],
      ExpansionOrder -> OptionValue["ExpansionOrder"],
      KinematicScale -> OptionValue["KinematicScale"],
      NormalizeKinematicScale -> OptionValue["NormalizeKinematicScale"],
      ReturnDiagnostics -> True,
      ReturnRecord -> False,
      LoopMomentum -> OptionValue["LoopMomentum"],
      ApplyDimReg -> OptionValue["ApplyDimReg"],
      BasisFamily -> OptionValue["BasisFamily"],
      BasisRoot -> OptionValue["BasisRoot"],
      GenerateMissingBases -> OptionValue["GenerateMissingBases"],
      ReturnTTerms -> OptionValue["ReturnTTerms"],
      IntermediateSteps -> If[TrueQ[OptionValue["ReturnRecord"]],
        IntegrationRecordStepLabels[],
        OptionValue["IntermediateSteps"]
      ],
      PrintIntermediateSteps -> False,
      DetailedTimingDiagnostics -> OptionValue["DetailedTimingDiagnostics"],
      Component -> selectionComponent,
      Contribution -> OptionValue["Contribution"]];
    integrationDiagnostics =
      Join[integrationDiagnostics, <|"SourceObject" -> antennaObject,
          "AntennaObject" -> antennaObject|>];
    FormatFreshIntegrationReturn[integrationResult, integrationDiagnostics,
      OptionValue["ReturnDiagnostics"], OptionValue["ReturnRecord"],
      intermediateSteps, OptionValue["PrintIntermediateSteps"],
      "BuildAndIntegrateAntenna", Automatic,
      Join[recordMetadata, <|"SourceObject" -> antennaObject,
          "AntennaObject" -> antennaObject|>]]
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
    Component -> OptionValue["Component"],
    Contribution -> OptionValue["Contribution"]];
IntegratedAntennaDiagnostics[key_, unintegrated_, integrated_, profile_Association,
   context_:<||>] :=
  Module[{paVeTarget, integratedTarget, integratedResidual, diagnostics,
     expansionOrder, tTerms, tTargets, antennaTargets, tResiduals,
     antennaResiduals},
    expansionOrder = Lookup[context, "ExpansionOrder", Lookup[profile,
       "ExpansionOrder", 0]];
    diagnostics =
      Switch[key,
        {a_Symbol /; SymbolName[a] === "A", 2, 1},
          paVeTarget = A21PaperPaVe /. D -> 4 - 2 Epsilon;
          integratedTarget = A21IntegratedPaper;
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
          integratedTarget = 1/FeynCalc`Epsilon^2 + 3/(2 FeynCalc`Epsilon
            ) + 19/4 - 7 Pi^2/12;
          integratedResidual =
            integrated - integratedTarget //
            FunctionExpand //
            FullSimplify;
          <|"IntegratedResidualIsZero" -> TrueQ[integratedResidual ===
             0], "IntegratedResidual" -> integratedResidual, "Profile" ->
              profile|>
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
              Missing["NotAvailable"]
            ];
          antennaResiduals =
            If[ListQ[integrated] && !TrueQ[Lookup[context, "ReturnTTerms",
                False]],
              A31IntegratedResiduals[integrated, antennaTargets]
              ,
              Missing["NotAvailable"]
            ];
          <|"TTermResiduals" -> tResiduals, "TTermResidualsAreZero" ->
            IntegratedResidualListZeroQ[tResiduals],
            "IntegratedAntennaResiduals" -> antennaResiduals,
            "IntegratedAntennaResidualsAreZero" ->
              IntegratedResidualListZeroQ[antennaResiduals],
            "Profile" -> profile|>
        ,
        {a_Symbol /; SymbolName[a] === "A", 2, 2},
          tTerms = Lookup[context, "TTerms", Missing["NotAvailable"]];
          tResiduals =
            If[ListQ[tTerms],
              A22TTermResiduals[tTerms, expansionOrder]
              ,
              If[tTerms === Missing["NotAvailable"],
                Missing["NotAvailable"]
                ,
                A22TTermResiduals[tTerms, Lookup[context, "BuildComponent",
                  Lookup[context, "SelectedComponent", All]],
                  expansionOrder]
              ]
            ];
          antennaResiduals =
            If[Lookup[context, "ReturnTTerms", False] === True,
              Missing["NotAvailable"]
              ,
              If[ListQ[integrated],
                A22IntegratedResiduals[integrated, expansionOrder]
                ,
                A22IntegratedResiduals[integrated,
                  Lookup[context, "BuildComponent",
                    Lookup[context, "SelectedComponent", All]],
                  expansionOrder]
              ]
            ];
          <|"TTermResiduals" -> tResiduals,
            "TTermResidualsAreZero" ->
              IntegratedResidualListZeroQ[tResiduals],
            "TTermResidualIsZero" -> TrueQ[tResiduals === 0],
            "IntegratedAntennaResiduals" -> antennaResiduals,
            "IntegratedAntennaResidualsAreZero" ->
              IntegratedResidualListZeroQ[antennaResiduals],
            "IntegratedAntennaResidualIsZero" -> TrueQ[antennaResiduals === 0],
            "FinalAntennaExtractionImplemented" -> True,
            "Profile" -> profile|>
        ,
        _,
          <|"PaperCheckAvailable" -> False, "Profile" -> profile|>
      ];
    diagnostics
  ];
