(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
data = Get["/private/tmp/a22_two_loop_tree_Leading_masters.mx"];

(* expr: Script-local helper for this development or benchmarking utility. *)
expr[c22_, c3_] =
  (
    c22 data["CoefficientA22LO"] A22TwoLoopTreeMasterValueA22LO[] +
    c3 data["CoefficientA3"] A22TwoLoopTreeMasterValueA3[] +
    data["CoefficientA4"] A22TwoLoopTreeMasterValueA4[]
  ) /. {
    d -> 4 - 2 eps,
    q2 -> 1
  };

(* raw: Script-local helper for this development or benchmarking utility. *)
raw[c22_, c3_] =
  Normal[Series[expr[c22, c3], {eps, 0, 0}]] // FunctionExpand // FullSimplify;

target = A22TTermTargetForComponent[Leading, 0];
(* tterm: Script-local helper for this development or benchmarking utility. *)
tterm[c22_, c3_] =
  IntegratedAntennaTTerms[
    {A, 2, 2},
    raw[c22, c3],
    ExpansionOrder -> 0,
    Component -> Leading
  ];

(* residual: Script-local helper for this development or benchmarking utility. *)
residual[c22_, c3_] = FullSimplify[tterm[c22, c3] - target] // Collect[#, eps]&;

eqns = {
  SeriesCoefficient[residual[c22, c3], {eps, 0, -4}] == 0,
  SeriesCoefficient[residual[c22, c3], {eps, 0, -3}] == 0
};

sol = Solve[eqns, {c22, c3}];

Print["residual(c22,c3): ", residual[c22, c3]];
Print["solution from top poles: ", sol];
If[Length[sol] > 0,
  Print["full residual at solution: ", FullSimplify[residual[c22, c3] /. sol[[1]]]]
];
