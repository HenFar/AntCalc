Get[FileNameJoin[{DirectoryName[$InputFileName], "common.wl"}]];

(* A6 is the fourth virtual two-loop master from Appendix A.1 of 0403057.

   For this master the appendix itself is already quoted as an epsilon series.
   The file therefore separates:
   - the literature/timelike series master;
   - the backend core using the same bracket;
   - the backend package value built from the validated convention factors. *)

A6Source[] :=
  <|
    "PrimaryPdf" -> "0403057v2-2.pdf",
    "Appendix" -> "A.1",
    "Equations" -> {"A.1"},
    "BackendMaster" -> "A6MI",
    "CrossReference" -> "R8b"
  |>;

A6SGamma[] :=
  ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

A6PaperBracket[] :=
  -1 / eps^4 + 5 Pi^2 / (6 eps^2) + 27 Zeta[3] / eps + 23 Pi^4 / 36;

A6PaperSeries[order_:0] :=
  MIExpand[A6SGamma[] (-q2)^(-2 - 2 eps) A6PaperBracket[], order];

A6BackendCore[] :=
  A6SGamma[] (-q2)^(-2 - 2 eps) A6PaperBracket[];

A6BackendCoreCheck[order_:0] :=
  FullSimplify[
    MIExpand[A6BackendCore[], order] - A6PaperSeries[order]
  ];

A6VirtualConventionFactor[] :=
  1 - Pi^2 eps^2 / 6 +
    (26 Zeta[3] / 3) eps^3 +
    (Pi^4 / 120 - 28 Zeta[3]) eps^4;

A6TwoLoopTreeVirtualConventionFactor[] :=
  1 - 2 Pi^2 eps^2 - (28 Zeta[3] eps^3) / 3 +
    (2 (Pi^4 + 42 Zeta[3]) eps^4) / 3;

A6BackendPackageExact[] :=
  -Pi^4 A6VirtualConventionFactor[] *
    A6TwoLoopTreeVirtualConventionFactor[] q2^(-2 - 2 eps) *
    A6PaperBracket[];

A6Report[order_:0] :=
  <|
    "Source" -> A6Source[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "A6PaperSeries[order]",
        "A6BackendCoreCheck[order]"
      },
      "ImportedFromPaper" -> {
        "A6PaperBracket[]"
      },
      "NotYetEncoded" -> {
        "A direct local derivation of the crossed two-loop vertex integral",
        "A clean local bridge from the appendix timelike series to the backend package value"
      }
    |>,
    "SGamma" -> A6SGamma[],
    "PaperBracket" -> A6PaperBracket[],
    "PaperSeries" -> A6PaperSeries[order],
    "BackendCore" -> A6BackendCore[],
    "BackendCoreCheck" -> A6BackendCoreCheck[order],
    "VirtualConventionFactor" -> A6VirtualConventionFactor[],
    "TwoLoopTreeVirtualConventionFactor" -> A6TwoLoopTreeVirtualConventionFactor[],
    "BackendPackageExact" -> A6BackendPackageExact[],
    "BackendPackageSeries" -> MIExpand[A6BackendPackageExact[], order]
  |>;

MasterIntegralA6Data[] :=
  A6Report[];
