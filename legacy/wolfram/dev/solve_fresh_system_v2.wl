(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
order = 0;

(* A22TwoLoopTreeSymbolicMasterValue: Script-local helper for this development or benchmarking utility. *)
A22TwoLoopTreeSymbolicMasterValue[master_, basis_] :=
  Module[{indices, activeDenominators, activeCount, l1Dens, l2Dens, mixedDens,
          v1, v2, v3, Q, QsqVal, u1, u2, p1, w1, w2, p2, p1sqVal, p2sqVal},
    indices = List @@ master // Rest;
    activeDenominators = Pick[LiteRed`Ds[basis], indices, _?(# > 0&)];
    activeCount = Length[activeDenominators];
    
    l1Dens = Select[activeDenominators, MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2]&];
    l2Dens = Select[activeDenominators, MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1]&];
    mixedDens = Select[activeDenominators, MemberQ[Cases[#, l1, Infinity], l1] && MemberQ[Cases[#, l2, Infinity], l2]&];
    
    Which[
      activeCount == 3,
        v1 = If[Length[l1Dens] == 1, A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
        v2 = If[Length[l2Dens] == 1, A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
        v3 = If[Length[mixedDens] == 1, A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
        Q = (v3 - v1 - v2) // Simplify;
        QsqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[Q, Q]];
        If[QsqVal === 0,
          A3MI
          ,
          A3MI * (QsqVal / q2)^(1 - 2 eps)
        ]
      ,
      A22DisconnectedBubbleMasterQ[activeDenominators],
        u1 = A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0};
        u2 = A22TwoLoopTreeGetVector[l1Dens[[2]]] /. {l1 -> 0};
        p1 = (u2 - u1) // Simplify;
        w1 = A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0};
        w2 = A22TwoLoopTreeGetVector[l2Dens[[2]]] /. {l2 -> 0};
        p2 = (w2 - w1) // Simplify;
        p1sqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p1, p1]];
        p2sqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p2, p2]];
        If[p1sqVal === 0 || p2sqVal === 0,
          0
          ,
          A22LOMI * (p1sqVal * p2sqVal / q2^2)^(-eps)
        ]
      ,
      activeCount == 4,
        v1 = If[Length[l1Dens] >= 1, A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
        v2 = If[Length[l2Dens] >= 1, A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
        v3 = If[Length[mixedDens] >= 1, A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
        Q = (v3 - v1 - v2) // Simplify;
        QsqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[Q, Q]];
        If[QsqVal === 0,
          A4MI
          ,
          A4MI * (QsqVal / q2)^(-2 eps)
        ]
      ,
      activeCount >= 5,
        A6MI
      ,
      True,
        0
    ]
  ];

(* getSymbolicBareAmp: Script-local helper for this development or benchmarking utility. *)
getSymbolicBareAmp[component_] := Module[{antenna, profile, basisLoad, reduction, rawReduced, records, symbolicReduced, totalSymbolic, norm},
  antenna = BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, Component -> component];
  profile = IBPProfile["A22TwoLoopTree"];
  basisLoad = LoadIBPBases[profile];
  reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];
  
  rawReduced = reduction["RawReducedTerms"];
  records = reduction["TermRecords"];
  
  symbolicReduced = Table[
    rawReduced[[i]] /. Table[m -> A22TwoLoopTreeSymbolicMasterValue[m, records[[i, "Basis"]]], {m, LiteRed`MIs[records[[i, "Basis"]]]}]
    , {i, Length[rawReduced]}
  ];
  
  totalSymbolic = Total[symbolicReduced];
  norm = IBPNormalization[profile];
  totalSymbolic * norm // ReplaceAll[#, {d -> 4 - 2 eps, q2 -> 1}]& // Together // Simplify
];

(* Get fresh exact bare amplitudes *)
Print["Reducing Leading component..."];
bareL = getSymbolicBareAmp[Leading];
Print["Reducing Subleading component..."];
bareS = getSymbolicBareAmp[Subleading];

(* toSeries: Script-local helper for this development or benchmarking utility. *)
toSeries[expr_] :=
  Normal[Series[expr, {eps, 0, order}]] // FunctionExpand // FullSimplify;

cLA22LO = Normal[Series[Coefficient[bareL, A22LOMI], {eps, 0, order + 2}]] // FunctionExpand // FullSimplify;
cLA3    = Normal[Series[Coefficient[bareL, A3MI], {eps, 0, order + 1}]] // FunctionExpand // FullSimplify;
cLA4    = Coefficient[bareL, A4MI];
cLA6    = Coefficient[bareL, A6MI];

cSA22LO = Normal[Series[Coefficient[bareS, A22LOMI], {eps, 0, order + 2}]] // FunctionExpand // FullSimplify;
cSA3    = Normal[Series[Coefficient[bareS, A3MI], {eps, 0, order + 1}]] // FunctionExpand // FullSimplify;
cSA4    = Coefficient[bareS, A4MI];
cSA6    = Coefficient[bareS, A6MI];

(* Validated master values expanded up to order 3 *)
A4val = toSeries[A22TwoLoopTreeMasterValueA4[] /. {q2 -> 1}];
A6val = toSeries[A22TwoLoopTreeMasterValueA6[] /. {q2 -> 1}];

leadA4 = toSeries[cLA4 * A4val];
leadA6 = toSeries[cLA6 * A6val];
subA4  = toSeries[cSA4 * A4val];
subA6  = toSeries[cSA6 * A6val];

targetLead = toSeries[1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440)];
targetSub = toSeries[-1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288)];

(* Subtraction series for coupling renormalization *)
(* Leading gets -11/(6 eps) * A21, Subleading gets 0 *)
a21Val = IntegratedLowerAntenna[{A, 2, 1}, 2];
intA21 = Series[a21Val, {eps, 0, 2}] // Normal // FunctionExpand // FullSimplify;
subL = toSeries[-11/(6 eps) * intA21];

residL = toSeries[targetLead - subL - (leadA4 + leadA6)];
residS = toSeries[targetSub - (subA4 + subA6)];

(* Xexpr: Script-local helper for this development or benchmarking utility. *)
Xexpr[x2_, x1_, x0_, x1new_, x2new_] := x2/eps^2 + x1/eps + x0 + x1new * eps + x2new * eps^2;
(* Yexpr: Script-local helper for this development or benchmarking utility. *)
Yexpr[y1_, y0_, y1new_, y2new_, y3new_] := y1/eps + y0 + y1new * eps + y2new * eps^2 + y3new * eps^3;

vars = {x2, x1, x0, x1new, x2new, y1, y0, y1new, y2new, y3new};

productL = toSeries[cLA22LO * Xexpr[x2, x1, x0, x1new, x2new] + cLA3 * Yexpr[y1, y0, y1new, y2new, y3new]];
productS = toSeries[cSA22LO * Xexpr[x2, x1, x0, x1new, x2new] + cSA3 * Yexpr[y1, y0, y1new, y2new, y3new]];

eqsL = Table[Coefficient[productL, eps, n] == Coefficient[residL, eps, n], {n, -4, 0}];
eqsS = Table[Coefficient[productS, eps, n] == Coefficient[residS, eps, n], {n, -4, 0}];
allEqs = Join[eqsL, eqsS];

sol = Solve[allEqs, vars] // FullSimplify;

If[Length[sol] > 0,
  sol1 = First[sol];
  Print["Solution found:"];
  Print["  x2 (A22LO at 1/eps^2): ", x2 /. sol1 // FullSimplify // InputForm];
  Print["  x1 (A22LO at 1/eps^1): ", x1 /. sol1 // FullSimplify // InputForm];
  Print["  x0 (A22LO at eps^0):   ", x0 /. sol1 // FullSimplify // InputForm];
  Print["  x1new (A22LO at eps^1): ", x1new /. sol1 // FullSimplify // InputForm];
  Print["  x2new (A22LO at eps^2): ", x2new /. sol1 // FullSimplify // InputForm];
  Print["  y1 (A3   at 1/eps^1): ", y1 /. sol1 // FullSimplify // InputForm];
  Print["  y0 (A3   at eps^0):   ", y0 /. sol1 // FullSimplify // InputForm];
  Print["  y1new (A3   at eps^1): ", y1new /. sol1 // FullSimplify // InputForm];
  Print["  y2new (A3   at eps^2): ", y2new /. sol1 // FullSimplify // InputForm];
  Print["  y3new (A3   at eps^3): ", y3new /. sol1 // FullSimplify // InputForm];
  ,
  Print["NO SOLUTION found."];
];

Quit[];
