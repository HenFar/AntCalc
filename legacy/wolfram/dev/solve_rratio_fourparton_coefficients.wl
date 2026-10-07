Get["AntennaPipeline.wl"];

ClearAll[
  exactPatchedIngredients,
  fourPartonAnsatz,
  coefficientEquations,
  targetResidual
];

exactPatchedIngredients[ingredients_Association] :=
  Module[{patched, a31Targets, a22Targets},
    patched = Association[ingredients];
    a31Targets = A31IntegratedAntennaTargets[0];
    a22Targets = A22TTermTargets[0];
    patched["intA31"] = a31Targets[[1]];
    patched["intTildeA31"] = a31Targets[[2]];
    patched["intHatA31"] = a31Targets[[3]];
    patched["intA22"] = a22Targets[[1]];
    patched["intTildeA22"] = a22Targets[[2]];
    patched["intHatA22"] = a22Targets[[3]];
    patched["intBreveA22"] = a22Targets[[4]];
    patched
  ];

fourPartonAnsatz[ingredients_Association] :=
  Module[{alphaS, n, nf, a, at, b, c},
    alphaS = SMP["alpha_s"];
    n = SUNN;
    nf = Nf;
    (alphaS / (2 Pi))^2 (n - 1 / n) (
      a n ingredients["intA40"] +
      at (-1 / n) ingredients["intTildeA40"] +
      b nf ingredients["intB40"] +
      c (-1 / n) ingredients["intC40"]
    )
  ];

coefficientEquations[expr_] :=
  Module[{eps, poles, finiteResidual},
    eps = FeynCalc`Epsilon;
    poles = Table[Coefficient[expr, eps, power] == 0, {power, -4, -1}];
    finiteResidual =
      SafeIntegratedResidualSimplify[
        Coefficient[expr, eps, 0] - BuildRRatioSMQCDReferenceFiniteExpression[NNLO]
      ];
    Join[poles, {finiteResidual == 0}]
  ];

Module[
  {
    runtime,
    diagnostics,
    ingredients,
    patched,
    alphaS,
    n,
    nf,
    tqq2,
    exactTwoPartonThreeParton,
    ansatz,
    expr,
    eqs,
    sol
  },
  runtime =
    BuildRRatio[
      SMQCD,
      ResultForm -> "RawDimRegSeries",
      ReturnDiagnostics -> True,
      UseStoredResults -> False,
      StoreResults -> False,
      RefreshStoredResults -> False
    ];
  If[!MatchQ[runtime, {_, _Association}],
    Print["BuildRRatio did not return {result, diagnostics}."];
    Abort[]
  ];
  diagnostics = runtime[[2]];
  ingredients = Lookup[diagnostics, "Ingredients", Missing["NoIngredients"]];
  If[!AssociationQ[ingredients],
    Print["No ingredient association was available in diagnostics."];
    Abort[]
  ];

  patched = exactPatchedIngredients[ingredients];
  alphaS = SMP["alpha_s"];
  n = SUNN;
  nf = Nf;
  tqq2 = 4 n (1 - FeynCalc`Epsilon) q2;

  exactTwoPartonThreeParton =
    (alphaS / (2 Pi))^2 FullSimplify[
      (n - 1 / n) (
        n patched["intA22"] +
        1 / n patched["intTildeA22"] +
        nf patched["intHatA22"] +
        (n - 1 / n) patched["intBreveA22"] +
        n (patched["intA31"] + patched["intA21"] patched["intA30"]) -
        1 / n (patched["intTildeA31"] + patched["intA21"] patched["intA30"]) +
        nf patched["intHatA31"]
      )
    ];

  ansatz = fourPartonAnsatz[patched];
  expr =
    Collect[
      1 +
      (alphaS / (2 Pi)) FullSimplify[
        (n - 1 / n) (patched["intA21"] + patched["intA30"])
      ] +
      exactTwoPartonThreeParton +
      ansatz,
      alphaS,
      FullSimplify
    ];

  eqs = coefficientEquations[expr];
  sol = Quiet[Solve[eqs, {a, at, b, c}, Reals]];

  Print["Equations:"];
  Print[eqs];
  Print["Solutions for {a, at, b, c}:"];
  Print[sol];
];
