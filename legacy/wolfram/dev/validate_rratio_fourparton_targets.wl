(* Direct four-parton comparison for the R-ratio assembly.
   Targets are transcribed from hep-ph/0403057, Eqs. (4.49), (4.51),
   and (4.53), in the component signs consumed by AssembleSMQCDRRatio. *)

Get["AntennaPipeline.wl"];

ClearAll[paperFourPartonTargets, reportResidual];

paperFourPartonTargets[order_Integer] :=
  Module[{eps, leading, paperSubleading, b, paperC},
    eps = FeynCalc`Epsilon;
    leading =
      3/(4 eps^4) + 65/(24 eps^3) +
      (217/18 - 13 Pi^2/12)/eps^2 +
      (43223/864 - 589 Pi^2/144 - 71 Zeta[3]/4)/eps +
      1076717/5184 - 7955 Pi^2/432 - 1327 Zeta[3]/18 +
      373 Pi^4/1440;
    paperSubleading =
      -1/(2 eps^4) - 3/(2 eps^3) +
      (-13/2 + 3 Pi^2/4)/eps^2 +
      (-845/32 + 9 Pi^2/4 + 40 Zeta[3]/3)/eps +
      (-6921/64 + 473 Pi^2/48 + 40 Zeta[3] - 17 Pi^4/144);
    b =
      -1/(12 eps^3) - 7/(18 eps^2) +
      (-407/216 + 11 Pi^2/72)/eps +
      (-11753/1296 + 77 Pi^2/108 + 67 Zeta[3]/18);
    paperC =
      (13/16 - Pi^2/8 + Zeta[3]/2)/eps +
      (339/32 - 17 Pi^2/24 - 21 Zeta[3]/4 + 2 Pi^4/45);
    <|
      "A40Leading" -> IntegratedAntennaSeries[leading, order],
      (* Public tilde A40 has no colour sign absorbed. *)
      "A40Subleading" -> IntegratedAntennaSeries[paperSubleading, order],
      "B40" -> IntegratedAntennaSeries[b, order],
      (* The driver applies -C40/N to reproduce the paper's + bracket/N. *)
      "C40" -> IntegratedAntennaSeries[-paperC, order]
    |>
  ];

reportResidual[label_String, observed_, target_] :=
  Module[{difference},
    difference = SafeIntegratedResidualSimplify[observed - target];
    Print[label, " residual against the paper-convention target:"];
    Print[difference];
  ];

Module[{order = 0, targets, a40Leading, a40Subleading, b40, c40},
  targets = paperFourPartonTargets[order];
  a40Leading = BuildAndIntegrateAntenna[
    A, 4, 0, Component -> Leading, ExpansionOrder -> order,
    UseStoredResults -> False, StoreResults -> False,
    RefreshStoredResults -> False
  ];
  a40Subleading = BuildAndIntegrateAntenna[
    A, 4, 0, Component -> Subleading, ExpansionOrder -> order,
    UseStoredResults -> False, StoreResults -> False,
    RefreshStoredResults -> False
  ];
  b40 = BuildAndIntegrateAntenna[
    B, 4, 0, ExpansionOrder -> order,
    UseStoredResults -> False, StoreResults -> False,
    RefreshStoredResults -> False
  ];
  c40 = BuildAndIntegrateAntenna[
    C, 4, 0, ExpansionOrder -> order,
    UseStoredResults -> False, StoreResults -> False,
    RefreshStoredResults -> False
  ];

  reportResidual["A40 leading", a40Leading, targets["A40Leading"]];
  reportResidual["A40 subleading", a40Subleading,
    targets["A40Subleading"]];
  reportResidual["B40", b40, targets["B40"]];
  reportResidual["C40", c40, targets["C40"]];
];
