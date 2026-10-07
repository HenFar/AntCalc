(*************************************************)

(*
  Lightweight shared normalisation.
  This is symbolic and cheap to define at load time; amplitudes and
  interferences are built lazily below.
*)

(*************************************************)

AntennaReductionProfile::usage =
  "AntennaReductionProfile[key] returns the build-side reduction settings associated with an antenna family.";

AntennaProfile::usage =
  "AntennaProfile[key] returns the main metadata association for an antenna route, including amplitudes, extraction rules, and diagnostics data.";

AntennaAmplitude::usage =
  "AntennaAmplitude[key] returns the tree-level amplitude object associated with a profile.";

AntennaSelfInterference::usage =
  "AntennaSelfInterference[key] returns the encoded self-interference or companion object associated with a profile.";

BornInterference::usage =
  "BornInterference[] returns the standard born-level interference data shared by the loop extractors.";

AntennaIntegrationProfile::usage =
  "AntennaIntegrationProfile[key] returns the integration-backend metadata used by IntegrateAntenna for a given route.";

colourNorm = SUNN - 1 / SUNN;

(*************************************************)

(*
  One-loop routing profiles.
  These profiles keep the A21/A31 differences out of the production code:
  particle exclusions, generation sums, reduction preferences, and antenna
  extraction are chosen from the antenna key {type, multiplicity, loop order}.
*)

(*************************************************)

AntennaReductionProfile[{A, 2, 1}] :=
  <|"DefaultBackend" -> "PaVe"|>;

AntennaReductionProfile[{A, 3, 1}] :=
  <|"DefaultBackend" -> "PaVe"|>;

AntennaReductionProfile[{type_Symbol /; SymbolName[type] === "A", 2, 1}] :=
  <|"DefaultBackend" -> "PaVe"|>;

AntennaReductionProfile[{type_Symbol /; SymbolName[type] === "A", 3, 1}] :=
  <|"DefaultBackend" -> "PaVe"|>;

AntennaProfile[{A, 2, 1}] :=
  <|"Key" -> {A, 2, 1}, "Name" -> "A21", "AntennaType" -> A, "NumFinalParticles"
     -> 2, "LoopOrder" -> 1, "TreeAmplitude" -> AntennaAmplitude[{A, 2,
      0}], "BornInterference" -> BornInterference[], "Extraction" -> "LoopScalar", 
    "ColourNorm" -> colourNorm, "ExcludedParticles" -> {S[_], V[1],
     V[2], V[3], U[1], U[2], U[3], 
    U[4]}, "DropSumOver" -> True, "ReductionProfile" -> AntennaReductionProfile[
    {A, 2, 1}]|>;

AntennaProfile[{A, 3, 1}] :=
  <|"Key" -> {A, 3, 1}, "Name" -> "A31", "AntennaType" -> A, "NumFinalParticles"
     -> 3, "LoopOrder" -> 1, "TreeAmplitude" -> AntennaAmplitude[{A, 3,
      0}], "BornInterference" -> BornInterference[], "Extraction" -> "LoopColorCoefficients",
     "ColourNorm" -> colourNorm, "ExcludedParticles" -> {S[_], V[1], V[2],
     V[3], U[1], U[
    2], U[3]}, "DropSumOver" -> False, "ReductionProfile" -> AntennaReductionProfile[
    {A, 3, 1}]|>;

AntennaProfile[{A, 2, 2}] :=
  <|"Key" -> {A, 2, 2}, "Name" -> "A22", "AntennaType" -> A,
    "NumFinalParticles" -> 2, "LoopOrder" -> 2,
    "BornInterference" -> BornInterference[],
    "Components" -> {Leading, Subleading, Nf, Breve},
    "Contributions" -> {TwoLoopTree, OneLoopSelf},
    "Extraction" -> "TwoLoopTTermComponents",
    "ExcludedParticles" -> {S[_], V[1], V[2], V[3], U[1], U[2],
      U[3], U[4]}, "DropSumOver" -> False,
    "ColourNorm" -> colourNorm,
    "ImplementationStatus" -> "ExperimentalSourceProduction"|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "A", 2, 1}] :=
  <|"Key" -> {type, 2, 1}, "Name" -> "A21", "AntennaType" -> type,
    "NumFinalParticles" -> 2, "LoopOrder" -> 1, "TreeAmplitude" ->
     AntennaAmplitude[{type, 2, 0}], "BornInterference" ->
     BornInterference[], "Extraction" -> "LoopScalar", "ColourNorm" ->
     colourNorm, "ExcludedParticles" -> {S[_], V[1], V[2], V[3], U[1],
      U[2], U[3], U[4]}, "DropSumOver" -> True, "ReductionProfile" ->
     AntennaReductionProfile[{type, 2, 1}]|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "A", 3, 1}] :=
  <|"Key" -> {type, 3, 1}, "Name" -> "A31", "AntennaType" -> type,
    "NumFinalParticles" -> 3, "LoopOrder" -> 1, "TreeAmplitude" ->
     AntennaAmplitude[{type, 3, 0}], "BornInterference" ->
     BornInterference[], "Extraction" -> "LoopColorCoefficients",
    "ColourNorm" -> colourNorm, "ExcludedParticles" -> {S[_], V[1], V[2],
      V[3], U[1], U[2], U[3]}, "DropSumOver" -> False,
    "ReductionProfile" -> AntennaReductionProfile[{type, 3, 1}]|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "A", 2, 2}] :=
  <|"Key" -> {type, 2, 2}, "Name" -> "A22", "AntennaType" -> type,
    "NumFinalParticles" -> 2, "LoopOrder" -> 2, "BornInterference" ->
     BornInterference[], "Components" -> {Leading, Subleading, Nf,
      Breve}, "Contributions" -> {TwoLoopTree, OneLoopSelf},
    "Extraction" -> "TwoLoopTTermComponents", "ExcludedParticles" -> {S[_],
      V[1], V[2], V[3], U[1], U[2], U[3], U[4]}, "DropSumOver" -> False,
    "ColourNorm" -> colourNorm, "ImplementationStatus" ->
     "ExperimentalSourceProduction"|>;
(*************************************************)

(*
  Tree-level antenna profiles.
  Antenna-specific physics is stored as metadata here: colour normalisation,
  production mode, and the sector definitions used for B/C four-quark
  antennae.  The production functions below are generic.
*)

(*************************************************)

AntennaProfile[{A, 2, 0}] :=
  <|"Key" -> {A, 2, 0}, "Name" -> "A20", "AntennaType" -> A, "NumFinalParticles"
     -> 2, "Production" -> "SelfInterference", "Extraction" -> "BornScalar",
     "ColourNorm" -> colourNorm|>;

AntennaProfile[{A, 3, 0}] :=
  <|"Key" -> {A, 3, 0}, "Name" -> "A30", "AntennaType" -> A, "NumFinalParticles"
     -> 3, "Production" -> "SelfInterference", "Extraction" -> "TreeColorCoefficients",
     "ColourNorm" -> colourNorm|>;

AntennaProfile[{A, 4, 0}] :=
  <|"Key" -> {A, 4, 0}, "Name" -> "A40", "AntennaType" -> A, "NumFinalParticles"
     -> 4, "Production" -> "ColorOrderedAntenna", "Extraction" -> "TreeColorCoefficients",
     "ColourNorm" -> colourNorm, "ColorOrderedSpec" -> <|"Name" -> "A40",
     "Ordering" -> {1, 3, 4, 2}, "NumGluons" -> 2|>|>;

AntennaProfile[{B, 4, 0}] :=
  <|"Key" -> {B, 4, 0}, "Name" -> "B40", "AntennaType" -> B, "NumFinalParticles"
     -> 4, "Production" -> "SectorSelfInterference", "Extraction" -> "ColourNormScalar",
     "ColourNorm" -> colourNorm, "ProductionSectors" -> {"PrimaryCurrent",
     "PrimaryCurrent"}, "SectorDefinitions" -> <|"PrimaryCurrent" -> {{s34
    }, {s134, s234}}, "SecondaryCurrent" -> {{s12}, {s123, s124}}|>|>;

AntennaProfile[{C, 4, 0}] :=
  <|"Key" -> {C, 4, 0}, "Name" -> "C40", "AntennaType" -> C, "NumFinalParticles"
     -> 4, "Production" -> "SectorSymmetrizedInterference", "Extraction" 
    -> "MinusTwoColourNormOverSUNN", "ColourNorm" -> colourNorm, "ProductionSectors"
     -> {"DirectPrimary", "ExchangePrimary"}, "ReferenceSquareSector" -> 
    "DirectPrimary", "ReferenceSquareProfile" -> {B, 4, 0}, "SectorDefinitions"
     -> <|"DirectPrimary" -> {{s34}, {s134, s234}}, "DirectSecondary" -> 
    {{s12}, {s123, s124}}, "ExchangePrimary" -> {{s23}, {s123, s234}}, "ExchangeSecondary"
     -> {{s14}, {s124, s134}}|>|>;

AntennaProfile[{D, 3, 0}] :=
  <|"Key" -> {D, 3, 0}, "Name" -> "D30", "AntennaType" -> D,
    "NumFinalParticles" -> 3, "Production" -> "EffectiveSourcePending",
    "Extraction" -> "ColourNormScalar", "ColourNorm" -> 1,
    "SourceModel" -> D30EffectiveModelName[],
    "ImplementationStatus" -> "ModelOwnedSourcePendingRoute"|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "A", 2, 0}] :=
  <|"Key" -> {type, 2, 0}, "Name" -> "A20", "AntennaType" -> type,
    "NumFinalParticles" -> 2, "Production" -> "SelfInterference",
    "Extraction" -> "BornScalar", "ColourNorm" -> colourNorm|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "A", 3, 0}] :=
  <|"Key" -> {type, 3, 0}, "Name" -> "A30", "AntennaType" -> type,
    "NumFinalParticles" -> 3, "Production" -> "SelfInterference",
    "Extraction" -> "TreeColorCoefficients", "ColourNorm" -> colourNorm|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "A", 4, 0}] :=
  <|"Key" -> {type, 4, 0}, "Name" -> "A40", "AntennaType" -> type,
    "NumFinalParticles" -> 4, "Production" -> "ColorOrderedAntenna",
    "Extraction" -> "TreeColorCoefficients", "ColourNorm" -> colourNorm,
    "ColorOrderedSpec" -> <|"Name" -> "A40", "Ordering" -> {1, 3, 4, 2},
      "NumGluons" -> 2|>|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "B", 4, 0}] :=
  <|"Key" -> {type, 4, 0}, "Name" -> "B40", "AntennaType" -> type,
    "NumFinalParticles" -> 4, "Production" -> "SectorSelfInterference",
    "Extraction" -> "ColourNormScalar", "ColourNorm" -> colourNorm,
    "ProductionSectors" -> {"PrimaryCurrent", "PrimaryCurrent"},
    "SectorDefinitions" -> <|"PrimaryCurrent" -> {{s34}, {s134, s234}},
      "SecondaryCurrent" -> {{s12}, {s123, s124}}|>|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "C", 4, 0}] :=
  <|"Key" -> {type, 4, 0}, "Name" -> "C40", "AntennaType" -> type,
    "NumFinalParticles" -> 4, "Production" ->
     "SectorSymmetrizedInterference", "Extraction" ->
     "MinusTwoColourNormOverSUNN", "ColourNorm" -> colourNorm,
    "ProductionSectors" -> {"DirectPrimary", "ExchangePrimary"},
    "ReferenceSquareSector" -> "DirectPrimary", "ReferenceSquareProfile" ->
     {B, 4, 0}, "SectorDefinitions" -> <|
      "DirectPrimary" -> {{s34}, {s134, s234}},
      "DirectSecondary" -> {{s12}, {s123, s124}},
      "ExchangePrimary" -> {{s23}, {s123, s234}},
      "ExchangeSecondary" -> {{s14}, {s124, s134}}|>|>;

AntennaProfile[{type_Symbol /; SymbolName[type] === "D", 3, 0}] :=
  <|"Key" -> {type, 3, 0}, "Name" -> "D30", "AntennaType" -> type,
    "NumFinalParticles" -> 3, "Production" -> "EffectiveSourcePending",
    "Extraction" -> "ColourNormScalar", "ColourNorm" -> 1,
    "SourceModel" -> D30EffectiveModelName[],
    "ImplementationStatus" -> "ModelOwnedSourcePendingRoute"|>;

AntennaAmplitude[{A, 2, 0}] :=
  AntennaAmplitude[{A, 2, 0}] = MAmpLoopLess[2];

AntennaAmplitude[{A, 3, 0}] :=
  AntennaAmplitude[{A, 3, 0}] = MAmpLoopLess[3];

AntennaAmplitude[{A, 4, 0}] :=
  AntennaAmplitude[{A, 4, 0}] = MAmpLoopLess[4];

AntennaAmplitude[{B, 4, 0}] :=
  AntennaAmplitude[{B, 4, 0}] = MAmpLoopLess[4, AntennaType -> B];

AntennaAmplitude[{C, 4, 0}] :=
  AntennaAmplitude[{C, 4, 0}] = MAmpLoopLess[4, AntennaType -> C];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "A", 2, 0}] :=
  AntennaAmplitude[{type, 2, 0}] = MAmpLoopLess[2];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "A", 3, 0}] :=
  AntennaAmplitude[{type, 3, 0}] = MAmpLoopLess[3];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "A", 4, 0}] :=
  AntennaAmplitude[{type, 4, 0}] = MAmpLoopLess[4];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "B", 4, 0}] :=
  AntennaAmplitude[{type, 4, 0}] = MAmpLoopLess[4, AntennaType -> B];

AntennaAmplitude[{type_Symbol /; SymbolName[type] === "C", 4, 0}] :=
  AntennaAmplitude[{type, 4, 0}] = MAmpLoopLess[4, AntennaType -> C];

AntennaSelfInterference[{A, 2, 0}] :=
  AntennaSelfInterference[{A, 2, 0}] =
    InterfereMAmplitudes[AntennaAmplitude[{A, 2, 0}], AntennaAmplitude[{
      A, 2, 0}], 2];

AntennaSelfInterference[{A, 3, 0}] :=
  AntennaSelfInterference[{A, 3, 0}] =
    InterfereMAmplitudes[AntennaAmplitude[{A, 3, 0}], AntennaAmplitude[{
      A, 3, 0}], 3];

AntennaSelfInterference[{A, 4, 0}] :=
  AntennaSelfInterference[{A, 4, 0}] =
    InterfereMAmplitudes[AntennaAmplitude[{A, 4, 0}], AntennaAmplitude[{
      A, 4, 0}], 4];

AntennaSelfInterference[{B, 4, 0}] :=
  AntennaSelfInterference[{B, 4, 0}] =
    InterfereMAmplitudes[AntennaAmplitude[{B, 4, 0}], AntennaAmplitude[{
      B, 4, 0}], 4, AntennaType -> B];

AntennaSelfInterference[{C, 4, 0}] :=
  AntennaSelfInterference[{C, 4, 0}] =
    InterfereMAmplitudes[AntennaAmplitude[{C, 4, 0}], AntennaAmplitude[{
      C, 4, 0}], 4, AntennaType -> C];

BornInterference[] :=
  AntennaSelfInterference[{A, 2, 0}];
AntennaIntegrationProfile[{A, 2, 1}] :=
  <|"DefaultBackend" -> PaVe, "PaVeFamily" -> "MasslessTwoPartonVertex",
    "PaXConvention" -> "PaperRealMasslessTwoParton", "KinematicScale" ->
     q2, "ExpansionOrder" -> 2|>;

AntennaIntegrationProfile[{A, 3, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X30", "ExpansionOrder"
     -> 0|>;

AntennaIntegrationProfile[{A, 4, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder"
     -> 0|>;

AntennaIntegrationProfile[{B, 4, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder"
     -> 0|>;

AntennaIntegrationProfile[{C, 4, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder"
     -> 0|>;

AntennaIntegrationProfile[{A, 3, 1}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "A31", "ExpansionOrder"
     -> -2|>;

AntennaIntegrationProfile[{A, 2, 2}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "A22", "ExpansionOrder"
     -> 0, "ImplementationStatus" -> "ScaffoldOnly"|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 2, 1}] :=
  <|"DefaultBackend" -> PaVe, "PaVeFamily" -> "MasslessTwoPartonVertex",
    "PaXConvention" -> "PaperRealMasslessTwoParton", "KinematicScale" ->
     q2, "ExpansionOrder" -> 2|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 3, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X30", "ExpansionOrder" -> 0|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 4, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder" -> 0|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "B", 4, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder" -> 0|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "C", 4, 0}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "X40", "ExpansionOrder" -> 0|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 3, 1}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "A31", "ExpansionOrder" -> -2|>;

AntennaIntegrationProfile[{type_Symbol /; SymbolName[type] === "A", 2, 2}] :=
  <|"DefaultBackend" -> IBP, "BasisFamily" -> "A22", "ExpansionOrder" ->
     0, "ImplementationStatus" -> "ScaffoldOnly"|>;

AntennaIntegrationProfile[_] :=
  <|"DefaultBackend" -> IBP|>;
