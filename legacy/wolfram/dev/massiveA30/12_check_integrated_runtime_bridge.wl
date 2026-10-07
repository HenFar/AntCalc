(* Development script: verify that the public massive A30 integration route
   reproduces the provenance-backed runtime bridge result. *)

(* ::Package:: *)

If[!ValueQ[$AntennaPipelineRoot],
  Get[
    FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
      "AntennaPipeline.wl"}]
  ];
];

Get[
  FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
    "dev", "massiveA30_sources", "index.wl"}]
];

bridgeReport = MassiveA30IntegratedBridgeReport[];
runtimeTarget = MassiveA30IntegratedRuntimeSeries[mQ, 0, True];
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
runtimeResidual =
  Together[record["Result"] - runtimeTarget] // FullSimplify;
runtimeMatchQ = TrueQ[runtimeResidual === 0];

Print["massiveA30 integrated runtime bridge"];
Print["Source status: ", MassiveA30IntegratedSource[]["Status"]];
Print["Bridge factor: ", bridgeReport["BridgeFactor"]];
Print["Bridge residual: ", InputForm[bridgeReport["BridgeResidual"]]];
Print["Runtime route kind: ", record["IntegratedResultKind"]];
Print["Runtime open masters: ", record["OpenMasterValuesQ"]];
Print["Runtime residual: ", InputForm[runtimeResidual]];
Print["Runtime match: ", runtimeMatchQ];

If[
  record["IntegratedResultKind"] =!= "ClosedDerivedMX30Series" ||
  record["OpenMasterValuesQ"] =!= False ||
  !runtimeMatchQ,
  Exit[1];
];

Print["massiveA30 integrated runtime bridge passed."];
Exit[0];
