(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];

Do[
  Print["\n=== Basis ", i, " ==="];
  basis = Symbol["A22TwoLoopTreeBasis" <> ToString[i]];
  masters = LiteRed`MIs[basis];
  Do[
    val = A22TwoLoopTreeRefinedMasterValue[master, basis];
    Print["Master: ", InputForm[master]];
    Print["  Value: ", InputForm[val]];
    , {master, masters}
  ];
  , {i, 8}
];

Quit[];
