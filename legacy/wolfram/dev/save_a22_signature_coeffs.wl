(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

componentString = Environment["A22_COMPONENT"];
component =
  If[StringQ[componentString] && StringLength[componentString] > 0,
    ToExpression[componentString],
    Leading
  ];

(* CanonicalDenominatorString: Script-local helper for this development or benchmarking utility. *)
CanonicalDenominatorString[den_] :=
  ToString[InputForm[den // Expand // Simplify]];

(* SignatureKey: Script-local helper for this development or benchmarking utility. *)
SignatureKey[master_, basis_] :=
  Module[{indices, activeDenominators, activeCount, l1Dens, l2Dens, mixedDens,
      v1, v2, v3, qSqVal, u1, u2, p1, w1, w2, p2, p1SqVal, p2SqVal},
    indices = Rest[List @@ master];
    activeDenominators = Pick[LiteRed`Ds[basis], indices, _?(# > 0 &)];
    activeCount = Length[activeDenominators];
    l1Dens = Select[activeDenominators,
      MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2] &];
    l2Dens = Select[activeDenominators,
      MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1] &];
    mixedDens = Select[activeDenominators,
      MemberQ[Cases[#, l1, Infinity], l1] &&
        MemberQ[Cases[#, l2, Infinity], l2] &];
    qSqVal = Missing["NotApplicable"];
    p1SqVal = Missing["NotApplicable"];
    p2SqVal = Missing["NotApplicable"];

    If[activeCount == 3 || (activeCount == 4 &&
          !A22DisconnectedBubbleMasterQ[activeDenominators]),
      v1 = If[Length[l1Dens] >= 1,
        A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
      v2 = If[Length[l2Dens] >= 1,
        A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
      v3 = If[Length[mixedDens] >= 1,
        A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
      qSqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[v3 - v1 - v2, v3 - v1 - v2]];
    ];

    If[A22DisconnectedBubbleMasterQ[activeDenominators],
      u1 = A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0};
      u2 = A22TwoLoopTreeGetVector[l1Dens[[2]]] /. {l1 -> 0};
      p1 = (u2 - u1) // Simplify;
      w1 = A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0};
      w2 = A22TwoLoopTreeGetVector[l2Dens[[2]]] /. {l2 -> 0};
      p2 = (w2 - w1) // Simplify;
      p1SqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p1, p1]];
      p2SqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p2, p2]];
    ];

    <|
      "ActiveCount" -> activeCount,
      "DisconnectedBubbleQ" -> A22DisconnectedBubbleMasterQ[activeDenominators],
      "QSq" -> ToString[InputForm[qSqVal]],
      "P1Sq" -> ToString[InputForm[p1SqVal]],
      "P2Sq" -> ToString[InputForm[p2SqVal]],
      "ActiveDenominators" -> Sort[CanonicalDenominatorString /@ activeDenominators]
    |>
  ];

antenna = BuildAntenna[A, 2, 2,
  Contribution -> TwoLoopTree, Component -> component];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];

aggregated = <||>;
Do[
  basis = reduction["TermRecords"][[i, "Basis"]];
  term = reduction["RawReducedTerms"][[i]];
  masters = LiteRed`MIs[basis];
  Do[
    coeff = Together[Coefficient[term, master]];
    If[coeff =!= 0,
      key = SignatureKey[master, basis];
      If[!KeyExistsQ[aggregated, key],
        aggregated[key] = 0
      ];
      aggregated[key] = Together[aggregated[key] + coeff];
    ],
    {master, masters}
  ],
  {i, Length[reduction["RawReducedTerms"]]}
];

normAgg = AssociationMap[
  Together[(# * IBPNormalization[profile] /. {d -> 4 - 2 eps, q2 -> 1})] &,
  aggregated
];

outfile = FileNameJoin[{"/private/tmp",
  "a22_signature_coeffs_" <> ToString[component] <> ".mx"}];
Put[<|"Component" -> ToString[component], "Coefficients" -> aggregated,
    "NormalizedCoefficients" -> normAgg|>, outfile];
Print["saved: ", outfile];
Quit[];
