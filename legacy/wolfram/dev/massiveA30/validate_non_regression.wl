scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

result = BuildAntenna[A, 3, 0];
expected =
  (-2 Epsilon)/q2 + (2 s12)/(q2 s13) + (2 s12)/(q2 s23) +
    (2 s12^2)/(q2 s13 s23) + s13/(q2 s23) - (Epsilon s13)/(q2 s23) +
    s23/(q2 s13) - (Epsilon s23)/(q2 s13);

nonRegressionQ = TrueQ[Together[result - expected] === 0];

Print["massiveA30 non-regression check"];
Print["  public massless A30 route remains unchanged: ", nonRegressionQ];

If[!nonRegressionQ,
  Print["  result   = ", InputForm[result]];
  Print["  expected = ", InputForm[expected]];
  massiveA30ValidationExit[1];
];

Print["massiveA30 non-regression check passed."];
massiveA30ValidationExit[0];
