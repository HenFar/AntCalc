(*************************************************)

(*
  IBP reduction infrastructure.
  The public integrator dispatches here when ReductionBackend -> IBP.  This
  file is organised around integration profiles: basis loading, term matching,
  reduction, master substitution, and epsilon-series normalisation are kept
  separate so that X40, X31, and A22 can be added without changing the public
  IntegrateAntenna call.
*)

(*************************************************)

EnsureLiteRedLoaded::usage = "EnsureLiteRedLoaded[] lazily loads LiteRed and initializes the minimal symbols needed by the IBP backend.";
LiteRedContextPath::usage = "LiteRedContextPath[] returns the context path used when looking up LiteRed symbols by name.";
LiteRedSymbol::usage = "LiteRedSymbol[name] resolves a LiteRed symbol name string inside the LiteRed context path.";
LiteRedScalarProduct::usage = "LiteRedScalarProduct[a, b] builds the LiteRed scalar-product form used in generated basis definitions.";
MomentumRules::usage = "MomentumRules[numFinalParticles] returns the momentum relabeling rules used when translating package kinematics into the IBP convention.";
PhaseSpace::usage = "PhaseSpace[numFinalParticles] returns the phase-space replacement rules associated with the selected final-state multiplicity.";
MX30CutDenominators::usage = "MX30CutDenominators[mass] returns the three reverse-unitarity cut denominators for the massive final-final A30 family.";
MX30InvariantBridgeRules::usage = "MX30InvariantBridgeRules[mass] returns the explicit massive-A30 invariant-to-basis bridge rules.";
MX30BasisTopologyDenominators::usage = "MX30BasisTopologyDenominators[topology, mass] returns the ordered five-denominator candidate family for one MX30 topology.";
MX30BasisTopologyAssociation::usage = "MX30BasisTopologyAssociation[mass] returns the full topology-to-denominator association for the MX30 family.";
X30BasisTopologyDenominators::usage = "X30BasisTopologyDenominators[topology] returns the ordered five-denominator family used by the massless X30 topology.";
X30BasisTopologyAssociation::usage = "X30BasisTopologyAssociation[] returns the full topology-to-denominator association for the massless X30 family.";
IBPBasisSymbol::usage = "IBPBasisSymbol[topology, ...] returns the LiteRed basis symbol associated with a topology record.";
X30BasisRootCompleteQ::usage = "X30BasisRootCompleteQ[root] tests whether the expected X30 basis files are present under a basis root.";
MX30BasisRootCompleteQ::usage = "MX30BasisRootCompleteQ[root] tests whether the expected MX30 massive-A30 basis files are present under a basis root.";
X40BasisRootCompleteQ::usage = "X40BasisRootCompleteQ[root] tests whether the expected X40 basis files are present under a basis root.";
A31BasisRootCompleteQ::usage = "A31BasisRootCompleteQ[root] tests whether the expected A31 basis files are present under a basis root.";
A22TwoLoopTreeBasisRootCompleteQ::usage = "A22TwoLoopTreeBasisRootCompleteQ[root] tests whether the expected A22 tree/two-loop basis files are present under a basis root.";
DefaultIBPBasisRoot::usage = "DefaultIBPBasisRoot[family] returns the default on-disk basis root for the selected IBP family.";
IBPProfile::usage = "IBPProfile[family] returns the family-specific IBP reduction profile used by the backend.";
MergeIBPProfileOptions::usage = "MergeIBPProfileOptions[profile, opts] merges runtime options into a base IBP profile association.";
IBPBasisRecords::usage = "IBPBasisRecords[profile] returns the ordered basis records that should be loaded for an IBP profile.";
X40BasisPriority::usage = "X40BasisPriority[basis] scores X40 basis names so the shared basis-order optimization can prefer the most useful matches first.";
OrderX40BasisRecords::usage = "OrderX40BasisRecords[records] reorders X40 basis records according to the adopted shared priority scheme.";
LoadSingleIBPBasis::usage = "LoadSingleIBPBasis[record, profile] loads one LiteRed basis record from disk.";
IBPBasisLoadedQ::usage = "IBPBasisLoadedQ[name] returns True when a LiteRed basis symbol is already loaded in the current kernel.";
LoadIBPBases::usage = "LoadIBPBases[profile] loads the full basis family required by an IBP route.";
A22OneLoopSelfDenominators::usage = "A22OneLoopSelfDenominators[] returns the denominator list used to generate the A22 one-loop/self basis.";
InitialiseA22OneLoopSelfKinematics::usage = "InitialiseA22OneLoopSelfKinematics[] sets up the special kinematics used when generating the A22 one-loop/self basis.";
GenerateA22OneLoopSelfBasis::usage = "GenerateA22OneLoopSelfBasis[record, profile] generates the A22 one-loop/self basis from LiteRed in a clean kernel.";
MX30BasisSpecifications::usage = "MX30BasisSpecifications[mass] returns the named topology specifications used by the massive A30 basis generator.";
GenerateMX30Basis::usage = "GenerateMX30Basis[record, profile] generates one MX30 basis from LiteRed in a clean kernel.";
GenerateSingleIBPBasis::usage = "GenerateSingleIBPBasis[record, profile] generates one missing LiteRed basis for the selected profile.";
IBPInvariantRules::usage = "IBPInvariantRules[profile] returns the invariant substitutions used to move package expressions into the IBP convention.";
IBPIndexedInvariantRules::usage = "IBPIndexedInvariantRules[profile] returns indexed invariant substitutions used by the basis-matching helpers.";
IBPPhaseSpace::usage = "IBPPhaseSpace[profile] returns the phase-space rules attached to an IBP profile.";
A31MomentumVector::usage = "A31MomentumVector[expr] normalizes A31 momentum symbols into the vector form expected by LiteRed.";
A31PropagatorToLiteRed::usage = "A31PropagatorToLiteRed[den] rewrites one A31 propagator denominator into the LiteRed denominator convention.";
A31FeynCalcToLiteRed::usage = "A31FeynCalcToLiteRed[term] rewrites one A31 integrand term from FeynCalc syntax into LiteRed syntax.";
PrepareA31IBPTerm::usage = "PrepareA31IBPTerm[term, profile] prepares one A31 term for basis matching and LiteRed reduction.";
CanonicalizeMX30BasisSigns::usage = "CanonicalizeMX30BasisSigns[expr, mass] rewrites massive shifted denominators into the sign convention used by the MX30 LiteRed bases.";
ExpandMX30NumeratorShiftedForms::usage = "ExpandMX30NumeratorShiftedForms[expr, mass] rewrites positive-power shifted MX30 numerator factors into scalar-product form while leaving denominator factors intact.";
PrepareMX30IBPTerm::usage = "PrepareMX30IBPTerm[term, profile] prepares one MX30 term for basis matching and LiteRed reduction.";
A22MomentumVector::usage = "A22MomentumVector[expr] normalizes A22 momentum symbols into the vector form expected by LiteRed.";
A22PropagatorToLiteRed::usage = "A22PropagatorToLiteRed[den] rewrites one A22 propagator denominator into the LiteRed denominator convention.";
A22FeynCalcToLiteRed::usage = "A22FeynCalcToLiteRed[term] rewrites one A22 integrand term from FeynCalc syntax into LiteRed syntax.";
PrepareA22OneLoopSelfIBPTerm::usage = "PrepareA22OneLoopSelfIBPTerm[term, profile] prepares one breve-A22 term for the one-loop/self IBP reduction path.";
CanonicalIBPInvariantSums::usage = "CanonicalIBPInvariantSums[expr] canonicalizes invariant sums before basis matching.";
X30BasisDenominatorIndex::usage = "X30BasisDenominatorIndex[den] returns the X30 denominator slot associated with a propagator denominator.";
X30BasisDenominators::usage = "X30BasisDenominators[] returns the ordered denominator list used by the X30 basis.";
ExpandX30NumeratorScalarProducts::usage = "ExpandX30NumeratorScalarProducts[expr] rewrites X30 numerator scalar products into the basis variable set.";
SplitNegativeProductPowers::usage = "SplitNegativeProductPowers[expr] rewrites products with negative powers into a sum of factorized terms before basis absorption.";
ProductPowerCount::usage = "ProductPowerCount[expr, factor] counts the power of a selected factor inside a product term.";
AbsorbX30BasisDenominatorTerm::usage = "AbsorbX30BasisDenominatorTerm[term] absorbs explicit X30 denominators into the LiteRed basis-index representation.";
AbsorbX30BasisDenominators::usage = "AbsorbX30BasisDenominators[expr, profile] applies the X30 denominator-absorption step to a full expression.";
ShiftJIndex::usage = "ShiftJIndex[jTerm, index, shift] shifts one LiteRed j-index by the requested amount.";
ShiftX30JIndex::usage = "ShiftX30JIndex[jTerm, index, shift] is the X30-specific wrapper used when adjusting LiteRed j-indices.";
AbsorbBasisDenominatorTerm::usage = "AbsorbBasisDenominatorTerm[term, basis] absorbs explicit denominators into the index structure of a generic LiteRed basis term.";
AbsorbBasisDenominators::usage = "AbsorbBasisDenominators[expr, basis, profile] applies denominator absorption to a full expression after basis matching.";
IBPVectorCoefficient::usage = "IBPVectorCoefficient[vec, mom] returns the coefficient of one momentum vector inside a LiteRed scalar-product expression.";
IBPScalarProductMomenta::usage = "IBPScalarProductMomenta[profile] returns the momentum list used to resolve scalar products for an IBP family.";
IBPScalarProductVariables::usage = "IBPScalarProductVariables[momenta] returns the scalar-product variables associated with a list of momenta.";
IBPScalarProductVariableList::usage = "IBPScalarProductVariableList[momenta] flattens the scalar-product variables into a list convenient for Collect and Solve.";
IBPScalarProductExternalEquations::usage = "IBPScalarProductExternalEquations[momenta, profile] returns the external kinematic equations used when simplifying IBP scalar products.";
IBPScalarProductAlgebra::usage = "IBPScalarProductAlgebra[expr, ...] expands LiteRed scalar products into the chosen basis variables.";
IBPScalarProductBasisRules::usage = "IBPScalarProductBasisRules[basis, profile] returns the scalar-product rewrite rules attached to one basis.";
RewriteScalarProductsToBasis::usage = "RewriteScalarProductsToBasis[expr, basis, ...] rewrites scalar products so the selected basis can match the term.";
PrepareIBPTerm::usage = "PrepareIBPTerm[term, profile] prepares one generic term for basis matching and LiteRed reduction.";
MatchIBPBasis::usage = "MatchIBPBasis[term, bases, profile] finds the first basis that can represent a prepared IBP term.";
isBasisChainOrBox::usage = "isBasisChainOrBox[basis] returns True when a basis belongs to the chain or box X40 topologies.";
mastersSub4FP::usage = "mastersSub4FP[basis, numLoops] returns the four-parton master-substitution rule set associated with a matched X40 basis.";
A31MasterRules::usage = "A31MasterRules[] returns the master-replacement rules used by the A31 IBP route.";
A22OneLoopSelfMasterRules::usage = "A22OneLoopSelfMasterRules[] returns the master-replacement rules used by the breve-A22 one-loop/self route.";
A22LoopMixedDenominatorQ::usage = "A22LoopMixedDenominatorQ[den] tests whether an A22 denominator mixes the two loop momenta.";
A22DisconnectedBubbleMasterQ::usage = "A22DisconnectedBubbleMasterQ[activeDenominators] identifies the factorized two-bubble master used by the A22 one-loop/self route.";
A22TwoLoopTreeGetVector::usage = "A22TwoLoopTreeGetVector[expr] extracts the vector head used when canonicalizing A22 denominators.";
A22TwoLoopTreeCanonicalDenominatorString::usage = "A22TwoLoopTreeCanonicalDenominatorString[den] converts one denominator into the canonical string key used by the A22 exact-topology tables.";
A22TwoLoopTreeActiveDenominators::usage = "A22TwoLoopTreeActiveDenominators[master, basis] returns the active denominators present in an A22 tree/two-loop master.";
A22TwoLoopTreeActiveDenominatorSignature::usage = "A22TwoLoopTreeActiveDenominatorSignature[master, basis] returns the normalized signature used to classify A22 tree/two-loop masters.";
A22TwoLoopTreeExactTopologyLabel::usage = "A22TwoLoopTreeExactTopologyLabel[master, basis] maps an A22 master to the exact-topology label used by the encoded notebook data.";
A22TwoLoopTreeValueForExactTopology::usage = "A22TwoLoopTreeValueForExactTopology[label] returns the encoded value for one A22 exact-topology class.";
A22TwoLoopTreeExactTopologyLabels::usage = "A22TwoLoopTreeExactTopologyLabels[] returns the full list of encoded A22 exact-topology labels.";
A22TwoLoopTreeSimplifySp::usage = "A22TwoLoopTreeSimplifySp[expr] applies the special scalar-product simplification rules used by the A22 tree/two-loop backend.";
A22TwoLoopTreeRefinedMasterValue::usage = "A22TwoLoopTreeRefinedMasterValue[master, basis] returns the refined encoded value for one matched A22 tree/two-loop master.";
A22TwoLoopTreeMasterRulesForBasis::usage = "A22TwoLoopTreeMasterRulesForBasis[basis] returns the basis-local master substitution rules used by the A22 tree/two-loop backend.";
IBPMasterRulesForBasis::usage = "IBPMasterRulesForBasis[basis, profile] returns the master substitution rules used for one matched basis.";
IBPMasterRules::usage = "IBPMasterRules[profile] returns the profile-level master substitution rules used after LiteRed reduction.";
IBPX40MasterCoefficientRules::usage = "IBPX40MasterCoefficientRules[] returns the coefficient normalizations used when mapping X40 masters into the paper convention.";
DefaultRuntimeMasterValuesPath::usage = "DefaultRuntimeMasterValuesPath[] returns the checked-in runtime master-values artifact path under masterIntegrals/.";
RuntimeMasterValuesValidQ::usage = "RuntimeMasterValuesValidQ[data] returns True when a loaded runtime master-values artifact is structurally usable.";
LoadRuntimeMasterValues::usage = "LoadRuntimeMasterValues[] loads and memoizes the checked-in runtime master-values artifact exported from masterIntegrals/.";
RuntimeMasterValue::usage = "RuntimeMasterValue[group, key] returns one runtime master expression from the exported master-values artifact.";
A31Ceps::usage = "A31Ceps[] returns the epsilon-dependent normalization factor used by the A31 master convention.";
A31SGamma2::usage = "A31SGamma2[] returns the gamma-function normalization factor used by the A31 master convention.";
A31MasterCoefficientRules::usage = "A31MasterCoefficientRules[] returns the coefficient normalizations used when mapping A31 masters into the paper convention.";
A22LOMasterCore::usage = "A22LOMasterCore[] returns the encoded core series for the A22_LO virtual master.";
A22SGamma::usage = "A22SGamma[] returns the gamma-function normalization factor used by the A22 master convention.";
A22TwoLoopTreeMasterCoreA22LO::usage = "A22TwoLoopTreeMasterCoreA22LO[] returns the encoded core series for the A22 tree/two-loop A22_LO master.";
A22TwoLoopTreeMasterCoreA3::usage = "A22TwoLoopTreeMasterCoreA3[] returns the encoded core series for the A22 tree/two-loop A3 master.";
A22TwoLoopTreeMasterCoreA4::usage = "A22TwoLoopTreeMasterCoreA4[] returns the encoded core series for the A22 tree/two-loop A4 master.";
A22TwoLoopTreeMasterCoreA6::usage = "A22TwoLoopTreeMasterCoreA6[] returns the encoded core series for the A22 tree/two-loop A6 master.";
A22VirtualTwoPartonConventionFactor::usage = "A22VirtualTwoPartonConventionFactor[] returns the virtual two-parton normalization factor used in the A22 notebook convention.";
A22TwoLoopTreeVirtualConventionFactor::usage = "A22TwoLoopTreeVirtualConventionFactor[] returns the tree/two-loop normalization factor used by the A22 exact-topology data.";
A22TwoLoopTreePaperConventionRules::usage = "A22TwoLoopTreePaperConventionRules[expr] rewrites an A22 tree/two-loop expression into the paper normalization convention.";
A22TwoLoopTreePaperConventionFactor::usage = "A22TwoLoopTreePaperConventionFactor[] returns the overall factor needed to move an A22 tree/two-loop master into the paper convention.";
A22TwoLoopTreeMasterValueA22LO::usage = "A22TwoLoopTreeMasterValueA22LO[] returns the encoded paper-convention value of the A22_LO master.";
A22TwoLoopTreeMasterValueA3::usage = "A22TwoLoopTreeMasterValueA3[] returns the encoded paper-convention value of the A3 master.";
A22TwoLoopTreeMasterValueA4::usage = "A22TwoLoopTreeMasterValueA4[] returns the encoded paper-convention value of the A4 master.";
A22TwoLoopTreeMasterValueA6::usage = "A22TwoLoopTreeMasterValueA6[] returns the encoded paper-convention value of the A6 master.";
A22TwoLoopTreeMasterValueA22LOQQ::usage = "A22TwoLoopTreeMasterValueA22LOQQ[] returns the encoded value of the quark-loop variant of the A22_LO master.";
A22TwoLoopTreeMasterValueA3Basis15Like::usage = "A22TwoLoopTreeMasterValueA3Basis15Like[] returns the encoded value for the A3 basis-15-like topology.";
A22TwoLoopTreeMasterValueA3Sunset::usage = "A22TwoLoopTreeMasterValueA3Sunset[] returns the encoded value for the A3 sunset topology.";
A22TwoLoopTreeMasterValueA3Basis7Like::usage = "A22TwoLoopTreeMasterValueA3Basis7Like[] returns the encoded value for the A3 basis-7-like topology.";
A22TwoLoopTreeMasterValueA3Basis8Like::usage = "A22TwoLoopTreeMasterValueA3Basis8Like[] returns the encoded value for the A3 basis-8-like topology.";
A22TwoLoopTreeMasterValueA4NfLike::usage = "A22TwoLoopTreeMasterValueA4NfLike[] returns the encoded value for the A4 Nf-like topology.";
A22TwoLoopTreeMasterValueA4Basis46Like::usage = "A22TwoLoopTreeMasterValueA4Basis46Like[] returns the encoded value for the A4 basis-46-like topology.";
A22TwoLoopTreeMasterValueA4Basis7Like::usage = "A22TwoLoopTreeMasterValueA4Basis7Like[] returns the encoded value for the A4 basis-7-like topology.";
A22TwoLoopTreeMasterValueA4Basis8Like::usage = "A22TwoLoopTreeMasterValueA4Basis8Like[] returns the encoded value for the A4 basis-8-like topology.";
A22TwoLoopTreeMasterValueA6Basis8Like::usage = "A22TwoLoopTreeMasterValueA6Basis8Like[] returns the encoded value for the A6 basis-8-like topology.";
A22OneLoopSelfMasterCoefficientRules::usage = "A22OneLoopSelfMasterCoefficientRules[] returns the coefficient rules used to map the breve-A22 master into the paper convention.";
A22TwoLoopTreeMasterCoefficientRules::usage = "A22TwoLoopTreeMasterCoefficientRules[] returns the coefficient rules used to map A22 tree/two-loop masters into the paper convention.";
IBPMasterValues::usage = "IBPMasterValues[profile] returns the master-value association used after coefficient rules and master matching are chosen.";
IBPPhaseSpaceMeasure::usage = "IBPPhaseSpaceMeasure[numFinalParticles] returns the analytic phase-space measure factor used by the IBP series normalizer.";
IBPNormalization::usage = "IBPNormalization[profile] returns the overall normalization factor applied after LiteRed reduction.";
IBPToSeries::usage = "IBPToSeries[reduced, profile] converts a reduced master combination into the final epsilon series returned publicly.";
IBPToSeriesWithDiagnostics::usage = "IBPToSeriesWithDiagnostics[rawReduced, reduced, profile] converts a reduced master combination into a final series while recording timing and size diagnostics.";
IBPReductionStages::usage = "IBPReductionStages[rawReduced, reduced, profile] returns the named post-reduction stages recorded in backend diagnostics.";
IntegrateViaIBP::usage = "IntegrateViaIBP[antenna, ...] runs the full LiteRed-backed IBP integration pipeline.";
ReduceAntennaIBP::usage = "ReduceAntennaIBP[antenna, numFinalParticles, numLoops] is the legacy reduction helper kept for the original notebooks.";
basisMatch::usage = "basisMatch[term, basesList] is the legacy basis-matching helper kept for older notebook-driven IBP tests.";
reduceAntenna::usage = "reduceAntenna[antenna, numFinalParticles, numLoops] is the legacy top-level reduction helper kept for older notebook-driven IBP tests.";

(*************************************************)

(* LiteRed general setup, loaded only when the IBP backend is called. *)

EnsureLiteRedLoaded[] :=
  Module[{},
    If[Length[DownValues[LiteRed`Toj]] == 0,
      Quiet[
        Block[{$Output = {}},
          Get["LiteRed2`"]
        ]
      ]
    ];
    If[!MemberQ[$ContextPath, "LiteRed`"],
      AppendTo[$ContextPath, "LiteRed`"]
    ];
    Quiet[LiteRed`Declare[q2, Number]];
    Quiet[LiteRed`sp[q, q] = q2];
  ];

LiteRedContextPath[] :=
  {"LiteRed`", "Vectors`", "Numbers`", "LinearFunctions`", "Types`",
    "System`"};

LiteRedSymbol[name_String] :=
  Block[{$ContextPath = LiteRedContextPath[]},
    ToExpression[name]
  ];

LiteRedScalarProduct[a_, b_] :=
  LiteRedSymbol["sp"][a, b];

(*************************************************)

(* Aux functions *)

MomentumRules[numFinalParticles_] :=
  Switch[numFinalParticles,
    2,
      {p[1] -> p1, p[2] -> q - p1}
    ,
    3,
      {p[1] -> p1, p[2] -> p2, p[3] -> q - p1 - p2}
    ,
    4,
      {p[1] -> p1, p[2] -> p2, p[3] -> p3, p[4] -> q - p1 - p2 - p3}
  ];

PhaseSpace[numFinalParticles_] :=
  Switch[numFinalParticles,
    2,
      LiteRed`sp[p1, p1] LiteRed`sp[q - p1, q - p1]
    ,
    3,
      LiteRed`sp[p1, p1] LiteRed`sp[p2, p2] LiteRed`sp[q - p1 - p2, q
         - p1 - p2]
    ,
    4,
      LiteRed`sp[p1, p1] LiteRed`sp[p2, p2] LiteRed`sp[p3, p3] LiteRed`sp[
        q - p1 - p2 - p3, q - p1 - p2 - p3]
  ];

MX30CutDenominators[mass_:quarkMass^2] :=
  {
    mass - LiteRed`sp[p1, p1],
    mass - LiteRed`sp[p2, p2],
    LiteRed`sp[-p1 - p2 + q, -p1 - p2 + q]
  };

MX30InvariantBridgeRules[mass_:quarkMass^2] :=
  {
    s12 -> -(2 mass - LiteRed`sp[p1 + p2, p1 + p2]),
    s13 -> -(mass - LiteRed`sp[-p2 + q, -p2 + q]),
    s23 -> -(mass - LiteRed`sp[-p1 + q, -p1 + q]),
    q2 -> LiteRed`sp[q, q]
  };

X30BasisTopologyDenominators[topology_List] :=
  Switch[topology,
    {1, 2, 3},
      {
        LiteRed`sp[p1, p1],
        LiteRed`sp[p2, p2],
        LiteRed`sp[-p1 - p2 + q, -p1 - p2 + q],
        LiteRed`sp[-p2 + q, -p2 + q],
        LiteRed`sp[-p1 + q, -p1 + q]
      }
    ,
    {1, 3, 2},
      {
        LiteRed`sp[p1, p1],
        LiteRed`sp[p2, p2],
        LiteRed`sp[-p1 - p2 + q, -p1 - p2 + q],
        LiteRed`sp[p1 + p2, p1 + p2],
        LiteRed`sp[-p1 + q, -p1 + q]
      }
    ,
    {2, 1, 3},
      {
        LiteRed`sp[p1, p1],
        LiteRed`sp[p2, p2],
        LiteRed`sp[-p1 - p2 + q, -p1 - p2 + q],
        LiteRed`sp[-p1 + q, -p1 + q],
        LiteRed`sp[-p2 + q, -p2 + q]
      }
    ,
    {2, 3, 1},
      {
        LiteRed`sp[p1, p1],
        LiteRed`sp[p2, p2],
        LiteRed`sp[-p1 - p2 + q, -p1 - p2 + q],
        LiteRed`sp[p1 + p2, p1 + p2],
        LiteRed`sp[-p2 + q, -p2 + q]
      }
    ,
    {3, 1, 2},
      {
        LiteRed`sp[p1, p1],
        LiteRed`sp[p2, p2],
        LiteRed`sp[-p1 - p2 + q, -p1 - p2 + q],
        LiteRed`sp[-p1 + q, -p1 + q],
        LiteRed`sp[p1 + p2, p1 + p2]
      }
    ,
    {3, 2, 1},
      {
        LiteRed`sp[p1, p1],
        LiteRed`sp[p2, p2],
        LiteRed`sp[-p1 - p2 + q, -p1 - p2 + q],
        LiteRed`sp[-p2 + q, -p2 + q],
        LiteRed`sp[p1 + p2, p1 + p2]
      }
    ,
    _,
      Missing["UnknownX30Topology", topology]
  ];

X30BasisTopologyAssociation[] :=
  AssociationMap[X30BasisTopologyDenominators, Permutations[{1, 2, 3}]];

MX30BasisTopologyDenominators[topology_List, mass_:quarkMass^2] :=
  Switch[topology,
    {1, 2, 3},
      Join[
        MX30CutDenominators[mass],
        {
          mass - LiteRed`sp[-p2 + q, -p2 + q],
          mass - LiteRed`sp[-p1 + q, -p1 + q]
        }
      ]
    ,
    {1, 3, 2},
      Join[
        MX30CutDenominators[mass],
        {
          2 mass - LiteRed`sp[p1 + p2, p1 + p2],
          mass - LiteRed`sp[-p1 + q, -p1 + q]
        }
      ]
    ,
    {2, 1, 3},
      Join[
        MX30CutDenominators[mass],
        {
          mass - LiteRed`sp[-p1 + q, -p1 + q],
          mass - LiteRed`sp[-p2 + q, -p2 + q]
        }
      ]
    ,
    {2, 3, 1},
      Join[
        MX30CutDenominators[mass],
        {
          2 mass - LiteRed`sp[p1 + p2, p1 + p2],
          mass - LiteRed`sp[-p2 + q, -p2 + q]
        }
      ]
    ,
    {3, 1, 2},
      Join[
        MX30CutDenominators[mass],
        {
          mass - LiteRed`sp[-p1 + q, -p1 + q],
          2 mass - LiteRed`sp[p1 + p2, p1 + p2]
        }
      ]
    ,
    {3, 2, 1},
      Join[
        MX30CutDenominators[mass],
        {
          mass - LiteRed`sp[-p2 + q, -p2 + q],
          2 mass - LiteRed`sp[p1 + p2, p1 + p2]
        }
      ]
    ,
    _,
      Missing["UnknownMX30Topology", topology]
  ];

MX30BasisTopologyAssociation[mass_:quarkMass^2] :=
  AssociationMap[MX30BasisTopologyDenominators[#, mass]&, Permutations[{1, 2, 3}]];

(*************************************************)

(* IBP profiles *)

IBPBasisSymbol[topology_List, prefix_String] :=
  Symbol[prefix <> "Basis" <> StringJoin[ToString /@ topology]];

IBPBasisSymbol[topology_List, profile_Association, basisClass_:None] :=
  Switch[profile["BasisFamily"],
    "X40",
      Symbol[ToString[basisClass] <> "Basis" <> StringJoin[ToString /@
         topology]]
    ,
    _,
      IBPBasisSymbol[topology, profile["BasisPrefix"]]
  ];

X30BasisRootCompleteQ[root_String] :=
  Module[{topologies, files},
    topologies = Permutations[{1, 2, 3}];
    files =
      Table[
        With[{name = "NLOBasis" <> StringJoin[ToString /@ topologies[[
          i]]]},
          FileNameJoin[{root, name, name}]
        ]
        ,
        {i, Length[topologies]}
      ];
    And @@ (FileExistsQ /@ files)
  ];

MX30BasisRootCompleteQ[root_String] :=
  Module[{topologies, files},
    topologies = Permutations[{1, 2, 3}];
    files =
      Table[
        With[{name = "MX30Basis" <> StringJoin[ToString /@ topologies[[i]]]},
          FileNameJoin[{root, name}]
        ]
        ,
        {i, Length[topologies]}
      ];
    And @@ (FileExistsQ /@ files)
  ];

X40BasisRootCompleteQ[root_String] :=
  Module[{topologies, classes, files},
    topologies = Permutations[{1, 2, 3, 4}];
    classes = {chain, box, hybrid};
    files =
      Flatten[
        Table[
          With[{name = ToString[classes[[j]]] <> "Basis" <>
              StringJoin[ToString /@ topologies[[i]]]},
            FileNameJoin[{root, name, name}]
          ]
          ,
          {i, Length[topologies]}, {j, Length[classes]}
        ]
      ];
    And @@ (FileExistsQ /@ files)
  ];

A31BasisRootCompleteQ[root_String] :=
  Module[{leading, subleading, super, files},
    leading =
      Table[
        FileNameJoin[{root, "A31basis" <> ToString[i], "A31Basis" <>
           ToString[i]}]
        ,
        {i, 13}
      ];
    subleading =
      Table[
        FileNameJoin[{root, "A31SLbasis" <> ToString[i], "A31SLBasis" <>
           ToString[i]}]
        ,
        {i, 14}
      ];
    super =
      Table[
        FileNameJoin[{root, "A31basisSuper" <> ToString[i],
          "A31BasisSuper" <> ToString[i]}]
        ,
        {i, 2}
      ];
    files = Join[leading, subleading, super];
    And @@ (FileExistsQ /@ files)
  ];

A22TwoLoopTreeBasisRootCompleteQ[root_String] :=
  Module[{files},
    files =
      Table[
        With[{name = "A22TwoLoopTreeBasis" <> ToString[i]},
          FileNameJoin[{root, name}]
        ]
        ,
        {i, 8}
      ];
    And @@ (FileExistsQ /@ files)
  ];

DefaultIBPBasisRoot["X30"] :=
  Module[{candidates},
    candidates = {
       FileNameJoin[{$AntennaPipelineRoot, "bases", "X30"}]
      };
    SelectFirst[candidates, X30BasisRootCompleteQ, First[candidates]]
      
  ];

DefaultIBPBasisRoot["MX30"] :=
  Module[{candidates},
    candidates = {
      FileNameJoin[{$AntennaPipelineRoot, "generated_bases", "MX30"}]
    };
    SelectFirst[candidates, DirectoryQ, First[candidates]]
  ];

DefaultIBPBasisRoot["X40"] :=
  Module[{candidates},
    candidates = {
       FileNameJoin[{$AntennaPipelineRoot, "bases", "X40"}]
      };
    SelectFirst[candidates, X40BasisRootCompleteQ, First[candidates]]
      
  ];

DefaultIBPBasisRoot["A31"] :=
  Module[{candidates},
    candidates = {
       FileNameJoin[{$AntennaPipelineRoot, "bases", "X31"}]
    };
    SelectFirst[candidates, A31BasisRootCompleteQ, First[candidates]]
  ];

DefaultIBPBasisRoot["A22OneLoopSelf"] :=
  Module[{candidates},
    candidates = {
      FileNameJoin[{$AntennaPipelineRoot, "bases", "A22OneLoopSelf"}],
      FileNameJoin[{$AntennaPipelineRoot, "generated_bases", "A22OneLoopSelf"}]
    };
    SelectFirst[candidates, DirectoryQ, First[candidates]]
  ];

DefaultIBPBasisRoot["A22TwoLoopTree"] :=
  Module[{candidates},
    candidates = {
      FileNameJoin[{$AntennaPipelineRoot, "bases", "A22TwoLoopTree"}],
      FileNameJoin[{$AntennaPipelineRoot, "generated_bases", "A22TwoLoopTree"}]
    };
    SelectFirst[candidates, A22TwoLoopTreeBasisRootCompleteQ, First[candidates]]
  ];

IBPProfile["X30"] :=
  <|"BasisFamily" -> "X30", "NumFinalParticles" -> 3, "NumLoops" -> 0,
     "BasisRoot" -> DefaultIBPBasisRoot["X30"], "BasisPrefix" -> "NLO", "Topologies"
     -> Permutations[{1, 2, 3}], "LoopMomenta" -> {p1, p2}, "MomentumRules"
     -> MomentumRules[3], "PhaseSpace" -> PhaseSpace[3], "ExpansionOrder"
     -> 0, "GenerateMissingBases" -> False|>;

IBPProfile["MX30"] :=
  <|"BasisFamily" -> "MX30", "NumFinalParticles" -> 3, "NumLoops" -> 0,
    "BasisRoot" -> DefaultIBPBasisRoot["MX30"], "BasisPrefix" -> "MX30",
    "Topologies" -> Permutations[{1, 2, 3}], "LoopMomenta" -> {p1, p2},
    "MomentumRules" -> MomentumRules[3],
    "PhaseSpace" -> Apply[Times, MX30CutDenominators[]],
    "MassSymbol" -> quarkMass,
    "InvariantBridgeRules" -> MX30InvariantBridgeRules[],
    "TopologyDenominators" -> MX30BasisTopologyAssociation[],
    "ExpansionOrder" -> 0, "GenerateMissingBases" -> False,
    "ImplementationStatus" -> "Implemented",
    "OpenMasterValuesQ" -> True,
    "IntegratedResultKind" -> "MasterCombination",
    "ExternalKinematics" -> <|
      "p1Squared" -> quarkMass^2,
      "p2Squared" -> quarkMass^2,
      "p3Squared" -> 0,
      "qSquared" -> 2 quarkMass^2 + s12 + s13 + s23
    |>,
    "Notes" -> {
      "This profile keeps the developer-facing MX30 open-master route available in symbolic master-combination mode.",
      "The massive cut structure, term-preparation bridge, and topology bases are now encoded explicitly in the profile.",
      "The package-owned MX30 readiness check reduces the massive A30 build output to a clean linear combination of LiteRed masters.",
      "Public IntegrateAntenna and BuildAndIntegrateAntenna calls use the provenance-backed closed bibliography bridge unless the developer-only $MassiveA30ForceIBPMasterRoute flag is set."
    }|>;

IBPProfile["X40"] :=
  <|"BasisFamily" -> "X40", "NumFinalParticles" -> 4, "NumLoops" -> 0,
     "BasisRoot" -> DefaultIBPBasisRoot["X40"], "BasisPrefix" -> "NNLO",
     "BasisClasses" -> {chain, box, hybrid}, "Topologies" -> Permutations[
      {1, 2, 3, 4}], "LoopMomenta" -> {p1, p2, p3}, "MomentumRules" ->
     MomentumRules[4], "PhaseSpace" -> PhaseSpace[4], "ExpansionOrder"
     -> 0, "GenerateMissingBases" -> False|>;

IBPProfile["A31"] :=
  <|"BasisFamily" -> "A31", "NumFinalParticles" -> 3, "NumLoops" -> 1,
     "BasisRoot" -> DefaultIBPBasisRoot["A31"], "BasisNames" ->
      Join[
        Table[<|"Basis" -> Symbol["A31Basis" <> ToString[i]],
          "DirectoryName" -> "A31basis" <> ToString[i]|>, {i,
          {9, 10, 12, 2, 6, 5, 4, 3, 7, 8, 11, 13, 1}}],
        Table[<|"Basis" -> Symbol["A31SLBasis" <> ToString[i]],
          "DirectoryName" -> "A31SLbasis" <> ToString[i]|>, {i, 14}],
        Table[<|"Basis" -> Symbol["A31BasisSuper" <> ToString[i]],
          "DirectoryName" -> "A31basisSuper" <> ToString[i]|>, {i, 2}]
      ], "LoopMomenta" -> {k1, k2, l}, "MomentumRules" ->
      {p[1] -> k1, p[2] -> k2, p[3] -> -k1 - k2 + q},
     "PhaseSpace" -> LiteRed`sp[k1, k1] LiteRed`sp[k2, k2] LiteRed`sp[
        -k1 - k2 + q, -k1 - k2 + q], "ExpansionOrder" -> -2,
     "GenerateMissingBases" -> False|>;

IBPProfile["X31"] :=
  IBPProfile["A31"];

IBPProfile["A22OneLoopSelf"] :=
  <|"BasisFamily" -> "A22OneLoopSelf", "NumFinalParticles" -> 2,
    "NumLoops" -> 2, "BasisRoot" -> DefaultIBPBasisRoot["A22OneLoopSelf"],
    "BasisNames" -> {<|"Basis" -> A22OneLoopSelfBasis,
       "DirectoryName" -> "."|>},
    "LoopMomenta" -> {l1, l2},
    "ExternalMomenta" -> {k1, q},
    "MomentumRules" -> {k2 -> q - k1},
    "PhaseSpace" -> 1,
    "ExpansionOrder" -> 0,
    "GenerateMissingBases" -> False,
    "ImplementationStatus" -> "BasisProfileOnly"|>;

IBPProfile["A22TwoLoopTree"] :=
  <|"BasisFamily" -> "A22TwoLoopTree", "NumFinalParticles" -> 2,
    "NumLoops" -> 2, "BasisRoot" -> DefaultIBPBasisRoot["A22TwoLoopTree"],
    "BasisNames" ->
      Table[
        <|"Basis" -> Symbol["A22TwoLoopTreeBasis" <> ToString[i]],
          "DirectoryName" -> "."|>
        ,
        {i, 8}
      ],
    "LoopMomenta" -> {l1, l2},
    "ExternalMomenta" -> {k1, q},
    "MomentumRules" -> {k2 -> q - k1},
    "PhaseSpace" -> 1,
    "ExpansionOrder" -> 0,
    "GenerateMissingBases" -> False,
    "ImplementationStatus" -> "ExperimentalTwoLoopTree"|>;

IBPProfile[family_] :=
  <|"Failed" -> True, "Reason" -> "UnsupportedIBPFamily", "BasisFamily"
     -> family|>;

MergeIBPProfileOptions[profile_Association, opts_Association] :=
  Module[{output},
    output = profile;
    If[KeyExistsQ[opts, "BasisRoot"] && opts["BasisRoot"] =!= Automatic,
      
      output["BasisRoot"] = opts["BasisRoot"]
    ];
    If[KeyExistsQ[opts, "GenerateMissingBases"],
      output["GenerateMissingBases"] = opts["GenerateMissingBases"]
    ];
    If[KeyExistsQ[opts, "ExpansionOrder"],
      output["ExpansionOrder"] = opts["ExpansionOrder"]
    ];
    If[KeyExistsQ[opts, "NumFinalParticles"],
      output["NumFinalParticles"] = opts["NumFinalParticles"]
    ];
    If[KeyExistsQ[opts, "NumLoops"],
      output["NumLoops"] = opts["NumLoops"]
    ];
    If[KeyExistsQ[opts, "MassSymbol"],
      output["MassSymbol"] = opts["MassSymbol"]
    ];
    If[Lookup[output, "BasisFamily", Missing["NoFamily"]] === "MX30",
      output["PhaseSpace"] =
        Apply[Times,
          MX30CutDenominators[Lookup[output, "MassSymbol", quarkMass]^2]
        ];
      output["InvariantBridgeRules"] =
        MX30InvariantBridgeRules[Lookup[output, "MassSymbol", quarkMass]^2];
      output["TopologyDenominators"] =
        MX30BasisTopologyAssociation[Lookup[output, "MassSymbol",
          quarkMass]^2];
      output["ExternalKinematics"] = <|
        "p1Squared" -> Lookup[output, "MassSymbol", quarkMass]^2,
        "p2Squared" -> Lookup[output, "MassSymbol", quarkMass]^2,
        "p3Squared" -> 0,
        "qSquared" -> 2 Lookup[output, "MassSymbol", quarkMass]^2 +
          s12 + s13 + s23
      |>;
    ];
    output
  ];

(*************************************************)

(* Basis loading *)

IBPBasisRecords[profile_Association] :=
  Module[{classes, records},
    If[KeyExistsQ[profile, "BasisNames"],
      Return[
        Table[
          <|"Topology" -> Missing["ExplicitA31Basis"], "Class" ->
             Missing["A31Class"], "Basis" -> profile["BasisNames"][[i,
              "Basis"]], "DirectoryName" -> profile["BasisNames"][[i,
              "DirectoryName"]]|>
          ,
          {i, Length[profile["BasisNames"]]}
        ]
      ]
    ];
    classes = Lookup[profile, "BasisClasses", {None}];
    records = Flatten[
      Table[
        <|"Topology" -> profile["Topologies"][[i]], "Class" ->
           classes[[j]], "Basis" -> IBPBasisSymbol[profile["Topologies"][[
             i]], profile, classes[[j]]], "DirectoryName" ->
           If[Lookup[profile, "BasisFamily", Missing["UnknownFamily"]] ===
               "MX30",
             ".",
             ToString[IBPBasisSymbol[profile["Topologies"][[i]], profile,
               classes[[j]]]]
           ]|>
        ,
        {i, Length[profile["Topologies"]]}, {j, Length[classes]}
      ]
    ];
    If[Lookup[profile, "BasisFamily", Missing["UnknownFamily"]] === "X40",
      records = OrderX40BasisRecords[records]
    ];
    records
  ];

X40BasisPriority[basis_] :=
  Module[{name},
    name = ToString[basis];
    FirstCase[
      {
        "chainBasis1432" -> 1,
        "chainBasis1342" -> 2,
        "hybridBasis1234" -> 3,
        "hybridBasis1243" -> 4,
        "chainBasis1234" -> 5,
        "boxBasis1234" -> 6,
        "boxBasis1243" -> 7,
        "chainBasis1243" -> 8,
        "chainBasis1324" -> 9,
        "hybridBasis1342" -> 10
      },
      (key_ -> priority_) /; key === name :> priority,
      1000
    ]
  ];

OrderX40BasisRecords[records_List] :=
  SortBy[records, {X40BasisPriority[Lookup[#, "Basis"]]&, ToString[
       Lookup[#, "Basis"]]&}];

LoadSingleIBPBasis[record_Association, profile_Association] :=
  Module[{name, basisDir, loc, status},
    name = record["Basis"];
    basisDir = FileNameJoin[{profile["BasisRoot"], Lookup[record,
       "DirectoryName", ToString[name]]}];
    loc = FileNameJoin[{basisDir, ToString[name]}];
    status =
      Which[
        IBPBasisLoadedQ[name],
          "Kernel"
        ,
        FileExistsQ[loc],
          Get[loc];
          Quiet[
            Block[{$Output = {}},
              Check[LiteRed`ExecuteDefinitions[name], Null]
            ]
            ,
            {LiteRed`CheckDefinitions::warn}
          ];
          "Disk"
        ,
        TrueQ[profile["GenerateMissingBases"]],
          If[TrueQ[GenerateSingleIBPBasis[record, profile]],
            "Generated"
            ,
            "MissingGenerationNotImplemented"
          ]
        ,
        True,
          "Missing"
      ];
    Join[record, <|"Directory" -> basisDir, "Location" -> loc, "Status"
       -> status, "LoadedQ" -> IBPBasisLoadedQ[name]|>]
  ];

LoadSingleIBPBasis[topology_List, profile_Association] :=
  LoadSingleIBPBasis[<|"Topology" -> topology, "Class" -> None, "Basis"
      -> IBPBasisSymbol[topology, profile, None]|>, profile];

IBPBasisLoadedQ[name_] :=
  Quiet[
    Block[{$Output = {}},
      ListQ[LiteRed`Ds[name]]
    ]
    ,
    {LiteRed`CheckDefinitions::warn}
  ];

LoadIBPBases[profile_Association] :=
  Module[{records, loaded, missing},
    EnsureLiteRedLoaded[];
    If[TrueQ[Lookup[profile, "Failed", False]],
      Return[<|"Bases" -> {}, "Records" -> {}, "LoadedQ" -> False, "Missing"
         -> {}, "Profile" -> profile|>]
    ];
    Quiet[Off[LiteRed`CheckDefinitions::warn]];
    records = LoadSingleIBPBasis[#, profile]& /@ IBPBasisRecords[profile
      ];
    Quiet[On[LiteRed`CheckDefinitions::warn]];
    loaded = Select[records, TrueQ[#["LoadedQ"]]&];
    missing = Select[records, !TrueQ[#["LoadedQ"]]&];
    <|"Bases" -> loaded[[All, "Basis"]], "Records" -> records, "LoadedQ"
       -> (Length[missing] == 0), "Missing" -> missing, "Profile" -> profile
      |>
  ];

(*************************************************)

(* Optional basis generation for new IBP families *)

A22OneLoopSelfDenominators[] :=
  {
    l1,
    l1 - k1,
    l1 - q,
    l2,
    l2 - k1,
    l2 - q,
    l1 - l2
  };

InitialiseA22OneLoopSelfKinematics[] :=
  Module[{setDim, declare, vector, number, sp},
    setDim = LiteRedSymbol["SetDim"];
    declare = LiteRedSymbol["Declare"];
    vector = LiteRedSymbol["Vector"];
    number = LiteRedSymbol["Number"];
    sp = LiteRedSymbol["sp"];
    Quiet[setDim[d]];
    Quiet[declare[{l1, l2, k1, q}, vector]];
    Quiet[declare[q2, number]];
    sp[q, q] = q2;
    sp[k1, k1] = 0;
    sp[q, k1] = q2 / 2;
    sp[k1, q] = q2 / 2;
  ];

GenerateA22OneLoopSelfBasis[record_Association, profile_Association] :=
  Module[{basis, root, script, kernel, process, loc},
    basis = record["Basis"];
    root = profile["BasisRoot"];
    script = FileNameJoin[{$AntennaPipelineRoot, "dev",
       "generate_a22_one_loop_self_basis.wl"}];
    kernel =
      If[Length[$CommandLine] > 0 && FileExistsQ[First[$CommandLine]],
        First[$CommandLine]
        ,
        "/Applications/Wolfram.app/Contents/MacOS/WolframKernel"
      ];
    If[!FileExistsQ[script] || !FileExistsQ[kernel],
      Return[False]
    ];
    process =
      RunProcess[{kernel, "-script", script}, "ExitCode"];
    If[process =!= 0,
      Return[False]
    ];
    loc = FileNameJoin[{root, ToString[basis]}];
    If[FileExistsQ[loc],
      Get[loc];
      Quiet[
        Block[{$Output = {}},
          Check[LiteRed`ExecuteDefinitions[basis], Null]
        ]
        ,
        {LiteRed`CheckDefinitions::warn}
      ]
    ];
    IBPBasisLoadedQ[basis]
  ];

MX30BasisSpecifications[mass_:m2] :=
  AssociationMap[
    <|
      "Basis" -> Symbol["MX30Basis" <> StringJoin[ToString /@ #]],
      "Denominators" -> MX30BasisTopologyDenominators[#, mass]
    |>&,
    Permutations[{1, 2, 3}]
  ];

GenerateMX30Basis[record_Association, profile_Association] :=
  Module[{basis, root, script, kernel, process, loc},
    basis = record["Basis"];
    root = profile["BasisRoot"];
    script = FileNameJoin[{$AntennaPipelineRoot, "dev",
       "generate_mx30_bases.wl"}];
    kernel =
      If[Length[$CommandLine] > 0 && FileExistsQ[First[$CommandLine]],
        First[$CommandLine]
        ,
        "/Applications/Wolfram.app/Contents/MacOS/WolframKernel"
      ];
    If[!FileExistsQ[script] || !FileExistsQ[kernel],
      Return[False]
    ];
    process =
      RunProcess[{kernel, "-script", script}, "ExitCode"];
    If[process =!= 0,
      Return[False]
    ];
    loc = FileNameJoin[{root, ToString[basis]}];
    If[FileExistsQ[loc],
      Get[loc];
      Quiet[
        Block[{$Output = {}},
          Check[LiteRed`ExecuteDefinitions[basis], Null]
        ]
        ,
        {LiteRed`CheckDefinitions::warn}
      ]
    ];
    IBPBasisLoadedQ[basis]
  ];

GenerateSingleIBPBasis[record_Association, profile_Association] :=
  Switch[profile["BasisFamily"],
    "A22OneLoopSelf",
      GenerateA22OneLoopSelfBasis[record, profile]
    ,
    "MX30",
      GenerateMX30Basis[record, profile]
    ,
    _,
      False
  ];

(*************************************************)

(* Term preparation and basis matching *)

IBPInvariantRules[profile_Association /;
    Lookup[profile, "BasisFamily", Missing["NoFamily"]] === "MX30"] :=
  Module[{mass},
    mass = Lookup[profile, "MassSymbol", quarkMass];
    Join[
      MX30InvariantBridgeRules[mass^2],
      {
        s123 -> LiteRed`sp[q, q] - 2 mass^2,
        Epsilon -> eps,
        FeynCalc`Epsilon -> eps,
        D -> d,
        SUNN -> N
      }
    ]
  ];

IBPInvariantRules[_Association] :=
  {s12 -> s[1, 2], s13 -> s[1, 3], s14 -> s[1, 4], s23 -> s[2, 3],
     s24 -> s[2, 4], s34 -> s[3, 4], s123 -> s[1, 2, 3], s124 ->
     s[1, 2, 4], s134 -> s[1, 3, 4], s234 -> s[2, 3, 4], Epsilon ->
     eps, FeynCalc`Epsilon -> eps, D -> d, SUNN -> N};

IBPIndexedInvariantRules[profile_Association /;
    Lookup[profile, "BasisFamily", Missing["NoFamily"]] === "MX30"] := {};

IBPIndexedInvariantRules[_Association] :=
  {s[i_, j_] :> LiteRed`sp[p[i] + p[j], p[i] + p[j]], s[i_, j_, k_] :>
     LiteRed`sp[p[i] + p[j] + p[k], p[i] + p[j] + p[k]]};

IBPPhaseSpace[profile_Association] :=
  profile["PhaseSpace"];

(* The A31 bases were generated directly in the FeynCalc momentum naming
   convention k1,k2,k3,l, with k3 eliminated through momentum conservation.
   This adapter is the analogue of the notebook feyncalcToLitered helper. *)
A31MomentumVector[expr_] :=
  expr /. {
    FeynCalc`Momentum[p_, ___] :> p,
    Momentum[p_, ___] :> p
  };

A31PropagatorToLiteRed[FeynCalc`PropagatorDenominator[mom_, 0]] :=
  Module[{vec},
    vec = A31MomentumVector[mom] /. k3 -> -k1 - k2 + q;
    1 / LiteRed`sp[vec, vec]
  ];

A31PropagatorToLiteRed[PropagatorDenominator[mom_, 0]] :=
  Module[{vec},
    vec = A31MomentumVector[mom] /. k3 -> -k1 - k2 + q;
    1 / LiteRed`sp[vec, vec]
  ];

A31FeynCalcToLiteRed[term_] :=
  Module[{expr},
    expr =
      term /. {
        FeynCalc`FeynAmpDenominator[props__] :>
          Times @@ (A31PropagatorToLiteRed /@ {props}),
        FeynAmpDenominator[props__] :>
          Times @@ (A31PropagatorToLiteRed /@ {props}),
        FeynCalc`Pair[a_, b_] :>
          LiteRed`sp[A31MomentumVector[a], A31MomentumVector[b]],
        Pair[a_, b_] :>
          LiteRed`sp[A31MomentumVector[a], A31MomentumVector[b]]
      };
    expr =
      expr /. {
        s12 + s13 -> 2 LiteRed`sp[q, k1],
        s12 + s23 -> 2 LiteRed`sp[q, k2],
        s13 + s23 -> 2 LiteRed`sp[q, -k1 - k2 + q],
        s123 -> q2,
        D -> d,
        Epsilon -> eps,
        FeynCalc`Epsilon -> eps
      };
    expr =
      expr /. {
        s12 -> 2 LiteRed`sp[k1, k2],
        s13 -> 2 LiteRed`sp[k1, -k1 - k2 + q],
        s23 -> 2 LiteRed`sp[k2, -k1 - k2 + q],
        k3 -> -k1 - k2 + q
      };
    expr =
      expr //. {
        LiteRed`sp[-k1 + q, -k1 + q] :>
          2 LiteRed`sp[k2, -k1 - k2 + q],
        LiteRed`sp[k1 - q, k1 - q] :>
          2 LiteRed`sp[k2, -k1 - k2 + q],
        LiteRed`sp[-k2 + q, -k2 + q] :>
          LiteRed`sp[k2 - q, k2 - q],
        LiteRed`sp[k1 + k2, k1 + k2] :>
          2 LiteRed`sp[k1, k2]
      };
    expr =
      expr /. {
        LiteRed`sp[k1, -k1 - k2 + q] :>
          LiteRed`sp[k2 - q, k2 - q] / 2,
        Epsilon -> eps,
        FeynCalc`Epsilon -> eps
      };
    expr
  ];

PrepareA31IBPTerm[term_, profile_Association] :=
  Module[{expr},
    expr =
      term / IBPPhaseSpace[profile] //
      CanonicalIBPInvariantSums //
      A31FeynCalcToLiteRed //
      Together //
      Simplify;
    expr
  ];

CanonicalizeMX30BasisSigns[expr_, mass_] :=
  expr /. {
    mass^2 - sp[p1, p1] :> -(-mass^2 + sp[p1, p1]),
    mass^2 - sp[p2, p2] :> -(-mass^2 + sp[p2, p2]),
    mass^2 - sp[-p1 + q, -p1 + q] :>
      -(-mass^2 + sp[-p1 + q, -p1 + q]),
    mass^2 - sp[-p2 + q, -p2 + q] :>
      -(-mass^2 + sp[-p2 + q, -p2 + q]),
    2 mass^2 - sp[p1 + p2, p1 + p2] :>
      -(-2 mass^2 + sp[p1 + p2, p1 + p2]),
    mass^2 - LiteRed`sp[p1, p1] :> -(-mass^2 + LiteRed`sp[p1, p1]),
    mass^2 - LiteRed`sp[p2, p2] :> -(-mass^2 + LiteRed`sp[p2, p2]),
    mass^2 - LiteRed`sp[-p1 + q, -p1 + q] :>
      -(-mass^2 + LiteRed`sp[-p1 + q, -p1 + q]),
    mass^2 - LiteRed`sp[-p2 + q, -p2 + q] :>
      -(-mass^2 + LiteRed`sp[-p2 + q, -p2 + q]),
    2 mass^2 - LiteRed`sp[p1 + p2, p1 + p2] :>
      -(-2 mass^2 + LiteRed`sp[p1 + p2, p1 + p2])
  };

ExpandMX30NumeratorShiftedForms[expr_, mass_] :=
  Module[{numerator, denominator, expandedNumerator},
    {numerator, denominator} = NumeratorDenominator[Together[expr]];
    expandedNumerator =
      numerator /. {
        2 m2 - sp[p1 + p2, p1 + p2] :>
          2 m2 - sp[p1, p1] - 2 sp[p1, p2] - sp[p2, p2],
        m2 - sp[-p2 + q, -p2 + q] :>
          m2 - q2 - sp[p2, p2] + 2 sp[p2, q],
        m2 - sp[-p1 + q, -p1 + q] :>
          m2 - q2 - sp[p1, p1] + 2 sp[p1, q],
        2 m2 - LiteRed`sp[p1 + p2, p1 + p2] :>
          2 m2 - LiteRed`sp[p1, p1] - 2 LiteRed`sp[p1, p2] - LiteRed`sp[p2, p2],
        m2 - LiteRed`sp[-p2 + q, -p2 + q] :>
          m2 - q2 - LiteRed`sp[p2, p2] + 2 LiteRed`sp[p2, q],
        m2 - LiteRed`sp[-p1 + q, -p1 + q] :>
          m2 - q2 - LiteRed`sp[p1, p1] + 2 LiteRed`sp[p1, q]
      };
    Together[expandedNumerator / denominator]
  ];

PrepareMX30IBPTerm[term_, profile_Association] :=
  Module[{expr, mass},
    mass = Lookup[profile, "MassSymbol", quarkMass];
    expr =
      term / IBPPhaseSpace[profile] //
      CanonicalIBPInvariantSums //
      ReplaceAll[#, IBPInvariantRules[profile]]& //
      ReplaceAll[#, profile["MomentumRules"]]& //
      ReplaceAll[#, mass^2 -> m2]& //
      Together //
      CanonicalizeMX30BasisSigns[#, mass]& //
      ExpandMX30NumeratorShiftedForms[#, mass]& //
      Together;
    expr
  ];

(* The A22 one-loop self source has two independent loop momenta and the
   external two-parton kinematics k1^2 = k2^2 = 0, q = k1 + k2.  The seventh
   denominator is an auxiliary scalar product that lets LiteRed express
   l1.l2 numerator terms generated by the spin trace. *)
A22MomentumVector[expr_] :=
  expr /. {
    FeynCalc`Momentum[p_, ___] :> p,
    Momentum[p_, ___] :> p
  };

A22PropagatorToLiteRed[FeynCalc`PropagatorDenominator[mom_, 0]] :=
  Module[{vec},
    vec = A22MomentumVector[mom] /. k2 -> q - k1;
    1 / LiteRedScalarProduct[vec, vec]
  ];

A22PropagatorToLiteRed[PropagatorDenominator[mom_, 0]] :=
  Module[{vec},
    vec = A22MomentumVector[mom] /. k2 -> q - k1;
    1 / LiteRedScalarProduct[vec, vec]
  ];

A22FeynCalcToLiteRed[term_] :=
  Module[{expr},
    expr =
      term /. {
        FeynCalc`FeynAmpDenominator[props__] :>
          Times @@ (A22PropagatorToLiteRed /@ {props}),
        FeynAmpDenominator[props__] :>
          Times @@ (A22PropagatorToLiteRed /@ {props}),
        FeynCalc`Pair[a_, b_] :>
          LiteRedScalarProduct[A22MomentumVector[a], A22MomentumVector[b]],
        Pair[a_, b_] :>
          LiteRedScalarProduct[A22MomentumVector[a], A22MomentumVector[b]]
      };
    expr =
      expr /. {
        k2 -> q - k1,
        s12 -> q2,
        D -> d,
        Epsilon -> eps,
        FeynCalc`Epsilon -> eps
      };
    expr =
      expr //. {
        LiteRedScalarProduct[k1, k1] -> 0,
        LiteRedScalarProduct[q, q] -> q2,
        LiteRedScalarProduct[k1, q] -> q2 / 2,
        LiteRedScalarProduct[q, k1] -> q2 / 2,
        LiteRedScalarProduct[-k1 + q, -k1 + q] -> 0,
        LiteRedScalarProduct[k1 - q, k1 - q] -> 0
      };
    expr
  ];

PrepareA22OneLoopSelfIBPTerm[term_, profile_Association] :=
  Module[{expr},
    expr =
      term / IBPPhaseSpace[profile] //
      CanonicalIBPInvariantSums //
      A22FeynCalcToLiteRed //
      Together //
      Simplify;
    expr
  ];

CanonicalIBPInvariantSums[expr_] :=
  expr //. {
    s12 + s13 + s14 + s23 + s24 + s34 -> q2,
    s12 + s13 + s23 -> s123,
    s12 + s14 + s24 -> s124,
    s13 + s14 + s34 -> s134,
    s23 + s24 + s34 -> s234
  };

X30BasisDenominatorIndex[den_] :=
  Which[
    MatchQ[den, LiteRed`sp[-p1 - p2 + q, -p1 - p2 + q] | LiteRed`sp[p1
       + p2 - q, p1 + p2 - q]],
      3
    ,
    MatchQ[den, LiteRed`sp[-p2 + q, -p2 + q] | LiteRed`sp[p2 - q, p2 
      - q]],
      4
    ,
    MatchQ[den, LiteRed`sp[-p1 + q, -p1 + q] | LiteRed`sp[p1 - q, p1 
      - q]],
      5
    ,
    True,
      Missing["NotX30BasisDenominator"]
  ];

X30BasisDenominators[] :=
  {{3, LiteRed`sp[-p1 - p2 + q, -p1 - p2 + q]}, {3, LiteRed`sp[p1 + p2
     - q, p1 + p2 - q]}, {4, LiteRed`sp[-p2 + q, -p2 + q]}, {4, LiteRed`sp[
    p2 - q, p2 - q]}, {5, LiteRed`sp[-p1 + q, -p1 + q]}, {5, LiteRed`sp[p1
     - q, p1 - q]}};

ShiftX30JIndex[LiteRed`j[b_, i1_, i2_, i3_, i4_, i5_], index_, shift_
  ] :=
  Switch[index,
    3,
      LiteRed`j[b, i1, i2, i3 + shift, i4, i5]
    ,
    4,
      LiteRed`j[b, i1, i2, i3, i4 + shift, i5]
    ,
    5,
      LiteRed`j[b, i1, i2, i3, i4, i5 + shift]
  ];

ExpandX30NumeratorScalarProducts[expr_] :=
  expr /. LiteRed`sp[p1 + p2, p1 + p2] -> LiteRed`sp[p1, p1] + 2 LiteRed`sp[
    p1, p2] + LiteRed`sp[p2, p2];

SplitNegativeProductPowers[expr_] :=
  expr //. Power[Times[factors__], n_Integer?Negative] :> Times @@ (Power[
    #, n]& /@ {factors});

ProductPowerCount[expr_, factor_] :=
  Module[{factors},
    factors =
      If[Head[expr] === Times,
        List @@ expr
        ,
        {expr}
      ];
    Total[Replace[factors, {Power[x_, n_Integer] /; SameQ[x, factor] 
      :> n, x_ /; SameQ[x, factor] :> 1, _ -> 0}, {1}]]
  ];

AbsorbX30BasisDenominatorTerm[term_] :=
  Module[{jTerm, coeff, numerator, denominator, outputJ, outputCoeff,
     factorData, index, factor, denominatorPower, numeratorPower},
    jTerm = FirstCase[term, _LiteRed`j, Missing["NoJ"], Infinity];
    If[MissingQ[jTerm],
      Return[term]
    ];
    outputJ = jTerm;
    outputCoeff = Together[term /. jTerm -> 1];
    factorData = X30BasisDenominators[];
    Do[
      index = factorData[[i, 1]];
      factor = factorData[[i, 2]];
      {numerator, denominator} = NumeratorDenominator[Together[outputCoeff
        ]];
      denominatorPower = ProductPowerCount[denominator, factor];
      If[denominatorPower > 0,
        outputCoeff = Together[outputCoeff * factor^denominatorPower]
          ;
        outputJ = ShiftX30JIndex[outputJ, index, denominatorPower]
      ];
      {numerator, denominator} = NumeratorDenominator[Together[outputCoeff
        ]];
      numeratorPower = ProductPowerCount[numerator, factor];
      If[numeratorPower > 0,
        outputCoeff = Together[outputCoeff / factor^numeratorPower];
        outputJ = ShiftX30JIndex[outputJ, index, -numeratorPower]
      ];
      ,
      {i, Length[factorData]}
    ];
    Together[outputCoeff] outputJ
  ];

AbsorbX30BasisDenominators[expr_, profile_Association] :=
  Module[{splitExpr, terms, numerator, denominator, output},
    output =
      If[profile["BasisFamily"] =!= "X30",
        expr
        ,
        splitExpr = SplitNegativeProductPowers[expr] // Together;
        {numerator, denominator} = NumeratorDenominator[splitExpr];
        terms =
          If[Head[Expand[numerator]] === Plus,
            (List @@ Expand[numerator]) / denominator
            ,
            {Expand[numerator] / denominator}
          ];
        Total[AbsorbX30BasisDenominatorTerm /@ terms] // Together
      ];
    output
  ];

ShiftJIndex[LiteRed`j[b_, indices___], index_, shift_] :=
  Module[{indexList},
    indexList = {indices};
    indexList[[index]] = indexList[[index]] + shift;
    Apply[LiteRed`j, Prepend[indexList, b]]
  ];

AbsorbBasisDenominatorTerm[term_, basis_] :=
  Module[{jTerm, outputJ, outputCoeff, factorData, index, factor, numerator,
     denominator, denominatorPower, numeratorPower},
    jTerm = FirstCase[term, _LiteRed`j, Missing["NoJ"], Infinity];
    If[MissingQ[jTerm],
      Return[term]
    ];
    outputJ = jTerm;
    outputCoeff = Together[term /. jTerm -> 1];
    factorData = Thread[{Range[Length[LiteRed`Ds[basis]]], LiteRed`Ds[
         basis]}];
    Do[
      index = factorData[[i, 1]];
      factor = factorData[[i, 2]];
      {numerator, denominator} = NumeratorDenominator[Together[outputCoeff
        ]];
      denominatorPower = ProductPowerCount[denominator, factor];
      If[denominatorPower > 0,
        outputCoeff = Together[outputCoeff * factor^denominatorPower]
          ;
        outputJ = ShiftJIndex[outputJ, index, denominatorPower]
      ];
      {numerator, denominator} = NumeratorDenominator[Together[outputCoeff
        ]];
      numeratorPower = ProductPowerCount[numerator, factor];
      If[numeratorPower > 0,
        outputCoeff = Together[outputCoeff / factor^numeratorPower];
        outputJ = ShiftJIndex[outputJ, index, -numeratorPower]
      ];
      ,
      {i, Length[factorData]}
    ];
    Together[outputCoeff] outputJ
  ];

AbsorbBasisDenominators[expr_, basis_, profile_Association] :=
  Module[{splitExpr, terms, numerator, denominator},
    splitExpr = SplitNegativeProductPowers[expr] // Together;
    {numerator, denominator} = NumeratorDenominator[splitExpr];
    terms =
      If[Head[Expand[numerator]] === Plus,
        (List @@ Expand[numerator]) / denominator
        ,
        {Expand[numerator] / denominator}
      ];
    Total[AbsorbBasisDenominatorTerm[#, basis]& /@ terms] // Together
  ];

IBPVectorCoefficient[vec_, mom_] :=
  Coefficient[vec, mom];

IBPScalarProductMomenta[profile_Association] :=
  Switch[profile["BasisFamily"],
    "A31",
      {k1, k2, l, q}
    ,
    "A22OneLoopSelf" | "A22TwoLoopTree",
      {l1, l2, k1, q}
    ,
    _,
      {p1, p2, p3, q}
  ];

IBPScalarProductVariables[momenta_List] :=
  Module[{n, matrix},
    n = Length[momenta];
    matrix =
      Table[
        Which[
          i == n && j == n,
            q2
          ,
          i <= j,
            Symbol["ibpSP" <> ToString[i] <> ToString[j]]
          ,
          True,
            Symbol["ibpSP" <> ToString[j] <> ToString[i]]
        ]
        ,
        {i, n}, {j, n}
      ];
    matrix
  ];

IBPScalarProductVariableList[momenta_List] :=
  DeleteDuplicates @ Cases[IBPScalarProductVariables[momenta],
    s_Symbol /; StringStartsQ[SymbolName[s], "ibpSP"], Infinity];

IBPScalarProductExternalEquations[momenta_List, profile_Association] :=
  Module[{variables},
    variables = IBPScalarProductVariables[momenta];
    Switch[profile["BasisFamily"],
      "A22OneLoopSelf" | "A22TwoLoopTree",
        {
          variables[[3, 3]] == 0,
          variables[[3, 4]] == q2 / 2
        }
      ,
      _,
        {}
    ]
  ];

IBPScalarProductAlgebra[LiteRed`sp[a_, b_], momenta_List] :=
  Module[{variables, coeffA, coeffB},
    variables = IBPScalarProductVariables[momenta];
    coeffA = IBPVectorCoefficient[a, #]& /@ momenta;
    coeffB = IBPVectorCoefficient[b, #]& /@ momenta;
    Sum[coeffA[[i]] coeffB[[j]] variables[[i, j]], {i, Length[
       momenta]}, {j, Length[momenta]}] // Expand
  ];

IBPScalarProductAlgebra[expr_] :=
  expr /. HoldPattern[LiteRed`sp[a_, b_]] :>
     IBPScalarProductAlgebra[LiteRed`sp[a, b], {p1, p2, p3, q}];

IBPScalarProductBasisRules[basis_, profile_Association] :=
  IBPScalarProductBasisRules[basis, profile["BasisFamily"]] =
    Module[{momenta, variables, dsVariables, equations, solution},
      momenta = IBPScalarProductMomenta[profile];
      variables = IBPScalarProductVariableList[momenta];
      dsVariables = Array[ibpD, Length[LiteRed`Ds[basis]]];
      equations =
        Join[
          Thread[(IBPScalarProductAlgebra[#, momenta]& /@ LiteRed`Ds[
             basis]) == dsVariables],
          IBPScalarProductExternalEquations[momenta, profile]
        ];
      solution = First[Solve[equations, variables]];
      Thread[variables -> (variables /. solution /. Thread[dsVariables
           -> LiteRed`Ds[basis]])]
    ];

RewriteScalarProductsToBasis[expr_, basis_, profile_Association] :=
  Module[{rules, momenta},
    momenta = IBPScalarProductMomenta[profile];
    rules = IBPScalarProductBasisRules[basis, profile];
    expr /. HoldPattern[LiteRed`sp[a_, b_]] :>
       (IBPScalarProductAlgebra[LiteRed`sp[a, b], momenta] /. rules)
  ];

RewriteScalarProductsToBasis[expr_, basis_] :=
  RewriteScalarProductsToBasis[expr, basis, IBPProfile["X40"]];

PrepareIBPTerm[term_, profile_Association] :=
  Module[{expr},
    If[profile["BasisFamily"] === "A31",
      Return[PrepareA31IBPTerm[term, profile]]
    ];
    If[profile["BasisFamily"] === "MX30",
      Return[PrepareMX30IBPTerm[term, profile]]
    ];
    If[MemberQ[{"A22OneLoopSelf", "A22TwoLoopTree"},
        profile["BasisFamily"]],
      Return[PrepareA22OneLoopSelfIBPTerm[term, profile]]
    ];
    expr =
      term / IBPPhaseSpace[profile] //
      CanonicalIBPInvariantSums //
      ReplaceAll[#, IBPInvariantRules[profile]]& //
      ReplaceAll[#, IBPIndexedInvariantRules[profile]]& //
      ReplaceAll[#, profile["MomentumRules"]]& //
      ExpandX30NumeratorScalarProducts //
      Together //
      Simplify;
    expr
  ];

MatchIBPBasis[term_, bases_List, profile_Association] :=
  Module[{expr, try, match, tojTerm},
    expr = PrepareIBPTerm[term, profile];
    match = Missing["NoMatch"];
    tojTerm = $Failed;
    Do[
      try = Quiet @ Check[LiteRed`Toj[bases[[i]], expr], $Failed];
      If[try =!= $Failed,
        try = AbsorbX30BasisDenominators[try, profile];
        try = AbsorbBasisDenominators[try, bases[[i]], profile];
        If[MemberQ[{"X40", "A31", "A22OneLoopSelf",
            "A22TwoLoopTree"},
            profile["BasisFamily"]],
          try = RewriteScalarProductsToBasis[try, bases[[i]], profile]
        ];
        try = AbsorbBasisDenominators[try, bases[[i]], profile]
      ];
      If[try =!= $Failed && FreeQ[try, LiteRed`Toj] && FreeQ[try, LiteRed`sp
        ] && FreeQ[try, Dot],
        match = bases[[i]];
        tojTerm = try;
        Break[]
      ];
      ,
      {i, Length[bases]}
    ];
    <|"Basis" -> match, "PreparedTerm" -> expr, "JTerm" -> tojTerm, "MatchedQ"
       -> !MissingQ[match]|>
  ];

(*************************************************)

(* Master substitutions *)

(* chain or box differentiator function. Used for the 4FP case *)

isBasisChainOrBox[basis_] :=
  Module[{basisName, flag},
    basisName = ToString[basis];
    flag = 0;
    Which[
      StringStartsQ[basisName, "chain"],
        flag = chain
      ,
      StringStartsQ[basisName, "box"],
        flag = box
      ,
      StringStartsQ[basisName, "hybrid"],
        flag = hybrid
    ];
    flag
  ];

mastersSub4FP[basis_, numLoops_] :=
  Module[{mis, miRs, currentMi, invList, invTotal, basisFlag, miSubs},
    
    If[numLoops != 0,
      Print["N3LO is not implemented as of this version. Aborting..."
        ];
      Return[$Failed]
    ];
    mis = LiteRed`MIs[basis];
    miRs = {};
    miSubs = {};
    Do[
      currentMi = mis[[i]];
      invList = {currentMi[[6]], currentMi[[7]], currentMi[[8]], currentMi
        [[9]], currentMi[[10]]};
      invTotal = Total[invList];
      If[invTotal == 0,
        AppendTo[miRs, R4]
      ];
      basisFlag = isBasisChainOrBox[basis];
      If[basisFlag === chain,
        If[invTotal == 2,
          AppendTo[miRs, R6]
        ];
        If[invTotal == 4,
          AppendTo[miRs, R8b]
        ]
      ];
      If[basisFlag === box,
        If[invTotal == 4,
          AppendTo[miRs, R8a]
        ]
      ];
      If[basisFlag === hybrid,
        If[invTotal == 2,
          AppendTo[miRs, R6]
        ];
        If[invTotal == 4,
          AppendTo[miRs, R8b]
        ]
      ];
      ,
      {i, mis // Length}
    ];
    Do[AppendTo[miSubs, mis[[i]] -> miRs[[i]]], {i, mis // Length}];
    miSubs
  ];

A31MasterRules[] :=
  {
    LiteRed`j[A31Basis3, 1, 1, 1, 0, 1, 0, 0, 1, 0] -> qMI,
    LiteRed`j[A31Basis4, 1, 1, 1, 0, 1, 0, 0, 1, 0] -> qMI,
    LiteRed`j[A31Basis5, 1, 1, 1, 0, 1, 0, 0, 1, 0] -> qMI,
    LiteRed`j[A31Basis6, 1, 1, 1, 0, 1, 0, 0, 1, 0] -> qMI,
    LiteRed`j[A31Basis7, 1, 1, 1, 1, 0, 0, 0, 1, 0] -> qMI,
    LiteRed`j[A31Basis8, 1, 1, 1, 1, 0, 0, 0, 1, 0] -> qMI,
    LiteRed`j[A31Basis9, 1, 1, 1, 1, 0, 0, 0, 1, 0] -> qMI,
    LiteRed`j[A31Basis10, 1, 1, 1, 0, 0, 1, 0, 1, 0] -> qkMI,
    LiteRed`j[A31Basis12, 1, 1, 1, 0, 0, 1, 0, 1, 0] -> qkMI,
    LiteRed`j[A31Basis2, 1, 1, 1, 0, 0, 1, 0, 1, 0] -> qkMI,
    LiteRed`j[A31Basis3, 1, 1, 1, 0, 0, 0, 1, 1, 0] -> qkMI,
    LiteRed`j[A31Basis4, 1, 1, 1, 0, 0, 1, 0, 1, 0] -> qkMI,
    LiteRed`j[A31Basis5, 1, 1, 1, 0, 0, 1, 0, 1, 0] -> qkMI,
    LiteRed`j[A31Basis6, 1, 1, 1, 0, 0, 1, 0, 1, 0] -> qkMI,
    LiteRed`j[A31Basis7, 1, 1, 1, 0, 1, 0, 0, 1, 0] -> qkMI,
    LiteRed`j[A31Basis8, 1, 1, 1, 0, 1, 0, 0, 1, 0] -> qkMI,
    LiteRed`j[A31Basis9, 1, 1, 1, 0, 1, 0, 0, 1, 0] -> qkMI,
    LiteRed`j[A31Basis4, 1, 1, 1, 0, 1, 1, 1, 1, 1] -> 2 qsMI,
    LiteRed`j[A31Basis7, 1, 1, 1, 1, 1, 1, 1, 1, 0] -> qsMI
  };

A22OneLoopSelfMasterRules[] :=
  {
    LiteRed`j[A22OneLoopSelfBasis, 1, 0, 1, 1, 0, 1, 0] ->
      A22LOMI
  };

A22LoopMixedDenominatorQ[den_] :=
  Module[{vars},
    vars = DeleteCases[Variables[List @@ den], _Symbol?(
        MemberQ[{k1, q}, #]&)];
    MemberQ[vars, l1] && MemberQ[vars, l2]
  ];

A22DisconnectedBubbleMasterQ[activeDenominators_List] :=
  Module[{nonMixed},
    nonMixed = FreeQ[#, l1 l2 | l1 + l2 | l1 - l2 | -l1 + l2 |
          l1 + l2 + _ | -l1 + l2 + _ | l1 - l2 + _]& /@
       activeDenominators;
    Length[activeDenominators] == 4 &&
      And @@ (Not /@ (A22LoopMixedDenominatorQ /@ activeDenominators))
  ];

A22TwoLoopTreeGetVector[LiteRed`sp[v_, _]] := v;
A22TwoLoopTreeGetVector[v_] := v;

A22TwoLoopTreeCanonicalDenominatorString[den_] :=
  ToString[InputForm[den // Expand // Simplify]];

A22TwoLoopTreeActiveDenominators[master_, basis_] :=
  Module[{indices},
    indices = List @@ master // Rest;
    Pick[LiteRed`Ds[basis], indices, _?(# > 0&)]
  ];

A22TwoLoopTreeActiveDenominatorSignature[master_, basis_] :=
  Sort[A22TwoLoopTreeCanonicalDenominatorString /@
    A22TwoLoopTreeActiveDenominators[master, basis]];

(* Exact contributing topologies seen in the A22 two-loop/tree channels.
   These labels are more faithful than the old coarse A3/A4 bucket names and
   let us distinguish masters that share the same simple Q^2 tag but are not
   the same integral.  For now several labels still map to the same compact
   value formula; the point of the split is to make future topology-specific
   values pluggable without changing the reduction logic again. *)
A22TwoLoopTreeExactTopologyLabel[master_, basis_] :=
  Module[{signature},
    signature = A22TwoLoopTreeActiveDenominatorSignature[master, basis];
    Switch[signature,
      {"sp[l1, l1]", "sp[l1 + q, l1 + q]", "sp[l2, l2]", "sp[l2 - q, l2 - q]"},
        A22A22LOQQMI
      ,
      {"sp[-k1 + l1 + l2, -k1 + l1 + l2]", "sp[-k1 + l2, -k1 + l2]",
        "sp[l1 - q, l1 - q]"},
        A22A3Basis15LikeMI
      ,
      {"sp[l1, l1]", "sp[l1 + l2 - q, l1 + l2 - q]", "sp[l2, l2]"},
        A22A3SunsetMI
      ,
      {"sp[-k1 + l1, -k1 + l1]", "sp[k1 + l2 - q, k1 + l2 - q]",
        "sp[l1 + l2, l1 + l2]"},
        A22A3Basis7LikeMI
      ,
      {"sp[-k1 + l1, -k1 + l1]",
        "sp[-k1 + l1 + l2 + q, -k1 + l1 + l2 + q]", "sp[l2, l2]"},
        A22A3Basis8LikeMI
      ,
      {"sp[-k1 + l1 + l2, -k1 + l1 + l2]", "sp[l1, l1]",
        "sp[l1 - q, l1 - q]", "sp[l2, l2]"},
        A22A4NfLikeMI
      ,
      {"sp[-k1 + l2, -k1 + l2]", "sp[l1, l1]",
        "sp[l1 + l2 - q, l1 + l2 - q]", "sp[l1 - q, l1 - q]"},
        A22A4Basis46LikeMI
      ,
      {"sp[k1 + l2 - q, k1 + l2 - q]", "sp[l1, l1]",
        "sp[l1 + l2, l1 + l2]", "sp[l1 + q, l1 + q]"},
        A22A4Basis7LikeMI
      ,
      {"sp[-k1 + l2, -k1 + l2]", "sp[l1, l1]",
        "sp[l1 + l2, l1 + l2]", "sp[l1 + q, l1 + q]"},
        A22A4Basis8LikeMI
      ,
      {"sp[-k1 + l1 + l2 + q, -k1 + l1 + l2 + q]",
        "sp[-k1 + l2, -k1 + l2]", "sp[l1, l1]",
        "sp[l1 + l2, l1 + l2]", "sp[l1 + q, l1 + q]", "sp[l2, l2]"},
        A22A6Basis8LikeMI
      ,
      _,
        Missing["UnknownA22Topology"]
    ]
  ];

A22TwoLoopTreeValueForExactTopology[label_] :=
  Switch[label,
    A22A22LOQQMI,
      A22TwoLoopTreeMasterValueA22LOQQ[]
    ,
    A22A3Basis15LikeMI,
      A22TwoLoopTreeMasterValueA3Basis15Like[]
    ,
    A22A3SunsetMI,
      A22TwoLoopTreeMasterValueA3Sunset[]
    ,
    A22A3Basis7LikeMI,
      A22TwoLoopTreeMasterValueA3Basis7Like[]
    ,
    A22A3Basis8LikeMI,
      A22TwoLoopTreeMasterValueA3Basis8Like[]
    ,
    A22A4NfLikeMI,
      A22TwoLoopTreeMasterValueA4NfLike[]
    ,
    A22A4Basis46LikeMI,
      A22TwoLoopTreeMasterValueA4Basis46Like[]
    ,
    A22A4Basis7LikeMI,
      A22TwoLoopTreeMasterValueA4Basis7Like[]
    ,
    A22A4Basis8LikeMI,
      A22TwoLoopTreeMasterValueA4Basis8Like[]
    ,
    A22A6Basis8LikeMI,
      A22TwoLoopTreeMasterValueA6Basis8Like[]
    ,
    _,
      Missing["UnknownA22TopologyValue", label]
  ];

A22TwoLoopTreeExactTopologyLabels[] :=
  {
    A22A22LOQQMI,
    A22A3Basis15LikeMI,
    A22A3SunsetMI,
    A22A3Basis7LikeMI,
    A22A3Basis8LikeMI,
    A22A4NfLikeMI,
    A22A4Basis46LikeMI,
    A22A4Basis7LikeMI,
    A22A4Basis8LikeMI,
    A22A6Basis8LikeMI
  };

A22TwoLoopTreeSimplifySp[expr_] :=
  Module[{e = expr // Expand, r1, r2, r3, r4, r5},
    r1 = e //. {LiteRed`sp[x_ + y_, z_] :> LiteRed`sp[x, z] + LiteRed`sp[y, z]};
    r2 = r1 //. {LiteRed`sp[x_, y_ + z_] :> LiteRed`sp[x, y] + LiteRed`sp[x, z]};
    r3 = r2 //. {LiteRed`sp[b_, a_] /; !OrderedQ[{b, a}] :> LiteRed`sp[a, b]};
    r4 = r3 //. {
      LiteRed`sp[a_?NumberQ * x_, y_] /; a =!= 1 :> a * LiteRed`sp[x, y],
      LiteRed`sp[x_, a_?NumberQ * y_] /; a =!= 1 :> a * LiteRed`sp[x, y],
      LiteRed`sp[0, _] -> 0,
      LiteRed`sp[_, 0] -> 0
    };
    r5 = r4 /. {
      LiteRed`sp[k1, k1] -> 0,
      LiteRed`sp[q, q] -> q2,
      LiteRed`sp[k1, q] -> q2/2,
      LiteRed`sp[q, k1] -> q2/2
    };
    r5 // Simplify
  ];

A22TwoLoopTreeRefinedMasterValue[master_, basis_] :=
  Module[{topologyLabel, indices, activeDenominators, activeCount,
      l1Dens, l2Dens, mixedDens, v1, v2, v3, Q, QsqVal, u1, u2, p1, w1, w2,
      p2, p1sqVal, p2sqVal, scale},
    topologyLabel = A22TwoLoopTreeExactTopologyLabel[master, basis];
    If[!MissingQ[topologyLabel],
      Return[topologyLabel]
    ];
    indices = List @@ master // Rest;
    activeDenominators = Pick[LiteRed`Ds[basis], indices, _?(# > 0&)];
    activeCount = Length[activeDenominators];
    
    l1Dens = Select[activeDenominators, MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2]&];
    l2Dens = Select[activeDenominators, MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1]&];
    mixedDens = Select[activeDenominators, MemberQ[Cases[#, l1, Infinity], l1] && MemberQ[Cases[#, l2, Infinity], l2]&];
    
    Which[
      activeCount == 3,
        v1 = If[Length[l1Dens] == 1, A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
        v2 = If[Length[l2Dens] == 1, A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
        v3 = If[Length[mixedDens] == 1, A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
        Q = (v3 - v1 - v2) // Simplify;
        QsqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[Q, Q]];
        scale = Which[
          QsqVal === 0, 1,
          (NumberQ[QsqVal] && QsqVal < 0) || (Head[QsqVal] === Times && MemberQ[QsqVal, -1]) || (Simplify[QsqVal / q2] < 0),
            (-QsqVal / q2)^(1 - 2 eps) / Cos[2 Pi eps]
          ,
          True,
            (QsqVal / q2)^(1 - 2 eps)
        ];
        A22TwoLoopTreeMasterValueA3[] * scale
      ,
      A22DisconnectedBubbleMasterQ[activeDenominators],
        u1 = A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0};
        u2 = A22TwoLoopTreeGetVector[l1Dens[[2]]] /. {l1 -> 0};
        p1 = (u2 - u1) // Simplify;
        w1 = A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0};
        w2 = A22TwoLoopTreeGetVector[l2Dens[[2]]] /. {l2 -> 0};
        p2 = (w2 - w1) // Simplify;
        p1sqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p1, p1]];
        p2sqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[p2, p2]];
        If[p1sqVal === 0 || p2sqVal === 0,
          0
          ,
          scale = Which[
            (Simplify[p1sqVal / q2] < 0 && Simplify[p2sqVal / q2] > 0) || (Simplify[p1sqVal / q2] > 0 && Simplify[p2sqVal / q2] < 0),
              (p1sqVal * p2sqVal / -q2^2)^(-eps) * Cos[Pi eps] / Cos[2 Pi eps]
            ,
            True,
              (p1sqVal * p2sqVal / q2^2)^(-eps)
          ];
          A22TwoLoopTreeMasterValueA22LO[] * scale
        ]
      ,
      activeCount == 4,
        v1 = If[Length[l1Dens] >= 1, A22TwoLoopTreeGetVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
        v2 = If[Length[l2Dens] >= 1, A22TwoLoopTreeGetVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
        v3 = If[Length[mixedDens] >= 1, A22TwoLoopTreeGetVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
        Q = (v3 - v1 - v2) // Simplify;
        QsqVal = A22TwoLoopTreeSimplifySp[LiteRed`sp[Q, Q]];
        scale = Which[
          QsqVal === 0, 1,
          (NumberQ[QsqVal] && QsqVal < 0) || (Head[QsqVal] === Times && MemberQ[QsqVal, -1]) || (Simplify[QsqVal / q2] < 0),
            (-QsqVal / q2)^(-2 eps) / Cos[2 Pi eps]
          ,
          True,
            (QsqVal / q2)^(-2 eps)
        ];
        A22TwoLoopTreeMasterValueA4[] * scale
      ,
      activeCount >= 5,
        A22TwoLoopTreeMasterValueA6[]
      ,
      True,
        0
    ]
  ];

A22TwoLoopTreeMasterRulesForBasis[basis_] :=
  Module[{masters, mapped},
    masters = LiteRed`MIs[basis];
    mapped = Table[A22TwoLoopTreeRefinedMasterValue[m, basis], {m, masters}];
    Thread[masters -> mapped]
  ];

IBPMasterRulesForBasis[basis_, profile_Association] :=
  Switch[profile["BasisFamily"],
    "X40",
      mastersSub4FP[basis, profile["NumLoops"]]
    ,
    "A31",
      A31MasterRules[]
    ,
    "A22OneLoopSelf",
      A22OneLoopSelfMasterRules[]
    ,
    "A22TwoLoopTree",
      A22TwoLoopTreeMasterRulesForBasis[basis]
    ,
    _,
      IBPMasterRules[profile]
  ];

IBPMasterRules[profile_Association] :=
  Switch[profile["BasisFamily"],
    "X30",
      {LiteRed`j[_, 1, 1, 1, 0, 0] -> R3}
    ,
    _,
      {}
  ];

IBPX40MasterCoefficientRules[] :=
  {
    R4 -> 1/12 + eps (59/72) + eps^2 (2263/432 - Pi^2/9) +
       eps^3 (72023/2592 - (59 Pi^2)/54 - (13 Zeta[3])/6) +
       eps^4 (2073631/15552 - (2263 Pi^2)/324 - (767 Zeta[3])/36 +
          Pi^4/1080),
    R6 -> -1 + Pi^2/6 + eps (-12 + (5 Pi^2)/6 + 9 Zeta[3]) +
       eps^2 (-91 + (9 Pi^2)/2 + 45 Zeta[3] + (61 Pi^4)/180),
    R8a -> 5/eps^4 - (20 Pi^2)/(3 eps^2) - (126 Zeta[3])/eps +
       (7 Pi^4)/18,
    R8b -> 3/(4 eps^4) - (17 Pi^2)/(12 eps^2) -
       (44 Zeta[3])/eps - (61 Pi^4)/60
  };

DefaultRuntimeMasterValuesPath[] :=
  FileNameJoin[{$AntennaPipelineRoot, "masterIntegrals", "master_values_runtime.wl"}];

RuntimeMasterValuesValidQ[data_] :=
  AssociationQ[data] &&
    Lookup[data, "SchemaVersion", Missing["KeyAbsent", "SchemaVersion"]] === 1 &&
    Lookup[data, "GeneratedFrom", Missing["KeyAbsent", "GeneratedFrom"]] === "masterIntegrals" &&
    AssociationQ[Lookup[data, "A22TwoLoopTree", Missing["KeyAbsent", "A22TwoLoopTree"]]] &&
    AssociationQ[Lookup[data, "A31", Missing["KeyAbsent", "A31"]]] &&
    And @@ (KeyExistsQ[Lookup[data, "A22TwoLoopTree", <||>], #]& /@
      {"A22LO", "A3", "A4", "A6"}) &&
    And @@ (KeyExistsQ[Lookup[data, "A31", <||>], #]& /@
      {"qMI", "qkMI", "qsMI"});

LoadRuntimeMasterValues::missing =
  "Runtime master-values artifact not found at `1`. Regenerate it with masterIntegrals/export_runtime_master_values.wl.";

LoadRuntimeMasterValues::invalid =
  "Runtime master-values artifact at `1` is missing required keys or has an unexpected schema. Regenerate it with masterIntegrals/export_runtime_master_values.wl.";

RuntimeMasterValue::missing =
  "Runtime master value `2` in group `1` was not found in the exported master-values artifact. Regenerate it with masterIntegrals/export_runtime_master_values.wl.";

LoadRuntimeMasterValues[] :=
  Module[{path, data},
    If[ValueQ[$AntennaPipelineRuntimeMasterValues] &&
        RuntimeMasterValuesValidQ[$AntennaPipelineRuntimeMasterValues],
      Return[$AntennaPipelineRuntimeMasterValues]
    ];
    path = DefaultRuntimeMasterValuesPath[];
    If[!FileExistsQ[path],
      Message[LoadRuntimeMasterValues::missing, path];
      Return[$Failed]
    ];
    data = Quiet[Check[Get[path], $Failed]];
    If[data === $Failed || !RuntimeMasterValuesValidQ[data],
      Message[LoadRuntimeMasterValues::invalid, path];
      Return[$Failed]
    ];
    $AntennaPipelineRuntimeMasterValues = data;
    data
  ];

RuntimeMasterValue[group_String, key_String] :=
  Module[{data, value},
    data = LoadRuntimeMasterValues[];
    If[data === $Failed,
      Return[$Failed]
    ];
    value = Lookup[Lookup[data, group, <||>], key, Missing["NotAvailable"]];
    If[MissingQ[value],
      Message[RuntimeMasterValue::missing, group, key];
      Return[$Failed]
    ];
    value
  ];

A31Ceps[] :=
  (4 Pi) ^ eps Exp[-EulerGamma eps] / (8 Pi^2);

A31SGamma2[] :=
  IBPPhaseSpaceMeasure[2] ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

A31MasterCoefficientRules[] :=
  {
    qMI -> RuntimeMasterValue["A31", "qMI"],
    qkMI -> RuntimeMasterValue["A31", "qkMI"],
    qsMI -> RuntimeMasterValue["A31", "qsMI"]
  };

A22LOMasterCore[] :=
  Pi^4 Gamma[1 + eps]^2 Gamma[1 - eps]^6 /
    (eps^2 Gamma[2 - 2 eps]^2);

A22SGamma[] :=
  ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

A22TwoLoopTreeMasterCoreA22LO[] :=
  -A22SGamma[] (-q2)^(-2 eps) Gamma[1 + eps]^2 Gamma[1 - eps]^6 /
    (eps^2 Gamma[2 - 2 eps]^2);

A22TwoLoopTreeMasterCoreA3[] :=
  -A22SGamma[] (-q2)^(1 - 2 eps) Gamma[1 + 2 eps] Gamma[1 - eps]^5 /
    (2 (1 - 2 eps) eps Gamma[3 - 3 eps]);

A22TwoLoopTreeMasterCoreA4[] :=
  (-A22SGamma[] (-q2)^(-2 eps) Gamma[1 - 2 eps] Gamma[1 + eps] Gamma[1 - eps]^4 Gamma[1 + 2 eps]) /
    (2 (1 - 2 eps) eps^2 Gamma[2 - 3 eps]);

A22TwoLoopTreeMasterCoreA6[] :=
  A22SGamma[] (-q2)^(-2 - 2 eps) (-1 / eps^4 + 5 Pi^2 / (6 eps^2) +
     27 Zeta[3] / eps + 23 Pi^4 / 36);

(* Appendix A.1 of hep-ph/0403057 gives A22,LO as the product of two
   massless two-point functions after factoring out S_Gamma.  The LiteRed
   source for the one-loop self-interference reduces to exactly this
   disconnected two-bubble master.  The conversion factor below puts the
   S_Gamma-stripped master into the same real two-parton paper convention used
   by the T_{qq}^{(6,[1x1])} bracket. *)
A22VirtualTwoPartonConventionFactor[] :=
  1 - Pi^2 eps^2 / 6 +
    (26 Zeta[3] / 3) eps^3 +
    (Pi^4 / 120 - 28 Zeta[3]) eps^4;

(* The tree/two-loop interference uses a different external two-parton
   convention than the one-loop self-interference.  Matching the Appendix A.1
   masters to the bare T_{qq}^{(6,[2x0])} bracket fixes an additional factor
   that first contributes at O(eps^3), so the highest poles are left
   untouched. *)
A22TwoLoopTreeVirtualConventionFactor[] :=
  1 - 2 Pi^2 eps^2 - (28 Zeta[3] eps^3) / 3 +
    (2 (Pi^4 + 42 Zeta[3]) eps^4) / 3;

(* Appendix A.1 is written with timelike powers (-q^2)^alpha.  The integrated
   T-brackets are real, so the physical continuation contributes only the
   cosine phase.  We convert those powers explicitly before applying the same
   two-parton virtual convention used by the validated one-loop self route. *)
A22TwoLoopTreePaperConventionRules[expr_] :=
  expr /. {
    HoldPattern[Power[-q2, -2 eps]] :> q2^(-2 eps) Cos[2 Pi eps],
    HoldPattern[Power[-q2, 1 - 2 eps]] :> -q2^(1 - 2 eps) Cos[2 Pi eps],
    HoldPattern[Power[-q2, -2 - 2 eps]] :> q2^(-2 - 2 eps) Cos[2 Pi eps]
  };

A22TwoLoopTreePaperConventionFactor[] :=
  256 Pi^8 A22VirtualTwoPartonConventionFactor[] Gamma[1 - eps]^2 /
    ((4 Pi)^(2 eps) Cos[2 Pi eps]);

(* After applying the Appendix A.1 timelike continuation and the common
   two-parton convention factor, each master collapses to a compact form in
   the package convention.  These simplified values are what the IBP backend
   actually substitutes, while the explicit core/rule helpers above remain as
   the transparent derivation layer. *)
A22TwoLoopTreeMasterValueA22LO[] :=
  RuntimeMasterValue["A22TwoLoopTree", "A22LO"];

A22TwoLoopTreeMasterValueA3[] :=
  RuntimeMasterValue["A22TwoLoopTree", "A3"];

A22TwoLoopTreeMasterValueA4[] :=
  RuntimeMasterValue["A22TwoLoopTree", "A4"];

A22TwoLoopTreeMasterValueA6[] :=
  RuntimeMasterValue["A22TwoLoopTree", "A6"];

A22TwoLoopTreeMasterValueA22LOQQ[] :=
  A22TwoLoopTreeMasterValueA22LO[];

A22TwoLoopTreeMasterValueA3Basis15Like[] :=
  A22TwoLoopTreeMasterValueA3[];

A22TwoLoopTreeMasterValueA3Sunset[] :=
  A22TwoLoopTreeMasterValueA3[];

A22TwoLoopTreeMasterValueA3Basis7Like[] :=
  A22TwoLoopTreeMasterValueA3[];

A22TwoLoopTreeMasterValueA3Basis8Like[] :=
  A22TwoLoopTreeMasterValueA3[];

A22TwoLoopTreeMasterValueA4NfLike[] :=
  A22TwoLoopTreeMasterValueA4[];

A22TwoLoopTreeMasterValueA4Basis46Like[] :=
  A22TwoLoopTreeMasterValueA4[];

A22TwoLoopTreeMasterValueA4Basis7Like[] :=
  (Pi^4*(-18 + eps*(-90 + eps*(-342 + 33*Pi^2) +
        2*eps^3*(-390 + 55*Pi^2 + 52*Zeta[3]))))/(72*eps^2);

A22TwoLoopTreeMasterValueA4Basis8Like[] :=
  (Pi^4*(-360 + eps*(-1800 + eps*(-6840 + 660*Pi^2 +
        eps^2*(83760 - 13640*Pi^2 + 79*Pi^4 - 16640*Zeta[3]) -
        60*eps*(-390 + 55*Pi^2 + 52*Zeta[3])))))/(1440*eps^2);

A22TwoLoopTreeMasterValueA6Basis8Like[] :=
  A22TwoLoopTreeMasterValueA6[];

A22OneLoopSelfMasterCoefficientRules[] :=
  {
    A22LOMI -> A22LOMasterCore[] A22VirtualTwoPartonConventionFactor[]
  };

A22TwoLoopTreeMasterCoefficientRules[] :=
  Join[
    {
      A22LOMI -> A22TwoLoopTreeMasterValueA22LO[],
      A3MI -> A22TwoLoopTreeMasterValueA3[],
      A4MI -> A22TwoLoopTreeMasterValueA4[],
      A6MI -> A22TwoLoopTreeMasterValueA6[]
    },
    (# -> A22TwoLoopTreeValueForExactTopology[#])& /@
      A22TwoLoopTreeExactTopologyLabels[]
  ];

IBPMasterValues[profile_Association] :=
  Switch[profile["BasisFamily"],
    "X30",
      {R3 -> IBPPhaseSpaceMeasure[3]}
    ,
    "X40",
      IBPX40MasterCoefficientRules[]
    ,
    "A31",
      A31MasterCoefficientRules[]
    ,
    "A22OneLoopSelf",
      A22OneLoopSelfMasterCoefficientRules[]
    ,
    "A22TwoLoopTree",
      A22TwoLoopTreeMasterCoefficientRules[]
    ,
    _,
      {}
  ];

(*************************************************)

(* Reduction and normalisation *)

ReduceAntennaIBP[antenna_, bases_List, profile_Association,
   detailedTiming_:False] :=
  Module[{expanded, listAntenna, records, reduced, unmatched, rawReduced,
     expansionSeconds, reductionSeconds, totalMatchSeconds,
     totalReduceSeconds, totalMasterRuleSeconds, totalSeconds},
    {expansionSeconds, expanded} =
      AbsoluteTiming[
        antenna //
        CanonicalIBPInvariantSums //
        Expand
      ];
    listAntenna =
      If[Head[expanded] === Plus,
        List @@ expanded
        ,
        {expanded}
      ];
    {reductionSeconds, records} =
      AbsoluteTiming[
        Table[
          Module[{match, redTerm, masterRules, matchSeconds, reduceSeconds,
             masterRuleSeconds, baseRecord},
            {matchSeconds, match} =
              AbsoluteTiming[
                MatchIBPBasis[listAntenna[[i]], bases, profile]
              ];
            {reduceSeconds, redTerm} =
              If[TrueQ[match["MatchedQ"]],
                AbsoluteTiming[
                  Check[
                    Quiet[
                      Block[{$Output = {}},
                        LiteRed`IBPReduce[match["JTerm"]]
                      ]
                    ]
                    ,
                    $Failed
                  ]
                ]
                ,
                {0., $Failed}
              ];
            {masterRuleSeconds, masterRules} =
              If[TrueQ[match["MatchedQ"]],
                AbsoluteTiming[
                  IBPMasterRulesForBasis[match["Basis"], profile]
                ]
                ,
                {0., {}}
              ];
            baseRecord =
              Join[match, <|"Index" -> i, "InputTerm" -> listAntenna[[i]],
                 "MasterRules" -> masterRules, "ReducedTerm" -> redTerm|>];
            If[TrueQ[detailedTiming],
              Join[baseRecord, <|"MatchSeconds" -> matchSeconds,
                "ReduceSeconds" -> reduceSeconds, "MasterRuleSeconds" ->
                 masterRuleSeconds, "PreparedLeafCount" ->
                 If[match["PreparedTerm"] === $Failed, $Failed,
                   LeafCount[match["PreparedTerm"]]], "ReducedLeafCount" ->
                 If[redTerm === $Failed, $Failed, LeafCount[redTerm]]|>]
              ,
              baseRecord
            ]
          ]
          ,
          {i, Length[listAntenna]}
        ]
      ];
    unmatched = Select[records, !TrueQ[#["MatchedQ"]] || #["ReducedTerm"
      ] === $Failed&];
    rawReduced =
      If[Length[unmatched] == 0,
        Table[
          records[[i, "ReducedTerm"]]
          ,
          {i, Length[records]}
        ]
        ,
        $Failed
      ];
    reduced =
      If[rawReduced === $Failed,
        $Failed
        ,
        Table[
          rawReduced[[i]] /. records[[i, "MasterRules"]]
          ,
          {i, Length[rawReduced]}
        ]
      ];
    totalMatchSeconds =
      If[TrueQ[detailedTiming],
        Total[Lookup[records, "MatchSeconds", 0.]]
        ,
        0.
      ];
    totalReduceSeconds =
      If[TrueQ[detailedTiming],
        Total[Lookup[records, "ReduceSeconds", 0.]]
        ,
        0.
      ];
    totalMasterRuleSeconds =
      If[TrueQ[detailedTiming],
        Total[Lookup[records, "MasterRuleSeconds", 0.]]
        ,
        0.
      ];
    totalSeconds = expansionSeconds + reductionSeconds;
    <|"RawReducedTerms" -> rawReduced, "ReducedTerms" -> reduced,
      "TermRecords" -> If[TrueQ[detailedTiming], records, Missing[
          "NotRequested"]], "UnmatchedTerms" -> unmatched, "UnmatchedCount"
       -> Length[unmatched], "TimingDiagnostics" -> <|"ExpansionSeconds" ->
         expansionSeconds, "ReductionLoopSeconds" -> reductionSeconds,
         "MatchSeconds" -> totalMatchSeconds, "IBPReduceSeconds" ->
         totalReduceSeconds, "MasterRuleSeconds" -> totalMasterRuleSeconds,
         "ReductionTotalSeconds" -> totalSeconds, "InputTermCount" -> Length[
           listAntenna], "ExpandedLeafCount" -> LeafCount[expanded]|>|>
  ];

IBPPhaseSpaceMeasure[2] :=
  2 ^ (-3 + 2 eps) Pi ^ (-1 + eps) Gamma[1 - eps] / Gamma[2 - 2 eps] q2 ^
     (-eps);

IBPPhaseSpaceMeasure[3] :=
  2 ^ (-7 + 4 eps) Pi ^ (-3 + 2 eps) Gamma[1 - eps] ^ 3 / (Gamma[2 - 
    2 eps] Gamma[3 - 3 eps]) q2 ^ (1 - 2 eps);

IBPNormalization[profile_Association] :=
  Switch[profile["BasisFamily"],
    "X30",
      8 Pi^2 (4 Pi) ^ (-eps) Exp[eps EulerGamma] / IBPPhaseSpaceMeasure[
        2]
    ,
    "X40",
      Exp[2 eps EulerGamma] / (4 Gamma[1 - eps]^2)
    ,
    "A31",
      1 / (IBPPhaseSpaceMeasure[2] A31Ceps[]^2)
    ,
    "A22TwoLoopTree",
      1
    ,
    _,
      1
  ];

IBPToSeries[reduced_, profile_Association] :=
  Module[{timed},
    timed = IBPToSeriesWithDiagnostics[Missing["NotAvailable"], reduced,
      profile];
    timed["Integrated"]
  ];

IBPToSeriesWithDiagnostics[rawReduced_, reduced_, profile_Association] :=
  Module[{rawLiteRed, rawMapped, withMasters, normalized, series,
     rawLiteRedSeconds, rawMappedSeconds, masterSubstitutionSeconds,
     normalizationSeconds, seriesSeconds},
    If[reduced === $Failed,
      Return[<|"Integrated" -> $Failed, "Stages" -> <|"RawLiteRedCombination"
            -> $Failed, "MasterMappedExpression" -> $Failed,
            "RawMasterCombination" -> $Failed,
            "MasterSubstitutedExpression" -> $Failed,
            "NormalizedBeforeSeries" -> $Failed, "SeriesResult" -> $Failed|>,
          "TimingDiagnostics" -> <|"RawLiteRedCombinationSeconds" -> 0.,
            "RawMasterCombinationSeconds" -> 0.,
            "MasterSubstitutionSeconds" -> 0., "NormalizationSeconds" ->
             0., "SeriesSeconds" -> 0., "SeriesPipelineTotalSeconds" -> 0.,
            "RawLiteRedLeafCount" -> $Failed, "MasterMappedLeafCount" ->
             $Failed, "MasterSubstitutedLeafCount" -> $Failed,
            "NormalizedLeafCount" -> $Failed, "SeriesLeafCount" -> $Failed|>|>]
    ];
    {rawLiteRedSeconds, rawLiteRed} =
      If[ListQ[rawReduced],
        AbsoluteTiming[Total[rawReduced]]
        ,
        {0., Missing["NotAvailable"]}
      ];
    {rawMappedSeconds, rawMapped} = AbsoluteTiming[Total[reduced]];
    {masterSubstitutionSeconds, withMasters} =
      AbsoluteTiming[rawMapped /. IBPMasterValues[profile]];
    {normalizationSeconds, normalized} =
      AbsoluteTiming[
        withMasters * IBPNormalization[profile] //
        ReplaceAll[#, {d -> 4 - 2 eps, q2 -> 1}]& //
        Together //
        Simplify
      ];
    {seriesSeconds, series} =
      AbsoluteTiming[
        Series[normalized, {eps, 0, profile["ExpansionOrder"]}] //
        Normal //
        FullSimplify //
        ReplaceAll[#, eps -> FeynCalc`Epsilon]& //
        Collect[#, FeynCalc`Epsilon]&
      ];
    <|"Integrated" -> series, "Stages" -> <|"RawLiteRedCombination" ->
         rawLiteRed, "MasterMappedExpression" -> rawMapped,
        "RawMasterCombination" -> rawMapped,
        "MasterSubstitutedExpression" -> withMasters,
        "NormalizedBeforeSeries" -> normalized, "SeriesResult" -> series|>,
      "TimingDiagnostics" -> <|"RawLiteRedCombinationSeconds" ->
         rawLiteRedSeconds, "RawMasterCombinationSeconds" ->
         rawMappedSeconds,
        "MasterSubstitutionSeconds" -> masterSubstitutionSeconds,
        "NormalizationSeconds" -> normalizationSeconds, "SeriesSeconds" ->
         seriesSeconds, "SeriesPipelineTotalSeconds" -> rawLiteRedSeconds +
          rawMappedSeconds + masterSubstitutionSeconds +
          normalizationSeconds + seriesSeconds, "RawLiteRedLeafCount" ->
         If[rawLiteRed === Missing["NotAvailable"], Missing[
             "NotAvailable"], LeafCount[rawLiteRed]],
        "MasterMappedLeafCount" -> LeafCount[rawMapped],
        "MasterSubstitutedLeafCount" -> LeafCount[withMasters],
        "NormalizedLeafCount" -> LeafCount[normalized], "SeriesLeafCount"
         -> LeafCount[series]|>|>
  ];

IBPReductionStages[rawReduced_, reduced_, profile_Association] :=
  Module[{timed},
    timed = IBPToSeriesWithDiagnostics[rawReduced, reduced, profile];
    timed["Stages"]
  ];

(*************************************************)

(* Public IBP backend *)

Options[IntegrateViaIBP] = {NumFinalParticles -> 3, NumLoops -> 0, BasisFamily
   -> "X30", BasisRoot -> Automatic, GenerateMissingBases -> False, ExpansionOrder
   -> 0, ReturnDiagnostics -> False, DetailedTimingDiagnostics -> False};

IntegrateViaIBP[antenna_, OptionsPattern[]] :=
  Module[{family, profile, basisLoad, reduction, integrated, diagnostics,
     masterSymbols, remainingBad, componentResults, reductionStages,
     basisLoadSeconds, reductionSeconds, seriesSeconds, timedSeries,
     timingDiagnostics},
    If[ListQ[antenna],
      componentResults =
        If[# === $Failed,
          If[OptionValue[ReturnDiagnostics] === True,
            {$Failed, <|"SkippedQ" -> True,
              "Reason" -> "ComponentNotBuilt"|>}
            ,
            $Failed
          ]
          ,
          IntegrateViaIBP[#, NumFinalParticles -> OptionValue[
              NumFinalParticles], NumLoops -> OptionValue[NumLoops],
             BasisFamily -> OptionValue[BasisFamily], BasisRoot -> OptionValue[
              BasisRoot], GenerateMissingBases -> OptionValue[
              GenerateMissingBases], ExpansionOrder -> OptionValue[
              ExpansionOrder], ReturnDiagnostics -> OptionValue[
              ReturnDiagnostics], DetailedTimingDiagnostics -> OptionValue[
              DetailedTimingDiagnostics]]
        ]& /@ antenna;
      Return[
        If[OptionValue[ReturnDiagnostics] === True,
          {componentResults[[All, 1]], <|"ComponentDiagnostics" ->
             componentResults[[All, 2]]|>}
          ,
          componentResults
        ]
      ]
    ];
    If[antenna === 0,
      diagnostics = <|"SkippedQ" -> True, "Reason" -> "ZeroAntenna"|>;
      Return[
        If[OptionValue["ReturnDiagnostics"] === True,
          {0, diagnostics}
          ,
          0
        ]
      ]
    ];
    family = OptionValue["BasisFamily"];
    If[family === Automatic,
      family = "X30"
    ];
    profile = IBPProfile[family] // MergeIBPProfileOptions[#, <|"BasisRoot"
       -> OptionValue["BasisRoot"], "GenerateMissingBases" -> OptionValue["GenerateMissingBases"
      ], "ExpansionOrder" -> OptionValue["ExpansionOrder"], "NumFinalParticles"
       -> OptionValue["NumFinalParticles"], "NumLoops" -> OptionValue["NumLoops"
      ]|>]&;
    If[TrueQ[Lookup[profile, "Failed", False]],
      diagnostics = <|"Failed" -> True, "Reason" -> profile["Reason"],
         "Profile" -> profile|>;
      Return[
        If[OptionValue["ReturnDiagnostics"] === True,
          {$Failed, diagnostics}
          ,
          $Failed
        ]
      ]
    ];
    If[Lookup[profile, "ImplementationStatus", "Implemented"] ===
        "ScaffoldOnly",
      diagnostics = <|"Failed" -> True,
        "Reason" -> Lookup[profile, "BlockingReason",
          "IBPReductionProfileNotImplemented"],
        "Profile" -> profile,
        "Notes" -> Lookup[profile, "Notes", {}]|>;
      Return[
        If[OptionValue["ReturnDiagnostics"] === True,
          {$Failed, diagnostics}
          ,
          $Failed
        ]
      ]
    ];
    {basisLoadSeconds, basisLoad} = AbsoluteTiming[LoadIBPBases[profile]];
    If[!TrueQ[basisLoad["LoadedQ"]],
      diagnostics = <|"Failed" -> True, "Reason" -> "MissingIBPBases",
         "Profile" -> profile, "BasisLoad" -> basisLoad|>;
      Return[
        If[OptionValue["ReturnDiagnostics"] === True,
          {$Failed, diagnostics}
          ,
          $Failed
        ]
      ]
    ];
    {reductionSeconds, reduction} =
      AbsoluteTiming[
        ReduceAntennaIBP[antenna, basisLoad["Bases"], profile,
          OptionValue["DetailedTimingDiagnostics"]]
      ];
    {seriesSeconds, timedSeries} =
      AbsoluteTiming[
        IBPToSeriesWithDiagnostics[reduction["RawReducedTerms"],
          reduction["ReducedTerms"], profile]
      ];
    integrated = timedSeries["Integrated"];
    reductionStages = timedSeries["Stages"];
    masterSymbols =
      If[reduction["ReducedTerms"] === $Failed,
        {}
        ,
        DeleteDuplicates @ Cases[reduction["ReducedTerms"], R3 | R4 |
           R6 | R8a | R8b | V8a | V8b | qMI | qkMI | qsMI |
           A22LOMI | A3MI | A4MI | A6MI | _LiteRed`j, Infinity]
      ];
    remainingBad =
      If[reduction["ReducedTerms"] === $Failed,
        True
        ,
        !FreeQ[reduction["ReducedTerms"], LiteRed`Toj | LiteRed`sp | 
          Dot]
      ];
    timingDiagnostics =
      Join[
        Lookup[reduction, "TimingDiagnostics", <||>],
        Lookup[timedSeries, "TimingDiagnostics", <||>],
        <|"BasisLoadSeconds" -> basisLoadSeconds, "ReductionSeconds" ->
           reductionSeconds, "SeriesPipelineSeconds" -> seriesSeconds,
          "EndToEndSeconds" -> basisLoadSeconds + reductionSeconds +
            seriesSeconds|>
      ];
    diagnostics = <|"Profile" -> profile, "BasisLoad" -> basisLoad, "LoadedBasisCount"
       -> Length[basisLoad["Bases"]], "UnmatchedCount" -> reduction["UnmatchedCount"
      ], "UnmatchedTerms" -> reduction["UnmatchedTerms"], "RemainingTojSpOrDotQ"
       -> remainingBad, "MasterSymbols" -> masterSymbols, "RawReducedTerms" ->
       reduction["RawReducedTerms"], "ReducedTerms" -> reduction["ReducedTerms"],
      "TermRecords" -> Lookup[reduction, "TermRecords", Missing[
          "NotRequested"]], "TimingDiagnostics" -> timingDiagnostics,
      "OpenMasterValuesQ" -> Lookup[profile, "OpenMasterValuesQ", False],
      "IntegratedResultKind" -> Lookup[profile, "IntegratedResultKind",
        "Series"],
      "RawLiteRedCombination" -> reductionStages["RawLiteRedCombination"],
      "MasterMappedExpression" -> reductionStages["MasterMappedExpression"],
      "RawMasterCombination" -> reductionStages["RawMasterCombination"],
      "MasterSubstitutedExpression" -> reductionStages["MasterSubstitutedExpression"],
      "NormalizedBeforeSeries" -> reductionStages["NormalizedBeforeSeries"],
      "SeriesResult" -> reductionStages["SeriesResult"]|>;
    If[OptionValue["ReturnDiagnostics"] === True,
      {integrated, diagnostics}
      ,
      integrated
    ]
  ];

(*************************************************)

(* Backwards-compatible internal aliases *)

basisMatch[term_, basesList_] :=
  MatchIBPBasis[term, basesList, IBPProfile["X30"]]["Basis"];

reduceAntenna[antenna_, numFinalParticles_:3, numLoops_:0] :=
  Module[{profile, basisLoad, reduction},
    profile = MergeIBPProfileOptions[IBPProfile["X30"], <|"NumFinalParticles"
       -> numFinalParticles, "NumLoops" -> numLoops|>];
    basisLoad = LoadIBPBases[profile];
    If[!TrueQ[basisLoad["LoadedQ"]],
      Return[$Failed]
    ];
    reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile
      ];
    reduction["ReducedTerms"]
  ];
