Get[FileNameJoin[{DirectoryName[$InputFileName], "common.wl"}]];

(* A3 is the second virtual two-loop master from Appendix A.1 of 0403057.

   This file separates the literature master from the current repo layers:
   - the appendix/timelike core with S_Gamma and (-q^2)^(1-2 eps);
   - the current backend core, which differs by an explicit sign;
   - the compact package-convention series currently used by the IBP backend.

   The package bridge recorded here is inherited from the R8a normalization
   work, where the same A3 object appears as the integrated master behind R8a. *)

A3Source[] :=
  <|
    "PrimaryPdf" -> "0403057v2-2.pdf",
    "Appendix" -> "A.1",
    "Equations" -> {"A.1"},
    "BackendMaster" -> "A3MI",
    "CrossReference" -> "R8a"
  |>;

A3SGamma[] :=
  ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

A3LoopDefinition =
  HoldForm[
    Integrate[
      1 / (k^2 l^2 (k - l - p1 - p2)^2),
      ddk ddl / (2 Pi)^(2 d)
    ]
  ];

A3PaperClosedForm[] :=
  A3SGamma[] (-q2)^(1 - 2 eps) Gamma[1 + 2 eps] Gamma[1 - eps]^5 /
    (2 (1 - 2 eps) eps Gamma[3 - 3 eps]);

A3BackendCoreRelation =
  HoldForm[A22TwoLoopTreeCoreA3 == -A3];

A3BackendCore[] :=
  -A3SGamma[] (-q2)^(1 - 2 eps) Gamma[1 + 2 eps] Gamma[1 - eps]^5 /
    (2 (1 - 2 eps) eps Gamma[3 - 3 eps]);

A3BackendCoreCheck[] :=
  FullSimplify[A3BackendCore[] + A3PaperClosedForm[]];

A3RealConventionRules[expr_] :=
  expr /. {
    HoldPattern[Power[-q2, 1 - 2 eps]] :> -q2^(1 - 2 eps)
  };

A3RealConventionFactor[] :=
  256 Pi^8 Gamma[1 - eps]^2 / (4 Pi)^(2 eps) *
    (
      1 - Pi^2 eps^2 / 6 +
      (26 Zeta[3] / 3) eps^3 +
      (Pi^4 / 120 - 28 Zeta[3]) eps^4
    );

(* This reduced naive series and finite bridge were already checked in R8a. We
   reuse them here because the same backend A3 core is involved. *)
A3NaiveReducedSeries[order_:3] :=
  MIExpand[
    (Pi^4*(240 +
        eps*(1560 -
          eps*(-6900 + 40*Pi^2 +
            eps*(-25950 - 89565*eps + 260*Pi^2 + 1150*eps*Pi^2 +
              38*eps*Pi^4 + 160*(2 + 55*eps)*Zeta[3]))))) /
      (960*eps),
    order
  ];

A3PackageBridgeSeries[order_:3] :=
  MIExpand[
    -eps/18 +
    ((17 + 48 Pi^2) eps^2)/108 +
    ((-13675 + 1788 Pi^2 + 8784 Zeta[3]) eps^3)/648 +
    ((29494 - 2598 Pi^2 - 1323 Pi^4 - 4968 Zeta[3]) eps^4)/1944,
    order
  ];

A3BackendReducedPackageSeries[order_:3] :=
  MIFullExpand[
    A3NaiveReducedSeries[order] * A3PackageBridgeSeries[order + 1],
    order
  ];

A3BackendPackageExact[] :=
  q2^(1 - 2 eps) * (
    -Pi^4/72 +
    (Pi^4*(-11 + 24*Pi^2)/216) * eps +
    (Pi^4*(-14047 + 3666*Pi^2 + 8784*Zeta[3])/2592) * eps^2 +
    (Pi^4*(-480097 + 114348*Pi^2 - 2934*Pi^4 + 332928*Zeta[3])/15552) * eps^3
  );

A3BackendPackageSeries[order_:3] :=
  MIFullExpand[A3BackendPackageExact[], order];

A3ExpectedPackageValue[] :=
  q2^(1 - 2 eps) * (
    -Pi^4/72 +
    (Pi^4*(-11 + 24*Pi^2)/216) * eps +
    (Pi^4*(-14047 + 3666*Pi^2 + 8784*Zeta[3])/2592) * eps^2 +
    (Pi^4*(-480097 + 114348*Pi^2 - 2934*Pi^4 + 332928*Zeta[3])/15552) * eps^3
  );

A3ExpectedPackageSeries[order_:3] :=
  MIExpand[A3ExpectedPackageValue[], order];

A3PackageCheck[order_:3] :=
  FullSimplify[
    A3BackendReducedPackageSeries[order] -
      (A3ExpectedPackageSeries[order] / q2^(1 - 2 eps) /. q2 -> 1)
  ];

A3Report[order_:3] :=
  <|
    "Source" -> A3Source[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "A3SGamma[]",
        "A3PaperClosedForm[]",
        "A3BackendCoreCheck[]",
        "A3PackageCheck[order]"
      },
      "ImportedFromPaper" -> {
        "A3LoopDefinition"
      },
      "InheritedNormalizationLayer" -> {
        "A3NaiveReducedSeries[order]",
        "A3PackageBridgeSeries[order]"
      },
      "NotYetEncoded" -> {
        "A direct local derivation of the two-loop vertex integral",
        "An independent derivation in this file of the finite package bridge, instead of reusing the R8a normalization analysis"
      }
    |>,
    "SGamma" -> A3SGamma[],
    "LoopDefinition" -> A3LoopDefinition,
    "PaperClosedForm" -> A3PaperClosedForm[],
    "BackendCoreRelation" -> A3BackendCoreRelation,
    "BackendCore" -> A3BackendCore[],
    "BackendCoreCheck" -> A3BackendCoreCheck[],
    "RealConventionFactor" -> A3RealConventionFactor[],
    "NaiveReducedSeries" -> A3NaiveReducedSeries[order],
    "PackageBridgeSeries" -> A3PackageBridgeSeries[order + 1],
    "BackendReducedPackageSeries" -> A3BackendReducedPackageSeries[order],
    "BackendPackageExact" -> A3BackendPackageExact[],
    "BackendPackageSeries" -> A3BackendPackageSeries[order],
    "ExpectedPackageSeries" -> A3ExpectedPackageSeries[order],
    "PackageCheck" -> A3PackageCheck[order]
  |>;

MasterIntegralA3Data[] :=
  A3Report[];
