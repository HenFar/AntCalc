(* Build-side convention audit for A31.  This avoids LiteRed and inspects the
   public/prototype component payloads that later enter the IBP reduction. *)

Get["AntennaPipeline.wl"];

ClearAll[task10bBuildSeries, task10bBuildChecks];

task10bBuildSeries[expr_] :=
  Module[{regulator},
    regulator = FeynCalc`Epsilon;
    Normal[Series[
      expr /. {eps -> regulator, Epsilon -> regulator},
      {regulator, 0, 0}
    ]] // FullSimplify
  ];

task10bBuildChecks[components_Association] :=
  Association @ KeyValueMap[
    #1 -> Module[{series},
      series = task10bBuildSeries[#2];
      <|
        "DirectEulerGammaFreeQ" -> FreeQ[#2, EulerGamma],
        "SeriesEulerGammaFreeQ" -> FreeQ[series, EulerGamma],
        "InputLeafCount" -> LeafCount[#2],
        "SeriesLeafCount" -> LeafCount[series]
      |>
    ]&,
    components
  ];

Module[{presentationData, integrableData, presentationBoundary,
   integrableBoundary, presentationPublic, presentationPrototype,
   integrableRouteNative, integrablePublic, integrablePrototype},
  presentationData = BuildAntenna[
    A, 3, 1, ReturnRecord -> True, IntegrableForm -> False,
    UseStoredResults -> False, StoreResults -> False,
    RefreshStoredResults -> False
  ]["BuildData"];
  integrableData = BuildAntenna[
    A, 3, 1, ReturnRecord -> True, IntegrableForm -> True,
    UseStoredResults -> False, StoreResults -> False,
    RefreshStoredResults -> False
  ]["BuildData"];
  presentationBoundary = Lookup[presentationData, "BuildOutputBoundary", <||>];
  integrableBoundary = Lookup[integrableData, "BuildOutputBoundary", <||>];
  presentationPublic = Lookup[Lookup[presentationBoundary, "Public", <||>],
    "Components", <||>];
  presentationPrototype = Lookup[Lookup[presentationBoundary, "Prototype", <||>],
    "Components", <||>];
  integrableRouteNative = Lookup[integrableData, "Components", <||>];
  integrablePublic = Lookup[Lookup[integrableBoundary, "Public", <||>],
    "Components", <||>];
  integrablePrototype = Lookup[Lookup[integrableBoundary, "Prototype", <||>],
    "Components", <||>];
  Print["A31 presentation public components:"];
  Print[task10bBuildChecks[presentationPublic]];
  Print["A31 presentation prototype components:"];
  Print[task10bBuildChecks[presentationPrototype]];
  Print["A31 integrable route-native components:"];
  Print[task10bBuildChecks[integrableRouteNative]];
  Print["A31 integrable public components:"];
  Print[task10bBuildChecks[integrablePublic]];
  Print["A31 integrable prototype components:"];
  Print[task10bBuildChecks[integrablePrototype]];
];
