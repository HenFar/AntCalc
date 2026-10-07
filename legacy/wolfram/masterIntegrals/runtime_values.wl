runtimeValuesDirectory = DirectoryName[$InputFileName];

LoadRuntimeMasterValueSources[] :=
  Module[{requiredFiles},
    requiredFiles = {
      "common.wl",
      "A22LO.wl",
      "A3.wl",
      "A4.wl",
      "A6.wl",
      "V5a.wl",
      "V5b.wl",
      "V8.wl"
    };
    Scan[
      Get[FileNameJoin[{runtimeValuesDirectory, #}]]&,
      requiredFiles
    ];
  ];

MasterIntegralRuntimeSchemaVersion = 1;

MasterIntegralRuntimeValuesAssociation[] :=
  <|
    "SchemaVersion" -> MasterIntegralRuntimeSchemaVersion,
    "GeneratedFrom" -> "masterIntegrals",
    "A22TwoLoopTree" -> <|
      "A22LO" -> A22LOBackendPackageExact[],
      "A3" -> A3BackendPackageExact[],
      "A4" -> A4BackendPackageExact[],
      "A6" -> A6BackendPackageExact[]
    |>,
    "A31" -> <|
      "qMI" -> -I V5aBackendScalarPart[],
      "qkMI" -> -I V5bBackendScalarPart[],
      "qsMI" -> I V8BackendScalarExact[]
    |>
  |>;
