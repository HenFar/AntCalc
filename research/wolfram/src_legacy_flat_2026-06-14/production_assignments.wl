AssignAntennaProductionVariables::usage =
  "AssignAntennaProductionVariables[] populates the legacy global antenna symbols from the current public build routes.";

(*************************************************)

(*
  Optional notebook-style production assignments.
  Loading AntennaPipeline.wl deliberately does not build any antennae.  Call
  AssignAntennaProductionVariables[] when you want the old public variables
  A20, A30, A40, tildeA40, B40, and C40 to be populated in the
  current kernel.
*)

(*************************************************)

AssignAntennaProductionVariables[] :=
  Module[{},
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

    A20Build = BuildAntennaData[{A, 2, 0}];
    A30Build = BuildAntennaData[{A, 3, 0}];
    A40Build = BuildAntennaData[{A, 4, 0}];
    B40Build = BuildAntennaData[{B, 4, 0}];
    C40Build = BuildAntennaData[{C, 4, 0}];

    A20 = BuildAntennaResult[{A, 2, 0}, A20Build];
    A30 = BuildAntennaResult[{A, 3, 0}, A30Build];

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
