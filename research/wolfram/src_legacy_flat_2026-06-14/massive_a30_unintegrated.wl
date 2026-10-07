If[!ValueQ[AntennaPipelineMassiveA30LoadedQ],
  AntennaPipelineMassiveA30LoadedQ = True;
];

MassiveA30UnintegratedSource::usage =
  "MassiveA30UnintegratedSource[] returns provenance metadata for the bibliography-facing massive A30 unintegrated result.";

MassiveA30UnintegratedPaperConvention::usage =
  "MassiveA30UnintegratedPaperConvention[] returns the thesis-facing massive A30 antenna expression in the notation used for the bibliography milestone.";

MassiveA30SquaredMatrixElementPaperBracket::usage =
  "MassiveA30SquaredMatrixElementPaperBracket[] returns the bracket appearing in the thesis qqbar g squared-matrix-element expression before the overall N3 factor.";

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
    "PrimarySource" -> "TM_Joana_Reis.pdf",
    "SourceSection" -> "Chapter 5",
    "SourceEquations" -> {"(5.1.1)", "(5.1.2)", "(5.1.3)"},
    "Notes" -> {
      "PaperConvention preserves the thesis-facing normalization and symbols mf, s123, q2, epsilon.",
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
  MassiveA30UnintegratedPaperBracket[];

MassiveA30BornNormalizationPaper[] :=
  4 ((1 - epsilon) q2 + 2 mf^2);

MassiveA30UnintegratedPaperConvention[] :=
  MassiveA30UnintegratedPaperBracket[]/MassiveA30BornNormalizationPaper[];

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
