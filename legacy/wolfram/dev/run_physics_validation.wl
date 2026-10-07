repoRoot = Environment["ANTENNA_PIPELINE_ROOT"];

If[repoRoot === $Failed || repoRoot === "",
  repoRoot = DirectoryName[DirectoryName[$InputFileName]];
];

Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

report = RunSupportedMasslessPhysicsValidation[];

Print["=== PHYSICS VALIDATION REPORT ==="];
Print[report];

Print["=== STATUS COUNTS ==="];
Print[PhysicsValidationStatusCounts[report]];

failCount =
  Count[
    Lookup[Values[report], "ValidationStatus", Missing["UnknownStatus"]],
    "Fail" | "RouteEvaluationFailed"
  ];

If[failCount > 0,
  Exit[1],
  Exit[0]
];
