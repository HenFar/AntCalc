(* ::Package:: *)
(* Antenna Pipeline - Build Stage Loader
   Decoupled loader for constructing unintegrated antenna expressions and AntennaObjects.
   Omits integration backends (IBP, PaVe) and miscellaneous presentation/version banners. *)

If[!TrueQ[$AntennaPipelineBuildLoaded],

  If[$FrontEnd === Null,
    $FeynCalcStartupMessages = False;
  ];

  packageRoot = If[StringQ[$InputFileName] && $InputFileName =!= "",
    AbsoluteFileName[FileNameJoin[{DirectoryName[$InputFileName], "..", ".."}]],
    If[StringQ[$AntennaPipelineRoot] && $AntennaPipelineRoot =!= "",
      $AntennaPipelineRoot,
      AbsoluteFileName[FileNameJoin[{Directory[], "..", ".."}]]
    ]
  ];

  $AntennaPipelineRoot = packageRoot;

  (* Core symbolic environment, kinematics, and cache *)
  Get[FileNameJoin[{packageRoot, "src", "core", "setup.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "core", "result_cache.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "core", "kinematics_and_utilities.wl"}]];

  (* Tree and loop amplitude & interference engines *)
  Get[FileNameJoin[{packageRoot, "src", "engines", "amplitudes_tree.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "engines", "amplitudes_loop.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "engines", "interference_tree.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "engines", "interference_loop.wl"}]];

  (* Profiles, validation, and component extraction *)
  Get[FileNameJoin[{packageRoot, "src", "core", "profiles.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "core", "ward_identity_validation.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "engines", "extraction_tree.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "engines", "extraction_loop.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "engines", "color_ordered_a40.wl"}]];

  (* Route catalog, resolution, and family declarations *)
  Get[FileNameJoin[{packageRoot, "src", "routes", "route_catalog.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "route_resolution.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "families", "A20.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "families", "A30.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "families", "A21.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "families", "A31.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "families", "A22.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "families", "A40.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "families", "B40.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "families", "C40.wl"}]];

  InstallAntennaRouteCompatibilityFacades[];

  (* Massive A30 unintegrated and reconstruction routes *)
  Get[FileNameJoin[{packageRoot, "src", "routes", "massive_a30_unintegrated.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "massive_a30_reconstruction.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "routes", "build_workflows.wl"}]];

  (* Public build router and assignments *)
  Get[FileNameJoin[{packageRoot, "src", "interface", "build_router.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "core", "production_assignments.wl"}]];

  (* Literature benchmarks and build diagnostics *)
  Get[FileNameJoin[{packageRoot, "src", "interface", "paper_targets.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "core", "diagnostics.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "core", "notebook_patches.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "interface", "build_all_antennae.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "core", "public_defaults.wl"}]];

  $AntennaPipelineBuildLoaded = True;
];
