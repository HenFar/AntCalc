scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

Get[FileNameJoin[{repoRoot, "dev", "massiveA30_sources", "index.wl"}]];
Get[FileNameJoin[{repoRoot, "src", "paper_targets.wl"}]];

candidate = MassiveA30UnintegratedPackageConventionCandidate[];
masslessCandidate =
  candidate /. quarkMass -> 0 /. q2 -> s12 + s13 + s23 // Together;
masslessPaperTarget =
  (ToExpression[ToString[A30Paper, InputForm]] /. D -> 4 - 2 Epsilon /. q2 ->
      s12 + s13 + s23) // Together;

limitMatchQ = TrueQ[Together[masslessCandidate - masslessPaperTarget] === 0];

Print["massiveA30 massless-limit check"];
Print["  package candidate reproduces existing A30 target in the massless limit: ",
  limitMatchQ];

If[!limitMatchQ,
  Print["  candidate = ", InputForm[masslessCandidate]];
  Print["  target    = ", InputForm[masslessPaperTarget]];
  massiveA30ValidationExit[1];
];

Print["massiveA30 massless-limit check passed."];
massiveA30ValidationExit[0];
