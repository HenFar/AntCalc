scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

Get[FileNameJoin[{repoRoot, "dev", "massiveA30_sources", "reconstruction.wl"}]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

self = MassiveA30SelfInterference[quarkMass -> mQ] // Together;
born = MassiveA30BornInterference[quarkMass -> mQ] // Together;
normalized = MassiveA30NormalizedInterference[quarkMass -> mQ] // Together;
internalResidual = Together[self/(born * colourNorm) - normalized];
massPresentQ = !FreeQ[self, mQ];

Print["massiveA30 stage 03: interference"];
Print["  explicit heavy-mass dependence present: ", massPresentQ];
Print["  normalized self-interference residual: ", InputForm[internalResidual]];
Print["  status: ", If[massPresentQ && TrueQ[internalResidual === 0],
    "derived", "failed"]];

If[!And[massPresentQ, TrueQ[internalResidual === 0]],
  massiveA30ValidationExit[1];
];

massiveA30ValidationExit[0];
