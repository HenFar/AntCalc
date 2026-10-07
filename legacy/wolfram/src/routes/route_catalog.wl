(* ::Section:: *)
(* Human-readable route stories *)

(* Communicates with:
   - src/routes/build_workflows.wl and src/routes/integration_workflows.wl,
     which attach these story associations to their returned diagnostics.
   - src/interface/build_router.wl and src/interface/integration_router.wl,
     which expose the resulting metadata publicly.

   Why this file exists:
   The pipeline is complex enough that a compact narrative description of each
   route is useful metadata in its own right.  These “stories” give later
   readers a high-level map of which stages a request went through without
   forcing them to reconstruct that map from code paths alone. *)

BuildRouteStory::usage =
  "BuildRouteStory[key] returns a readable summary of the route stages used to build the selected antenna in src.";

IntegrationRouteStory::usage =
  "IntegrationRouteStory[key] returns a readable summary of the route stages used to integrate the selected antenna in src.";

BuildRouteStory[{A, 2, 0}] :=
  <|
    "Key" -> {A, 2, 0},
    "Kind" -> "Build",
    "Stages" -> {"Amplitude", "Interference", "Antenna"},
    "Notes" -> "Massless tree A20 route."
  |>;

BuildRouteStory[{A, 3, 0}] :=
  <|
    "Key" -> {A, 3, 0},
    "Kind" -> "Build",
    "Stages" -> {"Amplitude", "Interference", "Antenna"},
    "Notes" -> "Massless tree A30 route, or massive reconstruction when quarkMass != 0."
  |>;

BuildRouteStory[{A, 4, 0}] :=
  <|
    "Key" -> {A, 4, 0},
    "Kind" -> "Build",
    "Stages" -> {"Amplitude", "SectorSplit", "Interference", "AntennaComponents"},
    "Notes" -> "Tree four-parton A-type route."
  |>;

BuildRouteStory[{B, 4, 0}] :=
  <|
    "Key" -> {B, 4, 0},
    "Kind" -> "Build",
    "Stages" -> {"Amplitude", "Interference", "ColorOrdering", "Antenna"},
    "Notes" -> "Tree four-parton B-type route."
  |>;

BuildRouteStory[{C, 4, 0}] :=
  <|
    "Key" -> {C, 4, 0},
    "Kind" -> "Build",
    "Stages" -> {"Amplitude", "Interference", "ColorOrdering", "Antenna"},
    "Notes" -> "Tree four-parton C-type route."
  |>;

BuildRouteStory[{A, 2, 1}] :=
  <|
    "Key" -> {A, 2, 1},
    "Kind" -> "Build",
    "Stages" -> {"LoopAmplitude", "Interference", "Extraction"},
    "Notes" -> "One-loop A21 build route."
  |>;

BuildRouteStory[{A, 3, 1}] :=
  <|
    "Key" -> {A, 3, 1},
    "Kind" -> "Build",
    "Stages" -> {"LoopAmplitude", "Interference", "Extraction"},
    "Notes" -> "One-loop A31 build route."
  |>;

BuildRouteStory[{A, 2, 2}] :=
  <|
    "Key" -> {A, 2, 2},
    "Kind" -> "Build",
    "Stages" -> {"TwoLoopTreeContribution", "OneLoopSelfContribution", "Combination"},
    "Notes" -> "Two-loop A22 stitched route."
  |>;

BuildRouteStory[key_] :=
  <|
    "Key" -> key,
    "Kind" -> "Build",
    "Stages" -> {"Unsupported"},
    "Notes" -> "No dedicated src build story recorded for this key."
  |>;

IntegrationRouteStory[{A, 3, 0}] :=
  <|
    "Key" -> {A, 3, 0},
    "Kind" -> "Integrate",
    "Stages" -> {"BackendSelection", "MasterCombination", "MasterSubstitution", "DimensionForm", "SeriesResult"},
    "Notes" -> "PaVe for the standard massless route, bibliography bridge for the current massive route, IBP when requested."
  |>;

IntegrationRouteStory[{A, 2, 1}] :=
  <|
    "Key" -> {A, 2, 1},
    "Kind" -> "Integrate",
    "Stages" -> {"BackendSelection", "IntegratedObject", "TTerms", "FinalResult"},
    "Notes" -> "One-loop A21 integration route."
  |>;

IntegrationRouteStory[{A, 3, 1}] :=
  <|
    "Key" -> {A, 3, 1},
    "Kind" -> "Integrate",
    "Stages" -> {"IBPReduction", "MasterCombination", "MasterSubstitution", "FinalResult"},
    "Notes" -> "One-loop A31 IBP route."
  |>;

IntegrationRouteStory[{A, 2, 2}] :=
  <|
    "Key" -> {A, 2, 2},
    "Kind" -> "Integrate",
    "Stages" -> {"ContributionSelection", "IBPReduction", "MasterSubstitution", "CombinedResult"},
    "Notes" -> "Two-loop stitched A22 integration route."
  |>;

IntegrationRouteStory[{A, 4, 0}] :=
  <|
    "Key" -> {A, 4, 0},
    "Kind" -> "Integrate",
    "Stages" -> {"BackendSelection", "IntegratedObject", "TTerms", "FinalResult"},
    "Notes" -> "Tree-level integrated A40 route."
  |>;

IntegrationRouteStory[{B, 4, 0}] :=
  <|
    "Key" -> {B, 4, 0},
    "Kind" -> "Integrate",
    "Stages" -> {"BackendSelection", "IntegratedObject", "TTerms", "FinalResult"},
    "Notes" -> "Tree-level integrated B40 route."
  |>;

IntegrationRouteStory[{C, 4, 0}] :=
  <|
    "Key" -> {C, 4, 0},
    "Kind" -> "Integrate",
    "Stages" -> {"BackendSelection", "IntegratedObject", "TTerms", "FinalResult"},
    "Notes" -> "Tree-level integrated C40 route."
  |>;

IntegrationRouteStory[key_] :=
  <|
    "Key" -> key,
    "Kind" -> "Integrate",
    "Stages" -> {"Unsupported"},
    "Notes" -> "No dedicated src integration story recorded for this key."
  |>;
