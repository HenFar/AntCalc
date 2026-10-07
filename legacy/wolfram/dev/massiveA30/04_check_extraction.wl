scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

Get[FileNameJoin[{repoRoot, "dev", "massiveA30_sources", "reconstruction.wl"}]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

extraction = MassiveA30ExtractionAssociation[quarkMass -> mQ];
antenna = MassiveA30ExtractedAntenna[quarkMass -> mQ] // Together;
masslessLimitResidual =
  Together[MassiveA30ExtractedAntenna[quarkMass -> 0] - BuildAntenna[A, 3, 0]];
born = extraction["BornInterference"];
norm = Lookup[extraction, "NormalizedInterference", Missing["NotAvailable"]];

Print["massiveA30 stage 04: extraction"];
Print["  normalized interference available: ", norm =!= Missing["NotAvailable"]];
Print["  born normalization object: ", InputForm[born]];
Print["  massless-limit residual: ", InputForm[masslessLimitResidual]];
Print["  extracted antenna head: ", Head[antenna]];
Print["  status: ", If[norm =!= Missing["NotAvailable"] &&
     TrueQ[masslessLimitResidual === 0], "derived", "failed"]];

If[!And[norm =!= Missing["NotAvailable"],
    TrueQ[masslessLimitResidual === 0]],
  massiveA30ValidationExit[1];
];

massiveA30ValidationExit[0];
