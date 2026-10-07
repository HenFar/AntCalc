ReduceLoopIntegrals::usage =
  "ReduceLoopIntegrals[expr, loopMomentum, ...] applies the requested one-loop reduction backend before interference extraction.";

SafeOneLoopTreeConjugate::usage =
  "SafeOneLoopTreeConjugate[treeAmp, numFinalParticles] takes the tree conjugate with the extra cleanup needed by the loop routes.";

InterfereTreeOneLoopAmplitudes::usage =
  "InterfereTreeOneLoopAmplitudes[treeAmp, loopAmp, numFinalParticles, ...] builds the one-loop/tree interference used by A21 and A31.";

LoopExpansionNormalization::usage =
  "LoopExpansionNormalization[numLoops] returns the normalization factor used when converting loop amplitudes into the package expansion convention.";

NotebookChargeConvention::usage =
  "NotebookChargeConvention[expr] rewrites charge conventions so saved notebook expressions match the package sign choices.";

InterfereTreeTwoLoopMAmplitudes::usage =
  "InterfereTreeTwoLoopMAmplitudes[treeAmp, twoLoopAmp, numFinalParticles, ...] builds the tree/two-loop interference used by the A22 source route.";

InterfereTreeTwoLoopTerm::usage =
  "InterfereTreeTwoLoopTerm[treeAmp, twoLoopTerm, numFinalParticles] evaluates one tree/two-loop interference contribution.";

InterfereOneLoopSelfMAmplitudes::usage =
  "InterfereOneLoopSelfMAmplitudes[loopAmp, numFinalParticles, ...] builds the one-loop self-interference used by breve A22.";

InterfereOneLoopMAmplitudes::usage =
  "InterfereOneLoopMAmplitudes[treeAmp, loopAmp, numFinalParticles, ...] is the public one-loop interference entrypoint used by the loop builders.";

Options[ReduceLoopIntegrals] = {ReductionBackend -> "PaVe"};

ReduceLoopIntegrals[expr_, loopMomentum_, OptionsPattern[]] :=
  Module[{backend, output},
    backend = OptionValue["ReductionBackend"];
    output =
      Which[
        backend === "PaVe",
          TID[expr, loopMomentum, ToPaVe -> True]
        ,
        backend === None || backend === "None",
          expr
        ,
        True,
          Print["Unsupported loop reduction backend: ", backend, ". Aborting..."
            ];
          $Failed
      ];
    output
  ];

Options[InterfereTreeOneLoopAmplitudes] = {ApplyCasimirSubstitution ->
   True, ApplyDimReg -> False, LoopMomentum -> l, ReductionBackend -> "PaVe"
  };

SafeOneLoopTreeConjugate[treeAmp_, numFinalParticles_] :=
  Module[{safeTree, safeConjugate, output},
    If[numFinalParticles == 3,
      safeTree = treeAmp /. SUNTF[a_, b_, c_] :> DummyColor[a, c, b];
        
      safeConjugate = ComplexConjugate[safeTree];
      output = safeConjugate /. {ComplexConjugate[DummyColor[{a_}, b_,
         c_]] :> SUNTF[{a}, b, c], ComplexConjugate[DummyColor[a_, b_, c_]] :>
         SUNTF[a, b, c], DummyColor[{a_}, b_, c_] :> SUNTF[{a}, b, c], DummyColor[
        a_, b_, c_] :> SUNTF[a, b, c]}
      ,
      output = ComplexConjugate[treeAmp]
    ];
    output
  ];

InterfereOneLoopMAmplitudes[treeAmp_, loopAmp_, numFinalParticles_, OptionsPattern[
  InterfereTreeOneLoopAmplitudes]] :=
  Module[{applyCasimirSubstitutionOpt, applyDimRegOpt, loopMomentumOpt,
     reductionBackendOpt, conjugateTree, bare, simp, numPart, diracSimp, 
    calcExpr, reduced, output},
    applyCasimirSubstitutionOpt = OptionValue["ApplyCasimirSubstitution"
      ];
    applyDimRegOpt = OptionValue["ApplyDimReg"];
    loopMomentumOpt = OptionValue["LoopMomentum"];
    reductionBackendOpt = OptionValue["ReductionBackend"];
    KinematicRules[numFinalParticles];
    conjugateTree = SafeOneLoopTreeConjugate[treeAmp, numFinalParticles
      ];
    bare = 2 loopAmp conjugateTree;
    simp =
      bare //
      SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
      FermionSpinSum //
      SafeDoPolarizationSums[#, p, 0, VirtualBoson -> True]&;
    Which[
      numFinalParticles == 2,
        numPart = simp
      ,
      numFinalParticles == 3,
        numPart = SafeDoPolarizationSums[simp, k3, 0, VirtualBoson -> True]
      ,
      numFinalParticles == 4,
        numPart = SafeDoPolarizationSums[
          SafeDoPolarizationSums[simp, k3, k4],
          k4,
          k3
        ]
      ,
      True,
        Print["Loop interferences are currently implemented only for 2, 3, or 4 final-state particles. Aborting..."
          ];
        Return[$Failed]
    ];
    diracSimp = numPart // DiracSimplify;
    calcExpr = Calc[diracSimp];
    reduced = ReduceLoopIntegrals[calcExpr, loopMomentumOpt, ReductionBackend
       -> reductionBackendOpt];
    If[reduced === $Failed,
      Return[$Failed]
    ];
    output =
      reduced //
      ApplyFeynCalcRules[#, numFinalParticles]& //
      Simplify;
    If[applyCasimirSubstitutionOpt === True,
      output = output /. CasimirSubs // Simplify
    ];
    If[applyDimRegOpt === True,
      output = output /. D -> 4 - 2 Epsilon // Simplify
    ];
    output
  ];

InterfereTreeOneLoopAmplitudes[treeAmp_, loopAmp_, numFinalParticles_,
   OptionsPattern[]] :=
  InterfereOneLoopMAmplitudes[treeAmp, loopAmp, numFinalParticles, ApplyCasimirSubstitution
     -> OptionValue["ApplyCasimirSubstitution"], ApplyDimReg -> OptionValue[
    "ApplyDimReg"], LoopMomentum -> OptionValue["LoopMomentum"], ReductionBackend
     -> OptionValue["ReductionBackend"]];

LoopExpansionNormalization[1] :=
  8 Pi^2;

LoopExpansionNormalization[2] :=
  (8 Pi^2)^2;

NotebookChargeConvention[expr_] :=
  Simplify[upQuarkElectricCharge^2 expr];

(*************************************************)

(* Two-loop and one-loop self-interference machinery for A22 *)

Options[InterfereTreeTwoLoopMAmplitudes] = {ApplyCasimirSubstitution ->
   True, ApplyDimReg -> False, LoopMomenta -> {l1, l2}};

InterfereTreeTwoLoopTerm[treeAmp_, twoLoopTerm_, numFinalParticles_] :=
  Module[{conjugateTree, bare, simp, diracSimp, calcExpr},
    conjugateTree = ComplexConjugate[treeAmp];
    bare = 2 twoLoopTerm conjugateTree;
    simp =
      bare //
      SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
      FermionSpinSum //
      SafeDoPolarizationSums[#, p, 0, VirtualBoson -> True]&;
    diracSimp = simp // DiracSimplify;
    calcExpr = Calc[diracSimp];
    calcExpr //
      ApplyFeynCalcRules[#, numFinalParticles]& //
      Simplify
  ];

InterfereTreeTwoLoopMAmplitudes[treeAmp_, twoLoopAmp_, numFinalParticles_,
   OptionsPattern[]] :=
  Module[{applyCasimirSubstitutionOpt, applyDimRegOpt, terms, output},
    applyCasimirSubstitutionOpt = OptionValue["ApplyCasimirSubstitution"];
    applyDimRegOpt = OptionValue["ApplyDimReg"];
    KinematicRules[numFinalParticles];
    If[numFinalParticles =!= 2,
      Print["Tree/two-loop interferences are currently implemented only for 2 final-state particles. Aborting..."
        ];
      Return[$Failed]
    ];
    terms =
      If[ListQ[twoLoopAmp],
        twoLoopAmp
        ,
        {twoLoopAmp}
      ];
    output =
      Total[InterfereTreeTwoLoopTerm[treeAmp, #, numFinalParticles]& /@
         terms] // Simplify;
    If[applyCasimirSubstitutionOpt === True,
      output = output /. CasimirSubs // Simplify
    ];
    If[applyDimRegOpt === True,
      output = output /. D -> 4 - 2 Epsilon // Simplify
    ];
    output
  ];

Options[InterfereOneLoopSelfMAmplitudes] = {ApplyCasimirSubstitution ->
   True, ApplyDimReg -> False};

InterfereOneLoopSelfMAmplitudes[leftLoopAmp_, rightLoopAmp_,
   numFinalParticles_, OptionsPattern[]] :=
  Module[{applyCasimirSubstitutionOpt, applyDimRegOpt, bare, simp, numPart,
     diracSimp, calcExpr, output},
    applyCasimirSubstitutionOpt = OptionValue["ApplyCasimirSubstitution"];
    applyDimRegOpt = OptionValue["ApplyDimReg"];
    KinematicRules[numFinalParticles];
    bare = ComplexConjugate[leftLoopAmp] rightLoopAmp;
    simp =
      bare //
      SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
      FermionSpinSum //
      DoPolarizationSums[#, p, 0, VirtualBoson -> True]&;
    If[numFinalParticles =!= 2,
      Print["One-loop self-interferences are currently implemented only for 2 final-state particles. Aborting..."
        ];
      Return[$Failed]
    ];
    numPart = simp;
    diracSimp = numPart // DiracSimplify;
    calcExpr = Calc[diracSimp];
    output =
      calcExpr //
      ApplyFeynCalcRules[#, numFinalParticles]& //
      Simplify;
    If[applyCasimirSubstitutionOpt === True,
      output = output /. CasimirSubs // Simplify
    ];
    If[applyDimRegOpt === True,
      output = output /. D -> 4 - 2 Epsilon // Simplify
    ];
    output
  ];
