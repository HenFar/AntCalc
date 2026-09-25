(*
  Fresh-kernel timing for one A22 public build request. Run this script in five
  separate Wolfram kernels. Before Get, set $AntennaBuildTimingCase to one of
  Leading, Subleading, Nf, Breve, or IntegrableForm. No expansion-order
  override is supplied.
*)

packageRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{packageRoot, "AntennaPipeline.wl"}]];

buildCaseFromEnvironment = Environment["ANTCALC_BUILD_CASE"];
buildCase = If[StringQ[buildCaseFromEnvironment], buildCaseFromEnvironment,
  If[ValueQ[$AntennaBuildTimingCase], $AntennaBuildTimingCase, Missing["Unset"]]];
buildOptions = {
  PrintComponentLegend -> False,
  UseStoredResults -> False,
  StoreResults -> False
};
If[!MemberQ[{"Leading", "Subleading", "Nf", "Breve", "IntegrableForm"},
    buildCase],
  Print["INPUT_ERROR = ", InputForm[buildCase]];
  Abort[]
];

{elapsed, result} = Switch[buildCase,
  "Leading",
    AbsoluteTiming[TimeConstrained[
      BuildAntenna[A, 2, 2, Component -> Leading,
        Sequence @@ buildOptions], 1800, $TimedOut]],
  "Subleading",
    AbsoluteTiming[TimeConstrained[
      BuildAntenna[A, 2, 2, Component -> Subleading,
        Sequence @@ buildOptions], 1800, $TimedOut]],
  "Nf",
    AbsoluteTiming[TimeConstrained[
      BuildAntenna[A, 2, 2, Component -> Nf,
        Sequence @@ buildOptions], 1800, $TimedOut]],
  "Breve",
    AbsoluteTiming[TimeConstrained[
      BuildAntenna[A, 2, 2, Component -> Breve,
        Sequence @@ buildOptions], 1800, $TimedOut]],
  "IntegrableForm",
    AbsoluteTiming[TimeConstrained[
      BuildAntenna[A, 2, 2, IntegrableForm -> True,
        Sequence @@ buildOptions], 1800, $TimedOut]]
];

Print["BUILD_CASE = ", buildCase];
Print["SECONDS = ", elapsed];
Print["STATUS = ", If[result === $TimedOut, "Timed out", Head[result]]];
If[result =!= $TimedOut,
  Print["LEAF_COUNT = ", LeafCount[result]];
  Print["FAILED = ", result === $Failed];
  If[buildCase =!= "IntegrableForm",
    Print["FREE_OF_Q2_S12 = ", FreeQ[result, q2 | s12]];
    Print["SERIES_DATA = ", Head[result] === SeriesData]
  ]
];
