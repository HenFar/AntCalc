scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[scriptDirectory];
masterIntegralDirectory = FileNameJoin[{repoRoot, "masterIntegrals"}];
artifactPath = FileNameJoin[{masterIntegralDirectory, "master_values_runtime.wl"}];

normalizeRuntimeValue[value_] :=
  Which[
    AssociationQ[value],
      KeySort[Association @ KeyValueMap[
        #1 -> normalizeRuntimeValue[#2]&,
        value
      ]]
    ,
    ListQ[value],
      normalizeRuntimeValue /@ value
    ,
    MatchQ[value, _Rule | _RuleDelayed],
      normalizeRuntimeValue[First[value]] ->
        normalizeRuntimeValue[Last[value]]
    ,
    True,
      value
  ];

runtimeValueEqualQ[left_, right_] :=
  Module[{normalizedLeft, normalizedRight},
    normalizedLeft = normalizeRuntimeValue[left];
    normalizedRight = normalizeRuntimeValue[right];
    Which[
      AssociationQ[normalizedLeft] && AssociationQ[normalizedRight],
        Keys[normalizedLeft] === Keys[normalizedRight] &&
          And @@ (runtimeValueEqualQ[normalizedLeft[#], normalizedRight[#]]& /@
            Keys[normalizedLeft])
      ,
      ListQ[normalizedLeft] && ListQ[normalizedRight],
        Length[normalizedLeft] === Length[normalizedRight] &&
          And @@ MapThread[runtimeValueEqualQ, {normalizedLeft, normalizedRight}]
      ,
      MatchQ[normalizedLeft, _Rule | _RuleDelayed] &&
        MatchQ[normalizedRight, _Rule | _RuleDelayed],
        runtimeValueEqualQ[First[normalizedLeft], First[normalizedRight]] &&
          runtimeValueEqualQ[Last[normalizedLeft], Last[normalizedRight]]
      ,
      True,
        TrueQ[FullSimplify[normalizedLeft == normalizedRight]]
    ]
  ];

If[!FileExistsQ[artifactPath],
  Print["Runtime master artifact not found: ", artifactPath];
  Print["Run masterIntegrals/export_runtime_master_values.wl first."];
  Exit[1];
];

artifactValues = Get[artifactPath];

Get[FileNameJoin[{masterIntegralDirectory, "runtime_values.wl"}]];
LoadRuntimeMasterValueSources[];

sourceValues = MasterIntegralRuntimeValuesAssociation[];

If[runtimeValueEqualQ[artifactValues, sourceValues],
  Print["Runtime master values validation passed."];
  Exit[0];
];

Print["Runtime master values validation failed."];
Print["Artifact path: ", artifactPath];
Exit[1];
