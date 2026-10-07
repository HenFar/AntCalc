(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];
eps = FeynCalc`Epsilon;

Print["Before: ", IntegratedLowerAntenna[{A, 2, 1}, 2]];

antenna = BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, Component -> Leading];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];

Print["After: ", IntegratedLowerAntenna[{A, 2, 1}, 2]];
Quit[];
