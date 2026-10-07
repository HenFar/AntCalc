(* Regression: A22BuildIntegrationBoundary
   ----------------------------------------
   A direct A22 BuildAntenna expression is invariant-only and is covered by
   the costly A22BuildInvariantOnly acceptance case.  This fast companion
   test protects the separate AntennaObject contract: an integration object
   must retain its route-native loop payload and must not trigger build-side
   LiteRed reduction. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "AntennaPipeline.wl"}]];

ClearAll[object, objectData, integrationPayload, report];

object = BuildAntenna[A, 2, 2,
  Component -> Leading,
  IntegrableForm -> True,
  UseStoredResults -> False,
  StoreResults -> False
];

objectData = If[AntennaObjectQ[object], AntennaObjectData[object], <||>];
integrationPayload = Lookup[objectData, "IntegrationAntenna", $Failed];

report = <|
  "Regression" -> "A22BuildIntegrationBoundary",
  "AntennaObjectReturnedQ" -> AntennaObjectQ[object],
  "IntegrationPayloadPresentQ" -> integrationPayload =!= $Failed,
  "PayloadRetainsLoopVariablesQ" ->
    !FreeQ[integrationPayload, l | l1 | l2],
  "PayloadHasNoLiteRedMastersQ" ->
    FreeQ[integrationPayload, HoldPattern[LiteRed`j[___]]],
  "BuildBoundaryWasDeferredQ" ->
    MissingQ[Lookup[Lookup[objectData, "BuildData", <||>],
      "BuildOutputBoundary", Missing["NotConstructed"]]]
  |>;
report["Passed"] = And @@ Values[KeyDrop[report, "Regression"]];
Print[report];
Exit[If[TrueQ[report["Passed"]], 0, 1]];
