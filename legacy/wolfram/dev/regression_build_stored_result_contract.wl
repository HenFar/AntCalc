(* Regression: BuildStoredResultContract
   -------------------------------------
   Uses a private temporary cache root.  The first call seeds a current cache
   entry; the second must be a hit without recomputing the A20 build. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "AntennaPipeline.wl"}]];

cacheRoot = FileNameJoin[{$TemporaryDirectory,
  "AntCalc-BuildCache-" <> CreateUUID[]}];

Internal`WithLocalSettings[
  Null,
  first = BuildAntenna[A, 2, 0,
    UseStoredResults -> True, StoreResults -> True,
    ResultsCacheRoot -> cacheRoot, ReturnDiagnostics -> True];
  second = BuildAntenna[A, 2, 0,
    UseStoredResults -> True, StoreResults -> False,
    ResultsCacheRoot -> cacheRoot, ReturnDiagnostics -> True];
  report = <|"Regression" -> "BuildStoredResultContract",
    "Checks" -> <|
      "FirstResultStored" -> !TrueQ[Lookup[first[[2]], "StoredResultCache",
        <||>]["LoadedFromStoredResults"]],
      "SecondCallLoadedStoredResult" -> TrueQ[Lookup[second[[2]],
        "StoredResultCache", <||>]["LoadedFromStoredResults"]],
      "ResultsMatch" -> first[[1]] === second[[1]]
    |>|>;
  Print[report];
  report,
  If[DirectoryQ[cacheRoot], DeleteDirectory[cacheRoot,
    DeleteContents -> True]]
]
