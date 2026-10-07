(* Diagnose whether the A31 Ward residual vanishes only after the standard
   one-loop tensor reduction. This remains an amplitude-level check: it does
   not form a tree interference or enter the public A31 build/integration path. *)

repoRoot = Environment["ANTENNA_PIPELINE_ROOT"];

If[repoRoot === $Failed || repoRoot === "",
  repoRoot = DirectoryName[DirectoryName[$InputFileName]];
];

Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

rawReport = VerifyWardIdentity[A, 3, 1, ReturnDiagnostics -> True];
rawResidual = Lookup[rawReport["LegReports", "3"], "Residual", $Failed];

compactSummary[expression_] :=
  Which[
    expression === 0, "0",
    expression === $Aborted, "TimedOut",
    expression === $Failed, "EvaluationFailed",
    True, <|
      "LeafCount" -> LeafCount[expression],
      "HasLoopDenominators" ->
        !FreeQ[expression, _FeynAmpDenominator | _PropagatorDenominator]
    |>
  ];

Print["=== A31 WARD-IDENTITY REDUCTION DIAGNOSTIC ==="];
Print["Raw amplitude-level residual: ", compactSummary[rawResidual]];

If[MemberQ[{0, $Aborted, $Failed}, rawResidual],
  Exit[If[rawResidual === 0, 0, 1]];
];

paVeResidual = Quiet[
  Check[
    TimeConstrained[
      TID[rawResidual, l, ToPaVe -> True] // Contract // DiracSimplify //
        SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& // Simplify,
      900,
      $Aborted
    ],
    $Failed
  ]
];

Print["PaVe-reduced amplitude-level residual: ",
  compactSummary[paVeResidual]];

If[paVeResidual === 0,
  Print["Result: PASS after standard one-loop tensor reduction."];
  Exit[0],
  Print["Result: unresolved; preserve this output for the next diagnostic step."];
  Exit[1]
];
