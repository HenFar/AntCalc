(* ::Section:: *)
(* Shared kinematics and amplitude utilities *)

(* Communicates with:
   - src/core/setup.wl, whose propagator and coupling conventions are consumed
     by ApplyFeynCalcRules and StripCouplings.
   - src/engines/amplitudes_tree.wl and src/engines/amplitudes_loop.wl, which
     use StripCouplings and MakeAmplitudeObject to package raw amplitudes.
   - src/engines/interference_tree.wl and src/engines/interference_loop.wl,
     which rely on SpinPolSum and the colour helpers during interference
     construction.
   - src/engines/extraction_tree.wl and src/engines/extraction_loop.wl, which
     inherit the kinematic normalization choices encoded here.

   Why this file exists:
   The project treats kinematic and coupling conventions as infrastructure,
   not route-local details.  Centralizing them here means that when a physics
   convention changes, every tree, loop, and integration workflow sees the same
   scalar products, prefactor stripping rules, and polarization logic. *)

KinematicRules::usage =
  "KinematicRules[numFinalParticles, ...] sets the scalar-product kinematics used throughout the package for the selected final-state multiplicity.";

ApplyFeynCalcRules::usage =
  "ApplyFeynCalcRules[expr, numFinalParticles] normalizes denominator and propagator syntax after FeynCalc/FeynArts generation.";

StripCouplings::usage =
  "StripCouplings[flag, numFinalParticles, numLoops] returns the coupling factor associated with the selected stripping mode.";

MakeAmplitudeObject::usage =
  "MakeAmplitudeObject[expr, n, L, colourMode, couplingMode, colourNorm] wraps a raw amplitude together with the metadata used by later pipeline stages.";

GluonColourBasisNorm::usage =
  "GluonColourBasisNorm[numGluons] returns the normalization factor for the color-stripped gluon basis.";

HasPolarizationVectorQ::usage =
  "HasPolarizationVectorQ[expr, mom] tests whether a polarization vector for the given momentum still appears in an expression.";

SafeDoPolarizationSums::usage =
  "SafeDoPolarizationSums[expr, mom, ref, ...] applies DoPolarizationSums only when the matching polarization vector is present.";

SpinPolSum::usage =
  "SpinPolSum[expr, numFinalParticles] performs the standard spin and polarization sums for the selected tree or loop expression.";

ColourTensorCounter::usage =
  "ColourTensorCounter[amp] counts color-tensor structures inside an amplitude expression.";

ReturnColourSpinCouples::usage =
  "ReturnColourSpinCouples[MAmp] extracts the color-and-spin normalized expression returned by the amplitude builders.";

Options[KinematicRules] = {QuarkMass -> 0};

(* KinematicRules[numFinalParticles, OptionsPattern[]]
   ===================================================
   Summary
     Install the package-wide scalar-product environment for a fixed final-state
     multiplicity and quark-mass convention.

   Parameters
     numFinalParticles : Integer
       Number of outgoing resolved partons used by the current antenna route.
     QuarkMass : expression, optional
       Mass assigned to the quark pair.  `0` selects the default massless
       antenna convention; any other value switches the quark legs onto the
       corresponding massive shell.

   Returns
     Null
       This function acts by defining FeynCalc scalar products globally.

   Notes
     FeynCalc stores scalar products in mutable kernel state.  The explicit
     reset at the top is a design choice for reproducibility: it prevents a
     stale notebook session from contaminating a later route with incompatible
     on-shell conditions. *)
KinematicRules[numFinalParticles_Integer /; numFinalParticles >= 2, OptionsPattern[
  ]] :=
  Module[{quarkMassOpt},
    quarkMassOpt = OptionValue["QuarkMass"];
    (* The package assumes one active scalar-product environment at a time.
       Clearing first avoids stale notebook state leaking into later routes. *)
    FCClearScalarProducts[];
    If[quarkMassOpt == 0,
      (* The massless routes use outgoing momenta and the standard s_ij/2
         normalization for scalar products.  Many later simplifications assume
         exactly these assignments rather than deriving them on the fly. *)
      Which[
        numFinalParticles == 2,
          SPD[k1, k1] = 0;
          SPD[k2, k2] = 0;
          SPD[k1, k2] = q2 / 2
        ,
        numFinalParticles == 3,
          SPD[k1, k1] = 0;
          SPD[k2, k2] = 0;
          SPD[k3, k3] = 0;
          SPD[k1, k2] = s12 / 2;
          SPD[k1, k3] = s13 / 2;
          SPD[k2, k3] = s23 / 2
        ,
        numFinalParticles == 4,
          SPD[k1, k1] = 0;
          SPD[k2, k2] = 0;
          SPD[k3, k3] = 0;
          SPD[k4, k4] = 0;
          SPD[k1, k2] = s12 / 2;
          SPD[k1, k3] = s13 / 2;
          SPD[k1, k4] = s14 / 2;
          SPD[k2, k3] = s23 / 2;
          SPD[k2, k4] = s24 / 2;
          SPD[k3, k4] = s34 / 2
      ]
      ,
      Which[
        numFinalParticles == 2,
          SPD[k1, k1] = quarkMassOpt ^ 2;
          SPD[k2, k2] = quarkMassOpt ^ 2;
          SPD[k1, k2] = (q2 - 2 quarkMassOpt ^ 2) / 2
        ,
        numFinalParticles == 3,
          SPD[k1, k1] = quarkMassOpt ^ 2;
          SPD[k2, k2] = quarkMassOpt ^ 2;
          SPD[k3, k3] = 0;
          SPD[k1, k2] = s12 / 2;
          SPD[k1, k3] = s13 / 2;
          SPD[k2, k3] = s23 / 2
        ,
        numFinalParticles == 4,
          SPD[k1, k1] = quarkMassOpt ^ 2;
          SPD[k2, k2] = quarkMassOpt ^ 2;
          SPD[k3, k3] = 0;
          SPD[k4, k4] = 0;
          SPD[k1, k2] = s12 / 2;
          SPD[k1, k3] = s13 / 2;
          SPD[k1, k4] = s14 / 2;
          SPD[k2, k3] = s23 / 2;
          SPD[k2, k4] = s24 / 2;
          SPD[k3, k4] = s34 / 2
      ]
    ];
  ];

(* ApplyFeynCalcRules[expr, numFinalParticles]
   ===========================================
   Summary
     Normalize propagator syntax produced by FeynArts/FeynCalc into the compact
     invariant-based representation used by the rest of the package.

   Parameters
     expr : expression
       Raw symbolic amplitude or interference expression.
     numFinalParticles : Integer
       Final-state multiplicity.  Included for interface consistency with the
       other convention helpers, even though the current replacements are
       multiplicity-independent.

   Returns
     expression
       The same physics object rewritten into the package’s canonical
       denominator language.

   Notes
     This helper exists because later extraction and comparison stages are built
     around `sij` invariants, not around nested `FeynAmpDenominator` heads. *)
ApplyFeynCalcRules[expr_, numFinalParticles_] :=
  Module[{exprSubs, output},
    exprSubs = expr /. FeynAmpDenSub /. NegativePropDenSub;
    exprSubs = exprSubs /. FeynPropListSubs;
    output = exprSubs;
    output
  ];

(* StripCouplings[flag, numFinalParticles, numLoops]
   =================================================
   Summary
     Return the coupling prefactor associated with the chosen stripping mode.

   Parameters
     flag : symbol or False
       Coupling-selection mode.  Supported values are `False`,
       `AllCouplings`, `ElectricCoupling`, and `StrongCoupling`.
     numFinalParticles : Integer
       Final-state multiplicity of the antenna under construction.
     numLoops : Integer
       Loop order of the object whose coupling counting is being normalized.

   Returns
     expression
       The prefactor to divide out or keep, depending on the route.

   Notes
     The strong coupling power is determined from the antenna multiplicity and
     loop order instead of being pattern-matched from the algebra.  That is a
     usability choice: explicit counting is more stable than inferring powers
     from expressions that may already have been simplified or partially
     normalized. *)
StripCouplings[flag_, numFinalParticles_, numLoops_] :=
  Module[{electricCoupling, strongCoupling, output},
    (* The builders factor couplings in a consistent package convention so
       later extraction and comparison steps can decide explicitly whether to
       keep or strip electroweak and strong prefactors. *)
    electricCoupling = electricCouplingConstant * upQuarkElectricCharge
      ;
    strongCoupling = strongCouplingConstant ^ (numFinalParticles - 2 
      + 2 numLoops);
    Which[
      flag === False,
        output = 1
      ,
      flag === AllCouplings,
        output = electricCoupling * strongCoupling
      ,
      flag === ElectricCoupling,
        output = electricCoupling
      ,
      flag === StrongCoupling,
        output = strongCoupling
      ,
      Default,
        Print["Non-valid option inserted. Valid options are: AllCouplings, ElectricCoupling, StrongCoupling. Aborting..."
          ];
        $Failed
    ];
    output
  ];

(* MakeAmplitudeObject[expr, n, L, colourMode, couplingMode, colourNorm]
   ======================================================================
   Summary
     Package a raw symbolic amplitude together with the metadata needed by the
     interference and extraction layers.

   Parameters
     expr : expression
       Raw FeynCalc amplitude.
     n : Integer
       Number of final-state partons.
     L : Integer
       Loop order.
     colourMode : expression
       Internal tag describing how colour information is organized.
     couplingMode : expression
       Internal tag describing whether couplings were stripped or retained.
     colourNorm : expression
       Antenna normalization factor used when extracting the final scalar
       antenna from the matrix element.

   Returns
     Association
       A lightweight record shared across the engine layer.

   Notes
     This is intentionally just an association, not a custom symbolic head.
     The design favors inspectability in notebooks and loose compatibility with
     old workflow code over a stricter type system. *)
MakeAmplitudeObject[expr_, n_, L_, colourMode_, couplingMode_, colourNorm_
  ] :=
  (* This lightweight record is the common hand-off object between the raw
     amplitude builders and the interference/extraction stages. *)
  <|"Expression" -> expr, "NumFinalParticles" -> n, "LoopOrder" -> L,
     "ColourMode" -> colourMode, "CouplingMode" -> couplingMode, "AntennaColourNorm"
     -> colourNorm|>;

(* GluonColourBasisNorm[numGluons]
   ===============================
   Summary
     Return the normalization factor associated with the project’s gluon colour
     basis convention.

   Parameters
     numGluons : Integer
       Number of external gluons in the color-ordered object.

   Returns
     expression
       The basis normalization factor.

   Notes
     This is kept as a named helper because the normalization is a convention,
     not a universal identity.  Calling it out explicitly makes later
     color-ordered formulas easier to audit against the literature. *)
GluonColourBasisNorm[numGluons_] :=
  Module[{output},
    output = Sqrt[2] ^ numGluons;
    output
  ];

(* HasPolarizationVectorQ[expr, mom]
   =================================
   Summary
     Test whether an expression still contains an unsummed polarization vector
     for a specified momentum.

   Parameters
     expr : expression
       Symbolic amplitude or interference term.
     mom : symbol
       Momentum label to inspect.

   Returns
     Boolean
       `True` when the polarization vector is present.

   Notes
     This guard exists because aggressive prior simplification can remove some
     external vectors completely.  Calling DoPolarizationSums blindly in that
     situation is both slower and less robust. *)
HasPolarizationVectorQ[expr_, mom_] :=
  !FreeQ[expr, Polarization[mom, ___]];

(* SafeDoPolarizationSums[expr, mom, ref, opts___]
   ===============================================
   Summary
     Apply `DoPolarizationSums` only when the target polarization vector
     actually appears in the expression.

   Parameters
     expr : expression
       Symbolic object to sum over.
     mom : symbol
       Momentum label of the vector boson whose polarization is to be summed.
     ref : expression
       Reference momentum passed through to FeynCalc.
     opts : sequence
       Additional options forwarded to `DoPolarizationSums`.

   Returns
     expression
       Either the polarization-summed expression or the original input.

   Notes
     This is a small software guard with a real usability payoff: it lets the
     same reduction code run across antenna families that differ in which
     polarization structures survive intermediate simplification. *)
SafeDoPolarizationSums[expr_, mom_, ref_, opts___] :=
  If[HasPolarizationVectorQ[expr, mom],
    DoPolarizationSums[expr, mom, ref, opts]
    ,
    expr
  ];

(* SpinPolSum[expr, numFinalParticles]
   ===================================
   Summary
     Perform the standard spin and polarization sums for the current antenna
     multiplicity.

   Parameters
     expr : expression
       Interference expression before external-state sums.
     numFinalParticles : Integer
       Final-state multiplicity, used to decide which gluon legs require
       polarization sums.

   Returns
     expression
       The summed and simplified expression.

   Notes
     The polarization logic is multiplicity-aware because the project uses a
     single helper across antenna families with different external content.
     Encoding that branch here keeps the engine files focused on physics
     construction rather than on repeated boilerplate around the same sums. *)
SpinPolSum[expr_, numFinalParticles_] :=
  Module[{result, resultWhich, output},
    (* Polarization sums are applied only to vectors that actually survive the
       earlier algebra.  That keeps the helper robust across antenna families
       whose reduced expressions no longer carry every nominal external leg. *)
    result =
      expr //
      FermionSpinSum //
      SafeDoPolarizationSums[#, p, 0, VirtualBoson -> True]&;
    Which[
      numFinalParticles == 3,
        resultWhich = SafeDoPolarizationSums[result, k3, 0]
      ,
      numFinalParticles == 4,
        resultWhich = SafeDoPolarizationSums[
          SafeDoPolarizationSums[result, k3, 0],
          k4,
          0
        ]
      ,
      Default,
        resultWhich = result
    ];
    resultWhich =
      resultWhich //
      DiracSimplify //
      Contract //
      Simplify;
    output = resultWhich;
    output
  ];

(* ColourTensorCounter[amp]
   ========================
   Summary
     Count how many terms in an amplitude still carry explicit colour tensors.

   Parameters
     amp : expression
       Usually a list-like decomposition of amplitude terms.

   Returns
     Integer
       Number of entries containing `SUNTF` or `SUNFDelta`.

   Notes
     This is primarily a diagnostic helper.  It provides a lightweight way to
     tell whether a route has successfully separated colour structure from
     kinematics before a more expensive extraction step is attempted. *)
ColourTensorCounter[amp_] :=
  Module[{ampLen, count, term, output},
    ampLen = amp // Length;
    count = 0;
    Do[
      term = amp[[i]];
      If[Or[!FreeQ[term, SUNTF[__]], !FreeQ[term, SUNFDelta[__]]],
        count = count + 1
      ]
      ,
      {i, ampLen}
    ];
    output = count;
    output
  ];

(* ReturnColourSpinCouples[MAmp]
   =============================
   Summary
     Split amplitude terms into the pieces that carry colour tensors and the
     pieces that carry the complementary spin-kinematic factors.

   Parameters
     MAmp : expression
       Structured amplitude object or sum of such terms.

   Returns
     list
       A pairwise decomposition of colour versus non-colour contributions.

   Notes
     Later reconstruction logic often needs colour and kinematics separately.
     This helper codifies that separation once, rather than forcing each route
     to rediscover it by ad hoc pattern matching. *)
ReturnColourSpinCouples[MAmp_] :=
  Module[{listTotal, cycleList, term},
    If[FreeQ[MAmp, Plus[__]],
      listTotal = {0, 0};
      Do[
        term = MAmp[[i]];
        If[Or[!FreeQ[term, SUNTF[__]], !FreeQ[term, SUNFDelta[__]]],
          listTotal[[1]] = term
          ,
          listTotal[[2]] = term
        ]
        ,
        {i, MAmp // Length}
      ]
      ,
      listTotal = ConstantArray[{0, 0}, MAmp // Length];
      Do[
        cycleList = {0, 0};
        Do[
          term = MAmp[[i]][[j]];
          If[Or[!FreeQ[term, SUNTF[__]], !FreeQ[term, SUNFDelta[__]]],
            
            cycleList[[1]] = term
            ,
            cycleList[[2]] = term
          ]
          ,
          {j, MAmp[[i]] // Length}
        ];
        listTotal[[i]] = cycleList
        ,
        {i, MAmp // Length}
      ];
    ];
    listTotal
  ];

