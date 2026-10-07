(* ::Section:: *)
(* Build-route orchestration *)

(* Communicates with:
   - src/core/profiles.wl and src/routes/route_catalog.wl for route metadata.
   - src/engines/amplitudes_tree.wl, src/engines/interference_tree.wl,
     src/engines/extraction_tree.wl, and src/engines/color_ordered_a40.wl for
     the tree-level production pipeline.
   - src/interface/build_router.wl, which wraps these raw build-data records in
     the public API.
   - route declarations under src/routes/families/, which select any
     family-local adapter without leaking antenna-name checks into funnels.

   Why this file exists:
   The engines know how to perform one physical step at a time.  This layer is
   where those steps are composed into full antenna-specific workflows, with the
   profile metadata deciding which branch to take. *)

BuildRouteBuildData::usage =
  "BuildRouteBuildData[key, options] dispatches the src build route and returns the raw stage association before public formatting.";

BuildTreeRouteData::usage =
  "BuildTreeRouteData[key, options] runs the tree-level build workflow for the selected antenna.";

ResolveTreeSelfInterferenceRoute::usage =
  "ResolveTreeSelfInterferenceRoute[key, amp, profile] returns the tree-level self-interference used by the src route layer.";

(* BuildRouteBuildData[key, options]
   =================================
   Dispatch to the build workflow appropriate for the requested loop order. *)
BuildRouteBuildData[key_, options_Association] :=
  Module[{loopOrder},
    loopOrder = key[[3]];
    Switch[loopOrder,
      0,
        BuildTreeRouteData[key, options]
      ,
      1,
        BuildLoopAntennaData[key,
          printDiagram -> Lookup[options, "printDiagram", False],
          prefactor -> Lookup[options, "prefactor", 1],
          ApplyStripCouplings -> Lookup[options, "ApplyStripCouplings", AllCouplings],
          ApplyCasimirSubstitution -> Lookup[options, "ApplyCasimirSubstitution", True],
          ApplyDimReg -> Lookup[options, "ApplyDimReg", True],
          LoopMomentum -> Lookup[options, "LoopMomentum", l],
          ReductionBackend -> Lookup[options, "ReductionBackend", Automatic]
        ]
      ,
      2,
        BuildTwoLoopAntennaData[key,
          printDiagram -> Lookup[options, "printDiagram", False],
          prefactor -> Lookup[options, "prefactor", 1],
          ApplyStripCouplings -> Lookup[options, "ApplyStripCouplings", AllCouplings],
          ApplyCasimirSubstitution -> Lookup[options, "ApplyCasimirSubstitution", True],
          ApplyDimReg -> Lookup[options, "ApplyDimReg", True],
          LoopMomenta -> Lookup[options, "LoopMomenta", {l1, l2}],
          Contribution -> AntennaInternalContribution[key,
            Lookup[options, "Component", All]]
        ]
      ,
      _,
        <|
          "Profile" -> <|"Key" -> key, "RouteStory" -> BuildRouteStory[key]|>,
          "Components" -> <||>,
          "Diagnostics" -> <|"Failed" -> True, "Reason" -> "UnsupportedLoopOrder"|>
        |>
    ]
  ];

(* BuildTreeRouteData[key, options]
   ================================
   Run the full tree-level build workflow for one antenna family.

   Notes
     Although this function is named “tree”, it also owns the route-level
   declared adapters that replace the standard tree source with a custom
   reconstruction.  The funnel dispatches by adapter, never by family name. *)
BuildTreeRouteData[key_, options_Association] :=
  Module[{profile, amp, context, fullInterference, fullExtraction, split,
     sectors, sectorInterference, extraction, colorOrderedData, diagnostics,
     referenceSector, referenceProfile, referenceInterference,
     referenceExtraction, output, quarkMassOpt, resolved},
    resolved = ResolveAntennaRoute[key, options];
    If[!TrueQ[Lookup[resolved, "Resolved", False]],
      Return[<|"Profile" -> <|"Key" -> key|>, "Components" -> <||>,
        "Diagnostics" -> <|"Failed" -> True, "Reason" -> Lookup[resolved, "Reason", "UnsupportedRoute"]|>|>]
    ];
    profile = Join[AntennaProfile[key], Lookup[resolved, "Build", <||>]];
    quarkMassOpt = Lookup[options, "quarkMass", 0];
    If[Lookup[Lookup[resolved, "Build", <||>], "Adapter", "None"] ===
        "MassiveA30Reconstruction",
      LoadMassiveA30Reconstruction[];
      Return[
        MassiveA30BuildData[
          quarkMass -> quarkMassOpt,
          printDiagram -> Lookup[options, "printDiagram", False],
          ApplyStripCouplings -> Lookup[options, "ApplyStripCouplings", AllCouplings],
          ApplyCasimirSubstitution -> Lookup[options, "ApplyCasimirSubstitution", True],
          ApplyDimReg -> Lookup[options, "ApplyDimReg", True]
        ]
      ]
    ];
    (* AntennaAmplitude[key] is memoized, so draw requested diagrams explicitly
       at the route boundary instead of relying on a generation-time option
       that a warm cache will never see.  The returned amplitude remains the
       exact cached source used by ordinary builds. *)
    If[TrueQ[Lookup[options, "printDiagram", False]],
      PrintAntennaTreeDiagrams[profile["NumFinalParticles"],
        profile["AntennaType"]]
    ];
    amp = AntennaAmplitude[key];
    context = <|"BornInterference" -> BornInterference[]|>;
    (* The production mode stored in the profile is the key route switch:
       it tells us whether this family is a plain self-interference build, a
       color-ordered special case, or a sector-based four-quark construction. *)
    output =
      Switch[profile["Production"],
        "SelfInterference",
          fullInterference = ResolveTreeSelfInterferenceRoute[key, amp, profile];
          extraction = ExtractAntennaComponents[fullInterference, profile, context];
          <|
            "Profile" -> Join[profile, <|"RouteStory" -> BuildRouteStory[key]|>],
            "Amplitude" -> amp,
            "Sectors" -> <||>,
            "Interferences" -> <|"Production" -> fullInterference|>,
            "Components" -> extraction["Components"],
            "Diagnostics" -> extraction["Diagnostics"]
          |>
        ,
        "ColourOrderedAntenna",
          fullInterference = ResolveTreeSelfInterferenceRoute[key, amp, profile];
          fullExtraction = ExtractAntennaComponents[fullInterference, profile, context];
          colorOrderedData = ColourOrderedAntenna[
            amp,
            AntennaAmplitude[{A, 2, 0}],
            profile["NumFinalParticles"],
            profile["ColorOrderedSpec"]
          ];
          diagnostics =
            If[colorOrderedData === $Failed,
              <|"Failed" -> True, "Reason" -> "ColorOrderedConstructionFailed"|>
              ,
              Join[fullExtraction["Diagnostics"], colorOrderedData["Diagnostics"]]
            ];
          <|
            "Profile" -> Join[profile, <|"RouteStory" -> BuildRouteStory[key]|>],
            "Amplitude" -> amp,
            "Sectors" -> <||>,
            "Interferences" -> <|"FullColor" -> fullInterference|>,
            "FullColorComponents" -> fullExtraction["Components"],
            "Components" ->
              If[colorOrderedData === $Failed,
                <|"Antenna" -> $Failed|>,
                <|"Antenna" -> colorOrderedData["Antenna"]|>
              ],
            "ColorOrderedData" -> colorOrderedData,
            "Diagnostics" -> diagnostics
          |>
        ,
        "SectorSelfInterference",
          fullInterference = ResolveTreeSelfInterferenceRoute[key, amp, profile];
          fullExtraction = ExtractAntennaComponents[fullInterference, profile, context];
          split = SplitAmplitudeBySectors[amp, profile];
          sectors = profile["ProductionSectors"];
          sectorInterference =
            If[
              split["Diagnostics"][sectors[[1]] <> "Terms"] > 0 &&
              split["Diagnostics"][sectors[[2]] <> "Terms"] > 0,
              InterfereMAmplitudes[
                split["Parts"][sectors[[1]]],
                split["Parts"][sectors[[2]]],
                profile["NumFinalParticles"],
                AntennaType -> profile["AntennaType"]
              ]
              ,
              $Failed
            ];
          extraction = ExtractAntennaComponents[sectorInterference, profile, context];
          diagnostics = Join[split["Diagnostics"], extraction["Diagnostics"]];
          <|
            "Profile" -> Join[profile, <|"RouteStory" -> BuildRouteStory[key]|>],
            "Amplitude" -> amp,
            "Sectors" -> split["Parts"],
            "Interferences" -> <|"Full" -> fullInterference, "Production" -> sectorInterference|>,
            "FullComponents" -> fullExtraction["Components"],
            "FullDiagnostics" -> fullExtraction["Diagnostics"],
            "Components" -> extraction["Components"],
            "Diagnostics" -> diagnostics
          |>
        ,
        "SectorSymmetrisedInterference",
          split = SplitAmplitudeBySectors[amp, profile];
          sectors = profile["ProductionSectors"];
          sectorInterference =
            If[
              split["Diagnostics"][sectors[[1]] <> "Terms"] > 0 &&
              split["Diagnostics"][sectors[[2]] <> "Terms"] > 0,
              SymmetrizedInterference[
                split["Parts"][sectors[[1]]],
                split["Parts"][sectors[[2]]],
                profile["NumFinalParticles"],
                profile["AntennaType"]
              ]
              ,
              $Failed
            ];
          extraction = ExtractAntennaComponents[sectorInterference, profile, context];
          referenceSector = Lookup[profile, "ReferenceSquareSector", Missing["NotAvailable"]];
          referenceProfile = AntennaProfile[Lookup[profile, "ReferenceSquareProfile", key]];
          referenceInterference =
            If[StringQ[referenceSector] && split["Diagnostics"][referenceSector <> "Terms"] > 0,
              InterfereMAmplitudes[
                split["Parts"][referenceSector],
                split["Parts"][referenceSector],
                profile["NumFinalParticles"],
                AntennaType -> profile["AntennaType"]
              ]
              ,
              $Failed
            ];
          referenceExtraction =
            ExtractAntennaComponents[referenceInterference, referenceProfile, context];
          diagnostics = Join[split["Diagnostics"], extraction["Diagnostics"]];
          <|
            "Profile" -> Join[profile, <|"RouteStory" -> BuildRouteStory[key]|>],
            "Amplitude" -> amp,
            "Sectors" -> split["Parts"],
            "Interferences" -> <|"Production" -> sectorInterference, "ReferenceSquare" -> referenceInterference|>,
            "Components" -> extraction["Components"],
            "Diagnostics" -> diagnostics,
            "ReferenceSquareComponents" -> referenceExtraction["Components"],
            "ReferenceSquareDiagnostics" -> referenceExtraction["Diagnostics"]
          |>
        ,
        _,
          <|
            "Profile" -> Join[profile, <|"RouteStory" -> BuildRouteStory[key]|>],
            "Amplitude" -> amp,
            "Sectors" -> <||>,
            "Interferences" -> <||>,
            "Components" -> <||>,
            "Diagnostics" -> <|"Failed" -> True, "Reason" -> "UnknownProductionMode"|>
          |>
      ];
    output
  ];

(* ResolveTreeSelfInterferenceRoute[key, amp, profile]
   ===================================================
   Resolve the tree-level self-interference source used by the build route,
   preferring cached profile-level definitions when available and falling back
   to direct recomputation otherwise. *)
ResolveTreeSelfInterferenceRoute[key_, amp_, profile_Association] :=
  Module[{interference, storedRuleValue, keyTypeName},
    keyTypeName = SymbolName[First[key]];
    If[keyTypeName === "A" && key[[2]] === 3 && key[[3]] === 0,
      Return[
        InterfereMAmplitudes[
          amp,
          amp,
          Lookup[profile, "NumFinalParticles", key[[2]]]
        ]
      ]
    ];
    interference = Quiet[Check[Evaluate[AntennaSelfInterference[key]], $Failed]];
    If[interference === $Failed || Head[interference] === AntennaSelfInterference,
      storedRuleValue =
        FirstCase[
          DownValues[AntennaSelfInterference],
          HoldPattern[HoldPattern[AntennaSelfInterference[arg : {type_Symbol, n_Integer, l_Integer}]] :> rhs_] /;
              TrueQ[
                SymbolName[type] === keyTypeName &&
                n === key[[2]] &&
                l === key[[3]]
              ] :>
            rhs,
          Missing["NotFound"]
        ];
      If[storedRuleValue =!= Missing["NotFound"],
        Return[storedRuleValue]
      ];
      interference =
        If[Lookup[profile, "AntennaType", First[key]] === A,
          InterfereMAmplitudes[
            amp,
            amp,
            Lookup[profile, "NumFinalParticles", key[[2]]]
          ]
          ,
          InterfereMAmplitudes[
            amp,
            amp,
            Lookup[profile, "NumFinalParticles", key[[2]]],
            AntennaType -> Lookup[profile, "AntennaType", First[key]]
          ]
        ]
    ];
    interference
  ];
