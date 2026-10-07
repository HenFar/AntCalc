(* Development script: verify that the public massive A30 integration route now returns the provenance-backed closed result instead of the developer-only open-master combination. *)

(* ::Package:: *)

If[!ValueQ[$AntennaPipelineRoot],
  Get[
    FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
      "AntennaPipeline.wl"}]
  ];
];

Print["MX30 public-route check: building massive A30 object."];
obj = BuildAntennaObject[A, 3, 0, quarkMass -> mQ];

Print["MX30 public-route check: running IntegrateAntenna in record mode."];
integratedRecord =
  IntegrateAntenna[
    obj,
    quarkMass -> mQ,
    ExpansionOrder -> 0,
    ReturnRecord -> True,
    UseStoredResults -> False,
    StoreResults -> False,
    DetailedTimingDiagnostics -> False
  ];

Print["MX30 public-route check: running BuildAndIntegrateAntenna in record mode."];
record =
  BuildAndIntegrateAntenna[
    A, 3, 0,
    quarkMass -> mQ,
    ExpansionOrder -> 0,
    ReturnRecord -> True,
    UseStoredResults -> False,
    StoreResults -> False,
    DetailedTimingDiagnostics -> False
  ];

If[!AntennaRunRecordQ[integratedRecord] || !AntennaRunRecordQ[record],
  Print["MX30 public-route check failed: no run record was returned."];
  Print["Integrate head = ", Head[integratedRecord]];
  Print["BuildAndIntegrate head = ", Head[record]];
  Exit[1];
];

integratedResult = integratedRecord["Result"];
integratedDiagnostics = integratedRecord["Diagnostics"];
integratedBackendDiagnostics = integratedRecord["BackendDiagnostics"];
integratedIntermediateSteps = integratedRecord["IntermediateSteps"];
integratedBridgeReport =
  Lookup[integratedBackendDiagnostics, "MassiveA30BridgeReport",
    Missing["NotAvailable"]];

result = record["Result"];
diagnostics = record["Diagnostics"];
backendDiagnostics = record["BackendDiagnostics"];
intermediateSteps = record["IntermediateSteps"];
bridgeReport = Lookup[backendDiagnostics, "MassiveA30BridgeReport",
  Missing["NotAvailable"]];

Print["Integrate result head = ", Head[integratedResult]];
Print["Integrate kind = ", integratedRecord["IntegratedResultKind"]];
Print["Integrate open masters = ", integratedRecord["OpenMasterValuesQ"]];
Print["Integrate bridge report present = ", AssociationQ[integratedBridgeReport]];
Print["Integrate intermediate steps = ", Keys[integratedIntermediateSteps]];
Print["BuildAndIntegrate result head = ", Head[result]];
Print["BuildAndIntegrate kind = ", record["IntegratedResultKind"]];
Print["BuildAndIntegrate open masters = ", record["OpenMasterValuesQ"]];
Print["BuildAndIntegrate bridge report present = ", AssociationQ[bridgeReport]];
Print["BuildAndIntegrate intermediate steps = ", Keys[intermediateSteps]];

If[
  integratedResult === $Failed ||
  Lookup[integratedDiagnostics, "Failed", False] === True ||
  integratedRecord["IntegratedResultKind"] =!= "ClosedDerivedMX30Series" ||
  integratedRecord["OpenMasterValuesQ"] =!= False ||
  !AssociationQ[integratedBridgeReport] ||
  !FreeQ[integratedResult, _LiteRed`j, Infinity] ||
  result === $Failed ||
  Lookup[diagnostics, "Failed", False] === True ||
  record["IntegratedResultKind"] =!= "ClosedDerivedMX30Series" ||
  record["OpenMasterValuesQ"] =!= False ||
  !AssociationQ[bridgeReport] ||
  !FreeQ[result, _LiteRed`j, Infinity] ||
  Together[integratedResult - result] =!= 0,
  Print["MX30 public-route check failed."];
  Exit[1];
];

Print["MX30 public-route check passed."];
