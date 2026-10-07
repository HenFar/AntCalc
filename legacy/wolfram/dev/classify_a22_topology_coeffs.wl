(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

(* A22TopologyClassSymbol: Script-local helper for this development or benchmarking utility. *)
A22TopologyClassSymbol[master_, basis_] :=
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
        Switch[qSqVal,
          0, A3Q0,
          q2, A3Q1,
          2 q2, A3Q2,
          -q2, A3QM1,
          _, Symbol["A3Other$" <> StringReplace[ToString[InputForm[qSqVal]], {" " -> "", "*" -> "x", "-" -> "m"}]]
        ]
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
        Which[
          Sort[{p1SqVal, p2SqVal}] === Sort[{q2, q2}], A22LOQQ,
          Sort[{p1SqVal, p2SqVal}] === Sort[{2 q2, q2}], A22LO2QQ,
          Sort[{p1SqVal, p2SqVal}] === Sort[{q2, -q2}], A22LOQmQ,
          True,
            Symbol["A22LOOther$" <> StringReplace[
              ToString[InputForm[Sort[{p1SqVal, p2SqVal}]]], {" " -> "", "*" -> "x", "-" -> "m", "{" -> "", "}" -> "", "," -> "$"}]]
        ]
      ,
      activeCount == 4,
        v1 = If[Length[l1Dens] >= 1,
          A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
        v2 = If[Length[l2Dens] >= 1,
          A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
        v3 = If[Length[mixedDens] >= 1,
          A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
        qSqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[v3 - v1 - v2, v3 - v1 - v2]];
        Switch[qSqVal,
          0, A4Q0,
          q2, A4Q1,
          2 q2, A4Q2,
          4 q2, A4Q4,
          6 q2, A4Q6,
          -q2, A4QM1,
          _, Symbol["A4Other$" <> StringReplace[ToString[InputForm[qSqVal]], {" " -> "", "*" -> "x", "-" -> "m"}]]
        ]
      ,
      activeCount == 5,
        A6N5
      ,
      activeCount == 6,
        A6N6
      ,
      activeCount == 7,
        A6N7
      ,
      True,
        AUnknown
    ]
  ];

(* ClassifiedBareAmplitude: Script-local helper for this development or benchmarking utility. *)
ClassifiedBareAmplitude[component_] :=
  Module[{antenna, profile, basisLoad, reduction, rawReduced, records,
      classifiedReduced, totalClassified, norm},
    antenna = BuildAntenna[A, 2, 2,
      Contribution -> TwoLoopTree, Component -> component];
    profile = IBPProfile["A22TwoLoopTree"];
    basisLoad = LoadIBPBases[profile];
    reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];
    rawReduced = reduction["RawReducedTerms"];
    records = reduction["TermRecords"];
    classifiedReduced = Table[
      rawReduced[[i]] /. Table[
        m -> A22TopologyClassSymbol[m, records[[i, "Basis"]]],
        {m, LiteRed`MIs[records[[i, "Basis"]]]}
      ],
      {i, Length[rawReduced]}
    ];
    totalClassified = Total[classifiedReduced];
    norm = IBPNormalization[profile];
    totalClassified * norm /. {d -> 4 - 2 eps, q2 -> 1} //
      Together // Simplify
  ];

(* PrintComponent: Script-local helper for this development or benchmarking utility. *)
PrintComponent[component_] :=
  Module[{expr, symbols},
    Print[""];
    Print["=== ", component, " ==="];
    expr = ClassifiedBareAmplitude[component];
    symbols = DeleteDuplicates @ Cases[
      expr,
      A3Q0 | A3Q1 | A3Q2 | A3QM1 |
        A22LOQQ | A22LO2QQ | A22LOQmQ |
        A4Q0 | A4Q1 | A4Q2 | A4Q4 | A4Q6 | A4QM1 |
        A6N5 | A6N6 | A6N7 | _Symbol ? (StringStartsQ[SymbolName[#], "A"] &),
      Infinity
    ];
    Do[
      If[!NumericQ[Coefficient[expr, sym]] && Coefficient[expr, sym] =!= 0,
        Print[sym, ": ", InputForm[Together[Coefficient[expr, sym]]]]
      ],
      {sym, symbols}
    ];
  ];

PrintComponent[Leading];
PrintComponent[Subleading];
PrintComponent[Nf];

Quit[];
