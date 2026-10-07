(* Shared kinematics and amplitude utilities.
   These helpers encode package-wide conventions, so small changes here can
   affect many antenna families at once. *)

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

ApplyFeynCalcRules[expr_, numFinalParticles_] :=
  Module[{exprSubs, output},
    exprSubs = expr /. FeynAmpDenSub /. NegativePropDenSub;
    exprSubs = exprSubs /. FeynPropListSubs;
    output = exprSubs;
    output
  ];

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

MakeAmplitudeObject[expr_, n_, L_, colourMode_, couplingMode_, colourNorm_
  ] :=
  (* This lightweight record is the common hand-off object between the raw
     amplitude builders and the interference/extraction stages. *)
  <|"Expression" -> expr, "NumFinalParticles" -> n, "LoopOrder" -> L,
     "ColourMode" -> colourMode, "CouplingMode" -> couplingMode, "AntennaColourNorm"
     -> colourNorm|>;

GluonColourBasisNorm[numGluons_] :=
  Module[{output},
    output = Sqrt[2] ^ numGluons;
    output
  ];

HasPolarizationVectorQ[expr_, mom_] :=
  !FreeQ[expr, Polarization[mom, ___]];

SafeDoPolarizationSums[expr_, mom_, ref_, opts___] :=
  If[HasPolarizationVectorQ[expr, mom],
    DoPolarizationSums[expr, mom, ref, opts]
    ,
    expr
  ];

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

