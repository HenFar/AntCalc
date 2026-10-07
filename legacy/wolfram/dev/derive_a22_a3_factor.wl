(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
data = Get["/private/tmp/a22_two_loop_tree_Leading_masters.mx"];

(* expr: Script-local helper for this development or benchmarking utility. *)
expr[x_] =
  (
    data["CoefficientA22LO"] A22TwoLoopTreeMasterValueA22LO[] +
    x data["CoefficientA3"] A22TwoLoopTreeMasterValueA3[] +
    data["CoefficientA4"] A22TwoLoopTreeMasterValueA4[]
  ) /. {
    d -> 4 - 2 eps,
    q2 -> 1
  };

(* raw: Script-local helper for this development or benchmarking utility. *)
raw[x_] =
  Normal[Series[expr[x], {eps, 0, 0}]] // FunctionExpand // FullSimplify;

target = A22TTermTargetForComponent[Leading, 0];
(* tterm: Script-local helper for this development or benchmarking utility. *)
tterm[x_] =
  IntegratedAntennaTTerms[
    {A, 2, 2},
    raw[x],
    ExpansionOrder -> 0,
    Component -> Leading
  ];

(* residual: Script-local helper for this development or benchmarking utility. *)
residual[x_] = FullSimplify[tterm[x] - target] // Collect[#, eps]&;

Print["residual(x): ", residual[x]];
Print["coeff 1/eps^4: ", SeriesCoefficient[residual[x], {eps, 0, -4}]];
Print["coeff 1/eps^3: ", SeriesCoefficient[residual[x], {eps, 0, -3}]];
Print["solve top two poles: ",
  Solve[
    {
      SeriesCoefficient[residual[x], {eps, 0, -4}] == 0,
      SeriesCoefficient[residual[x], {eps, 0, -3}] == 0
    },
    x
  ]
];
