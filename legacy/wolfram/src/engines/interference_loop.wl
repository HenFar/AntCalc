(* ::Section:: *)
(* Loop-level interference construction *)

(* Communicates with:
   - src/engines/amplitudes_tree.wl and src/engines/amplitudes_loop.wl, whose
     outputs are interfered here.
   - src/core/kinematics_and_utilities.wl through KinematicRules,
     SafeDoPolarizationSums, and ApplyFeynCalcRules.
   - src/engines/extraction_loop.wl, which consumes the normalized loop
     interferences produced here.
   - src/routes/build_workflows.wl, which uses these helpers inside the A21,
     A31, and A22 virtual-source workflows.

   Why this file exists:
   Loop interferences have a distinct algebraic shape from tree ones because
   they may still contain unreduced tensor integrals and because the package
   adopts an explicit loop-expansion normalization convention.  Those concerns
   are isolated here rather than mixed into generic interference logic. *)

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

(* ReduceLoopIntegrals[expr, loopMomentum, ...]
   ============================================
   Apply the chosen one-loop reduction backend before antenna extraction. *)
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
   True, ApplyDimReg -> False, LoopMomentum -> l, ReductionBackend -> "PaVe",
   ReturnStages -> False
  };

(* SafeOneLoopTreeConjugate[treeAmp, numFinalParticles]
   ====================================================
   Conjugate a tree amplitude in the way required by the one-loop routes.

   Notes
     The A31 colour structure needs a small convention-preserving workaround so
     conjugation does not scramble the tensor ordering expected by the later
     decomposition logic. *)
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

(* InterfereOneLoopMAmplitudes[treeAmp, loopAmp, numFinalParticles, ...]
   =====================================================================
   Build the one-loop/tree interference used by the A21 and A31 routes. *)
InterfereOneLoopMAmplitudes[treeAmp_, loopAmp_, numFinalParticles_, OptionsPattern[
  InterfereTreeOneLoopAmplitudes]] :=
  Module[{applyCasimirSubstitutionOpt, applyDimRegOpt, loopMomentumOpt,
     reductionBackendOpt, conjugateTree, bare, simp, numPart, diracSimp, 
    calcExpr, reduced, output, returnStages},
    applyCasimirSubstitutionOpt = OptionValue["ApplyCasimirSubstitution"
      ];
    applyDimRegOpt = OptionValue["ApplyDimReg"];
    loopMomentumOpt = OptionValue["LoopMomentum"];
    reductionBackendOpt = OptionValue["ReductionBackend"];
    returnStages = TrueQ[OptionValue[ReturnStages]];
    KinematicRules[numFinalParticles];
    conjugateTree = SafeOneLoopTreeConjugate[treeAmp, numFinalParticles
      ];
    (* The factor of 2 implements the standard real-part convention for
       tree/loop interference, written explicitly so the normalization is
       visible at the point where the physical interference is formed. *)
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
    If[returnStages,
      <|
        "InterferenceBeforeReduction" -> calcExpr,
        "ReducedInterference" -> reduced,
        "Interference" -> output,
        "ReductionBackend" -> reductionBackendOpt
      |>
      ,
      output
    ]
  ];

(* Keep InterfereTreeOneLoopAmplitudes as the public historical name while
   routing the implementation through InterfereOneLoopMAmplitudes[...]. *)
InterfereTreeOneLoopAmplitudes[treeAmp_, loopAmp_, numFinalParticles_,
   OptionsPattern[]] :=
  InterfereOneLoopMAmplitudes[treeAmp, loopAmp, numFinalParticles, ApplyCasimirSubstitution
     -> OptionValue["ApplyCasimirSubstitution"], ApplyDimReg -> OptionValue[
    "ApplyDimReg"], LoopMomentum -> OptionValue["LoopMomentum"], ReductionBackend
     -> OptionValue["ReductionBackend"], ReturnStages -> OptionValue[ReturnStages]];

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

(* InterfereTreeTwoLoopTerm[treeAmp, twoLoopTerm, numFinalParticles]
   =================================================================
   Evaluate one tree/two-loop interference contribution before the A22-specific
   component extraction stage. *)
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

(* InterfereTreeTwoLoopMAmplitudes[treeAmp, twoLoopAmp, numFinalParticles, ...]
   =============================================================================
   Sum all tree/two-loop interference terms for the A22 source route. *)
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

(* InterfereOneLoopSelfMAmplitudes[leftLoopAmp, rightLoopAmp, numFinalParticles, ...]
   ===================================================================================
   Build the one-loop self-interference source used for the breve A22
   contribution. *)
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
