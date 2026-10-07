Get[FileNameJoin[{DirectoryName[$InputFileName], "common.wl"}]];

(* V5b is the second of the one-loop / three-particle phase-space masters from
   Appendix A.2 of 0403057.

   As with V5a, this first pass only separates the master cleanly, keeps the
   literature definition visible, and ties it to the existing backend master
   class. No fresh integration is attempted here. *)

V5bSource[] :=
  <|
    "PrimaryPdf" -> "0403057v2-2.pdf",
    "Appendix" -> "A.2",
    "Equations" -> {"A.6", "A.8"},
    "BackendMaster" -> "qkMI"
  |>;

V5bP2[] :=
  2^(-3 + 2 eps) Pi^(-1 + eps) Gamma[1 - eps] q2^(-eps) /
    Gamma[2 - 2 eps];

V5bSGamma2[] :=
  V5bP2[] ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

V5bLoopDefinition =
  HoldForm[
    Re[
      -I Integrate[
        dPhi3 Integrate[
          1 / (k^2 (k - p1 - p3)^2),
          ddk / (2 Pi)^d
        ]
      ]
    ]
  ];

V5bBranchRemark =
  "The appendix writes V5b with Re[(-1)^(-eps)]. For the real master this is Cos[Pi eps].";

V5bPaperClosedForm[] :=
  -V5bSGamma2[] q2^(1 - 2 eps) Gamma[1 - eps]^5 Gamma[1 - 2 eps]
    Gamma[1 + eps] Cos[Pi eps] /
    (Gamma[2 - 2 eps] Gamma[3 - 4 eps] eps);

(* LiteRed's cut class carries the opposite loop phase to the real Appendix
   A.2 convention Re[-I V5b], so qkMI maps to -I V5b. *)
V5bBackendClassRelation =
  HoldForm[qkMI == -I V5b];

V5bBackendScalarPart[] :=
  -V5bSGamma2[] q2^(1 - 2 eps) Gamma[1 - eps]^5 Gamma[1 - 2 eps]
    Gamma[1 + eps] Cos[Pi eps] /
    (Gamma[2 - 2 eps] Gamma[3 - 4 eps] eps);

V5bBackendScalarCheck[] :=
  FullSimplify[V5bBackendScalarPart[] - V5bPaperClosedForm[]];

V5bSeries[order_:2] :=
  MIFullExpand[V5bPaperClosedForm[], order];

V5bReport[order_:2] :=
  <|
    "Source" -> V5bSource[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "V5bP2[]",
        "V5bSGamma2[]",
        "V5bPaperClosedForm[]",
        "V5bBackendScalarCheck[]"
      },
      "ImportedFromPaper" -> {
        "V5bLoopDefinition"
      },
      "NotYetEncoded" -> {
        "A direct local integration of the loop-plus-phase-space definition",
        "The companion master V8"
      }
    |>,
    "P2" -> V5bP2[],
    "SGamma2" -> V5bSGamma2[],
    "LoopDefinition" -> V5bLoopDefinition,
    "BranchRemark" -> V5bBranchRemark,
    "PaperClosedForm" -> V5bPaperClosedForm[],
    "BackendClassRelation" -> V5bBackendClassRelation,
    "BackendScalarPart" -> V5bBackendScalarPart[],
    "BackendScalarCheck" -> V5bBackendScalarCheck[],
    "Series" -> V5bSeries[order]
  |>;

MasterIntegralV5bData[] :=
  V5bReport[];
