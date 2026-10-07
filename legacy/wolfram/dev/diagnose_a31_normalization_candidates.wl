(* One-reduction A31 normalization-ledger test.  The expensive IBP reduction
   runs once; its master-substituted component expressions are then replayed
   under physically motivated post-reduction convention factors.  No package
   source or stored result is modified. *)

Get["AntennaPipeline.wl"];

ClearAll[task10bA31CandidateSeries, task10bA31CandidateReport,
  task10bA31AllZeroQ];

task10bA31CandidateSeries[masterExpression_, factor_] :=
  Module[{regulator, normalized},
    regulator = Unique["eps"];
    normalized = factor masterExpression /. {
      d -> 4 - 2 regulator,
      eps -> regulator,
      FeynCalc`Epsilon -> regulator,
      q2 -> 1
    } // Together;
    Normal[Series[normalized, {regulator, 0, 0}]] // Expand //
      ReplaceAll[#, regulator -> FeynCalc`Epsilon]&
  ];

task10bA31PoleResiduals[expressions_List] :=
  Module[{eps},
    eps = FeynCalc`Epsilon;
    AssociationThread[
      {"Leading", "Subleading", "Nf"},
      (Association @ Table[
        power -> Expand[Coefficient[#, eps, power]],
        {power, -4, 0}
      ])& /@ expressions
    ]
  ];

task10bA31CandidateReport[label_String, rawSeries_List] :=
  Module[{eps, lowerA21, lowerA30, product, tTerms, finalIntegrated,
   tResiduals, finalResiduals},
    eps = FeynCalc`Epsilon;
    lowerA21 = IntegratedA21SubtractionSeries[2];
    lowerA30 = IntegratedA30SubtractionSeries[2];
    product = IntegratedAntennaSeries[lowerA21 lowerA30, 0];
    tTerms = IntegratedAntennaSeries[#, 0]& /@ {
      A31PaperConventionFactor[] rawSeries[[1]] - 11 lowerA30/(6 eps),
      A31PaperConventionFactor[] rawSeries[[2]],
      A31PaperConventionFactor[] rawSeries[[3]] + lowerA30/(3 eps)
    };
    finalIntegrated = IntegratedAntennaSeries[#, 0]& /@ {
      tTerms[[1]] - product,
      -(tTerms[[2]] + product),
      tTerms[[3]]
    };
    tResiduals = Expand /@ (tTerms - A31TTermTargets[0]);
    finalResiduals = Expand /@ (
      finalIntegrated - A31IntegratedAntennaTargets[0]);
    <|
      "Candidate" -> label,
      "EulerGammaFreeQ" -> FreeQ[finalIntegrated, EulerGamma],
      "TTermResidualPoleCoefficients" -> task10bA31PoleResiduals[tResiduals],
      "FinalResidualPoleCoefficients" -> task10bA31PoleResiduals[finalResiduals]
    |>
  ];

Module[{result, diagnostics, backend, componentDiagnostics, masters,
   profile, bridge, candidates, candidateSeries},
  result = BuildAndIntegrateAntenna[
    A, 3, 1,
    ReturnDiagnostics -> True,
    ExpansionOrder -> 0,
    UseStoredResults -> False,
    StoreResults -> False,
    RefreshStoredResults -> False
  ];
  If[!MatchQ[result, {_, _Association}],
    Print["A31 route did not return {result, diagnostics}."];
    Print[result];
    Abort[]
  ];
  diagnostics = result[[2]];
  backend = Lookup[diagnostics, "BackendDiagnostics", <||>];
  componentDiagnostics = Lookup[backend, "ComponentDiagnostics", {}];
  masters = Lookup[componentDiagnostics, "MasterSubstitutedExpression", {}];
  If[Length[masters] =!= 3 || MemberQ[masters, Missing[__]],
    Print["A31 component master-substituted expressions were unavailable."];
    Print[backend];
    Abort[]
  ];
  profile = IBPProfile["A31"];
  bridge = IBPConventionBridgeFactor[profile, True, 0];
  candidates = <|
    "CurrentPackageLedger" -> IBPNormalization[profile] bridge,
    "WithoutPostReductionPhaseSpaceInverse" -> bridge/A31Ceps[]^2,
    "MastersAndBridgeOnly" -> bridge
  |>;
  candidateSeries = Association @ KeyValueMap[
    Function[{label, factor},
      label -> (task10bA31CandidateSeries[#, factor]& /@ masters)
    ],
    candidates
  ];
  Print["A31 post-reduction normalization candidate reports:"];
  Print[Association @ KeyValueMap[
    Function[{label, series},
      label -> task10bA31CandidateReport[label, series]
    ],
    candidateSeries
  ]];
];
