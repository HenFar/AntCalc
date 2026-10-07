(* Regression for the A22 one-shot record's component-resolved master view. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

record = BuildAndIntegrateAntenna[A, 2, 2,
  ReturnRecord -> True,
  ReturnMasterCombination -> True,
  UseStoredResults -> False,
  StoreResults -> False
];
masterCombination = record["MasterCombination"];
expectedComponents = {"Leading", "Subleading", "Nf", "Breve"};
componentRecords = record["IntegrationRecord"];
componentStatus =
  If[AssociationQ[masterCombination] && ListQ[componentRecords],
    AssociationThread[expectedComponents,
      MapThread[
      Function[{component, value, componentRecord},
        Module[{diagnostics, backendDiagnostics},
          diagnostics =
            If[AntennaRunRecordQ[componentRecord],
              componentRecord["Diagnostics"], <||>];
          backendDiagnostics = Lookup[diagnostics, "BackendDiagnostics",
            Missing["BackendDiagnosticsNotPresent"]];
        <|
          "MasterCombinationAvailableQ" -> !MissingQ[value] && value =!= $Failed,
          "Head" -> ToString[Head[value], InputForm],
          "RecordedSelectedComponent" -> If[AntennaRunRecordQ[componentRecord],
            componentRecord["SelectedComponent"], Missing["NotARecord"]],
          "BackendDiagnosticsAssociationQ" -> AssociationQ[backendDiagnostics],
          "BackendDiagnosticKeys" -> If[AssociationQ[backendDiagnostics],
            Keys[backendDiagnostics], backendDiagnostics],
          "RawLiteRedCombinationHead" -> If[AssociationQ[backendDiagnostics],
            ToString[Head[Lookup[backendDiagnostics, "RawLiteRedCombination",
              Missing["NotPresent"]]], InputForm], "NotAvailable"]
        |>
        ]
      ], {expectedComponents, Values[masterCombination], componentRecords}]
    ],
    <||>
  ];
report = <|
  "Regression" -> "A22MasterRecordContract",
  "RecordReturnedQ" -> AntennaRunRecordQ[record],
  "MasterCombinationAssociationQ" -> AssociationQ[masterCombination],
  "ExpectedComponentsPresentQ" -> AssociationQ[masterCombination] &&
    ContainsAll[Keys[masterCombination], expectedComponents],
  "NoComponentMasterMissingQ" -> AssociationQ[masterCombination] &&
    AllTrue[Values[masterCombination], !MissingQ[#] && # =!= $Failed &],
  "DirectReturnMasterCombination" -> record["Result"],
  "ComponentMasterStatus" -> componentStatus
|>;
report["Passed"] = And @@ Values[KeyDrop[report,
  {"Regression", "DirectReturnMasterCombination", "ComponentMasterStatus"}]];
Print[report];
Quit[If[TrueQ[report["Passed"]], 0, 1]];
