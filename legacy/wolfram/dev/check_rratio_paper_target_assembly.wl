(* Symbolic audit of the NNLO SMQCD R-ratio convention ledger.

   This script performs no antenna build or IBP reduction.  It checks that the
   encoded direct component targets, after the observable-only convention map,
   reproduce a pole-free NNLO R-ratio and the known finite coefficient.  It
   also prints the two literal-source discrepancies that motivated the map. *)

Get["AntennaPipeline.wl"];

ClearAll[paperFourPartonIngredients, reportClosure, task10bIngredients,
  task10bAssembly, task10bA22, task10bA31, task10bLiteralA31Nf,
  task10bLedger];

paperFourPartonIngredients[order_Integer] :=
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
      "intA40" -> IntegratedAntennaSeries[leading, order],
      (* The public tilde A40 convention leaves the colour sign external. *)
      "intTildeA40" -> IntegratedAntennaSeries[-2 paperSubleading, order],
      "intB40" -> IntegratedAntennaSeries[b, order],
      (* The public C40 component is minus one half of this paper bracket. *)
      "intC40" -> IntegratedAntennaSeries[-paperC/2, order]
    |>
  ];

reportClosure[label_String, expression_] :=
  Module[{poles, finiteResidual},
    poles = Association @ Table[
      power -> SafeIntegratedResidualSimplify[
        RRatioPoleCoefficientAssociation[expression][power]
      ],
      {power, -4, -1}
    ];
    finiteResidual = SafeIntegratedResidualSimplify[
      RRatioFiniteCoefficient[expression] -
        BuildRRatioSMQCDReferenceFiniteExpression[NNLO]
    ];
    Print[label, " pole coefficients:"];
    Print[poles];
    Print[label, " finite residual:"];
    Print[finiteResidual];
  ];

Module[{eps},
  eps = FeynCalc`Epsilon;
  task10bA22 = A22TTermTargets[0];
  task10bA31 = A31IntegratedAntennaTargets[0];
  task10bLiteralA31Nf = task10bA31[[3]] + 47/(6 eps);
  task10bIngredients = Join[
    <|
      "intA21" -> IntegratedA21SubtractionSeries[2],
      "intA30" -> IntegratedA30SubtractionSeries[2],
      "intA31" -> task10bA31[[1]],
      "intTildeA31" -> task10bA31[[2]],
      "intHatA31" -> task10bA31[[3]],
      "intA22" -> task10bA22[[1]],
      "intTildeA22" -> task10bA22[[2]],
      "intHatA22" -> task10bA22[[3]],
      "intBreveA22" -> task10bA22[[4]]
    |>,
    paperFourPartonIngredients[0]
  ];
  task10bLedger = SMQCDRRatioObservableConventionLedger[];
  task10bAssembly = AssembleSMQCDRRatio[task10bIngredients];

  Print["NNLO observable convention ledger:"];
  Print[task10bLedger];
  Print["Literal A31 Nf source term minus closure reference:"];
  Print[SafeIntegratedResidualSimplify[
    task10bLiteralA31Nf - task10bA31[[3]]
  ]];
  Print["Direct A22 breve term minus observable-normalized breve term:"];
  Print[SafeIntegratedResidualSimplify[
    -task10bLedger["A22OneLoopSelfPoleShift"]
  ]];
  reportClosure["Closure-normalized paper-target assembly",
    task10bAssembly["FinalExpression"]];
];
