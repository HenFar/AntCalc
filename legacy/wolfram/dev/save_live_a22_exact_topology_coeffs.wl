(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

labels = A22TwoLoopTreeExactTopologyLabels[];
components = {Leading, Subleading, Global`Nf};

(* extractForComponent: Script-local helper for this development or benchmarking utility. *)
extractForComponent[component_] :=
  Module[{res, diag, expr, normalized, rawIntegrated},
    {res, diag} = IntegrateAntenna[A, 2, 2,
      Contribution -> TwoLoopTree,
      Component -> component,
      ReturnDiagnostics -> True,
      ExpansionOrder -> 0
    ];
    expr = diag["BackendDiagnostics", "ReductionStages", "MasterMappedExpression"];
    normalized = diag["BackendDiagnostics", "ReductionStages", "NormalizedBeforeSeries"];
    rawIntegrated = diag["RawIntegrated"];
    <|
      "Component" -> ToString[component],
      "RawIntegrated" -> rawIntegrated,
      "MasterMappedCoefficients" -> Association@Table[
        labels[[i]] -> FullSimplify[Coefficient[expr, labels[[i]]]],
        {i, Length[labels]}
      ],
      "NormalizedCoefficients" -> Association@Table[
        labels[[i]] -> FullSimplify[
          Coefficient[
            normalized /. Thread[labels -> Array[a22x, Length[labels]]],
            a22x[i]
          ]
        ],
        {i, Length[labels]}
      ],
      "TTermResiduals" -> diag["TTermResiduals"]
    |>
  ];

result = Association@Table[
  ToString[components[[i]]] -> extractForComponent[components[[i]]],
  {i, Length[components]}
];

outfile = "/private/tmp/a22_live_exact_topology_coeffs.mx";
Put[result, outfile];
Print["saved: ", outfile];
Quit[];
