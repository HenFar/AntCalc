(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

antenna = BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, Component -> Nf];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];

Print["Term Records:"];
records = reduction["TermRecords"];
Do[
  record = records[[i]];
  If[record["MatchedQ"],
    Print["Term ", i, " matched basis ", record["Basis"]];
    Print["  JTerm: ", InputForm[record["JTerm"]]];
    Print["  ReducedTerm: ", InputForm[record["ReducedTerm"]]];
    Print["  MasterRules: ", InputForm[record["MasterRules"]]];
  ];
  , {i, Length[records]}
];

Quit[];
