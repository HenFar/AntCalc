(* Fresh-kernel public API regression: direct AntennaObject integration and
   BuildAndIntegrateAntenna must expose identical integration options and
   identical unreplaced A30 master combinations. *)

If[!ValueQ[$AntennaPipelineRoot],
  Get[FileNameJoin[{DirectoryName[$InputFileName], "..",
      "AntennaPipeline.wl"}]]
];

ClearAll[a30Object, directDefault, wrappedDefault, directDiagnostics,
  wrappedDiagnostics, directMaster, wrappedMaster, directTTerms,
  wrappedTTerms, directRecord, wrappedRecord, optionNames, contract,
  forwardedRules, probeRules, report];

a30Object = BuildAntenna[A, 3, 0,
  IntegrableForm -> True,
  UseStoredResults -> False,
  StoreResults -> False];

directDefault = IntegrateAntenna[a30Object,
  UseStoredResults -> False,
  StoreResults -> False];

wrappedDefault = BuildAndIntegrateAntenna[A, 3, 0,
  UseStoredResults -> False,
  StoreResults -> False];

directDiagnostics = IntegrateAntenna[a30Object,
  ReturnDiagnostics -> True,
  UseStoredResults -> False,
  StoreResults -> False];

wrappedDiagnostics = BuildAndIntegrateAntenna[A, 3, 0,
  ReturnDiagnostics -> True,
  UseStoredResults -> False,
  StoreResults -> False];

directMaster = IntegrateAntenna[a30Object,
  ReturnMasterCombination -> True,
  UseStoredResults -> False,
  StoreResults -> False];

wrappedMaster = BuildAndIntegrateAntenna[A, 3, 0,
  ReturnMasterCombination -> True,
  UseStoredResults -> False,
  StoreResults -> False];

directTTerms = IntegrateAntenna[a30Object,
  ReturnTTerms -> True,
  UseStoredResults -> False,
  StoreResults -> False];

wrappedTTerms = BuildAndIntegrateAntenna[A, 3, 0,
  ReturnTTerms -> True,
  UseStoredResults -> False,
  StoreResults -> False];

directRecord = IntegrateAntenna[a30Object,
  ReturnRecord -> True,
  UseStoredResults -> False,
  StoreResults -> False];

wrappedRecord = BuildAndIntegrateAntenna[A, 3, 0,
  ReturnRecord -> True,
  UseStoredResults -> False,
  StoreResults -> False];

optionNames[head_] := Sort[First /@ Options[head]];
contract = IntegrationWrapperOptionContract[];
forwardedRules = Association[BuildAndIntegrateIntegrationOptions[<||>]];
probeRules = Association[BuildAndIntegrateIntegrationOptions[<|
  "ApplyFeynCalcMS" -> False, "quarkMass" -> testMass,
  "ExpansionOrder" -> 3,
  "KinematicScale" -> testScale, "NormalizeKinematicScale" -> False,
  "ReturnMasterCombination" -> True, "LoopMomentum" -> testLoop,
  "ApplyDimReg" -> False, "BasisFamily" -> testBasis,
  "BasisRoot" -> testRoot, "GenerateMissingBases" -> True,
  "ReturnTTerms" -> True, "IntermediateSteps" -> {"TTerms"},
  "PrintIntermediateSteps" -> True,
  "DetailedTimingDiagnostics" -> True, "UseStoredResults" -> True,
  "StoreResults" -> True, "ResultsCacheRoot" -> testCacheRoot,
  "RefreshStoredResults" -> True|>]];

report = <|
  "Regression" -> "IntegrationWrapperContract",
  "Checks" -> <|
    "IntegrationOptionSetsMatch" ->
      (optionNames[IntegrateAntenna] ===
        optionNames[BuildAndIntegrateAntenna]),
    "EveryPublicOptionHasOneShotDisposition" ->
      (optionNames[IntegrateAntenna] === Sort[Keys[contract]]),
    "ForwardedRulesCoverPhysicsAndReturnControls" ->
      ContainsAll[Keys[forwardedRules], {
        ApplyFeynCalcMS, quarkMass, ExpansionOrder,
        KinematicScale, NormalizeKinematicScale, ReturnDiagnostics,
        ReturnRecord, ReturnMasterCombination, LoopMomentum, ApplyDimReg,
        BasisFamily, BasisRoot, GenerateMissingBases, ReturnTTerms,
        IntermediateSteps, PrintIntermediateSteps,
        DetailedTimingDiagnostics, UseStoredResults, StoreResults,
        ResultsCacheRoot, RefreshStoredResults, Component
      }],
    "ForwardedRulesPreserveRequestedValues" ->
      And[
        probeRules[ApplyFeynCalcMS] === False,
        probeRules[quarkMass] === testMass,
        probeRules[ExpansionOrder] === 3,
        probeRules[KinematicScale] === testScale,
        probeRules[NormalizeKinematicScale] === False,
        probeRules[ReturnMasterCombination] === True,
        probeRules[LoopMomentum] === testLoop,
        probeRules[ApplyDimReg] === False,
        probeRules[BasisFamily] === testBasis,
        probeRules[BasisRoot] === testRoot,
        probeRules[GenerateMissingBases] === True,
        probeRules[ReturnTTerms] === True,
        probeRules[IntermediateSteps] === {"TTerms"},
        probeRules[PrintIntermediateSteps] === True,
        probeRules[DetailedTimingDiagnostics] === True,
        probeRules[UseStoredResults] === True,
        probeRules[StoreResults] === True,
        probeRules[ResultsCacheRoot] === testCacheRoot,
        probeRules[RefreshStoredResults] === True
      ],
    "DirectMasterCombinationReturned" -> directMaster =!= $Failed,
    "WrapperMasterCombinationReturned" -> wrappedMaster =!= $Failed,
    "DirectAndWrapperMasterCombinationsMatch" ->
      TrueQ[Together[directMaster - wrappedMaster] === 0],
    "DefaultResultsMatchExplicitComposition" ->
      TrueQ[Together[directDefault - wrappedDefault] === 0],
    "DiagnosticsResultsMatchExplicitComposition" ->
      MatchQ[directDiagnostics, {_, _Association}] &&
        MatchQ[wrappedDiagnostics, {_, _Association}] &&
        TrueQ[Together[directDiagnostics[[1]] - wrappedDiagnostics[[1]]] === 0],
    "TTermsMatchExplicitComposition" ->
      TrueQ[Together[directTTerms - wrappedTTerms] === 0],
    "OneShotRecordRetainsBothStageProvenances" ->
      AntennaRunRecordQ[wrappedRecord] &&
        AntennaRunRecordQ[wrappedRecord["BuildRecord"]] &&
        AntennaRunRecordQ[wrappedRecord["IntegrationRecord"]] &&
        TrueQ[Together[directRecord["Result"] - wrappedRecord["Result"]] === 0]
    |>
  |>;
report = Join[report, <|"Passed" -> And @@ Values[report["Checks"]]|>];
Print[report];
