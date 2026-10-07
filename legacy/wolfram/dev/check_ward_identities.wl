repoRoot = Environment["ANTENNA_PIPELINE_ROOT"];

If[repoRoot === $Failed || repoRoot === "",
  repoRoot = DirectoryName[DirectoryName[$InputFileName]];
];

Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

reports = VerifyWardIdentity[ReturnDiagnostics -> True];
WardIdentityPrintSuite[reports];

If[AllTrue[Values[reports], Lookup[#, "ValidationStatus", "Failed"] === "Pass" &],
  Exit[0],
  Exit[1]
];
