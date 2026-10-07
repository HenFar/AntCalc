(* Regression: RRatioStoredResultContract
   --------------------------------------
   Exercises the driver-level BuildRRatio cache key and provenance on the
   inexpensive NLO surface.  NNLO uses the same key construction but is too
   costly for a routine cache-contract regression. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "AntennaPipeline.wl"}]];

ClearAll[cacheRoot, seeded, replayed, cacheInfo, report];

cacheRoot = FileNameJoin[{$TemporaryDirectory,
  "AntCalc-RRatioCache-" <> CreateUUID[]}];

Internal`WithLocalSettings[
  Null,
  seeded = BuildRRatio[SMQCD,
    maxOrder -> NLO,
    ReturnDiagnostics -> True,
    UseStoredResults -> True,
    StoreResults -> True,
    ResultsCacheRoot -> cacheRoot];
  replayed = BuildRRatio[SMQCD,
    maxOrder -> NLO,
    ReturnDiagnostics -> True,
    UseStoredResults -> True,
    StoreResults -> False,
    ResultsCacheRoot -> cacheRoot];
  cacheInfo = replayed[[2]]["StoredResultCache"];
  report = <|
    "Regression" -> "RRatioStoredResultContract",
    "Checks" -> <|
      "SeededResultWasFresh" ->
        !TrueQ[Lookup[seeded[[2]], "StoredResultCache", <||>][
          "LoadedFromStoredResults"]],
      "ReplayLoadedStoredResult" ->
        TrueQ[cacheInfo["LoadedFromStoredResults"]],
      "ReplayHasBuildRRatioProvenance" ->
        cacheInfo["RouteKind"] === "BuildRRatio",
      "ResultsMatch" -> seeded[[1]] === replayed[[1]],
      "ReferenceAgreementQ" -> TrueQ[replayed[[2]]["ReferenceAgreementQ"]]
      |>
    |>;
  report = Join[report, <|"Passed" -> And @@ Values[report["Checks"]]|>];
  Print[report];
  report,
  If[DirectoryQ[cacheRoot], DeleteDirectory[cacheRoot,
    DeleteContents -> True]]
]
