Get[FileNameJoin[{DirectoryName[$InputFileName], "common.wl"}]];

(* V5a is the first of the one-loop / three-particle phase-space masters from
   Appendix A.2 of 0403057.

   For this first pass we do not attempt to re-integrate it. The goal is only
   to separate the master cleanly, preserve its literature definition, and make
   its relation to the repo's existing A31 master class explicit. *)

V5aSource[] :=
  <|
    "PrimaryPdf" -> "0403057v2-2.pdf",
    "Appendix" -> "A.2",
    "Equations" -> {"A.6", "A.7"},
    "BackendMaster" -> "qMI"
  |>;

V5aP2[] :=
  2^(-3 + 2 eps) Pi^(-1 + eps) Gamma[1 - eps] q2^(-eps) /
    Gamma[2 - 2 eps];

V5aSGamma2[] :=
  V5aP2[] ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

V5aLoopDefinition =
  HoldForm[
    Re[
      -I Integrate[
        dPhi3 Integrate[
          1 / (k^2 (k - p1 - p2 - p3)^2),
          ddk / (2 Pi)^d
        ]
      ]
    ]
  ];

V5aBranchRemark =
  "The appendix writes V5a with Re[(-1)^(-eps)]. For the real master this is Cos[Pi eps].";

V5aPaperClosedForm[] :=
  -V5aSGamma2[] q2^(1 - 2 eps) Gamma[1 - eps]^6 Gamma[1 + eps] Cos[Pi eps] /
    (Gamma[2 - 2 eps] Gamma[3 - 3 eps] eps);

(* LiteRed's cut class carries the opposite loop phase to the real Appendix
   A.2 convention Re[-I V5a], so qMI maps to -I V5a. *)
V5aBackendClassRelation =
  HoldForm[qMI == -I V5a];

V5aBackendScalarPart[] :=
  -V5aSGamma2[] q2^(1 - 2 eps) Gamma[1 - eps]^6 Gamma[1 + eps] Cos[Pi eps] /
    (Gamma[2 - 2 eps] Gamma[3 - 3 eps] eps);

V5aBackendScalarCheck[] :=
  FullSimplify[V5aBackendScalarPart[] - V5aPaperClosedForm[]];

V5aSeries[order_:2] :=
  MIFullExpand[V5aPaperClosedForm[], order];

V5aReport[order_:2] :=
  <|
    "Source" -> V5aSource[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "V5aP2[]",
        "V5aSGamma2[]",
        "V5aPaperClosedForm[]",
        "V5aBackendScalarCheck[]"
      },
      "ImportedFromPaper" -> {
        "V5aLoopDefinition"
      },
      "NotYetEncoded" -> {
        "A direct local integration of the loop-plus-phase-space definition",
        "The companion masters V5b and V8"
      }
    |>,
    "P2" -> V5aP2[],
    "SGamma2" -> V5aSGamma2[],
    "LoopDefinition" -> V5aLoopDefinition,
    "BranchRemark" -> V5aBranchRemark,
    "PaperClosedForm" -> V5aPaperClosedForm[],
    "BackendClassRelation" -> V5aBackendClassRelation,
    "BackendScalarPart" -> V5aBackendScalarPart[],
    "BackendScalarCheck" -> V5aBackendScalarCheck[],
    "Series" -> V5aSeries[order]
  |>;

MasterIntegralV5aData[] :=
  V5aReport[];
