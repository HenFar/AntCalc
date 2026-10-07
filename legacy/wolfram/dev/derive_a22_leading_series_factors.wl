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

target = A22TTermTargetForComponent[Leading, 0];
c22 = a0 + a1 eps;
c3 = b0 + b1 eps;
raw =
  Normal[Series[expr[c22, c3], {eps, 0, 0}]] // FunctionExpand // FullSimplify;
tterm =
  IntegratedAntennaTTerms[
    {A, 2, 2},
    raw,
    ExpansionOrder -> 0,
    Component -> Leading
  ];
residual = FullSimplify[tterm - target] // Collect[#, eps]&;
eqns = Table[SeriesCoefficient[residual, {eps, 0, n}] == 0, {n, -4, -1}];
sol = Solve[eqns, {a0, a1, b0, b1}];

Print["solution: ", sol];
If[Length[sol] > 0,
  Print["residual at solution: ", FullSimplify[residual /. sol[[1]]]]
];
