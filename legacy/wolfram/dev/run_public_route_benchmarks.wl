(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

scriptRoot = DirectoryName[$InputFileName];

Get[FileNameJoin[{DirectoryName[scriptRoot], "AntennaPipeline.wl"}]];

benchmarkTimeoutSeconds =
  Module[{raw = Environment["ANTENNA_BENCHMARK_TIMEOUT"]},
    If[StringQ[raw] && StringLength[raw] > 0,
      ToExpression[raw],
      300
    ]
  ];

selectedRouteLabels =
  Module[{raw = Environment["ANTENNA_BENCHMARK_LABELS"]},
    If[StringQ[raw] && StringLength[StringTrim[raw]] > 0,
      StringTrim /@ StringSplit[raw, ","],
      All
    ]
  ];

(* stringifyValue: Script-local helper for this development or benchmarking utility. *)
stringifyValue[value_] :=
  Which[
    MatchQ[value, _Missing], ToString[value, InputForm],
    Head[value] === Symbol, SymbolName[Unevaluated[value]],
    StringQ[value], value,
    True, ToString[value, InputForm]
  ];

(* serializeValue: Script-local helper for this development or benchmarking utility. *)
serializeValue[value_] :=
  Which[
    AssociationQ[value], serializeAssociation[value],
    ListQ[value], serializeValue /@ value,
    StringQ[value] || NumberQ[value] || BooleanQ[value], value,
    MatchQ[value, _Missing] || Head[value] === Symbol, stringifyValue[value],
    True, stringifyValue[value]
  ];

(* serializeAssociation: Script-local helper for this development or benchmarking utility. *)
serializeAssociation[assoc_Association] :=
  Association @ KeyValueMap[
    With[{serialized = serializeValue[#2]},
      #1 -> serialized
    ]&,
    assoc
  ];

(* routeOptionsSummary: Script-local helper for this development or benchmarking utility. *)
routeOptionsSummary[route_Association] :=
  <|
    "Component" -> Lookup[route, "ComponentLabel", "All"],
    "Contribution" -> Lookup[route, "ContributionLabel", "All"],
    "ExpansionOrder" -> Lookup[route, "ExpansionOrderLabel", "default"]
  |>;

(* extractDiagnosticSummary: Script-local helper for this development or benchmarking utility. *)
extractDiagnosticSummary[diag_] :=
  Module[{backend, backendProfile, baseSummary},
    If[!AssociationQ[diag],
      Return[<||>]
    ];
    backend = Lookup[diag, "BackendDiagnostics", <||>];
    backendProfile = Lookup[backend, "Profile", <||>];
    baseSummary =
      <|
        "SelectedComponent" -> serializeValue[
          Lookup[diag, "SelectedComponent", Missing["NotAvailable"]]
        ],
        "Contribution" -> serializeValue[
          Lookup[diag, "Contribution", Missing["NotAvailable"]]
        ],
        "BasisFamily" -> serializeValue[
          Lookup[
            If[AssociationQ[backendProfile], backendProfile, Lookup[diag, "Profile", <||>]],
            "BasisFamily",
            Missing["NotAvailable"]
          ]
        ],
        "UnmatchedCount" -> serializeValue[
          Lookup[backend, "UnmatchedCount", Missing["NotAvailable"]]
        ],
        "RemainingTojSpOrDotQ" -> serializeValue[
          Lookup[backend, "RemainingTojSpOrDotQ", Missing["NotAvailable"]]
        ],
        "Failed" -> serializeValue[Lookup[diag, "Failed", False]],
        "Reason" -> serializeValue[Lookup[diag, "Reason", Missing["NotAvailable"]]]
      |>;
    Association @ KeyValueMap[
      If[#2 === "Missing[\"NotAvailable\"]",
        Nothing,
        #1 -> #2
      ]&,
      baseSummary
    ]
  ];

(* benchmarkCall: Script-local helper for this development or benchmarking utility. *)
benchmarkCall[route_Association, entryPoint_String, thunk_] :=
  Module[{timedOut = False, elapsed, outcome, value, diag, base},
    Print[
      "[", DateString[{"ISODate", " ", "Time"}], "] ",
      route["Label"], " :: ", entryPoint, " :: starting"
    ];
    {elapsed, outcome} =
      AbsoluteTiming[
        TimeConstrained[
          Quiet[thunk[], IntegrateAntenna::heavy],
          benchmarkTimeoutSeconds,
          (timedOut = True; $Aborted)
        ]
      ];
    Print[
      "[", DateString[{"ISODate", " ", "Time"}], "] ",
      route["Label"], " :: ", entryPoint, " :: ",
      If[timedOut, "timed out", "finished"],
      " in ", ToString[Round[1000. N[elapsed]]/1000., InputForm], " s"
    ];
    base =
      Join[
        <|
          "RouteLabel" -> route["Label"],
          "EntryPoint" -> entryPoint,
          "WallClockSeconds" -> N[elapsed],
          "TimedOut" -> timedOut
        |>,
        routeOptionsSummary[route]
      ];
    If[timedOut,
      Return[
        <|
          "Benchmark" -> Join[base, <|"Success" -> False, "FailureSummary" -> "TimedOut"|>],
          "Value" -> $Aborted,
          "Diagnostics" -> <||>
        |>
      ]
    ];
    If[outcome === $Failed,
      Return[
        <|
          "Benchmark" -> Join[base, <|"Success" -> False, "FailureSummary" -> "ReturnedFailed"|>],
          "Value" -> $Failed,
          "Diagnostics" -> <||>
        |>
      ]
    ];
    If[ListQ[outcome] && Length[outcome] == 2 && AssociationQ[outcome[[2]]],
      value = outcome[[1]];
      diag = outcome[[2]];
      Return[
        <|
          "Benchmark" -> Join[
            base,
            <|
              "Success" -> TrueQ[value =!= $Failed],
              "FailureSummary" ->
                If[value === $Failed,
                  "ValueFailed",
                  "None"
                ]
            |>,
            extractDiagnosticSummary[diag]
          ],
          "Value" -> value,
          "Diagnostics" -> diag
        |>
      ]
    ];
    <|
      "Benchmark" -> Join[base, <|"Success" -> TrueQ[outcome =!= $Failed], "FailureSummary" -> "None"|>],
      "Value" -> outcome,
      "Diagnostics" -> <||>
    |>
  ];

(* buildCallArguments: Script-local helper for this development or benchmarking utility. *)
buildCallArguments[route_Association] :=
  Join[
    {
      route["Type"],
      route["NumFinalParticles"],
      route["LoopOrder"]
    },
    Lookup[route, "BuildOptions", {}]
  ];

(* integrationCallArguments: Script-local helper for this development or benchmarking utility. *)
integrationCallArguments[route_Association] :=
  Lookup[route, "IntegrationOptions", {}];

benchmarkRoutes = {
  <|"Label" -> "A20", "Type" -> A, "NumFinalParticles" -> 2, "LoopOrder" -> 0,
    "BuildOptions" -> {}, "IntegrationSupported" -> False|>,
  <|"Label" -> "A30", "Type" -> A, "NumFinalParticles" -> 3, "LoopOrder" -> 0,
    "BuildOptions" -> {}, "IntegrationOptions" -> {ExpansionOrder -> 0},
    "ExpansionOrderLabel" -> "0", "IntegrationSupported" -> True|>,
  <|"Label" -> "A40 Leading", "Type" -> A, "NumFinalParticles" -> 4,
    "LoopOrder" -> 0, "BuildOptions" -> {Component -> Leading},
    "IntegrationOptions" -> {Component -> Leading, ExpansionOrder -> 0},
    "ComponentLabel" -> "Leading", "ExpansionOrderLabel" -> "0",
    "IntegrationSupported" -> True|>,
  <|"Label" -> "A40 Subleading", "Type" -> A, "NumFinalParticles" -> 4,
    "LoopOrder" -> 0, "BuildOptions" -> {Component -> Subleading},
    "IntegrationOptions" -> {Component -> Subleading, ExpansionOrder -> 0},
    "ComponentLabel" -> "Subleading", "ExpansionOrderLabel" -> "0",
    "IntegrationSupported" -> True|>,
  <|"Label" -> "B40", "Type" -> B, "NumFinalParticles" -> 4, "LoopOrder" -> 0,
    "BuildOptions" -> {}, "IntegrationOptions" -> {ExpansionOrder -> 0},
    "ExpansionOrderLabel" -> "0", "IntegrationSupported" -> True|>,
  <|"Label" -> "C40", "Type" -> C, "NumFinalParticles" -> 4, "LoopOrder" -> 0,
    "BuildOptions" -> {}, "IntegrationOptions" -> {ExpansionOrder -> 0},
    "ExpansionOrderLabel" -> "0", "IntegrationSupported" -> True|>,
  <|"Label" -> "A21", "Type" -> A, "NumFinalParticles" -> 2, "LoopOrder" -> 1,
    "BuildOptions" -> {}, "IntegrationOptions" -> {},
    "IntegrationSupported" -> True|>,
  <|"Label" -> "A31 Leading", "Type" -> A, "NumFinalParticles" -> 3,
    "LoopOrder" -> 1, "BuildOptions" -> {Component -> Leading},
    "IntegrationOptions" -> {Component -> Leading, ExpansionOrder -> 0},
    "ComponentLabel" -> "Leading", "ExpansionOrderLabel" -> "0",
    "IntegrationSupported" -> True|>,
  <|"Label" -> "A22 Leading", "Type" -> A, "NumFinalParticles" -> 2,
    "LoopOrder" -> 2,
    "BuildOptions" -> {Contribution -> TwoLoopTree, Component -> Leading},
    "IntegrationOptions" -> {Contribution -> TwoLoopTree, Component -> Leading,
      ExpansionOrder -> 0},
    "ComponentLabel" -> "Leading", "ContributionLabel" -> "TwoLoopTree",
    "ExpansionOrderLabel" -> "0", "IntegrationSupported" -> True|>,
  <|"Label" -> "A22 full stitched", "Type" -> A, "NumFinalParticles" -> 2,
    "LoopOrder" -> 2, "BuildOptions" -> {},
    "IntegrationOptions" -> {ExpansionOrder -> 0},
    "ExpansionOrderLabel" -> "0", "IntegrationSupported" -> True|>
};

rRatioBenchmarkRoutes = {
  <|"Label" -> "RRatio SMQCD", "Model" -> SMQCD,
    "DriverOptions" -> {quarkMass -> 0}|>,
  <|"Label" -> "RRatio SMQCD cached", "Model" -> SMQCD,
    "DriverOptions" -> {quarkMass -> 0, UseStoredResults -> True},
    "CacheModeLabel" -> "CacheHitRequested"|>
};

filteredRoutes =
  If[selectedRouteLabels === All,
    Join[benchmarkRoutes, rRatioBenchmarkRoutes],
    Join[
      Select[benchmarkRoutes, MemberQ[selectedRouteLabels, #["Label"]]&],
      Select[rRatioBenchmarkRoutes, MemberQ[selectedRouteLabels, #["Label"]]&]
    ]
  ];

(* runRouteBenchmarks: Script-local helper for this development or benchmarking utility. *)
runRouteBenchmarks[route_Association] :=
  Module[{buildResult, buildObjectResult, integrateResult, combinedResult,
     buildArgs, integrateArgs, prebuiltObject, skippedIntegration},
    buildArgs = buildCallArguments[route];
    integrateArgs = integrationCallArguments[route];
    buildResult =
      benchmarkCall[
        route,
        "BuildAntenna",
        Function[
          BuildAntenna @@ Join[buildArgs, {ReturnDiagnostics -> True,
            RunPaperCheck -> False}]
        ]
      ];
    buildObjectResult =
      benchmarkCall[
        route,
        "BuildAntennaObject",
        Function[
          BuildAntennaObject @@ Join[buildArgs, {ReturnDiagnostics -> True,
            RunPaperCheck -> False}]
        ]
      ];
    prebuiltObject = buildObjectResult["Value"];
    skippedIntegration =
      <|
        "Benchmark" -> Join[
          <|
            "RouteLabel" -> route["Label"],
            "EntryPoint" -> "IntegrateAntenna",
            "WallClockSeconds" -> 0.,
            "TimedOut" -> False,
            "Success" -> False,
            "FailureSummary" -> "Skipped"
          |>,
          routeOptionsSummary[route],
          <|"Reason" -> "IntegrationNotSupported"|>
        ],
        "Value" -> $Failed,
        "Diagnostics" -> <||>
      |>;
    integrateResult =
      If[!TrueQ[Lookup[route, "IntegrationSupported", True]],
        skippedIntegration,
        If[Head[prebuiltObject] =!= AntennaObject,
          <|
            "Benchmark" -> Join[
              <|
                "RouteLabel" -> route["Label"],
                "EntryPoint" -> "IntegrateAntenna",
                "WallClockSeconds" -> 0.,
                "TimedOut" -> False,
                "Success" -> False,
                "FailureSummary" -> "PrebuiltObjectUnavailable"
              |>,
              routeOptionsSummary[route]
            ],
            "Value" -> $Failed,
            "Diagnostics" -> <||>
          |>,
          benchmarkCall[
            route,
            "IntegrateAntenna",
            Function[
              IntegrateAntenna[
                prebuiltObject,
                ReturnDiagnostics -> True,
                Sequence @@ integrateArgs
              ]
            ]
          ]
        ]
      ];
    combinedResult =
      If[!TrueQ[Lookup[route, "IntegrationSupported", True]],
        <|
          "Benchmark" -> Join[
            <|
              "RouteLabel" -> route["Label"],
              "EntryPoint" -> "BuildAndIntegrateAntenna",
              "WallClockSeconds" -> 0.,
              "TimedOut" -> False,
              "Success" -> False,
              "FailureSummary" -> "IntegrationNotSupported"
            |>,
            routeOptionsSummary[route]
          ],
          "Value" -> $Failed,
          "Diagnostics" -> <||>
        |>,
        benchmarkCall[
          route,
          "BuildAndIntegrateAntenna",
          Function[
            BuildAndIntegrateAntenna @@ Join[
              buildArgs,
              {ReturnDiagnostics -> True},
              integrateArgs
            ]
          ]
        ]
      ];
    {
      buildResult["Benchmark"],
      buildObjectResult["Benchmark"],
      integrateResult["Benchmark"],
      combinedResult["Benchmark"]
    }
  ];

(* runRRatioBenchmarks: Script-local helper for this development or benchmarking utility. *)
runRRatioBenchmarks[route_Association] :=
  Module[{driverOptions, rratioResult, modelSymbol},
    driverOptions = Lookup[route, "DriverOptions", {}];
    modelSymbol = Lookup[route, "Model", Missing["UnknownModel"]];
    rratioResult =
      benchmarkCall[
        <|"Label" -> route["Label"], "ComponentLabel" -> "All",
          "ContributionLabel" -> "All", "ExpansionOrderLabel" -> "default"|>,
        "BuildRRatio",
        Function[
          BuildRRatio[
            route["Model"],
            Sequence @@ Join[driverOptions, {ReturnDiagnostics -> True}]
          ]
        ]
      ];
    {
      Join[
        rratioResult["Benchmark"],
        <|
          "Model" -> ToString[modelSymbol, InputForm],
          "CacheMode" -> Lookup[route, "CacheModeLabel",
            "FreshOrDefault"]
        |>
      ]
    }
  ];

results =
  Flatten[
    If[KeyExistsQ[#, "Model"],
      runRRatioBenchmarks[#],
      runRouteBenchmarks[#]
    ]& /@ filteredRoutes,
    1
  ];

report =
  <|
    "GeneratedAt" -> DateString[{"ISODate", "T", "Time"}],
    "BenchmarkTimeoutSeconds" -> benchmarkTimeoutSeconds,
    "RouteCount" -> Length[filteredRoutes],
    "Results" -> serializeAssociation /@ results
  |>;

outputPath = Environment["ANTENNA_BENCHMARK_OUTPUT"];

If[StringQ[outputPath] && StringLength[StringTrim[outputPath]] > 0,
  Export[outputPath, report, "RawJSON"]
];

If[Environment["ANTENNA_BENCHMARK_DEBUG"] === "1",
  Print[InputForm[report]]
];

Print[ExportString[report, "RawJSON"]];
