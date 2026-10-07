(* Fresh-kernel regression: an advisory message must not make the release
   worker classify a successful public route as $Failed. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

ClearAll[runTimedLikeReleaseWorker, object, call, result, diagnostics, report];

runTimedLikeReleaseWorker[thunk_] := Module[{seconds, value},
  {seconds, value} = AbsoluteTiming[Quiet[thunk[]]];
  <|"Seconds" -> N[seconds], "Value" -> value|>
];

object = BuildAntenna[B, 4, 0, IntegrableForm -> True,
  UseStoredResults -> False, StoreResults -> False];
call = runTimedLikeReleaseWorker[Function[
  IntegrateAntenna[object, ReturnDiagnostics -> True, ExpansionOrder -> 0,
    UseStoredResults -> False, StoreResults -> False]
]];

If[MatchQ[call["Value"], {_, _Association}],
  {result, diagnostics} = call["Value"],
  result = call["Value"]; diagnostics = <||>
];

report = <|
  "Regression" -> "ReleaseWorkerMessageContract",
  "Checks" -> <|
    "B40IntegrationResultIsNotFailed" -> (result =!= $Failed),
    "B40IntegrationDiagnosticsReturned" -> AssociationQ[diagnostics]
    |>
  |>;
report = Join[report, <|"Passed" -> And @@ Values[report["Checks"]]|>];
Print[report];
Quit[];
