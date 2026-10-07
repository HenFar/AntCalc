(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

componentString = Environment["A22_COMPONENT"];
component =
  If[StringQ[componentString] && StringLength[componentString] > 0,
    ToExpression[componentString],
    Leading
  ];

(* ClassName: Script-local helper for this development or benchmarking utility. *)
ClassName[master_, basis_] :=
  Module[{indices, activeDenominators, activeCount, l1Dens, l2Dens, mixedDens,
      v1, v2, v3, qSqVal, u1, u2, p1, w1, w2, p2, p1SqVal, p2SqVal},
    indices = List @@ master // Rest;
    activeDenominators = Pick[LiteRed`Ds[basis], indices, _?(# > 0 &)];
    activeCount = Length[activeDenominators];
    l1Dens = Select[activeDenominators,
      MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2] &];
    l2Dens = Select[activeDenominators,
      MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1] &];
    mixedDens = Select[activeDenominators,
      MemberQ[Cases[#, l1, Infinity], l1] &&
        MemberQ[Cases[#, l2, Infinity], l2] &];
    Which[
      activeCount == 3,
        v1 = If[Length[l1Dens] == 1,
          A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
        v2 = If[Length[l2Dens] == 1,
          A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
        v3 = If[Length[mixedDens] == 1,
          A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
        qSqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[v3 - v1 - v2, v3 - v1 - v2]];
        "A3:" <> ToString[InputForm[qSqVal]]
      ,
      A22DisconnectedBubbleMasterQ[activeDenominators],
        u1 = A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0};
        u2 = A22TwoLoopTreeGetVector[l1Dens[[2]]] /. {l1 -> 0};
        p1 = (u2 - u1) // Simplify;
        w1 = A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0};
        w2 = A22TwoLoopTreeGetVector[l2Dens[[2]]] /. {l2 -> 0};
        p2 = (w2 - w1) // Simplify;
        p1SqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p1, p1]];
        p2SqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p2, p2]];
        "A22LO:" <> ToString[InputForm[Sort[{p1SqVal, p2SqVal}]]]
      ,
      activeCount == 4,
        v1 = If[Length[l1Dens] >= 1,
          A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
        v2 = If[Length[l2Dens] >= 1,
          A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
        v3 = If[Length[mixedDens] >= 1,
          A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
        qSqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[v3 - v1 - v2, v3 - v1 - v2]];
        "A4:" <> ToString[InputForm[qSqVal]]
      ,
      True,
        "A6:" <> ToString[activeCount]
    ]
  ];

antenna = BuildAntenna[A, 2, 2,
  Contribution -> TwoLoopTree, Component -> component];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];
rawReduced = reduction["RawReducedTerms"];
records = reduction["TermRecords"];
coeffs = <||>;

Do[
  basis = records[[i, "Basis"]];
  term = rawReduced[[i]];
  mis = LiteRed`MIs[basis];
  Do[
    coeff = Coefficient[term, m];
    If[coeff =!= 0,
      class = ClassName[m, basis];
      coeffs[class] = Lookup[coeffs, class, 0] + coeff;
    ],
    {m, mis}
  ],
  {i, Length[rawReduced]}
];

Print["=== ", component, " ==="];
KeyValueMap[
  Print[#1, " -> ", InputForm[Together[#2]]] &,
  KeySort[coeffs]
];

Quit[];
