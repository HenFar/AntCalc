(* A31 epsilon-depth closure regression.

   The public A31 result at epsilon^0 has two distinct depth requirements:
   (1) lower-order counterterm/extraction inputs, and (2) the raw IBP master
   substitution.  This script performs one fresh cache-disabled public route
   computation and audits the latter from the normalized master coefficients.
   It deliberately does not use encoded A31 targets as an input to the audit. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

ClearAll[A31LaurentMinimumPower, A31MasterAvailabilityOrder,
  A31UsableMasterDiagnosticQ, A31MasterDiagnosticAssociations];

A31LaurentMinimumPower[expression_] :=
  Module[{eps, expanded, terms, powers},
    (* An absent master has exactly zero coefficient.  Mathematica assigns
       Exponent[0, eps] = -Infinity; this is not a non-Laurent coefficient and
       requires no terms from that master's series. *)
    If[expression === 0,
      Return[Infinity]
    ];
    eps = FeynCalc`Epsilon;
    expanded = Quiet[Check[Normal[Series[expression, {eps, 0, 0}]], $Failed]];
    If[expanded === $Failed,
      Return[Missing["SeriesFailed"]]
    ];
    terms = If[Head[Expand[expanded]] === Plus, List @@ Expand[expanded],
      {Expand[expanded]}];
    powers = Quiet[Check[Exponent[#, eps] & /@ terms, $Failed]];
    If[powers === $Failed || !AllTrue[powers, IntegerQ],
      Missing["NonLaurentCoefficient"]
      ,
      Min[powers]
    ]
  ];

(* qMI and qkMI are exact Gamma-function expressions in the runtime artifact.
   qsMI is supplied explicitly through epsilon^0, so it is the only finite
   availability boundary this audit needs to establish. *)
A31MasterAvailabilityOrder[qMI | qkMI] := Infinity;
A31MasterAvailabilityOrder[qsMI] := 0;
A31MasterAvailabilityOrder[master_] := Missing["UnknownMaster", master];

(* The public one-shot route deliberately collects diagnostics by component.
   Each component's backend payload owns the reduction profile and the raw
   master-mapped expression needed for this audit.  Prefer that explicit
   public structure: a recursive association scan can accidentally select a
   presentation or summary association when diagnostic nesting evolves. *)
A31UsableMasterDiagnosticQ[candidate_Association] :=
  Module[{profile, masterMapped},
    profile = Lookup[candidate, "Profile", Missing["ProfileUnavailable"]];
    masterMapped = Lookup[candidate, "MasterMappedExpression",
      Missing["MasterMappedExpressionUnavailable"]];
    AssociationQ[profile] && !MissingQ[masterMapped] && masterMapped =!= $Failed
  ];

A31UsableMasterDiagnosticQ[_] := False;

A31MasterDiagnosticAssociations[diagnostics_Association] :=
  Module[{componentDiagnostics, direct, fallback},
    componentDiagnostics = Lookup[diagnostics, "ComponentDiagnostics",
      Missing["ComponentDiagnosticsUnavailable"]];
    direct =
      If[AssociationQ[componentDiagnostics],
        Cases[Normal[componentDiagnostics],
          Rule[component_, componentDiagnostic_Association] :>
            With[{backend = Lookup[componentDiagnostic, "BackendDiagnostics",
                Missing["BackendDiagnosticsUnavailable"]]},
              If[A31UsableMasterDiagnosticQ[backend],
                Join[<|"Component" -> component|>, backend],
                Nothing
              ]
            ],
          {1}
        ],
        {}
      ];
    If[Length[direct] > 0,
      Return[direct]
    ];
    (* Compatibility fallback for legacy public wrappers.  It is deliberately
       secondary to the explicit component map above. *)
    fallback = DeleteDuplicatesBy[
      Cases[diagnostics,
        candidate_Association /; A31UsableMasterDiagnosticQ[candidate] :>
          candidate,
        Infinity
      ],
      ToString[Lookup[#, "MasterMappedExpression"], InputForm]&
    ];
    fallback
  ];

Module[{result, diagnostics, masterDiagnostics, masters, finalOrder,
   componentReports, componentPasses, lowerOrderLedger, report, passed},
  finalOrder = 0;
  result = BuildAndIntegrateAntenna[
    A, 3, 1,
    ReturnDiagnostics -> True,
    ExpansionOrder -> finalOrder,
    UseStoredResults -> False,
    StoreResults -> False,
    RefreshStoredResults -> False
  ];
  If[!MatchQ[result, {_, _Association}],
    Print[<|"Regression" -> "A31EpsilonDepth", "Passed" -> False,
      "FailureReason" -> "PublicRouteDidNotReturnDiagnostics",
      "Observed" -> result|>];
    Exit[1]
  ];
  diagnostics = result[[2]];
  masterDiagnostics = A31MasterDiagnosticAssociations[diagnostics];
  If[Length[masterDiagnostics] =!= 3,
    Print[<|"Regression" -> "A31EpsilonDepth", "Passed" -> False,
      "FailureReason" -> "ExpectedThreeMasterDiagnostics",
      "ObservedMasterDiagnosticCount" -> Length[masterDiagnostics]|>];
    Exit[1]
  ];
  masters = {qMI, qkMI, qsMI};
  componentReports = Association @ MapIndexed[
    Function[{componentDiagnostic, index},
      Module[{backend, profile, masterMapped, normalized},
        profile = Lookup[componentDiagnostic, "Profile",
          Missing["ProfileUnavailable"]];
        masterMapped = Lookup[componentDiagnostic,
          "MasterMappedExpression", Missing["MasterMappedExpressionUnavailable"]];
        If[!AssociationQ[profile] || MissingQ[masterMapped],
          ("Component" <> ToString[First[index]]) -> <|"SufficientQ" -> False,
            "FailureReason" -> "RequiredIBPDiagnosticsUnavailable",
            "Profile" -> profile,
            "MasterMappedExpression" -> masterMapped|>
          ,
          normalized = NormalizeIBPIntegratedResult[
            masterMapped, profile,
            ApplyFeynCalcMS -> True,
            KinematicScale -> q2,
            NormalizeKinematicScale -> True
          ]["NormalizedResult"];
          ("Component" <> ToString[First[index]]) -> Association @ Table[
            With[{coefficient = Collect[Coefficient[normalized, master],
                FeynCalc`Epsilon]},
              master -> Module[{minimumPower, requiredThrough, availableThrough},
                minimumPower = A31LaurentMinimumPower[coefficient];
                requiredThrough = Which[
                  minimumPower === Infinity, -Infinity,
                  IntegerQ[minimumPower], finalOrder - minimumPower,
                  True, Missing["Undetermined"]
                ];
                availableThrough = A31MasterAvailabilityOrder[master];
                <|"NormalizedCoefficientMinimumEpsilonPower" -> minimumPower,
                  "RequiredMasterSeriesThrough" -> requiredThrough,
                  "RuntimeMasterAvailableThrough" -> availableThrough,
                  "SufficientQ" -> TrueQ[minimumPower === Infinity] ||
                    TrueQ[availableThrough === Infinity] ||
                    (IntegerQ[requiredThrough] && IntegerQ[availableThrough] &&
                      availableThrough >= requiredThrough)|>
              ]
            ],
            {master, masters}
          ]
        ]
      ]
    ],
    masterDiagnostics
  ];
  componentPasses = Flatten @ Map[
    If[KeyExistsQ[#, "SufficientQ"],
      {TrueQ[#["SufficientQ"]]},
      TrueQ /@ Lookup[Values[#], "SufficientQ", False]
    ]&,
    Values[componentReports]
  ];
  lowerOrderLedger = <|
    "RequestedPublicOrder" -> finalOrder,
    "RawA31SeriesRequiredThrough" -> finalOrder,
    "A30OverEpsilonRequiresThrough" -> finalOrder + 1,
    "A21TimesA30RequiresEachThrough" -> finalOrder + 2,
    "EncodedLowerAntennaDependencyOrder" ->
      IntegratedAntennaDependencyExpansionOrder[finalOrder]|>;
  passed = AllTrue[componentPasses, TrueQ];
  report = <|"Regression" -> "A31EpsilonDepth",
    "LowerOrderExtractionLedger" -> lowerOrderLedger,
    "NormalizedMasterRequirements" -> componentReports,
    "Passed" -> passed|>;
  Print[report];
  Exit[If[passed, 0, 1]]
];
