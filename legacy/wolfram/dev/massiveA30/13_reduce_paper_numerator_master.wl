(* Development script: make the paper numerator-master gap explicit in the
   package MX30 basis and record the relation that a future honest IBP
   reduction must reproduce. *)

(* ::Package:: *)

If[!ValueQ[$AntennaPipelineRoot],
  Quiet[
    Get[
      FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
        "AntennaPipeline.wl"}]
    ],
    {InitializeModel::incomp2, InitializeModel::shdw}
  ];
];

Get[
  FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
    "dev", "massiveA30_sources", "index.wl"}]
];

profile = MergeIBPProfileOptions[IBPProfile["MX30"], <|"MassSymbol" -> mQ|>];
basisLoad = LoadIBPBases[profile];
representatives = MassiveA30IntegratedPaperNumeratorMasterRepresentatives[];
derivedReduction = MassiveA30IntegratedPaperNumeratorMasterReduction[];
derivedRelation = MassiveA30IntegratedPaperToRuntimeBasisRelation[];

attempt13 =
  Quiet @ Check[
    LiteRed`Solvej[-LiteRed`j[MX30Basis123, 1, 1, 1, -1, 0], MX30Basis123],
    $Failed
  ];
attempt23 =
  Quiet @ Check[
    LiteRed`Solvej[-LiteRed`j[MX30Basis123, 1, 1, 1, 0, -1], MX30Basis123],
    $Failed
  ];

Print["massiveA30 paper numerator-master scaffold"];
Print["Loaded basis count: ", Length[basisLoad["Bases"]]];
Print["Representative interpretation: ",
  representatives["SymmetricClassInterpretation"]];
Print["s13 representative: ",
  InputForm[representatives["InvariantRepresentatives"]["s13"]]];
Print["s23 representative: ",
  InputForm[representatives["InvariantRepresentatives"]["s23"]]];
Print["Derived runtime-basis coefficients:"];
Print["  I1 coefficient = ",
  InputForm[derivedRelation["I1Coefficient"]]];
Print["  j2 coefficient = ",
  InputForm[derivedRelation["I2Coefficient"]]];
Print["Derived reduction: ",
  InputForm[derivedReduction["Reduction"]]];
Print["Derived relation target: ",
  InputForm[derivedRelation["Relation"]]];
Print["Direct LiteRed Solvej attempt for s13 representative: ",
  InputForm[attempt13]];
Print["Direct LiteRed Solvej attempt for s23 representative: ",
  InputForm[attempt23]];

If[attempt13 === False || attempt23 === False,
  Print["Status: the explicit jRules-plus-ZerojRule reduction gives the basis relation, but direct negative-sector Solvej is still unresolved in the current generated-basis workflow."];
  Exit[0];
];

Print["Status: direct reduction attempt returned a nontrivial result."];
Exit[0];
