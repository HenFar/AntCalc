(* ::Section:: *)
(* Massive A30 reconstruction route *)

(* Communicates with:
   - src/engines/interference_tree.wl and src/engines/extraction_tree.wl for
     the actual source-to-antenna mechanics.
   - src/core/profiles.wl for reused A30 normalization metadata.
   - src/routes/build_workflows.wl, which delegates here for nonzero-mass A30
     builds.
   - src/routes/massive_a30_unintegrated.wl, whose thesis-facing target is used
     as the route benchmark.

   Why this file exists:
   Massive A30 requires a special reconstruction and convention bridge, but the
   result still needs to fit into the same build-data contract as the standard
   routes so the rest of the package can consume it uniformly. *)

If[!ValueQ[$MassiveA30ReconstructionPackageLoaded] ||
    !TrueQ[$MassiveA30ReconstructionPackageLoaded],
  $MassiveA30ReconstructionPackageLoaded = True;
];

MassiveA30ReconstructionOptions::usage =
  "MassiveA30ReconstructionOptions[] returns the default option set for the massive A30 reconstruction helpers.";

MassiveA30TreeDiagrams::usage =
  "MassiveA30TreeDiagrams[] returns the tree-level diagram object used for the massive A30 reconstruction track.";

MassiveA30TreeAmplitude::usage =
  "MassiveA30TreeAmplitude[...] builds the stripped tree amplitude used by the massive A30 reconstruction track.";

MassiveA30BornAmplitude::usage =
  "MassiveA30BornAmplitude[...] builds the stripped two-parton massive born amplitude used to normalize the massive A30 antenna.";

MassiveA30SelfInterference::usage =
  "MassiveA30SelfInterference[...] computes the massive qqbar g self-interference through the package interference machinery.";

MassiveA30BornInterference::usage =
  "MassiveA30BornInterference[...] computes the massive qqbar born self-interference used for normalization.";

MassiveA30ExtractionAssociation::usage =
  "MassiveA30ExtractionAssociation[...] returns the extraction association for the massive A30 reconstruction track.";

MassiveA30NormalizedInterference::usage =
  "MassiveA30NormalizedInterference[...] returns the normalized interference before the final antenna is selected.";

MassiveA30ExtractedAntenna::usage =
  "MassiveA30ExtractedAntenna[...] returns the final extracted massive A30 antenna reconstructed through the package build chain.";

MassiveA30ReconstructionRecord::usage =
  "MassiveA30ReconstructionRecord[...] returns a structured association containing the main stage objects for the massive A30 reconstruction track.";

MassiveA30StageStatusBlock::usage =
  "MassiveA30StageStatusBlock[name, ...] returns the lab-note bookkeeping block used by the massive A30 reconstruction notes.";

MassiveA30ThesisTarget::usage =
  "MassiveA30ThesisTarget[...] returns the thesis-facing massive A30 antenna target after the explicit massive invariant substitutions used in the reconstruction track.";

MassiveA30ThesisAntenna::usage =
  "MassiveA30ThesisAntenna[...] returns the dimensionally continued massive A30 antenna reconstructed from the package-derived raw interference using the explicit normalization bridge. Its Epsilon -> 0 limit is the thesis-facing antenna target.";

MassiveA30BuildData::usage =
  "MassiveA30BuildData[...] returns a BuildAntennaData-shaped association for the public massive A30 build route.";

MassiveA30ReconstructionOptions[] :=
  {quarkMass -> quarkMass, printDiagram -> False, ApplyStripCouplings -> AllCouplings,
    ApplyCasimirSubstitution -> True, ApplyDimReg -> True};

Options[MassiveA30TreeAmplitude] = MassiveA30ReconstructionOptions[];
Options[MassiveA30BornAmplitude] = MassiveA30ReconstructionOptions[];
Options[MassiveA30SelfInterference] = MassiveA30ReconstructionOptions[];
Options[MassiveA30BornInterference] = MassiveA30ReconstructionOptions[];
Options[MassiveA30ExtractionAssociation] = MassiveA30ReconstructionOptions[];
Options[MassiveA30NormalizedInterference] = MassiveA30ReconstructionOptions[];
Options[MassiveA30ExtractedAntenna] = MassiveA30ReconstructionOptions[];
Options[MassiveA30ReconstructionRecord] = MassiveA30ReconstructionOptions[];
Options[MassiveA30ThesisTarget] = MassiveA30ReconstructionOptions[];
Options[MassiveA30ThesisAntenna] = MassiveA30ReconstructionOptions[];
Options[MassiveA30BuildData] = MassiveA30ReconstructionOptions[];

(* MassiveA30FieldState[numFinalParticles]
   =======================================
   Return the explicit heavy-quark final state used by the massive A30 route.

   Notes
     The same helper is reused for the two-parton born channel and the
     three-parton production channel so the normalization pair stays
     convention-aligned. *)
MassiveA30FieldState[numFinalParticles_Integer] :=
  Which[
    numFinalParticles == 2,
      {F[4, {3}], -F[4, {3}]}
    ,
    numFinalParticles == 3,
      {F[4, {3}], -F[4, {3}], V[5]}
    ,
    True,
      $Failed
  ];

(* MassiveA30CanonicalRules[qm]
   ============================
   Declare the on-shell and propagator replacements that rewrite the raw
   massive expressions into the invariant basis expected by the rest of the
   package. *)
MassiveA30CanonicalRules[qm_] :=
  {
    Pair[Momentum[k1, _], Momentum[k1, _]] -> qm ^ 2,
    Pair[Momentum[k2, _], Momentum[k2, _]] -> qm ^ 2,
    Pair[Momentum[k3, _], Momentum[k3, _]] -> 0,
    Pair[Momentum[k1, _], Momentum[k2, _]] -> s12 / 2,
    Pair[Momentum[k2, _], Momentum[k1, _]] -> s12 / 2,
    Pair[Momentum[k1, _], Momentum[k3, _]] -> s13 / 2,
    Pair[Momentum[k3, _], Momentum[k1, _]] -> s13 / 2,
    Pair[Momentum[k2, _], Momentum[k3, _]] -> s23 / 2,
    Pair[Momentum[k3, _], Momentum[k2, _]] -> s23 / 2,
    FeynAmpDenominator[
      PropagatorDenominator[
        Plus[Times[-1, Momentum[k1, _]], Times[-1, Momentum[k3, _]]],
        qm
      ]
    ] :> 1 / s13,
    FeynAmpDenominator[
      PropagatorDenominator[
        Plus[Momentum[k2, _], Momentum[k3, _]],
        qm
      ]
    ] :> 1 / s23
  };

(* MassiveA30Canonicalize[expr, qm]
   ================================
   Push one massive expression into the canonical invariant representation used
   throughout this route. *)
MassiveA30Canonicalize[expr_, qm_] :=
  expr /. MassiveA30CanonicalRules[qm] // Together // Expand // Simplify;

(* MassiveA30GeneratedAmplitude[numFinalParticles, qm, printDiagramQ, stripCouplings]
   ================================================================================
   Generate the stripped source amplitude for the massive A30 reconstruction
   track. *)
MassiveA30GeneratedAmplitude[numFinalParticles_Integer, qm_,
   printDiagramQ_:False, stripCouplings_:AllCouplings] :=
  Module[{outMoms, finalState, diagsTree, ampTree, ampTreeCouplings},
    FCClearScalarProducts[];
    outMoms = Table[Symbol["k" <> ToString[i]], {i, 1, numFinalParticles}];
    Do[
      SPD[outMoms[[i]], outMoms[[i]]] = If[i <= 2, qm ^ 2, 0];
      ,
      {i, 1, numFinalParticles}
    ];
    finalState = MassiveA30FieldState[numFinalParticles];
    diagsTree =
      InsertFields[
        CreateTopologies[0, 1 -> numFinalParticles],
        {V[1]} -> finalState,
        InsertionLevel -> {Classes},
        Model -> "SMQCD",
        ExcludeParticles -> {}
      ];
    If[TrueQ[printDiagramQ],
      Print[Paint[diagsTree, ColumnsXRows -> {2, 1}, Numbering -> Simple,
        SheetHeader -> None, ImageSize -> {512, 256}]]
    ];
    ampTree =
      With[{evalDiags = diagsTree, evalOutMoms = outMoms},
        FCFAConvert[
          CreateFeynAmp[evalDiags],
          IncomingMomenta -> {p},
          OutgoingMomenta -> evalOutMoms,
          UndoChiralSplittings -> True,
          ChangeDimension -> D,
          List -> False,
          SMP -> True,
          Contract -> True,
          DropSumOver -> True,
          FinalSubstitutions -> {
            SMP["m_u"] -> 0,
            SMP["m_d"] -> 0,
            SMP["m_s"] -> 0,
            SMP["m_c"] -> 0,
            SMP["m_b"] -> qm,
            SMP["m_t"] -> 0
          }
        ]
      ];
    ampTreeCouplings = ampTree / StripCouplings[stripCouplings,
      numFinalParticles, 0];
    ampTreeCouplings // SUNSimplify // Simplify
  ];

(* MassiveA30StageStatusBlock[name, status, ...]
   =============================================
   Build a structured status note for the development-heavy massive route. *)
MassiveA30StageStatusBlock[name_String, status_String,
   blockedOn_: "None", forcedStep_: "None",
   whyTemporary_: "Not applicable", replaceLater_: "Nothing"] :=
  <|
    "Stage" -> name,
    "Status" -> status,
    "BlockedOn" -> blockedOn,
    "ForcedStepUsed" -> forcedStep,
    "WhyAcceptableTemporarily" -> whyTemporary,
      "WhatMustBeReplacedLater" -> replaceLater
  |>;

(* MassiveA30TreeDiagrams[]
   ========================
   Return the tree diagrams used by MassiveA30TreeAmplitude[...]. *)
MassiveA30TreeDiagrams[] :=
  InsertFields[
    CreateTopologies[0, 1 -> 3],
    {V[1]} -> MassiveA30FieldState[3],
    InsertionLevel -> {Classes},
    Model -> "SMQCD",
    ExcludeParticles -> {}
  ];

(* MassiveA30TreeAmplitude[...]
   ============================
   Build the three-parton heavy-quark production amplitude for the route. *)
MassiveA30TreeAmplitude[OptionsPattern[]] :=
  MassiveA30GeneratedAmplitude[3, OptionValue[quarkMass],
    OptionValue[printDiagram], OptionValue[ApplyStripCouplings]];

(* MassiveA30BornAmplitude[...]
   ============================
   Build the two-parton heavy born amplitude used for normalization. *)
MassiveA30BornAmplitude[OptionsPattern[]] :=
  MassiveA30GeneratedAmplitude[2, OptionValue[quarkMass],
    False, OptionValue[ApplyStripCouplings]];

(* MassiveA30SelfInterference[...]
   ===============================
   Compute the heavy qqbar g production self-interference and immediately
   rewrite it into the route's invariant basis. *)
MassiveA30SelfInterference[OptionsPattern[]] :=
  Module[{amp},
    amp = MassiveA30TreeAmplitude[quarkMass -> OptionValue[quarkMass],
      ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
      printDiagram -> False];
    MassiveA30Canonicalize[
      InterfereMAmplitudes[amp, amp, 3,
        ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
        ApplyDimReg -> OptionValue[ApplyDimReg],
        quarkMass -> OptionValue[quarkMass]],
      OptionValue[quarkMass]
    ]
  ];

(* MassiveA30BornInterference[...]
   ===============================
   Compute the born self-interference that fixes the overall antenna
   normalization. *)
MassiveA30BornInterference[OptionsPattern[]] :=
  Module[{amp},
    amp = MassiveA30BornAmplitude[quarkMass -> OptionValue[quarkMass],
      ApplyStripCouplings -> OptionValue[ApplyStripCouplings]];
    MassiveA30Canonicalize[
      InterfereMAmplitudes[amp, amp, 2,
        ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
        ApplyDimReg -> OptionValue[ApplyDimReg],
        quarkMass -> OptionValue[quarkMass]],
      OptionValue[quarkMass]
    ]
  ];

(* MassiveA30ExtractionAssociation[...]
   ====================================
   Run the standard extraction machinery on the custom massive source so the
   special route still returns ordinary package-shaped build data. *)
MassiveA30ExtractionAssociation[OptionsPattern[]] :=
  Module[{profile, selfInterference, bornInterference, extraction},
    profile = AntennaProfile[{A, 3, 0}];
    selfInterference =
      MassiveA30SelfInterference[quarkMass -> OptionValue[quarkMass],
        ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
        ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
        ApplyDimReg -> OptionValue[ApplyDimReg]];
    bornInterference =
      MassiveA30BornInterference[quarkMass -> OptionValue[quarkMass],
        ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
        ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
        ApplyDimReg -> OptionValue[ApplyDimReg]];
    extraction =
      ExtractAntennaComponents[selfInterference, profile,
        <|"BornInterference" -> bornInterference|>];
    Join[extraction,
      <|"RawInterference" -> selfInterference,
        "BornInterference" -> bornInterference|>]
  ];

(* MassiveA30NormalizedInterference[...]
   =====================================
   Expose the normalized interference returned by the extraction layer. *)
MassiveA30NormalizedInterference[OptionsPattern[]] :=
  Lookup[
    MassiveA30ExtractionAssociation[quarkMass -> OptionValue[quarkMass],
      ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
      ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
      ApplyDimReg -> OptionValue[ApplyDimReg]],
    "NormalizedInterference",
    Missing["NotAvailable"]
  ];

(* MassiveA30ExtractedAntenna[...]
   ===============================
   Return the package-side extracted antenna before the thesis-facing bridge is
   applied. *)
MassiveA30ExtractedAntenna[OptionsPattern[]] :=
  Module[{components},
    components =
      Lookup[
        MassiveA30ExtractionAssociation[quarkMass -> OptionValue[quarkMass],
          ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
          ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
          ApplyDimReg -> OptionValue[ApplyDimReg]],
        "Components",
        <||>
      ];
    Lookup[components, "Antenna", components]
  ];

(* MassiveA30ThesisTarget[...]
   ===========================
   Re-express the encoded thesis target in the same on-shell variables used by
   the reconstruction track. *)
MassiveA30ThesisTarget[OptionsPattern[]] :=
  Module[{qm},
    qm = OptionValue[quarkMass];
    MassiveA30UnintegratedPaperConvention[] /. {
      mf -> qm,
      q2 -> 2 qm ^ 2 + s12 + s13 + s23,
      s123 -> s12 + s13 + s23,
      epsilon -> 0
    } // Together // Simplify
  ];

(* MassiveA30ThesisAntenna[...]
   ============================
   Apply the explicit notebook-to-thesis normalization bridge to the raw route
   interference.  Keep its d-dimensional numerator: setting Epsilon -> 0 here
   makes the unintegrated paper check pass, but discards exactly the terms that
   enter the all-epsilon reverse-unitarity reduction. *)
MassiveA30ThesisAntenna[OptionsPattern[]] :=
  Module[{qm, rawInterference, thesisBornOnShell},
    qm = OptionValue[quarkMass];
    rawInterference =
      MassiveA30SelfInterference[quarkMass -> qm,
        ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
        ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
        ApplyDimReg -> OptionValue[ApplyDimReg]];
    thesisBornOnShell =
      MassiveA30BornNormalizationPaper[] /. {
        mf -> qm,
        epsilon -> Epsilon,
        q2 -> 2 qm ^ 2 + s12 + s13 + s23
      } // Together;
    (
      ((4 / 9) rawInterference /. SUNN -> 3) /
      ((4 / 3) (colourNorm /. SUNN -> 3) thesisBornOnShell)
    ) /. q2 -> 2 qm ^ 2 + s12 + s13 + s23 // Together // Simplify
  ];

(* MassiveA30BuildData[...]
   ========================
   Package the massive route into the same association contract returned by
   BuildTreeRouteData[...] for ordinary tree antennas. *)
MassiveA30BuildData[OptionsPattern[]] :=
  Module[{qm, profile, record, thesisAntenna, paperResidual},
    qm = OptionValue[quarkMass];
    profile = AntennaProfile[{A, 3, 0}];
    record =
      MassiveA30ReconstructionRecord[quarkMass -> qm,
        printDiagram -> OptionValue[printDiagram],
        ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
        ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
        ApplyDimReg -> OptionValue[ApplyDimReg]];
    thesisAntenna =
      MassiveA30ThesisAntenna[quarkMass -> qm,
        ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
        ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
        ApplyDimReg -> OptionValue[ApplyDimReg]];
    paperResidual =
      Together[
        (thesisAntenna /. Epsilon -> 0) -
          MassiveA30ThesisTarget[quarkMass -> qm,
            ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
            ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
            ApplyDimReg -> OptionValue[ApplyDimReg]]
      ];
    <|
      "Profile" -> profile,
      "quarkMass" -> qm,
      "Amplitude" -> record["Amplitude"],
      "Sectors" -> <||>,
      "Interferences" -> <|"Production" -> record["RawInterference"]|>,
      "Components" -> <|"Antenna" -> thesisAntenna|>,
      "Diagnostics" -> Join[
        Lookup[record, "ExtractionDiagnostics", <||>],
        <|
          "MassiveA30Route" -> True,
          "quarkMass" -> qm,
          "NormalizationBridge" ->
            "Notebook-style d-dimensional raw interference, s123 -> s12 + s13 + s23, and package-to-thesis normalization factor 4/3 * colourNorm. The Epsilon -> 0 limit is checked against the thesis target.",
          "ThesisResidual" -> paperResidual,
          "ThesisExactMatchQ" -> TrueQ[paperResidual === 0]
        |>
      ],
      "NormalizedInterference" -> Lookup[record, "NormalizedInterference",
        Missing["NotAvailable"]],
      "PackageExtractedAntenna" -> Lookup[record, "ExtractedAntenna",
        Missing["NotAvailable"]],
      "ThesisTarget" -> MassiveA30ThesisTarget[quarkMass -> qm]
    |>
  ];

(* MassiveA30ReconstructionRecord[...]
   ===================================
   Collect the major intermediate objects of the massive A30 reconstruction in
   one provenance association. *)
MassiveA30ReconstructionRecord[OptionsPattern[]] :=
  Module[{qm, amplitude, bornAmplitude, selfInterference, extraction},
    qm = OptionValue[quarkMass];
    amplitude =
      MassiveA30TreeAmplitude[quarkMass -> qm,
        printDiagram -> OptionValue[printDiagram],
        ApplyStripCouplings -> OptionValue[ApplyStripCouplings]];
    bornAmplitude =
      MassiveA30BornAmplitude[quarkMass -> qm,
        ApplyStripCouplings -> OptionValue[ApplyStripCouplings]];
    selfInterference =
      MassiveA30SelfInterference[quarkMass -> qm,
        ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
        ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
        ApplyDimReg -> OptionValue[ApplyDimReg]];
    extraction =
      MassiveA30ExtractionAssociation[quarkMass -> qm,
        ApplyStripCouplings -> OptionValue[ApplyStripCouplings],
        ApplyCasimirSubstitution -> OptionValue[ApplyCasimirSubstitution],
        ApplyDimReg -> OptionValue[ApplyDimReg]];
    <|
      "Key" -> {A, 3, 0},
      "quarkMass" -> qm,
      "Diagrams" -> MassiveA30TreeDiagrams[],
      "Amplitude" -> amplitude,
      "BornAmplitude" -> bornAmplitude,
      "RawInterference" -> selfInterference,
      "BornInterference" -> extraction["BornInterference"],
      "NormalizedInterference" -> Lookup[extraction,
        "NormalizedInterference", Missing["NotAvailable"]],
      "ExtractedAntenna" -> Lookup[extraction["Components"], "Antenna",
        extraction["Components"]],
      "ExtractionDiagnostics" -> extraction["Diagnostics"],
      "ThesisTargets" -> <|
        "SquaredMatrixElementBracket" ->
          MassiveA30SquaredMatrixElementPaperBracket[],
        "BornNormalization" -> MassiveA30BornNormalizationPaper[],
        "Antenna" -> MassiveA30UnintegratedPaperConvention[]
      |>
    |>
  ];
