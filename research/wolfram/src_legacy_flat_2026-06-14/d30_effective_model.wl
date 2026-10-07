D30EffectiveModelDirectory::usage =
  "D30EffectiveModelDirectory[] returns the repo-local directory containing the effective FeynArts model files for the D30 source process.";

D30EffectiveModelName::usage =
  "D30EffectiveModelName[] returns the classes-model name used for the repo-local D30 source model.";

D30EffectiveGenericModelName::usage =
  "D30EffectiveGenericModelName[] returns the generic-model name used for the repo-local D30 source model.";

EnsureD30EffectiveModelPath::usage =
  "EnsureD30EffectiveModelPath[] prepends the repo-local D30 effective-model directory to $ModelPath when needed and returns the directory path.";

D30EffectiveModelSpec::usage =
  "D30EffectiveModelSpec[] returns an association describing the repo-local D30 effective FeynArts model.";

D30EffectiveModelFilesExistQ::usage =
  "D30EffectiveModelFilesExistQ[] returns True when the repo-local D30 effective model files are present.";

D30EffectiveSourceInsertions::usage =
  "D30EffectiveSourceInsertions[numFinalParticles] generates the tree-level FeynArts field insertions for the neutralino source process in the repo-local D30 effective model.";

D30EffectiveSourceAmplitude::usage =
  "D30EffectiveSourceAmplitude[numFinalParticles] generates the converted FeynCalc amplitude for the neutralino source process in the repo-local D30 effective model.";

D30SourcePolarizationCanonicalize::usage =
  "D30SourcePolarizationCanonicalize[expr] rewrites the source-model polarization labels to the outgoing-momentum convention expected by the package summation helpers.";

D30SourceCanonicalKinematicRules::usage =
  "D30SourceCanonicalKinematicRules[numFinalParticles] returns the additional source-process scalar-product rules involving the incoming neutralino momentum p.";

D30SourceMassRules::usage =
  "D30SourceMassRules[] returns the source-process mass substitutions used to reach the massless D30 source convention.";

D30SourceAmplitudeTerms::usage =
  "D30SourceAmplitudeTerms[numFinalParticles] returns the expanded source-amplitude terms used by the D30 source-interference builder.";

D30SourceRenameSUNIndices::usage =
  "D30SourceRenameSUNIndices[expr] renames the explicit SUN indices in one source amplitude copy so self-interference products do not violate Einstein summation.";

D30SourceInterferencePair::usage =
  "D30SourceInterferencePair[leftTerm, rightTerm, numFinalParticles] evaluates one source-model interference pair for the D30 reconstruction track.";

D30SourceSelfInterference::usage =
  "D30SourceSelfInterference[numFinalParticles] builds the summed source-model self-interference for the D30 reconstruction track.";

D30EffectiveModelDirectory[] :=
  FileNameJoin[{$AntennaPipelineRoot, "models"}];

D30EffectiveModelName[] :=
  "D30Effective";

D30EffectiveGenericModelName[] :=
  "D30Effective";

EnsureD30EffectiveModelPath[] :=
  Module[{modelDir},
    modelDir = D30EffectiveModelDirectory[];
    If[!MemberQ[$ModelPath, modelDir],
      PrependTo[$ModelPath, modelDir]
    ];
    modelDir
  ];

D30EffectiveModelSpec[] :=
  <|
    "Directory" -> EnsureD30EffectiveModelPath[],
    "Model" -> D30EffectiveModelName[],
    "GenericModel" -> D30EffectiveGenericModelName[],
    "ModelFile" -> FileNameJoin[{D30EffectiveModelDirectory[],
      D30EffectiveModelName[] <> ".mod"}],
    "GenericFile" -> FileNameJoin[{D30EffectiveModelDirectory[],
      D30EffectiveGenericModelName[] <> ".gen"}]
  |>;

D30EffectiveModelFilesExistQ[] :=
  Module[{spec},
    spec = D30EffectiveModelSpec[];
    AllTrue[{spec["ModelFile"], spec["GenericFile"]}, FileExistsQ]
  ];

D30EffectiveSourceInsertions[numFinalParticles_Integer /;
    MemberQ[{2, 3}, numFinalParticles]] :=
  Module[{spec, finalState},
    spec = D30EffectiveModelSpec[];
    finalState = Join[{F[2], V[1]}, Table[V[1], {numFinalParticles - 2}]];
    InsertFields[
      CreateTopologies[0, 1 -> numFinalParticles],
      {F[1]} -> finalState,
      InsertionLevel -> {Classes},
      Model -> spec["Model"],
      GenericModel -> spec["GenericModel"]
    ]
  ];

D30EffectiveSourceAmplitude[numFinalParticles_Integer /;
    MemberQ[{2, 3}, numFinalParticles]] :=
  Module[{insertions, outMoms},
    insertions = D30EffectiveSourceInsertions[numFinalParticles];
    outMoms = Table[Symbol["k" <> ToString[i]], {i, 1, numFinalParticles}];
    FCFAConvert[
      CreateFeynAmp[insertions],
      IncomingMomenta -> {p},
      OutgoingMomenta -> outMoms,
      UndoChiralSplittings -> True,
      ChangeDimension -> D,
      List -> False,
      SMP -> True,
      Contract -> True,
      DropSumOver -> True
    ]
  ];

D30SourcePolarizationCanonicalize[expr_] :=
  expr /. Polarization[-mom_, phase_] :> Polarization[mom, phase];

D30SourceCanonicalKinematicRules[2] :=
  {
    Pair[Momentum[p, _], Momentum[p, _]] -> q2,
    Pair[Momentum[p, _], Momentum[k1, _]] -> q2 / 2,
    Pair[Momentum[k1, _], Momentum[p, _]] -> q2 / 2,
    Pair[Momentum[p, _], Momentum[k2, _]] -> q2 / 2,
    Pair[Momentum[k2, _], Momentum[p, _]] -> q2 / 2
  };

D30SourceCanonicalKinematicRules[3] :=
  {
    Pair[Momentum[p, _], Momentum[p, _]] -> q2,
    Pair[Momentum[p, _], Momentum[k1, _]] -> (s12 + s13) / 2,
    Pair[Momentum[k1, _], Momentum[p, _]] -> (s12 + s13) / 2,
    Pair[Momentum[p, _], Momentum[k2, _]] -> (s12 + s23) / 2,
    Pair[Momentum[k2, _], Momentum[p, _]] -> (s12 + s23) / 2,
    Pair[Momentum[p, _], Momentum[k3, _]] -> (s13 + s23) / 2,
    Pair[Momentum[k3, _], Momentum[p, _]] -> (s13 + s23) / 2
  };

D30SourceCanonicalKinematicRules[_] :=
  {};

D30SourceMassRules[] :=
  {MGl -> 0, MNeu^2 -> q2};

D30SourceAmplitudeTerms[numFinalParticles_Integer /; MemberQ[{2, 3}, numFinalParticles]] :=
  AmplitudeTerms[
    Expand[D30SourcePolarizationCanonicalize[D30EffectiveSourceAmplitude[
      numFinalParticles]]]
  ];

D30SourceRenameSUNIndices[expr_] :=
  Module[{indices, rules},
    indices =
      DeleteDuplicates[
        Cases[
          expr,
          head_Symbol[sym_Symbol] /; SymbolName[head] === "SUNIndex" :>
            head[sym],
          Infinity
        ]
      ];
    rules =
      Thread[
        indices ->
          (indices /. head_[sym_Symbol] :>
            head[Unique[SymbolName[sym] <> "$r"]])
      ];
    expr /. rules
  ];

D30SourceInterferencePair[leftTerm_, rightTerm_,
   numFinalParticles_Integer /; MemberQ[{2, 3}, numFinalParticles]] :=
  Module[{left, bare, summed, polarized, expanded, evaluated, gluonMomenta,
     final},
    KinematicRules[numFinalParticles];
    left = D30SourceRenameSUNIndices[leftTerm];
    bare = ComplexConjugate[left] * rightTerm;
    summed =
      bare //
      SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
      FermionSpinSum;
    gluonMomenta =
      If[numFinalParticles === 2,
        {k2},
        {k2, k3}
      ];
    polarized =
      Fold[
        SafeDoPolarizationSums[#1, #2, 0, VirtualBoson -> True]&,
        summed,
        gluonMomenta
      ];
    expanded = DiracSigmaExplicit[polarized];
    evaluated = Calc[expanded];
    final =
      evaluated //
      ApplyFeynCalcRules[#, numFinalParticles]& //
      ReplaceAll[D30SourceCanonicalKinematicRules[numFinalParticles]] //
      ReplaceAll[D30SourceMassRules[]] //
      ReplaceAll[CasimirSubs] //
      ReplaceAll[D -> 4 - 2 Epsilon] //
      SUNSimplify //
      Together;
    final
  ];

D30SourceSelfInterference[numFinalParticles_Integer /; MemberQ[{2, 3}, numFinalParticles]] :=
  Module[{terms, nTerms, diagonal, offDiagonal, result},
    terms = D30SourceAmplitudeTerms[numFinalParticles];
    nTerms = Length[terms];
    diagonal =
      Sum[
        D30SourceInterferencePair[terms[[i]], terms[[i]], numFinalParticles],
        {i, 1, nTerms}
      ];
    offDiagonal =
      Sum[
        2 D30SourceInterferencePair[terms[[i]], terms[[j]], numFinalParticles],
        {i, 1, nTerms - 1},
        {j, i + 1, nTerms}
      ];
    result =
      diagonal + offDiagonal //
      SUNSimplify //
      Together;
    result
  ];
