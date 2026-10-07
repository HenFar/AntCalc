(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

candidate =
  (Pi^4*(-18 + eps*(-90 + eps*(-342 + 33*Pi^2) +
        2*eps^3*(-390 + 55*Pi^2 + 52*Zeta[3]))))/(72*eps^2);

generic =
  Normal[Series[A22TwoLoopTreeMasterValueA4[] /. {q2 -> 1}, {eps, 0, 2}]] //
    FunctionExpand // FullSimplify;

difference =
  Normal[Series[candidate - generic, {eps, 0, 2}]] // FullSimplify;

signature = {
  "sp[k1 + l2 - q, k1 + l2 - q]",
  "sp[l1, l1]",
  "sp[l1 + l2, l1 + l2]",
  "sp[l1 + q, l1 + q]"
};

Print["Topology label: A22A4Basis7LikeMI"];
Print["Basis origin: A22TwoLoopTreeBasis7"];
Print["Active denominators: ", InputForm[signature]];
Print["Candidate series: ", InputForm[candidate]];
Print["Generic A4 series through O(eps^2): ", InputForm[generic]];
Print["Candidate - generic through O(eps^2): ", InputForm[difference]];

Quit[];
