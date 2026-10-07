(* Development script: validate that generated MX30 bases can be loaded and used for a first reduction attempt. *)

(* ::Package:: *)

If[!ValueQ[$AntennaPipelineRoot],
  Get[
    FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
      "AntennaPipeline.wl"}]
  ];
];

profile =
  MergeIBPProfileOptions[
    IBPProfile["MX30"],
    <|"MassSymbol" -> mQ|>
  ];

Print["MX30 readiness: profile prepared."];

If[!MX30BasisRootCompleteQ[profile["BasisRoot"]],
  Print["MX30 reduction-readiness check skipped: basis files not generated yet."];
  Print["Run dev/generate_mx30_bases.wl first."];
  Exit[0];
];

Print["MX30 readiness: building massive antenna."];
antenna = BuildAntenna[A, 3, 0, quarkMass -> mQ];
Print["MX30 readiness: loading bases."];
basisLoad = LoadIBPBases[profile];
Print["MX30 readiness: basis load attempted."];

If[!TrueQ[basisLoad["LoadedQ"]],
  Print["MX30 reduction-readiness check failed while loading bases."];
  Print["BasisLoad = ", basisLoad];
  Exit[1];
];

Print["MX30 readiness: reducing antenna."];
reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];
Print["MX30 readiness: reduction finished."];

Print["Loaded basis count = ", Length[basisLoad["Bases"]]];
Print["Unmatched count = ", reduction["UnmatchedCount"]];
Print["Remaining unmatched terms = ", reduction["UnmatchedTerms"]];
Print["Reduced terms head = ", Head[reduction["ReducedTerms"]]];
Print["Master symbols = ",
  DeleteDuplicates @ Cases[
    reduction["ReducedTerms"],
    _LiteRed`j,
    Infinity
  ]
];

If[reduction["UnmatchedCount"] =!= 0 || reduction["ReducedTerms"] === $Failed,
  Print["MX30 reduction-readiness check failed."];
  Exit[1];
];

Print["MX30 reduction-readiness check passed."];
