(* One fresh-kernel massive-A30 epsilon-depth benchmark.
   The shell driver starts this worker once per order, so timings include
   package startup and cannot borrow an in-memory result from another order. *)

repoRoot = Nest[DirectoryName, $InputFileName, 4];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

order = ToExpression[Environment["ANTCALC_MX30_BENCHMARK_ORDER"]];
If[!IntegerQ[order] || order < 0,
  Print[ExportString[<|"Status" -> "Failed", "Reason" -> "InvalidExpansionOrder"|>, "RawJSON"]];
  Exit[1]
];

timeoutSeconds = ToExpression[Environment["ANTCALC_MX30_BENCHMARK_TIMEOUT"]];
If[!IntegerQ[timeoutSeconds] || timeoutSeconds <= 0, timeoutSeconds = 600];

ClearAll[exactZeroQ, noRuntimeArtifactsQ];
exactZeroQ[expr_] := TrueQ[Quiet[Check[Together[expr] === 0, False]]];
noRuntimeArtifactsQ[expr_] :=
  expr =!= $Failed && !MissingQ[expr] &&
    FreeQ[expr, HoldPattern[LiteRed`j[___]]] &&
    FreeQ[expr, l | l1 | l2 | p1 | p2] &&
    FreeQ[expr, FeynCalc`FeynAmpDenominator];

timedOut = False;
{elapsed, record} = AbsoluteTiming[
  TimeConstrained[
    BuildAndIntegrateAntenna[
      A, 3, 0,
      quarkMass -> mQ,
      ExpansionOrder -> order,
      ReturnRecord -> True,
      UseStoredResults -> False,
      StoreResults -> False,
      DetailedTimingDiagnostics -> False
    ],
    timeoutSeconds,
    (timedOut = True; $Aborted)
  ]
];

reference = If[timedOut || record === $Failed || record === $Aborted,
  Missing["NotComputed"],
  MassiveA30IntegratedRuntimeSeries[mQ, order, True]
];
recordResult = Quiet[Check[record["Result"], Missing["ResultUnavailable"]]];
recordKind = Quiet[Check[record["IntegratedResultKind"],
  Missing["IntegratedResultKindUnavailable"]]];
result = If[MissingQ[recordResult], record, recordResult];
matchQ = !timedOut && exactZeroQ[result - reference];
artifactFreeQ = !timedOut && noRuntimeArtifactsQ[result];
routeKindQ = !timedOut &&
  TrueQ[recordKind === "ClosedDerivedMX30Series"];

report = <|
  "SchemaVersion" -> 1,
  "Benchmark" -> "MassiveA30EpsilonDepth",
  "FreshKernel" -> True,
  "ExpansionOrder" -> order,
  "TimeoutSeconds" -> timeoutSeconds,
  "WallClockSeconds" -> N[elapsed],
  "TimedOut" -> timedOut,
  "ReturnedFailed" -> TrueQ[record === $Failed],
  "Checks" -> <|
    "DerivedMX30RouteQ" -> routeKindQ,
    "MatchesRuntimeReferenceQ" -> matchQ,
    "NoRuntimeArtifactsQ" -> artifactFreeQ
  |>
|>;
report = Append[report, "Passed" -> !timedOut && And @@ Values[report["Checks"]]];
Print[ExportString[report, "RawJSON"]];
Exit[Which[timedOut, 2, TrueQ[report["Passed"]], 0, True, 1]];
