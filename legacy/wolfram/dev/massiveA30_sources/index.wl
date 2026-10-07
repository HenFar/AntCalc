repoRoot = DirectoryName[DirectoryName[DirectoryName[$InputFileName]]];

If[!ValueQ[$AntennaPipelineRoot],
  Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];
];

MassiveA30BibliographyResults::usage =
  "MassiveA30BibliographyResults[] returns the bibliography-facing massive A30 bundle for the current milestone.";

MassiveA30BibliographyResults[] :=
  <|
    "Key" -> {A, 3, 0},
    "Milestone" -> "BibliographyMatch",
    "Unintegrated" -> <|
      "PaperConvention" -> MassiveA30UnintegratedPaperConvention[],
      "PackageConventionCandidate" ->
        MassiveA30UnintegratedPackageConventionCandidate[],
      "Report" -> MassiveA30UnintegratedReport[]
    |>,
    "Integrated" -> <|
      "PaperConvention" -> MassiveA30IntegratedPaperConvention[],
      "PackageConventionCandidate" ->
        MassiveA30IntegratedPackageConventionCandidate[],
      "Report" -> MassiveA30IntegratedReport[]
    |>,
    "Metadata" -> <|
      "ThesisSource" -> MassiveA30UnintegratedSource[],
      "PaperSource" -> MassiveA30IntegratedSource[]
    |>
  |>;
