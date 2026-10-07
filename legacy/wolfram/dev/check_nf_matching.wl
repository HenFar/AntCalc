(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

antenna = BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, Component -> Nf];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];

Print["Head of reduction: ", Head[reduction]];
Print["Keys of reduction: ", Keys[reduction]];
Print["Unmatched terms count: ", reduction["UnmatchedCount"]];
If[reduction["UnmatchedCount"] > 0,
  Print["Unmatched terms: ", InputForm[reduction["UnmatchedTerms"]]];
];
Quit[];
