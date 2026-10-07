(* Regression: BuildIntermediateStepsContract
   ------------------------------------------
   Fresh-kernel contract test for the compact build-stage association. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "AntennaPipeline.wl"}]];

{a30, a30Steps} = BuildAntenna[A, 3, 0, IntermediateSteps -> True,
  UseStoredResults -> False, StoreResults -> False];

{a31, a31Steps} = BuildAntenna[A, 3, 1, IntermediateSteps -> True,
  UseStoredResults -> False, StoreResults -> False];

<|"Regression" -> "BuildIntermediateStepsContract",
  "Checks" -> <|
    "A30CompactKeys" -> Keys[a30Steps] ===
      {"Amplitude", "Interference", "Antenna"},
    "A30AntennaMatchesResult" -> a30Steps["Antenna"] === a30,
    "A31ContainsPreReductionStage" ->
      KeyExistsQ[a31Steps, "InterferenceBeforeReduction"],
    "A31ContainsReducedStage" -> KeyExistsQ[a31Steps, "ReducedInterference"],
    "A31AntennaMatchesResult" -> a31Steps["Antenna"] === a31,
    "NoRawBuildDataInDefaultView" -> !KeyExistsQ[a31Steps, "BuildData"]
  |>|>
