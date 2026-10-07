(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
Print[InputForm[LiteRed`Ds[A22TwoLoopTreeBasis1]]];
Quit[];
