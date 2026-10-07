(* ::Section:: *)
(* Tree-level interference construction *)

(* Communicates with:
   - src/engines/amplitudes_tree.wl, which supplies the raw amplitudes
     interfered here.
   - src/core/kinematics_and_utilities.wl through KinematicRules,
     SafeDoPolarizationSums, ColourTensorCounter, ReturnColourSpinCouples, and
     ApplyFeynCalcRules.
   - src/core/profiles.wl through AntennaSelfInterference[...] and
     BornInterference[], which memoize the outputs of this layer.
   - src/engines/extraction_tree.wl, which consumes these interferences to
     extract public tree-level antenna components.

   Why this file exists:
   The amplitude builders stop at unsquared matrix elements.  This layer turns
   them into physical interference objects in a way that respects colour
   structure, spin sums, and antenna-family-specific polarization handling. *)

InterfereMAmplitudes::usage =
  "InterfereMAmplitudes[amp1, amp2, numFinalParticles, ...] builds the tree-level interference used by the unintegrated antenna extractors.";

InterfereMAmplitudesPair::usage =
  "InterfereMAmplitudesPair[term1, term2, numFinalParticles, ...] evaluates one pairwise tree-level interference contribution.";

InterfereMAmp1Count::usage =
  "InterfereMAmp1Count[amp] returns the number of terms in the first interfering amplitude.";

InterfereMAmp2Count::usage =
  "InterfereMAmp2Count[amp] returns the number of terms in the second interfering amplitude.";

A40LocalTraceDiracReduce::usage =
  "A40LocalTraceDiracReduce[expr] contracts an A40 colour/spin pair and reduces each Dirac trace independently, avoiding a non-terminating global DiracSimplify pass without changing the individual FeynCalc trace reductions.";

SymmetrizedInterference::usage =
  "SymmetrizedInterference[left, right] adds the left-right and right-left interference pieces in the package convention.";

Options[InterfereMAmplitudes] = {ApplyCasimirSubstitution -> True, ApplyDimReg
   -> True, AntennaType -> A, quarkMass -> 0};

(* A40LocalTraceDiracReduce[expr]
   =============================
   The full-colour A40 pair can contain O(10^2) independent Dirac traces.
   FeynCalc's global DiracSimplify on that complete expression can fail to
   terminate, although each trace reduces promptly.  Contract first, then use
   FeynCalc's unchanged trace reduction on every exact trace representative and
   substitute those values back in one structural pass.  This is intentionally
   A40-specific: other routes retain their established reduction order. *)
A40LocalTraceDiracReduce[expr_] :=
  Module[{contracted, traces, reducedTraces},
    contracted = FeynCalc`Contract[expr];
    traces = DeleteDuplicates @ Cases[contracted, _FeynCalc`DiracTrace,
      Infinity];
    If[Length[traces] === 0,
      Return[FeynCalc`DiracSimplify[contracted]]
    ];
    reducedTraces = FeynCalc`DiracSimplify /@ traces;
    contracted /. Thread[traces -> reducedTraces]
  ];

(* InterfereMAmplitudes[MAmp1, MAmp2, numFinalParticles, ...]
   ==========================================================
   Dispatch to the interference strategy appropriate to the colour complexity
   of the input amplitudes. *)
InterfereMAmplitudes[MAmp1_, MAmp2_, numFinalParticles_, OptionsPattern[
  ]] :=
  Module[{ApplyCasimirSubstitutionOpt, ApplyDimRegOpt, AntennaTypeOpt,
     quarkMassOpt, colourCounts1, colourCounts2, interference},
    ApplyCasimirSubstitutionOpt = OptionValue["ApplyCasimirSubstitution"
      ];
    ApplyDimRegOpt = OptionValue["ApplyDimReg"];
    AntennaTypeOpt = OptionValue["AntennaType"];
    quarkMassOpt = OptionValue["quarkMass"];
    colourCounts1 = ColourTensorCounter[MAmp1];
    colourCounts2 = ColourTensorCounter[MAmp2];
    If[MAmp1 == MAmp2,
      Which[
        colourCounts1 == 1,
          interference = InterfereMAmp1Count[MAmp1, MAmp2, numFinalParticles,
             ApplyCasimirSubstitutionOpt, ApplyDimRegOpt, AntennaTypeOpt,
             quarkMassOpt]
        ,
        colourCounts1 == 2,
          interference = InterfereMAmp2Count[MAmp1, MAmp2, numFinalParticles,
             ApplyCasimirSubstitutionOpt, ApplyDimRegOpt, AntennaTypeOpt,
             quarkMassOpt]
        ,
        Default,
          Print["Input M amplitudes have a maximum of ", Max[colourCounts1,
             colourCounts2], " colour tensors in their individual definitions. In the present version of this software, only amplitudes with up to 2 colour tensors are accepted. Aborting..."
            ];
          $Failed
      ]
      ,
      Print["The input M amplitudes are not equal. This is not yet implemented in the present version. Aborting..."
        ];
      $Failed
    ]
  ];

(* InterfereMAmplitudesPair[MAmp1, MAmp2, numFinalParticles, ...]
   ==============================================================
   Pairwise interference entry point used when the two amplitudes are not
   necessarily identical. *)
InterfereMAmplitudesPair[MAmp1_, MAmp2_, numFinalParticles_, OptionsPattern[
  InterfereMAmplitudes]] :=
  Module[{ApplyCasimirSubstitutionOpt, ApplyDimRegOpt, AntennaTypeOpt,
     quarkMassOpt, colourCounts1, colourCounts2, interference},
    ApplyCasimirSubstitutionOpt = OptionValue["ApplyCasimirSubstitution"
      ];
    ApplyDimRegOpt = OptionValue["ApplyDimReg"];
    AntennaTypeOpt = OptionValue["AntennaType"];
    quarkMassOpt = OptionValue["quarkMass"];
    colourCounts1 = ColourTensorCounter[MAmp1];
    colourCounts2 = ColourTensorCounter[MAmp2];
    Which[
      colourCounts1 == 1 && colourCounts2 == 1,
        interference = InterfereMAmp1Count[MAmp1, MAmp2, numFinalParticles,
           ApplyCasimirSubstitutionOpt, ApplyDimRegOpt, AntennaTypeOpt,
           quarkMassOpt]
      ,
      colourCounts1 <= 2 && colourCounts2 <= 2,
        interference = InterfereMAmp2Count[MAmp1, MAmp2, numFinalParticles,
           ApplyCasimirSubstitutionOpt, ApplyDimRegOpt, AntennaTypeOpt,
           quarkMassOpt]
      ,
      True,
        Print["Pair interference received unsupported colour tensor counts ",
           {colourCounts1, colourCounts2}, ". Aborting..."];
        interference = $Failed
    ];
    interference
  ];

(* SymmetrizedInterference[amp1, amp2, numFinalParticles, antennaType]
   ===================================================================
   Add the left-right and right-left interferences explicitly.  This keeps the
   route logic readable for sector-based four-quark constructions where the two
   amplitude orderings are physically distinct pieces before symmetrization. *)
SymmetrizedInterference[amp1_, amp2_, numFinalParticles_, antennaType_
  ] :=
  Module[{leftRight, rightLeft, output},
    leftRight = InterfereMAmplitudesPair[amp1, amp2, numFinalParticles,
       AntennaType -> antennaType];
    rightLeft = InterfereMAmplitudesPair[amp2, amp1, numFinalParticles,
       AntennaType -> antennaType];
    If[MemberQ[{leftRight, rightLeft}, $Failed],
      output = $Failed
      ,
      output =
        leftRight + rightLeft //
        Simplify //
        Expand
    ];
    output
  ];

(* InterfereMAmp1Count[...]
   ========================
   Evaluate the simpler interference path where each amplitude carries a single
   colour tensor, so the full object can be interfered directly. *)
InterfereMAmp1Count[MAmp1_, MAmp2_, numFinalParticles_, ApplyCasimirSubstitution_,
   ApplyDimReg_, AntennaType_, quarkMass_] :=
  Module[{interfBare, interfSimp, interfNumPart, interfDiracSimp, interfCalc,
     interfFinal, output},
    KinematicRules[numFinalParticles, QuarkMass -> quarkMass];
    interfBare = ComplexConjugate[MAmp1] * MAmp2;
    (* Perform colour simplification and external-state sums before the final
       scalar-product cleanup so the expression is reduced in the same physical
       order one would use by hand. *)
    interfSimp =
      interfBare //
      SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
      FermionSpinSum //
      SafeDoPolarizationSums[#, p, 0, VirtualBoson -> True]&;
    If[AntennaType === A,
      Which[
        numFinalParticles == 2,
          interfNumPart = interfSimp
        ,
        numFinalParticles == 3,
          interfNumPart = SafeDoPolarizationSums[
            interfSimp,
            k3,
            0,
            VirtualBoson -> True
          ]
        ,
        numFinalParticles == 4,
          interfNumPart = SafeDoPolarizationSums[
            SafeDoPolarizationSums[interfSimp, k3, k4],
            k4,
            k3
          ]
      ]
      ,
      interfNumPart = interfSimp;
    ];
    interfDiracSimp = interfNumPart // DiracSimplify;
    interfCalc = Calc[interfDiracSimp];
    interfFinal = interfCalc // ApplyFeynCalcRules[#, numFinalParticles
      ]&;
    If[ApplyCasimirSubstitution === True,
      interfFinal = interfFinal /. CasimirSubs
    ];
    If[ApplyDimReg === True,
      interfFinal = interfFinal /. D -> 4 - 2 Epsilon
    ];
    output = interfFinal // Simplify;
    output
  ];

(* InterfereMAmp2Count[...]
   ========================
   Evaluate the more structured interference path where colour and spin pieces
   are separated term by term before recombination.  This is needed when the
   amplitude contains multiple colour tensors and a fully naive conjugate
   product would obscure the physically meaningful colour decomposition. *)
InterfereMAmp2Count[MAmp1_, MAmp2_, numFinalParticles_, ApplyCasimirSubstitution_,
   ApplyDimReg_, AntennaType_, quarkMass_] :=
  Module[{listTermsMAmp1, listTermsMAmp2, terms, C1, S1, C2, S2, CCouples,
     SCouples, MixedCouples, interference, output},
    KinematicRules[numFinalParticles, QuarkMass -> quarkMass];
    listTermsMAmp1 = ReturnColourSpinCouples[MAmp1];
    listTermsMAmp2 = ReturnColourSpinCouples[MAmp2];
    C1 = ConstantArray[0, listTermsMAmp1 // Length];
    C2 = ConstantArray[0, listTermsMAmp2 // Length];
    S1 = ConstantArray[0, listTermsMAmp1 // Length];
    S2 = ConstantArray[0, listTermsMAmp2 // Length];
    Do[
      terms = listTermsMAmp1[[i]];
      C1[[i]] = terms[[1]];
      S1[[i]] = terms[[2]];
      ,
      {i, listTermsMAmp1 // Length}
    ];
    Do[
      terms = listTermsMAmp2[[i]];
      C2[[i]] = terms[[1]];
      S2[[i]] = terms[[2]];
      ,
      {i, listTermsMAmp2 // Length}
    ];
    CCouples = {};
    SCouples = {};
    Do[
      Do[
        AppendTo[CCouples, ComplexConjugate[C1[[i]]] C2[[j]] // SUNSimplify
          ];
        AppendTo[
          SCouples
          ,
          ComplexConjugate[S1[[i]]] S2[[j]] //
          SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
          FermionSpinSum //
          SafeDoPolarizationSums[#, p, 0, VirtualBoson -> True]&
        ]
        ,
        {j, C2 // Length}
      ]
      ,
      {i, C1 // Length}
    ];
    (* B and C antennae dont require gluon polarization sums *)
    If[AntennaType === A,
      (* for A type antennae *)
      Which[
        numFinalParticles == 2,
          Do[
            SCouples[[i]] =
              SCouples[[i]] //
              DiracSimplify //
              Simplify //
              Calc
            ,
            {i, SCouples // Length}
          ]
        ,
        numFinalParticles == 3,
          Do[
            SCouples[[i]] =
              SCouples[[i]] //
              SafeDoPolarizationSums[#, k3, 0, VirtualBoson -> True]& //
              DiracSimplify //
              Simplify //
              Calc
            ,
            {i, SCouples // Length}
          ]
        ,
        numFinalParticles == 4,
          Do[
            SCouples[[i]] =
              SCouples[[i]] //
              SafeDoPolarizationSums[#, k3, k4]& //
              SafeDoPolarizationSums[#, k4, k3]& //
              A40LocalTraceDiracReduce //
              Simplify //
              Calc
            ,
            {i, SCouples // Length}
          ]
        ,
        Default,
          Print["numFinalParticles < 2 or > 4 are not yet implemented. Aborting..."
            ];
          $Failed
      ]
      ,
      (* for B and C type antennae *)
      Do[
        SCouples[[i]] =
          SCouples[[i]] //
          DiracSimplify //
          Simplify //
          Calc;
        ,
        {i, SCouples // Length}
      ]
    ];
    MixedCouples = {};
    Do[AppendTo[MixedCouples, CCouples[[i]] SCouples[[i]]], {i, CCouples
       // Length}];
    interference = Total[MixedCouples];
    interference = interference // ApplyFeynCalcRules[#, numFinalParticles
      ]&;
    If[ApplyCasimirSubstitution === True,
      interference = interference /. CasimirSubs
    ];
    If[ApplyDimReg === True,
      interference = interference /. D -> 4 - 2 Epsilon
    ];
    output = interference // Simplify;
    output
  ];
