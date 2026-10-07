(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];
expr1 = LiteRed`sp[k1 + q, k1 + q];
Print["Input Form: ", InputForm[expr1]];
Print["Context of Head: ", Context[Evaluate[Head[expr1]]]];
Quit[];
