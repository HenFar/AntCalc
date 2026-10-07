(* Fast master-level audit for the A31 convention ledger.  This script does
   not invoke LiteRed or build an antenna.  It compares the runtime master
   values before and after the IBP normalizer so a phase-space/S_Gamma factor
   cannot be counted invisibly twice. *)

Get["AntennaPipeline.wl"];

ClearAll[task10bA31Series, task10bGammaFreeQ];

task10bA31Series[expr_, order_Integer] :=
  Module[{regulator},
    regulator = FeynCalc`Epsilon;
    Normal[Series[
      expr /. {eps -> regulator, FeynCalc`Epsilon -> regulator, q2 -> 1},
      {regulator, 0, order}
    ]] // FullSimplify
  ];

task10bGammaFreeQ[expr_] := FreeQ[expr, EulerGamma];

Module[{profile, normalization, bridge, masters, rawSeries,
   normalizedSeries},
  profile = IBPProfile["A31"];
  normalization = IBPNormalization[profile];
  bridge = IBPConventionBridgeFactor[profile, True, 0];
  masters = <|
    "qMI/V5a" -> RuntimeMasterValue["A31", "qMI"],
    "qkMI/V5b" -> RuntimeMasterValue["A31", "qkMI"],
    "qsMI/V8" -> RuntimeMasterValue["A31", "qsMI"]
  |>;
  rawSeries = Association @ KeyValueMap[
    #1 -> task10bA31Series[#2, 0]&,
    masters
  ];
  normalizedSeries = Association @ KeyValueMap[
    #1 -> task10bA31Series[normalization bridge #2, 0]&,
    masters
  ];
  Print["A31 IBP normalization:"];
  Print[normalization];
  Print["A31 convention bridge:"];
  Print[bridge];
  Print["Runtime master EulerGamma checks before IBP normalization:"];
  Print[Association @ KeyValueMap[
    #1 -> task10bGammaFreeQ[#2]&,
    rawSeries
  ]];
  Print["Runtime master EulerGamma checks after IBP normalization:"];
  Print[Association @ KeyValueMap[
    #1 -> task10bGammaFreeQ[#2]&,
    normalizedSeries
  ]];
  Print["Normalized runtime master series through epsilon^0:"];
  Print[normalizedSeries];
];
