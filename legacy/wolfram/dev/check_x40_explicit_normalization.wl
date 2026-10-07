Get["AntennaPipeline.wl"];

x40Profile = IBPProfile["X40"];
oldNorm = IBPNormalization[x40Profile];
bridge =
  IBPPhaseSpaceMeasure[2] * ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;
newNorm =
  (8 Pi^2 (4 Pi)^(-eps) Exp[eps EulerGamma])^2 / IBPPhaseSpaceMeasure[2];

masterRules = IBPX40MasterCoefficientRules[];
samplePointRules = {
  q2 -> SetPrecision[7/5, 50]
};
sampleEpsValues = SetPrecision[#, 50]& /@ {1/10, 1/20, 1/100};

numericValue[expr_, epsValue_] :=
  N[expr /. samplePointRules /. eps -> epsValue, 40];

checkEntry[label_, lhs_, rhs_, epsValue_] :=
  Module[{left, right, diff},
    left = numericValue[lhs, epsValue];
    right = numericValue[rhs, epsValue];
    diff = N[left - right, 30];
    <|
      "Label" -> label,
      "eps" -> epsValue,
      "Left" -> left,
      "Right" -> right,
      "Difference" -> diff
    |>
  ];

normChecks =
  checkEntry[
      "NormOnly",
      oldNorm,
      newNorm * bridge,
      #
    ]& /@ sampleEpsValues;

masterChecks =
  Flatten[
    Table[
      With[{master = rule[[1]], value = rule[[2]]},
        checkEntry[
          ToString[InputForm[master]],
          oldNorm * value,
          newNorm * (bridge * value),
          epsValue
        ]
      ],
      {rule, masterRules},
      {epsValue, sampleEpsValues}
    ],
    1
  ];

symbolicNormCheck = FullSimplify[oldNorm - newNorm * bridge];

Print["symbolicNormCheck = ", symbolicNormCheck];
Print["normChecks = ", normChecks];
Print["masterChecks = ", masterChecks];
