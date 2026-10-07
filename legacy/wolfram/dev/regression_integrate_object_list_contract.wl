(* Fresh-kernel public API regression: an integrable object list must be the
   exact lifted form of integrating each object separately. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

ClearAll[objects, direct, mapped, masterDirect, masterMapped, report];

objects = BuildAntenna[A, 3, 1,
  IntegrableForm -> True,
  UseStoredResults -> False,
  StoreResults -> False];

direct = IntegrateAntenna[objects,
  UseStoredResults -> False,
  StoreResults -> False];
mapped = IntegrateAntenna[#, UseStoredResults -> False,
    StoreResults -> False]& /@ objects;

masterDirect = IntegrateAntenna[objects,
  ReturnMasterCombination -> True,
  UseStoredResults -> False,
  StoreResults -> False];
masterMapped = IntegrateAntenna[#, ReturnMasterCombination -> True,
    UseStoredResults -> False,
    StoreResults -> False]& /@ objects;

report = <|
  "Regression" -> "IntegrateObjectListContract",
  "Checks" -> <|
    "A31IntegrableObjectsReturned" ->
      ListQ[objects] && Length[objects] === 3 && And @@ (AntennaObjectQ /@ objects),
    "DefaultListEqualsMappedCalls" -> SameQ[direct, mapped],
    "MasterListEqualsMappedCalls" -> SameQ[masterDirect, masterMapped]
    |>
  |>;
report = Join[report, <|"Passed" -> And @@ Values[report["Checks"]]|>];
Print[report];
