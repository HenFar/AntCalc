scriptDirectory = DirectoryName[$InputFileName];
repoRoot = DirectoryName[DirectoryName[scriptDirectory]];

massiveA30ValidationExit[code_Integer] :=
  If[TrueQ[$MassiveA30RunAll],
    Throw[code, $MassiveA30ValidationTag]
    ,
    Exit[code]
  ];

If[!ValueQ[$AntennaPipelineRoot],
  Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];
];

Get[FileNameJoin[{repoRoot, "dev", "massiveA30_sources", "index.wl"}]];
Get[FileNameJoin[{repoRoot, "masterIntegrals", "MX30I1.wl"}]];
Get[FileNameJoin[{repoRoot, "masterIntegrals", "MX30I2.wl"}]];

integratedSource = MassiveA30IntegratedSource[];
integratedPaper = MassiveA30IntegratedPaperConvention[];
integratedPackage = MassiveA30IntegratedPackageConventionCandidate[];
bridgeReport = MassiveA30IntegratedBridgeReport[];
basisRelation = MassiveA30IntegratedPaperToRuntimeBasisRelation[];
runtimeTarget = MassiveA30IntegratedRuntimeSeries[mQ, 0, True];
publicRecord =
  BuildAndIntegrateAntenna[
    A, 3, 0,
    quarkMass -> mQ,
    ExpansionOrder -> 0,
    ReturnRecord -> True,
    UseStoredResults -> False,
    StoreResults -> False,
    DetailedTimingDiagnostics -> False
  ];
publicRuntimeResidual =
  Together[publicRecord["Result"] - runtimeTarget] // FullSimplify;

Print["massiveA30 integrated paper-match"];

sourceEncodedQ =
  integratedSource["Status"] =!= "NotYetEncoded" &&
  !MatchQ[integratedPaper, Missing["NotYetEncoded"]];

bridgeEncodedQ =
  integratedPackage =!= Missing["NotYetEncoded"] &&
  TrueQ[bridgeReport["BridgeResidual"] === 0];

runtimeMatchQ =
  publicRecord["IntegratedResultKind"] === "ClosedDerivedMX30Series" &&
  publicRecord["OpenMasterValuesQ"] === False &&
  TrueQ[publicRuntimeResidual === 0];
basisRelationEncodedQ =
  AssociationQ[basisRelation] &&
  basisRelation["I2Coefficient"] =!= 0 &&
  basisRelation["Relation"] =!= $Failed;

mx30ReportsPresentQ =
  Length[DownValues[MasterIntegralMX30I1Data]] > 0 &&
  Length[DownValues[MasterIntegralMX30I2Data]] > 0;

Print["  integrated source encoded: ", sourceEncodedQ];
Print["  source section: ", integratedSource["SourceSection"]];
Print["  bridge encoded: ", bridgeEncodedQ];
Print["  bridge factor: ", bridgeReport["BridgeFactor"]];
Print["  basis relation encoded: ", basisRelationEncodedQ];
Print["  runtime master match: ", runtimeMatchQ];
Print["  MX30 reports present: ", mx30ReportsPresentQ];

If[!sourceEncodedQ,
  Print["  integrated paper source is still missing."];
  massiveA30ValidationExit[1];
];

If[!bridgeEncodedQ,
  Print["  integrated bridge residual is nonzero."];
  Print["  residual = ", InputForm[bridgeReport["BridgeResidual"]]];
  massiveA30ValidationExit[1];
];

If[!mx30ReportsPresentQ,
  Print["  MX30 master reports are not available."];
  massiveA30ValidationExit[1];
];

If[!basisRelationEncodedQ,
  Print["  warning: experimental paper-to-runtime basis relation is not available."];
];

If[!runtimeMatchQ,
  Print["  public runtime bridge did not reproduce the bridged target."];
  Print["  residual = ", InputForm[publicRuntimeResidual]];
  massiveA30ValidationExit[1];
];

Print["  build-side/thesis reconstruction gate: delegated to scripts 01-05 in this suite."];
Print["  MX30 master-definition gate: present and linked to the integrated target."];
Print["  integrated literature gate: passed through the public runtime bridge."];
Print["massiveA30 integrated paper-match passed."];
massiveA30ValidationExit[0];
