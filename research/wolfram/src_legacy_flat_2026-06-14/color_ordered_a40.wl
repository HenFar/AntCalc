(*************************************************)

(*
  Colour-ordered A40 construction.
  The paper A40 is not the full-colour SUNN coefficient.  This block extracts
  the unsquared (1,3,4,2) fundamental colour chain, squares that colour-stripped
  partial amplitude, and normalises by the colour-stripped Born square.
*)

(*************************************************)

ColorTensorFreeQ::usage =
  "ColorTensorFreeQ[expr] tests whether an expression is free of explicit color tensors.";

ExpandUnsquaredColor::usage =
  "ExpandUnsquaredColor[amp] expands and collects the color structures needed to isolate the A40 ordered partials.";

TwoGluonChainQ::usage =
  "TwoGluonChainQ[expr] returns True when expr is a two-gluon fundamental color chain.";

ChainData::usage =
  "ChainData[chain] extracts the adjoint and fundamental indices carried by a two-gluon color chain.";

ReversedChainPairQ::usage =
  "ReversedChainPairQ[d1, d2] tests whether two chain records form the reversed pair used by the A40 color-ordering logic.";

DiscoverTwoGluonChains::usage =
  "DiscoverTwoGluonChains[orderedAmp] locates the two reversed two-gluon chains expected in the color-ordered A40 construction.";

PoleQ::usage =
  "PoleQ[expr, inv] tests whether an expression contains a pole in the selected invariant.";

PoleSignature::usage =
  "PoleSignature[expr] returns the set of pole invariants present in an expression.";

AdjacentPoleScore1342::usage =
  "AdjacentPoleScore1342[expr] scores a partial amplitude by how closely its pole structure matches the target 1342 ordering.";

ExtractTwoGluonColorOrderedPartials::usage =
  "ExtractTwoGluonColorOrderedPartials[amp4] extracts the color-ordered four-parton partial amplitudes used to build A40.";

ExtractBornColorStrippedPartial::usage =
  "ExtractBornColorStrippedPartial[bornAmp] extracts the color-stripped Born partial used to normalize the ordered A40 object.";

HasPolarizationVectorQ::usage =
  "HasPolarizationVectorQ[expr, mom] tests whether a polarization vector for the given momentum still appears in an expression.";

SafeDoPolarizationSums::usage =
  "SafeDoPolarizationSums[expr, mom, ref, ...] applies DoPolarizationSums only when the requested polarization vector is present.";

ColorStrippedInterference::usage =
  "ColorStrippedInterference[ampLeft, ampRight, numFinalParticles] computes the spin-summed color-stripped interference used by the ordered A40 route.";

ColorOrderedAntenna::usage =
  "ColorOrderedAntenna[amp4, bornAmp] builds the paper-style color-ordered A40 antenna from the full-color amplitude and Born normalization.";

ColorTensorFreeQ[expr_] :=
  FreeQ[expr, _SUNTF | _SUNF | _SUNFDelta];

ExpandUnsquaredColor[amp_] :=
  Module[{expanded, colorObjects},
    expanded =
      amp //
      SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
      Expand //
      Simplify;
    If[Names["FeynCalc`ColorCollect"] =!= {},
      ColorCollect[expanded]
      ,
      colorObjects = DeleteDuplicates[Cases[expanded, _SUNTF | _SUNFDelta,
         Infinity]];
      Collect[expanded, colorObjects, Simplify]
    ]
  ];

TwoGluonChainQ[SUNTF[inds_List, _, _]] :=
  Length[inds] === 2;

TwoGluonChainQ[_] :=
  False;

ChainData[chain : SUNTF[inds_List, left_, right_]] /; Length[inds] ===
   2 :=
  <|"Chain" -> chain, "Adjoint" -> inds, "Left" -> left, "Right" -> right
    |>;

ReversedChainPairQ[d1_, d2_] :=
  TrueQ[d1["Left"] === d2["Left"] && d1["Right"] === d2["Right"] && d1[
    "Adjoint"] === Reverse[d2["Adjoint"]]];

DiscoverTwoGluonChains[orderedAmp_] :=
  Module[{chains, data, pairs},
    chains = DeleteDuplicates[Cases[orderedAmp, c_SUNTF /; TwoGluonChainQ[
      c], Infinity]];
    data = ChainData /@ chains;
    If[Length[data] =!= 2,
      Print["Color-ordered antenna: expected exactly two two-gluon chains, found ",
         Length[data]];
      Return[$Failed]
    ];
    pairs = Select[Permutations[data, {2}], ReversedChainPairQ[#[[1]],
       #[[2]]]&];
    If[Length[pairs] =!= 2,
      Print["Color-ordered antenna: two-gluon chains do not form one reversed pair."
        ];
      Return[$Failed]
    ];
    data
  ];

PoleQ[expr_, inv_] :=
  Module[{rewritten},
    rewritten = ApplyFeynCalcRules[expr, 4];
    !FreeQ[rewritten, Power[inv, n_Integer /; n < 0]]
  ];

PoleSignature[expr_] :=
  AssociationThread[{s13, s14, s23, s24, s34, s134, s234}, PoleQ[expr,
     #]& /@ {s13, s14, s23, s24, s34, s134, s234}];

AdjacentPoleScore1342[expr_] :=
  Module[{sig},
    sig = PoleSignature[expr];
    Count[Lookup[sig, {s13, s24}], True] - Count[Lookup[sig, {s14, s23
      }], True]
  ];

ExtractTwoGluonColorOrderedPartials[amp4_] :=
  Module[{ordered, chainData, coeffs, sorted, reconstruction},
    ordered = ExpandUnsquaredColor[amp4];
    chainData = DiscoverTwoGluonChains[ordered];
    If[chainData === $Failed,
      Return[$Failed]
    ];
    coeffs =
      Table[
        With[{coeff = Simplify[Coefficient[ordered, chainData[[i]]["Chain"
          ]]]},
          <|"Chain" -> chainData[[i]]["Chain"], "Coefficient" -> coeff,
             "PoleSignature" -> PoleSignature[coeff], "Score1342" -> AdjacentPoleScore1342[
            coeff]|>
        ]
        ,
        {i, Length[chainData]}
      ];
    sorted = ReverseSortBy[coeffs, #["Score1342"]&];
    If[sorted[[1, "Score1342"]] <= sorted[[2, "Score1342"]],
      Print["Color-ordered antenna: could not identify the (1,3,4,2) chain."
        ];
      Print["Color-ordered antenna candidates: ", coeffs];
      Return[$Failed]
    ];
    reconstruction = Simplify[ordered - sorted[[1, "Chain"]] sorted[[
      1, "Coefficient"]] - sorted[[2, "Chain"]] sorted[[2, "Coefficient"]]]
      ;
    If[!TrueQ[reconstruction === 0],
      Print["Color-ordered antenna: unsquared color reconstruction failed."
        ];
      Return[$Failed]
    ];
    If[!ColorTensorFreeQ[sorted[[1, "Coefficient"]]],
      Print["Color-ordered antenna: selected partial still contains color tensors."
        ];
      Return[$Failed]
    ];
    <|"Target" -> sorted[[1]], "Reverse" -> sorted[[2]], "OrderedAmplitude"
       -> ordered, "ReconstructionResidual" -> reconstruction|>
  ];

ExtractBornColorStrippedPartial[bornAmp_] :=
  Module[{ordered, deltas, coeff},
    ordered = ExpandUnsquaredColor[bornAmp];
    deltas = DeleteDuplicates[Cases[ordered, _SUNFDelta, Infinity]];
    If[Length[deltas] =!= 1,
      Print["Color-ordered antenna: expected one Born color delta, found ",
         Length[deltas]];
      Return[$Failed]
    ];
    coeff = Simplify[Coefficient[ordered, First[deltas]]];
    If[!ColorTensorFreeQ[coeff],
      Print["Color-ordered antenna: Born partial still contains color tensors."
        ];
      Return[$Failed]
    ];
    <|"ColorDelta" -> First[deltas], "Coefficient" -> coeff|>
  ];

HasPolarizationVectorQ[expr_, mom_] :=
  !FreeQ[expr, Polarization[mom, ___]];

SafeDoPolarizationSums[expr_, mom_, ref_, opts___] :=
  If[HasPolarizationVectorQ[expr, mom],
    DoPolarizationSums[expr, mom, ref, opts]
    ,
    expr
  ];

ColorStrippedInterference[ampLeft_, ampRight_, numFinalParticles_] :=
  Module[{bare, pol, dirac, contracted, calc, rules, final},
    KinematicRules[numFinalParticles];
    bare = ComplexConjugate[ampLeft] ampRight;
    pol =
      bare //
      FermionSpinSum //
      SafeDoPolarizationSums[#, p, 0, VirtualBoson -> True]&;
    If[numFinalParticles == 4,
      pol =
        pol //
        SafeDoPolarizationSums[#, k3, k4]& //
        SafeDoPolarizationSums[#, k4, k3]&
    ];
    dirac = pol // DiracSimplify;
    contracted = TimeConstrained[Contract[dirac] // Simplify, 90, $Failed
      ];
    If[contracted === $Failed,
      Print["Color-ordered antenna: Contract timed out."];
      Return[$Failed]
    ];
    calc = TimeConstrained[Calc[contracted], 90, $Failed];
    If[calc === $Failed,
      Print["Color-ordered antenna: Calc timed out."];
      Return[$Failed]
    ];
    rules = ApplyFeynCalcRules[calc, numFinalParticles];
    final =
      (rules /. D -> 4 - 2 Epsilon) //
      Simplify //
      Expand;
    final
  ];

ColorOrderedAntenna[amp_, bornAmp_, numFinalParticles_, spec_Association
  ] :=
  Module[{numGluons, orderedData, bornData, partialSq, bornSq, antenna
    },
    numGluons = Lookup[spec, "NumGluons", numFinalParticles - 2];
    orderedData = ExtractTwoGluonColorOrderedPartials[amp];
    If[orderedData === $Failed,
      Return[$Failed]
    ];
    bornData = ExtractBornColorStrippedPartial[bornAmp];
    If[bornData === $Failed,
      Return[$Failed]
    ];
    partialSq = ColorStrippedInterference[orderedData["Target"]["Coefficient"
      ], orderedData["Target"]["Coefficient"], numFinalParticles];
    bornSq = ColorStrippedInterference[bornData["Coefficient"], bornData[
      "Coefficient"], 2];
    If[MemberQ[{partialSq, bornSq}, $Failed],
      Return[$Failed]
    ];
    antenna = Simplify[partialSq / (bornSq GluonColourBasisNorm[numGluons
      ] ^ 2)] // Expand;
    <|"Antenna" -> antenna, "SelectedChain" -> orderedData["Target"][
      "Chain"], "SelectedPoleSignature" -> orderedData["Target"]["PoleSignature"
      ], "BornColorDelta" -> bornData["ColorDelta"], "Normalization" -> GluonColourBasisNorm[
      numGluons] ^ 2, "Diagnostics" -> <|"UnsquaredReconstructionResidual" 
      -> orderedData["ReconstructionResidual"]|>|>
  ];
