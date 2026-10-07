(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
data = Get["/private/tmp/a22_two_loop_tree_Leading_masters.mx"];

baseNoA4 =
  (
    data["CoefficientA22LO"] A22TwoLoopTreeMasterValueA22LO[] +
    data["CoefficientA3"] A22TwoLoopTreeMasterValueA3[]
  ) /. {d -> 4 - 2 eps, q2 -> 1};

a4Part =
  (data["CoefficientA4"] A22TwoLoopTreeMasterValueA4[] /. {d -> 4 - 2 eps, q2 -> 1});

(* raw: Script-local helper for this development or benchmarking utility. *)
raw[f_] =
  Normal[Series[f baseNoA4 + a4Part, {eps, 0, 0}]] //
    FunctionExpand // FullSimplify;

target = A22TTermTargetForComponent[Leading, 0];
(* tterm: Script-local helper for this development or benchmarking utility. *)
tterm[f_] =
  IntegratedAntennaTTerms[
    {A, 2, 2},
    raw[f],
    ExpansionOrder -> 0,
    Component -> Leading
  ];

factor = 1 + a eps + b eps^2 + c eps^3;
residual = FullSimplify[tterm[factor] - target] // Collect[#, eps]&;
eqns = Table[SeriesCoefficient[residual, {eps, 0, n}] == 0, {n, -4, -1}];
sol = Solve[eqns, {a, b, c}];

Print["residual(f): ", residual];
Print["solution: ", sol];
If[Length[sol] > 0,
  Print["finite residual: ", FullSimplify[residual /. sol[[1]]]]
];
