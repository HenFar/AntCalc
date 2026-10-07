IntegrateViaPaVe::usage =
  "IntegrateViaPaVe[antenna, profile, expandPaVeQ, applyFeynCalcQ, quarkMass, ...] runs the PaVe/Package-X integration route.";

EvaluatePaVeAntenna::usage =
  "EvaluatePaVeAntenna[antenna, profile, applyFeynCalcMS, ...] evaluates a PaVe antenna with the selected PaVe backend.";

NormalizePaXEvaluateResult::usage =
  "NormalizePaXEvaluateResult[paXResult, profile, applyFeynCalcMS, ...] converts a raw Package-X result into the package or paper convention.";

NormalizeMasslessTwoPartonPaXResult::usage =
  "NormalizeMasslessTwoPartonPaXResult[paXResult, epsilon, scale, scaleMu, applyFeynCalcMS, ...] applies the special normalization used by the massless two-parton paper route.";

MasslessTwoPartonPaXPaperConversionFactor::usage =
  "MasslessTwoPartonPaXPaperConversionFactor[epsilon, order] returns the Package-X-to-paper conversion factor used for the A21 route.";

Options[IntegrateViaPaVe] = {PaVeEvaluation -> "PaXEvaluate",
   ExpansionOrder -> 2, KinematicScale -> q2, NormalizeKinematicScale ->
    True, LoopMomentum -> l, ApplyDimReg -> True};

IntegrateViaPaVe[antenna_, profile_Association, ExpandPaVeFunction_,
   ApplyFeynCalc_, quarkMass_, OptionsPattern[]] :=
  Module[{paVeAntenna, evaluatedAntenna, output},
    paVeAntenna =
      If[FreeQ[antenna, _FeynAmpDenominator | _PropagatorDenominator],
        antenna
        ,
        TID[antenna, OptionValue["LoopMomentum"], ToPaVe -> True]
      ];
    evaluatedAntenna =
      If[ExpandPaVeFunction === True,
        EvaluatePaVeAntenna[paVeAntenna, profile, ApplyFeynCalc,
          PaVeEvaluation -> OptionValue["PaVeEvaluation"], ExpansionOrder ->
           OptionValue["ExpansionOrder"], KinematicScale -> OptionValue[
           "KinematicScale"], NormalizeKinematicScale -> OptionValue[
           "NormalizeKinematicScale"], ApplyDimReg -> OptionValue[
           "ApplyDimReg"]]
        ,
        paVeAntenna
      ];
    output = evaluatedAntenna // Simplify;
    output
  ];

Options[EvaluatePaVeAntenna] = {PaVeEvaluation -> "PaXEvaluate",
   ExpansionOrder -> 2, KinematicScale -> q2, NormalizeKinematicScale ->
    True, ApplyDimReg -> True};

EvaluatePaVeAntenna[antenna_, profile_Association, applyFeynCalcMS_,
   OptionsPattern[]] :=
  Module[{evaluation, expansionOrder, kinematicScale, paXResult, output},
    evaluation = OptionValue["PaVeEvaluation"];
    expansionOrder = OptionValue["ExpansionOrder"];
    kinematicScale = OptionValue["KinematicScale"];
    output =
      Switch[evaluation,
        "PaXEvaluate",
          paXResult = FeynCalc`PaXEvaluate[antenna];
          NormalizePaXEvaluateResult[paXResult, profile, applyFeynCalcMS,
            ExpansionOrder -> expansionOrder, KinematicScale ->
             kinematicScale, NormalizeKinematicScale -> OptionValue[
             "NormalizeKinematicScale"]]
        ,
        None,
          antenna
        ,
        _,
          Print["Unsupported PaVe evaluation mode: ", evaluation,
            ". Aborting..."];
          $Failed
      ];
    output
  ];

Options[NormalizePaXEvaluateResult] = {ExpansionOrder -> 2,
   KinematicScale -> q2, NormalizeKinematicScale -> True};

NormalizePaXEvaluateResult[paXResult_, profile_Association, applyFeynCalcMS_,
   OptionsPattern[]] :=
  Module[{convention, epsilon, scale, scaleMu, output},
    convention = Lookup[profile, "PaXConvention", "PackageX"];
    epsilon = Epsilon;
    scale = OptionValue["KinematicScale"];
    scaleMu = FeynCalc`ScaleMu;
    output =
      Switch[convention,
        "PackageX",
          paXResult
        ,
        "PaperRealMasslessTwoParton",
          NormalizeMasslessTwoPartonPaXResult[paXResult, epsilon, scale,
            scaleMu, applyFeynCalcMS, ExpansionOrder -> OptionValue[
             "ExpansionOrder"], NormalizeKinematicScale -> OptionValue[
             "NormalizeKinematicScale"]]
        ,
        _,
          Print["Unsupported Package-X convention: ", convention,
            ". Aborting..."];
          $Failed
      ];
    output
  ];

Options[NormalizeMasslessTwoPartonPaXResult] = {ExpansionOrder -> 2,
   NormalizeKinematicScale -> True};

NormalizeMasslessTwoPartonPaXResult[paXResult_, epsilon_, scale_, scaleMu_,
   applyFeynCalcMS_, OptionsPattern[]] :=
  Module[{branchRules, scaledResult, conversionFactor, expandedResult,
     output},
    branchRules = {
      Log[-(scaleMu^2 / scale)] -> EulerGamma + Log[Pi]
      ,
      Log[-(scaleMu^2 / (Pi scale))] -> EulerGamma
    };
    scaledResult = paXResult /. branchRules;
    If[OptionValue["NormalizeKinematicScale"] === True,
      scaledResult = scaledResult /. scale -> 1
    ];
    conversionFactor =
      If[applyFeynCalcMS === True,
        MasslessTwoPartonPaXPaperConversionFactor[epsilon,
          OptionValue["ExpansionOrder"]]
        ,
        1
      ];
    expandedResult =
      Normal[Series[conversionFactor scaledResult, {epsilon, 0,
         OptionValue["ExpansionOrder"]}]];
    output = expandedResult // FunctionExpand // FullSimplify;
    output
  ];

MasslessTwoPartonPaXPaperConversionFactor[epsilon_, order_Integer] :=
  Module[{factor},
    factor =
      1 - Pi^2 / 2 epsilon^2
        + (8 - Pi^2 / 8 - 7 Zeta[3] / 3) epsilon^3
        + (4 - 7 Pi^2 / 48 + 13 Pi^4 / 1440) epsilon^4;
    Normal[Series[factor, {epsilon, 0, order + 2}]]
  ];
