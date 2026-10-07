(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];

(* analyzeExactMaster: Script-local helper for this development or benchmarking utility. *)
analyzeExactMaster[basis_, master_] := Module[{indices, activeDenominators, activeCount, l1Dens, l2Dens, mixedDens,
        v1, v2, v3, Q, QsqVal, u1, u2, p1, w1, w2, p2, p1sqVal, p2sqVal},
  indices = List @@ master // Rest;
  activeDenominators = Pick[LiteRed`Ds[basis], indices, _?(# > 0&)];
  activeCount = Length[activeDenominators];
  
  l1Dens = Select[activeDenominators, MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2]&];
  l2Dens = Select[activeDenominators, MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1]&];
  mixedDens = Select[activeDenominators, MemberQ[Cases[#, l1, Infinity], l1] && MemberQ[Cases[#, l2, Infinity], l2]&];
  
  Print["Master: ", master];
  Print["  Active count: ", activeCount];
  
  If[activeCount == 3,
    v1 = If[Length[l1Dens] == 1, A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
    v2 = If[Length[l2Dens] == 1, A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
    v3 = If[Length[mixedDens] == 1, A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
    Q = (v3 - v1 - v2) // Simplify;
    QsqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[Q, Q]];
    Print["  Type: Sunset"];
    Print["  QsqVal: ", QsqVal];
  ];
  
  If[A22DisconnectedBubbleMasterQ[activeDenominators],
    u1 = A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0};
    u2 = A22TwoLoopTreeGetVector[l1Dens[[2]]] /. {l1 -> 0};
    p1 = (u2 - u1) // Simplify;
    w1 = A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0};
    w2 = A22TwoLoopTreeGetVector[l2Dens[[2]]] /. {l2 -> 0};
    p2 = (w2 - w1) // Simplify;
    p1sqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p1, p1]];
    p2sqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p2, p2]];
    Print["  Type: Disconnected Bubble"];
    Print["  p1sqVal: ", p1sqVal, ", p2sqVal: ", p2sqVal];
  ];
  
  If[activeCount == 4 && !A22DisconnectedBubbleMasterQ[activeDenominators],
    v1 = If[Length[l1Dens] >= 1, A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
    v2 = If[Length[l2Dens] >= 1, A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
    v3 = If[Length[mixedDens] >= 1, A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
    Q = (v3 - v1 - v2) // Simplify;
    QsqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[Q, Q]];
    Print["  Type: 4-prop master"];
    Print["  QsqVal: ", QsqVal];
  ];
  Print["---"];
];

Do[
  basis = basisLoad["Bases"][[i]];
  masters = LiteRed`MIs[basis];
  Print["\n=========================================="];
  Print["Basis: ", basis];
  Print["=========================================="];
  Do[
    analyzeExactMaster[basis, masters[[k]]];
    , {k, Length[masters]}
  ];
  , {i, Length[basisLoad["Bases"]]}
];

Quit[];
