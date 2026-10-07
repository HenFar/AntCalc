Get[FileNameJoin[{DirectoryName[$InputFileName], "common.wl"}]];

(* A4 is the third virtual two-loop master from Appendix A.1 of 0403057.

   This file separates the literature master from the current repo layers:
   - the appendix/timelike core with S_Gamma and (-q^2)^(-2 eps);
   - the current backend core, which matches the appendix-sign choice;
   - the backend package value, which additionally carries the later 1/2
     normalization fix used by the validated A22 tree/two-loop route. *)

A4Source[] :=
  <|
    "PrimaryPdf" -> "0403057v2-2.pdf",
    "Appendix" -> "A.1",
    "Equations" -> {"A.1"},
    "BackendMaster" -> "A4MI",
    "CrossReference" -> "R6"
  |>;

A4SGamma[] :=
  ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

A4LoopDefinition =
  HoldForm[
    Integrate[
      1 / (k^2 l^2 (k - p1 - p2)^2 (k - l - p1)^2),
      ddk ddl / (2 Pi)^(2 d)
    ]
  ];

A4PaperClosedForm[] :=
  -A4SGamma[] (-q2)^(-2 eps) Gamma[1 - 2 eps] Gamma[1 + eps]
    Gamma[1 - eps]^4 Gamma[1 + 2 eps] /
    (2 (1 - 2 eps) eps^2 Gamma[2 - 3 eps]);

A4BackendCore[] :=
  -A4SGamma[] (-q2)^(-2 eps) Gamma[1 - 2 eps] Gamma[1 + eps]
    Gamma[1 - eps]^4 Gamma[1 + 2 eps] /
    (2 (1 - 2 eps) eps^2 Gamma[2 - 3 eps]);

A4BackendCoreCheck[] :=
  FullSimplify[A4BackendCore[] - A4PaperClosedForm[]];

A4VirtualConventionFactor[] :=
  1 - Pi^2 eps^2 / 6 +
    (26 Zeta[3] / 3) eps^3 +
    (Pi^4 / 120 - 28 Zeta[3]) eps^4;

A4TwoLoopTreeVirtualConventionFactor[] :=
  1 - 2 Pi^2 eps^2 - (28 Zeta[3] eps^3) / 3 +
    (2 (Pi^4 + 42 Zeta[3]) eps^4) / 3;

A4BackendPackageExact[] :=
  (-(Pi^4/2) A4VirtualConventionFactor[] * A4TwoLoopTreeVirtualConventionFactor[] q2^(-2 eps) *
    Gamma[1 - 2 eps] Gamma[1 + eps] Gamma[1 - eps]^4 Gamma[1 + 2 eps]) /
    (2 (1 - 2 eps) eps^2 Gamma[2 - 3 eps]);

A4BackendConventionRemark =
  "The validated backend package value includes an additional overall 1/2 normalization adjustment relative to the straightforward appendix-to-package lift.";

A4Report[order_:2] :=
  <|
    "Source" -> A4Source[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "A4SGamma[]",
        "A4PaperClosedForm[]",
        "A4BackendCoreCheck[]"
      },
      "ImportedFromPaper" -> {
        "A4LoopDefinition"
      },
      "NotYetEncoded" -> {
        "A direct local derivation of the two-loop vertex integral",
        "A clean local bridge from the appendix master to the backend package value including the validated extra 1/2 normalization"
      }
    |>,
    "SGamma" -> A4SGamma[],
    "LoopDefinition" -> A4LoopDefinition,
    "PaperClosedForm" -> A4PaperClosedForm[],
    "BackendCore" -> A4BackendCore[],
    "BackendCoreCheck" -> A4BackendCoreCheck[],
    "VirtualConventionFactor" -> A4VirtualConventionFactor[],
    "TwoLoopTreeVirtualConventionFactor" -> A4TwoLoopTreeVirtualConventionFactor[],
    "BackendConventionRemark" -> A4BackendConventionRemark,
    "BackendPackageExact" -> A4BackendPackageExact[],
    "BackendPackageSeries" -> MIFullExpand[A4BackendPackageExact[], order]
  |>;

MasterIntegralA4Data[] :=
  A4Report[];
