(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

components = {Leading, Subleading, Nf};

Do[
  data = Get[
    FileNameJoin[{"/private/tmp",
      "a22_two_loop_tree_" <> ToString[component] <> "_masters.mx"}]
  ];
  expr =
    (
      data["CoefficientA22LO"] A22TwoLoopTreeMasterValueA22LO[] +
      data["CoefficientA3"] A22TwoLoopTreeMasterValueA3[] +
      data["CoefficientA4"] A22TwoLoopTreeMasterValueA4[] +
      Coefficient[data["RawMapped"], A6MI] A22TwoLoopTreeMasterValueA6[]
    ) /. {d -> 4 - 2 eps, q2 -> 1};
  raw = Normal[Series[expr, {eps, 0, 0}]] // FunctionExpand // FullSimplify;
  rawFC = raw /. eps -> FeynCalc`Epsilon;
  tterm =
    IntegratedAntennaTTerms[
      {A, 2, 2},
      rawFC,
      ExpansionOrder -> 0,
      Component -> component
    ];
  Print["component: ", component];
  Print["raw: ", rawFC];
  Print["t-term: ", tterm];
  Print["residual: ", A22TTermResiduals[tterm, component, 0]];
  Print["---"];
  ,
  {component, components}
];
