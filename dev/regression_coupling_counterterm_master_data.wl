(*
  Compare the hard-coded A21 and A30 lower-master expressions used by A22/A31
  counterterms with the lower routes' own public ReturnMasterCombination
  outputs. Run once in a fresh kernel; this script can take several minutes.
*)

packageRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{packageRoot, "AntennaPipeline.wl"}]];

RunLowerMasterRoute[key_List] :=
  Module[{elapsed, result},
    {elapsed, result} = AbsoluteTiming[TimeConstrained[
      BuildAndIntegrateAntenna @@ Join[key, {
        ReturnMasterCombination -> True,
        ReturnDiagnostics -> True,
        PrintComponentLegend -> False,
        UseStoredResults -> False,
        StoreResults -> False
      }], 1800, $TimedOut]];
    {elapsed, result}
  ];

{a21Seconds, a21Result} = RunLowerMasterRoute[{A, 2, 1}];
Print["A21_SECONDS = ", a21Seconds];
Print["A21_STATUS = ", If[a21Result === $TimedOut, "Timed out", Head[a21Result]]];
If[!MatchQ[a21Result, {_, _Association}],
  Print["A21_MASTER_RESULT = ", InputForm[a21Result]];
  Abort[]
];

a21LowerData = CouplingCountertermMasterData[{A, 2, 2}, Leading];
a21LowerScalarSymbols = DeleteDuplicates @ Cases[
  a21LowerData["LowerMasterCombination"],
  s_Symbol /; MemberQ[{"B0", "C0"}, SymbolName[Unevaluated[s]]],
  {0, Infinity}, Heads -> True];
a21LowerB0Symbol = First @ Select[a21LowerScalarSymbols,
  SymbolName[#] === "B0" &];
a21LowerC0Symbol = First @ Select[a21LowerScalarSymbols,
  SymbolName[#] === "C0" &];
a21ScalarCalls = DeleteDuplicates @ Cases[a21Result[[1]],
  HoldPattern[h_Symbol[___]] /;
    MemberQ[{"B0", "C0"}, SymbolName[h]], Infinity];
a21ScalarHeads = DeleteDuplicates[Head /@ a21ScalarCalls];
Print["A21_SCALAR_HEAD_CONTEXTS = ",
  InputForm[({SymbolName[#], Context[#]}& /@ a21ScalarHeads)]];
Print["A21_LOWER_SCALAR_CONTEXTS = ",
  InputForm[({SymbolName[#], Context[#]}& /@ a21LowerScalarSymbols)]];
a21ReturnedMaster = a21Result[[1]] /. {
  D -> 4 - 2 Epsilon,
  d -> 4 - 2 Epsilon,
  eps -> Epsilon,
  FeynCalc`Epsilon -> Epsilon,
  HoldPattern[Global`B0[args___]] :> a21LowerB0Symbol,
  HoldPattern[FeynCalc`B0[args___]] :> a21LowerB0Symbol,
  HoldPattern[Global`C0[args___]] :> a21LowerC0Symbol,
  HoldPattern[FeynCalc`C0[args___]] :> a21LowerC0Symbol,
  q2 -> 1,
  s12 -> 1
};
a21ReturnedTimelike = Cos[Pi Epsilon] a21ReturnedMaster;
a21Residual = TimeConstrained[
  FunctionExpand @ FullSimplify[Together[
    a21ReturnedTimelike - a21LowerData["LowerMasterCombination"]]],
  120, $TimedOut];
Print["A21_RETURNED_MASTER = ", InputForm[a21Result[[1]]]];
Print["A21_COUNTERTERM_LOWER = ",
  InputForm[a21LowerData["LowerMasterCombination"]]];
Print["A21_LOWER_RESIDUAL = ", InputForm[a21Residual]];

{a30Seconds, a30Result} = RunLowerMasterRoute[{A, 3, 0}];
Print["A30_SECONDS = ", a30Seconds];
Print["A30_STATUS = ", If[a30Result === $TimedOut, "Timed out", Head[a30Result]]];
If[!MatchQ[a30Result, {_, _Association}],
  Print["A30_MASTER_RESULT = ", InputForm[a30Result]];
  Abort[]
];

a30RawMasters = DeleteDuplicates @ Cases[a30Result[[1]],
  HoldPattern[LiteRed`j[___]], Infinity];
Print["A30_RAW_MASTER_COUNT = ", Length[a30RawMasters]];
Print["A30_RETURNED_MASTER = ", InputForm[a30Result[[1]]]];
If[Length[a30RawMasters] =!= 1,
  Print["A30_LOWER_RESIDUAL = ",
    "Cannot map the live lower route: expected its single NLOBasis123 master."];
  Abort[]
];

a30ReturnedR3 = a30Result[[1]] /. First[a30RawMasters] -> Global`R3;
a30ReturnedR3 = a30ReturnedR3 *
  (IBPNormalization[<|"BasisFamily" -> "X30"|>] /.
    {q2 -> 1, eps -> Epsilon}) /. {
      d -> 4 - 2 Epsilon,
      eps -> Epsilon,
      FeynCalc`Epsilon -> Epsilon,
      q2 -> 1,
      s12 -> 1
    };
a30LowerData = CouplingCountertermMasterData[{A, 3, 1}, Nf];
a30CountertermLower = A31MasterCombinationPrefactor[] *
  a30LowerData["LowerMasterCombination"];
a30Residual = TimeConstrained[
  FunctionExpand @ FullSimplify[Together[
    a30ReturnedR3 - a30CountertermLower]],
  120, $TimedOut];
Print["A30_RETURNED_R3_FORM = ", InputForm[a30ReturnedR3]];
Print["A30_COUNTERTERM_LOWER = ", InputForm[a30CountertermLower]];
Print["A30_LOWER_RESIDUAL = ", InputForm[a30Residual]];

If[TrueQ[a21Residual === 0] && TrueQ[a30Residual === 0],
  Print["LOWER_MASTER_REGRESSION = PASS"],
  Print["LOWER_MASTER_REGRESSION = REVIEW RESIDUALS ABOVE"]
];
