(* ::Section:: *)
(* Tree-level amplitude generation *)

(* Communicates with:
   - src/core/kinematics_and_utilities.wl through StripCouplings[...] and the
     shared scalar-product conventions.
   - src/core/profiles.wl through AntennaAmplitude[...], which memoizes and
     exposes MAmpLoopLess[...] as the tree-level source for many routes.
   - src/engines/interference_tree.wl, which consumes the amplitudes produced
     here to build self-interferences and mixed interferences.
   - src/engines/color_ordered_a40.wl, which further decomposes the A40 tree
     amplitude into color-ordered pieces.

   Why this file exists:
   This is the lowest-level tree-generation layer: it turns a process
   definition into a raw FeynCalc amplitude before any interference or antenna
   extraction occurs.  Keeping generation separate from extraction makes the
   physics pipeline easier to reason about, especially when one wants to debug
   whether an issue entered at the diagram stage or at the normalization stage. *)

ComputeMAmplitude::usage =
  "ComputeMAmplitude[numFinalParticles, numLoops] dispatches to the tree, one-loop, or two-loop M-amplitude builder for the requested multiplicity.";

MAmpLoopLess::usage =
  "MAmpLoopLess[numFinalParticles, ...] builds the tree-level M amplitude used as the starting point for tree antenna construction.";

AntennaTreeDiagramSet::usage =
  "AntennaTreeDiagramSet[numFinalParticles, antennaType] returns the FeynArts tree diagram set for the requested antenna source.";

PrintAntennaTreeDiagrams::usage =
  "PrintAntennaTreeDiagrams[numFinalParticles, antennaType] renders the tree diagram set used by a BuildAntenna route without rebuilding its memoized amplitude.";

(*************************************************)

(*
  General M amplitude computing function. \
It delegates the generation of the amplitudes based on the number of l\
oops.
*)

(*************************************************)

(* ComputeMAmplitude[numFinalParticles, numLoops]
   ==============================================
   Dispatch to the appropriate amplitude generator based on loop order.

   Notes
     This is a compatibility-level dispatcher rather than a deep abstraction.
     The actual physics-specific logic still lives in the dedicated tree, one-
     loop, and two-loop builders because their generation constraints differ
     substantially. *)
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

(* Keep diagram rendering separate from amplitude construction.  Most public
   tree routes use AntennaAmplitude[key], which is deliberately memoized and
   therefore cannot replay a generation-time option on a cache hit. *)
AntennaTreeDiagramSet[numFinalParticles_Integer, antennaType_] :=
  Module[{finalState, excludedParticles},
    finalState =
      Switch[antennaType,
        A,
          Join[{F[3, {1}], -F[3, {1}]}, Table[V[5], {numFinalParticles - 2}]]
        ,
        B,
          {F[3, {1}], -F[3, {1}], F[3, {2}], -F[3, {2}]}
        ,
        C,
          {F[3, {1}], -F[3, {1}], F[3, {1}], -F[3, {1}]}
      ];
    excludedParticles =
      Switch[antennaType,
        A, {},
        B | C, {V[1], V[2], S[_]}
      ];
    InsertFields[CreateTopologies[0, 1 -> numFinalParticles],
      {V[1]} -> finalState, InsertionLevel -> {Classes}, Model -> "SMQCD",
      ExcludeParticles -> excludedParticles]
  ];

PrintAntennaTreeDiagrams[numFinalParticles_Integer, antennaType_:A] :=
  Module[{diagrams},
    diagrams = AntennaTreeDiagramSet[numFinalParticles, antennaType];
    Print[Style["[AntCalc] Tree diagrams: ", Bold],
      "", antennaType, numFinalParticles, " (", numFinalParticles,
      " final-state partons)"];
    Print[Paint[diagrams, ColumnsXRows -> {2, 1}, Numbering -> Simple,
      SheetHeader -> None, ImageSize -> {512, 256}]];
    diagrams
  ];

(* MAmpLoopLess[numFinalParticles, OptionsPattern[]]
   ================================================
   Summary
     Generate the tree-level M amplitude for the requested antenna family.

   Parameters
     numFinalParticles : Integer
       Number of outgoing resolved partons.

   Options
     printDiagram : Boolean
       Whether to draw the generated FeynArts diagrams.
     prefactor : expression
       Prefactor passed through to `CreateFeynAmp`.
     ApplyStripCouplings : symbol
       Coupling-normalization mode consumed by StripCouplings[...].
     AntennaType : symbol
       Antenna family selector (`A`, `B`, or `C`).
     quarkMass : expression
       Optional mass assigned to the quark pair in the A-type route.

   Returns
     expression
       The simplified tree-level amplitude.

   Notes
     The function fixes the external-state content at the amplitude level rather
     than deducing it later from a generic process.  That is a physics-facing
     design choice: the antenna family is fundamentally defined by which partons
     are resolved, so making the final state explicit here reduces ambiguity
     downstream. *)
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
    (* The mass substitutions define whether we are working in the standard
       massless antenna convention or in the massive variant used for selected
       cross-checks.  Encoding them once here keeps the generated diagrams and
       the scalar-product setup physically aligned. *)
    finalSubstitutions =
      If[TrueQ[quarkMassOpt === 0],
        {SMP["m_u"] -> 0, SMP["m_d"] -> 0, SMP["m_s"] -> 0, SMP["m_c"] -> 0,
          SMP["m_b"] -> 0, SMP["m_t"] -> 0}
        ,
        {SMP["m_u"] -> 0, SMP["m_d"] -> quarkMassOpt, SMP["m_s"] -> 0,
          SMP["m_c"] -> 0, SMP["m_b"] -> 0, SMP["m_t"] -> 0}
      ];
    (* Generate canonical outgoing momentum labels.  The rest of the package
       assumes these names when mapping propagators to Mandelstam invariants, so
       it is important that generation already uses the shared naming scheme. *)
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
    (* Choose the external state directly from the antenna family.  The B/C
       four-quark antennae are not just differently normalized A-type objects;
       they correspond to genuinely different flavour/current assignments, so we
       branch here rather than trying to retrofit that distinction later. *)
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
    (* Build the actual tree topologies and insert the family-specific external
       fields.  The model stays fixed to SMQCD because these antennae are meant
       to capture QCD radiation patterns in that convention. *)
    diagsTree = AntennaTreeDiagramSet[numFinalParticles, optAntennaType];
    (* paint said diagrams *)
    If[optPrintDiag == True,
      Print[Paint[diagsTree, ColumnsXRows -> {2, 1}, Numbering -> Simple,
        SheetHeader -> None, ImageSize -> {512, 256}]];
    ];
    (* Convert the FeynArts amplitude to FeynCalc form with a package-wide set
       of options: outgoing momenta, explicit symbolic parameters, and stripped
       sum-over clutter where appropriate.  This keeps the generated object
       compatible with the generic interference builders. *)
    ampTree =
      With[{evalDiags = diagsTree, evalOutMoms = outMoms},
        FCFAConvert[CreateFeynAmp[evalDiags], IncomingMomenta -> {p},
           OutgoingMomenta -> evalOutMoms, UndoChiralSplittings -> True, ChangeDimension
           -> D, List -> False, SMP -> True, Contract -> True, DropSumOver -> True,
           Prefactor -> optPrefactor, FinalSubstitutions -> finalSubstitutions]
      ];
    (* Coupling normalization is factored in a dedicated final step so the same
       generated amplitude can support routes that want full couplings retained
       and routes that want them stripped before extraction. *)
    ampTreeCouplings = ampTree / StripCouplings[optStripCouplings, numFinalParticles,
       numLoops];
    output =
      ampTreeCouplings //
      SUNSimplify //
      Simplify;
    output
  ];
