Get[FileNameJoin[{DirectoryName[$InputFileName], "common.wl"}]];

(* V8 is the third one-loop / three-particle phase-space master from Appendix
   A.2 of 0403057.

   Unlike V5a and V5b, the appendix gives V8 only as an epsilon series rather
   than as a compact gamma-function closed form. We therefore separate it as a
   literature master with an explicit series target and record carefully how
   the current backend qsMI representative is related to it. *)

V8Source[] :=
  <|
    "PrimaryPdf" -> "0403057v2-2.pdf",
    "Appendix" -> "A.2",
    "Equations" -> {"A.6", "A.9"},
    "BackendMaster" -> "qsMI"
  |>;

V8P2[] :=
  2^(-3 + 2 eps) Pi^(-1 + eps) Gamma[1 - eps] q2^(-eps) /
    Gamma[2 - 2 eps];

V8SGamma2[] :=
  V8P2[] ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

V8LoopDefinition =
  HoldForm[
    Re[
      -I Integrate[
        dPhi3 Integrate[
          1 / (2 p1 . p2 k^2 (k - p1)^2 (k - p1 - p3)^2 (k - p1 - p2 - p3)^2),
          ddk / (2 Pi)^d
        ]
      ]
    ]
  ];

V8PaperBracket[] :=
  -5 / (2 eps^4) + 9 Pi^2 / (2 eps^2) + 89 Zeta[3] / eps + 13 Pi^4 / 180;

V8PaperSeries[order_:0] :=
  MIExpand[V8SGamma2[] q2^(-2 - 2 eps) V8PaperBracket[], order];

(* The A31 backend currently uses qsMI -> I v8 with v8 carrying the opposite
   scalar sign convention to the literature V8 master. We keep that mismatch
   explicit instead of hiding it. *)
V8BackendClassRelation =
  HoldForm[qsMI == I V8backend];

V8BackendReducedBracket[] :=
  -V8PaperBracket[];

V8BackendScalarExact[] :=
  V8SGamma2[] q2^(-2 - 2 eps) V8BackendReducedBracket[];

V8BackendScalarPart[order_:0] :=
  MIExpand[V8BackendScalarExact[], order];

V8BackendConventionRemark =
  "The current qsMI scalar representative is the negative of the appendix V8 series. The i-factor in the backend class map is kept separate from that scalar sign choice.";

V8BackendScalarCheck[order_:0] :=
  FullSimplify[V8BackendScalarPart[order] + V8PaperSeries[order]];

V8Report[order_:0] :=
  <|
    "Source" -> V8Source[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "V8P2[]",
        "V8SGamma2[]",
        "V8PaperSeries[order]",
        "V8BackendScalarCheck[order]"
      },
      "ImportedFromPaper" -> {
        "V8LoopDefinition"
      },
      "NotYetEncoded" -> {
        "A direct local integration of the loop-plus-phase-space definition",
        "A closed-form representation beyond the appendix epsilon series"
      }
    |>,
    "P2" -> V8P2[],
    "SGamma2" -> V8SGamma2[],
    "LoopDefinition" -> V8LoopDefinition,
    "PaperBracket" -> V8PaperBracket[],
    "PaperSeries" -> V8PaperSeries[order],
    "BackendClassRelation" -> V8BackendClassRelation,
    "BackendConventionRemark" -> V8BackendConventionRemark,
    "BackendReducedBracket" -> V8BackendReducedBracket[],
    "BackendScalarExact" -> V8BackendScalarExact[],
    "BackendScalarPart" -> V8BackendScalarPart[order],
    "BackendScalarCheck" -> V8BackendScalarCheck[order]
  |>;

MasterIntegralV8Data[] :=
  V8Report[];
