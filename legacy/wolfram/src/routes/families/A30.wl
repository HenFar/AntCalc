(* EDIT HERE: A30 route declaration.  Massless and massive routes are named variants. *)
RegisterAntennaRouteDefinition[<|
  "Key" -> {A, 3, 0}, "Name" -> "A30", "Status" -> "SupportedWithBetaMassiveVariant",
  "EditFile" -> "src/routes/families/A30.wl",
  "Build" -> <|"Funnel" -> "TreeSelfInterference", "Adapter" -> "StandardFeynArts", "Production" -> "SelfInterference", "Extraction" -> "TreeColourCoefficients", "ColourNorm" -> colourNorm|>,
  "Integration" -> <|"Funnel" -> "IBP", "Adapter" -> "StandardIBP", "BasisFamily" -> "X30", "ExpansionOrder" -> 2|>,
  "Variants" -> <|
    "Massless" -> <|"Activation" -> Function[opts, TrueQ[Lookup[opts, "quarkMass", 0] === 0]]|>,
    "Massive" -> <|"Activation" -> Function[opts, !TrueQ[Lookup[opts, "quarkMass", 0] === 0]],
      "Build" -> <|"Adapter" -> "MassiveA30Reconstruction"|>,
      "Integration" -> <|"Adapter" -> "MassiveA30MX30Bridge", "BasisFamily" -> "MX30", "MasterConvention" -> "DerivedMX30RuntimeBridge"|>|>
  |>,
  "Conventions" -> <|"Build" -> BuildAntennaConventionProfile[{A, 3, 0}], "MassiveBridge" -> "DerivedMX30RuntimeBridge"|>,
  "Validation" -> AntennaRouteVerificationMetadata[{A, 3, 0}], "Notes" -> {"Massive variant is beta-qualified through ExpansionOrder -> 2."}|>
];
