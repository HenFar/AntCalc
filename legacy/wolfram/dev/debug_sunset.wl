(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];

basis = A22TwoLoopTreeBasis1;
master = j[A22TwoLoopTreeBasis1, 0, 0, 0, 1, 0, 1, 1];
indices = List @@ master // Rest;
activeDenominators = Pick[LiteRed`Ds[basis], indices, _?(# > 0&)];

l1Dens = Select[activeDenominators, MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2]&];
l2Dens = Select[activeDenominators, MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1]&];
mixedDens = Select[activeDenominators, MemberQ[Cases[#, l1, Infinity], l1] && MemberQ[Cases[#, l2, Infinity], l2]&];

Print["activeDenominators: ", InputForm[activeDenominators]];
Print["l1Dens: ", InputForm[l1Dens]];
Print["l2Dens: ", InputForm[l2Dens]];
Print["mixedDens: ", InputForm[mixedDens]];

v1 = If[Length[l1Dens] == 1, A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
v2 = If[Length[l2Dens] == 1, A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
v3 = If[Length[mixedDens] == 1, A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];

Print["v1: ", InputForm[v1]];
Print["v2: ", InputForm[v2]];
Print["v3: ", InputForm[v3]];

Q = (v3 - v1 - v2) // Simplify;
Print["Q: ", InputForm[Q]];
QsqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[Q, Q]];
Print["QsqVal: ", InputForm[QsqVal]];

Quit[];
