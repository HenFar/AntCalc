(* One fresh-kernel case of the supported massless release gate.  The shell
   driver starts this file in a separate kernel for every case. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];
Get[FileNameJoin[{repoRoot, "dev", "a31_literature_reference.wl"}]];
Get[FileNameJoin[{repoRoot, "dev", "a22_literature_reference.wl"}]];

ClearAll[caseLabel, cases, route, runTimed, buildRules, integrationRules,
  validationEvidence, evidenceStatus, validationContract, validationReport,
  validationStatus, comparisonReport, routeAcceptance, rratioAcceptance,
  massiveA30BetaAcceptance, a22BuildInvariantOnlyAcceptance, exactZeroQ,
  noRuntimeArtifactsQ, report,
  outputPath];

caseLabel = Environment["ANTCALC_ACCEPTANCE_CASE"];

cases = <|
  "A20" -> <|"Key" -> {A, 2, 0}, "Integration" -> False|>,
  "A21" -> <|"Key" -> {A, 2, 1}, "Integration" -> True|>,
  "A30" -> <|"Key" -> {A, 3, 0}, "Integration" -> True|>,
  (* The published A31 targets encoded below run through the finite term.
     Request that same public surface explicitly: the package default is
     ExpansionOrder -> 2, whose positive-epsilon coefficients are outside
     this release comparison. *)
  "A31All" -> <|"Key" -> {A, 3, 1}, "Integration" -> True,
    "IntegrationOptions" -> {ExpansionOrder -> 0}|>,
  "A22All" -> <|"Key" -> {A, 2, 2}, "Integration" -> True,
    "AcceptanceMode" -> "OneShotOnly"|>,
  "A22Leading" -> <|"Key" -> {A, 2, 2}, "Component" -> Leading,
    "Integration" -> True, "AcceptanceMode" -> "OneShotOnly"|>,
  "A22Subleading" -> <|"Key" -> {A, 2, 2}, "Component" -> Subleading,
    "Integration" -> True, "AcceptanceMode" -> "OneShotOnly"|>,
  "A22Nf" -> <|"Key" -> {A, 2, 2}, "Component" -> Nf,
    "Integration" -> True, "AcceptanceMode" -> "OneShotOnly"|>,
  "A22Breve" -> <|"Key" -> {A, 2, 2}, "Component" -> Breve,
    "Integration" -> True, "AcceptanceMode" -> "OneShotOnly"|>,
  "A40Leading" -> <|"Key" -> {A, 4, 0}, "Component" -> Leading,
    "Integration" -> True|>,
  "A40Subleading" -> <|"Key" -> {A, 4, 0}, "Component" -> Subleading,
    "Integration" -> True|>,
  "B40" -> <|"Key" -> {B, 4, 0}, "Integration" -> True|>,
  "C40" -> <|"Key" -> {C, 4, 0}, "Integration" -> True|>
  |>;

runTimed[thunk_] := Module[{seconds, value},
  (* Do not wrap a public route in Check[..., $Failed].  Check treats any
     emitted message as a failed computation, even where the route returns a
     valid result and diagnostics (for example the four-parton heavy-route
     advisory).  Public route failures are represented explicitly as $Failed
     and are classified by routeAcceptance below. *)
  {seconds, value} = AbsoluteTiming[Quiet[thunk[]]];
  <|"Seconds" -> N[seconds], "Value" -> value|>
  ];

buildRules[spec_Association] :=
  Join[{UseStoredResults -> False, StoreResults -> False},
    If[KeyExistsQ[spec, "Component"], {Component -> spec["Component"]}, {}]];

integrationRules[spec_Association] :=
  Join[buildRules[spec], Lookup[spec, "IntegrationOptions", {}]];

(*
  Evidence is deliberately declared by release case.  A completed route or an
  empty diagnostics association is never evidence of physics correctness.

  ExternalLiterature means that the required Boolean comes from a target with
  a documented literature/convention mapping.  InternalConsistency means that
  the route is checked only against its reduction/reconstruction contract: it
  may be healthy, but it is not eligible for a validated release pass.
*)
validationContract = <|
  "A20" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "PublicBuild",
    "Required" -> {"ExactMatchQ"}|>,
  "A21" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "PublicBuildAndIntegratedOutput",
    "Required" -> {"ExactMatchQ", "IntegratedResidualIsZero"}|>,
  "A30" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "PublicBuildAndIntegratedOutputThroughEpsilon0",
    "Required" -> {"ExactMatchQ", "IntegratedResidualIsZero"}|>,
  "A40Leading" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "PublicBuild;IntegrationComposition",
    "Required" -> {"A40ExactMatchQ", "tA40ExactMatchQ"}|>,
  "A40Subleading" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "PublicBuild;IntegrationComposition",
    "Required" -> {"A40ExactMatchQ", "tA40ExactMatchQ"}|>,
  "B40" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "PublicBuild;IntegrationComposition",
    "Required" -> {"ExactMatchQ"}|>,
  "C40" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "PublicBuild;IntegrationComposition",
    "Required" -> {"ExactMatchQ"}|>,
  "A31All" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "PublicIntegratedOutputThroughEpsilon0;PaperEquations5.18To5.20;RouteInternalTTermsRetainedAsNonReleaseDiagnostics",
    "Required" -> {"A31DirectExternalLiteratureAgreementQ",
      "A31OneShotExternalLiteratureAgreementQ"}|>,
  "A22All" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "FreshKernelCanonicalOneShotIntegratedTTermAndOutput;PaperEquations4.8To4.10",
    "Required" -> {"TTermResidualsAreZero",
      "IntegratedAntennaResidualsAreZero",
      "A22OneShotExternalLiteratureAgreementQ"}|>,
  "A22Leading" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "FreshKernelCanonicalOneShotIntegratedTTermAndOutput;PaperEquations4.8To4.10",
    "Required" -> {"TTermResidualsAreZero",
      "IntegratedAntennaResidualsAreZero",
      "A22OneShotExternalLiteratureAgreementQ"}|>,
  "A22Subleading" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "FreshKernelCanonicalOneShotIntegratedTTermAndOutput;PaperEquations4.8To4.10",
    "Required" -> {"TTermResidualsAreZero",
      "IntegratedAntennaResidualsAreZero",
      "A22OneShotExternalLiteratureAgreementQ"}|>,
  "A22Nf" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "FreshKernelCanonicalOneShotIntegratedTTermAndOutput;PaperEquations4.8To4.10",
    "Required" -> {"TTermResidualsAreZero",
      "IntegratedAntennaResidualsAreZero",
      "A22OneShotExternalLiteratureAgreementQ"}|>,
  "A22Breve" -> <|"Tier" -> "ExternalLiterature",
    "Scope" -> "FreshKernelCanonicalOneShotIntegratedTTermAndOutput;PaperEquations4.8To4.10",
    "Required" -> {"TTermResidualIsZero",
      "IntegratedAntennaResidualIsZero",
      "A22OneShotExternalLiteratureAgreementQ"}|>
  |>;

validationEvidence[diagnostics_, key_String] :=
  (* Associations do not reliably expose their internal Rule expressions to
     a generic Cases[..., Rule[...], Infinity] traversal. Match every nested
     association itself and perform the key lookup there. *)
  Cases[diagnostics,
    association_?AssociationQ :> Lookup[association, key, Nothing],
    {0, Infinity}
  ];

evidenceStatus[values_List] := Which[
  MemberQ[values, False], "Fail",
  MemberQ[values, True], "Pass",
  True, "Missing"
  ];

validationReport[case_String, diagnostics_] :=
  Module[{contract, required, observed, statuses},
    contract = Lookup[validationContract, case,
      <|"Tier" -> "NoDeclaredEvidence", "Scope" -> "None",
        "Required" -> {}|>];
    required = contract["Required"];
    observed = AssociationMap[validationEvidence[diagnostics, #] &, required];
    statuses = AssociationMap[evidenceStatus[observed[#]] &, required];
    <|"Tier" -> contract["Tier"], "Scope" -> contract["Scope"],
      "Required" -> required,
      "Observed" -> observed, "Checks" -> statuses|>
  ];

validationStatus[validation_Association] := Module[{checks, tier},
  checks = Values[validation["Checks"]];
  tier = validation["Tier"];
  Which[
    MemberQ[checks, "Fail"], "Failed",
    MemberQ[checks, "Missing"], "Unvalidated",
    tier === "ExternalLiterature", "Validated",
    tier === "InternalConsistency", "Unvalidated",
    True, "Unvalidated"
  ]
  ];

comparisonReport[left_, right_] :=
  If[SameQ[left, right],
    <|"Method" -> "ExactSameQ", "Passed" -> True|>,
    <|"Method" -> "ExactSameQ", "Passed" -> False|>
  ];

exactZeroQ[expr_] := TrueQ[Quiet[Check[Together[expr] === 0, False]]];

noRuntimeArtifactsQ[expr_] :=
  expr =!= $Failed && !MissingQ[expr] &&
    FreeQ[expr, HoldPattern[LiteRed`j[___]]] &&
    FreeQ[expr, l | l1 | l2 | p1 | p2] &&
    FreeQ[expr, FeynCalc`FeynAmpDenominator];

a31ExternalLiteratureEvidence[spec_Association, direct_, oneShot_] :=
  Module[{agreement},
    If[spec["Key"] =!= {A, 3, 1}, Return[<||>]];
    agreement = Function[value,
      Quiet[Check[
        ListQ[value] && Length[value] === 3 &&
          TrueQ[A31LiteratureReferenceAgreementQ[value, 0]],
        False]]
      ];
    <|
      "A31ExternalLiteratureReference" -> A31LiteratureReferenceMetadata[],
      "A31DirectExternalLiteratureAgreementQ" -> agreement[direct],
      "A31OneShotExternalLiteratureAgreementQ" -> agreement[oneShot]
      |>
    ];

a22ExternalLiteratureEvidence[spec_Association, direct_, oneShot_] :=
  Module[{component, agreement},
    If[spec["Key"] =!= {A, 2, 2}, Return[<||>]];
    component = Lookup[spec, "Component", All];
    agreement = Function[value,
      Quiet[Check[
        If[component === All,
          ListQ[value] && Length[value] === 4 &&
            TrueQ[A22LiteratureReferenceAgreementQ[value, 0]],
          value =!= $Failed &&
            TrueQ[A22LiteratureReferenceAgreementQ[value, component, 0]]
          ],
        False]]
      ];
    <|
      "A22ExternalLiteratureReference" -> A22LiteratureReferenceMetadata[],
      "A22DirectExternalLiteratureAgreementQ" -> agreement[direct],
      "A22OneShotExternalLiteratureAgreementQ" -> agreement[oneShot]
      |>
    ];

routeAcceptance[spec_Association] :=
  Module[{key, build, integrableBuild, directIntegration, oneShot, buildValue,
     buildDiagnostics, object, directValue, directDiagnostics, oneShotValue,
     oneShotDiagnostics, integrationQ, validation, status, comparison,
     externalEvidence, acceptanceMode,
     structuralPassQ, executionPassQ},
    key = spec["Key"];
    integrationQ = TrueQ[spec["Integration"]];
    acceptanceMode = Lookup[spec, "AcceptanceMode", "DirectAndOneShot"];
    (* A22's documented one-shot route is exactly its integrable build followed
       by IntegrateAntenna.  Re-running that same composition through a
       separately built object triples its uncached cost without introducing
       an independent physics path, and exceeds the release timeout. *)
    If[acceptanceMode === "OneShotOnly",
      oneShot = runTimed[Function[
        BuildAndIntegrateAntenna @@ Join[key, {ReturnDiagnostics -> True},
          integrationRules[spec]]]];
      If[MatchQ[oneShot["Value"], {_, _Association}],
        {oneShotValue, oneShotDiagnostics} = oneShot["Value"],
        oneShotValue = oneShot["Value"]; oneShotDiagnostics = <||>
      ];
      externalEvidence = Join[
        a31ExternalLiteratureEvidence[spec, $Failed, oneShotValue],
        a22ExternalLiteratureEvidence[spec, $Failed, oneShotValue]
      ];
      validation = validationReport[caseLabel,
        {oneShotDiagnostics, externalEvidence}];
      structuralPassQ = oneShotValue =!= $Failed;
      status = Which[
        !structuralPassQ, "Failed",
        validationStatus[validation] === "Failed", "Failed",
        validationStatus[validation] === "Validated", "Validated",
        True, "Unvalidated"
      ];
      Return[<|
        "Case" -> caseLabel, "Key" -> ToString[key, InputForm],
        "Component" -> ToString[Lookup[spec, "Component", All], InputForm],
        "AcceptanceMode" -> acceptanceMode,
        "Status" -> status,
        "ExecutionSucceeded" -> (structuralPassQ &&
          validationStatus[validation] =!= "Failed"),
        "PublicIntegration" -> <|"Seconds" -> oneShot["Seconds"],
          "Succeeded" -> structuralPassQ|>,
        "Comparison" -> <|"Method" -> "CanonicalOneShotRoute",
          "Passed" -> structuralPassQ|>,
        "ExternalLiterature" -> externalEvidence,
        "Validation" -> validation
      |>]
    ];
    build = runTimed[Function[
      BuildAntenna @@ Join[key, {ReturnDiagnostics -> True,
        RunPaperCheck -> True}, buildRules[spec]]]];
    If[MatchQ[build["Value"], {_, _Association}],
      {buildValue, buildDiagnostics} = build["Value"],
      buildValue = build["Value"]; buildDiagnostics = <||>
    ];
    If[!integrationQ,
      validation = validationReport[caseLabel, buildDiagnostics];
      status = If[buildValue === $Failed, "Failed", validationStatus[validation]];
      Return[<|
        "Case" -> caseLabel, "Key" -> ToString[key, InputForm],
        "Status" -> status,
        "Build" -> <|"Seconds" -> build["Seconds"], "Succeeded" -> buildValue =!= $Failed|>,
        "Validation" -> validation,
        "Comparison" -> <|"Method" -> "NotApplicable", "Passed" -> True|>
        |>]
    ];
    integrableBuild = runTimed[Function[
      BuildAntenna @@ Join[key, {IntegrableForm -> True,
        ReturnDiagnostics -> True}, buildRules[spec]]]];
    If[MatchQ[integrableBuild["Value"], {_, _Association}],
      object = First[integrableBuild["Value"]], object = $Failed
    ];
    directIntegration = runTimed[Function[
      If[object === $Failed, $Failed,
        IntegrateAntenna[object, ReturnDiagnostics -> True,
          Sequence @@ integrationRules[spec]]]]];
    If[ListQ[object] && ListQ[directIntegration["Value"]] &&
        And @@ (MatchQ[#, {_, _Association}]& /@ directIntegration["Value"]),
      directValue = First /@ directIntegration["Value"];
      directDiagnostics = <|"ComponentDiagnostics" -> Last /@ directIntegration["Value"]|>,
      If[MatchQ[directIntegration["Value"], {_, _Association}],
      {directValue, directDiagnostics} = directIntegration["Value"],
      directValue = directIntegration["Value"]; directDiagnostics = <||>
      ]
    ];
    oneShot = runTimed[Function[
      BuildAndIntegrateAntenna @@ Join[key, {ReturnDiagnostics -> True},
        integrationRules[spec]]]];
    If[MatchQ[oneShot["Value"], {_, _Association}],
      {oneShotValue, oneShotDiagnostics} = oneShot["Value"],
      oneShotValue = oneShot["Value"]; oneShotDiagnostics = <||>
    ];
    comparison = comparisonReport[directValue, oneShotValue];
    structuralPassQ = buildValue =!= $Failed && object =!= $Failed &&
      directValue =!= $Failed && oneShotValue =!= $Failed &&
      TrueQ[comparison["Passed"]];
    externalEvidence = Join[
      a31ExternalLiteratureEvidence[spec, directValue, oneShotValue],
      a22ExternalLiteratureEvidence[spec, directValue, oneShotValue]
      ];
    validation = validationReport[caseLabel,
      {buildDiagnostics, directDiagnostics, oneShotDiagnostics,
        externalEvidence}];
    executionPassQ = structuralPassQ && validationStatus[validation] =!= "Failed";
    status = Which[
      !structuralPassQ, "Failed",
      validationStatus[validation] === "Failed", "Failed",
      validationStatus[validation] === "Validated", "Validated",
      True, "Unvalidated"
      ];
    <|
      "Case" -> caseLabel, "Key" -> ToString[key, InputForm],
      "Component" -> ToString[Lookup[spec, "Component", All], InputForm],
      "Status" -> status,
      "ExecutionSucceeded" -> executionPassQ,
      "Build" -> <|"Seconds" -> build["Seconds"], "Succeeded" -> buildValue =!= $Failed|>,
      "IntegrableBuild" -> <|"Seconds" -> integrableBuild["Seconds"], "Succeeded" -> object =!= $Failed|>,
      "DirectIntegration" -> <|"Seconds" -> directIntegration["Seconds"], "Succeeded" -> directValue =!= $Failed|>,
      "OneShot" -> <|"Seconds" -> oneShot["Seconds"], "Succeeded" -> oneShotValue =!= $Failed|>,
      "Comparison" -> comparison,
      "ExternalLiterature" -> externalEvidence,
      "Validation" -> validation
      |>
  ];

massiveA30BetaAcceptance[] :=
  Module[{publicCall, publicRecord, publicResult, reference, paperRelation,
     paperI2, runtimeRules, runtimeRuleValues, checks, validation, passed},
    publicCall = runTimed[Function[
      BuildAndIntegrateAntenna[A, 3, 0,
        quarkMass -> mQ, ExpansionOrder -> 0, ReturnRecord -> True,
        UseStoredResults -> False, StoreResults -> False,
        DetailedTimingDiagnostics -> False]
      ]];
    publicRecord = publicCall["Value"];
    publicResult = Quiet[Check[publicRecord["Result"], $Failed]];
    reference = MassiveA30IntegratedRuntimeSeries[mQ, 0, True];
    paperRelation = MassiveA30IntegratedPaperToRuntimeBasisRelation[];
    paperI2 = MassiveA30IntegratedExperimentalPaperI2Relation[];
    runtimeRules = MassiveA30IntegratedRuntimeMasterRules[];
    runtimeRuleValues = Last /@ runtimeRules;
    checks = <|
      "PublicDerivedMX30RouteQ" -> TrueQ[
        Quiet[Check[publicRecord["IntegratedResultKind"], $Failed]] ===
          "ClosedDerivedMX30Series"],
      "PublicOrderZeroReferenceMatchQ" ->
        exactZeroQ[publicResult - reference],
      "PublicResultHasNoRuntimeArtifactsQ" ->
        noRuntimeArtifactsQ[publicResult],
      "DeclaredCutMeasureFactorQ" ->
        TrueQ[MassiveA30IntegratedCutMeasureFactor[] === -1/4],
      "PaperToRuntimeRelationAcceptedQ" ->
        AssociationQ[paperRelation] && TrueQ[paperRelation["AcceptedForRuntimeQ"]],
      "RuntimeMasterRuleValuesHaveNoRuntimeArtifactsQ" ->
        ListQ[runtimeRuleValues] && AllTrue[runtimeRuleValues, noRuntimeArtifactsQ],
      "PaperI2ReductionQ" -> TrueQ[paperI2["MatchQ"]]
      |>;
    passed = And @@ Values[checks];
    validation = <|
      "Tier" -> "DerivedMX30ClosureAndRuntimeReference",
      "Scope" -> "FreshKernelPublicOrderZeroAndInstalledMX30Closure;ForcedIBPRegressionAndEpsilonDepthCoveredByDedicatedChecks",
      "Required" -> Keys[checks], "Observed" -> AssociationMap[{checks[#]} &, Keys[checks]],
      "Checks" -> AssociationMap[If[checks[#], "Pass", "Fail"] &, Keys[checks]]
      |>;
    <|
      "Case" -> caseLabel, "Key" -> "{A, 3, 0}; quarkMass -> mQ",
      "Status" -> If[passed, "Validated", "Failed"],
      "ExecutionSucceeded" -> passed,
      "PublicIntegration" -> <|"Seconds" -> publicCall["Seconds"],
        "Succeeded" -> publicResult =!= $Failed|>,
      "Validation" -> validation
      |>
  ];

(* This is intentionally a build-only release check.  PaVe scalar functions
   are allowed in the public A22 representation; unreduced loop variables,
   LiteRed masters, and raw FeynCalc denominator objects are not. *)
a22BuildInvariantOnlyAcceptance[] :=
  Module[{buildCall, buildResult, diagnostics, artifactFreeQ, validation},
    buildCall = runTimed[Function[
      BuildAntenna[A, 2, 2, ReturnDiagnostics -> True,
        UseStoredResults -> False, StoreResults -> False]
      ]];
    If[MatchQ[buildCall["Value"], {_, _Association}],
      {buildResult, diagnostics} = buildCall["Value"],
      buildResult = buildCall["Value"]; diagnostics = <||>
    ];
    artifactFreeQ = buildResult =!= $Failed &&
      FreeQ[buildResult, l | l1 | l2 | HoldPattern[LiteRed`j[___]] |
        FeynCalc`FeynAmpDenominator];
    validation = <|
      "Tier" -> "PublicArtifactContract",
      "Scope" -> "FreshKernelPublicA22BuildContainsOnlyInvariantAndScalarMasterObjects",
      "Required" -> {"NoLoopRuntimeArtifactsQ"},
      "Observed" -> <|"NoLoopRuntimeArtifactsQ" -> {artifactFreeQ}|>,
      "Checks" -> <|"NoLoopRuntimeArtifactsQ" ->
        If[artifactFreeQ, "Pass", "Fail"]|>
      |>;
    <|
      "Case" -> caseLabel, "Key" -> "{A, 2, 2}; public build",
      "Status" -> If[artifactFreeQ, "Validated", "Failed"],
      "ExecutionSucceeded" -> artifactFreeQ,
      "PublicBuild" -> <|"Seconds" -> buildCall["Seconds"],
        "Succeeded" -> buildResult =!= $Failed|>,
      "Validation" -> validation
      |>
  ];

rratioAcceptance[order_] :=
  Module[{call, result, diagnostics, passed, referenceAgreement, checkStatus,
    validation, status},
    If[order === NNLO,
      call = runTimed[Function[
        BuildRRatioPhysicsValidationReport[
          "UseStoredResults" -> False,
          "StoreResults" -> False]]];
      result = call["Value"];
      passed = AssociationQ[result] &&
        Lookup[result, "ValidationStatus", "Fail"] === "Pass";
      validation = <|"Tier" -> "ExternalLiterature",
        "Scope" -> "RawLaurentPoleAndFiniteOutput",
        "Required" -> {"RawLaurentPoleAndFiniteTarget"},
        "Observed" -> <|"RawLaurentPoleAndFiniteTarget" -> {passed}|>,
        "Checks" -> <|"RawLaurentPoleAndFiniteTarget" ->
          If[passed, "Pass", "Fail"]|>|>;
      Return[<|"Case" -> caseLabel, "Key" -> "BuildRRatio[SMQCD]",
        "RequestedOrder" -> "NNLO",
        "Status" -> If[passed, "Validated", "Failed"],
        "BuildRRatio" -> <|"Seconds" -> call["Seconds"], "Succeeded" -> passed|>,
        "Comparison" -> <|"Method" -> "RawLaurentPoleAndFiniteTarget",
          "Passed" -> passed|>,
        "Validation" -> validation,
        "ValidationStatus" -> ToString[Lookup[result, "ValidationStatus",
          Missing["NotAvailable"]], InputForm]|>]
    ];
    call = runTimed[Function[
      BuildRRatio[SMQCD, quarkMass -> 0, maxOrder -> order,
        ReturnDiagnostics -> True, UseStoredResults -> False,
        StoreResults -> False]]];
    If[MatchQ[call["Value"], {_, _Association}],
      {result, diagnostics} = call["Value"], result = call["Value"]; diagnostics = <||>
    ];
    referenceAgreement = Lookup[diagnostics, "ReferenceAgreementQ",
      Missing["NotReported"]];
    passed = result =!= $Failed && TrueQ[referenceAgreement];
    checkStatus = Which[
      TrueQ[referenceAgreement], "Pass",
      referenceAgreement === False, "Fail",
      True, "Missing"
    ];
    validation = <|"Tier" -> "ExternalLiterature",
      "Scope" -> "ComputedFiniteCoefficient",
      "Required" -> {"ReferenceFiniteTargetAgreementQ"},
      "Observed" -> <|"ReferenceFiniteTargetAgreementQ" ->
        {referenceAgreement}|>,
      "Checks" -> <|"ReferenceFiniteTargetAgreementQ" -> checkStatus|>|>;
    status = If[result === $Failed, "Failed", validationStatus[validation]];
    <|"Case" -> caseLabel, "Key" -> "BuildRRatio[SMQCD]",
      "RequestedOrder" -> ToString[order, InputForm],
      "Status" -> status,
      "BuildRRatio" -> <|"Seconds" -> call["Seconds"], "Succeeded" -> result =!= $Failed|>,
      "IncludedIngredients" -> ToString[Lookup[diagnostics, "IncludedIngredients", Missing["NotAvailable"]], InputForm],
      "Comparison" -> <|"Method" -> "ComputedFiniteCoefficientVsReferenceTarget",
        "Passed" -> passed|>,
      "Validation" -> validation
      |>
  ];

report = Which[
  KeyExistsQ[cases, caseLabel], routeAcceptance[cases[caseLabel]],
  caseLabel === "A22BuildInvariantOnly", a22BuildInvariantOnlyAcceptance[],
  caseLabel === "A30MassiveBeta", massiveA30BetaAcceptance[],
  caseLabel === "RRatioLO", rratioAcceptance[LO],
  caseLabel === "RRatioNLO", rratioAcceptance[NLO],
  caseLabel === "RRatioNNLO", rratioAcceptance[NNLO],
  True, <|"Case" -> caseLabel, "Status" -> "Failed",
    "Reason" -> "UnknownAcceptanceCase"|>
  ];

report = Join[<|"GeneratedAt" -> DateString[{"ISODate", "T", "Time"}],
  "FreshKernel" -> True, "UseStoredResults" -> False,
  "StoreResults" -> False|>, report];

outputPath = Environment["ANTCALC_ACCEPTANCE_OUTPUT"];
If[StringQ[outputPath] && StringLength[StringTrim[outputPath]] > 0,
  Export[outputPath, report, "RawJSON"]
];
Print[ExportString[report, "RawJSON"]];
Exit[Switch[report["Status"],
  "Validated", 0,
  "Unvalidated", 3,
  _, 1
  ]];
