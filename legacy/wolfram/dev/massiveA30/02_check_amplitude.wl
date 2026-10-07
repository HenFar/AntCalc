scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

Get[FileNameJoin[{repoRoot, "dev", "massiveA30_sources", "reconstruction.wl"}]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

amp = MassiveA30TreeAmplitude[quarkMass -> mQ];
massPresentQ = !FreeQ[amp, mQ];
spinorMassPresentQ =
  !FreeQ[amp, Spinor[Momentum[k1, _], mQ, __]] &&
    !FreeQ[amp, Spinor[-Momentum[k2, _], mQ, __]];
propagatorMassPresentQ =
  !FreeQ[amp, PropagatorDenominator[_, mQ]];
masslessReferenceResidual =
  Together[MassiveA30TreeAmplitude[quarkMass -> 0] -
    AntennaAmplitude[{A, 3, 0}]];

Print["massiveA30 stage 02: amplitude"];
Print["  explicit heavy-mass dependence present: ", massPresentQ];
Print["  external spinor masses present: ", spinorMassPresentQ];
Print["  internal propagator masses present: ", propagatorMassPresentQ];
Print["  massless-reference residual (expected flavor-strip factor difference): ",
  InputForm[masslessReferenceResidual]];
Print["  status: ", If[massPresentQ && spinorMassPresentQ &&
     propagatorMassPresentQ, "derived", "failed"]];

If[!And[massPresentQ, spinorMassPresentQ, propagatorMassPresentQ],
  massiveA30ValidationExit[1];
];

massiveA30ValidationExit[0];
