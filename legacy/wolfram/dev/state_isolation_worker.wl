(* One isolated worker used by regression_state_isolation.wl.
   This file deliberately has no stored-result fallback: its only purpose is
   to compare a target call in a fresh kernel with the same target after a
   controlled sequence in one reused kernel. *)

workerRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{workerRoot, "AntennaPipeline.wl"}]];

(* WolframKernel -script does not populate $ScriptCommandLine on all supported
   kernel versions; $CommandLine consistently retains the script arguments. *)
workerArgs = $CommandLine;
workerMode = SelectFirst[workerArgs, MemberQ[{"fresh", "contaminated"}, #]&,
  "fresh"];
workerScenario = SelectFirst[
  workerArgs,
  MemberQ[{"A30ThenA40", "A30Sequential", "A21ThenA40", "A31ThenMX30",
    "MX30ThenA31", "A40ThenA30", "C40ThenA31ThenA22"}, #]&,
  "A30ThenA40"
];
workerTimeout = ToExpression[SelectFirst[workerArgs,
  StringMatchQ[#, DigitCharacter..]&,
  "300"
]];
workerCacheRoot = FileNameJoin[{$TemporaryDirectory,
  "antcalc-state-isolation-" <> CreateUUID[]}];

ClearAll[WorkerStateSnapshot, WorkerResultSignature, WorkerRun, WorkerCall];

WorkerStateSnapshot[] :=
  Module[{momenta, scalarProducts, globals, liteRedBases, resolvedPublicA},
    momenta = {k1, k2, k3, k4};
    scalarProducts = Association @ Flatten@Table[
      ToString[{momenta[[i]], momenta[[j]]}, InputForm] ->
        ToString[SPD[momenta[[i]], momenta[[j]]], InputForm],
      {i, Length[momenta]}, {j, i, Length[momenta]}
    ];
    globals = <|
      "$AntennaPipelineBypassStoredResults" ->
        ToString[OwnValues[$AntennaPipelineBypassStoredResults], InputForm],
      "$MassiveA30ForceIBPMasterRoute" ->
        ToString[OwnValues[$MassiveA30ForceIBPMasterRoute], InputForm],
      "$AntennaPipelineRuntimeMasterValues" ->
        ToString[OwnValues[$AntennaPipelineRuntimeMasterValues], InputForm],
      "$AntennaPipelineHeavyRouteNotices" ->
        ToString[OwnValues[$AntennaPipelineHeavyRouteNotices], InputForm]
    |>;
    liteRedBases = If[NameQ["LiteRed`j"],
      ToString[Select[Names["LiteRed`*"], StringStartsQ[#, "LiteRed`j"]&],
        InputForm],
      "NotLoaded"
    ];
    (* Resolve A at runtime rather than relying on the symbol parsed when this
       script was loaded.  This recreates the context-path condition that once
       made A22 reject an A symbol after LiteRed had been loaded. *)
    resolvedPublicA = ToExpression["A"];
    <|
      "CurrentContext" -> $Context,
      "ScalarProducts" -> scalarProducts,
      "ContextPath" -> $ContextPath,
      "RuntimePublicAContext" -> Context[resolvedPublicA],
      "ManagedOptions" -> <|
        "BuildAntenna" -> ToString[Options[BuildAntenna], InputForm],
        "BuildAntennaObject" -> ToString[Options[BuildAntennaObject], InputForm],
        "IntegrateAntenna" -> ToString[Options[IntegrateAntenna], InputForm],
        "BuildAndIntegrateAntenna" ->
          ToString[Options[BuildAndIntegrateAntenna], InputForm]
      |>,
      "PackageGlobals" -> globals,
      "LiteRedBasisSymbols" -> liteRedBases,
      "RuntimeMasterCachePresentQ" ->
        ValueQ[$AntennaPipelineRuntimeMasterValues]
    |>
  ];

WorkerResultSignature[result_] :=
  Module[{pointRules, pointValue, recordQ, master, publicResult, diagnostics,
     targetAgreement, masterAvailableQ, contractSatisfiedQ},
    pointRules = {q2 -> 17/5, s12 -> 7/5, s13 -> 11/5, s14 -> 13/5,
      s23 -> 19/5, s24 -> 23/5, s34 -> 29/5, SUNN -> 3,
      Nf -> 5, FeynCalc`Epsilon -> 1/17, Epsilon -> 1/17};
    recordQ = AntennaRunRecordQ[result];
    publicResult = Which[
      recordQ, AntennaRunRecordValue[result, "Result"],
      MatchQ[result, {_, _Association}], First[result],
      True, result
    ];
    diagnostics = Which[
      recordQ, AntennaRunRecordValue[result, "Diagnostics"],
      MatchQ[result, {_, diag_Association}], result[[2]],
      True, <||>
    ];
    pointValue = Quiet[Check[
      ToString[N[publicResult /. pointRules, 30], InputForm],
      "PointEvaluationFailed"
    ]];
    master = If[recordQ,
      AntennaRunRecordValue[result, "MasterCombination"],
      Missing["NoRunRecord"]
    ];
    targetAgreement = Lookup[Lookup[diagnostics, "PaperDiagnostics", <||>],
      "ExactMatchQ", Lookup[Lookup[diagnostics, "PaperDiagnostics", <||>],
        "A40ExactMatchQ", Missing["NotAvailable"]]];
    If[MissingQ[targetAgreement], targetAgreement = "NotAvailable"];
    masterAvailableQ = !MissingQ[master] && master =!= $Failed;
    contractSatisfiedQ =
      If[recordQ,
        masterAvailableQ && publicResult =!= $Failed,
        publicResult =!= $Failed
      ];
    <|
      "InputFormHash" -> Hash[ToString[publicResult, InputForm], "SHA256"],
      "FixedPhysicalPoint" -> pointValue,
      "ExactTargetAgreementQ" -> targetAgreement,
      "RunRecordQ" -> recordQ,
      "OpenMasterCombinationHash" -> If[MissingQ[master], "NotAvailable",
        Hash[ToString[master, InputForm], "SHA256"]],
      "MasterCombinationAvailableQ" -> masterAvailableQ,
      "ContractSatisfiedQ" -> contractSatisfiedQ,
      "FailedQ" -> TrueQ[result === $Failed],
      "TimedOutQ" -> TrueQ[result === $TimedOut]
    |>
  ];

SetAttributes[WorkerRun, HoldRest];
WorkerRun[label_String, expr_] :=
  Module[{seconds, result},
    {seconds, result} = AbsoluteTiming[
      TimeConstrained[expr, workerTimeout, $TimedOut]
    ];
    <|
      "Label" -> label,
      "Seconds" -> seconds,
      "Signature" -> WorkerResultSignature[result]
    |>
  ];

WorkerCall["A30Integrated"] :=
  BuildAndIntegrateAntenna[A, 3, 0,
    ReturnDiagnostics -> True,
    UseStoredResults -> False, StoreResults -> False,
    ResultsCacheRoot -> workerCacheRoot];

WorkerCall["A30Build"] :=
  BuildAntenna[A, 3, 0, ReturnDiagnostics -> True,
    UseStoredResults -> False, StoreResults -> False,
    ResultsCacheRoot -> workerCacheRoot];

WorkerCall["A40Build"] :=
  BuildAntenna[A, 4, 0, ReturnDiagnostics -> True,
    UseStoredResults -> False, StoreResults -> False,
    ResultsCacheRoot -> workerCacheRoot];

WorkerCall["A21Integrated"] :=
  BuildAndIntegrateAntenna[A, 2, 1,
    ReturnDiagnostics -> True,
    UseStoredResults -> False, StoreResults -> False,
    ResultsCacheRoot -> workerCacheRoot];

WorkerCall["A31Integrated"] :=
  BuildAndIntegrateAntenna[A, 3, 1,
    ReturnDiagnostics -> True,
    UseStoredResults -> False, StoreResults -> False,
    ResultsCacheRoot -> workerCacheRoot];

WorkerCall["C40MasterRecord"] :=
  BuildAndIntegrateAntenna[C, 4, 0,
    ReturnRecord -> True,
    UseStoredResults -> False, StoreResults -> False,
    ResultsCacheRoot -> workerCacheRoot];

WorkerCall["A22MasterRecord"] :=
  BuildAndIntegrateAntenna[ToExpression["A"], 2, 2,
    ReturnRecord -> True,
    UseStoredResults -> False, StoreResults -> False,
    ResultsCacheRoot -> workerCacheRoot];

WorkerCall["MX30OpenMaster"] :=
  Block[{$MassiveA30ForceIBPMasterRoute = True},
    BuildAndIntegrateAntenna[A, 3, 0, quarkMass -> mQ,
      ReturnRecord -> True, ReturnMasterCombination -> True,
      ExpansionOrder -> 0, UseStoredResults -> False, StoreResults -> False,
      ResultsCacheRoot -> workerCacheRoot]
  ];

WorkerScenarioCalls["A30ThenA40"] := {{"A30Integrated"}, "A40Build"};
WorkerScenarioCalls["A30Sequential"] :=
  {{"A30Integrated", "A30Integrated"}, "A30Build"};
WorkerScenarioCalls["A21ThenA40"] := {{"A21Integrated"}, "A40Build"};
WorkerScenarioCalls["A31ThenMX30"] := {{"A31Integrated"}, "MX30OpenMaster"};
WorkerScenarioCalls["MX30ThenA31"] := {{"MX30OpenMaster"}, "A31Integrated"};
WorkerScenarioCalls["A40ThenA30"] := {{"A40Build"}, "A30Integrated"};
WorkerScenarioCalls["C40ThenA31ThenA22"] :=
  {{"C40MasterRecord", "A31Integrated"}, "A22MasterRecord"};

{workerPredecessors, workerTarget} = WorkerScenarioCalls[workerScenario];
workerPrintLog = {};
workerBefore = WorkerStateSnapshot[];
workerPredecessorRuns = {};
workerTargetRun = Block[{Print = (AppendTo[workerPrintLog,
      ToString[Row[{##}], InputForm]]& )},
  If[workerMode === "contaminated",
    workerPredecessorRuns = WorkerRun[#, WorkerCall[#]]& /@ workerPredecessors
  ];
  WorkerRun[workerTarget, WorkerCall[workerTarget]]
];
workerAfter = WorkerStateSnapshot[];

workerReport = <|
  "SchemaVersion" -> 1,
  "Mode" -> workerMode,
  "Scenario" -> workerScenario,
  "TimeoutSeconds" -> workerTimeout,
  "CachePolicy" -> <|"UseStoredResults" -> False, "StoreResults" -> False,
    "ResultsCacheRoot" -> workerCacheRoot|>,
  "BeforeState" -> workerBefore,
  "PredecessorRuns" -> workerPredecessorRuns,
  "TargetRun" -> workerTargetRun,
  "AfterState" -> workerAfter,
  "StoredResultHitQ" -> AnyTrue[workerPrintLog,
    StringContainsQ[#, "Stored result"]&]
|>;

WriteString[$Output, "ANTCALC_STATE_REPORT=", ExportString[workerReport, "JSON", "Compact" -> True], "\n"];
