(* Regression: the A31 release reference is explicit, complete, and separate
   from the route's internal target accessor. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];
Get[FileNameJoin[{repoRoot, "dev", "a31_literature_reference.wl"}]];

metadata = A31LiteratureReferenceMetadata[];
paperTargets = A31LiteratureReferenceTargets[0];
runtimeTargets = A31IntegratedAntennaTargets[0];
perturbedNf = paperTargets[[3]] + 1;

report = <|
  "Regression" -> "A31ExternalLiteratureContract",
  "Source" -> metadata["Source"],
  "Equations" -> metadata["Equations"],
  "HasThreePaperFacingComponents" -> Length[paperTargets] === 3,
  "PaperReferenceMatchesCurrentPublicConvention" ->
    And @@ (TrueQ[# === 0]& /@
      (FullSimplify /@ (paperTargets - runtimeTargets))),
  "NfPerturbationIsRejected" ->
    !TrueQ[A31LiteratureReferenceAgreementQ[perturbedNf, Nf, 0]],
  "Passed" -> And @@ {
    metadata["Source"] === "arXiv:hep-ph/0505111v3",
    metadata["Equations"]["IntegratedAntennaDefinition"] === "(2.35)",
    metadata["Equations"]["Leading"] === "(5.18)",
    metadata["Equations"]["Subleading"] === "(5.19)",
    metadata["Equations"]["Nf"] === "(5.20)",
    Length[paperTargets] === 3,
    And @@ (TrueQ[# === 0]& /@
      (FullSimplify /@ (paperTargets - runtimeTargets))),
    !TrueQ[A31LiteratureReferenceAgreementQ[perturbedNf, Nf, 0]]
    }
  |>;

Print[report];
Exit[If[TrueQ[report["Passed"]], 0, 1]];
