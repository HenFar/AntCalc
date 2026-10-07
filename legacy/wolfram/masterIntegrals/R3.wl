Get[FileNameJoin[{DirectoryName[$InputFileName], "common.wl"}]];

(* R3 is the three-particle phase-space-volume master.

   In 0311276 this object appears as P3 = Integrate[dPS3]. In the backend and
   reduction layer it is represented by the symbol R3. *)

R3Source[] :=
  <|
    "PrimaryPdf" -> "0311276v1.pdf",
    "Appendix" -> "A",
    "Equations" -> {"A.6", "A.8"},
    "PaperName" -> "P3",
    "BackendMaster" -> "R3"
  |>;

R3PhaseSpaceDefinition =
  HoldForm[
    Integrate[dPS3]
  ];

R3PaperClosedForm[] :=
  2^(-7 + 4 eps) Pi^(-3 + 2 eps) Gamma[1 - eps]^3 q2^(1 - 2 eps) /
    (Gamma[2 - 2 eps] Gamma[3 - 3 eps]);

R3BackendRelation =
  HoldForm[R3 == P3];

R3BackendCheck[] :=
  FullSimplify[
    R3PaperClosedForm[] -
      2^(-7 + 4 eps) Pi^(-3 + 2 eps) Gamma[1 - eps]^3 q2^(1 - 2 eps) /
        (Gamma[2 - 2 eps] Gamma[3 - 3 eps])
  ];

R3Series[order_:2] :=
  MIFullExpand[R3PaperClosedForm[], order];

R3Report[order_:2] :=
  <|
    "Source" -> R3Source[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "R3PaperClosedForm[]",
        "R3BackendCheck[]"
      },
      "ImportedFromPaper" -> {
        "R3PhaseSpaceDefinition"
      },
      "NotYetEncoded" -> {
        "A local derivation of P3 directly from the appendix dPS3 measure"
      }
    |>,
    "PhaseSpaceDefinition" -> R3PhaseSpaceDefinition,
    "PaperClosedForm" -> R3PaperClosedForm[],
    "BackendRelation" -> R3BackendRelation,
    "BackendCheck" -> R3BackendCheck[],
    "Series" -> R3Series[order]
  |>;

MasterIntegralR3Data[] :=
  R3Report[];
