(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];
eps = FeynCalc`Epsilon;
a21Val = IntegratedLowerAntenna[{A, 2, 1}, 2];
Print["a21Val: ", a21Val];
Quit[];
