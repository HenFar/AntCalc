Get[FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]], "AntennaPipeline.wl"}]];
Get[FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]], "dev", "massiveA30_sources", "unintegrated.wl"}]];

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

diagsA20Massive =
  FeynArts`InsertFields[
    FeynArts`CreateTopologies[0, 1 -> 2],
    {FeynArts`V[1]} -> {FeynArts`F[4, {3}], -FeynArts`F[4, {3}]},
    FeynArts`InsertionLevel -> {FeynArts`Classes},
    FeynArts`Model -> "SMQCD",
    FeynArts`ExcludeParticles -> {}
  ];

ampA20Massive =
  FCFAConvert[
    CreateFeynAmp[diagsA20Massive],
    IncomingMomenta -> {p},
    OutgoingMomenta -> {k1, k2},
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

interferenceA20Massive =
  InterfereMAmplitudes[
    ampA20Massive,
    ampA20Massive,
    2,
    ApplyCasimirSubstitution -> True,
    ApplyDimReg -> True,
    AntennaType -> A,
    quarkMass -> mQ
  ];

canonicalRules = {
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
};

interfA30MassiveCanonical =
  interferenceA30Massive /. canonicalRules //
  Together //
  Expand //
  Simplify;

interfA20MassiveCanonical =
  interferenceA20Massive /. {
    Pair[Momentum[k1, _], Momentum[k1, _]] -> mQ^2,
    Pair[Momentum[k2, _], Momentum[k2, _]] -> mQ^2,
    Pair[Momentum[k1, _], Momentum[k2, _]] -> s12/2,
    Pair[Momentum[k2, _], Momentum[k1, _]] -> s12/2
  } //
  Together //
  Expand //
  Simplify;

interfA30MassiveStripped =
  interfA30MassiveCanonical / (SMP["e"]^2 SMP["g_s"]^2) //
  Together //
  Simplify;

interfA20MassiveStripped =
  interfA20MassiveCanonical / SMP["e"]^2 //
  Together //
  Simplify;

thesisBracket =
  (
    s13/s23 +
    s23/s13 +
    2 s12 (s12 + s13 + s23)/(s23 s13) -
    2 mQ^2 (
      (s12 + s13 + s23) (1/s23^2 + 1/s13^2) -
      4 s12/(s13 s23)
    ) -
    8 mQ^4 (1/s23^2 + 1/s13^2)
  ) //
  Together //
  Simplify;

thesisBorn =
  (4 ((1 - Epsilon) q2 + 2 mQ^2)) //
  Together //
  Simplify;

thesisAntenna =
  thesisBracket / thesisBorn //
  Together //
  Simplify;

bornMassiveTarget = thesisBorn;

packageColourNorm = colourNorm /. SUNN -> 3;

thesisNormDirect =
  interfA30MassiveStripped /. SUNN -> 3 //
  Together //
  Simplify;

bornRatioToThesis =
  Together[
    (interfA20MassiveStripped /. SUNN -> 3) /
    (thesisBorn /. q2 -> 2 mQ^2 + s12)
  ] //
  Factor;

ratioToBracket =
  Together[
    thesisNormDirect / thesisBracket
  ] //
  Factor;

normViaThesisBorn =
  Together[
    thesisNormDirect / (packageColourNorm bornMassiveTarget)
  ] //
  Simplify //
  Together;

normViaThesisBornOnShell =
  normViaThesisBorn /. q2 -> 2 mQ^2 + s12 + s13 + s23 //
  Together //
  Simplify;

thesisAntennaOnShell =
  thesisAntenna /. q2 -> 2 mQ^2 + s12 + s13 + s23 //
  Together //
  Simplify;

residualDirect =
  Together[normViaThesisBornOnShell - thesisAntennaOnShell];

packageBornInterference =
  MassiveA30BornInterference[quarkMass -> mQ] //
  Together //
  Simplify;

packageAntenna =
  MassiveA30ExtractedAntenna[quarkMass -> mQ] //
  Together //
  Simplify;

residualPackageToThesis =
  Together[
    packageAntenna - thesisAntennaOnShell
  ];

bruteForceThesisMatch =
  (
    (interfA30MassiveStripped /. SUNN -> 3 /. Epsilon -> 0) /
    (
      (4/3) *
      packageColourNorm *
      (thesisBorn /. Epsilon -> 0)
    )
  ) /. q2 -> 2 mQ^2 + s12 + s13 + s23 //
  Together //
  Simplify;

bruteForceTarget =
  thesisAntennaOnShell /. Epsilon -> 0 //
  Together //
  Simplify;

bruteForceResidual =
  Together[
    bruteForceThesisMatch - bruteForceTarget
  ];

Print["interfA30MassiveCanonical = ", InputForm[interfA30MassiveCanonical]];
Print["interfA30MassiveStripped = ", InputForm[interfA30MassiveStripped]];
Print["interfA20MassiveCanonical = ", InputForm[interfA20MassiveCanonical]];
Print["interfA20MassiveStripped = ", InputForm[interfA20MassiveStripped]];
Print["thesisBracket = ", InputForm[thesisBracket]];
Print["thesisBorn = ", InputForm[thesisBorn]];
Print["bornRatioToThesis = ", InputForm[bornRatioToThesis]];
Print["ratioToBracket = ", InputForm[ratioToBracket]];
Print["packageBornInterference = ", InputForm[packageBornInterference]];
Print["normViaThesisBornOnShell = ", InputForm[normViaThesisBornOnShell]];
Print["thesisAntennaOnShell = ", InputForm[thesisAntennaOnShell]];
Print["residualDirect = ", InputForm[residualDirect]];
Print["packageAntenna = ", InputForm[packageAntenna]];
Print["residualPackageToThesis = ", InputForm[residualPackageToThesis]];
Print["bruteForceThesisMatch = ", InputForm[bruteForceThesisMatch]];
Print["bruteForceTarget = ", InputForm[bruteForceTarget]];
Print["bruteForceResidual = ", InputForm[bruteForceResidual]];
