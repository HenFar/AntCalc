(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

data = Get["/private/tmp/a22_two_loop_tree_Nf_masters.mx"];

expr =
  data["CoefficientA4"] A22TwoLoopTreeMasterValueA4[] /. {
    d -> 4 - 2 eps,
    q2 -> 1
  };

raw = Normal[Series[expr, {eps, 0, 0}]] // FunctionExpand // FullSimplify;
rawFC = raw /. eps -> FeynCalc`Epsilon;

Print["raw: ", rawFC];
Print["t-term: ",
  IntegratedAntennaTTerms[
    {A, 2, 2},
    rawFC,
    ExpansionOrder -> 0,
    Component -> Nf
  ]
];
Print["target: ", A22TTermTargetForComponent[Nf, 0]];
