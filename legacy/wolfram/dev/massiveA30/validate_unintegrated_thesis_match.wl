scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

Get[FileNameJoin[{repoRoot, "dev", "massiveA30_sources", "index.wl"}]];

paperExpression = MassiveA30UnintegratedPaperConvention[];
expectedExpression =
  (
    s13/s23 + s23/s13 + 2 s12 s123/(s23 s13) -
      2 mf^2 (s123 (1/s23^2 + 1/s13^2) - 4 s12/(s13 s23)) -
      8 mf^4 (1/s23^2 + 1/s13^2)
  )/(4 ((1 - epsilon) q2 + 2 mf^2));

matchQ = TrueQ[Together[paperExpression - expectedExpression] === 0];

Print["massiveA30 unintegrated thesis-match"];
Print["  encoded paper expression matches local thesis transcription: ", matchQ];

If[!matchQ,
  Print["  encoded   = ", InputForm[paperExpression]];
  Print["  expected  = ", InputForm[expectedExpression]];
  massiveA30ValidationExit[1];
];

Print["massiveA30 unintegrated thesis-match passed."];
massiveA30ValidationExit[0];
