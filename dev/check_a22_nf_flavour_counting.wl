Get[FileNameJoin[{Directory[], "AntennaPipeline.wl"}]];

(* Loading the classes model is explicit here because the test does not build
   a full A22 amplitude, which normally performs this step. *)
ToExpression[
  "FeynArts`InsertFields[FeynArts`CreateTopologies[0, 1 -> 2], {FeynArts`V[1]} -> {FeynArts`F[3, {1}], -FeynArts`F[3, {1}]}, FeynArts`InsertionLevel -> {FeynArts`Classes}, FeynArts`Model -> \"SMQCD\"]"
];

modelClassText =
  ToString[
    InputForm[ToExpression["FeynArts`M$ClassesDescription"]]
  ];

twoQuarkClassCheck =
  StringContainsQ[modelClassText, "F[3] =="] &&
  StringContainsQ[modelClassText, "F[4] =="] &&
  Count[
    StringCases[modelClassText, "Indices -> {Index[Generation], Index[Colour]}"],
    _String
  ] >= 2;

singleClassCheck =
  Simplify[
    TwoLoopSMQCDGenerationMultiplicity[] - Nf / 2
  ];

pairedClassCheck =
  Simplify[
    2 TwoLoopSMQCDGenerationMultiplicity[] - Nf
  ];

If[!TrueQ[twoQuarkClassCheck] || singleClassCheck =!= 0 ||
    pairedClassCheck =!= 0,
  Print["FAIL: A22 SMQCD generation sums do not combine to total Nf."];
  Exit[1]
];

Print["PASS: each SMQCD quark class contributes Nf/2 and the F[3]+F[4] pair contributes Nf."];
Exit[0];
