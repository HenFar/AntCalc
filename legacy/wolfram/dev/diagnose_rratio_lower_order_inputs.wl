(* Compare the lower-order public routes with the subtraction series used
   internally when reconstructing the A31 paper brackets. *)

Get["AntennaPipeline.wl"];

ClearAll[seriesToFiniteOrder, residual];

seriesToFiniteOrder[expr_, order_Integer] :=
  IntegratedAntennaSeries[expr, order];

residual[observed_, expected_, order_Integer] :=
  SafeIntegratedResidualSimplify[
    seriesToFiniteOrder[observed - expected, order]
  ];

Module[
  {
    a21,
    a30,
    canonicalA21,
    canonicalA30,
    productOrder = 0,
    a21Order = 2,
    a30Order = 2
  },
  a21 = BuildAndIntegrateAntenna[
    A, 2, 1,
    ExpansionOrder -> a21Order,
    UseStoredResults -> False,
    StoreResults -> False,
    RefreshStoredResults -> False
  ];
  a30 = BuildAndIntegrateAntenna[
    A, 3, 0,
    ExpansionOrder -> a30Order,
    UseStoredResults -> False,
    StoreResults -> False,
    RefreshStoredResults -> False
  ];

  canonicalA21 = IntegratedA21SubtractionSeries[a21Order];
  canonicalA30 = IntegratedA30SubtractionSeries[a30Order];

  Print["A21 public-route residual against A31 subtraction input:"];
  Print[residual[a21, canonicalA21, a21Order]];
  Print["A30 public-route residual against A31 subtraction input:"];
  Print[residual[a30, canonicalA30, a30Order]];
  Print["A21*A30 product residual through epsilon^0:"];
  Print[residual[a21 a30, canonicalA21 canonicalA30, productOrder]];
];
