scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

Get[FileNameJoin[{repoRoot, "dev", "massiveA30_sources", "index.wl"}]];

paperBracket =
  MassiveA30UnintegratedPaperBracket[] /. {mf -> quarkMass,
    s123 -> q2 - 2 quarkMass^2} // Expand;
packageBracket = MassiveA30UnintegratedPackageBracket[] // Expand;

paperMassTerms = Total[Select[List @@ paperBracket, !FreeQ[#, quarkMass]&]];
packageMassTerms = Total[Select[List @@ packageBracket, !FreeQ[#, quarkMass]&]];

massTermsMatchQ = TrueQ[Together[paperMassTerms - packageMassTerms] === 0];

Print["massiveA30 convention-bridge check"];
Print["  paper and package candidates agree on the massive correction sector: ",
  massTermsMatchQ];

If[!massTermsMatchQ,
  Print["  paper mass terms   = ", InputForm[paperMassTerms]];
  Print["  package mass terms = ", InputForm[packageMassTerms]];
  massiveA30ValidationExit[1];
];

Print["massiveA30 convention-bridge check passed."];
massiveA30ValidationExit[0];
