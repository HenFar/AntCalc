(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
den = First[LiteRed`Ds[A22TwoLoopTreeBasis1]];
Print["Denominator: ", InputForm[den]];
Print["Head: ", InputForm[Head[den]]];
Print["Context of Head: ", Context[Evaluate[Head[den]]]];
Quit[];
