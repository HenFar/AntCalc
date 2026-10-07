(*************************************************)

(*
  File role and communication map
  -------------------------------
  This file communicates with:
    - src/core/profiles.wl through AntennaProfile[...], which supplies route
      metadata such as excluded particles and DropSumOver policy.
    - src/core/kinematics_and_utilities.wl through StripCouplings[...].
    - src/engines/interference_loop.wl, which consumes the amplitudes produced
      here to build loop/tree and loop/loop interferences.
    - src/routes/build_workflows.wl, which uses these builders indirectly in
      the A21, A31, and A22 source pipelines.

  Why this file exists:
  Loop amplitude generation has its own physics and software constraints:
  explicit loop momenta, topology exclusions, and flavour-sum cleanup.  Keeping
  it separate from tree generation makes those route-specific choices much more
  visible.

  One-loop M amplitude computing function.
  Used first for A21, then for the A31-type antennae.
*)

(*************************************************)

MAmpOneLoop::usage =
  "MAmpOneLoop[numFinalParticles, ...] builds the one-loop M amplitude for the requested A-type antenna sector.";

OneLoopExcludedParticles::usage =
  "OneLoopExcludedParticles[numFinalParticles, antennaType] returns the FeynArts particle exclusions recorded in the antenna profile.";

OneLoopDropSumOver::usage =
  "OneLoopDropSumOver[numFinalParticles, antennaType] returns whether external SumOver factors should be stripped in the selected loop route.";

CleanOneLoopAmplitude::usage =
  "CleanOneLoopAmplitude[amp, numFinalParticles] applies the notebook-to-package cleanup rules used after one-loop amplitude generation.";

MAmpTwoLoop::usage =
  "MAmpTwoLoop[numFinalParticles, ...] builds the experimental two-loop amplitude object used by the A22 source routes.";

TwoLoopExcludedParticles::usage =
  "TwoLoopExcludedParticles[numFinalParticles, antennaType] returns the profile-driven particle exclusions for two-loop generation.";

TwoLoopDropSumOver::usage =
  "TwoLoopDropSumOver[numFinalParticles, antennaType] returns whether SumOver cleanup should be applied after two-loop generation.";

CleanTwoLoopAmplitude::usage =
  "CleanTwoLoopAmplitude[amp, numFinalParticles] applies the standard post-processing rules to raw two-loop amplitudes.";

MAmpTwoLoops::usage =
  "MAmpTwoLoops[numFinalParticles, ...] is a compatibility wrapper around MAmpTwoLoop.";

Options[MAmpOneLoop] = {printDiagram -> False, prefactor -> 1, ApplyStripCouplings
   -> AllCouplings, AntennaType -> A, LoopMomentum -> l};

(*************************************************)
(* OneLoopExcludedParticles[numFinalParticles, antennaType]
   ========================================================
   Read the profile-defined FeynArts particle exclusions for the selected
   one-loop route. *)
OneLoopExcludedParticles[numFinalParticles_, antennaType_] :=
  Lookup[AntennaProfile[{antennaType, numFinalParticles, 1}], "ExcludedParticles",
     {}];

(* OneLoopDropSumOver[numFinalParticles, antennaType]
   ==================================================
   Read the profile-defined DropSumOver policy for one-loop generation. *)
OneLoopDropSumOver[numFinalParticles_, antennaType_] :=
  Lookup[AntennaProfile[{antennaType, numFinalParticles, 1}], "DropSumOver",
     True];

(* CleanOneLoopAmplitude[amp, numFinalParticles]
   =============================================
   Translate notebook-era one-loop output conventions into the explicit
   package conventions used by the extraction layer, especially the `Nf`
   encoding of flavour sums. *)
CleanOneLoopAmplitude[amp_, numFinalParticles_] :=
  Module[{output},
    output = amp;
    If[numFinalParticles == 3,
      output =
        output /.
          {
            SumOver[_, _, External] -> 1
            ,
            SumOver[x_, _] :>
              If[StringMatchQ[ToString[x], "Gen*"],
                Nf
                ,
                1
              ]
            ,
            MQD[_] -> 0
            ,
            MQU[_] -> 0
          }
    ];
    output
  ];

(* MAmpOneLoop[numFinalParticles, OptionsPattern[]]
   ===============================================
   Generate the one-loop amplitude source used by the A21 and A31 workflows. *)
MAmpOneLoop[numFinalParticles_ /; numFinalParticles >= 2, OptionsPattern[
  ]] :=
  Module[{numLoops, optPrintDiag, optPrefactor, optStripCouplings, optAntennaType,
     optLoopMomentum, outMoms, finalState, excludedParticles, excludedTopologies,
     diagsLoop, ampLoop, ampLoopCouplings, output},
    numLoops = 1;
    optPrintDiag = OptionValue["printDiagram"];
    optPrefactor = OptionValue["prefactor"];
    optStripCouplings = OptionValue["ApplyStripCouplings"];
    optAntennaType = OptionValue["AntennaType"];
    optLoopMomentum = OptionValue["LoopMomentum"];
    FCClearScalarProducts[];
    outMoms = Table[Symbol["k" <> ToString[i]], {i, 1, numFinalParticles
      }];
    Do[
      With[{sym = outMoms[[i]], index = ToString[i]},
        SPD[sym, sym] = 0;
        MakeBoxes[sym, TraditionalForm] := SubscriptBox["k", index];
      ]
      ,
      {i, 1, numFinalParticles}
    ];
    If[SymbolName[optAntennaType] =!= "A",
      Print["One-loop amplitudes are currently implemented only for A-type antennae. Aborting..."
        ];
      Return[$Failed]
    ];
    (* The one-loop virtual source is fixed to the A-family gamma* -> q qbar +
       gluons process in SMQCD.  Writing it explicitly here keeps the later
       Born normalization physically transparent. *)
    finalState = Join[{F[3, {1}], -F[3, {1}]}, Table[V[5], {numFinalParticles
       - 2}]];
    excludedParticles = OneLoopExcludedParticles[numFinalParticles, optAntennaType
      ];
    excludedTopologies = {WFCorrections, Tadpoles};
    diagsLoop = InsertFields[CreateTopologies[1, 1 -> numFinalParticles,
       ExcludeTopologies -> excludedTopologies], {V[1]} -> finalState, InsertionLevel
       -> {Classes}, Model -> "SMQCD", ExcludeParticles -> excludedParticles
      ];
    If[optPrintDiag == True,
      Print[Paint[diagsLoop, ColumnsXRows -> {2, 2}, Numbering -> Simple,
        SheetHeader -> None, ImageSize -> {512, 512}]];
    ];
    ampLoop =
      With[{evalDiags = diagsLoop, evalOutMoms = outMoms, evalLoopMomentum
         = optLoopMomentum},
        FCFAConvert[CreateFeynAmp[evalDiags], IncomingMomenta -> {p},
           LoopMomenta -> {evalLoopMomentum}, OutgoingMomenta -> evalOutMoms, UndoChiralSplittings
           -> True, ChangeDimension -> D, List -> False, SMP -> True, Contract 
          -> True, DropSumOver -> OneLoopDropSumOver[numFinalParticles, optAntennaType
          ], Prefactor -> optPrefactor, FinalSubstitutions -> {SMP["m_u"] -> 0,
           SMP["m_d"] -> 0, SMP["m_s"] -> 0, SMP["m_c"] -> 0, SMP["m_b"] -> 0, 
          SMP["m_t"] -> 0}]
      ];
    ampLoopCouplings = ampLoop / StripCouplings[optStripCouplings, numFinalParticles,
       numLoops];
    output =
      CleanOneLoopAmplitude[ampLoopCouplings, numFinalParticles] //
      SUNSimplify //
      Simplify;
    output
  ];

(*************************************************)

(*
  Two-loop M amplitude computing function.
  This is currently needed only for the A22 two-parton virtual antenna.  The
  function mirrors MAmpOneLoop, but uses two independent loop momenta.
*)

(*************************************************)

Options[MAmpTwoLoop] = {printDiagram -> False, prefactor -> 1,
   ApplyStripCouplings -> AllCouplings, AntennaType -> A,
   LoopMomenta -> {l1, l2}};

(* TwoLoopExcludedParticles / TwoLoopDropSumOver mirror the one-loop helpers,
   but read from the two-loop profile entries because A22 has its own source
   generation constraints. *)
TwoLoopExcludedParticles[numFinalParticles_, antennaType_] :=
  Lookup[AntennaProfile[{antennaType, numFinalParticles, 2}],
    "ExcludedParticles", {}];

TwoLoopDropSumOver[numFinalParticles_, antennaType_] :=
  Lookup[AntennaProfile[{antennaType, numFinalParticles, 2}], "DropSumOver",
    False];

CleanTwoLoopAmplitude[amp_, numFinalParticles_] :=
  amp /.
    {
      SumOver[_, _, External] -> 1
      ,
      SumOver[x_, _] :>
        If[StringMatchQ[ToString[x], "Gen*"] ||
            StringContainsQ[ToString[x], "Generation"],
          Nf
          ,
          1
        ]
      ,
      MQD[_] -> 0
      ,
      MQU[_] -> 0
    };

(* MAmpTwoLoop[numFinalParticles, OptionsPattern[]]
   ===============================================
   Generate the experimental two-loop amplitude source used by the A22 route. *)
MAmpTwoLoop[numFinalParticles_ /; numFinalParticles == 2, OptionsPattern[
  ]] :=
  Module[{numLoops, optPrintDiag, optPrefactor, optStripCouplings,
     optAntennaType, optLoopMomenta, outMoms, finalState, excludedParticles,
     excludedTopologies, diagsLoop, ampLoop, ampLoopCouplings, output},
    numLoops = 2;
    optPrintDiag = OptionValue["printDiagram"];
    optPrefactor = OptionValue["prefactor"];
    optStripCouplings = OptionValue["ApplyStripCouplings"];
    optAntennaType = OptionValue["AntennaType"];
    optLoopMomenta = OptionValue["LoopMomenta"];
    (* Use the canonical outgoing momentum labels immediately so later
       denominator-to-invariant rewrites recognize the loop amplitude without
       any route-specific relabeling. *)
    FCClearScalarProducts[];
    outMoms = Table[Symbol["k" <> ToString[i]], {i, 1, numFinalParticles
      }];
    Do[
      With[{sym = outMoms[[i]], index = ToString[i]},
        SPD[sym, sym] = 0;
        MakeBoxes[sym, TraditionalForm] := SubscriptBox["k", index];
      ]
      ,
      {i, 1, numFinalParticles}
    ];
    If[SymbolName[optAntennaType] =!= "A",
      Print["Two-loop amplitudes are currently implemented only for A-type antennae. Aborting..."
        ];
      Return[$Failed]
    ];
    If[Length[optLoopMomenta] =!= 2,
      Print["MAmpTwoLoop expects exactly two loop momenta. Aborting..."];
      Return[$Failed]
    ];
    finalState = {F[3, {1}], -F[3, {1}]};
    excludedParticles = TwoLoopExcludedParticles[numFinalParticles,
      optAntennaType];
    excludedTopologies = {WFCorrections, Tadpoles};
    diagsLoop = InsertFields[CreateTopologies[2, 1 -> numFinalParticles,
       ExcludeTopologies -> excludedTopologies], {V[1]} -> finalState,
      InsertionLevel -> {Classes}, Model -> "SMQCD",
      ExcludeParticles -> excludedParticles];
    If[optPrintDiag == True,
      Print[Paint[diagsLoop, ColumnsXRows -> {3, 3}, Numbering -> Simple,
        SheetHeader -> None, ImageSize -> {768, 768}]];
    ];
    (* The profile-driven DropSumOver behavior is left visible at conversion
       time because it is part of how the project balances compactness against
       transparent flavour bookkeeping in different loop routes. *)
    ampLoop =
      With[{evalDiags = diagsLoop, evalOutMoms = outMoms,
        evalLoopMomenta = optLoopMomenta},
        FCFAConvert[CreateFeynAmp[evalDiags], IncomingMomenta -> {p},
          LoopMomenta -> evalLoopMomenta, OutgoingMomenta -> evalOutMoms,
          UndoChiralSplittings -> True, ChangeDimension -> D, List -> True,
          SMP -> True, Contract -> True, DropSumOver -> TwoLoopDropSumOver[
            numFinalParticles, optAntennaType], Prefactor -> optPrefactor,
          FinalSubstitutions -> {SMP["m_u"] -> 0, SMP["m_d"] -> 0,
            SMP["m_s"] -> 0, SMP["m_c"] -> 0, SMP["m_b"] -> 0,
            SMP["m_t"] -> 0}]
      ];
    ampLoopCouplings =
      ampLoop / StripCouplings[optStripCouplings, numFinalParticles,
        numLoops];
    output =
      If[ListQ[ampLoopCouplings],
        (CleanTwoLoopAmplitude[#, numFinalParticles] // Simplify)& /@
          ampLoopCouplings
        ,
        CleanTwoLoopAmplitude[ampLoopCouplings, numFinalParticles] //
          Simplify
      ];
    output
  ];

MAmpTwoLoop[numFinalParticles_, OptionsPattern[]] :=
  Module[{},
    Print["MAmpTwoLoop is currently implemented only for 2 final-state particles. You selected ",
      numFinalParticles, ". Aborting..."];
    $Failed
  ];

MAmpTwoLoops[numFinalParticles_, opts:OptionsPattern[MAmpTwoLoop]] :=
  MAmpTwoLoop[numFinalParticles, opts];
