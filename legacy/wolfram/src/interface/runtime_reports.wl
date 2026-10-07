(* ::Section:: *)
(* Runtime convention and profile reports *)

(* Communicates with:
   - AntennaPipeline.wl, which loads this file after the public interfaces and
     profile registry are available.
   - src/core/setup.wl, whose shared backend startup choices are surfaced here
     as inspectable package state.
   - src/core/profiles.wl and src/routes/route_catalog.wl, whose metadata are
     assembled into route-facing summaries.

   Why this file exists:
   The README now documents the intended public contract, current
   implementation reality, and several convention-level caveats.  This file
   gives users and thesis readers a code-level way to inspect that same state
   without pretending unresolved physics questions are already configurable or
   fully settled. *)

AntennaPipelineConventionReport::usage =
  "AntennaPipelineConventionReport[] returns a structured report of package-wide public defaults, backend expectations, and current convention status notes.";

AntennaRouteProfileReport::usage =
  "AntennaRouteProfileReport[type, numFinalParticles, loopOrder] returns a structured report of the resolved build and integration metadata for one antenna route.";

AntennaRouteEnvironmentReport::usage =
  "AntennaRouteEnvironmentReport[type, numFinalParticles, loopOrder] returns a structured report of the effective build, integration, and one-shot pipeline defaults that govern one antenna route.";

NormalizeOptionAssociationKeys[assoc_Association] :=
  KeyMap[
    If[StringQ[#],
      #
      ,
      ToString[Unevaluated[#], InputForm]
    ]&,
    assoc
  ];

PublicOptionDefaultsAssociation[head_Symbol] :=
  NormalizeOptionAssociationKeys[Association[Options[head]]];

SelectPublicOptionDefaults[head_Symbol, keys_List] :=
  KeyTake[PublicOptionDefaultsAssociation[head], keys];

AssociationOrEmpty[expr_] :=
  If[AssociationQ[expr],
    expr
    ,
    <||>
  ];

SupportedMasslessReleaseRouteQ[key_] :=
  MemberQ[
    {
      {A, 2, 0},
      {A, 3, 0},
      {A, 2, 1},
      {A, 4, 0},
      {B, 4, 0},
      {C, 4, 0},
      {A, 3, 1},
      {A, 2, 2}
    },
    key
  ];

RouteMassHandlingProfile[key_] :=
  Switch[key,
    {A, 3, 0},
      <|
        "DefaultquarkMass" -> 0,
        "MassiveSupportStatus" -> "BetaMassiveA30Extension",
        "MassHandlingNote" -> "Massless A30 is supported; nonzero quarkMass selects the beta massive A30 extension."
      |>
    ,
    {D, 3, 0},
      <|
        "DefaultquarkMass" -> 0,
        "MassiveSupportStatus" -> "NotApplicable",
        "MassHandlingNote" -> "Nonzero quark masses are resolved through named route variants."
      |>
    ,
    _,
      <|
        "DefaultquarkMass" -> 0,
        "MassiveSupportStatus" -> "MasslessPublicDefault",
        "MassHandlingNote" -> "The supported public default is quarkMass -> 0."
      |>
  ];

BuildRouteEnvironmentResolution[key_List] :=
  Module[{buildProfile, reductionProfile, buildDefaults, massProfile,
     conventionProfile},
    buildProfile = AntennaProfile[key];
    reductionProfile = AssociationOrEmpty[AntennaReductionProfile[key]];
    buildDefaults = PublicOptionDefaultsAssociation[BuildAntenna];
    massProfile = RouteMassHandlingProfile[key];
    conventionProfile = Lookup[buildProfile, "ConventionProfile", <||>];
    <|
      "ResolvedDefaults" -> <|
        "quarkMass" -> massProfile["DefaultquarkMass"],
        "ApplyDimReg" -> Lookup[buildDefaults, "ApplyDimReg", True],
        "ReductionBackend" -> Lookup[reductionProfile, "DefaultBackend",
          Lookup[buildDefaults, "ReductionBackend", Automatic]],
        "AllowPrototypeTargets" -> Lookup[buildDefaults,
          "AllowPrototypeTargets", False],
        "UseSourceModelRoute" -> Lookup[buildDefaults,
          "UseSourceModelRoute", False]
      |>,
      "CachePolicy" -> <|
        "UseStoredResults" -> Lookup[buildDefaults, "UseStoredResults",
          False],
        "StoreResults" -> Lookup[buildDefaults, "StoreResults", False],
        "RefreshStoredResults" -> Lookup[buildDefaults,
          "RefreshStoredResults", False],
        "ResultsCacheRoot" -> Lookup[buildDefaults, "ResultsCacheRoot",
          Automatic]
      |>,
      "MassHandling" -> massProfile,
      "PrototypeRouting" -> <|
        "AllowPrototypeTargetsDefault" -> Lookup[buildDefaults,
          "AllowPrototypeTargets", False],
        "UseSourceModelRouteDefault" -> Lookup[buildDefaults,
          "UseSourceModelRoute", False],
        "ConventionStatus" -> Lookup[conventionProfile,
          "PrototypeExposureStatus", Missing["NotAvailable"]]
      |>,
      "ResolvedConventionProfile" -> conventionProfile
    |>
  ];

IntegrationRouteEnvironmentResolution[key_List] :=
  Module[{integrationProfile, integrationDefaults, massProfile,
     conventionProfile},
    integrationProfile = AssociationOrEmpty[AntennaIntegrationProfile[key]];
    integrationDefaults = PublicOptionDefaultsAssociation[IntegrateAntenna];
    massProfile = RouteMassHandlingProfile[key];
    conventionProfile = Lookup[integrationProfile, "ConventionProfile",
      <||>];
    <|
      "ResolvedDefaults" -> <|
        "quarkMass" -> massProfile["DefaultquarkMass"],
        "DefaultBackend" -> Lookup[integrationProfile, "DefaultBackend",
          IBP],
        "PaVeEvaluation" -> Lookup[integrationDefaults, "PaVeEvaluation",
          "PaXEvaluate"],
        "ExpansionOrder" -> Lookup[integrationProfile, "ExpansionOrder",
          Lookup[integrationDefaults, "ExpansionOrder", Automatic]],
        "KinematicScale" -> Lookup[integrationProfile, "KinematicScale",
          Lookup[integrationDefaults, "KinematicScale", q2]],
        "NormalizeKinematicScale" -> Lookup[integrationDefaults,
          "NormalizeKinematicScale", True],
        "ApplyFeynCalcMS" -> Lookup[integrationDefaults,
          "ApplyFeynCalcMS", True],
        "ApplyDimReg" -> Lookup[integrationDefaults, "ApplyDimReg", True],
        "BasisFamily" -> Lookup[integrationProfile, "BasisFamily",
          Lookup[integrationDefaults, "BasisFamily", Automatic]],
        "BasisRoot" -> Lookup[integrationDefaults, "BasisRoot", Automatic],
        "GenerateMissingBases" -> Lookup[integrationDefaults,
          "GenerateMissingBases", False]
      |>,
      "CachePolicy" -> <|
        "UseStoredResults" -> Lookup[integrationDefaults,
          "UseStoredResults", False],
        "StoreResults" -> Lookup[integrationDefaults, "StoreResults",
          False],
        "RefreshStoredResults" -> Lookup[integrationDefaults,
          "RefreshStoredResults", False],
        "ResultsCacheRoot" -> Lookup[integrationDefaults,
          "ResultsCacheRoot", Automatic]
      |>,
      "MassHandling" -> massProfile,
      "ResolvedConventionProfile" -> conventionProfile
    |>
  ];

BuildAndIntegrateRouteEnvironmentResolution[key_List] :=
  Module[{routeDefaults, buildResolution, integrationResolution},
    routeDefaults =
      PublicOptionDefaultsAssociation[BuildAndIntegrateAntenna];
    buildResolution = BuildRouteEnvironmentResolution[key];
    integrationResolution = IntegrationRouteEnvironmentResolution[key];
    <|
      "ResolvedDefaults" -> <|
        "quarkMass" -> Lookup[routeDefaults, "quarkMass", 0],
        "ApplyFeynCalcMS" -> Lookup[routeDefaults, "ApplyFeynCalcMS",
          True],
        "PaVeEvaluation" -> Lookup[routeDefaults, "PaVeEvaluation",
          "PaXEvaluate"],
        "ExpansionOrder" -> Lookup[
          integrationResolution["ResolvedDefaults"], "ExpansionOrder",
          Lookup[routeDefaults, "ExpansionOrder", Automatic]],
        "KinematicScale" -> Lookup[
          integrationResolution["ResolvedDefaults"], "KinematicScale",
          Lookup[routeDefaults, "KinematicScale", q2]],
        "NormalizeKinematicScale" -> Lookup[routeDefaults,
          "NormalizeKinematicScale", True],
        "ApplyDimReg" -> Lookup[routeDefaults, "ApplyDimReg", True],
        "BasisFamily" -> Lookup[
          integrationResolution["ResolvedDefaults"], "BasisFamily",
          Lookup[routeDefaults, "BasisFamily", Automatic]],
        "BasisRoot" -> Lookup[routeDefaults, "BasisRoot", Automatic],
        "GenerateMissingBases" -> Lookup[routeDefaults,
          "GenerateMissingBases", False],
        "AllowPrototypeTargets" -> Lookup[
          buildResolution["ResolvedDefaults"], "AllowPrototypeTargets",
          False],
        "UseSourceModelRoute" -> Lookup[
          buildResolution["ResolvedDefaults"], "UseSourceModelRoute",
          False]
      |>,
      "CachePolicy" -> <|
        "UseStoredResults" -> Lookup[routeDefaults, "UseStoredResults",
          False],
        "StoreResults" -> Lookup[routeDefaults, "StoreResults", False],
        "RefreshStoredResults" -> Lookup[routeDefaults,
          "RefreshStoredResults", False],
        "ResultsCacheRoot" -> Lookup[routeDefaults, "ResultsCacheRoot",
          Automatic]
      |>,
      "MassHandling" -> buildResolution["MassHandling"],
      "PipelineInterpretation" -> "BuildAndIntegrateAntenna inherits build-side route-selection defaults and integration-side backend defaults, then applies the one-shot top-level option surface over them."
    |>
  ];

RouteContractStatus[key_] :=
  Module[{buildProfile, integrationProfile, buildConvention,
     integrationConvention, notes},
    buildProfile = AntennaProfile[key];
    integrationProfile = AntennaIntegrationProfile[key];
    buildConvention = Lookup[buildProfile, "ConventionProfile", <||>];
    integrationConvention = Lookup[integrationProfile, "ConventionProfile",
      <||>];
    notes = DeleteCases[
      {
        If[StringQ[Lookup[buildConvention, "CurrentImplementationNote",
            Missing["NotAvailable"]]],
          buildConvention["CurrentImplementationNote"],
          Nothing
        ],
        If[StringQ[Lookup[integrationConvention,
            "CurrentImplementationNote", Missing["NotAvailable"]]],
          integrationConvention["CurrentImplementationNote"],
          Nothing
        ],
        If[Lookup[buildProfile, "ImplementationStatus", Missing["NotAvailable"]] === "ExperimentalSourceProduction",
          "Build profile note: this route still carries an experimental-source-production marker internally.",
          Nothing
        ],
        If[Lookup[integrationProfile, "ImplementationStatus", Missing["NotAvailable"]] === "ScaffoldOnly",
          "Integration profile note: the registry still labels this route scaffolded even though the package exposes a public stitched route around it.",
          Nothing
        ]
      },
      Nothing
    ];
    <|
      "SupportedMasslessReleaseRoute" -> SupportedMasslessReleaseRouteQ[key],
      "BuildImplementationStatus" -> Lookup[buildProfile, "ImplementationStatus", "Implemented"],
      "IntegrationImplementationStatus" -> Lookup[integrationProfile, "ImplementationStatus", "Implemented"],
      "Notes" -> notes
    |>
  ];

AntennaPipelineConventionReport[] :=
  Module[{model},
    model = AntennaPipelineConventionModel[];
    <|
    "GlobalDefaults" -> AntennaPipelineDefaults[],
    "PublicDefaultOptions" -> <|
      "BuildAntenna" ->
        SelectPublicOptionDefaults[
          BuildAntenna,
          {
            "quarkMass",
            "ApplyDimReg",
            "ReductionBackend",
            "AllowPrototypeTargets",
            "UseSourceModelRoute",
            "UseStoredResults",
            "StoreResults",
            "ResultsCacheRoot",
            "RefreshStoredResults"
          }
        ],
      "IntegrateAntenna" ->
        SelectPublicOptionDefaults[
          IntegrateAntenna,
          {
            "ApplyFeynCalcMS",
            "quarkMass",
            "PaVeEvaluation",
            "ExpansionOrder",
            "KinematicScale",
            "NormalizeKinematicScale",
            "ApplyDimReg",
            "BasisFamily",
            "BasisRoot",
            "GenerateMissingBases",
            "UseStoredResults",
            "StoreResults",
            "ResultsCacheRoot",
            "RefreshStoredResults"
          }
        ],
      "BuildAndIntegrateAntenna" ->
        SelectPublicOptionDefaults[
          BuildAndIntegrateAntenna,
          {
            "ApplyFeynCalcMS",
            "quarkMass",
            "PaVeEvaluation",
            "ExpansionOrder",
            "KinematicScale",
            "NormalizeKinematicScale",
            "ApplyDimReg",
            "UseStoredResults",
            "StoreResults",
            "ResultsCacheRoot",
            "RefreshStoredResults"
          }
        ],
      "BuildRRatio" ->
        SelectPublicOptionDefaults[
          BuildRRatio,
          {
            "quarkMass",
            "UseStoredResults",
            "StoreResults",
            "ResultsCacheRoot",
            "RefreshStoredResults",
            "ResultForm"
          }
        ],
      "TObject" ->
        SelectPublicOptionDefaults[
          TObject,
          {
            "quarkMass",
            "ExpansionOrder",
            "UseStoredResults",
            "StoreResults",
            "ResultsCacheRoot",
            "RefreshStoredResults"
          }
        ]
    |>,
    "BackendEnvironment" -> <|
      "ValidatedFeynCalcVersion" -> "10.2.1",
      "ValidatedToolchain" -> <|
        "FeynCalc" -> "10.2.1",
        "FeynArts" -> "3.12 (27 Mar 2025)",
        "FeynHelpers" -> "2.0.0",
        "FeynCalcLegacy" -> "1.0.0",
        "LiteRed2" -> "2.025 beta"
        |>,
      "StartupAddOns" -> $LoadAddOns,
      "RenameFeynCalcObjects" -> $RenameFeynCalcObjects
    |>,
    "ConventionState" -> Join[
      model,
      <|
        "PrototypeSurface" -> Join[
          Lookup[model, "PrototypeSurface", <||>],
          <|
            "AllowPrototypeTargetsDefault" -> Lookup[
              PublicOptionDefaultsAssociation[BuildAntenna],
              "AllowPrototypeTargets", False],
            "UseSourceModelRouteDefault" -> Lookup[
              PublicOptionDefaultsAssociation[BuildAntenna],
              "UseSourceModelRoute", False]
          |>
        ],
        "PaVeBridge" -> Join[
          Lookup[model, "PaVeBridge", <||>],
          <|
            "DefaultPaVeEvaluation" -> Lookup[
              PublicOptionDefaultsAssociation[IntegrateAntenna],
              "PaVeEvaluation", "PaXEvaluate"],
            "ApplyFeynCalcMSDefault" -> Lookup[
              PublicOptionDefaultsAssociation[IntegrateAntenna],
              "ApplyFeynCalcMS", True]
          |>
        ],
        "ScaleNormalization" -> Join[
          Lookup[model, "ScaleNormalization", <||>],
          <|
            "PublicKinematicScale" -> Lookup[
              PublicOptionDefaultsAssociation[IntegrateAntenna],
              "KinematicScale", q2],
            "NormalizeKinematicScaleDefault" -> Lookup[
              PublicOptionDefaultsAssociation[IntegrateAntenna],
              "NormalizeKinematicScale", True]
          |>
        ]
      |>
    ]
  |>];

AntennaRouteProfileReport[type_, numFinalParticles_Integer,
   loopOrder_Integer] :=
  AntennaRouteProfileReport[{type, numFinalParticles, loopOrder}];

AntennaRouteProfileReport[key_List] :=
  Module[{buildProfile, reductionProfile, integrationProfile,
     buildDefaults, integrationDefaults},
    buildProfile = AntennaProfile[key];
    reductionProfile = AssociationOrEmpty[AntennaReductionProfile[key]];
    integrationProfile = AssociationOrEmpty[AntennaIntegrationProfile[key]];
    buildDefaults = PublicOptionDefaultsAssociation[BuildAntenna];
    integrationDefaults = PublicOptionDefaultsAssociation[IntegrateAntenna];
    <|
      "Key" -> key,
      "Name" -> Lookup[buildProfile, "Name", Missing["NotAvailable"]],
      "BuildProfile" -> buildProfile,
      "BuildReductionProfile" -> reductionProfile,
      "IntegrationProfile" -> integrationProfile,
      "Verification" -> AntennaRouteVerificationMetadata[key],
      "ResolvedRouteDefaults" -> <|
        "BuildAntenna" -> <|
          "quarkMass" -> Lookup[buildDefaults, "quarkMass", 0],
          "ApplyDimReg" -> Lookup[buildDefaults, "ApplyDimReg", True],
          "ReductionBackend" -> Lookup[reductionProfile, "DefaultBackend",
            Lookup[buildDefaults, "ReductionBackend", Automatic]]
        |>,
        "IntegrateAntenna" -> <|
          "quarkMass" -> Lookup[integrationDefaults, "quarkMass", 0],
          "PaVeEvaluation" -> Lookup[integrationDefaults, "PaVeEvaluation",
            "PaXEvaluate"],
          "ExpansionOrder" -> Lookup[integrationProfile, "ExpansionOrder",
            Lookup[integrationDefaults, "ExpansionOrder", Automatic]],
          "KinematicScale" -> Lookup[integrationProfile, "KinematicScale",
            Lookup[integrationDefaults, "KinematicScale", q2]],
          "NormalizeKinematicScale" -> Lookup[integrationDefaults,
            "NormalizeKinematicScale", True],
          "ApplyDimReg" -> Lookup[integrationDefaults, "ApplyDimReg",
            True],
          "DefaultBackend" -> Lookup[integrationProfile, "DefaultBackend",
            IBP]
        |>
      |>,
      "RouteStories" -> <|
        "Build" -> BuildRouteStory[key],
        "Integration" -> IntegrationRouteStory[key]
      |>,
      "ContractStatus" -> RouteContractStatus[key]
    |>
  ];

AntennaRouteEnvironmentReport[type_, numFinalParticles_Integer,
   loopOrder_Integer] :=
  AntennaRouteEnvironmentReport[{type, numFinalParticles, loopOrder}];

AntennaRouteEnvironmentReport[key_List] :=
  <|
    "Key" -> key,
    "Name" -> Lookup[AntennaProfile[key], "Name", Missing["NotAvailable"]],
    "GlobalDefaults" -> AntennaPipelineDefaults[],
    "BuildAntenna" -> BuildRouteEnvironmentResolution[key],
    "IntegrateAntenna" -> IntegrationRouteEnvironmentResolution[key],
    "BuildAndIntegrateAntenna" ->
      BuildAndIntegrateRouteEnvironmentResolution[key],
    "ContractStatus" -> RouteContractStatus[key]
  |>;
