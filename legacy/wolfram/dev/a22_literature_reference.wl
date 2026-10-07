(*
  Independent external reference for the massless A22 release contract.

  This file intentionally does not call A22TTermTargets or any route
  diagnostics.  It is a transcription of hep-ph/0403057v2, Eqs. (4.8)--(4.10),
  into the package's documented paper-facing component convention.  The
  release worker compares freshly recomputed route output to these expressions.
*)

ClearAll[A22LiteratureReferenceMetadata, A22LiteratureReferenceTargets,
  A22LiteratureReferenceTarget, A22LiteratureReferenceResiduals,
  A22LiteratureReferenceAgreementQ];

A22LiteratureReferenceMetadata[] := <|
  "Source" -> "arXiv:hep-ph/0403057v2",
  "Title" -> "Infrared Structure of e+ e- -> 2 jets at NNLO",
  "Equations" -> <|
    "TwoLoopTreeDefinition" -> "(4.8)",
    "TwoLoopTreeColourBrackets" -> "(4.9)",
    "OneLoopSelfInterference" -> "(4.10)",
    "TwoLoopLoopNormalization" -> "(A.1)"
    |>,
  "Renormalization" -> "MSbar; mu^2 = q^2 as stated below Eq. (4.12)",
  "PackageConvention" ->
    "The public A22 slots are the paper-facing colour brackets: Leading, " <>
    "Subleading and Nf are the N, 1/N and Nf brackets in Eq. (4.9), and " <>
    "Breve is Eq. (4.10).  The common (N - 1/N) Tqqbar^(2) prefactor in " <>
    "the paper is not part of an individual public slot."
  |>;

A22LiteratureReferenceTargets[order_Integer] := Module[{eps, targets},
  eps = FeynCalc`Epsilon;
  targets = {
    1/(4 eps^4) + 17/(8 eps^3) +
      (433/144 - Pi^2/2)/eps^2 +
      (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
      (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440),
    -1/(4 eps^4) - 3/(4 eps^3) +
      (-41/16 + 13 Pi^2/24)/eps^2 +
      (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
      (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288),
    -1/(4 eps^3) - 1/(9 eps^2) +
      (65/216 + Pi^2/24)/eps +
      (4085/1296 - 91 Pi^2/216 + Zeta[3]/18),
    1/(4 eps^4) + 3/(4 eps^3) +
      (41/16 - Pi^2/24)/eps^2 +
      (7 - Pi^2/8 + 7 Zeta[3]/6)/eps +
      (18 - 41 Pi^2/96 - 7 Zeta[3]/2 - 7 Pi^4/480)
    };
  Normal[Series[#, {eps, 0, order}]]& /@ targets
  ];

A22LiteratureReferenceTarget[component_, order_Integer] := Module[{position},
  position = FirstPosition[
    CanonicalAntennaComponentName /@ {Leading, Subleading, Nf, Breve},
    CanonicalAntennaComponentName[component], Missing["UnknownComponent"]
    ];
  If[position === Missing["UnknownComponent"],
    Missing["UnknownA22Component", component],
    A22LiteratureReferenceTargets[order][[position[[1]]]]
    ]
  ];

A22LiteratureReferenceResiduals[result_List, order_Integer] :=
  MapThread[FullSimplify[FunctionExpand[#1 - #2]]&, {
    result, A22LiteratureReferenceTargets[order]}];

A22LiteratureReferenceResiduals[result_, component_, order_Integer] :=
  Module[{target = A22LiteratureReferenceTarget[component, order]},
    If[MissingQ[target], target, FullSimplify[FunctionExpand[result - target]]]
    ];

A22LiteratureReferenceAgreementQ[result_List, order_Integer] :=
  And @@ (TrueQ[# === 0]& /@ A22LiteratureReferenceResiduals[result, order]);

A22LiteratureReferenceAgreementQ[result_, component_, order_Integer] :=
  TrueQ[A22LiteratureReferenceResiduals[result, component, order] === 0];
