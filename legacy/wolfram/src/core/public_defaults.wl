(* ::Section:: *)

(* Supported package-wide default environment control *)

AntennaPipelineDefaults::usage =
  "AntennaPipelineDefaults[] returns the currently active package-wide user default environment together with the supported option keys, precedence model, and effective managed-head default resolutions.";

SetAntennaPipelineDefaults::usage =
  "SetAntennaPipelineDefaults[assoc] installs supported package-wide default option overrides that apply across the public API until reset.";

ResetAntennaPipelineDefaults::usage =
  "ResetAntennaPipelineDefaults[] restores the original built-in public option defaults for the supported package-wide environment layer.";

SetAntennaPipelineDefaults::unsupported =
  "Unsupported package-wide default option key(s): `1`. Supported keys are `2`.";

AntennaPipelineNormalizeDefaultKey[key_String] :=
  key;

AntennaPipelineNormalizeDefaultKey[key_Symbol] :=
  SymbolName[Unevaluated[key]];

AntennaPipelineNormalizeDefaultKey[key_] :=
  ToString[Unevaluated[key], InputForm];

AntennaPipelineNormalizeDefaultAssociation[assoc_Association] :=
  Association @ KeyValueMap[
    AntennaPipelineNormalizeDefaultKey[#1] -> #2 &,
    assoc
  ];

AntennaPipelineNormalizeDefaultAssociation[rules_List] :=
  AntennaPipelineNormalizeDefaultAssociation[Association[rules]];

AntennaPipelineSupportedDefaultKeys[] :=
  {
    "quarkMass",
    "ApplyDimReg",
    "ReductionBackend",
    "AllowPrototypeTargets",
    "UseSourceModelRoute",
    "UseStoredResults",
    "StoreResults",
    "ResultsCacheRoot",
    "RefreshStoredResults",
    "ApplyFeynCalcMS",
    "PaVeEvaluation",
    "ExpansionOrder",
    "KinematicScale",
    "NormalizeKinematicScale",
    "BasisFamily",
    "BasisRoot",
    "GenerateMissingBases",
    "ResultForm"
  };

AntennaPipelineDefaultManagedHeads[] :=
  {
    BuildAntenna,
    BuildAntennaObject,
    IntegrateAntenna,
    BuildAndIntegrateAntenna,
    BuildRRatio,
    TObject
  };

AntennaPipelineRawOptionRules[head_Symbol] :=
  Options[head];

AntennaPipelineNormalizeHeadOptionAssociation[head_Symbol] :=
  Association @ KeyValueMap[
    AntennaPipelineNormalizeDefaultKey[#1] -> #2 &,
    Association[Options[head]]
  ];

AntennaPipelineSupportedHeadDefaults[assoc_Association] :=
  KeyTake[assoc, Intersection[
    Keys[assoc],
    AntennaPipelineSupportedDefaultKeys[]
  ]];

AntennaPipelineHeadDefaultResolution[head_Symbol] :=
  Module[{headName, headOptions, builtInDefaults, effectiveDefaults,
     overriddenKeys},
    headName = SymbolName[head];
    headOptions = Lookup[$AntennaPipelineBasePublicOptions, headName, <||>];
    builtInDefaults =
      AntennaPipelineSupportedHeadDefaults[
        Lookup[headOptions, "NormalizedAssociation", <||>]
      ];
    effectiveDefaults =
      AntennaPipelineSupportedHeadDefaults[
        AntennaPipelineNormalizeHeadOptionAssociation[head]
      ];
    overriddenKeys =
      Select[
        Keys[builtInDefaults],
        Lookup[builtInDefaults, #, Missing["Absent"]] =!=
          Lookup[effectiveDefaults, #, Missing["Absent"]] &
      ];
    <|
      "BuiltInDefaults" -> builtInDefaults,
      "EffectiveDefaults" -> effectiveDefaults,
      "OverriddenKeys" -> overriddenKeys,
      "UsingUserOverridesQ" -> (Length[overriddenKeys] > 0)
    |>
  ];

If[!ValueQ[$AntennaPipelineBasePublicOptions],
  $AntennaPipelineBasePublicOptions =
    Association @ Table[
      SymbolName[head] -> <|
        "RawRules" -> AntennaPipelineRawOptionRules[head],
        "NormalizedAssociation" ->
          AntennaPipelineNormalizeHeadOptionAssociation[head]
      |>,
      {head, AntennaPipelineDefaultManagedHeads[]}
    ];
];

If[!ValueQ[$AntennaPipelineUserDefaults],
  $AntennaPipelineUserDefaults = <||>;
];

ApplyAntennaPipelineUserDefaults[] :=
  Module[{userDefaults, baseOptions, managedHeads, headName, headOptions,
     appliedRules},
    userDefaults = $AntennaPipelineUserDefaults;
    managedHeads = AntennaPipelineDefaultManagedHeads[];
    Do[
      headName = SymbolName[head];
      headOptions = Lookup[$AntennaPipelineBasePublicOptions, headName, <||>];
      baseOptions = Lookup[headOptions, "RawRules", {}];
      Options[head] = baseOptions;
      appliedRules =
        KeyValueMap[
          If[KeyExistsQ[Lookup[headOptions, "NormalizedAssociation", <||>], #1],
            ToExpression[#1, InputForm, Identity] -> #2,
            Nothing
          ] &,
          userDefaults
        ];
      If[Length[appliedRules] > 0,
        SetOptions[head, appliedRules]
      ];
      ,
      {head, managedHeads}
    ];
  ];

AntennaPipelineDefaults[] :=
  <|
    "UserDefaults" -> $AntennaPipelineUserDefaults,
    "SupportedKeys" -> AntennaPipelineSupportedDefaultKeys[],
    "ManagedHeads" -> (SymbolName /@ AntennaPipelineDefaultManagedHeads[]),
    "Precedence" -> {
      "BuiltInDefaults",
      "PackageWideUserDefaults",
      "PerCallOptions"
    },
    "HeadResolutions" -> Association @ Table[
      SymbolName[head] -> AntennaPipelineHeadDefaultResolution[head],
      {head, AntennaPipelineDefaultManagedHeads[]}
    ]
  |>;

SetAntennaPipelineDefaults[assoc_Association] :=
  Module[{normalized, unsupported},
    normalized = AntennaPipelineNormalizeDefaultAssociation[assoc];
    unsupported =
      Complement[Keys[normalized], AntennaPipelineSupportedDefaultKeys[]];
    If[Length[unsupported] > 0,
      Message[SetAntennaPipelineDefaults::unsupported,
        StringRiffle[unsupported, ", "],
        StringRiffle[AntennaPipelineSupportedDefaultKeys[], ", "]];
      Return[$Failed]
    ];
    $AntennaPipelineUserDefaults =
      Join[$AntennaPipelineUserDefaults, normalized];
    ApplyAntennaPipelineUserDefaults[];
    AntennaPipelineDefaults[]
  ];

SetAntennaPipelineDefaults[rules_List] :=
  SetAntennaPipelineDefaults[Association[rules]];

ResetAntennaPipelineDefaults[] :=
  (
    $AntennaPipelineUserDefaults = <||>;
    ApplyAntennaPipelineUserDefaults[];
    AntennaPipelineDefaults[]
  );

ApplyAntennaPipelineUserDefaults[];
