(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

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

(* runFreshCheck: Script-local helper for this development or benchmarking utility. *)
runFreshCheck[component_] := Module[{antenna, profile, basisLoad, reduction, rawReduced, records, symbolicReduced, totalSymbolic, norm, normalized},
  Print["\n================ FRESH CHECK FOR: ", component, " ================"];
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
  normalized = totalSymbolic * norm // ReplaceAll[#, {d -> 4 - 2 eps, q2 -> 1}]& // Together // Simplify;
  
  Print["Coefficients in normalized bare amplitude:"];
  Print["  A22LOMI: ", Coefficient[normalized, A22LOMI] // FullSimplify];
  Print["  A3MI:    ", Coefficient[normalized, A3MI] // FullSimplify];
  Print["  A4MI:    ", Coefficient[normalized, A4MI] // FullSimplify];
  Print["  A6MI:    ", Coefficient[normalized, A6MI] // FullSimplify];
];

runFreshCheck[Leading];
runFreshCheck[Subleading];
runFreshCheck[Nf];

Quit[];
