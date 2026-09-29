(* ::Section:: *)
(* Massive A30 unintegrated source bridge *)

(* Communicates with:
   - src/routes/massive_a30_reconstruction.wl, which uses the same physics
     target in a full BuildAntennaData-shaped workflow.
   - src/routes/massive_a30_integrated.wl, which assumes the same package-side
     convention when constructing the integrated bridge.
   - thesis-facing encoded targets, which are represented explicitly here.

   Why this file exists:
   The massive A30 route needs an explicit bridge between thesis notation and
   the package’s internal unintegrated convention.  This file makes that bridge
   transparent instead of burying it inside a larger workflow. *)

If[!ValueQ[AntennaPipelineMassiveA30LoadedQ],
  AntennaPipelineMassiveA30LoadedQ = True;
];

MassiveA30UnintegratedSource::usage =
  "MassiveA30UnintegratedSource[] returns provenance metadata for the bibliography-facing massive A30 unintegrated result.";

MassiveA30UnintegratedPaperConvention::usage =
  "MassiveA30UnintegratedPaperConvention[] returns the thesis-facing massive A30 antenna expression in the notation used for the bibliography milestone.";

MassiveA30SquaredMatrixElementPaperBracket::usage =
  "MassiveA30SquaredMatrixElementPaperBracket[] returns the numerator of the massive A30 in paper Eq. (3.1), including its explicit overall factor 4.";

MassiveA30BornNormalizationPaper::usage =
  "MassiveA30BornNormalizationPaper[] returns the thesis massive qqbar normalization denominator used to define the antenna.";

MassiveA30UnintegratedPackageConventionCandidate::usage =
  "MassiveA30UnintegratedPackageConventionCandidate[] returns the package-facing massive A30 candidate expression used for later integration planning.";

MassiveA30UnintegratedPaperBracket::usage =
  "MassiveA30UnintegratedPaperBracket[] returns the bracket multiplying the thesis normalization denominator in the encoded paper expression.";

MassiveA30UnintegratedPackageBracket::usage =
  "MassiveA30UnintegratedPackageBracket[] returns the bracket multiplying the package-convention q2 denominator in the candidate expression.";

MassiveA30UnintegratedReport::usage =
  "MassiveA30UnintegratedReport[] returns a structured report for the encoded bibliography-facing massive A30 unintegrated result.";

MassiveA30UnintegratedSource[] :=
  <|
    "Key" -> {A, 3, 0},
    "Status" -> "Encoded",
    "ResultKind" -> "Unintegrated",
    "PrimarySource" -> "A. Gehrmann-De Ridder and M. Ritzmann, JHEP 07 (2009) 041, Eq. (3.1)",
    "SourceSection" -> "Paper §3; thesis §4.5",
    "SourceEquations" -> {"Paper (3.1)-(3.2)", "Thesis (4.43)-(4.48)"},
    "Notes" -> {
      "PaperConvention preserves the symbols mf, s123, q2, epsilon and the explicit factor 4 multiplying the kinematic bracket in paper Eq. (3.1).",
      "The prior transcription omitted that numerator factor while retaining the denominator factor 4, producing an erroneous overall 1/4 and a discontinuous massless limit.",
      "For the thesis-facing convention used here, s123 follows the pair-invariant sum convention s123 = s12 + s13 + s23, while q2 = s123 + 2 mf^2 in the massive kinematics.",
      "PackageConventionCandidate keeps the same mass-dependent bracket structure while being adapted to the package denominator and symbol conventions.",
      "The package candidate is chosen to reproduce the existing massless A30 target in the quarkMass -> 0 limit."
    }
  |>;

MassiveA30UnintegratedPaperBracket[] :=
  s13/s23 + s23/s13 + 2 s12 s123/(s23 s13) -
    2 mf^2 (s123 (1/s23^2 + 1/s13^2) - 4 s12/(s13 s23)) -
    8 mf^4 (1/s23^2 + 1/s13^2);

MassiveA30SquaredMatrixElementPaperBracket[] :=
  4 MassiveA30UnintegratedPaperBracket[];

MassiveA30BornNormalizationPaper[] :=
  4 ((1 - epsilon) q2 + 2 mf^2);

MassiveA30UnintegratedPaperConvention[] :=
  MassiveA30SquaredMatrixElementPaperBracket[]/
    MassiveA30BornNormalizationPaper[];

MassiveA30UnintegratedPackageBracket[] :=
  (1 - Epsilon) (s13/s23 + s23/s13) +
    2 s12 (q2 - 2 quarkMass^2)/(s13 s23) -
    2 Epsilon -
    2 quarkMass^2 (q2 - 2 quarkMass^2) (1/s23^2 + 1/s13^2 - 4/(s13 s23)) -
    8 quarkMass^4 (1/s23^2 + 1/s13^2);

MassiveA30UnintegratedPackageConventionCandidate[] :=
  MassiveA30UnintegratedPackageBracket[]/q2;

MassiveA30UnintegratedReport[] :=
  <|
    "Source" -> MassiveA30UnintegratedSource[],
    "PaperConvention" -> MassiveA30UnintegratedPaperConvention[],
    "SquaredMatrixElementPaperBracket" ->
      MassiveA30SquaredMatrixElementPaperBracket[],
    "BornNormalizationPaper" -> MassiveA30BornNormalizationPaper[],
    "PackageConventionCandidate" ->
      MassiveA30UnintegratedPackageConventionCandidate[],
    "PaperBracket" -> MassiveA30UnintegratedPaperBracket[],
    "PackageBracket" -> MassiveA30UnintegratedPackageBracket[]
  |>;
