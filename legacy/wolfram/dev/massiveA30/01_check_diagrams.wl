scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

Get[FileNameJoin[{repoRoot, "dev", "massiveA30_sources", "reconstruction.wl"}]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

diagrams = MassiveA30TreeDiagrams[];
diagramCount = Length[diagrams];
passQ = TrueQ[diagramCount === 2];

Print["massiveA30 stage 01: diagrams"];
Print["  expected tree diagrams for gamma* -> QQbar g: ", diagramCount];
Print["  status: ", If[passQ, "derived", "failed"]];

If[!passQ,
  massiveA30ValidationExit[1];
];

massiveA30ValidationExit[0];
