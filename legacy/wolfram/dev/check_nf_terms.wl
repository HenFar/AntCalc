(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

antenna = BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, Component -> Nf];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];

Print["Term Records:"];
Do[
  If[record["MatchedQ"],
    Print["Term ", i, " matched basis ", record["Basis"], " with JTerm: ", InputForm[record["JTerm"]]];
    Print["LiteRed IBPReduce: ", InputForm[record["ReducedTerm"]]];
  ];
  , {i, Length[reduction["TermRecords"]]}
];

Quit[];
