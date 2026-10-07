(* Task 10b: one-reduction, bounded decomposition of the A31 leading and
   subleading channels into the V5a (qMI), V5b (qkMI), and V8 (qsMI) masters.
   The script intentionally reports only Laurent coefficients through 1/eps. *)

Get["AntennaPipeline.wl"];

ClearAll[a31MasterPoleSeries, a31PoleCoefficients, a31MasterReport];

a31MasterPoleSeries[expression_, profile_, master_] :=
  Module[{regulator, isolated, normalized, bridge},
    regulator = Unique["eps"];
    bridge = IBPConventionBridgeFactor[profile, True,
      Lookup[profile, "ExpansionOrder", 0]];
    isolated = expression /. Thread[
      DeleteCases[{qMI, qkMI, qsMI}, master] -> 0
    ] /. IBPMasterValues[profile];
    normalized = bridge IBPNormalization[profile] isolated /. {
      d -> 4 - 2 regulator,
      eps -> regulator,
      FeynCalc`Epsilon -> regulator,
      q2 -> 1
    };
    TimeConstrained[
      ReplaceAll[
        Normal[Series[Together[normalized], {regulator, 0, -1}]] // Expand,
        regulator -> FeynCalc`Epsilon
      ],
      180,
      Missing["TimedOut"]
    ]
  ];

a31PoleCoefficients[series_] :=
  If[MissingQ[series],
    series,
    AssociationThread[
      {-4, -3, -2, -1},
      Coefficient[series, FeynCalc`Epsilon, #]& /@ {-4, -3, -2, -1}
    ]
  ];

a31MasterReport[expression_, profile_] :=
  <|
    "qMI/V5a" ->
      a31PoleCoefficients[a31MasterPoleSeries[expression, profile, qMI]],
    "qkMI/V5b" ->
      a31PoleCoefficients[a31MasterPoleSeries[expression, profile, qkMI]],
    "qsMI/V8" ->
      a31PoleCoefficients[a31MasterPoleSeries[expression, profile, qsMI]]
  |>;

Module[{result, diagnostics, backend, componentDiagnostics, profile,
   componentNames, expressions, reports},
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
  If[!ListQ[componentDiagnostics] || Length[componentDiagnostics] < 2,
    Print["A31 component diagnostics were unavailable."];
    Print[backend];
    Abort[]
  ];
  profile = IBPProfile["A31"];
  componentNames = {"Leading", "Subleading"};
  expressions = Lookup[componentDiagnostics[[;; 2]],
    "MasterMappedExpression", Missing["NotAvailable"]];
  If[MemberQ[expressions, _Missing],
    Print["A31 master-mapped expressions were unavailable."];
    Abort[]
  ];
  reports = AssociationThread[
    componentNames,
    a31MasterReport[#, profile]& /@ expressions
  ];
  Print["A31 isolated master Laurent coefficients:"];
  Print[reports];
];
