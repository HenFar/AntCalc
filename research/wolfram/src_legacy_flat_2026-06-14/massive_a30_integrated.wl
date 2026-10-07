MassiveA30IntegratedSource::usage =
  "MassiveA30IntegratedSource[] returns provenance metadata for the bibliography-facing integrated massive A30 result.";

MassiveA30IntegratedPaperR0::usage =
  "MassiveA30IntegratedPaperR0[] returns the paper threshold variable r0 = 1 - 4 mQ^2/Ecm2 used in the integrated massive A30 literature formula.";

MassiveA30IntegratedPaperMasterI1::usage =
  "MassiveA30IntegratedPaperMasterI1[] returns the paper master I1^(m,0,m) in paper convention.";

MassiveA30IntegratedPaperMasterI2::usage =
  "MassiveA30IntegratedPaperMasterI2[] returns the paper master I2^(m,0,m) in paper convention.";

MassiveA30IntegratedPaperConvention::usage =
  "MassiveA30IntegratedPaperConvention[] returns the encoded bibliography-facing integrated massive A30 expression in paper convention.";

MassiveA30IntegratedInvariantBridgeRules::usage =
  "MassiveA30IntegratedInvariantBridgeRules[] returns the explicit paper-to-package invariant bridge for the integrated massive A30 provenance layer.";

MassiveA30IntegratedNormalizationBridge::usage =
  "MassiveA30IntegratedNormalizationBridge[] returns the explicit convention bridge data used to convert the paper integrated result into the package-facing candidate.";

MassiveA30IntegratedApplyPackageBridge::usage =
  "MassiveA30IntegratedApplyPackageBridge[expr] applies the explicit paper-to-package bridge used for the integrated massive A30 provenance layer.";

MassiveA30IntegratedPackageMasterI1Candidate::usage =
  "MassiveA30IntegratedPackageMasterI1Candidate[] returns the package-facing candidate for the undotted paper master after the explicit bridge.";

MassiveA30IntegratedPackageMasterI2PaperCandidate::usage =
  "MassiveA30IntegratedPackageMasterI2PaperCandidate[] returns the bridged paper numerator master before any runtime-basis conversion.";

MassiveA30IntegratedPackageConventionCandidate::usage =
  "MassiveA30IntegratedPackageConventionCandidate[] returns the package-facing integrated massive A30 candidate derived from the paper convention through the explicit bridge.";

MassiveA30IntegratedRuntimeClosedExpression::usage =
  "MassiveA30IntegratedRuntimeClosedExpression[qm] returns the package-facing integrated massive A30 closed expression with the runtime heavy-mass symbol inserted explicitly.";

MassiveA30IntegratedRuntimeSeries::usage =
  "MassiveA30IntegratedRuntimeSeries[qm, order, normalizeScale] returns the epsilon-series form used by the public massive A30 integration route.";

MassiveA30IntegratedRuntimeMasterCoefficientAssociation::usage =
  "MassiveA30IntegratedRuntimeMasterCoefficientAssociation[] extracts the actual current package master-combination coefficients for the massive A30 IBP route.";

MassiveA30IntegratedRuntimeMasterI2Candidate::usage =
  "MassiveA30IntegratedRuntimeMasterI2Candidate[] returns the provisional package-basis value for j[MX30Basis123,2,1,1,0,0] obtained by matching the actual runtime master combination to the bridged literature target after identifying the undotted master with the paper I1 master.";

MassiveA30IntegratedRuntimeMasterRules::usage =
  "MassiveA30IntegratedRuntimeMasterRules[] returns the current development-only substitution rules from the package MX30 masters to closed-form candidates.";

MassiveA30IntegratedRuntimeMatchReport::usage =
  "MassiveA30IntegratedRuntimeMatchReport[] returns the development-only report that checks the actual runtime master combination against the bridged integrated literature target.";

MassiveA30IntegratedPaperCoefficientAssociation::usage =
  "MassiveA30IntegratedPaperCoefficientAssociation[] returns the paper-basis coefficients multiplying I1^(m,0,m) and I2^(m,0,m) after the paper-to-package bridge.";

MassiveA30IntegratedPaperNumeratorMasterRepresentatives::usage =
  "MassiveA30IntegratedPaperNumeratorMasterRepresentatives[] returns the natural MX30 reverse-unitarity representatives for the paper numerator-master class.";

MassiveA30IntegratedPaperNumeratorMasterReduction::usage =
  "MassiveA30IntegratedPaperNumeratorMasterReduction[] returns the explicit MX30 basis reduction of the candidate numerator-master representative used in the current dev investigation.";

MassiveA30IntegratedPaperToRuntimeBasisRelation::usage =
  "MassiveA30IntegratedPaperToRuntimeBasisRelation[] returns the experimental package-facing basis relation implied by the explicit MX30 numerator-representative reduction. It is not yet the accepted runtime bridge.";

MassiveA30IntegratedCandidateNumeratorMasterClosedForm::usage =
  "MassiveA30IntegratedCandidateNumeratorMasterClosedForm[] returns the closed-form value of the explicitly reduced numerator representative after substituting the current development master values.";

MassiveA30IntegratedExperimentalPaperI2Relation::usage =
  "MassiveA30IntegratedExperimentalPaperI2Relation[] returns the current experimental decomposition of the encoded paper I2 object in terms of I1 and the explicitly reduced numerator representative.";

MassiveA30IntegratedBridgeReport::usage =
  "MassiveA30IntegratedBridgeReport[] returns the explicit normalization/convention bridge report for the integrated massive A30 bibliography layer.";

MassiveA30IntegratedReport::usage =
  "MassiveA30IntegratedReport[] returns the structured integrated massive A30 bibliography report.";

MassiveA30IntegratedSource[] :=
  <|
    "Key" -> {A, 3, 0},
    "Status" -> "EncodedWithProvisionalRuntimeBridge",
    "ResultKind" -> "Integrated",
    "PrimarySource" -> "A. Gehrmann-De Ridder and M. Ritzmann, JHEP 07 (2009) 041",
    "ArXiv" -> "0904.3297",
    "SourceSection" -> "Section 5",
    "SourceEquations" -> {
      "Integrated A_QgQbar formula in the integrated massive final-final section",
      "I1^(m,0,m) phase-space master definition",
      "I2^(m,0,m) numerator master definition"
    },
    "Notes" -> {
      "PaperConvention keeps the literature structure explicit through the threshold variable r0 and the two paper masters I1^(m,0,m) and I2^(m,0,m).",
      "PackageConventionCandidate is derived from the paper result only through the explicit bridge in MassiveA30IntegratedNormalizationBridge[].",
      "The current package runtime basis is not identical to the paper master basis: the package second master is the dotted LiteRed basis representative j[MX30Basis123,2,1,1,0,0], whereas the paper I2^(m,0,m) is a numerator master.",
      "The accepted runtime bridge is still provisional at the second-master level: the undotted runtime master is identified with the bridged paper I1 master, while the dotted runtime master is solved from the final integrated target.",
      "An explicit MX30 numerator-representative reduction has now been derived in the dev track, but it does not yet coincide with the currently encoded paper I2 object, so it remains an investigation result rather than the active runtime bridge."
    }
  |>;

MassiveA30IntegratedPaperR0[] :=
  1 - (4 mQ^2)/Ecm2;

MassiveA30IntegratedPaperMasterI1[] :=
  Ecm2^(1 - eps) * MassiveA30IntegratedPaperR0[]^(2 - 2 eps) * 2^(-2 eps) *
    Pi^(-2 + eps) * Gamma[2 - 2 eps] * Gamma[3 - 3 eps] /
    Gamma[6 - 6 eps] *
    Hypergeometric2F1[
      1/2,
      2 - 2 eps,
      7/2 - 3 eps,
      MassiveA30IntegratedPaperR0[]
    ];

MassiveA30IntegratedPaperMasterI2[] :=
  Ecm2^(2 - eps) * MassiveA30IntegratedPaperR0[]^(3 - 2 eps) * 2^(1 - 2 eps) *
    Pi^(-2 + eps) * Gamma[3 - 2 eps] * Gamma[4 - 3 eps] /
    Gamma[8 - 6 eps] *
    Hypergeometric2F1[
      1/2,
      3 - 2 eps,
      9/2 - 3 eps,
      MassiveA30IntegratedPaperR0[]
    ];

MassiveA30IntegratedPaperConvention[] :=
  Module[{r0 = MassiveA30IntegratedPaperR0[]},
    (
      2 (1 - eps) (
        -15 + 8 r0 - r0^2 +
        eps (28 - 12 r0 + 4 r0^2) -
        eps^2 (12 + 4 r0 + 4 r0^2) +
        8 eps^3 r0
      ) MassiveA30IntegratedPaperMasterI1[] +
      (24 (1 - eps)^2 (
        3 - r0 - eps (2 + r0) + 2 eps^2 r0
      ) MassiveA30IntegratedPaperMasterI2[])/Ecm2
    ) / (
      Ecm2 eps (1 - 2 eps) r0 (1 - r0) (3 - r0 - 2 eps)
    )
  ];

MassiveA30IntegratedInvariantBridgeRules[] :=
  {
    Ecm2 -> q2,
    mQ^2 -> m2,
    MassiveA30IntegratedPaperR0[] -> 1 - (4 m2)/q2
  };

MassiveA30IntegratedNormalizationBridge[] :=
  <|
    "PaperConvention" -> <|
      "EnergySquared" -> Ecm2,
      "HeavyMassSquared" -> mQ^2,
      "ThresholdVariable" -> MassiveA30IntegratedPaperR0[],
      "DimensionalVariable" -> eps
    |>,
    "ThesisBuildSideConvention" -> <|
      "EnergySquared" -> q2,
      "HeavyMassSquared" -> mf^2,
      "Notes" -> {
        "The build-side thesis track uses the unintegrated antenna normalization from Chapter 5.",
        "This integrated bibliography milestone keeps that thesis build-side normalization distinct from the literature integrated normalization."
      }
    |>,
    "PackageIBPConvention" -> <|
      "EnergySquared" -> q2,
      "HeavyMassSquared" -> m2,
      "DimensionalVariable" -> eps,
      "RuntimeMasterBasis" -> {
        HoldForm[LiteRed`j[MX30Basis123, 1, 1, 1, 0, 0]],
        HoldForm[LiteRed`j[MX30Basis123, 2, 1, 1, 0, 0]]
      }
    |>,
    "InvariantMapping" -> MassiveA30IntegratedInvariantBridgeRules[],
    "PhaseSpaceNormalizationFactor" -> 1,
    "AntennaNormalizationFactorPaperToPackage" -> 1,
    "CouplingColorStripping" -> "The encoded paper target and the package master combination are both treated as stripped integrated antenna objects, so no extra coupling/color factor is introduced in this bridge layer.",
    "OverallBridgeFactorPaperToPackage" -> 1,
    "BridgeStatus" -> "InvariantRenameOnlyAtTargetLevel",
    "Notes" -> {
      "The bridge keeps paper and thesis normalizations separate instead of silently identifying them.",
      "Any nontrivial conversion still needed at the runtime-master level is recorded in MassiveA30IntegratedRuntimeMatchReport[] rather than hidden inside the target formula."
    }
  |>;

MassiveA30IntegratedApplyPackageBridge[expr_] :=
  expr /. MassiveA30IntegratedInvariantBridgeRules[] //
    Together // FullSimplify;

MassiveA30IntegratedPackageMasterI1Candidate[] :=
  MassiveA30IntegratedApplyPackageBridge[
    MassiveA30IntegratedPaperMasterI1[]
  ];

MassiveA30IntegratedPackageMasterI2PaperCandidate[] :=
  MassiveA30IntegratedApplyPackageBridge[
    MassiveA30IntegratedPaperMasterI2[]
  ];

MassiveA30IntegratedPackageConventionCandidate[] :=
  MassiveA30IntegratedApplyPackageBridge[
    MassiveA30IntegratedPaperConvention[]
  ];

MassiveA30IntegratedRuntimeClosedExpression[qm_] :=
  MassiveA30IntegratedPackageConventionCandidate[] /. m2 -> qm^2 //
    Together // FullSimplify;

MassiveA30IntegratedRuntimeSeries[qm_, order_Integer, normalizeScale_:True] :=
  Module[{closed, normalized, series},
    closed = MassiveA30IntegratedRuntimeClosedExpression[qm];
    normalized =
      If[TrueQ[normalizeScale],
        closed /. q2 -> 1
        ,
        closed
      ] // Together // FullSimplify;
    series =
      Series[normalized, {eps, 0, order}] //
        Normal //
        FullSimplify //
        ReplaceAll[#, eps -> FeynCalc`Epsilon]& //
        Collect[#, FeynCalc`Epsilon]&;
    series
  ];

MassiveA30IntegratedLoadPackage[] :=
  Null;

MassiveA30IntegratedRuntimeMasterCoefficientAssociation[] :=
  Module[{record, combination, j1, j2},
    MassiveA30IntegratedLoadPackage[];
    record =
      Block[{$MassiveA30ForceIBPMasterRoute = True},
        BuildAndIntegrateAntenna[
          A, 3, 0,
          quarkMass -> mQ,
          ReturnRecord -> True,
          UseStoredResults -> False,
          StoreResults -> False,
          DetailedTimingDiagnostics -> False
        ]
      ];
    combination =
      record["MasterCombination"] /. d -> 4 - 2 eps //
        Together // FullSimplify;
    j1 = LiteRed`j[MX30Basis123, 1, 1, 1, 0, 0];
    j2 = LiteRed`j[MX30Basis123, 2, 1, 1, 0, 0];
    <|
      "Combination" -> combination,
      "Master1" -> j1,
      "Master2" -> j2,
      "C1" -> Coefficient[combination, j1] // Together // FullSimplify,
      "C2" -> Coefficient[combination, j2] // Together // FullSimplify
    |>
  ];

MassiveA30IntegratedPaperNumeratorMasterReduction[] :=
  Module[{dottedCoefficient, undottedCoefficient},
    undottedCoefficient =
      (
        2 (-3 + d) m2 + (-2 + d) q2
      ) / (
        3 (-2 + d)
      ) /. d -> 4 - 2 eps // Together // FullSimplify;
    dottedCoefficient =
      (
        2 m2 (4 m2 - q2)
      ) / (
        3 (-2 + d)
      ) /. d -> 4 - 2 eps // Together // FullSimplify;
    <|
      "Representative" -> -LiteRed`j[MX30Basis123, 1, 1, 1, -1, 0],
      "SymmetricRepresentative" -> -LiteRed`j[MX30Basis123, 1, 1, 1, 0, -1],
      "Reduction" ->
        undottedCoefficient * LiteRed`j[MX30Basis123, 1, 1, 1, 0, 0] +
        dottedCoefficient * LiteRed`j[MX30Basis123, 2, 1, 1, 0, 0],
      "UndottedCoefficient" -> undottedCoefficient,
      "DottedCoefficient" -> dottedCoefficient,
      "DerivedInRepo" ->
        "Derived by explicit generated-basis jRules reduction plus ZerojRule elimination in the MX30Basis123 family."
    |>
  ];

MassiveA30IntegratedPaperToRuntimeBasisRelation[] :=
  Module[{reduction},
    reduction = MassiveA30IntegratedPaperNumeratorMasterReduction[];
    <|
      "Meaning" ->
        "Experimental package-facing relation obtained from the explicit reduction of the candidate numerator-master representative.",
      "Relation" ->
        MassiveA30IntegratedPackageMasterI2PaperCandidate[] ==
          reduction["UndottedCoefficient"] *
            LiteRed`j[MX30Basis123, 1, 1, 1, 0, 0] +
          reduction["DottedCoefficient"] *
            LiteRed`j[MX30Basis123, 2, 1, 1, 0, 0],
      "I1Coefficient" -> reduction["UndottedCoefficient"],
      "I2Coefficient" -> reduction["DottedCoefficient"],
      "AcceptedForRuntimeQ" -> False
    |>
  ];

MassiveA30IntegratedRuntimeMasterI2Candidate[] :=
  Module[{coefficients, target},
    coefficients = MassiveA30IntegratedRuntimeMasterCoefficientAssociation[];
    target = MassiveA30IntegratedPackageConventionCandidate[];
    (
      target - coefficients["C1"] MassiveA30IntegratedPackageMasterI1Candidate[]
    ) / coefficients["C2"] // Together // FullSimplify
  ];

MassiveA30IntegratedRuntimeMasterRules[] :=
  Module[{coefficients},
    coefficients = MassiveA30IntegratedRuntimeMasterCoefficientAssociation[];
    {
      coefficients["Master1"] -> MassiveA30IntegratedPackageMasterI1Candidate[],
      coefficients["Master2"] -> MassiveA30IntegratedRuntimeMasterI2Candidate[]
    }
  ];

MassiveA30IntegratedCandidateNumeratorMasterClosedForm[] :=
  Module[{reduction, rules},
    reduction = MassiveA30IntegratedPaperNumeratorMasterReduction[];
    rules = MassiveA30IntegratedRuntimeMasterRules[];
    reduction["Reduction"] /. rules /. mQ^2 -> m2 //
      Together // FullSimplify
  ];

MassiveA30IntegratedPaperCoefficientAssociation[] :=
  Module[{r0, c1, c2},
    r0 = 1 - (4 m2)/q2;
    c1 =
      (
        2 (1 - eps) (
          -15 + 8 r0 - r0^2 +
          eps (28 - 12 r0 + 4 r0^2) -
          eps^2 (12 + 4 r0 + 4 r0^2) +
          8 eps^3 r0
        )
      ) / (
        q2 eps (1 - 2 eps) r0 (1 - r0) (3 - r0 - 2 eps)
      ) // Together // FullSimplify;
    c2 =
      (
        24 (1 - eps)^2 (
          3 - r0 - eps (2 + r0) + 2 eps^2 r0
        )
      ) / (
        q2^2 eps (1 - 2 eps) r0 (1 - r0) (3 - r0 - 2 eps)
      ) // Together // FullSimplify;
    <|"I1Coefficient" -> c1, "I2Coefficient" -> c2|>
  ];

MassiveA30IntegratedPaperNumeratorMasterRepresentatives[] :=
  <|
    "SymmetricClassInterpretation" ->
      "By symmetry of the equal-mass final-final phase space, the paper numerator master can be represented by either the s13 or the s23 insertion class.",
    "InvariantRepresentatives" -> <|
      "s13" -> HoldForm[-LiteRed`j[MX30Basis123, 1, 1, 1, -1, 0]],
      "s23" -> HoldForm[-LiteRed`j[MX30Basis123, 1, 1, 1, 0, -1]]
    |>,
    "BasisDenominatorMap" -> <|
      "D4(topology123)" -> HoldForm[m2 - LiteRed`sp[-p2 + q, -p2 + q]],
      "D5(topology123)" -> HoldForm[m2 - LiteRed`sp[-p1 + q, -p1 + q]]
    |>,
    "InvariantMap" -> <|
      "s13" -> HoldForm[-(m2 - LiteRed`sp[-p2 + q, -p2 + q])],
      "s23" -> HoldForm[-(m2 - LiteRed`sp[-p1 + q, -p1 + q])]
    |>,
    "CurrentStatus" ->
      "Representatives identified and reduced explicitly in the dev track. The remaining gap is to understand how that reduced numerator representative maps to the encoded paper I2 object."
  |>;

MassiveA30IntegratedExperimentalPaperI2Relation[] :=
  Module[
    {runtime, paper, reduction, c1, c2, alpha, beta, candidate, residual},
    runtime = MassiveA30IntegratedRuntimeMasterCoefficientAssociation[];
    paper = MassiveA30IntegratedPaperCoefficientAssociation[];
    reduction = MassiveA30IntegratedPaperNumeratorMasterReduction[];
    c1 =
      (runtime["C1"] - paper["I1Coefficient"]) / paper["I2Coefficient"] //
        Together // FullSimplify;
    c2 =
      runtime["C2"] / paper["I2Coefficient"] //
        Together // FullSimplify;
    beta =
      c2 / reduction["DottedCoefficient"] //
        Together // FullSimplify;
    alpha =
      c1 - beta * reduction["UndottedCoefficient"] //
        Together // FullSimplify;
    candidate =
      alpha * MassiveA30IntegratedPackageMasterI1Candidate[] +
      beta * MassiveA30IntegratedCandidateNumeratorMasterClosedForm[] //
        Together // FullSimplify;
    candidate = candidate /. mQ^2 -> m2 // Together // FullSimplify;
    residual =
      (MassiveA30IntegratedPackageMasterI2PaperCandidate[] /. mQ^2 -> m2) -
      candidate //
        Together // FullSimplify;
    residual = residual /. mQ^2 -> m2 // Together // FullSimplify;
    <|
      "Meaning" ->
        "Experimental decomposition showing that the encoded paper I2 object can be represented as a shifted combination of I1 and the explicitly reduced numerator representative.",
      "Alpha" -> alpha,
      "Beta" -> beta,
      "Relation" ->
        MassiveA30IntegratedPackageMasterI2PaperCandidate[] ==
          alpha * MassiveA30IntegratedPackageMasterI1Candidate[] +
          beta * MassiveA30IntegratedCandidateNumeratorMasterClosedForm[],
      "Residual" -> residual,
      "MatchQ" -> TrueQ[residual === 0]
    |>
  ];

MassiveA30IntegratedRuntimeMatchReport[] :=
  Module[
    {coefficients, target, rules, substituted, packageResidual, relation},
    coefficients = MassiveA30IntegratedRuntimeMasterCoefficientAssociation[];
    target = MassiveA30IntegratedPackageConventionCandidate[];
    rules = MassiveA30IntegratedRuntimeMasterRules[];
    relation = MassiveA30IntegratedPaperToRuntimeBasisRelation[];
    substituted =
      coefficients["Combination"] /. rules //
        Together // FullSimplify;
    packageResidual =
      substituted - target // Together // FullSimplify;
    <|
      "Status" -> "ProvisionalRuntimeBridgeSolvedAgainstIntegratedTarget",
      "BridgeMethod" ->
        "Identify the undotted runtime master with the bridged paper I1^(m,0,m) master and solve the dotted runtime master algebraically from the actual package master combination and the bridged literature target.",
      "RuntimeMasterCombination" -> coefficients["Combination"],
      "RuntimeCoefficients" -> <|
        "C1" -> coefficients["C1"],
        "C2" -> coefficients["C2"]
      |>,
      "PaperToRuntimeBasisRelation" -> relation,
      "RuntimeMasterRules" -> rules,
      "SubstitutedResult" -> substituted,
      "PackageTarget" -> target,
      "PackageResidual" -> packageResidual,
      "MatchQ" -> TrueQ[packageResidual === 0],
      "Notes" -> {
        "This report validates the actual package master combination against the integrated literature target after the explicit target-level bridge.",
        "The explicit MX30 numerator-representative reduction is now recorded alongside this report, but it is not yet the accepted runtime bridge because it does not coincide with the currently encoded paper I2 object."
      }
    |>
  ];

MassiveA30IntegratedBridgeReport[] :=
  Module[{paper, package},
    paper = MassiveA30IntegratedPaperConvention[];
    package = MassiveA30IntegratedPackageConventionCandidate[];
    <|
      "Source" -> MassiveA30IntegratedSource[],
      "NormalizationBridge" -> MassiveA30IntegratedNormalizationBridge[],
      "PaperResult" -> paper,
      "PackageCandidate" -> package,
      "BridgeResidual" ->
        package - MassiveA30IntegratedApplyPackageBridge[paper] //
          Together // FullSimplify,
      "BridgeFactor" ->
        MassiveA30IntegratedNormalizationBridge[][
          "OverallBridgeFactorPaperToPackage"
        ]
    |>
  ];

MassiveA30IntegratedReport[] :=
  <|
    "Source" -> MassiveA30IntegratedSource[],
    "PaperConvention" -> MassiveA30IntegratedPaperConvention[],
    "PackageConventionCandidate" ->
      MassiveA30IntegratedPackageConventionCandidate[],
    "PaperMasterI1" -> MassiveA30IntegratedPaperMasterI1[],
    "PaperMasterI2" -> MassiveA30IntegratedPaperMasterI2[],
    "PaperNumeratorMasterReduction" ->
      MassiveA30IntegratedPaperNumeratorMasterReduction[],
    "PaperToRuntimeBasisRelation" ->
      MassiveA30IntegratedPaperToRuntimeBasisRelation[],
    "ExperimentalPaperI2Relation" ->
      MassiveA30IntegratedExperimentalPaperI2Relation[],
    "BridgeReport" -> MassiveA30IntegratedBridgeReport[],
    "RuntimeMatchReport" -> MassiveA30IntegratedRuntimeMatchReport[]
  |>;
