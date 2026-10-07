(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

candidate =
  (Pi^4*(-360 + eps*(-1800 + eps*(-6840 + 660*Pi^2 +
        eps^2*(83760 - 13640*Pi^2 + 79*Pi^4 - 16640*Zeta[3]) -
        60*eps*(-390 + 55*Pi^2 + 52*Zeta[3])))))/(1440*eps^2);

generic =
  Normal[Series[A22TwoLoopTreeMasterValueA4[] /. {q2 -> 1}, {eps, 0, 2}]] //
    FunctionExpand // FullSimplify;

difference =
  Normal[Series[candidate - generic, {eps, 0, 2}]] // FullSimplify;

signature = {
  "sp[-k1 + l2, -k1 + l2]",
  "sp[l1, l1]",
  "sp[l1 + l2, l1 + l2]",
  "sp[l1 + q, l1 + q]"
};

Print["Topology label: A22A4Basis8LikeMI"];
Print["Basis origin: A22TwoLoopTreeBasis8"];
Print["Active denominators: ", InputForm[signature]];
Print["Candidate series: ", InputForm[candidate]];
Print["Generic A4 series through O(eps^2): ", InputForm[generic]];
Print["Candidate - generic through O(eps^2): ", InputForm[difference]];

Quit[];
