(* Fresh-kernel beta regression for the derived massive A30 MX30 closure.
   This test deliberately runs both the public closed route and the developer
   forced-MX30 route.  The latter must substitute every runtime master before
   its result is exposed. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

ClearAll[exactZeroQ, noRuntimeArtifactsQ, report];

exactZeroQ[expr_] := TrueQ[Together[expr] === 0];

noRuntimeArtifactsQ[expr_] :=
  expr =!= $Failed && !MissingQ[expr] &&
    FreeQ[expr, HoldPattern[LiteRed`j[___]]] &&
    FreeQ[expr, l | l1 | l2 | p1 | p2] &&
    FreeQ[expr, FeynCalc`FeynAmpDenominator];

publicRecord = BuildAndIntegrateAntenna[
  A, 3, 0,
  quarkMass -> mQ,
  ExpansionOrder -> 0,
  ReturnRecord -> True,
  UseStoredResults -> False,
  StoreResults -> False,
  DetailedTimingDiagnostics -> False
];

forcedRecord = Block[{$MassiveA30ForceIBPMasterRoute = True},
  BuildAndIntegrateAntenna[
    A, 3, 0,
    quarkMass -> mQ,
    ExpansionOrder -> 0,
    ReturnRecord -> True,
    UseStoredResults -> False,
    StoreResults -> False,
    DetailedTimingDiagnostics -> False
  ]
];

reference = MassiveA30IntegratedRuntimeSeries[mQ, 0, True];
cutMeasure = MassiveA30IntegratedCutMeasureConsistencyReport[];
runtimeMatch = MassiveA30IntegratedRuntimeMatchReport[];
paperI2 = MassiveA30IntegratedExperimentalPaperI2Relation[];

report = <|
  "SchemaVersion" -> 1,
  "Regression" -> "MassiveA30DerivedMX30Beta",
  "FreshKernel" -> True,
  "CachePolicy" -> <|"UseStoredResults" -> False, "StoreResults" -> False|>,
  "Checks" -> <|
    "PublicRouteKindQ" ->
      TrueQ[publicRecord["IntegratedResultKind"] === "ClosedDerivedMX30Series"],
    "PublicResultMatchesOrderZeroReferenceQ" ->
      exactZeroQ[publicRecord["Result"] - reference],
    "PublicResultHasNoRuntimeArtifactsQ" ->
      noRuntimeArtifactsQ[publicRecord["Result"]],
    "ForcedMasterSubstitutionPresentQ" ->
      forcedRecord["MasterSubstitutedExpression"] =!= $Failed &&
        !MissingQ[forcedRecord["MasterSubstitutedExpression"]],
    "ForcedMasterSubstitutionHasNoRuntimeArtifactsQ" ->
      noRuntimeArtifactsQ[forcedRecord["MasterSubstitutedExpression"]],
    "ForcedResultHasNoRuntimeArtifactsQ" ->
      noRuntimeArtifactsQ[forcedRecord["Result"]],
    "ForcedResultMatchesOrderZeroReferenceQ" ->
      exactZeroQ[forcedRecord["Result"] - reference],
    "CutMeasureConsistencyQ" -> TrueQ[cutMeasure["MatchQ"]],
    "RuntimeMasterClosureQ" -> TrueQ[runtimeMatch["MatchQ"]],
    "PaperI2ReductionQ" -> TrueQ[paperI2["MatchQ"]]
  |>,
  "Reference" -> "MassiveA30IntegratedRuntimeSeries[mQ, 0, True]",
  "PublicRouteKind" -> publicRecord["IntegratedResultKind"],
  "CutMeasureFactor" -> MassiveA30IntegratedCutMeasureFactor[]
|>;

report = Append[report, "Passed" -> And @@ Values[report["Checks"]]];
Print[ExportString[report, "RawJSON"]];
Exit[If[TrueQ[report["Passed"]], 0, 1]];
