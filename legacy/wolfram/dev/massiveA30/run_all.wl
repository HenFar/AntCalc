scriptDirectory = DirectoryName[$InputFileName];
validationScripts = {
  "01_check_diagrams.wl",
  "02_check_amplitude.wl",
  "03_check_interference.wl",
  "04_check_extraction.wl",
  "05_check_match_to_thesis.wl",
  "08_check_mx30_profile.wl",
  "10_check_mx30_reduction_readiness.wl",
  "11_check_mx30_public_route.wl",
  "validate_integrated_paper_match.wl"
};

failures = {};

Print["massiveA30 validation suite"];
$MassiveA30RunAll = True;
$MassiveA30ValidationTag = Unique["MassiveA30Validation"];

Do[
  scriptPath = FileNameJoin[{scriptDirectory, script}];
  Print["Running ", script, "..."];
  exitCode =
    Replace[
      Catch[Get[scriptPath], $MassiveA30ValidationTag],
      Except[_Integer] -> 0
    ];
  If[exitCode =!= 0,
    AppendTo[failures, <|"Script" -> script, "ExitCode" -> exitCode|>]
  ];
  ,
  {script, validationScripts}
];

If[failures === {},
  Print["massiveA30 validation suite passed."];
  $MassiveA30RunAll = False;
  Exit[0];
];

Print["massiveA30 validation suite failed."];
Print["Failures: ", InputForm[failures]];
$MassiveA30RunAll = False;
Exit[1];
