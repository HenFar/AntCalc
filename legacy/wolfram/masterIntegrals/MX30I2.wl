mx30I2Directory =
  Replace[
    DirectoryName[$InputFileName],
    "" :> FileNameJoin[{Directory[], "masterIntegrals"}]
  ];

Get[FileNameJoin[{mx30I2Directory, "common.wl"}]];
Get[FileNameJoin[{DirectoryName[mx30I2Directory], "massiveA30", "integrated.wl"}]];

MX30TrialBasisRoot[] :=
  FileNameJoin[{DirectoryName[mx30I2Directory], "generated_bases",
    "MX30"}];

LoadMX30TrialBasis123[] :=
  Module[{path},
    path = FileNameJoin[{MX30TrialBasisRoot[], "MX30Basis123"}];
    If[!FileExistsQ[path],
      Return[$Failed]
    ];
    Get[path]
  ];

MX30I2Source[] :=
  <|
    "PrimaryPdf" -> "0904.3297",
    "Section" -> "5",
    "Context" -> "Integrated massive final-final A30 antenna",
    "GeneratedBasis" -> "MX30Basis123",
    "BackendMaster" -> "j[MX30Basis123, 2, 1, 1, 0, 0]",
    "Status" -> "DerivedRuntimeBridge"
  |>;

MX30I2ExpectedDenominators[] :=
  {
    m2 - sp[p1, p1],
    m2 - sp[p2, p2],
    sp[-p1 - p2 + q, -p1 - p2 + q]
  };

MX30I2BasisDefinition =
  HoldForm[
    j[MX30Basis123, 2, 1, 1, 0, 0]
  ];

MX30I2CutDefinition =
  HoldForm[
    Cut[
      1 / (
        (m2 - p1^2)^2
        (m2 - p2^2)
        ((q - p1 - p2)^2)
      )
    ]
  ];

MX30I2PhysicalRole =
  "The dotted massive runtime master chosen by the current LiteRed basis. It is not the paper numerator master I2^(m,0,m), but its closed form is derived from the explicit numerator reduction and the common MX30 cut-measure factor.";

MX30I2BackendRelation =
  HoldForm[
    MX30I2 == j[MX30Basis123, 2, 1, 1, 0, 0]
  ];

MX30I2BasisCheck[] :=
  Module[{loaded, ds, mis},
    loaded = LoadMX30TrialBasis123[];
    If[loaded === $Failed,
      Return[Missing["BasisNotGenerated"]]
    ];
    ds = Ds[MX30Basis123];
    mis = MIs[MX30Basis123];
    <|
      "DenominatorCheck" ->
        Simplify[Take[ds, 3] - MX30I2ExpectedDenominators[]] === {0, 0, 0},
      "MasterPresentQ" ->
        MemberQ[mis, j[MX30Basis123, 2, 1, 1, 0, 0]]
    |>
  ];

MX30I2RejectedDerivativeAnsatz[] :=
  HoldForm[
    MX30I2 == -(1/2) D[MX30I1, m2]
  ];

MX30I2RejectedDerivativeReason =
  "The derivative relation was a useful trial shortcut, but it does not by itself establish the package dotted master in the exact runtime basis. The acceptance criterion is now the integrated-target match, not the derivative guess.";

MX30I2PaperNumeratorMasterRemark =
  "The paper second master is I2^(m,0,m), a phase-space integral with a numerator invariant insertion. The package second master is instead the dotted basis representative j[MX30Basis123,2,1,1,0,0].";

MX30I2CandidateClosedForm[] :=
  MassiveA30IntegratedRuntimeMasterI2Candidate[];

MX30I2IntegratedTargetCheck[] :=
  <|
    "Status" -> "Deferred",
    "ValidationEntrypoint" -> "MassiveA30IntegratedRuntimeMatchReport[]",
    "Note" ->
      "The dotted master is validated through the dedicated integrated-target bridge check, not inside the lightweight provenance report."
  |>;

MX30I2CandidateStrategy =
  "Reduce the paper numerator master explicitly in MX30Basis123, then apply the common conversion I_paper = -j_MX30/4 verified independently from the undotted and dotted runtime coefficients.";

MX30I2Report[] :=
  <|
    "Source" -> MX30I2Source[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "MX30I2ExpectedDenominators[]",
        "MX30I2BasisCheck[]",
        "MX30I2IntegratedTargetCheck[]"
      },
      "ImportedFromGeneratedBasis" -> {
        "MX30I2BasisDefinition",
        "MX30I2CutDefinition"
      },
      "ProvisionalBridge" -> {
        "MassiveA30IntegratedRuntimeMasterI2Candidate[]"
      },
      "RejectedTrial" -> {
        "MX30I2RejectedDerivativeAnsatz[]"
      }
    |>,
    "BasisDefinition" -> MX30I2BasisDefinition,
    "CutDefinition" -> MX30I2CutDefinition,
    "ExpectedDenominators" -> MX30I2ExpectedDenominators[],
    "PhysicalRole" -> MX30I2PhysicalRole,
    "BackendRelation" -> MX30I2BackendRelation,
    "BasisCheck" -> MX30I2BasisCheck[],
    "PaperNumeratorMasterRemark" -> MX30I2PaperNumeratorMasterRemark,
    "RejectedDerivativeAnsatz" -> MX30I2RejectedDerivativeAnsatz[],
    "RejectedDerivativeReason" -> MX30I2RejectedDerivativeReason,
    "CandidateClosedForm" -> MX30I2CandidateClosedForm[],
    "IntegratedTargetCheck" -> MX30I2IntegratedTargetCheck[],
    "CandidateStrategy" -> MX30I2CandidateStrategy
  |>;

MasterIntegralMX30I2Data[] :=
  MX30I2Report[];
