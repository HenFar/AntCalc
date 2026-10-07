repoRoot = ParentDirectory[DirectoryName[$InputFileName]];

Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

ClearAll[runCase, associationResultQ, backendConventionBridgeQ];

runCase[name_String, heldExpr_Hold, checkFn_] :=
  Module[{result, passedQ},
    Print["Running: ", name];
    result = Quiet[Check[ReleaseHold[heldExpr], $Failed]];
    passedQ = TrueQ[checkFn[result]];
    <|"Name" -> name, "Passed" -> passedQ, "Result" -> result|>
  ];

associationResultQ[result_] :=
  MatchQ[result, {_, _Association}];

backendConventionBridgeQ[result_] :=
  Module[{diagnostics, backendDiagnostics},
    If[!associationResultQ[result],
      Return[False]
    ];
    diagnostics = result[[2]];
    backendDiagnostics = Lookup[diagnostics, "BackendDiagnostics", <||>];
    AssociationQ[backendDiagnostics] &&
      KeyExistsQ[backendDiagnostics, "ConventionBridgeFactor"] &&
      KeyExistsQ[backendDiagnostics, "NormalizedBeforeSeries"] &&
      KeyExistsQ[backendDiagnostics, "SeriesResult"]
  ];

results = {
  runCase[
    "A21 integrated route matches encoded public target",
    Hold[BuildAndIntegrateAntenna[A, 2, 1, ReturnDiagnostics -> True]],
    Function[result,
      associationResultQ[result] &&
        TrueQ[Lookup[result[[2]], "PaVeResidualIsZero", False]] &&
        TrueQ[Lookup[result[[2]], "IntegratedResidualIsZero", False]]
    ]
  ],
  runCase[
    "A31 leading object route exposes convention-bridge diagnostics",
    Hold[
      Module[{obj},
        obj = BuildAntennaObject[A, 3, 1, Component -> Leading];
        IntegrateAntenna[obj, ReturnDiagnostics -> True]
      ]
    ],
    backendConventionBridgeQ
  ],
  runCase[
    "A31 subleading object route exposes convention-bridge diagnostics",
    Hold[
      Module[{obj},
        obj = BuildAntennaObject[A, 3, 1, Component -> Subleading];
        IntegrateAntenna[obj, ReturnDiagnostics -> True]
      ]
    ],
    backendConventionBridgeQ
  ]
};

failed = Select[results, Not[TrueQ[#["Passed"]]] &];

Print[""];
Print["=== TASK 6 VERIFICATION SUMMARY ==="];
Do[
  Print[result["Name"], " | passed=", result["Passed"]],
  {result, results}
];

Print[""];
Print["=== TASK 6 SCOPE ==="];
Print["This script verifies the explicit A21/A31 convention-bridge layer."];
Print["It does not assert the deferred A31 leading/subleading physics fix from Task 5b."];

Print[""];
Print["=== FINAL COUNTS ==="];
Print[
  <|
    "NumTests" -> Length[results],
    "NumPassed" -> Count[results[[All, "Passed"]], True],
    "NumFailed" -> Count[results[[All, "Passed"]], False]
  |>
];

If[failed === {},
  Exit[0],
  Print[""];
  Print["=== FAILED CASES ==="];
  Do[Print[result["Name"]], {result, failed}];
  Exit[1]
];
