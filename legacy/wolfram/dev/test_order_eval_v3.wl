(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];
eps = FeynCalc`Epsilon;

Print["Before ContextPath: ", $ContextPath];
Print["Before evaluation: ", IntegratedLowerAntenna[{A, 2, 1}, 2]];
Print["Before context: ", Context[IntegratedLowerAntenna]];

antenna = BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, Component -> Leading];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];

Print["After ContextPath: ", $ContextPath];
Print["After evaluation: ", IntegratedLowerAntenna[{A, 2, 1}, 2]];
Print["After context: ", Context[IntegratedLowerAntenna]];
Print["All matching names: ", Names["*`IntegratedLowerAntenna"]];
Quit[];
