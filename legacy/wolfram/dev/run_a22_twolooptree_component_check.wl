(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

componentString = Environment["A22_COMPONENT"];

component =
  If[StringQ[componentString] && StringLength[componentString] > 0,
    ToExpression[componentString],
    Leading
  ];

Print["A22 component: ", component];

{buildTime, antenna} =
  AbsoluteTiming[
    BuildAntenna[A, 2, 2,
      Contribution -> TwoLoopTree,
      Component -> component
    ]
  ];

Print["build time: ", buildTime];
Print["build leaf count: ", LeafCount[antenna]];

profile = IBPProfile["A22TwoLoopTree"];

{loadTime, basisLoad} = AbsoluteTiming[LoadIBPBases[profile]];
Print["basis load time: ", loadTime];
Print["loaded basis count: ", Length[basisLoad["Bases"]]];

{reduceTime, reduction} =
  AbsoluteTiming[
    ReduceAntennaIBP[antenna, basisLoad["Bases"], profile]
  ];

Print["reduction time: ", reduceTime];
Print["reduction unmatched: ", reduction["UnmatchedCount"]];
Print["raw reduced term count: ", If[ListQ[reduction["RawReducedTerms"]],
  Length[reduction["RawReducedTerms"]], "failed"]];

rawMapped = Total[reduction["ReducedTerms"]];
masterSymbols =
  If[reduction["ReducedTerms"] === $Failed,
    {}
    ,
    DeleteDuplicates @ Cases[
      reduction["ReducedTerms"],
      A22LOMI | A3MI | A4MI | A6MI | _LiteRed`j,
      Infinity
    ]
  ];

Print["mapped masters: ", masterSymbols];
Print["coeff A22LOMI: ", Coefficient[rawMapped, A22LOMI]];
Print["coeff A3MI: ", Coefficient[rawMapped, A3MI]];
Print["coeff A4MI: ", Coefficient[rawMapped, A4MI]];
Put[
  <|"Component" -> component, "RawMapped" -> rawMapped,
    "CoefficientA22LO" -> Coefficient[rawMapped, A22LOMI],
    "CoefficientA3" -> Coefficient[rawMapped, A3MI],
    "CoefficientA4" -> Coefficient[rawMapped, A4MI]|>,
  FileNameJoin[{"/private/tmp",
    "a22_two_loop_tree_" <> ToString[component] <> "_masters.mx"}]
];

{seriesTime, integrated} =
  AbsoluteTiming[
    IBPToSeries[reduction["ReducedTerms"], profile]
  ];

Print["series time: ", seriesTime];
Print["integrated raw: ", integrated];

tTerms =
  IntegratedAntennaTTerms[
    {A, 2, 2},
    integrated,
    ExpansionOrder -> 0,
    Component -> component
  ];

Print["t terms: ", tTerms];
Print["residual: ", A22TTermResiduals[tTerms, component, 0]];
