mx30I1Directory =
  Replace[
    DirectoryName[$InputFileName],
    "" :> FileNameJoin[{Directory[], "masterIntegrals"}]
  ];

Get[FileNameJoin[{mx30I1Directory, "common.wl"}]];
Get[FileNameJoin[{DirectoryName[mx30I1Directory], "massiveA30", "integrated.wl"}]];

MX30TrialBasisRoot[] :=
  FileNameJoin[{DirectoryName[mx30I1Directory], "generated_bases",
    "MX30"}];

LoadMX30TrialBasis123[] :=
  Module[{path},
    path = FileNameJoin[{MX30TrialBasisRoot[], "MX30Basis123"}];
    If[!FileExistsQ[path],
      Return[$Failed]
    ];
    Get[path]
  ];

MX30I1Source[] :=
  <|
    "PrimaryPdf" -> "0904.3297",
    "Section" -> "5",
    "Context" -> "Integrated massive final-final A30 antenna",
    "GeneratedBasis" -> "MX30Basis123",
    "BackendMaster" -> "j[MX30Basis123, 1, 1, 1, 0, 0]",
    "Status" -> "PaperMatchedPhaseSpaceMaster"
  |>;

MX30I1ExpectedDenominators[] :=
  {
    m2 - sp[p1, p1],
    m2 - sp[p2, p2],
    sp[-p1 - p2 + q, -p1 - p2 + q]
  };

MX30I1BasisDefinition =
  HoldForm[
    j[MX30Basis123, 1, 1, 1, 0, 0]
  ];

MX30I1CutDefinition =
  HoldForm[
    Cut[
      1 / (
        (m2 - p1^2)
        (m2 - p2^2)
        ((q - p1 - p2)^2)
      )
    ]
  ];

MX30I1PhysicalRole =
  "The undotted three-cut massive QQbar g phase-space master. In the declared MX30 cut convention it obeys j[MX30Basis123,1,1,1,0,0] = -4 I1^(m,0,m).";

MX30I1BackendRelation =
  HoldForm[
    MX30I1 == j[MX30Basis123, 1, 1, 1, 0, 0]
  ];

MX30I1BasisCheck[] :=
  Module[{loaded, ds, mis},
    loaded = LoadMX30TrialBasis123[];
    If[loaded === $Failed,
      Return[Missing["BasisNotGenerated"]]
    ];
    ds = Ds[MX30Basis123];
    mis = MIs[MX30Basis123];
    <|
      "DenominatorCheck" ->
        Simplify[Take[ds, 3] - MX30I1ExpectedDenominators[]] === {0, 0, 0},
      "MasterPresentQ" ->
        MemberQ[mis, j[MX30Basis123, 1, 1, 1, 0, 0]]
    |>
  ];

MX30I1RejectedTrialAnsatz[] :=
  HoldForm[
    PhaseSpacePrefactor[q2, eps] *
    Integrate[
      u^(1 - 2 eps) (1 - u)^(1 - 2 eps) (1 - u0 u)^(-1 + eps),
      {u, 0, 1}
    ] *
    Integrate[
      v^(-eps) (1 - v)^(-eps),
      {v, 0, 1}
    ]
  ];

MX30I1RejectedTrialReason =
  "The earlier u,v ansatz was fixed only from the massless limit and used the wrong closed-form family for the exact (m,0,m) paper master. It is kept only as a rejected provenance trail.";

MX30I1CandidateClosedForm[] :=
  MassiveA30IntegratedPackageMasterI1Candidate[];

MX30I1MasslessLimitCheck[] :=
  <|
    "Status" -> "Deferred",
    "ValidationEntrypoint" ->
      "Massless-limit checks belong in the dedicated dev validation scripts, not in the lightweight provenance report."
  |>;

MX30I1IntegratedTargetCheck[] :=
  <|
    "Status" -> "Deferred",
    "ValidationEntrypoint" -> "MassiveA30IntegratedRuntimeMatchReport[]",
    "Note" ->
      "The undotted master is accepted through the integrated-target match pipeline, not through a standalone guessed ansatz."
  |>;

MX30I1CandidateStrategy =
  "Use the exact literature phase-space master I1^(m,0,m) as the closed-form candidate for the undotted runtime master after the explicit paper-to-package bridge.";

MX30I1Report[] :=
  <|
    "Source" -> MX30I1Source[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "MX30I1ExpectedDenominators[]",
        "MX30I1BasisCheck[]",
        "MX30I1IntegratedTargetCheck[]"
      },
      "ImportedFromGeneratedBasis" -> {
        "MX30I1BasisDefinition",
        "MX30I1CutDefinition"
      },
      "ImportedFromLiterature" -> {
        "MassiveA30IntegratedPaperMasterI1[]"
      },
      "RejectedTrial" -> {
        "MX30I1RejectedTrialAnsatz[]"
      }
    |>,
    "BasisDefinition" -> MX30I1BasisDefinition,
    "CutDefinition" -> MX30I1CutDefinition,
    "ExpectedDenominators" -> MX30I1ExpectedDenominators[],
    "PhysicalRole" -> MX30I1PhysicalRole,
    "BackendRelation" -> MX30I1BackendRelation,
    "BasisCheck" -> MX30I1BasisCheck[],
    "RejectedTrialAnsatz" -> MX30I1RejectedTrialAnsatz[],
    "RejectedTrialReason" -> MX30I1RejectedTrialReason,
    "CandidateClosedForm" -> MX30I1CandidateClosedForm[],
    "MasslessLimitCheck" -> MX30I1MasslessLimitCheck[],
    "IntegratedTargetCheck" -> MX30I1IntegratedTargetCheck[],
    "CandidateStrategy" -> MX30I1CandidateStrategy
  |>;

MasterIntegralMX30I1Data[] :=
  MX30I1Report[];
