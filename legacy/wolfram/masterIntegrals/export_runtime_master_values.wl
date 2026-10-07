scriptDirectory = DirectoryName[$InputFileName];

Get[FileNameJoin[{scriptDirectory, "runtime_values.wl"}]];
LoadRuntimeMasterValueSources[];

runtimeValues = MasterIntegralRuntimeValuesAssociation[];
outputPath = FileNameJoin[{scriptDirectory, "master_values_runtime.wl"}];

Put[runtimeValues, outputPath];

Print["Exported runtime master values to: ", outputPath];
