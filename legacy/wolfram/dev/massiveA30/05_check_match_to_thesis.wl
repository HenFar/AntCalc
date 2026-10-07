scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

Get[FileNameJoin[{repoRoot, "dev", "massiveA30_sources", "reconstruction.wl"}]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

diagsA30 =
  FeynArts`InsertFields[
    FeynArts`CreateTopologies[0, 1 -> 3],
    {FeynArts`V[1]} -> {FeynArts`F[4, {3}], -FeynArts`F[4, {3}], FeynArts`V[5]},
    FeynArts`InsertionLevel -> {FeynArts`Classes},
    FeynArts`Model -> "SMQCD",
    FeynArts`ExcludeParticles -> {}
  ];

FCClearScalarProducts[];
SPD[k1, k1] = mQ^2;
SPD[k2, k2] = mQ^2;
SPD[k3, k3] = 0;

ampA30Massive =
  FCFAConvert[
    CreateFeynAmp[diagsA30],
    IncomingMomenta -> {p},
    OutgoingMomenta -> {k1, k2, k3},
    UndoChiralSplittings -> True,
    ChangeDimension -> D,
    List -> False,
    SMP -> True,
    Contract -> True,
    DropSumOver -> True,
    FinalSubstitutions -> {
      SMP["m_u"] -> 0,
      SMP["m_d"] -> 0,
      SMP["m_s"] -> 0,
      SMP["m_c"] -> 0,
      SMP["m_b"] -> mQ,
      SMP["m_t"] -> 0
    }
  ] //
  SUNSimplify //
  Simplify;

interferenceA30Massive =
  InterfereMAmplitudes[
    ampA30Massive,
    ampA30Massive,
    3,
    ApplyCasimirSubstitution -> True,
    ApplyDimReg -> True,
    AntennaType -> A,
    quarkMass -> mQ
  ];

interfA30MassiveCanonical =
  interferenceA30Massive /. {
    Pair[Momentum[k1, _], Momentum[k1, _]] -> mQ^2,
    Pair[Momentum[k2, _], Momentum[k2, _]] -> mQ^2,
    Pair[Momentum[k3, _], Momentum[k3, _]] -> 0,
    Pair[Momentum[k1, _], Momentum[k2, _]] -> s12/2,
    Pair[Momentum[k2, _], Momentum[k1, _]] -> s12/2,
    Pair[Momentum[k1, _], Momentum[k3, _]] -> s13/2,
    Pair[Momentum[k3, _], Momentum[k1, _]] -> s13/2,
    Pair[Momentum[k2, _], Momentum[k3, _]] -> s23/2,
    Pair[Momentum[k3, _], Momentum[k2, _]] -> s23/2,
    FeynAmpDenominator[
      PropagatorDenominator[
        Plus[
          Times[-1, Momentum[k1, _]],
          Times[-1, Momentum[k3, _]]
        ],
        mQ
      ]
    ] :> 1/s13,
    FeynAmpDenominator[
      PropagatorDenominator[
        Plus[Momentum[k2, _], Momentum[k3, _]],
        mQ
      ]
    ] :> 1/s23
  } //
  Together //
  Expand //
  Simplify;

interfA30MassiveStripped =
  interfA30MassiveCanonical / (SMP["e"]^2 SMP["g_s"]^2) //
  Together //
  Simplify;

thesisBornOnShell =
  MassiveA30BornNormalizationPaper[] /. {
    mf -> mQ,
    epsilon -> 0,
    q2 -> 2 mQ^2 + s12 + s13 + s23
  } // Together;

derived =
  (
    (interfA30MassiveStripped /. SUNN -> 3 /. Epsilon -> 0) /
    ((4/3) (colourNorm /. SUNN -> 3) thesisBornOnShell)
  ) /. q2 -> 2 mQ^2 + s12 + s13 + s23 //
  Together //
  Simplify;

thesisTarget =
  MassiveA30UnintegratedPaperConvention[] /. {
    mf -> mQ,
    q2 -> 2 mQ^2 + s12 + s13 + s23,
    s123 -> s12 + s13 + s23,
    epsilon -> 0
  } // Together;

residual = Together[derived - thesisTarget];
exactMatchQ = TrueQ[residual === 0];

Print["massiveA30 stage 05: match to thesis"];
Print["  exact direct residual: ", InputForm[residual]];
Print["  bridge used: notebook-style raw interference, four-dimensional thesis numerator, thesis normalization, s123 -> s12 + s13 + s23, and package-to-thesis normalization factor 4/3 * colourNorm."];
Print["  status: ", If[exactMatchQ, "derived", "failed"]];

If[!exactMatchQ,
  massiveA30ValidationExit[1];
];

massiveA30ValidationExit[0];
