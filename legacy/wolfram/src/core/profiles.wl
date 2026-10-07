(*************************************************)

(*
  File role and communication map
  -------------------------------
  This file is the metadata registry for the whole package.

  It communicates with:
    - src/engines/amplitudes_tree.wl through MAmpLoopLess[...], which supplies
      the tree amplitudes cached by AntennaAmplitude[...].
    - src/engines/interference_tree.wl through InterfereMAmplitudes[...], which
      supplies the Born/self-interference objects cached by
      AntennaSelfInterference[...].
    - src/routes/build_workflows.wl, which uses AntennaProfile[...] to choose
      the correct production and extraction workflow for a requested antenna.
    - src/routes/integration_workflows.wl and src/interface/integration_router.wl,
      which use AntennaIntegrationProfile[...] to choose the integration backend,
      basis family, and expansion depth.
    - src/core/production_assignments.wl, which reads AntennaAmplitude[...]
      and AntennaSelfInterference[...] to populate legacy globals.

  Why this file exists:
  The package separates route logic from physics metadata.  Instead of
  hard-coding every antenna family choice inside builders and integrators, the
  builders ask this registry what kind of object they are dealing with.  That
  makes the workflow code shorter and, more importantly, makes design decisions
  like colour normalization, sector choice, or reduction backend explicit and
  centrally auditable.

  Lightweight shared normalisation.
  This is symbolic and cheap to define at load time; amplitudes and
  interferences are built lazily below.
*)

(*************************************************)

AntennaReductionProfile::usage = "AntennaReductionProfile[key] returns the build-side reduction settings associated with an antenna family.";

AntennaProfile::usage = "AntennaProfile[key] returns the main metadata association for an antenna route, including amplitudes, extraction rules, and diagnostics data.";

AntennaAmplitude::usage = "AntennaAmplitude[key] returns the tree-level amplitude object associated with a profile.";

AntennaLoopAmplitude::usage = "AntennaLoopAmplitude[key] returns a memoized raw loop amplitude used by amplitude-level validation without entering interference or integration workflows.";

AntennaSelfInterference::usage = "AntennaSelfInterference[key] returns the encoded self-interference or companion object associated with a profile.";

BornInterference::usage = "BornInterference[] returns the standard born-level interference data shared by the loop extractors.";

AntennaIntegrationProfile::usage = "AntennaIntegrationProfile[key] returns the integration-backend metadata used by IntegrateAntenna for a given route.";

AntennaWardIdentityProfile::usage = "AntennaWardIdentityProfile[key] returns the applicability and external-gluon-leg metadata for amplitude-level Ward-identity validation.";

AntennaRouteVerificationMetadata::usage = "AntennaRouteVerificationMetadata[key] returns the release-verification status and evidence scope recorded for one antenna route.";

AntennaPipelineConventionModel::usage = "AntennaPipelineConventionModel[] returns the canonical package-level convention metadata used by route profiles and runtime reports.";

AntennaPipelineDimRegDeclaration::usage = "AntennaPipelineDimRegDeclaration[] returns the explicit code-level dimensional-regularization declaration currently used by the package.";

BuildAntennaConventionProfile::usage = "BuildAntennaConventionProfile[key] returns the build-side convention metadata for one antenna route.";

IntegrationAntennaConventionProfile::usage = "IntegrationAntennaConventionProfile[key] returns the integration-side convention metadata for one antenna route.";

colourNorm = SUNN - 1 / SUNN;

(* Release-verification metadata is deliberately separate from live route
   execution. It records the evidence supporting the public status; it does not
   convert a cached expression or an experimental branch into a supported route. *)
AntennaRouteVerificationMetadata[{A, 2, 0}] :=
  <|"Release" -> "0.2.0-alpha.1", "LastVerifiedDate" -> "2026-07-29",
    "Status" -> "SupportedMassless", "EvidenceScope" -> {"PublicBuild",
      "FreshKernelUncachedExternalLiteratureRegression",
      "ReleaseVerification"}|>;

AntennaRouteVerificationMetadata[{A, 3, 0}] :=
  <|"Release" -> "0.3.0-beta.1", "LastVerifiedDate" -> "2026-08-06",
    "Status" -> "SupportedMasslessWithBetaMassiveExtension",
    "EvidenceScope" -> {"PublicBuild", "PublicIntegration",
      "FreshAndContaminatedStateRegression", "FreshKernelDerivedMX30Regression",
      "FreshKernelEpsilonDepthBenchmarkOrders0To2", "ReleaseVerification"},
    "Qualification" -> "quarkMass -> 0 is the stable massless route. The nonzero-quarkMass MX30 route is beta-qualified through ExpansionOrder -> 2; deeper epsilon orders are not yet claimed."|>;

AntennaRouteVerificationMetadata[{A, 2, 1}] :=
  <|"Release" -> "0.2.0-alpha.1", "LastVerifiedDate" -> "2026-07-29",
    "Status" -> "SupportedMassless", "EvidenceScope" -> {"PublicIntegration",
      "FreshKernelUncachedExternalLiteratureRegression",
      "ReleaseVerification"}|>;

AntennaRouteVerificationMetadata[{A, 4, 0}] :=
  <|"Release" -> "0.2.0-alpha.1", "LastVerifiedDate" -> "2026-07-28",
    "Status" -> "SupportedMassless", "EvidenceScope" -> {"PublicBuild",
      "PublicIntegration", "FreshKernelUncachedExternalLiteratureRegression",
      "ReleaseVerification"}|>;

AntennaRouteVerificationMetadata[{B, 4, 0}] :=
  <|"Release" -> "0.2.0-alpha.1", "LastVerifiedDate" -> "2026-07-29",
    "Status" -> "SupportedMassless", "EvidenceScope" -> {"PublicBuild",
      "PublicIntegration", "FreshKernelUncachedExternalLiteratureRegression",
      "ReleaseVerification"}|>;

AntennaRouteVerificationMetadata[{C, 4, 0}] :=
  <|"Release" -> "0.2.0-alpha.1", "LastVerifiedDate" -> "2026-07-29",
    "Status" -> "SupportedMassless", "EvidenceScope" -> {"PublicBuild",
      "PublicIntegration", "FreshKernelUncachedExternalLiteratureRegression",
      "ReleaseVerification"}|>;

AntennaRouteVerificationMetadata[{A, 3, 1}] :=
  <|"Release" -> "0.2.0-alpha.1", "LastVerifiedDate" -> "2026-07-29",
    "Status" -> "SupportedMassless", "EvidenceScope" -> {"PublicBuild",
      "PublicIntegration", "IBPConventionRegression", "WardIdentityRegression",
      "FreshKernelUncachedExternalLiteratureRegression",
      "PaperEquations5.18To5.20", "ReleaseVerification"}|>;

AntennaRouteVerificationMetadata[{A, 2, 2}] :=
  <|"Release" -> "0.2.0-alpha.1", "LastVerifiedDate" -> "2026-07-27",
    "Status" -> "SupportedMassless", "EvidenceScope" -> {"PublicIntegration",
      "FreshKernelUncachedExternalLiteratureRegression",
      "PaperEquations4.8To4.10", "ReleaseVerification"}|>;

AntennaRouteVerificationMetadata[{D, 3, 0}] :=
  <|"Release" -> "0.1.0-alpha.3", "LastVerifiedDate" -> Missing["NotReleaseVerified"],
    "Status" -> "Experimental", "EvidenceScope" -> {"DiagnosticOnly"},
    "Qualification" -> "Source-model research route; not part of the release contract."|>;

AntennaRouteVerificationMetadata[_] :=
  <|"Release" -> Missing["NotReleaseTracked"], "LastVerifiedDate" -> Missing["NotReleaseVerified"],
    "Status" -> "NotReleaseTracked", "EvidenceScope" -> {}|>;

AntennaPipelineDimRegDeclaration[] :=
  <|"DeclaredStatus" -> "DeclaredWorkingAssumption", "SchemeTag" -> "UndifferentiatedDMinus2EpsilonContinuation",
     "DimensionRule" -> HoldForm[D -> 4 - 2 Epsilon], "DimensionalVariable"
     -> Epsilon, "ActivationControl" -> "ApplyDimReg", "Scope" -> "Package-wide symbolic continuation used in build extraction, diagnostics, and integration-side epsilon-series handling.",
     "ClosestPublicDescription" -> "The package explicitly uses a single global D -> 4 - 2 Epsilon continuation, but does not yet expose a defended public distinction between CDR, HV, GDR, or related external-state prescriptions.",
     "SupportedUserToggle" -> False, "StatusNote" -> "The code-level declaration is now explicit, but the package still does not claim user-selectable or separately validated CDR/HV/GDR variants as part of the stable public contract."
    |>;

AntennaPipelineConventionModel[] :=
  <|"IntendedPublicContract" -> {"BuildAntenna should expose package-facing public results at the package normalization and renormalization boundary.",
     "IntegrateAntenna and BuildAndIntegrateAntenna should preserve that same public convention.",
     "Bare or prototype algebra is not part of the stable public contract unless explicitly requested by a dedicated future option."
    }, "CurrentImplementationReality" -> {"The package uses q2 as the canonical public integrated kinematic scale and normalizes that scale to 1 by default on the integration surface.",
     "The loop extraction layer applies LoopExpansionNormalization[1] = 8 Pi^2 and LoopExpansionNormalization[2] = (8 Pi^2)^2 when converting loop objects into the package expansion convention.",
     "The A21 PaVe route carries an explicit Package-X-to-paper convention bridge through the PaperRealMasslessTwoParton profile metadata rather than treating raw PaXEvaluate output as final public form.",
     "The IBP integration layer now also carries an explicit backend-to-public convention bridge for loop families such as A31 and A22 instead of assuming the raw master-substituted series is already in the final package convention.",
     "The public A31 and A22 build boundaries apply their documented counterterm patterns; prototype payloads remain available only for provenance and integration bookkeeping."
    }, "DimensionalRegularizationScheme" -> Join[AntennaPipelineDimRegDeclaration[
    ], <|"InspectableState" -> "ApplyDimReg is exposed as a public option and epsilon-series processing is used throughout the package.",
     "ExternalStatePrescriptionStatus" -> "NotSeparatelyDeclared", "ImplementationReality"
     -> "The runtime uses one package-wide dimensional continuation rather than route-selectable CDR/HV/GDR-style branches."
    |>], "PrototypeSurface" -> <|"AllowPrototypeTargetsDefault" -> False,
     "UseSourceModelRouteDefault" -> False, "StatusNote" -> "Prototype or paper-style targets are only selectively exposed and should be read as internal or exploratory unless documented otherwise for a specific route."
    |>, "RenormalizationBoundary" -> <|"BuildSidePublicContract" -> "Public build outputs are intended to be package-facing normalized and renormalized results.",
     "IntegrationSidePublicContract" -> "Integrated public outputs are intended to preserve the package-facing normalization and renormalization convention selected at build level.",
     "CurrentLoopStatus" -> "Public loop-family build outputs follow their route-specific documented renormalization boundaries.",
     "A31Status" -> "The public A31 counterterm bridge is implemented; its prototype payload remains available for provenance inspection."
    |>, "ScaleNormalization" -> <|"PublicKinematicScale" -> q2, "NormalizeKinematicScaleDefault"
     -> True, "StatusNote" -> "Scale normalization is part of the public integrated convention and should not depend on backend-specific accidents."
    |>, "LoopExpansionNormalization" -> <|"OneLoop" -> LoopExpansionNormalization[
    1], "TwoLoop" -> LoopExpansionNormalization[2], "StatusNote" -> "Loop expansion normalization is an explicit package convention layer and is separate from later PaVe or IBP integration-side convention bridges."
    |>, "PaVeBridge" -> <|"DefaultPaVeEvaluation" -> "PaXEvaluate", "ApplyFeynCalcMSDefault"
     -> True, "A21Convention" -> "PaperRealMasslessTwoParton", "StatusNote"
     -> "Raw PaXEvaluate output is not automatically the final public package form; route-specific convention bridges remain explicit."
    |>|>;

BuildAntennaConventionProfile[key_] :=
  Module[{model},
    model = AntennaPipelineConventionModel[];
    Switch[key,
      {A, 3, 1},
        <|"ConventionModel" -> "PackagePublicBuildBoundary", "RenormalizationStatus"
           -> "PublicCountertermBridgeImplemented", "PrototypeExposureStatus" ->
           "NoStablePublicPrototypeOption", "CurrentImplementationNote" -> "The public A31 build branch now applies the explicit lower-A30 UV counterterm pattern, while the prototype branch preserves the pre-counterterm extracted components for inspection."
          |>
      ,
      {A, 2, 2},
        <|"ConventionModel" -> "PackagePublicBuildBoundary", "RenormalizationStatus"
           -> "PublicCountertermSkinImplemented", "PrototypeExposureStatus" -> "NoStablePublicPrototypeOption",
           "CurrentImplementationNote" -> "The public A22 build branch applies the unintegrated lower-A21 UV-counterterm skin. AntennaObject integration retains the pre-skin prototype payload, so the authoritative integrated-A21 counterterm is applied exactly once in the integration layer."
          |>
      ,
      _,
        <|"ConventionModel" -> "PackagePublicBuildBoundary", "RenormalizationStatus"
           -> "ImplementedOrExpected", "PrototypeExposureStatus" -> "NoStablePublicPrototypeOption"
          |>
    ]
  ];

IntegrationAntennaConventionProfile[key_] :=
  Module[{model},
    model = AntennaPipelineConventionModel[];
    Switch[key,
      {A, 2, 1},
        <|"ConventionModel" -> "PackagePublicIntegratedBoundary", "BackendConventionBridge"
           -> model["PaVeBridge", "A21Convention"], "ScaleNormalization" -> model[
          "ScaleNormalization", "PublicKinematicScale"], "NormalizeKinematicScaleDefault"
           -> model["ScaleNormalization", "NormalizeKinematicScaleDefault"], "CurrentImplementationNote"
           -> "The A21 integration route applies an explicit Package-X-to-paper bridge before presenting the public result."
          |>
      ,
      {A, 3, 1},
        <|"ConventionModel" -> "PackagePublicIntegratedBoundary", "BackendConventionBridge"
           -> "IBPMasterSubstitutionPlusConventionFactor", "ScaleNormalization"
           -> model["ScaleNormalization", "PublicKinematicScale"], "NormalizeKinematicScaleDefault"
           -> model["ScaleNormalization", "NormalizeKinematicScaleDefault"], "CurrentImplementationNote"
           -> "The integrated A31 route now applies an explicit IBP backend-to-public convention bridge after master substitution; remaining residual checks are treated as route-validation work rather than an undeclared backend normalization accident."
          |>
      ,
      {A, 2, 2},
        <|"ConventionModel" -> "PackagePublicIntegratedBoundary", "BackendConventionBridge"
           -> "IBPContributionStitchingPlusConventionFactor", "ScaleNormalization"
           -> model["ScaleNormalization", "PublicKinematicScale"], "NormalizeKinematicScaleDefault"
           -> model["ScaleNormalization", "NormalizeKinematicScaleDefault"], "CurrentImplementationNote"
           -> "The A22 integration route now shares the explicit IBP convention-bridge layer used to move master-substituted results into the public package convention, while still carrying scaffold and contribution-specific implementation markers internally."
          |>
      ,
      _,
        <|"ConventionModel" -> "PackagePublicIntegratedBoundary", "ScaleNormalization"
           -> model["ScaleNormalization", "PublicKinematicScale"], "NormalizeKinematicScaleDefault"
           -> model["ScaleNormalization", "NormalizeKinematicScaleDefault"]|>
    ]
  ];

(*************************************************)

(*
  One-loop routing profiles.
  These profiles keep the A21/A31 differences out of the production code:
  particle exclusions, generation sums, reduction preferences, and antenna
  extraction are chosen from the antenna key {type, multiplicity, loop order}.
*)

(*************************************************)

(* AntennaReductionProfile[key]
   ============================
   Summary
     Return build-side reduction preferences for a requested antenna family.

   Parameters
     key : list
       Antenna selector of the form `{type, multiplicity, loopOrder}`.

   Returns
     Association
       Reduction metadata consumed by the build routes.

   Notes
     The reduction backend is stored as metadata rather than inferred from the
     loop order because the physically natural backend can differ from one family
     to another.  A21 and A31, for example, are both one-loop objects but feed
     very different extraction logic downstream. *)

AntennaReductionProfile[{A, 2, 1}] :=
  <|"DefaultBackend" -> "PaVe"|>;

AntennaReductionProfile[{A, 3, 1}] :=
  <|"DefaultBackend" -> "PaVe"|>;

AntennaReductionProfile[{type_Symbol /; SymbolName[type] === "A", 2,
  1}] :=
  <|"DefaultBackend" -> "PaVe"|>;

AntennaReductionProfile[{type_Symbol /; SymbolName[type] === "A", 3,
  1}] :=
  <|"DefaultBackend" -> "PaVe"|>;

(* Ward-identity metadata is separate from production profiles so the
   validation source and its physics boundary remain explicit and inspectable. *)

AntennaWardIdentityProfile[{type_Symbol /; SymbolName[type] === "A",
  3, 0}] :=
  <|"Availability" -> "Applicable", "ExternalGluonLegs" -> {3}, "Scope"
     -> "MasslessTreeAmplitude", "AmplitudeSource" -> "TreeAmplitude", "AmplitudeStage"
     -> "RawTree", "ValidationReduction" -> None, "SimplificationTimeLimitSeconds"
     -> 120|>;

AntennaWardIdentityProfile[{type_Symbol /; SymbolName[type] === "A",
  4, 0}] :=
  <|"Availability" -> "Applicable", "ExternalGluonLegs" -> {3, 4}, "Scope"
     -> "MasslessTreeAmplitude", "AmplitudeSource" -> "TreeAmplitude", "AmplitudeStage"
     -> "RawTree", "ValidationReduction" -> None, "SimplificationTimeLimitSeconds"
     -> 120|>;

AntennaWardIdentityProfile[{type_Symbol /; SymbolName[type] === "A",
  3, 1}] :=
  <|"Availability" -> "Applicable", "ExternalGluonLegs" -> {3}, "Scope"
     -> "MasslessOneLoopAmplitude", "AmplitudeSource" -> "RawOneLoopAmplitude",
     "AmplitudeStage" -> "RawOneLoop", "LoopMomentum" -> l, "ValidationReduction"
     -> "PaVeTensor", "SimplificationTimeLimitSeconds" -> 900, "Note" ->
    "This checks the raw A31 virtual amplitude before interference, counterterm presentation, or integration; validation simplification applies PaVe tensor reduction."
    |>;

AntennaWardIdentityProfile[_] :=
  <|"Availability" -> "NotApplicable", "ExternalGluonLegs" -> {}, "Scope"
     -> "NoExternalGluonInInitialWardScope"|>;

(* AntennaProfile[key]
   ===================
   Summary
     Return the central metadata record describing how one antenna family should
     be produced, extracted, and normalized.

   Parameters
     key : list
       Antenna selector `{type, multiplicity, loopOrder}`.

   Returns
     Association
       Route metadata used throughout the build layer.

   Notes
     This function is the main contract between the physics taxonomy of the
     package and the workflow layer.  Fields such as `Extraction`,
     `ProductionSectors`, and `ColourNorm` encode not just what the object is,
     but why the code treats it differently from nearby families. *)

AntennaProfile[{A, 2, 1}] :=
  <|"Key" -> {A, 2, 1}, "Name" -> "A21", "AntennaType" -> A, "NumFinalParticles"
     -> 2, "LoopOrder" -> 1, "TreeAmplitude" -> AntennaAmplitude[{A, 2, 0
    }], "BornInterference" -> BornInterference[], "Extraction" -> "LoopScalar",
     "ColourNorm" -> colourNorm, "ExcludedParticles" -> {S[_], V[1], V[2],
     V[3], U[1], U[2], U[3], U[4]}, "DropSumOver" -> True, "ReductionProfile"
     -> AntennaReductionProfile[{A, 2, 1}], "ConventionProfile" -> BuildAntennaConventionProfile[
    {A, 2, 1}]|>;

AntennaProfile[{A, 3, 1}] :=
  <|"Key" -> {A, 3, 1}, "Name" -> "A31", "AntennaType" -> A, "NumFinalParticles"
     -> 3, "LoopOrder" -> 1, "TreeAmplitude" -> AntennaAmplitude[{A, 3, 0
    }], "BornInterference" -> BornInterference[], "Extraction" -> "LoopColourCoefficients",
     "ColourNorm" -> colourNorm, "ExcludedParticles" -> {S[_], V[1], V[2],
     V[3], U[1], U[2], U[3]}, "DropSumOver" -> False, "ReductionProfile"
    -> AntennaReductionProfile[{A, 3, 1}], "ConventionProfile" -> BuildAntennaConventionProfile[
    {A, 3, 1}]|>;

AntennaProfile[{A, 2, 2}] :=
  <|"Key" -> {A, 2, 2}, "Name" -> "A22", "AntennaType" -> A, "NumFinalParticles"
     -> 2, "LoopOrder" -> 2, "BornInterference" -> BornInterference[], "Components"
     -> {Leading, Subleading, Nf, Breve}, "Contributions" -> {TwoLoopTree,
     OneLoopSelf}, "ContributionPlan" -> <|"Leading" -> {TwoLoopTree},
       "Subleading" -> {TwoLoopTree}, "Nf" -> {TwoLoopTree},
       "Breve" -> {OneLoopSelf}|>, "Extraction" -> "TwoLoopTTermComponents", "ExcludedParticles"
     -> {S[_], V[1], V[2], V[3], U[1], U[2], U[3], U[4]}, "DropSumOver" ->
     False, "ColourNorm" -> colourNorm, "ImplementationStatus" -> "ExperimentalSourceProduction",
     "ConventionProfile" -> BuildAntennaConventionProfile[{A, 2, 2}]|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "A", 2, 1}] :=
  <|"Key" -> {type, 2, 1}, "Name" -> "A21", "AntennaType" -> type, "NumFinalParticles"
     -> 2, "LoopOrder" -> 1, "TreeAmplitude" -> AntennaAmplitude[{type, 2,
     0}], "BornInterference" -> BornInterference[], "Extraction" -> "LoopScalar",
     "ColourNorm" -> colourNorm, "ExcludedParticles" -> {S[_], V[1], V[2],
     V[3], U[1], U[2], U[3], U[4]}, "DropSumOver" -> True, "ReductionProfile"
     -> AntennaReductionProfile[{type, 2, 1}], "ConventionProfile" -> BuildAntennaConventionProfile[
    {A, 2, 1}]|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "A", 3, 1}] :=
  <|"Key" -> {type, 3, 1}, "Name" -> "A31", "AntennaType" -> type, "NumFinalParticles"
     -> 3, "LoopOrder" -> 1, "TreeAmplitude" -> AntennaAmplitude[{type, 3,
    0}], "BornInterference" -> BornInterference[], "Extraction" -> "LoopColourCoefficients",
     "ColourNorm" -> colourNorm, "ExcludedParticles" -> {S[_], V[1], V[2],
     V[3], U[1], U[2], U[3]}, "DropSumOver" -> False, "ReductionProfile"
    -> AntennaReductionProfile[{type, 3, 1}], "ConventionProfile" -> BuildAntennaConventionProfile[
    {A, 3, 1}]|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "A", 2, 2}] :=
  <|"Key" -> {type, 2, 2}, "Name" -> "A22", "AntennaType" -> type, "NumFinalParticles"
     -> 2, "LoopOrder" -> 2, "BornInterference" -> BornInterference[], "Components"
     -> {Leading, Subleading, Nf, Breve}, "Contributions" -> {TwoLoopTree,
     OneLoopSelf}, "ContributionPlan" -> <|"Leading" -> {TwoLoopTree},
       "Subleading" -> {TwoLoopTree}, "Nf" -> {TwoLoopTree},
       "Breve" -> {OneLoopSelf}|>, "Extraction" -> "TwoLoopTTermComponents", "ExcludedParticles"
     -> {S[_], V[1], V[2], V[3], U[1], U[2], U[3], U[4]}, "DropSumOver" ->
     False, "ColourNorm" -> colourNorm, "ImplementationStatus" -> "ExperimentalSourceProduction",
     "ConventionProfile" -> BuildAntennaConventionProfile[{A, 2, 2}]|>;

(*************************************************)

(*
  Tree-level antenna profiles.
  Antenna-specific physics is stored as metadata here: colour normalisation,
  production mode, and the sector definitions used for B/C four-quark
  antennae.  The production functions below are generic.
*)

(*************************************************)

(* The tree-level profiles below are intentionally declarative.
   The route layer reads these records to decide which engine workflow to call,
   so the profile tells us not only the antenna family name but also why the
   family branches:
   - `SelfInterference` for simple squared amplitudes,
   - `ColourOrderedAntenna` when the physically useful object is a colour-ordered
     decomposition rather than one scalar,
   - sector-based production for B40/C40 where phase-space singular structure
     and quark-pair symmetry make a one-shot build less usable. *)

(* AntennaAmplitude[key]
   =====================
   Summary
     Lazily build and memoize the tree-level amplitude associated with a tree
     antenna profile.

   Parameters
     key : list
       Tree-level antenna selector.

   Returns
     expression
       The underlying FeynCalc amplitude.

   Notes
     These amplitudes are memoized because many routes need them repeatedly:
     self-interference construction, Born normalization for loop antennae, and
     notebook compatibility helpers.  Building them once keeps the software
     responsive without hiding where the physics input came from. *)

AntennaAmplitude[{A, 2, 0}] := AntennaAmplitude[{A, 2, 0}] =
  MAmpLoopLess[2];

AntennaAmplitude[{A, 3, 0}] := AntennaAmplitude[{A, 3, 0}] =
  MAmpLoopLess[3];

AntennaAmplitude[{A, 4, 0}] := AntennaAmplitude[{A, 4, 0}] =
  MAmpLoopLess[4];

AntennaAmplitude[{B, 4, 0}] := AntennaAmplitude[{B, 4, 0}] =
  MAmpLoopLess[4, AntennaType -> B];

AntennaAmplitude[{C, 4, 0}] := AntennaAmplitude[{C, 4, 0}] =
  MAmpLoopLess[4, AntennaType -> C];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "A", 2, 0}] := AntennaAmplitude[
  {type, 2, 0}] =
  MAmpLoopLess[2];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "A", 3, 0}] := AntennaAmplitude[
  {type, 3, 0}] =
  MAmpLoopLess[3];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "A", 4, 0}] := AntennaAmplitude[
  {type, 4, 0}] =
  MAmpLoopLess[4];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "B", 4, 0}] := AntennaAmplitude[
  {type, 4, 0}] =
  MAmpLoopLess[4, AntennaType -> B];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "C", 4, 0}] := AntennaAmplitude[
  {type, 4, 0}] =
  MAmpLoopLess[4, AntennaType -> C];

(* Keep loop sources separate from AntennaAmplitude, whose public contract is
   explicitly tree-level. This memoization is kernel-local and never writes a
   stored-result artifact. *)

AntennaLoopAmplitude[{type_Symbol /; SymbolName[type] === "A", 3, 1}] := AntennaLoopAmplitude[
  {type, 3, 1}] =
  MAmpOneLoop[3, AntennaType -> type, LoopMomentum -> l];

(* AntennaSelfInterference[key]
   ============================
   Summary
     Lazily build and memoize the tree-level self-interference object associated
     with a tree antenna profile.

   Parameters
     key : list
       Tree-level antenna selector.

   Returns
     expression
       The squared or interfered matrix element before route-specific
       extraction.

   Notes
     This sits one level above AntennaAmplitude[...].  Keeping the self-
     interference cached separately is useful because several downstream routes
     need the squared object directly, while others still need access to the
     unsquared amplitude for more specialized reconstructions. *)

AntennaSelfInterference[{A, 2, 0}] := AntennaSelfInterference[{A, 2,
  0}] =
  InterfereMAmplitudes[AntennaAmplitude[{A, 2, 0}], AntennaAmplitude[
    {A, 2, 0}], 2];

AntennaSelfInterference[{A, 3, 0}] := AntennaSelfInterference[{A, 3,
  0}] =
  InterfereMAmplitudes[AntennaAmplitude[{A, 3, 0}], AntennaAmplitude[
    {A, 3, 0}], 3];

AntennaSelfInterference[{A, 4, 0}] := AntennaSelfInterference[{A, 4,
  0}] =
  InterfereMAmplitudes[AntennaAmplitude[{A, 4, 0}], AntennaAmplitude[
    {A, 4, 0}], 4];

AntennaSelfInterference[{B, 4, 0}] := AntennaSelfInterference[{B, 4,
  0}] =
  InterfereMAmplitudes[AntennaAmplitude[{B, 4, 0}], AntennaAmplitude[
    {B, 4, 0}], 4, AntennaType -> B];

AntennaSelfInterference[{C, 4, 0}] := AntennaSelfInterference[{C, 4,
  0}] =
  InterfereMAmplitudes[AntennaAmplitude[{C, 4, 0}], AntennaAmplitude[
    {C, 4, 0}], 4, AntennaType -> C];

(* BornInterference[]
   ==================
   Summary
     Return the canonical A20 Born interference used to normalize loop-level
     antenna extractions.

   Returns
     expression
       The A20 self-interference object.

   Notes
     This helper intentionally fixes the Born object to one canonical source.
     That avoids a common category error where “the relevant tree” is inferred
     differently in different loop routes. *)

BornInterference[] :=
  AntennaSelfInterference[{A, 2, 0}];

(* AntennaIntegrationProfile[key]
   ==============================
   Summary
     Return the integration-side backend metadata for a requested antenna.

   Parameters
     key : list
       Antenna selector `{type, multiplicity, loopOrder}`.

   Returns
     Association
       Integration routing metadata.

   Notes
     Integration is separated from build metadata because the most convenient
     construction representation is not always the most convenient integration
     representation.  For example, A21 is built naturally in a PaVe language,
     while A31 and the tree-level higher-multiplicity antennae are routed into
     IBP families whose expansion orders are determined by their infrared pole
     structure. *)

AntennaIntegrationProfile[{A, 2, 1}] :=
  <|"DefaultBackend" -> PaVe, "PaVeFamily" -> "MasslessTwoPartonVertex",
     "PaVeEvaluation" -> "PaXEvaluate", "PaXConvention" -> "PaperRealMasslessTwoParton", "KinematicScale" ->
     q2, "ExpansionOrder" -> 2, "ConventionProfile" -> IntegrationAntennaConventionProfile[
    {A, 2, 1}]|>;

AntennaIntegrationProfile[{A, 3, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X30", "ExpansionOrder"
     -> 2, "ConventionProfile" -> IntegrationAntennaConventionProfile[{A,
     3, 0}]|>;

AntennaIntegrationProfile[{A, 4, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder"
     -> 0, "ConventionProfile" -> IntegrationAntennaConventionProfile[{A,
     4, 0}]|>;

AntennaIntegrationProfile[{B, 4, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder"
     -> 0, "ConventionProfile" -> IntegrationAntennaConventionProfile[{B,
     4, 0}]|>;

AntennaIntegrationProfile[{C, 4, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder"
     -> 0, "ConventionProfile" -> IntegrationAntennaConventionProfile[{C,
     4, 0}]|>;

AntennaIntegrationProfile[{A, 3, 1}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "A31", "ExpansionOrder"
     -> 0, "ConventionProfile" -> IntegrationAntennaConventionProfile[{A,
     3, 1}]|>;

AntennaIntegrationProfile[{A, 2, 2}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "A22", "ExpansionOrder"
     -> 0, "ImplementationStatus" -> "ValidatedMasslessIntegration", "ConventionProfile"
    -> IntegrationAntennaConventionProfile[{A, 2, 2}]|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 2,
   1}] :=
  <|"DefaultBackend" -> PaVe, "PaVeFamily" -> "MasslessTwoPartonVertex",
     "PaVeEvaluation" -> "PaXEvaluate", "PaXConvention" -> "PaperRealMasslessTwoParton", "KinematicScale" ->
     q2, "ExpansionOrder" -> 2, "ConventionProfile" -> IntegrationAntennaConventionProfile[
    {A, 2, 1}]|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 3,
   0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X30", "ExpansionOrder"
     -> 2, "ConventionProfile" -> IntegrationAntennaConventionProfile[{A,
     3, 0}]|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 4,
   0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder"
     -> 0, "ConventionProfile" -> IntegrationAntennaConventionProfile[{A,
     4, 0}]|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "B", 4,
   0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder"
     -> 0, "ConventionProfile" -> IntegrationAntennaConventionProfile[{B,
     4, 0}]|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "C", 4,
   0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder"
     -> 0, "ConventionProfile" -> IntegrationAntennaConventionProfile[{C,
     4, 0}]|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 3,
   1}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "A31", "ExpansionOrder"
     -> 0, "ConventionProfile" -> IntegrationAntennaConventionProfile[{A,
     3, 1}]|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 2,
   2}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "A22", "ExpansionOrder"
     -> 0, "ImplementationStatus" -> "ValidatedMasslessIntegration", "ConventionProfile"
    -> IntegrationAntennaConventionProfile[{A, 2, 2}]|>;

AntennaIntegrationProfile[_] :=
  <|"DefaultBackend" -> IBP, "ConventionProfile" -> IntegrationAntennaConventionProfile[
    Automatic]|>;
