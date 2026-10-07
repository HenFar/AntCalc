(*
  Regression checks for the stable ReturnMasterCombination provenance object.

  Fast contract check:
    WolframKernel -script dev/regression_master_combination_view.wl

  Include the actual massive open-master public route:
    ANTCALC_MASTER_ROUTE=massive WolframKernel -script dev/regression_master_combination_view.wl
*)

packageRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{packageRoot, "AntennaPipeline.wl"}]];

(* The MX30 branch is selected by profile metadata.  Abstract placeholders
   keep this fast contract test independent of LiteRed initialisation. *)
runtimeCombination = 3 runtimeMaster1 - 2 runtimeMaster2;
mixedRuntimeCombination =
  -4 (d - 3) (d (eps - 2) - 4 eps + 4) LiteRed`j[NLOBasis123, 1, 1, 1, 0, 0] /
    ((d - 4)^2 q2);
publicMixedCombination = PublicMasterCombinationDisplayForm[mixedRuntimeCombination];
diagnostics = <|
  "quarkMass" -> mQ,
  "BackendDiagnostics" -> <|
    "Profile" -> <|"Key" -> {A, 3, 0}, "MassSymbol" -> mQ,
      "BasisFamily" -> "MX30"|>,
    "RawMasterCombination" -> runtimeCombination
  |>
|>;
view = MasterCombinationView[diagnostics];
attached = AttachMasterCombinationView[diagnostics];
checks = <|
  "RuntimeExpressionIsUnchanged" -> view["Expression"] === runtimeCombination,
  "MassiveBasisIsNamed" -> view["BasisFamily"] === "MX30Basis123",
  "MassiveDefinitionsAreExplicit" ->
    KeyExistsQ[view["MasterDefinitions"], "J11100"] &&
    KeyExistsQ[view["MasterDefinitions"], "J21100"],
  "BridgeIsExplicitlyProvisional" ->
    view["BridgeStatus"] === "ProvisionalSecondMasterBridge",
  "AttachmentPreservesView" -> attached["MasterCombinationView"] === view,
  "PublicDisplayUsesOnlyEpsilon" ->
    FreeQ[publicMixedCombination, d | eps] && !FreeQ[publicMixedCombination, Epsilon],
  "RawBackendCombinationIsUntouched" -> mixedRuntimeCombination ===
    -4 (d - 3) (d (eps - 2) - 4 eps + 4) LiteRed`j[NLOBasis123, 1, 1, 1, 0, 0] /
      ((d - 4)^2 q2),
  "OneShotRouteHasNoIndependentCache" ->
    !MemberQ[$StoredResultRouteKinds, "BuildAndIntegrateAntenna"]
|>;
observations = <||>;

If[Environment["ANTCALC_MASTER_ROUTE"] === "massive",
  routeResult = BuildAndIntegrateAntenna[A, 3, 0, quarkMass -> mQ,
    ReturnMasterCombination -> True, ReturnDiagnostics -> True,
    UseStoredResults -> False, StoreResults -> False];
  checks["MassiveRouteReturnedDiagnostics"] = MatchQ[routeResult, {_, _Association}];
  If[TrueQ[checks["MassiveRouteReturnedDiagnostics"]],
    routeView = routeResult[[2, "MasterCombinationView"]];
    checks["MassiveRouteExpressionMatchesView"] =
      routeResult[[1]] === routeView["Expression"];
    observations["MassiveRouteBridgeStatus"] =
      Lookup[routeView, "BridgeStatus", Missing["NotAvailable"]];
    checks["MassiveRouteKeepsProvisionalStatus"] =
      routeView["BridgeStatus"] === "ProvisionalSecondMasterBridge";
    routeBasisSummary = MasterCombinationBasisSummary[routeResult[[1]], routeResult[[2]]];
    checks["MassiveRouteDiscoversCutPropagators"] =
      routeBasisSummary["MX30Basis123", "CutPropagatorPositions"] === {1, 2, 3};
  ];
  ];

If[Environment["ANTCALC_MASTER_ROUTE"] === "massless",
  routeResult = BuildAndIntegrateAntenna[A, 3, 0,
    ReturnMasterCombination -> True, ReturnDiagnostics -> True,
    UseStoredResults -> False, StoreResults -> False];
  checks["MasslessRouteReturnedDiagnostics"] = MatchQ[routeResult, {_, _Association}];
  If[TrueQ[checks["MasslessRouteReturnedDiagnostics"]],
    checks["MasslessRouteReturnsLiteRedCombination"] =
      !FreeQ[routeResult[[1]], _LiteRed`j];
    checks["MasslessRouteCollectsRepeatedMasterTerms"] =
      Length[Cases[routeResult[[1]], _LiteRed`j, Infinity]] === 1;
    checks["MasslessRouteMarksMasterEndpoint"] =
      routeResult[[2, "RequestedResultKind"]] === "MasterCombination";
    routeBasisSummary = MasterCombinationBasisSummary[routeResult[[1]], routeResult[[2]]];
    checks["MasslessRouteDiscoversCutPropagators"] =
      routeBasisSummary["NLOBasis123", "CutPropagatorPositions"] === {1, 2, 3};
    checks["MasslessRouteDerivesInvariantAliases"] =
      routeBasisSummary["NLOBasis123", "PropagatorDisplayAliases"] ===
        {"p1^2", "p2^2", "p3^2", "s13", "s23"};
  ];
];

Print[ExportString[<|"Regression" -> "MasterCombinationView",
  "Checks" -> checks, "Observations" -> observations,
  "Passed" -> And @@ Values[checks]|>, "JSON", "Compact" -> True]];
Quit[If[And @@ Values[checks], 0, 1]];
