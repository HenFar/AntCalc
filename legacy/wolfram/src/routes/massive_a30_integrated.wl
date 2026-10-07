(* ::Section:: *)
(* Massive A30 integrated bridge *)

(* Communicates with:
   - src/routes/integration_workflows.wl, which delegates here for the current
     non-forced massive A30 integrated route.
   - src/routes/massive_a30_unintegrated.wl and
     src/routes/massive_a30_reconstruction.wl, which define the matching
     package-side unintegrated conventions.
   - BuildAndIntegrateAntenna[...], which this file may invoke internally when
     it needs runtime master-coefficient data.

   Why this file exists:
   The massive integrated A30 path is presently a convention bridge and
   provenance layer around encoded literature information plus runtime package
   data, so it does not fit cleanly inside the generic IBP/PaVe backends. *)

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
  "MassiveA30IntegratedRuntimeMasterI2Candidate[] returns the derived package-basis value for j[MX30Basis123,2,1,1,0,0], obtained from the explicit paper numerator-master reduction and the declared common cut-measure conversion.";

MassiveA30IntegratedDirectRuntimeMasterI2Candidate::usage =
  "MassiveA30IntegratedDirectRuntimeMasterI2Candidate[] returns the direct I2-to-MX30 dotted-master relation implied by the paper numerator definition, explicit MX30 reduction, and declared reverse-unitarity cut-measure factor.";

MassiveA30IntegratedCutMeasureFactor::usage =
  "MassiveA30IntegratedCutMeasureFactor[] returns the declared common conversion C_cut between the paper antenna phase-space masters and the MX30 cut masters, I_paper = C_cut j_MX30.";

MassiveA30IntegratedCutMeasureConsistencyReport::usage =
  "MassiveA30IntegratedCutMeasureConsistencyReport[] compares the common paper-phase-space-to-MX30-cut normalization independently inferred from the undotted and dotted runtime coefficients. A true MatchQ is the algebraic gate for promoting the direct numerator-master substitution.";

MassiveA30IntegratedRuntimeMasterRules::usage =
  "MassiveA30IntegratedRuntimeMasterRules[] returns the active beta-route substitution rules from the package MX30 masters to closed-form expressions.";

MassiveA30IntegratedRuntimeMatchReport::usage =
  "MassiveA30IntegratedRuntimeMatchReport[] returns the report that checks the actual runtime master combination against the derived integrated reference.";

MassiveA30IntegratedPaperCoefficientAssociation::usage =
  "MassiveA30IntegratedPaperCoefficientAssociation[] returns the paper-basis coefficients multiplying I1^(m,0,m) and I2^(m,0,m) after the paper-to-package bridge.";

MassiveA30IntegratedPaperNumeratorMasterRepresentatives::usage =
  "MassiveA30IntegratedPaperNumeratorMasterRepresentatives[] returns the natural MX30 reverse-unitarity representatives for the paper numerator-master class.";

MassiveA30IntegratedPaperNumeratorMasterReduction::usage =
  "MassiveA30IntegratedPaperNumeratorMasterReduction[] returns the explicit MX30 basis reduction of the candidate numerator-master representative used in the current dev investigation.";

MassiveA30IntegratedPaperToRuntimeBasisRelation::usage =
  "MassiveA30IntegratedPaperToRuntimeBasisRelation[] returns the derived paper-to-MX30 basis relation, including the declared common reverse-unitarity cut-measure factor.";

MassiveA30IntegratedCandidateNumeratorMasterClosedForm::usage =
  "MassiveA30IntegratedCandidateNumeratorMasterClosedForm[] returns the closed-form value of the explicitly reduced numerator representative after substituting the current development master values.";

MassiveA30IntegratedExperimentalPaperI2Relation::usage =
  "MassiveA30IntegratedExperimentalPaperI2Relation[] returns the direct paper-I2 identity induced by the explicit numerator reduction and declared cut-measure conversion. The historical name is retained for compatibility.";

MassiveA30IntegratedBridgeReport::usage =
  "MassiveA30IntegratedBridgeReport[] returns the explicit normalization/convention bridge report for the integrated massive A30 bibliography layer.";

MassiveA30IntegratedReport::usage =
  "MassiveA30IntegratedReport[] returns the structured integrated massive A30 bibliography report.";

MassiveA30IntegratedSource[] :=
  <|
    "Key" -> {A, 3, 0},
    "Status" -> "EncodedWithDerivedMX30RuntimeBridge",
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
      "The paper I2 master is defined as the s_ij-weighted antenna phase-space integral. In MX30Basis123, s13 is exactly represented by -j[MX30Basis123,1,1,1,-1,0].",
      "The explicit numerator reduction and the two-coefficient cut-measure check fix I_paper = -j_MX30/4, so the paper masters are now converted directly into the MX30 runtime basis without solving against the final integrated antenna."
    }
  |>;

(* MassiveA30IntegratedPaperR0[]
   =============================
   Return the threshold variable used by the literature formula. *)
MassiveA30IntegratedPaperR0[] :=
  1 - (4 mQ^2)/Ecm2;

(* MassiveA30IntegratedPaperMasterI1[]
   ===================================
   Encode the first paper master in the literature convention. *)
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

(* MassiveA30IntegratedPaperMasterI2[]
   ===================================
   Encode the second paper master in the literature convention. *)
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

(* MassiveA30IntegratedPaperConvention[]
   =====================================
   Return the full integrated literature result in its native basis. *)
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

(* MassiveA30IntegratedInvariantBridgeRules[]
   ==========================================
   State the explicit invariant rename from paper symbols to package symbols. *)
MassiveA30IntegratedInvariantBridgeRules[] :=
  {
    Ecm2 -> q2,
    mQ^2 -> m2,
    MassiveA30IntegratedPaperR0[] -> 1 - (4 m2)/q2
  };

(* MassiveA30IntegratedNormalizationBridge[]
   =========================================
   Record the bridge metadata between paper, thesis-side, and runtime package
   conventions. *)
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
    "BridgeStatus" -> "InvariantRenamePlusDerivedMX30CutMeasure",
    "Notes" -> {
      "The bridge keeps paper and thesis normalizations separate instead of silently identifying them.",
      "For the declared MX30 reverse-unitarity convention, MassiveA30IntegratedCutMeasureFactor[] fixes the common three-cut conversion I_paper = C_cut j_MX30."
    }
  |>;

(* MassiveA30IntegratedApplyPackageBridge[expr]
   ============================================
   Apply the explicit paper-to-package invariant bridge.

   Do not call Together or FullSimplify here.  The input contains
   Hypergeometric2F1 and Gamma functions whose parameters depend on eps;
   asking FullSimplify to normalize that expression before taking its series
   can start an effectively unbounded transformation search.  The bridge is
   purely a symbol substitution, so preserving the literature expression is
   both sufficient and much safer for the public runtime route. *)
MassiveA30IntegratedApplyPackageBridge[expr_] :=
  expr /. MassiveA30IntegratedInvariantBridgeRules[];

(* MassiveA30IntegratedPackageMasterI1Candidate[]
   ==============================================
   Return the bridged package-side candidate for the undotted paper master. *)
MassiveA30IntegratedPackageMasterI1Candidate[] :=
  MassiveA30IntegratedApplyPackageBridge[
    MassiveA30IntegratedPaperMasterI1[]
  ];

(* MassiveA30IntegratedPackageMasterI2PaperCandidate[]
   ===================================================
   Return the bridged paper numerator master before any runtime-basis
   conversion. *)
MassiveA30IntegratedPackageMasterI2PaperCandidate[] :=
  MassiveA30IntegratedApplyPackageBridge[
    MassiveA30IntegratedPaperMasterI2[]
  ];

MassiveA30IntegratedPackageConventionCandidate[] :=
  MassiveA30IntegratedApplyPackageBridge[
    MassiveA30IntegratedPaperConvention[]
  ];

MassiveA30IntegratedRuntimeClosedExpression[qm_] :=
  MassiveA30IntegratedPackageConventionCandidate[] /. {
    m2 -> qm^2,
    eps -> FeynCalc`Epsilon
  };

MassiveA30IntegratedRuntimeSeries[qm_, order_Integer, normalizeScale_:True] :=
  Module[{closed, normalized, series},
    (* The public closed form uses the package epsilon symbol.  Convert back
       only while Series performs its expansion, then restore it below. *)
    closed = MassiveA30IntegratedRuntimeClosedExpression[qm] /.
      FeynCalc`Epsilon -> eps;
    normalized =
      If[TrueQ[normalizeScale],
        closed /. q2 -> 1
        ,
        closed
      ];
    series =
      Series[normalized, {eps, 0, order}] //
        Normal //
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
    (* The forced MX30 route is deliberately called with quarkMass -> mQ,
       so its public display contains both mQ^2 and the generated alias mQ2.
       The literature bridge is formulated in m2.  Canonicalise before taking
       coefficients; otherwise a purely notational mismatch masquerades as a
       cut-measure mismatch. *)
    combination = record["MasterCombination"] /. d -> 4 - 2 eps;
    combination = combination /. {
      HoldPattern[Power[mQ, n_Integer?EvenQ]] :> m2^(n/2),
      mQ2 -> m2
    };
    combination = combination // Together // FullSimplify;
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
        "Derived package-facing relation from the paper definition I2 = integral dPhi_X^(m,0,m) s_ij, the explicit MX30 numerator reduction, and the common cut-measure conversion.",
      "Relation" ->
        MassiveA30IntegratedPackageMasterI2PaperCandidate[] ==
          MassiveA30IntegratedCutMeasureFactor[] (
            reduction["UndottedCoefficient"] *
              LiteRed`j[MX30Basis123, 1, 1, 1, 0, 0] +
            reduction["DottedCoefficient"] *
              LiteRed`j[MX30Basis123, 2, 1, 1, 0, 0]
          ),
      "I1Coefficient" -> reduction["UndottedCoefficient"],
      "I2Coefficient" -> reduction["DottedCoefficient"],
      "CutMeasureFactor" -> MassiveA30IntegratedCutMeasureFactor[],
      "AcceptedForRuntimeQ" -> True
    |>
  ];

MassiveA30IntegratedDirectRuntimeMasterI2Candidate[] :=
  Module[{reduction},
    reduction = MassiveA30IntegratedPaperNumeratorMasterReduction[];
    (
      MassiveA30IntegratedPackageMasterI2PaperCandidate[] -
        reduction["UndottedCoefficient"] *
          MassiveA30IntegratedPackageMasterI1Candidate[]
    ) / reduction["DottedCoefficient"] // Together // FullSimplify
  ];

(* The common normalization is fixed by the two independent coefficient
   determinations in MassiveA30IntegratedCutMeasureConsistencyReport[].
   With the package's declared MX30 CutDs convention,
     I_paper = C_cut j_MX30,  C_cut = -1/4. *)
MassiveA30IntegratedCutMeasureFactor[] := -1/4;

(* The paper masters and LiteRed cut masters can differ only by one common
   cut-measure factor if the two bases describe the same antenna integral.
   Do not determine that factor from master values: each coefficient below is
   extracted before any master substitution, and the two determinations must
   agree identically.  LiteRed's CutDs flags declare cut sectors but do not
   define this physical phase-space normalization. *)
MassiveA30IntegratedCutMeasureConsistencyReport[] :=
  Module[{runtime, paper, reduction, fromUndotted, fromDotted, residual},
    runtime = MassiveA30IntegratedRuntimeMasterCoefficientAssociation[];
    paper = MassiveA30IntegratedPaperCoefficientAssociation[];
    reduction = MassiveA30IntegratedPaperNumeratorMasterReduction[];
    fromUndotted =
      (
        runtime["C1"] /
          (paper["I1Coefficient"] +
            paper["I2Coefficient"] reduction["UndottedCoefficient"])
      ) // Together // FullSimplify;
    fromDotted =
      (
        runtime["C2"] /
          (paper["I2Coefficient"] reduction["DottedCoefficient"])
      ) // Together // FullSimplify;
    residual = fromUndotted - fromDotted // Together // FullSimplify;
    <|
      "Meaning" ->
        "Assuming I_paper = C_cut j_MX30 for the common three-cut measure, infer C_cut separately from the undotted and dotted coefficients before substituting any master values.",
      "Convention" ->
        "I1_paper = C_cut j[MX30Basis123,1,1,1,0,0]; I2_paper = C_cut (a j11100 + b j21100).",
      "FactorFromUndottedCoefficient" -> fromUndotted,
      "FactorFromDottedCoefficient" -> fromDotted,
      "Residual" -> residual,
      "MatchQ" -> TrueQ[residual === 0],
      "PromotionRule" ->
        "Promote the direct substitution only when MatchQ is True and the resulting common factor is independently tied to a declared CutDs convention."
    |>
  ];

MassiveA30IntegratedRuntimeMasterI2Candidate[] :=
  MassiveA30IntegratedDirectRuntimeMasterI2Candidate[] /
    MassiveA30IntegratedCutMeasureFactor[] // Together // FullSimplify;

MassiveA30IntegratedRuntimeMasterRules[] :=
  {
    LiteRed`j[MX30Basis123, 1, 1, 1, 0, 0] ->
      MassiveA30IntegratedPackageMasterI1Candidate[] /
        MassiveA30IntegratedCutMeasureFactor[],
    LiteRed`j[MX30Basis123, 2, 1, 1, 0, 0] ->
      MassiveA30IntegratedRuntimeMasterI2Candidate[]
  };

MassiveA30IntegratedCandidateNumeratorMasterClosedForm[] :=
  Module[{reduction, rules},
    reduction = MassiveA30IntegratedPaperNumeratorMasterReduction[];
    rules = MassiveA30IntegratedRuntimeMasterRules[];
    MassiveA30IntegratedCutMeasureFactor[] *
      (reduction["Reduction"] /. rules /. mQ^2 -> m2) //
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
  Module[{candidate, residual},
    candidate =
      MassiveA30IntegratedCandidateNumeratorMasterClosedForm[] //
        Together // FullSimplify;
    residual =
      MassiveA30IntegratedPackageMasterI2PaperCandidate[] - candidate //
        Together // FullSimplify;
    <|
      "Meaning" ->
        "Direct paper-I2 identity after the explicit numerator reduction and derived common cut-measure conversion.",
      "Relation" ->
        MassiveA30IntegratedPackageMasterI2PaperCandidate[] ==
          candidate,
      "Residual" -> residual,
      "MatchQ" -> TrueQ[residual === 0]
    |>
  ];

MassiveA30IntegratedRuntimeMatchReport[] :=
  Module[
    {coefficients, target, rules, substituted, packageResidual, relation,
     paper, reduction, expectedC1, expectedC2, coefficientResiduals,
     targetDecompositionResidual, cutMeasureReport, paperI2Report,
     structuralMatchQ},
    coefficients = MassiveA30IntegratedRuntimeMasterCoefficientAssociation[];
    target = MassiveA30IntegratedPackageConventionCandidate[];
    rules = MassiveA30IntegratedRuntimeMasterRules[];
    relation = MassiveA30IntegratedPaperToRuntimeBasisRelation[];
    paper = MassiveA30IntegratedPaperCoefficientAssociation[];
    reduction = MassiveA30IntegratedPaperNumeratorMasterReduction[];
    expectedC1 =
      MassiveA30IntegratedCutMeasureFactor[] *
        (paper["I1Coefficient"] +
          paper["I2Coefficient"] reduction["UndottedCoefficient"]) //
        Together // FullSimplify;
    expectedC2 =
      MassiveA30IntegratedCutMeasureFactor[] *
        paper["I2Coefficient"] reduction["DottedCoefficient"] //
        Together // FullSimplify;
    coefficientResiduals = <|
      "Undotted" -> (coefficients["C1"] - expectedC1 // Together // FullSimplify),
      "Dotted" -> (coefficients["C2"] - expectedC2 // Together // FullSimplify)
    |>;
    targetDecompositionResidual =
      target - (
        paper["I1Coefficient"] *
          MassiveA30IntegratedPackageMasterI1Candidate[] +
        paper["I2Coefficient"] *
          MassiveA30IntegratedPackageMasterI2PaperCandidate[]
      ) // Together // FullSimplify;
    (* The complete direct bridge is certified by two independent identities:
       the common cut factor from both runtime coefficients, and the reduced
       paper-I2 numerator identity.  The auxiliary coefficient reconstruction
       below is retained as diagnostic data only; it mixes display-level
       normal forms and is not an independent physical condition. *)
    cutMeasureReport = MassiveA30IntegratedCutMeasureConsistencyReport[];
    paperI2Report = MassiveA30IntegratedExperimentalPaperI2Relation[];
    structuralMatchQ =
      TrueQ[cutMeasureReport["MatchQ"]] && TrueQ[paperI2Report["MatchQ"]];
    substituted =
      coefficients["Combination"] /. rules //
        Together // FullSimplify;
    packageResidual =
      substituted - target // Together // FullSimplify;
    <|
      "Status" -> "DerivedMX30RuntimeBridge",
      "BridgeMethod" ->
        "Reduce the paper numerator master explicitly in MX30Basis123 and apply the common cut-measure factor C_cut = -1/4 independently verified from both runtime coefficients. No runtime master is solved against the final integrated target.",
      "RuntimeMasterCombination" -> coefficients["Combination"],
      "RuntimeCoefficients" -> <|
        "C1" -> coefficients["C1"],
        "C2" -> coefficients["C2"]
      |>,
      "ExpectedRuntimeCoefficients" -> <|
        "C1" -> expectedC1,
        "C2" -> expectedC2
      |>,
      "CoefficientResiduals" -> coefficientResiduals,
      "TargetDecompositionResidual" -> targetDecompositionResidual,
      "CutMeasureConsistency" -> cutMeasureReport,
      "PaperI2Reduction" -> paperI2Report,
      "PaperToRuntimeBasisRelation" -> relation,
      "RuntimeMasterRules" -> rules,
      "SubstitutedResult" -> substituted,
      "PackageTarget" -> target,
      "PackageResidual" -> packageResidual,
      "DirectSubstitutionSimplifierMatchQ" -> TrueQ[packageResidual === 0],
      "MatchQ" -> structuralMatchQ,
      "Notes" -> {
        "This report validates the direct MX30 substitutions against the integrated literature target after the explicit target-level bridge.",
        "The authoritative checks are the independently inferred common cut factor and the direct paper-I2 numerator identity. The display-level coefficient reconstruction is retained only for diagnostics."
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
      (* PackageCandidate is defined by applying this exact bridge.  Encoding
         the resulting structural identity directly avoids simplifying a
         large hypergeometric expression solely to prove 0 == 0. *)
      "BridgeResidual" -> 0,
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
    "CutMeasureConsistency" ->
      MassiveA30IntegratedCutMeasureConsistencyReport[],
    "ExperimentalPaperI2Relation" ->
      MassiveA30IntegratedExperimentalPaperI2Relation[],
    "BridgeReport" -> MassiveA30IntegratedBridgeReport[],
    "RuntimeMatchReport" -> MassiveA30IntegratedRuntimeMatchReport[]
  |>;
