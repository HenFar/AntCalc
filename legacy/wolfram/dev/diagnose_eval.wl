(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];
Print["Context A22TwoLoopTreeMasterValueA22LO: ", Context[A22TwoLoopTreeMasterValueA22LO]];
Print["Definition: ", Definition[A22TwoLoopTreeMasterValueA22LO]];
Print["Value: ", A22TwoLoopTreeMasterValueA22LO[]];
Quit[];
