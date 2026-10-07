(* EDIT HERE: A20 route declaration.  Change physics settings only in this association. *)
RegisterAntennaRouteDefinition[<|
  "Key" -> {A, 2, 0}, "Name" -> "A20", "Status" -> "Supported",
  "EditFile" -> "src/routes/families/A20.wl",
  "Build" -> <|"Funnel" -> "TreeSelfInterference", "Adapter" -> "StandardFeynArts", "Production" -> "SelfInterference", "Extraction" -> "BornScalar", "ColourNorm" -> colourNorm|>,
  "Integration" -> <|"Funnel" -> "IBP", "Adapter" -> "StandardIBP", "BasisFamily" -> "X20", "ExpansionOrder" -> 2|>,
  "Variants" -> <|"Massless" -> <|"Activation" -> Function[opts, True]|>|>,
  "Conventions" -> <|"Build" -> BuildAntennaConventionProfile[{A, 2, 0}]|>,
  "Validation" -> AntennaRouteVerificationMetadata[{A, 2, 0}], "Notes" -> {"Massless Born antenna."}|>
];
