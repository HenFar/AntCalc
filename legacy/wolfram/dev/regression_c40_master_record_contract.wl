(* Regression for the documented one-shot record master-combination lookup. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

record = BuildAndIntegrateAntenna[C, 4, 0,
  ReturnRecord -> True,
  UseStoredResults -> False,
  StoreResults -> False
];
masterCombination = record["MasterCombination"];
report = <|
  "Regression" -> "C40MasterRecordContract",
  "RecordReturnedQ" -> AntennaRunRecordQ[record],
  "MasterCombinationAvailableQ" ->
    !MissingQ[masterCombination] && masterCombination =!= $Failed,
  "ContainsLiteRedMastersQ" -> !FreeQ[masterCombination, _LiteRed`j]
|>;
report["Passed"] = And @@ Values[KeyDrop[report, "Regression"]];
Print[report];
Quit[If[TrueQ[report["Passed"]], 0, 1]];
