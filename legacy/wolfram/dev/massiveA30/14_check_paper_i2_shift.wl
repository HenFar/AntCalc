(* Development script: verify that the encoded paper I2 object is a shifted
   combination of I1 and the explicitly reduced MX30 numerator representative. *)

(* ::Package:: *)

If[!ValueQ[$AntennaPipelineRoot],
  Quiet[
    Get[
      FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
        "AntennaPipeline.wl"}]
    ],
    {InitializeModel::nosymb, InitializeModel::incomp2, InitializeModel::shdw}
  ];
];

Get[
  FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
    "dev", "massiveA30_sources", "index.wl"}]
];

relation = MassiveA30IntegratedExperimentalPaperI2Relation[];

Print["massiveA30 paper I2 shift check"];
Print["MatchQ: ", relation["MatchQ"]];
Print["Alpha: ", InputForm[relation["Alpha"]]];
Print["Beta: ", InputForm[relation["Beta"]]];
Print["Residual: ", InputForm[relation["Residual"]]];

If[!TrueQ[relation["MatchQ"]],
  Exit[1];
];

Print["massiveA30 paper I2 shift check passed."];
Exit[0];
