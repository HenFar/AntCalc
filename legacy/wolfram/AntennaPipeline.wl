description = "antenna pipeline v0.1 - layered package loader";

(*
  Canonical package loader.

  The runtime source tree now lives under src/ with a layered ownership split:

    1. core
       setup, shared utilities, profiles, cache, diagnostics support

    2. engines
       raw FeynArts/FeynCalc/LiteRed/Package-X operations

    3. routes
       readable antenna-specific workflows and stage contracts

    4. interface
       public API, return formatting, object/record handling, cache plumbing
*)

If[$FrontEnd === Null,
   $FeynCalcStartupMessages = False;
];

packageRoot = DirectoryName[$InputFileName];

$AntennaPipelineRoot = packageRoot;

Get[FileNameJoin[{packageRoot, "src", "core", "version.wl"}]];

Get[FileNameJoin[{packageRoot, "src", "core", "setup.wl"}]];

Get[FileNameJoin[{packageRoot, "src", "core", "result_cache.wl"}]];

Get[FileNameJoin[{packageRoot, "src", "core", "kinematics_and_utilities.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "engines", "amplitudes_tree.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "engines", "amplitudes_loop.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "engines", "interference_tree.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "engines", "interference_loop.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "core", "profiles.wl"}]];

Get[FileNameJoin[{packageRoot, "src", "core", "ward_identity_validation.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "engines", "extraction_tree.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "engines", "extraction_loop.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "engines", "color_ordered_a40.wl"
   }]];

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

Get[FileNameJoin[{packageRoot, "src", "routes", "massive_a30_unintegrated.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "routes", "massive_a30_reconstruction.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "routes", "massive_a30_integrated.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "routes", "build_workflows.wl"}
   ]];

Get[FileNameJoin[{packageRoot, "src", "interface", "build_router.wl"}
   ]];

Get[FileNameJoin[{packageRoot, "src", "core", "production_assignments.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "engines", "integration_ibp.wl"
   }]];

(* LiteRed remains lazy: loading it globally before FeynArts model setup
   changes the backend symbol environment. The startup banner reads its
   installed metadata without evaluating LiteRed itself. *)
$AntennaPipelineLiteRedBannerPrinted = True;

Get[FileNameJoin[{packageRoot, "src", "engines", "integration_pave.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "engines", "integrated_antenna_extraction.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "routes", "integration_workflows.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "interface", "integration_router.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "interface", "paper_targets.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "core", "diagnostics.wl"}]];

Get[FileNameJoin[{packageRoot, "src", "core", "notebook_patches.wl"}]
   ];

Get[FileNameJoin[{packageRoot, "src", "interface", "rratio_driver.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "interface", "build_all_antennae.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "core", "public_defaults.wl"}]];

Get[FileNameJoin[{packageRoot, "src", "interface", "runtime_reports.wl"
   }]];

Get[FileNameJoin[{packageRoot, "src", "core", "physics_validation.wl"
   }]];

(* The only visible package-startup presentation. *)
If[!TrueQ[$AntCalcStartupBannerPrinted],
  AntCalcStartupBanner[];
  $AntCalcStartupBannerPrinted = True
];
