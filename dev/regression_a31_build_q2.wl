(*
  Fresh-kernel regression for A31 public-build PaVe kinematic arguments.

  Run with:
    Get["/path/to/AntCalc/dev/regression_a31_build_q2.wl"]
*)

packageRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{packageRoot, "AntennaPipeline.wl"}]];

{elapsed, result} = AbsoluteTiming[TimeConstrained[
  BuildAntenna[A, 3, 1, Component -> All,
    PrintComponentLegend -> False,
    UseStoredResults -> False,
    StoreResults -> False],
  600, $TimedOut]];

Print["A31_BUILD_SECONDS = ", elapsed];
Print["A31_BUILD_STATUS = ",
  If[result === $TimedOut, "Timed out", Head[result]]];

If[result =!= $TimedOut,
  scalarCalls = Cases[result,
    _Global`PaVe | _FeynCalc`PaVe |
    _Global`B0 | _FeynCalc`B0 |
    _Global`C0 | _FeynCalc`C0 |
    _Global`D0 | _FeynCalc`D0,
    Infinity];
  oldKinematicSumCalls = Select[scalarCalls,
    !FreeQ[#, HoldPattern[s12 + s13 + s23]] &];
  Print["SCALAR_CALL_COUNT = ", Length[scalarCalls]];
  Print["OLD_SUM_CALL_COUNT = ", Length[oldKinematicSumCalls]];
  Print["SCALAR_CALLS_USE_Q2 = ", !FreeQ[scalarCalls, q2]];
  Print["SCALAR_CALL_SAMPLE = ",
    InputForm[Take[scalarCalls, Min[4, Length[scalarCalls]]]]]
];
