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

(* refinedA22LOMI: Script-local helper for this development or benchmarking utility. *)
refinedA22LOMI[p1sq_, p2sq_] := Module[{val},
  val = A22TwoLoopTreeMasterValueA22LO[];
  val * (p1sq * p2sq / q2^2)^(-eps)
];

(* refinedA3MI: Script-local helper for this development or benchmarking utility. *)
refinedA3MI[Qsq_] := Module[{val},
  val = A22TwoLoopTreeMasterValueA3[];
  val * (Qsq / q2)^(1 - 2 eps)
];

(* refinedA4MI: Script-local helper for this development or benchmarking utility. *)
refinedA4MI[Qsq_] := Module[{val},
  val = A22TwoLoopTreeMasterValueA4[];
  val * (Qsq / q2)^(-2 eps)
];

(* refinedA6MI: Script-local helper for this development or benchmarking utility. *)
refinedA6MI[Qsq_] := Module[{val},
  val = A22TwoLoopTreeMasterValueA6[];
  val * (Qsq / q2)^(-2 - 2 eps)
];

profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];

Do[
  Print["\n=== Basis ", i, " ==="];
  masters = LiteRed`MIs[Symbol["A22TwoLoopTreeBasis" <> ToString[i]]];
  Do[
    indices = List @@ master // Rest;
    activeDens = Pick[LiteRed`Ds[Symbol["A22TwoLoopTreeBasis" <> ToString[i]]], indices, _?(# > 0 &)];
    activeCount = Length[activeDens];
    
    l1Dens = Select[activeDens, MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2] &];
    l2Dens = Select[activeDens, MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1] &];
    mixedDens = Select[activeDens, MemberQ[Cases[#, l1, Infinity], l1] && MemberQ[Cases[#, l2, Infinity], l2] &];
    
    Print["Master: ", InputForm[master]];
    
    (* Sunset *)
    If[activeCount == 3,
      v1 = If[Length[l1Dens] == 1, getVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
      v2 = If[Length[l2Dens] == 1, getVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
      v3 = If[Length[mixedDens] == 1, getVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
      Q = (v3 - v1 - v2) // Simplify;
      QsqVal = simplifySp[LiteRed`sp[Q, Q]];
      Print["  v1 = ", InputForm[v1], ", v2 = ", InputForm[v2], ", v3 = ", InputForm[v3]];
      Print["  Q = ", InputForm[Q], ", QsqVal = ", InputForm[QsqVal]];
    ];
    
    (* Disconnected Bubble *)
    If[A22DisconnectedBubbleMasterQ[activeDens],
      u1 = getVector[l1Dens[[1]]] /. {l1 -> 0};
      u2 = getVector[l1Dens[[2]]] /. {l1 -> 0};
      p1 = (u2 - u1) // Simplify;
      w1 = getVector[l2Dens[[1]]] /. {l2 -> 0};
      w2 = getVector[l2Dens[[2]]] /. {l2 -> 0};
      p2 = (w2 - w1) // Simplify;
      p1sqVal = simplifySp[LiteRed`sp[p1, p1]];
      p2sqVal = simplifySp[LiteRed`sp[p2, p2]];
      Print["  u1 = ", InputForm[u1], ", u2 = ", InputForm[u2], ", p1 = ", InputForm[p1], ", p1sqVal = ", InputForm[p1sqVal]];
      Print["  w1 = ", InputForm[w1], ", w2 = ", InputForm[w2], ", p2 = ", InputForm[p2], ", p2sqVal = ", InputForm[p2sqVal]];
    ];
    
    (* Connected 4-prop master *)
    If[activeCount == 4 && !A22DisconnectedBubbleMasterQ[activeDens],
      v1 = If[Length[l1Dens] >= 1, getVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
      v2 = If[Length[l2Dens] >= 1, getVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
      v3 = If[Length[mixedDens] >= 1, getVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
      Q = (v3 - v1 - v2) // Simplify;
      QsqVal = simplifySp[LiteRed`sp[Q, Q]];
      Print["  v1 = ", InputForm[v1], ", v2 = ", InputForm[v2], ", v3 = ", InputForm[v3]];
      Print["  Q = ", InputForm[Q], ", QsqVal = ", InputForm[QsqVal]];
    ];
    
    , {master, masters}
  ];
  , {i, 1}
];

Quit[];
