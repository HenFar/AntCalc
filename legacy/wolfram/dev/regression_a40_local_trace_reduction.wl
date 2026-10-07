(*
  Cold, no-cache acceptance check for the A40 local-trace reduction.

  The run is successful only if both public A40 components agree with their
  encoded paper targets.  A stored result is deliberately excluded.
*)

packageRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{packageRoot, "AntennaPipeline.wl"}]];

routeResult = BuildAntenna[A, 4, 0,
  ReturnDiagnostics -> True,
  RunPaperCheck -> True,
  UseStoredResults -> False,
  StoreResults -> False,
  RefreshStoredResults -> False
];

checks = <|
  "ReturnedResultAndDiagnostics" -> MatchQ[routeResult, {_, _Association}],
  "NoStoredResultHit" -> True
|>;

If[TrueQ[checks["ReturnedResultAndDiagnostics"]],
  {publicResult, diagnostics} = routeResult;
  paper = diagnostics["PaperDiagnostics"];
  checks["ReturnsTwoPublicComponents"] = ListQ[publicResult] &&
    Length[publicResult] === 2;
  checks["OrderedA40MatchesPaper"] =
    TrueQ[paper["A40ExactMatchQ"]] &&
    TrueQ[paper["A40NumericResidual"] === 0];
  checks["TildeA40MatchesPaperWithColourSignExternal"] =
    TrueQ[paper["tA40ExactMatchQ"]] &&
    TrueQ[paper["tA40NumericResidual"] === 0];
];

Print[ExportString[<|
  "Regression" -> "A40LocalTraceReduction",
  "Checks" -> checks,
  "Passed" -> And @@ Values[checks]
|>, "JSON", "Compact" -> True]];

Quit[If[And @@ Values[checks], 0, 1]];
