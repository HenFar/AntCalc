(* Runtime audit for the A31 IBP backend-to-public convention bridge.

   This is intentionally a fresh, uncached route.  It does not modify package
   state or store a result.  The printed backend stages identify whether an
   EulerGamma term enters before or after the convention bridge. *)

Get["AntennaPipeline.wl"];

ClearAll[gammaFreeQ, compactBackendDiagnostics, componentStageGammaChecks];

gammaFreeQ[expr_] := FreeQ[expr, EulerGamma];

compactBackendDiagnostics[diagnostics_Association] :=
  KeyTake[diagnostics,
    {"ConventionBridgeFactor", "MasterMappedExpression",
     "RawMasterCombination", "MasterSubstitutedExpression",
     "NormalizedBeforeSeries", "SeriesResult", "AppliedMSBar",
     "Normalization", "ExpansionOrder"}];

componentStageGammaChecks[backend_Association] :=
  Module[{stages, componentDiagnostics},
    stages = {"RawLiteRedCombination", "MasterMappedExpression",
      "MasterSubstitutedExpression", "NormalizedBeforeSeries",
      "SeriesResult"};
    componentDiagnostics = Lookup[backend, "ComponentDiagnostics", {}];
    AssociationThread[
      {"Leading", "Subleading", "Nf"},
      (Association @ Table[
        stage -> gammaFreeQ[Lookup[#, stage, Missing["NotAvailable"]]],
        {stage, stages}
      ])& /@ componentDiagnostics
    ]
  ];

Module[{result, integrated, diagnostics, backend, residuals, tTerms,
   tTargets, integratedTargets},
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
  {integrated, diagnostics} = result;
  backend = Lookup[diagnostics, "BackendDiagnostics", <||>];
  tTerms = Lookup[diagnostics, "TTerms", Missing["NotAvailable"]];
  tTargets = A31TTermTargets[0];
  integratedTargets = A31IntegratedAntennaTargets[0];
  residuals = <|
    "TTerms" -> If[ListQ[tTerms],
      A31IntegratedResiduals[tTerms, tTargets],
      Missing["TTermsUnavailable"]
    ],
    "FinalIntegrated" -> If[ListQ[integrated],
      A31IntegratedResiduals[integrated, integratedTargets],
      Missing["IntegratedUnavailable"]
    ]
  |>;
  Print["A31 target residuals:"];
  Print[residuals];
  Print["EulerGamma-free checks:"];
  Print[<|
    "Integrated" -> gammaFreeQ[integrated],
    "TTerms" -> gammaFreeQ[Lookup[diagnostics, "TTerms", integrated]],
    (* NormalizedBeforeSeries intentionally retains unexpanded Gamma functions.
       The public series is the convention boundary relevant to this check. *)
    "PublicSeriesByComponent" -> If[AssociationQ[backend],
      AllTrue[
        Lookup[backend, "ComponentDiagnostics", {}],
        gammaFreeQ[Lookup[#, "SeriesResult", Missing["NotAvailable"]]]&
      ],
      Missing["BackendDiagnosticsUnavailable"]
    ]
  |>];
  Print["EulerGamma-free checks by A31 backend stage:"];
  Print[If[AssociationQ[backend], componentStageGammaChecks[backend], backend]];
  Print["A31 convention bridge:"];
  Print[If[AssociationQ[backend],
    Lookup[backend, "ConventionBridgeFactor", Missing["NotAvailable"]],
    Missing["BackendDiagnosticsUnavailable"]
  ]];
];
