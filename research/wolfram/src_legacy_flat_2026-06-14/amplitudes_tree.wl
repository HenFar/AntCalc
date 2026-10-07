(* M Amplitudes *)

ComputeMAmplitude::usage =
  "ComputeMAmplitude[numFinalParticles, numLoops] dispatches to the tree, one-loop, or two-loop M-amplitude builder for the requested multiplicity.";

MAmpLoopLess::usage =
  "MAmpLoopLess[numFinalParticles, ...] builds the tree-level M amplitude used as the starting point for tree antenna construction.";

(*************************************************)

(*
  General M amplitude computing function. \
It delegates the generation of the amplitudes based on the number of l\
oops.
*)

(*************************************************)

ComputeMAmplitude[numFinalParticles_, numLoops_] :=
  Module[{MAmp},
    Which[
      numLoops == 0,
        MAmp = MAmpLoopLess[numFinalParticles]
      ,
      numLoops == 1,
        MAmp = MAmpOneLoop[numFinalParticles]
      ,
      numLoops == 2,
        MAmp = MAmpTwoLoops[numFinalParticles];
        Print["The two loop antennae computing feature has not yet been implemented in the current version of this program. Aborting..."
          ];
        $Failed
    ];
    MAmp
  ];

(*************************************************)

(*
  Loopless M amplitude computing function.
*)

(*************************************************)

Options[MAmpLoopLess] = {printDiagram -> False, prefactor -> 1, ApplyStripCouplings
   -> AllCouplings, AntennaType -> A, quarkMass -> 0};

MAmpLoopLess[numFinalParticles_ /; numFinalParticles >= 2, OptionsPattern[
  ]] :=
  Module[{numLoops, optPrintDiag, optPrefactor, optStripCouplings,
     optAntennaType, quarkMassOpt, finalSubstitutions, outMoms, finalState,
     excludedParticles, diagsTree, ampTree, ampTreeCouplings,
     ampTreeColourStrip, metadata, output},
    numLoops = 0;
    (* options *)
    optPrintDiag = OptionValue["printDiagram"];
    optPrefactor = OptionValue["prefactor"];
    optStripCouplings = OptionValue["ApplyStripCouplings"];
    optAntennaType = OptionValue["AntennaType"];
    quarkMassOpt = OptionValue["quarkMass"];
    finalSubstitutions =
      If[TrueQ[quarkMassOpt === 0],
        {SMP["m_u"] -> 0, SMP["m_d"] -> 0, SMP["m_s"] -> 0, SMP["m_c"] -> 0,
          SMP["m_b"] -> 0, SMP["m_t"] -> 0}
        ,
        {SMP["m_u"] -> 0, SMP["m_d"] -> quarkMassOpt, SMP["m_s"] -> 0,
          SMP["m_c"] -> 0, SMP["m_b"] -> 0, SMP["m_t"] -> 0}
      ];
    (* generate k-momenta (outgoing) *)
    FCClearScalarProducts[];
    outMoms = Table[Symbol["k" <> ToString[i]], {i, 1, numFinalParticles
      }];
    Do[
      With[{sym = outMoms[[i]], index = ToString[i]},
        SPD[sym, sym] =
          Which[
            optAntennaType === A && quarkMassOpt =!= 0 && i <= 2,
              quarkMassOpt ^ 2
            ,
            True,
              0
          ];
        MakeBoxes[sym, TraditionalForm] := SubscriptBox["k", index];
      ]
      ,
      {i, 1, numFinalParticles}
    ];
    (* check for kinematics on the B and C antennae *)
    If[And[Or[optAntennaType === B, optAntennaType === C], numFinalParticles
       < 4],
      Print["B and C antennae are only available for 4 final-state particles. You selected antenna type ",
         optAntennaType, " and ", numFinalParticles, " final-state particles."
        ];
      Return[$Failed]
    ];
    (* define final state particles *)
    finalState =
      Switch[optAntennaType,
        A,
          Join[{F[3, {1}], -F[3, {1}]}, Table[V[5], {numFinalParticles
             - 2}]]
        ,
        B,
          {F[3, {1}], -F[3, {1}], F[3, {2}], -F[3, {2}]}
        ,
        C,
          {F[3, {1}], -F[3, {1}], F[3, {1}], -F[3, {1}]}
      ];
(* choose excluded particles (excludes Z and higgs bosons for B/C antennae) 
  
  
  
  
  
  
  
  
  
  *)
    excludedParticles =
      Switch[optAntennaType,
        A,
          {}
        ,
        B,
          {V[1], V[2], S[_]}(* internal photon, Z, or Higgs *)
        ,
        C,
          {V[1], V[2], S[_]}
      ];
    (* generate the diagrams *)
    diagsTree = InsertFields[CreateTopologies[0, 1 -> numFinalParticles
      ], {V[1]} -> finalState, InsertionLevel -> {Classes}, Model -> "SMQCD",
       ExcludeParticles -> excludedParticles];
    (* paint said diagrams *)
    If[optPrintDiag == True,
      Paint[diagsTree, ColumnsXRows -> {2, 1}, Numbering -> Simple, SheetHeader
         -> None, ImageSize -> {512, 256}];
    ];
    (* compute the amplitude itself *)
    ampTree =
      With[{evalDiags = diagsTree, evalOutMoms = outMoms},
        FCFAConvert[CreateFeynAmp[evalDiags], IncomingMomenta -> {p},
           OutgoingMomenta -> evalOutMoms, UndoChiralSplittings -> True, ChangeDimension
           -> D, List -> False, SMP -> True, Contract -> True, DropSumOver -> True,
           Prefactor -> optPrefactor, FinalSubstitutions -> finalSubstitutions]
      ];
    (* apply coupling normalisations *)
    ampTreeCouplings = ampTree / StripCouplings[optStripCouplings, numFinalParticles,
       numLoops];
    output =
      ampTreeCouplings //
      SUNSimplify //
      Simplify;
    output
  ];
