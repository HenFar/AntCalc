(*
  Independent external reference for the massless A31 release contract.

  This file intentionally does not call A31IntegratedAntennaTargets or route
  diagnostics. It transcribes arXiv:hep-ph/0505111v3, Eqs. (5.18)--(5.20),
  into the package's public integrated convention at s123 = 1.
*)

ClearAll[A31LiteratureReferenceMetadata, A31LiteratureReferenceTargets,
  A31LiteratureReferenceTarget, A31LiteratureReferenceResiduals,
  A31LiteratureReferenceAgreementQ];

A31LiteratureReferenceMetadata[] := <|
  "Source" -> "arXiv:hep-ph/0505111v3",
  "Title" -> "Antenna Subtraction at NNLO",
  "Equations" -> <|
    "IntegratedAntennaDefinition" -> "(2.35)",
    "Leading" -> "(5.18)",
    "Subleading" -> "(5.19)",
    "Nf" -> "(5.20)"
    |>,
  "PackageConvention" ->
    "The public slots {Leading, Subleading, Nf} are respectively the final " <>
    "integrated A3^1, tilde A3^1 and hat A3^1 expressions. The paper's " <>
    "common (s123)^(-2 epsilon) factor is one because the public integration " <>
    "surface normalizes the kinematic scale to s123 = 1. Route-local T terms " <>
    "are intermediate bookkeeping objects and are not compared to the paper."
  |>;

A31LiteratureReferenceTargets[order_Integer] := Module[{eps, targets},
  eps = FeynCalc`Epsilon;
  targets = {
    -1/(4 eps^4) - 31/(12 eps^3) +
      (-53/8 + 11 Pi^2/24)/eps^2 +
      (-647/24 + 22 Pi^2/9 + 23 Zeta[3]/3)/eps +
      (-5231/48 + 17 Pi^2/2 + 689 Zeta[3]/18 - 41 Pi^4/480),
    (-5/8 + Pi^2/6)/eps^2 +
      (-19/4 + Pi^2/4 + 7 Zeta[3])/eps +
      (-105/4 + 27 Pi^2/16 + 27 Zeta[3]/2 + 7 Pi^4/90),
    1/(3 eps^3) + 1/(2 eps^2) +
      (19/12 - 7 Pi^2/36)/eps +
      (109/24 - 7 Pi^2/24 - 25 Zeta[3]/9)
    };
  Normal[Series[#, {eps, 0, order}]]& /@ targets
  ];

A31LiteratureReferenceTarget[component_, order_Integer] := Module[{position},
  position = FirstPosition[
    CanonicalAntennaComponentName /@ {Leading, Subleading, Nf},
    CanonicalAntennaComponentName[component], Missing["UnknownComponent"]
    ];
  If[position === Missing["UnknownComponent"],
    Missing["UnknownA31Component", component],
    A31LiteratureReferenceTargets[order][[position[[1]]]]
    ]
  ];

A31LiteratureReferenceResiduals[result_List, order_Integer] :=
  MapThread[FullSimplify[FunctionExpand[#1 - #2]]&, {
    result, A31LiteratureReferenceTargets[order]}];

A31LiteratureReferenceResiduals[result_, component_, order_Integer] :=
  Module[{target = A31LiteratureReferenceTarget[component, order]},
    If[MissingQ[target], target, FullSimplify[FunctionExpand[result - target]]]
    ];

A31LiteratureReferenceAgreementQ[result_List, order_Integer] :=
  And @@ (TrueQ[# === 0]& /@ A31LiteratureReferenceResiduals[result, order]);

A31LiteratureReferenceAgreementQ[result_, component_, order_Integer] :=
  TrueQ[A31LiteratureReferenceResiduals[result, component, order] === 0];
