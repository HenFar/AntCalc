(* ::Package:: *)
(* Antenna Pipeline - Integrate Stage Loader
   Decoupled loader for integrating AntennaObjects via IBP or PaVe backends.
   Loads or depends on build_pipeline.wl while omitting presentation/version banners. *)

If[!TrueQ[$AntennaPipelineIntegrateLoaded],

  thisDir = If[StringQ[$InputFileName] && $InputFileName =!= "",
    DirectoryName[$InputFileName],
    If[StringQ[$AntennaPipelineRoot] && $AntennaPipelineRoot =!= "",
      FileNameJoin[{$AntennaPipelineRoot, "src", "next"}],
      Directory[]
    ]
  ];

  (* Ensure build stage foundation is loaded first *)
  If[!TrueQ[$AntennaPipelineBuildLoaded],
    Get[FileNameJoin[{thisDir, "build_pipeline.wl"}]]
  ];

  packageRoot = $AntennaPipelineRoot;

  (* Massive A30 integration bridge *)
  Get[FileNameJoin[{packageRoot, "src", "routes", "massive_a30_integrated.wl"}]];

  (* Integration engines *)
  Get[FileNameJoin[{packageRoot, "src", "engines", "integration_ibp.wl"}]];

  (* Suppress LiteRed eager banner *)
  $AntennaPipelineLiteRedBannerPrinted = True;

  Get[FileNameJoin[{packageRoot, "src", "engines", "integration_pave.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "engines", "integrated_antenna_extraction.wl"}]];

  (* Integration workflows and public router *)
  Get[FileNameJoin[{packageRoot, "src", "routes", "integration_workflows.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "interface", "integration_router.wl"}]];

  (* Drivers and runtime reports *)
  Get[FileNameJoin[{packageRoot, "src", "interface", "rratio_driver.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "interface", "runtime_reports.wl"}]];
  Get[FileNameJoin[{packageRoot, "src", "core", "physics_validation.wl"}]];

  $AntennaPipelineIntegrateLoaded = True;
];
