(* Fresh-kernel cache-provenance regression: the one-shot wrapper may reuse
   only its canonical BuildAntenna and IntegrateAntenna stage caches. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
If[!ValueQ[$AntennaPipelineRoot],
  Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]]
];

ClearAll[cacheRoot, seeded, replayed, buildCache, integrationCache, report];

cacheRoot = CreateDirectory[];

seeded = BuildAndIntegrateAntenna[A, 3, 0,
  ReturnRecord -> True,
  UseStoredResults -> True,
  StoreResults -> True,
  ResultsCacheRoot -> cacheRoot];

replayed = BuildAndIntegrateAntenna[A, 3, 0,
  ReturnRecord -> True,
  UseStoredResults -> True,
  StoreResults -> False,
  ResultsCacheRoot -> cacheRoot];

buildCache = replayed["BuildRecord"]["Diagnostics"]["StoredResultCache"];
integrationCache = replayed["IntegrationRecord"]["Diagnostics"]["StoredResultCache"];

report = <|
  "Regression" -> "BuildAndIntegrateCacheContract",
  "Checks" -> <|
    "NoOneShotCacheRouteKind" ->
      !MemberQ[$StoredResultRouteKinds, "BuildAndIntegrateAntenna"],
    "NoOneShotCacheDirectory" ->
      !DirectoryQ[FileNameJoin[{cacheRoot, "build_and_integrate"}]],
    "BuildStageCacheReused" ->
      AssociationQ[buildCache] && buildCache["RouteKind"] === "BuildAntenna",
    "IntegrationStageCacheReused" ->
      AssociationQ[integrationCache] &&
        integrationCache["RouteKind"] === "IntegrateAntenna",
    "CombinedRecordKeepsStageCacheProvenance" ->
      AntennaRunRecordQ[replayed] &&
        AntennaRunRecordQ[replayed["BuildRecord"]] &&
        AntennaRunRecordQ[replayed["IntegrationRecord"]]
    |>
  |>;
report = Join[report, <|"Passed" -> And @@ Values[report["Checks"]]|>];
Print[report];

Quiet[Check[DeleteDirectory[cacheRoot, DeleteContents -> True], Null]];
