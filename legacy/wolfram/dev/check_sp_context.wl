(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

(* getVector: Script-local helper for this development or benchmarking utility. *)
getVector[LiteRed`sp[v_, _]] := v;
(* getVector: Script-local helper for this development or benchmarking utility. *)
getVector[v_] := v;

(* simplifySp: Script-local helper for this development or benchmarking utility. *)
simplifySp[expr_] := expr // Expand //. {
  LiteRed`sp[x_ + y_, z_] :> LiteRed`sp[x, z] + LiteRed`sp[y, z],
  LiteRed`sp[x_, y_ + z_] :> LiteRed`sp[x, y] + LiteRed`sp[x, z],
  LiteRed`sp[a_ * x_, y_] :> a * LiteRed`sp[x, y],
  LiteRed`sp[x_, a_ * y_] :> a * LiteRed`sp[x, y],
  LiteRed`sp[0, _] -> 0,
  LiteRed`sp[_, 0] -> 0
} /. {
  LiteRed`sp[k1, k1] -> 0,
  LiteRed`sp[q, q] -> q2,
  LiteRed`sp[k1, q] -> q2/2,
  LiteRed`sp[q, k1] -> q2/2
} // Simplify;

profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];

master = j[A22TwoLoopTreeBasis1, 1, 0, 0, 0, 0, 1, 1];
indices = List @@ master // Rest;
activeDens = Pick[LiteRed`Ds[A22TwoLoopTreeBasis1], indices, _?(# > 0 &)];
activeCount = Length[activeDens];
l1Dens = Select[activeDens, MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2] &];
l2Dens = Select[activeDens, MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1] &];
mixedDens = Select[activeDens, MemberQ[Cases[#, l1, Infinity], l1] && MemberQ[Cases[#, l2, Infinity], l2] &];

v1 = If[Length[l1Dens] == 1, getVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
v2 = If[Length[l2Dens] == 1, getVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
v3 = If[Length[mixedDens] == 1, getVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
Q = (v3 - v1 - v2) // Simplify;
QsqVal = simplifySp[LiteRed`sp[Q, Q]];

Print["QsqVal Input Form: ", InputForm[QsqVal]];
Print["QsqVal Head Context: ", Context[Evaluate[Head[QsqVal]]]];
Quit[];
