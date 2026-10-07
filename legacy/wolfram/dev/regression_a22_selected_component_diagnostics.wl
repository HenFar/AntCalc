(* Regression: a selected A22 component must be checked against its own target,
   not against unavailable sibling contributions preserved in the full internal
   build payload. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

targets = A22TTermTargets[0];
payload = {targets[[1]], targets[[2]], targets[[3]], $Failed};
brevePayload = {$Failed, $Failed, $Failed, targets[[4]]};
profile = AntennaIntegrationProfile[{A, 2, 2}];

leadingDiagnostics = IntegratedAntennaDiagnostics[
  {A, 2, 2}, Missing["UnintegratedNotNeeded"], payload, profile,
  <|"TTerms" -> payload, "ExpansionOrder" -> 0,
    "SelectedComponent" -> Leading, "BuildComponent" -> Leading|>
];

allDiagnostics = IntegratedAntennaDiagnostics[
  {A, 2, 2}, Missing["UnintegratedNotNeeded"], payload, profile,
  <|"TTerms" -> payload, "ExpansionOrder" -> 0,
    "SelectedComponent" -> All, "BuildComponent" -> All|>
];

breveDiagnostics = IntegratedAntennaDiagnostics[
  {A, 2, 2}, Missing["UnintegratedNotNeeded"], brevePayload, profile,
  <|"TTerms" -> brevePayload, "ExpansionOrder" -> 0,
    "SelectedComponent" -> Breve, "BuildComponent" -> Breve|>
];

report = <|
  "Regression" -> "A22SelectedComponentDiagnostics",
  "LeadingTTermResidualIsZero" ->
    TrueQ[leadingDiagnostics["TTermResidualIsZero"]],
  "LeadingIntegratedResidualIsZero" ->
    TrueQ[leadingDiagnostics["IntegratedAntennaResidualIsZero"]],
  "LeadingAggregateTTermResidualsAreZero" ->
    TrueQ[leadingDiagnostics["TTermResidualsAreZero"]],
  "LeadingAggregateIntegratedResidualsAreZero" ->
    TrueQ[leadingDiagnostics["IntegratedAntennaResidualsAreZero"]],
  "BreveTTermResidualIsZero" ->
    TrueQ[breveDiagnostics["TTermResidualIsZero"]],
  "BreveIntegratedResidualIsZero" ->
    TrueQ[breveDiagnostics["IntegratedAntennaResidualIsZero"]],
  "AllComponentsStillRejectUnavailableSibling" ->
    !TrueQ[allDiagnostics["TTermResidualsAreZero"]],
  "Passed" -> And @@ {
    TrueQ[leadingDiagnostics["TTermResidualIsZero"]],
    TrueQ[leadingDiagnostics["IntegratedAntennaResidualIsZero"]],
    TrueQ[leadingDiagnostics["TTermResidualsAreZero"]],
    TrueQ[leadingDiagnostics["IntegratedAntennaResidualsAreZero"]],
    TrueQ[breveDiagnostics["TTermResidualIsZero"]],
    TrueQ[breveDiagnostics["IntegratedAntennaResidualIsZero"]],
    !TrueQ[allDiagnostics["TTermResidualsAreZero"]]
  }
|>;

Print[report];
Exit[If[TrueQ[report["Passed"]], 0, 1]];
