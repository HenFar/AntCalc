(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

(* printCoeffs: Script-local helper for this development or benchmarking utility. *)
printCoeffs[component_] := Module[{antenna, profile, basisLoad, reduction, rawReduced, records, mastersCoeffs},
  Print["\n=========================================="];
  Print["Component: ", component];
  Print["=========================================="];
  antenna = BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, Component -> component];
  profile = IBPProfile["A22TwoLoopTree"];
  basisLoad = LoadIBPBases[profile];
  reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];
  
  rawReduced = reduction["RawReducedTerms"];
  records = reduction["TermRecords"];
  
  mastersCoeffs = <||>;
  Do[
    basis = records[[i, "Basis"]];
    term = rawReduced[[i]];
    mis = LiteRed`MIs[basis];
    Do[
      coeff = Coefficient[term, mi];
      If[coeff =!= 0,
        key = {mi, basis};
        mastersCoeffs[key] = Lookup[mastersCoeffs, Key[key], 0] + coeff;
      ];
      , {mi, mis}
    ];
    , {i, Length[rawReduced]}
  ];
  
  KeyValueMap[
    (
      Print["Basis: ", #1[[2]], " Master: ", #1[[1]]];
      Print["  Coefficient: ", InputForm[#2 // Together // Simplify]];
      Print["  Value: ", InputForm[A22TwoLoopTreeRefinedMasterValue[#1[[1]], #1[[2]]]]];
    )&,
    mastersCoeffs
  ];
];

printCoeffs[Leading];
printCoeffs[Subleading];

Quit[];
