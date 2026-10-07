repoRoot = DirectoryName[DirectoryName[DirectoryName[$InputFileName]]];

If[!ValueQ[$AntennaPipelineRoot],
  Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];
];
