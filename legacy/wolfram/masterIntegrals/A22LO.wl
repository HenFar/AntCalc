Get[FileNameJoin[{DirectoryName[$InputFileName], "common.wl"}]];

(* A22LO is the first virtual two-loop master from Appendix A.1 of 0403057.

   This file separates the literature master itself from the two distinct repo
   layers built on top of it:
   - the appendix/timelike core written with S_Gamma and (-q^2)^(-2 eps);
   - the compact package-convention series currently substituted by the IBP
     backend.

   No fresh loop integration is attempted here. *)

A22LOSource[] :=
  <|
    "PrimaryPdf" -> "0403057v2-2.pdf",
    "Appendix" -> "A.1",
    "Equations" -> {"A.1"},
    "BackendMaster" -> "A22LOMI"
  |>;

A22LOSGamma[] :=
  ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

A22LOLoopDefinition =
  HoldForm[
    Integrate[
      1 / (k^2 (k - p1 - p2)^2 l^2 (l - p1 - p2)^2),
      ddk ddl / (2 Pi)^(2 d)
    ]
  ];

A22LOPaperClosedForm[] :=
  A22LOSGamma[] (-q2)^(-2 eps) Gamma[1 + eps]^2 Gamma[1 - eps]^6 /
    (eps^2 Gamma[2 - 2 eps]^2);

(* The current two-loop/tree backend uses the same appendix master but with an
   explicit minus sign in the core representative. We keep that distinction
   visible instead of blurring the literature object with the package object. *)
A22LOBackendCoreRelation =
  HoldForm[A22TwoLoopTreeCoreA22LO == -A22LO];

A22LOBackendCore[] :=
  -A22LOSGamma[] (-q2)^(-2 eps) Gamma[1 + eps]^2 Gamma[1 - eps]^6 /
    (eps^2 Gamma[2 - 2 eps]^2);

A22LOBackendCoreCheck[] :=
  FullSimplify[A22LOBackendCore[] + A22LOPaperClosedForm[]];

A22LOVirtualConventionFactor[] :=
  1 - Pi^2 eps^2 / 6 +
    (26 Zeta[3] / 3) eps^3 +
    (Pi^4 / 120 - 28 Zeta[3]) eps^4;

A22LOTwoLoopTreeVirtualConventionFactor[] :=
  1 - 2 Pi^2 eps^2 - (28 Zeta[3] eps^3) / 3 +
    (2 (Pi^4 + 42 Zeta[3]) eps^4) / 3;

A22LOPaperConventionRules[expr_] :=
  expr /. {
    HoldPattern[Power[-q2, -2 eps]] :> q2^(-2 eps) Cos[2 Pi eps]
  };

A22LOPaperConventionFactor[] :=
  256 Pi^8 A22LOVirtualConventionFactor[] Gamma[1 - eps]^2 /
    ((4 Pi)^(2 eps) Cos[2 Pi eps]);

A22LOBackendPackageExact[] :=
  q2^(-2 eps) * (
    (-3*Pi^4)/(8*eps^2) -
    Pi^4/eps +
    (Pi^4*(-53 + 14*Pi^2))/32 -
    (Pi^4*(-2239 + 6*Pi^2 + 3264*Zeta[3])/288) * eps +
    (Pi^4*(1338445 - 141690*Pi^2 + 3468*Pi^4 - 888480*Zeta[3])/17280) * eps^2
  );

A22LOBackendPackageSeries[order_:2] :=
  MIExpand[A22LOBackendPackageExact[], order];

A22LOPackageBridgeCheck[order_:2] :=
  Missing["NotYetEncoded"];

A22LOReport[order_:2] :=
  <|
    "Source" -> A22LOSource[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "A22LOSGamma[]",
        "A22LOPaperClosedForm[]",
        "A22LOBackendCoreCheck[]"
      },
      "ImportedFromPaper" -> {
        "A22LOLoopDefinition"
      },
      "NotYetEncoded" -> {
        "A direct local derivation of the disconnected two-bubble integral",
        "A clean local bridge from the appendix master to the compact package-convention series"
      }
    |>,
    "SGamma" -> A22LOSGamma[],
    "LoopDefinition" -> A22LOLoopDefinition,
    "PaperClosedForm" -> A22LOPaperClosedForm[],
    "BackendCoreRelation" -> A22LOBackendCoreRelation,
    "BackendCore" -> A22LOBackendCore[],
    "BackendCoreCheck" -> A22LOBackendCoreCheck[],
    "VirtualConventionFactor" -> A22LOVirtualConventionFactor[],
    "TwoLoopTreeVirtualConventionFactor" -> A22LOTwoLoopTreeVirtualConventionFactor[],
    "PaperConventionFactor" -> A22LOPaperConventionFactor[],
    "BackendPackageExact" -> A22LOBackendPackageExact[],
    "BackendPackageSeries" -> A22LOBackendPackageSeries[order],
    "PackageBridgeCheck" -> A22LOPackageBridgeCheck[order]
  |>;

MasterIntegralA22LOData[] :=
  A22LOReport[];
