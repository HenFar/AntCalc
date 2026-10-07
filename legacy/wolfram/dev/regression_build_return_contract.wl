(* Regression: BuildAntenna return-path compatibility and precedence.
   Run in a fresh kernel:
   wolframscript -file dev/regression_build_return_contract.wl *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "AntennaPipeline.wl"}]];

ClearAll[plain, record, legacyBuildData, legacyObject, objectBuilder,
  integrableObject, report];

plain = BuildAntenna[A, 2, 0, UseStoredResults -> False,
  StoreResults -> False];

record = BuildAntenna[A, 2, 0, ReturnRecord -> True,
  ReturnBuildData -> True, UseStoredResults -> False,
  StoreResults -> False];

legacyBuildData = Quiet[BuildAntenna[A, 2, 0, ReturnBuildData -> True,
  UseStoredResults -> False, StoreResults -> False]];

legacyObject = Quiet[BuildAntenna[A, 2, 0, ReturnAntennaObject -> True,
  UseStoredResults -> False, StoreResults -> False]];

objectBuilder = BuildAntennaObject[A, 2, 0, UseStoredResults -> False,
  StoreResults -> False];

integrableObject = BuildAntenna[A, 2, 0, IntegrableForm -> True,
  UseStoredResults -> False, StoreResults -> False];

report = <|
  "Regression" -> "BuildReturnContract",
  "Checks" -> <|
    "ReturnRecordWinsOverReturnBuildData" ->
      MatchQ[record, AntennaRunRecord[_Association]] && record["Result"] === plain,
    "RecordExposesBuildData" -> AssociationQ[record["BuildData"]],
    "LegacyBuildDataStillReturnsAssociation" -> AssociationQ[legacyBuildData],
    "LegacyObjectStillReturnsObject" -> AntennaObjectQ[legacyObject],
    "BuildAntennaObjectReturnsObject" -> AntennaObjectQ[objectBuilder],
    "IntegrableFormReturnsComposableObject" -> AntennaObjectQ[integrableObject]
    |>
  |>;

report = Join[report, <|"Passed" -> And @@ Values[report["Checks"]]|>];
Print[report];
If[TrueQ[report["Passed"]], Exit[0], Exit[1]];
