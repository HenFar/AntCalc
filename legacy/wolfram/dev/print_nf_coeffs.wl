(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

antenna = BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, Component -> Nf];
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];
reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];

rawReduced = reduction["RawReducedTerms"];
records = reduction["TermRecords"];

(* Find all masters and their coefficients *)
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

Print["\n=== Nf Master Coefficients ==="];
KeyValueMap[
  (
    Print["Basis: ", #1[[2]], " Master: ", #1[[1]]];
    Print["  Coefficient: ", InputForm[#2 // Together // Simplify]];
    Print["  Old Refined Value: ", InputForm[A22TwoLoopTreeRefinedMasterValue[#1[[1]], #1[[2]]]]];
    (* Compute new refined value if we write the logic here *)
  )&,
  mastersCoeffs
];

Quit[];
