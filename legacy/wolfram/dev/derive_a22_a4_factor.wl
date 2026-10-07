(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
data = Get["/private/tmp/a22_two_loop_tree_Nf_masters.mx"];
raw =
  Normal[
    Series[
      (data["CoefficientA4"] A22TwoLoopTreeMasterValueA4[] /. {
        d -> 4 - 2 eps,
        q2 -> 1
      }),
      {eps, 0, 0}
    ]
  ] // FunctionExpand // FullSimplify;

counterterm = -( -2/(6 eps)) IntegratedLowerAntenna[{A, 2, 1}, 2];
target = A22TTermTargetForComponent[Nf, 0];

factor =
  Normal[
    Series[
      FullSimplify[(target - counterterm)/raw],
      {eps, 0, 3}
    ]
  ] // FullSimplify // Collect[#, eps]&;

Print["raw: ", raw];
Print["counterterm: ", IntegratedAntennaSeries[counterterm, 0]];
Print["target: ", target];
Print["factor: ", factor];
