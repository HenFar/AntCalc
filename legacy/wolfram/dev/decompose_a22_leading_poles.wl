(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
data = Get["/private/tmp/a22_two_loop_tree_Leading_masters.mx"];

parts = <|
  "A22LO" -> (data["CoefficientA22LO"] A22TwoLoopTreeMasterValueA22LO[] /. {d -> 4 - 2 eps, q2 -> 1}),
  "A3" -> (data["CoefficientA3"] A22TwoLoopTreeMasterValueA3[] /. {d -> 4 - 2 eps, q2 -> 1}),
  "A4" -> (data["CoefficientA4"] A22TwoLoopTreeMasterValueA4[] /. {d -> 4 - 2 eps, q2 -> 1})
|>;

KeyValueMap[
  (
    series = Normal[Series[#2, {eps, 0, 0}]] // FunctionExpand // FullSimplify;
    Print[#1, ": ", series];
  )&,
  parts
];
