(* ::Section:: *)

(* AntCalc release identity *)

(* This release ledger is the single source of truth for user-facing AntCalc
   versions. Cache schema and route semantic versions are independent
   correctness barriers and must not be presented as release versions. Add a
   new entry here when advancing a release; never rewrite a released entry. *)

$AntCalcReleaseHistory = {<|"Version" -> "0.3.0-beta.2", "Date" -> "2026-07-18",
   "Stage" -> "Alpha", "Summary" -> "First tracked research release with the modular public build/integrate interface."
  |>, <|"Version" -> "0.1.0-alpha.3", "Date" -> "2026-07-19", "Stage" ->
   "Alpha", "Summary" -> "Documentation, provenance, and validated-environment release."
  |>, <|"Version" -> "0.1.0-alpha.4", "Date" -> "2026-07-23", "Stage" ->
   "Alpha", "Summary" -> "Patches on badly working routes."|>, <|"Version"
   -> "0.2.0-alpha.1", "Date" -> "2026-07-25", "Stage" -> "Alpha", "Summary"
   -> "Public master-combination records, A22 state robustness, and component-legends milestone."
  |>, <|"Version" -> "0.3.0-beta.1", "Date" -> "2026-08-06", "Stage" ->
   "Beta", "Summary" -> "Derived massive A30 MX30 closure, invariant-only A22 builds, and beta-route public integration."
  |>, <|"Version" -> "0.3.1-beta.1", "Date" -> "2026-09-07", "Stage" ->
   "Beta", "Summary" -> "Corrected the integrated Breve A22 one-loop/self convention using arXiv:2211.08446v2."
  |>};

$AntCalcVersion = Last[$AntCalcReleaseHistory]["Version"];

AntCalcVersion::usage = "AntCalcVersion[] returns the user-facing AntCalc release version.";

AntCalcVersion[] :=
  $AntCalcVersion;

AntCalcVersionHistory::usage = "AntCalcVersionHistory[] returns the ordered AntCalc release ledger.";

AntCalcVersionHistory[] :=
  $AntCalcReleaseHistory;

AntCalcDisplayVersion::usage = "AntCalcDisplayVersion[] returns the typeset user-facing release version.";

AntCalcDisplayVersion[] :=
  Row[{"0.3.1", Style[" β ", "Text"], "1 - Thesis Version"}];

LiteRed2InstallationVersion::usage = "LiteRed2InstallationVersion[] reads the installed LiteRed2 release identity without loading LiteRed.";

LiteRed2InstallationVersion[] :=
  Module[{initFile, initText, sourceName, digits},
    initFile = Quiet @ Check[FindFile["LiteRed2`"], $Failed];
    If[initFile === $Failed,
      Return["unavailable"]
    ];
    initText = Quiet @ Check[Import[initFile, "Text"], ""];
    sourceName = FirstCase[StringCases[initText, "file=\"" ~~ name : 
      Shortest[__] ~~ "\"" :> name], _String, Missing["SourceName"]];
    If[MissingQ[sourceName],
      Return["installed"]
    ];
    digits = StringReplace[FileBaseName[sourceName], Except[DigitCharacter
      ] -> ""];
    If[StringLength[digits] < 2,
      "installed"
      ,
      StringInsert[digits, ".", 2] <> "β"
    ]
  ];

AntCalcStartupBanner::usage = "AntCalcStartupBanner[] prints the concise AntCalc-owned startup banner.";

AntCalcStartupBanner[] :=
  Module[{feynCalcVersion, feynArtsVersion, feynHelpersVersion, feynCalcLegacyVersion,
     liteRedVersion},
    feynCalcVersion = Quiet @ Check[ToString[FeynCalc`$FeynCalcVersion
      ], "unavailable"];
    feynArtsVersion = Quiet @ Check[ToString[FeynArts`$FeynArtsVersion
      ], "FeynArts unavailable"];
(* Keep the release date together when a narrow notebook wraps this line.
  
  
  
  






  *)
    feynArtsVersion = StringReplace[feynArtsVersion, "27 Mar 2025" ->
       "27 Mar 2025"];
    feynHelpersVersion = Quiet @ Check[ToString[FeynCalc`$FeynHelpersVersion
      ], "unavailable"];
    feynCalcLegacyVersion = Quiet @ Check[ToString[FeynCalc`$FeynCalcLegacyVersion
      ], "unavailable"];
    liteRedVersion = LiteRed2InstallationVersion[];
(* Match FeynCalc's startup convention: notebook-owned Text styling and
  
  
  
  






   a bold package name, without imposing a colour or font size. *)
    Print[Style["AntCalc ", "Text", Bold], Style[AntCalcDisplayVersion[
      ], "Text"]];
    Print[Style["FeynCalc " <> feynCalcVersion <> "  ·  " <> feynArtsVersion
       <> "  ·  FeynHelpers " <> feynHelpersVersion <> "  ·  FeynCalcLegacy "
       <> feynCalcLegacyVersion, "Text"]];
    Print[Style["LiteRed2 " <> liteRedVersion, "Text"]];
  ];
