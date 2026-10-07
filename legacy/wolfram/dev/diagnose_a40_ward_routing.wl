repoRoot = Environment["ANTENNA_PIPELINE_ROOT"];

If[repoRoot === $Failed || repoRoot === "",
  repoRoot = DirectoryName[DirectoryName[$InputFileName]];
];

Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

compactResidual[residual_] :=
  Which[
    residual === 0, 0,
    MemberQ[{$Failed, $Aborted}, residual], residual,
    True, <|"NonzeroResidualLeafCount" -> LeafCount[residual]|>
  ];

Module[{amplitude, replaced, routed, directResidual, routedResidual},
  amplitude = AntennaAmplitude[{A, 4, 0}];
  replaced = WardIdentityReplacePolarization[amplitude, k3];
  routed = Quiet[Check[
    FCRerouteMomenta[replaced, {p}, {k1, k2, k3, k4}],
    $Failed
  ]];
  directResidual = WardIdentitySimplifyResidual[replaced, 4, {4}];
  routedResidual = If[routed === $Failed, $Failed,
    WardIdentitySimplifyResidual[routed, 4, {4}]
  ];
  Print["=== A40 WARD ROUTING DIAGNOSTIC ==="];
  Print[<|
    "DirectResidual" -> compactResidual[directResidual],
    "ReroutingCompletedQ" -> (routed =!= $Failed),
    "ReroutedResidual" -> compactResidual[routedResidual],
    "ReroutedAmplitudeLeafCount" -> If[routed === $Failed,
      Missing["NotAvailable"], LeafCount[routed]
    ]
  |>];
];
