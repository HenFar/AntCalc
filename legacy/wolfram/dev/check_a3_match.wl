(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

coreA3 = A22TwoLoopTreeMasterCoreA3[];
powerTerm = Cases[coreA3, _Power, Infinity][[5]];

(* Get the eps symbol inside the powerTerm *)
epsInside = Cases[powerTerm, _Symbol, Infinity][[2]];
Print["epsInside context: ", Context[epsInside]];
Print["eps parsed context: ", Context[eps]];

(* Are they the same symbol? *)
Print["Same symbol? ", SameQ[epsInside, Symbol["Global`eps"]]];
Print["Context of epsInside: ", Context[Evaluate[epsInside]]];

Quit[];
