AssignAntennaProductionVariables::usage =
  "AssignAntennaProductionVariables[] populates the legacy global antenna symbols from the current public build routes.";

(*************************************************)

(*
  File role and communication map
  -------------------------------
  This file communicates with:
    - src/core/profiles.wl through AntennaAmplitude[...] and
      AntennaSelfInterference[...].
    - src/routes/build_workflows.wl through BuildAntennaData[...] and
      BuildAntennaResult[...].
    - AntennaPipeline.wl, which loads this file after the build stack exists.

  Why this file exists:
  The layered package intentionally moved away from eager global variables,
  because building every antenna at load time is expensive and obscures data
  flow.  This helper preserves the old notebook ergonomics on demand without
  forcing the modern public API to adopt that eager, stateful behavior.

  Optional notebook-style production assignments.
  Loading AntennaPipeline.wl deliberately does not build any antennae.  Call
  AssignAntennaProductionVariables[] when you want the old public variables
  A20, A30, A40, tildeA40, B40, and C40 to be populated in the
  current kernel.
*)

(*************************************************)

(* AssignAntennaProductionVariables[]
   ==================================
   Summary
     Populate the legacy notebook-facing global symbols with amplitudes,
     interferences, build records, and final antenna expressions produced by
     the current layered pipeline.

   Returns
     List
       `{A20, A30, A40, tildeA40, B40, C40}` after the side-effectful global
       assignments have been made.

   Notes
     This function is intentionally side-effectful.  That is a usability choice
     for interactive notebooks, where users often want to inspect the old symbol
     names directly.  The production routers avoid this pattern so route calls
     remain explicit and reproducible. *)
AssignAntennaProductionVariables[] :=
  Module[{},
    (* First expose the raw amplitudes and self-interferences, because older
       exploratory notebooks often inspect these intermediate objects to track
       where a normalization or colour factor entered. *)
    M20 = AntennaAmplitude[{A, 2, 0}];
    M30 = AntennaAmplitude[{A, 3, 0}];
    M40 = AntennaAmplitude[{A, 4, 0}];
    M40BType = AntennaAmplitude[{B, 4, 0}];
    M40CType = AntennaAmplitude[{C, 4, 0}];

    SelfInterfM20 = AntennaSelfInterference[{A, 2, 0}];
    SelfInterfM30 = AntennaSelfInterference[{A, 3, 0}];
    SelfInterfM40 = AntennaSelfInterference[{A, 4, 0}];
    SelfInterfM40B = AntennaSelfInterference[{B, 4, 0}];
    SelfInterfM40C = AntennaSelfInterference[{C, 4, 0}];
    Tqq2 = SelfInterfM20;

    (* Then cache the structured build data, not just the final antennae.
       Keeping these objects around is useful when a future notebook session
       needs to inspect sector splits, colour diagnostics, or intermediate
       decomposition choices without re-running the entire route. *)
    A20Build = BuildAntennaData[{A, 2, 0}];
    A30Build = BuildAntennaData[{A, 3, 0}];
    A40Build = BuildAntennaData[{A, 4, 0}];
    B40Build = BuildAntennaData[{B, 4, 0}];
    C40Build = BuildAntennaData[{C, 4, 0}];

    A20 = BuildAntennaResult[{A, 2, 0}, A20Build];
    A30 = BuildAntennaResult[{A, 3, 0}, A30Build];

    (* A40/B40/C40 expose extra bookkeeping because their physically relevant
       structure is not a single scalar at every intermediate stage.  Preserving
       the split pieces makes the notebook compatibility layer useful for actual
       four-parton debugging rather than just for final-number reproduction. *)
    FullColorLeadCoefficientA40 = A40Build["FullColorComponents"]["Lead"];
    tildeA40 = A40Build["FullColorComponents"]["SubLead"];
    A40QuarkLoopCoefficient = A40Build["FullColorComponents"]["QuarkLoop"];
    A40ColorOrderedData = A40Build["ColorOrderedData"];
    {A40, tildeA40} = BuildAntennaResult[{A, 4, 0}, A40Build];

    B40Full = B40Build["FullComponents"]["Antenna"];
    B40FullColourDiagnostics = B40Build["FullDiagnostics"];
    B40AttachmentParts = B40Build["Sectors"];
    B40AttachmentDiagnostics = B40Build["Diagnostics"];
    B40Primary = B40Build["Components"]["Antenna"];
    B40PrimaryColourDiagnostics = B40Build["Diagnostics"];
    B40 = BuildAntennaResult[{B, 4, 0}, B40Build];

    C40AttachmentParts = C40Build["Sectors"];
    C40SplitDiagnostics = C40Build["Diagnostics"];
    C40Candidate = C40Build["Components"]["Antenna"];
    C40CandidateDiagnostics = C40Build["Diagnostics"];
    C40DirectPrimaryBLike = C40Build["ReferenceSquareComponents"]["Antenna"];
    C40DirectPrimaryBLikeDiagnostics = C40Build["ReferenceSquareDiagnostics"];
    C40 = BuildAntennaResult[{C, 4, 0}, C40Build];

    {A20, A30, A40, tildeA40, B40, C40}
  ];
