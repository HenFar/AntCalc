(* Diagnose the A22 integrable-build boundary after the sequence reported by
   the advisor.  This intentionally stops before A22 integration: if object
   construction fails, the relevant evidence is the build diagnostics. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

ClearAll[StateSummary];
StateSummary[] := Module[{scalarProducts, liteRedSymbols},
  scalarProducts = Association @ Table[
    ToString[{left, right}, InputForm] -> ToString[SPD[left, right], InputForm],
    {left, {k1, k2, k3, k4}}, {right, {k1, k2, k3, k4}}
  ];
  liteRedSymbols = If[NameQ["LiteRed`j"],
    Sort[Names["LiteRed`*"]], {"NotLoaded"}];
  <|"ContextPath" -> $ContextPath, "Directory" -> Directory[],
    "ScalarProductHash" -> Hash[scalarProducts, "SHA256"],
    "LiteRedSymbolHash" -> Hash[liteRedSymbols, "SHA256"],
    "LiteRedSymbolCount" -> Length[liteRedSymbols]|>
];

before = StateSummary[];
c40 = BuildAndIntegrateAntenna[C, 4, 0,
  ReturnRecord -> True,
  UseStoredResults -> False, StoreResults -> False
];
afterC40 = StateSummary[];
a31 = BuildAndIntegrateAntenna[A, 3, 1,
  UseStoredResults -> False, StoreResults -> False
];
afterA31 = StateSummary[];
a22Build = BuildAntenna[A, 2, 2,
  IntegrableForm -> True,
  ReturnDiagnostics -> True,
  UseStoredResults -> False, StoreResults -> False
];
afterA22Build = StateSummary[];

diagnosticSummary = If[MatchQ[a22Build, {_, _Association}],
  KeyTake[Last[a22Build], {"Failed", "Reason", "ImplementationStatus",
    "InternalSourceContribution", "SelectedComponent", "ContributionsUsed"}],
  Missing["NoBuildDiagnostics"]
];
report = <|
  "Regression" -> "A22AfterAdvisorSequence",
  "A22IntegrableBuildReturned" -> MatchQ[a22Build, {_, _Association}],
  "A22IntegrableObjectQ" -> If[MatchQ[a22Build, {_, _Association}],
    AllTrue[First[a22Build], AntennaObjectQ], False],
  "A22BuildDiagnostics" -> diagnosticSummary,
  "State" -> <|"Before" -> before, "AfterC40" -> afterC40,
    "AfterA31" -> afterA31, "AfterA22Build" -> afterA22Build|>
|>; 
Print[report];
Quit[If[TrueQ[report["A22IntegrableBuildReturned"]] &&
  TrueQ[report["A22IntegrableObjectQ"]], 0, 1]];
