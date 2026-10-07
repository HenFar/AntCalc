(* ::Section:: *)

(* Integration-route orchestration *)

(* Communicates with:
   - src/core/profiles.wl and src/routes/route_catalog.wl for integration
     metadata and route stories.
   - src/engines/integration_pave.wl and src/engines/integration_ibp.wl for
     the actual backend integrations.
   - src/engines/integrated_antenna_extraction.wl for T-term and final
     integrated-antenna post-processing.
   - src/core/result_cache.wl for stored-result reuse and replay.
   - src/interface/integration_router.wl, which wraps these raw route results
     in the public API.
   - src/routes/massive_a30_integrated.wl for the special massive A30 branch.

   Why this file exists:
   Integration is where the package stops being a collection of isolated engines
   and becomes a user-facing pipeline: backend selection, cache behavior,
   component-by-component A22 stitching, and post-integration extraction all
   need to be coordinated in one place. *)

IntegrateBackendDirectRoute::usage = "IntegrateBackendDirectRoute[antenna, backend, options] evaluates the src direct integration route for a raw antenna expression.";

IntegrateRouteObject::usage = "IntegrateRouteObject[obj, options] evaluates the src integration route for an AntennaObject.";

BuildAndIntegrateRouteResult::usage = "BuildAndIntegrateRouteResult[type, n, l, options] evaluates the src build-and-integrate route before public formatting.";

IntegrationWrapperOptionContract::usage =
  "IntegrationWrapperOptionContract[] returns the disposition of every public integration option in BuildAndIntegrateAntenna: forwarded to a canonical stage or applied only at the wrapper return boundary.";

BuildAndIntegrateIntegrationOptions::usage =
  "BuildAndIntegrateIntegrationOptions[options] converts one-shot integration settings into the rules supplied to IntegrateAntenna after the build stage.";

A22BuildIntegrationObject::usage = "A22BuildIntegrationObject[key, options, component] rebuilds a supported A22 source object for component-wise integration.";

A22BuildIntegrationObject[{type_, numFinalParticles_Integer, loopOrder_Integer
  }, options_Association, component_] :=
  BuildAntennaObject[type, numFinalParticles, loopOrder, Component ->
     component, quarkMass -> Lookup[options,
     "quarkMass", 0], ApplyDimReg -> Lookup[options, "ApplyDimReg", True],
     LoopMomentum -> Lookup[options, "LoopMomentum", l], UseStoredResults
     -> Lookup[options, "UseStoredResults", False], StoreResults -> Lookup[
    options, "StoreResults", False], ResultsCacheRoot -> Lookup[options,
    "ResultsCacheRoot", Automatic], RefreshStoredResults -> Lookup[options,
     "RefreshStoredResults", False], PrintIntermediateSteps -> False];

(* The one-shot function is a composition, not a separate integration API.
   Keep its option disposition explicit so additions to IntegrateAntenna cannot
   silently bypass the direct route.  Return shapes and cache handling belong
   to the wrapper; physics/backend controls are forwarded unchanged. *)
IntegrationWrapperOptionContract[] := <|
  ApplyFeynCalcMS -> "ForwardedToIntegrateAntenna",
  quarkMass -> "ForwardedToBuildAndIntegratePipeline",
  ExpansionOrder -> "ForwardedToIntegrateAntenna",
  KinematicScale -> "ForwardedToIntegrateAntenna",
  NormalizeKinematicScale -> "ForwardedToIntegrateAntenna",
  ReturnDiagnostics -> "AppliedAtWrapperReturnBoundary",
  ReturnRecord -> "AppliedAtWrapperReturnBoundary",
  ReturnMasterCombination -> "ForwardedToIntegrateAntenna",
  LoopMomentum -> "ForwardedToBuildAndIntegratePipeline",
  ApplyDimReg -> "ForwardedToBuildAndIntegratePipeline",
  BasisFamily -> "ForwardedToIntegrateAntenna",
  BasisRoot -> "ForwardedToIntegrateAntenna",
  GenerateMissingBases -> "ForwardedToIntegrateAntenna",
  ReturnTTerms -> "ForwardedToIntegrateAntenna",
  Component -> "ResolvedByBuildThenIntegratedAsSelectedObject",
  IntermediateSteps -> "ForwardedOrExpandedForWrapperRecord",
  PrintIntermediateSteps -> "ForwardedToIntegrateAntenna",
  PrintComponentLegend -> "AppliedAtPublicReturnBoundary",
  DetailedTimingDiagnostics -> "ForwardedToIntegrateAntenna",
  UseStoredResults -> "ForwardedToBuildAndIntegrateAntennaStages",
  StoreResults -> "ForwardedToBuildAndIntegrateAntennaStages",
  ResultsCacheRoot -> "ForwardedToBuildAndIntegrateAntennaStages",
  RefreshStoredResults -> "ForwardedToBuildAndIntegrateAntennaStages"
|>;

BuildAndIntegrateIntegrationOptions[options_Association] := {
  ApplyFeynCalcMS -> Lookup[options, "ApplyFeynCalcMS", True],
  quarkMass -> Lookup[options, "quarkMass", 0],
  ExpansionOrder -> Lookup[options, "ExpansionOrder", Automatic],
  KinematicScale -> Lookup[options, "KinematicScale", q2],
  NormalizeKinematicScale -> Lookup[options, "NormalizeKinematicScale", True],
  ReturnDiagnostics -> True,
  ReturnRecord -> Lookup[options, "ReturnRecord", False],
  ReturnMasterCombination -> Lookup[options, "ReturnMasterCombination", False],
  LoopMomentum -> Lookup[options, "LoopMomentum", l],
  ApplyDimReg -> Lookup[options, "ApplyDimReg", True],
  BasisFamily -> Lookup[options, "BasisFamily", Automatic],
  BasisRoot -> Lookup[options, "BasisRoot", Automatic],
  GenerateMissingBases -> Lookup[options, "GenerateMissingBases", False],
  ReturnTTerms -> Lookup[options, "ReturnTTerms", False],
  IntermediateSteps -> If[TrueQ[Lookup[options, "ReturnRecord", False]],
    IntegrationRecordStepLabels[], Lookup[options, "IntermediateSteps", {}]],
  PrintIntermediateSteps -> Lookup[options, "PrintIntermediateSteps", False],
  PrintComponentLegend -> Lookup[options, "PrintComponentLegend", Automatic],
  DetailedTimingDiagnostics -> Lookup[options, "DetailedTimingDiagnostics", False],
  UseStoredResults -> Lookup[options, "UseStoredResults", False],
  StoreResults -> Lookup[options, "StoreResults", False],
  ResultsCacheRoot -> Lookup[options, "ResultsCacheRoot", Automatic],
  RefreshStoredResults -> Lookup[options, "RefreshStoredResults", False],
  Component -> All
};

(* IntegrateBackendDirectRoute[antenna, integrationMethod, options]
   ================================================================
   Run one backend directly on a raw antenna expression, without any
   AntennaObject-level orchestration. *)

IntegrateBackendDirectRoute[antenna_, integrationMethod_, options_Association
  ] :=
  Module[{applyFeynCalcOpt, quarkMassOpt, profile, output, intermediateSteps,
     collectedSteps},
    applyFeynCalcOpt = Lookup[options, "ApplyFeynCalcMS", False];
    quarkMassOpt = Lookup[options, "quarkMass", 0];
    intermediateSteps = NormalizeIntermediateSteps[Lookup[options, "IntermediateSteps",
       {}]];
    profile =
      <|
        "DefaultBackend" -> integrationMethod
        ,
        "PaVeFamily" -> "MasslessTwoPartonVertex"
        ,
        "KinematicScale" -> Lookup[options, "KinematicScale", q2]
        ,
        "ExpansionOrder" ->
          If[Lookup[options, "ExpansionOrder", Automatic] === Automatic,

            2
            ,
            Lookup[options, "ExpansionOrder", 2]
          ]
      |>;
    output =
      Switch[integrationMethod,
        PaVe,
          IntegrateViaPaVe[antenna, profile, True, applyFeynCalcOpt,
            quarkMassOpt, PaVeEvaluation -> Lookup[profile, "PaVeEvaluation", "PaXEvaluate"
            ], ExpansionOrder -> profile["ExpansionOrder"], KinematicScale -> Lookup[
            options, "KinematicScale", q2], NormalizeKinematicScale -> Lookup[options,
             "NormalizeKinematicScale", False], LoopMomentum -> Lookup[options, "LoopMomentum",
             l], ApplyDimReg -> Lookup[options, "ApplyDimReg", True]]
        ,
        IBP,
          IntegrateViaIBP[antenna, ExpansionOrder -> profile["ExpansionOrder"
            ], BasisFamily -> Lookup[options, "BasisFamily", Automatic], BasisRoot
             -> Lookup[options, "BasisRoot", Automatic], GenerateMissingBases ->
            Lookup[options, "GenerateMissingBases", False], ReturnDiagnostics ->
            Lookup[options, "ReturnDiagnostics", False], DetailedTimingDiagnostics
             -> Lookup[options, "DetailedTimingDiagnostics", False], MassSymbol ->
             Lookup[profile, "MassSymbol", Automatic], ApplyFeynCalcMS -> Lookup[
            options, "ApplyFeynCalcMS", False], KinematicScale -> Lookup[options,
             "KinematicScale", q2], NormalizeKinematicScale -> Lookup[options, "NormalizeKinematicScale",
             False]]
        ,
        _,
          Print["Unsupported integration backend: ", integrationMethod,
             ". Aborting..."];
          $Failed
      ];
    output = SelectAntennaComponent[output, Missing["DirectIntegratedObject"
      ], Lookup[options, "Component", All]];
    collectedSteps = CollectIntegrationIntermediateSteps[antenna, Missing[
      "NotAvailable"], Missing["NotAvailable"], output, output, <||>, <||>,
       intermediateSteps];
    If[TrueQ[Lookup[options, "PrintIntermediateSteps", False]] && Length[
      collectedSteps] > 0,
      PrintIntermediateStepsAssociation[collectedSteps]
    ];
    If[Length[collectedSteps] > 0,
      {output, collectedSteps}
      ,
      output
    ]
  ];

(* IntegrateRouteObject[obj, options]
   ==================================
   Integrate one AntennaObject through the route layer, including backend
   selection, cache handling, diagnostics, and final post-processing. *)

IntegrateRouteObject[obj_, options_Association] :=
  Module[{data, key, profile, contributionInput, contribution, componentInput,
     componentName, storedComponent, backend, antenna, diagnostics, output,
     ibpResult, backendDiagnostics = <||>, rawIntegrated, tTerms, finalIntegrated,
     selectedIntegrated, expansionOrder, leadingCall, subleadingCall, nfCall,
     breveCall, leadingResult, subleadingResult, nfResult, breveResult, leadingDiag,
     subleadingDiag, nfDiag, breveDiag, treeDiags, intermediateSteps, collectedSteps,
     useStored, storeStored, refreshStored, cacheKey, cacheLabel, cacheRoot,
     loaded, computed, computedResult, computedDiagnostics, optionsAssoc,
     recordStages, recordMetadata, diagnosticsWithMetadata, ibpNeedsDiagnostics,
     quarkMassOpt, routeKind, progressActive, finishProgress, publicResult,
     publicDiagnostics, resolved, requestedExpansionOrder},
    routeKind = Lookup[options, "RouteKind", "IntegrateAntenna"];
    If[!AntennaObjectQ[obj],
      diagnostics = <|"Failed" -> True, "Reason" -> "InvalidAntennaObject"
        |>;
      Return[FormatFreshIntegrationReturn[$Failed, diagnostics, Lookup[
        options, "ReturnDiagnostics", False], Lookup[options, "ReturnRecord",
         False], {}, False, routeKind, CollectIntegrationRecordStages[Missing[
        "NotAvailable"], $Failed, $Failed, $Failed, $Failed, <||>, diagnostics
        ]]]
    ];
    data = AntennaObjectData[obj];
    intermediateSteps = NormalizeIntermediateSteps[Lookup[options, "IntermediateSteps",
       {}]];
    useStored = TrueQ[Lookup[options, "UseStoredResults", False]];
    storeStored = TrueQ[Lookup[options, "StoreResults", False]];
    refreshStored = TrueQ[Lookup[options, "RefreshStoredResults", False
      ]];
    optionsAssoc = <|"ApplyFeynCalcMS" -> Lookup[options, "ApplyFeynCalcMS",
       False], "quarkMass" -> Lookup[options, "quarkMass", 0], "ExpansionOrder" ->
       Lookup[options, "ExpansionOrder", Automatic], "KinematicScale" -> Lookup[
      options, "KinematicScale", q2], "NormalizeKinematicScale" -> Lookup[options,
       "NormalizeKinematicScale", False], "LoopMomentum" -> Lookup[options,
       "LoopMomentum", l], "ApplyDimReg" -> Lookup[options, "ApplyDimReg",
      True], "BasisFamily" -> Lookup[options, "BasisFamily", Automatic], "BasisRoot"
       -> Lookup[options, "BasisRoot", Automatic], "GenerateMissingBases" ->
       Lookup[options, "GenerateMissingBases", False], "ReturnTTerms" -> Lookup[
      options, "ReturnTTerms", False], "ReturnMasterCombination" -> Lookup[
      options, "ReturnMasterCombination", False], "Component" -> Lookup[options,
       "Component", All], "DetailedTimingDiagnostics" -> Lookup[options, "DetailedTimingDiagnostics",
       False]|>;
    key = Lookup[data, "Key", Missing["UnknownKey"]];
    recordMetadata = <|"Key" -> key, "SelectedComponent" -> Lookup[options,
       "Component", All], "ContributionsUsed" -> AntennaContributionsUsed[key,
       Lookup[options, "Component", Lookup[data, "SelectedComponent", All]]],
       "SourceObject" -> obj, "AntennaObject" -> obj, "RouteStory" ->
       IntegrationRouteStory[key], "PrintComponentLegend" -> Lookup[options,
        "PrintComponentLegend", Automatic]|>;
    componentInput =
      If[Lookup[options, "Component", All] === All,
        Lookup[data, "SelectedComponent", All]
        ,
        Lookup[options, "Component", All]
      ];
    contributionInput = AntennaInternalContribution[key, componentInput];
    recordMetadata = Join[recordMetadata,
      <|"SelectedComponent" -> componentInput,
        "ContributionsUsed" -> AntennaContributionsUsed[key, componentInput]|>];
(* Every public integration route reports its stages. Heavy routes retain

   the same detailed stages; lightweight routes now no longer appear idle.
  *)
    progressActive = True;
    If[key === Missing["UnknownKey"],
      diagnostics = <|"Failed" -> True, "Reason" -> "MissingAntennaObjectKey",
         "SourceObject" -> obj, "AntennaObject" -> obj|>;
      Return[FormatFreshIntegrationReturn[$Failed, diagnostics, Lookup[
        options, "ReturnDiagnostics", False], Lookup[options, "ReturnRecord",
         False], {}, False, routeKind, CollectIntegrationRecordStages[obj, $Failed,
         $Failed, $Failed, $Failed, <||>, diagnostics], recordMetadata]]
    ];
    If[!TrueQ[$AntennaPipelineBypassStoredResults] && StoredResultsEnabledQ[
      useStored, storeStored, refreshStored],
      cacheKey = IntegrateAntennaStoredResultKey[obj, optionsAssoc];
      cacheLabel = IntegrateAntennaStoredResultLabel[obj, optionsAssoc
        ];
      cacheRoot = Lookup[options, "ResultsCacheRoot", Automatic];
      If[!refreshStored && useStored,
        loaded = LoadStoredResultEntry["IntegrateAntenna", cacheKey,
          cacheRoot, cacheLabel];
        If[AssociationQ[loaded],
          PrintStoredResultHit[cacheLabel];
          Return[FormatStoredResultReturn[loaded["Result"], loaded["Diagnostics"
            ], loaded, Lookup[options, "ReturnDiagnostics", False], Lookup[options,
             "ReturnRecord", False], intermediateSteps, Lookup[options, "PrintIntermediateSteps",
             False], routeKind, recordMetadata]]
        ]
      ];
      computed =
        Block[{$AntennaPipelineBypassStoredResults = True},
          IntegrateRouteObject[obj, Join[options, <|"ReturnDiagnostics"
             -> True, "ReturnRecord" -> False, "IntermediateSteps" -> IntegrationRecordStepLabels[
            ], "PrintIntermediateSteps" -> Lookup[options, "PrintIntermediateSteps",
             False], "UseStoredResults" -> False, "StoreResults" -> False, "ResultsCacheRoot"
             -> cacheRoot, "RefreshStoredResults" -> False, "RouteKind" -> routeKind
            |>]]
        ];
      If[!MatchQ[computed, {_, _Association}],
        Return[computed]
      ];
      {computedResult, computedDiagnostics} = computed;
      If[computedResult =!= $Failed && (storeStored || refreshStored),

        StoreStoredResultEntry["IntegrateAntenna", cacheKey, cacheRoot,
           cacheLabel, computedResult, computedDiagnostics]
      ];
      Return[FormatFreshIntegrationReturn[computedResult, computedDiagnostics,
         Lookup[options, "ReturnDiagnostics", False], Lookup[options, "ReturnRecord",
         False], intermediateSteps, Lookup[options, "PrintIntermediateSteps",
         False], routeKind, Automatic, recordMetadata]]
    ];
    quarkMassOpt = Lookup[options, "quarkMass", 0];
    MaybeWarnHeavyIntegrationRoute[key, Lookup[data, "SelectedComponent",
       All], AntennaInternalContribution[key, Lookup[data, "SelectedComponent", All]]];
    resolved = ResolveAntennaRoute[key, options];
    profile = Join[AntennaIntegrationProfile[key], Lookup[resolved, "Integration", <||>]];
    If[Lookup[Lookup[resolved, "Integration", <||>], "Adapter", "None"] ===
        "MassiveA30MX30Bridge",
      profile = Join[profile, <|"MassSymbol" -> quarkMassOpt|>]
    ];
    contribution = CanonicalAntennaComponentName[contributionInput];
    componentName = CanonicalAntennaComponentName[componentInput];
    (* Stage 6 is the public-return formatting event.  Do not emit a second
       6/6 "finished" line afterwards: it adds no state information and
       separates the master-basis legend from the single terminal stage. *)
    finishProgress := Null;
    If[Lookup[Lookup[resolved, "Integration", <||>], "Adapter", "None"] ===
        "A22Contributions" && contribution === "OneLoopSelf",
      profile = Join[profile, <|"BasisFamily" -> "A22OneLoopSelf", "ImplementationStatus"
         -> "ExperimentalOneLoopSelfOnly"|>]
    ];
    If[Lookup[Lookup[resolved, "Integration", <||>], "Adapter", "None"] ===
        "A22Contributions" && contribution === "TwoLoopTree",
      profile = Join[profile, <|"BasisFamily" -> "A22TwoLoopTree", "ImplementationStatus"
         -> "ExperimentalTwoLoopTree"|>]
    ];
    If[TrueQ[progressActive],
      heavyIntegrationProgressPrint[routeKind, key, componentInput, contributionInput,
         1, 6, "resolving route profile"]
    ];
    requestedExpansionOrder = Lookup[options, "ExpansionOrder", Automatic];
    expansionOrder =
      If[requestedExpansionOrder === Automatic,
        Lookup[profile, "ExpansionOrder", 2]
        ,
        requestedExpansionOrder
      ];
(* Massive A30 is currently a special route: unless the caller explicitly

   forces the IBP master route, the package uses the dedicated integrated

   bridge module rather than the generic backend path. *)
    If[Lookup[Lookup[resolved, "Integration", <||>], "Adapter", "None"] ===
        "MassiveA30MX30Bridge" && !TrueQ[$MassiveA30ForceIBPMasterRoute],
      Module[{routeData, antennaLocal, openMasterBackendDiagnostics},

        antennaLocal = Lookup[data, "Antenna", $Failed];
        routeData = MassiveA30IntegratedRouteData[quarkMassOpt, requestedExpansionOrder,
           Lookup[options, "NormalizeKinematicScale", False], profile];
        rawIntegrated = routeData["RawIntegrated"];
        tTerms = routeData["TTerms"];
        finalIntegrated = routeData["FinalIntegrated"];
        selectedIntegrated = routeData["SelectedIntegrated"];
        backendDiagnostics = routeData["BackendDiagnostics"];
        diagnostics = routeData["Diagnostics"];
        openMasterBackendDiagnostics = MassiveA30OpenMasterBackendDiagnostics[
          obj, options, routeKind];
        If[AssociationQ[openMasterBackendDiagnostics] && Length[openMasterBackendDiagnostics
          ] > 0,
          backendDiagnostics = Join[backendDiagnostics, openMasterBackendDiagnostics
            ];
          diagnostics = Join[diagnostics, <|"BackendDiagnostics" -> backendDiagnostics,
             "OpenMasterRouteAvailable" -> True|>]
        ];
        collectedSteps = CollectIntegrationIntermediateSteps[antennaLocal,
           rawIntegrated, tTerms, finalIntegrated, selectedIntegrated, backendDiagnostics,
           diagnostics, intermediateSteps];
        diagnosticsWithMetadata =
          Join[
            diagnostics
            ,
            <|"SelectedComponent" -> componentInput, "BuildComponent"
               -> storedComponent, "ContributionsUsed" -> AntennaContributionsUsed[key,
               componentInput], "RawIntegrated" -> rawIntegrated, "TTerms" -> tTerms,
               "SourceObject" -> obj, "AntennaObject" -> obj, "RouteStory" -> IntegrationRouteStory[
              key]|>
            ,
            If[Length[collectedSteps] > 0,
              <|"IntermediateSteps" -> collectedSteps|>
              ,
              <||>
            ]
          ];
        recordStages = CollectIntegrationRecordStages[antennaLocal, rawIntegrated,
           tTerms, finalIntegrated, selectedIntegrated, backendDiagnostics, diagnosticsWithMetadata
          ];
        Return[
          With[{
            publicReturn =
              If[TrueQ[Lookup[options, "ReturnMasterCombination", False
                ]],
                ResolveIntegrationPublicResult[selectedIntegrated, diagnosticsWithMetadata,
                   True, ToString[key, InputForm]]
                ,
                MassiveA30DefaultMasterEndpointResult[obj, options, routeKind,
                   selectedIntegrated, diagnosticsWithMetadata, ToString[key, InputForm
                  ]]
              ]
          },
            FormatFreshIntegrationReturn[publicReturn[[1]], publicReturn
              [[2]], Lookup[options, "ReturnDiagnostics", False], Lookup[options, "ReturnRecord",
               False], intermediateSteps, Lookup[options, "PrintIntermediateSteps",
               False], routeKind, recordStages, recordMetadata]
          ]
        ]
      ]
    ];
    If[MatchQ[key, {a_Symbol /; SymbolName[a] === "A", 2, 2}] && contribution
       === "All",
      Switch[componentName,
        "Leading" | "Subleading" | "Nf",
          Return[IntegrateRouteObject[A22BuildIntegrationObject[key,
            options, componentInput], Join[options, <|"Component" ->
             All, "RouteKind" -> routeKind|>]]]
        ,
        "Breve",
          Return[IntegrateRouteObject[A22BuildIntegrationObject[key,
            options, Breve], Join[options, <|"Component" -> All,
             "RouteKind" -> routeKind|>]]]
        ,
        "All",
          If[TrueQ[progressActive],
            heavyIntegrationProgressPrint[routeKind, key, componentInput,
               contributionInput, 2, 6, "integrating component branches"]
          ];
          leadingCall = IntegrateRouteObject[A22BuildIntegrationObject[
            key, options, Leading], Join[options, <|"ReturnDiagnostics"
             -> True, "Component" -> All, "RouteKind"
             -> routeKind|>]];
          subleadingCall = IntegrateRouteObject[A22BuildIntegrationObject[
            key, options, Subleading], Join[options, <|"ReturnDiagnostics"
             -> True, "Component" -> All, "RouteKind"
             -> routeKind|>]];
          nfCall = IntegrateRouteObject[A22BuildIntegrationObject[key,
             options, Nf], Join[options, <|"ReturnDiagnostics" -> True,
             "Component" -> All, "RouteKind" -> routeKind
            |>]];
          breveCall = IntegrateRouteObject[A22BuildIntegrationObject[
            key, options, Breve], Join[options, <|"ReturnDiagnostics"
             -> True, "Component" -> All, "RouteKind"
             -> routeKind|>]];
          {leadingResult, leadingDiag} = leadingCall;
          {subleadingResult, subleadingDiag} = subleadingCall;
          {nfResult, nfDiag} = nfCall;
          {breveResult, breveDiag} = breveCall;
          If[MemberQ[{leadingResult, subleadingResult, nfResult, breveResult
            }, $Failed],
            diagnosticsWithMetadata = <|"Failed" -> True, "Reason" ->
               "A22CombinedContributionIntegrationFailed", "ContributionDiagnostics" ->
               <|"TwoLoopTree" -> <|"Leading" -> leadingDiag, "Subleading" -> subleadingDiag,
               "Nf" -> nfDiag|>, "OneLoopSelf" -> breveDiag|>,
               "ContributionsUsed" -> AntennaContributionsUsed[key, All], "SourceObject" -> obj,
               "AntennaObject" -> obj, "RouteStory" -> IntegrationRouteStory[key]|>
              ;
            finishProgress;
            Return[FormatFreshIntegrationReturn[$Failed, diagnosticsWithMetadata,
               Lookup[options, "ReturnDiagnostics", False], Lookup[options, "ReturnRecord",
               False], intermediateSteps, Lookup[options, "PrintIntermediateSteps",
               False], routeKind, CollectIntegrationRecordStages[Lookup[data, "Antenna",
               $Failed], $Failed, $Failed, $Failed, $Failed, <|"TwoLoopTree" -> <|"Leading"
               -> leadingDiag, "Subleading" -> subleadingDiag, "Nf" -> nfDiag|>, "OneLoopSelf"
               -> breveDiag|>, diagnosticsWithMetadata], recordMetadata]]
          ];
          If[TrueQ[progressActive],
            heavyIntegrationProgressPrint[routeKind, key, componentInput,
               contributionInput, 3, 6, "combining integrated components"]
          ];
          finalIntegrated = A22CombineIntegratedResults[{leadingResult,
             subleadingResult, nfResult}, breveResult];
          treeDiags = <|"Leading" -> leadingDiag, "Subleading" -> subleadingDiag,
             "Nf" -> nfDiag|>;
          If[TrueQ[progressActive],
            heavyIntegrationProgressPrint[routeKind, key, componentInput,
               contributionInput, 4, 6, "collecting diagnostics"]
          ];
          diagnostics = A22CombineIntegratedComponentDiagnostics[treeDiags,
             breveDiag, finalIntegrated, componentInput, Lookup[options, "ReturnTTerms",
             False]];
          diagnosticsWithMetadata = Join[diagnostics, <|"SourceObject"
             -> obj, "AntennaObject" -> obj, "RouteStory" -> IntegrationRouteStory[
            key]|>];
          recordStages = CollectIntegrationRecordStages[Lookup[data,
            "Antenna", $Failed], Lookup[diagnostics, "RawIntegrated", Missing["NotAvailable"
            ]], Lookup[diagnostics, "TTerms", Missing["NotAvailable"]], finalIntegrated,
             finalIntegrated, <|"TwoLoopTree" -> treeDiags, "OneLoopSelf" -> breveDiag
            |>, diagnosticsWithMetadata];
          If[TrueQ[progressActive],
            heavyIntegrationProgressPrint[routeKind, key, componentInput,
               contributionInput, 6, 6, "formatting public return"]
          ];
          finishProgress;
          Return[FormatFreshIntegrationReturn[finalIntegrated, diagnosticsWithMetadata,
             Lookup[options, "ReturnDiagnostics", False], Lookup[options, "ReturnRecord",
             False], intermediateSteps, Lookup[options, "PrintIntermediateSteps",
             False], routeKind, recordStages, recordMetadata]]
      ]
    ];
    If[Lookup[profile, "ImplementationStatus", "Implemented"] === "ScaffoldOnly"
       && Lookup[profile, "BasisFamily", Missing["NoFamily"]] =!= "MX30",
      diagnostics = <|"Failed" -> True, "Reason" -> "IntegratedAntennaNotImplemented",
         "Profile" -> profile, "ContributionsUsed" -> AntennaContributionsUsed[key,
         componentInput]|>;
      finishProgress;
      Return[FormatFreshIntegrationReturn[$Failed, Join[diagnostics,
        <|"SourceObject" -> obj, "AntennaObject" -> obj, "RouteStory" -> IntegrationRouteStory[
        key]|>], Lookup[options, "ReturnDiagnostics", False], Lookup[options,
         "ReturnRecord", False], intermediateSteps, Lookup[options, "PrintIntermediateSteps",
         False], routeKind, CollectIntegrationRecordStages[Lookup[data, "Antenna",
         $Failed], $Failed, $Failed, $Failed, $Failed, <||>, diagnostics], recordMetadata
        ]]
    ];
    backend = profile["DefaultBackend"];
    storedComponent = Lookup[data, "SelectedComponent", All];
(* Selected A31/A40 calls reduce only the requested raw component.  A31's
   scalar post-processing below restores its component-specific counterterm
   and common A21 A30 extraction term; Component -> All retains the combined
   payload and existing list-valued path. *)
    antenna =
      If[
        MemberQ[{{A, 3, 1}, {A, 4, 0}}, key] &&
          componentName =!= "All",
        SelectAntennaComponent[
          Lookup[data, "IntegrationFullAntenna",
            Lookup[data, "FullAntenna", Lookup[data, "Antenna", $Failed]]],
          key,
          componentInput
        ],
        Lookup[data, "IntegrationFullAntenna",
          Lookup[data, "FullAntenna", Lookup[data, "Antenna", $Failed]]]
      ];
(* The unreplaced master combination is a backend diagnostic payload.  A

   direct public ReturnMasterCombination request must therefore retain the

   same IBP diagnostics that BuildAndIntegrateAntenna collects internally.

   Otherwise the later public-result resolver has nothing to expose.
  *)
    ibpNeedsDiagnostics = TrueQ[Lookup[options, "ReturnDiagnostics",
      False]] || TrueQ[Lookup[options, "ReturnRecord", False]] || TrueQ[Lookup[
      options, "ReturnMasterCombination", False]];
    If[TrueQ[progressActive],
      heavyIntegrationProgressPrint[routeKind, key, componentInput, contributionInput,
         2, 6, "running backend reduction"]
    ];
    rawIntegrated =
      Switch[backend,
        PaVe,
          IntegrateViaPaVe[antenna, profile, True, Lookup[options, "ApplyFeynCalcMS",
             False], Lookup[options, "quarkMass", 0], PaVeEvaluation -> Lookup[profile,
             "PaVeEvaluation", "PaXEvaluate"], ExpansionOrder -> expansionOrder, KinematicScale
             -> Lookup[profile, "KinematicScale", Lookup[options, "KinematicScale",
             q2]], NormalizeKinematicScale -> Lookup[options, "NormalizeKinematicScale",
             False], LoopMomentum -> Lookup[options, "LoopMomentum", l], ApplyDimReg
             -> Lookup[options, "ApplyDimReg", True]]
        ,
        IBP,
          ibpResult =
            IntegrateViaIBP[
              antenna
              ,
              NumFinalParticles -> key[[2]]
              ,
              NumLoops -> key[[3]]
              ,
              BasisFamily ->
                If[Lookup[options, "BasisFamily", Automatic] === Automatic,

                  Lookup[profile, "BasisFamily", Automatic]
                  ,
                  Lookup[options, "BasisFamily", Automatic]
                ]
              ,
              BasisRoot -> Lookup[options, "BasisRoot", Automatic]
              ,
              GenerateMissingBases -> Lookup[options, "GenerateMissingBases",
                 False]
              ,
              ExpansionOrder -> expansionOrder
              ,
              ReturnDiagnostics -> ibpNeedsDiagnostics
              ,
              DetailedTimingDiagnostics -> Lookup[options, "DetailedTimingDiagnostics",
                 False]
              ,
              MassSymbol -> Lookup[profile, "MassSymbol", Automatic]
              ,
              ApplyFeynCalcMS -> Lookup[options, "ApplyFeynCalcMS", False
                ]
              ,
              KinematicScale -> Lookup[profile, "KinematicScale", Lookup[
                options, "KinematicScale", q2]]
              ,
              NormalizeKinematicScale -> Lookup[options, "NormalizeKinematicScale",
                 False]
            ];
          If[TrueQ[ibpNeedsDiagnostics],
            backendDiagnostics = ibpResult[[2]];
            ibpResult[[1]]
            ,
            backendDiagnostics = <||>;
            ibpResult
          ]
        ,
        _,
          Print["Unsupported integration backend for antenna ", key,
            ": ", backend, ". Aborting..."];
          $Failed
      ];
    tTerms =
      If[rawIntegrated === $Failed,
        $Failed
        ,
        IntegratedAntennaTTerms[key, rawIntegrated, ExpansionOrder ->
           expansionOrder, Component -> If[
             MemberQ[{{A, 3, 1}, {A, 4, 0}}, key] && componentName =!= "All",
             componentInput,
             All
           ]]
      ];
    If[TrueQ[progressActive],
      heavyIntegrationProgressPrint[routeKind, key, componentInput, contributionInput,
         3, 6, "constructing T-terms"]
    ];
    finalIntegrated =
      If[rawIntegrated === $Failed,
        $Failed
        ,
        If[Lookup[options, "ReturnTTerms", False] === True,
          tTerms
          ,
          ExtractIntegratedAntenna[key, tTerms, ExpansionOrder -> expansionOrder
            , Component -> If[
              MemberQ[{{A, 3, 1}, {A, 4, 0}}, key] && componentName =!= "All",
              componentInput,
              All
            ]]
        ]
      ];
    If[TrueQ[progressActive],
      heavyIntegrationProgressPrint[routeKind, key, componentInput, contributionInput,
         4, 6, "extracting integrated result"]
    ];
    (* Direct A31/A40 component routes are scalar by this point, so each is
       already the requested result. *)
    selectedIntegrated = SelectAntennaComponent[finalIntegrated, key,
       If[MemberQ[{{A, 3, 1}, {A, 4, 0}}, key] && componentName =!= "All",
          All, componentInput]];
    If[TrueQ[progressActive],
      heavyIntegrationProgressPrint[routeKind, key, componentInput, contributionInput,
         5, 6, "collecting diagnostics"]
    ];
    diagnostics =
      Join[
        IntegratedAntennaDiagnostics[key, antenna, finalIntegrated, profile,
           <|"RawIntegrated" -> rawIntegrated, "TTerms" -> tTerms, "ReturnTTerms"
           -> Lookup[options, "ReturnTTerms", False], "ExpansionOrder" -> expansionOrder,
           "SelectedComponent" -> componentInput, "BuildComponent" -> storedComponent
          |>]
        ,
        If[rawIntegrated === $Failed && AssociationQ[backendDiagnostics
          ] && KeyExistsQ[backendDiagnostics, "Reason"],
          <|"Failed" -> True, "Reason" -> backendDiagnostics["Reason"
            ]|>
          ,
          <||>
        ]
        ,
        If[AssociationQ[backendDiagnostics] && Length[backendDiagnostics
          ] > 0,
          <|"BackendDiagnostics" -> backendDiagnostics|>
          ,
          <||>
        ]
      ];
    collectedSteps = CollectIntegrationIntermediateSteps[antenna, rawIntegrated,
       tTerms, finalIntegrated, selectedIntegrated, backendDiagnostics, diagnostics,
       intermediateSteps];
    diagnosticsWithMetadata =
      Join[
        diagnostics
        ,
        <|"SelectedComponent" -> componentInput, "BuildComponent" ->
          storedComponent, "ContributionsUsed" -> AntennaContributionsUsed[key,
          componentInput], "RawIntegrated" -> rawIntegrated, "TTerms" -> tTerms,
           "SourceObject" -> obj, "AntennaObject" -> obj, "RouteStory" -> IntegrationRouteStory[
          key]|>
        ,
        If[Length[collectedSteps] > 0,
          <|"IntermediateSteps" -> collectedSteps|>
          ,
          <||>
        ]
      ];
    recordStages = CollectIntegrationRecordStages[antenna, rawIntegrated,
       tTerms, finalIntegrated, selectedIntegrated, backendDiagnostics, diagnosticsWithMetadata
      ];
    {publicResult, publicDiagnostics} = ResolveIntegrationPublicResult[
      selectedIntegrated, diagnosticsWithMetadata, Lookup[options, "ReturnMasterCombination",
       False], ToString[key, InputForm]];
    output = FormatFreshIntegrationReturn[publicResult, publicDiagnostics,
       Lookup[options, "ReturnDiagnostics", False], Lookup[options, "ReturnRecord",
       False], intermediateSteps, Lookup[options, "PrintIntermediateSteps",
       False], routeKind, recordStages, recordMetadata];
    If[TrueQ[progressActive],
      heavyIntegrationProgressPrint[routeKind, key, componentInput, contributionInput,
         6, 6, "formatting public return"]
    ];
    If[!TrueQ[$AntennaPipelineDeferMasterBasisPrint] && Lookup[publicDiagnostics,
       "RequestedResultKind", Missing["Absent"]] === "MasterCombination",
      PrintMasterCombinationBasisSummary[publicResult, publicDiagnostics
        ]
    ];
    finishProgress;
    output
  ];

(* BuildAndIntegrateRouteResult[type, numFinalParticles, loopOrder, options]
   =========================================================================
   The one-shot public entry point has no independent physics, backend, or
   stored-result path.  It builds the canonical integrable view and gives that
   exact object (or exact component-object list) to IntegrateAntenna. *)

BuildAndIntegrateCombinedRecord[key_, result_, diagnostics_Association,
   buildRecord_AntennaRunRecord, integrationRecord_, antennaObject_] :=
  Module[{integrationRecords, integrationSteps, componentNames,
     masterRecordAliases, componentMasterAliases},
    integrationRecords = If[ListQ[integrationRecord], integrationRecord,
      {integrationRecord}];
    integrationSteps = If[Length[integrationRecords] === 1,
      integrationRecords[[1]]["IntermediateSteps"],
      AssociationThread[
        CanonicalAntennaComponentName /@ (AntennaComponent /@ antennaObject),
        (# ["IntermediateSteps"]& /@ integrationRecords)]
      ];
    (* The one-shot record is a public composition of the build and integration
       records.  Promote the unreplaced master-combination aliases from a
       single integrated component so record["MasterCombination"] has the
       same meaning as it does for IntegrateAntenna.  Previously the payload
       existed only below "IntegrationRecord", leaving the documented C40
       record lookup as Missing[...]. *)
    componentNames =
      If[ListQ[antennaObject],
        CanonicalAntennaComponentName /@ (AntennaComponent /@ antennaObject),
        {CanonicalAntennaComponentName[Lookup[diagnostics,
          "SelectedComponent", All]]}
      ];
    componentMasterAliases =
      If[AllTrue[integrationRecords, AntennaRunRecordQ],
        AssociationThread[componentNames,
          AntennaRunRecordValue[#, "MasterCombination"]& /@ integrationRecords],
        <||>
      ];
    masterRecordAliases =
      If[Length[integrationRecords] === 1 &&
          AntennaRunRecordQ[First[integrationRecords]],
        KeyTake[AntennaRunRecordData[First[integrationRecords]], {
          "IntegratedResultKind", "OpenMasterValuesQ",
          "RawLiteRedCombination", "MasterMappedExpression",
          "RawMasterCombination", "MasterCombination",
          "MasterCombinationView", "MasterSubstitutedExpression",
          "NormalizedBeforeSeries", "SeriesResult",
          "OpenMasterRouteAvailable", "OpenMasterRouteSucceeded",
          "OpenMasterSubstitutedExpression", "OpenMasterSeriesResult",
          "OpenMasterRouteDiagnostics"
        }],
        If[AssociationQ[componentMasterAliases] &&
            Length[componentMasterAliases] > 0,
          <|"MasterCombination" -> componentMasterAliases,
            "RawMasterCombination" -> AssociationThread[componentNames,
              AntennaRunRecordValue[#, "RawMasterCombination"]& /@
                integrationRecords],
            "MasterCombinationView" -> AssociationThread[componentNames,
              AntennaRunRecordValue[#, "MasterCombinationView"]& /@
                integrationRecords]|>,
          <||>
        ]
      ];
    MakeAntennaRunRecord[
      Join[
        <|
          "RouteKind" -> "BuildAndIntegrateAntenna",
          "Result" -> result,
          "Diagnostics" -> diagnostics,
          "IntermediateSteps" -> <|"Build" -> buildRecord["IntermediateSteps"],
            "Integration" -> integrationSteps|>,
          "BuildRecord" -> buildRecord,
          "IntegrationRecord" -> If[Length[integrationRecords] === 1,
            First[integrationRecords], integrationRecords],
          "BuildData" -> buildRecord["BuildData"],
          "BuildDiagnostics" -> buildRecord["Diagnostics"],
          "SourceObject" -> antennaObject,
          "AntennaObject" -> antennaObject,
          "Key" -> key,
          "SelectedComponent" -> Lookup[diagnostics, "SelectedComponent", All],
          "ContributionsUsed" -> Lookup[diagnostics, "ContributionsUsed",
            Missing["NotAvailable"]]
        |>,
        masterRecordAliases
      ]
    ]
  ];

BuildAndIntegrateRouteResult[type_, numFinalParticles_Integer, loopOrder_Integer,
   options_Association] :=
  Module[{key = {type, numFinalParticles, loopOrder}, buildOutput, buildRecord,
     buildDiagnostics, antennaObject, integrateOptions, integrationOutput,
     integrationRecords, integrationResult, integrationDiagnostics, diagnostics,
     intermediateSteps, recordMetadata, combinedRecord, returnRecord},
    intermediateSteps = NormalizeIntermediateSteps[Lookup[options,
      "IntermediateSteps", {}]];
    returnRecord = TrueQ[Lookup[options, "ReturnRecord", False]];
    recordMetadata = <|"Key" -> key, "SelectedComponent" -> Lookup[options,
       "Component", All], "ContributionsUsed" -> AntennaContributionsUsed[key,
       Lookup[options, "Component", All]], "RouteStory" -> IntegrationRouteStory[key],
       "PrintComponentLegend" -> Lookup[options, "PrintComponentLegend", Automatic]|>;
    MaybeWarnHeavyIntegrationRoute[key, Lookup[options, "Component", All],
      AntennaInternalContribution[key, Lookup[options, "Component", All]]];
    heavyIntegrationProgressPrint["BuildAndIntegrateAntenna", key,
      Lookup[options, "Component", All], All, 1, 3, "building antenna"];
    buildOutput = BuildAntenna[type, numFinalParticles, loopOrder,
      ReturnDiagnostics -> True, ReturnRecord -> False,
      IntegrableForm -> True, quarkMass -> Lookup[options, "quarkMass", 0],
      ApplyDimReg -> Lookup[options, "ApplyDimReg", True],
      LoopMomentum -> Lookup[options, "LoopMomentum", l],
      Component -> Lookup[options, "Component", All],
      IntermediateSteps -> Lookup[options, "IntermediateSteps", {}],
      PrintIntermediateSteps -> Lookup[options, "PrintIntermediateSteps", False],
      PrintComponentLegend -> False,
      UseStoredResults -> Lookup[options, "UseStoredResults", False],
      StoreResults -> Lookup[options, "StoreResults", False],
      ResultsCacheRoot -> Lookup[options, "ResultsCacheRoot", Automatic],
      RefreshStoredResults -> Lookup[options, "RefreshStoredResults", False]];
    If[MatchQ[buildOutput, {_, _Association}],
      {antennaObject, buildDiagnostics} = buildOutput,
      antennaObject = buildOutput;
      buildDiagnostics = <||>
    ];
    If[returnRecord,
      buildRecord = BuildRunRecord["BuildAntenna", antennaObject,
        buildDiagnostics, <|"AntennaObject" -> antennaObject,
          "BuildData" -> Lookup[buildDiagnostics, "BuildData",
            Missing["NotAvailable"]]|>, recordMetadata]
    ];
    If[antennaObject === $Failed || MatchQ[antennaObject, _Missing],
      diagnostics = Join[buildDiagnostics, <|"Failed" -> True,
        "Reason" -> "BuildStageFailed"|>, recordMetadata];
      Return[FormatFreshIntegrationReturn[$Failed, diagnostics,
        Lookup[options, "ReturnDiagnostics", False], False, intermediateSteps,
        Lookup[options, "PrintIntermediateSteps", False],
        "BuildAndIntegrateAntenna", Automatic, recordMetadata]]
    ];
    heavyIntegrationProgressPrint["BuildAndIntegrateAntenna", key,
      Lookup[options, "Component", All], All, 2, 3, "integrating antenna"];
    integrateOptions = BuildAndIntegrateIntegrationOptions[options];
    integrationOutput = Block[{$AntennaPipelineDeferMasterBasisPrint = True},
      IntegrateAntenna[antennaObject, Sequence @@ integrateOptions]
      ];
    If[returnRecord,
      integrationRecords = integrationOutput;
      integrationResult = If[ListQ[integrationRecords],
        # ["Result"]& /@ integrationRecords, integrationRecords["Result"]];
      integrationDiagnostics = If[ListQ[integrationRecords],
        <|"ComponentDiagnostics" -> AssociationThread[
          CanonicalAntennaComponentName /@ (AntennaComponent /@ antennaObject),
          (# ["Diagnostics"]& /@ integrationRecords)]|>,
        integrationRecords["Diagnostics"]],
      If[ListQ[antennaObject],
        integrationResult = First /@ integrationOutput;
        integrationDiagnostics = <|"ComponentDiagnostics" -> AssociationThread[
          CanonicalAntennaComponentName /@ (AntennaComponent /@ antennaObject),
          Last /@ integrationOutput]|>,
        {integrationResult, integrationDiagnostics} = integrationOutput
      ]
    ];
    diagnostics = Join[buildDiagnostics, integrationDiagnostics, recordMetadata,
      <|"SourceObject" -> antennaObject, "AntennaObject" -> antennaObject|>,
      If[TrueQ[Lookup[options, "ReturnMasterCombination", False]],
        <|"RequestedResultKind" -> "MasterCombination"|>, <||>]];
    heavyIntegrationProgressPrint["BuildAndIntegrateAntenna", key,
      Lookup[options, "Component", All], All, 3, 3, "integration complete"];
    If[TrueQ[Lookup[options, "ReturnMasterCombination", False]],
      PrintMasterCombinationBasisSummary[integrationResult, diagnostics]
    ];
    If[returnRecord,
      combinedRecord = BuildAndIntegrateCombinedRecord[key, integrationResult,
        diagnostics, buildRecord, integrationRecords, antennaObject];
      If[TrueQ[Lookup[options, "PrintIntermediateSteps", False]],
        PrintIntermediateStepsAssociation[combinedRecord["IntermediateSteps"]]
      ];
      Return[combinedRecord]
    ];
    FormatFreshIntegrationReturn[integrationResult, diagnostics,
      Lookup[options, "ReturnDiagnostics", False], False, intermediateSteps,
      False, "BuildAndIntegrateAntenna", Automatic, recordMetadata]
  ];
