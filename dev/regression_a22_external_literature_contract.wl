(* Regression: the release-facing A22 source contract is explicit, complete,
   and independent of the route's internal diagnostic-target accessor. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];
Get[FileNameJoin[{repoRoot, "dev", "a22_literature_reference.wl"}]];

metadata = A22LiteratureReferenceMetadata[];
paperTargets = A22LiteratureReferenceTargets[0];
runtimeResult = BuildAndIntegrateAntenna[A, 2, 2,
  ExpansionOrder -> 0, UseStoredResults -> False, StoreResults -> False];
perturbedLeading = paperTargets[[1]] + 1;

report = <|
  "Regression" -> "A22ExternalLiteratureContract",
  "Source" -> metadata["Source"],
  "Equations" -> metadata["Equations"],
  "HasFourPaperFacingComponents" -> Length[paperTargets] === 4,
  "RuntimeBuildReturnsAllComponents" -> ListQ[runtimeResult] &&
    Length[runtimeResult] === 4,
  "RuntimeBuildMatchesDevelopmentTargets" ->
    TrueQ[A22LiteratureReferenceAgreementQ[runtimeResult, 0]],
  "LeadingPerturbationIsRejected" ->
    !TrueQ[A22LiteratureReferenceAgreementQ[perturbedLeading, Leading, 0]],
  "Passed" -> And @@ {
    metadata["Source"] === "arXiv:hep-ph/0403057v2",
    metadata["Equations"]["TwoLoopTreeDefinition"] === "(4.8)",
    metadata["Equations"]["TwoLoopTreeColourBrackets"] === "(4.9)",
    metadata["Equations"]["OneLoopSelfInterference"] ===
      "(4.10) target; compare with arXiv:2211.08446v2 Eq. (B.7)",
    Length[paperTargets] === 4,
    ListQ[runtimeResult] && Length[runtimeResult] === 4,
    TrueQ[A22LiteratureReferenceAgreementQ[runtimeResult, 0]],
    !TrueQ[A22LiteratureReferenceAgreementQ[perturbedLeading, Leading, 0]]
    }
  |>;

Print[report];
Exit[If[TrueQ[report["Passed"]], 0, 1]];
