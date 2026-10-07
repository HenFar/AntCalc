(*************************************************)

(*
  One-loop antenna extraction.
  The interference has already been computed; this stage performs the common
  Born and colour normalisation, then returns either a scalar loop antenna or
  the leading/subleading/quark-loop colour components.
*)

(*************************************************)

OneLoopColorFreeQ::usage =
  "OneLoopColorFreeQ[expr] tests whether the loop interference has been stripped of the color structures expected by the extractor.";

ExtractLoopAntennaComponents::usage =
  "ExtractLoopAntennaComponents[interference, profile, context, ...] extracts the one-loop public antenna components from the normalized interference.";

ExtractTwoLoopAntennaComponents::usage =
  "ExtractTwoLoopAntennaComponents[interference, profile, context, ...] extracts the two-loop/tree source components used by the A22 route.";

ExtractA22OneLoopSelfComponent::usage =
  "ExtractA22OneLoopSelfComponent[interference, profile, context, ...] extracts the breve A22 one-loop self-interference source.";

ExtractA22TwoLoopTreeComponents::usage =
  "ExtractA22TwoLoopTreeComponents[interference, profile, context, ...] extracts the Leading, Subleading, and Nf A22 tree/two-loop sources.";

Options[ExtractLoopAntennaComponents] = {ApplyDimReg -> True};

OneLoopColorFreeQ[expr_] :=
  FreeQ[expr, SUNN | CA | CF | Nf | _SUNTF | _SUNF | _SUNFDelta];

ExtractLoopAntennaComponents[interference_, profile_, context_, opts : OptionsPattern[]] :=
  Module[{resolvedProfile, resolvedContext},
    resolvedProfile = Quiet[Check[Evaluate[profile], profile]];
    resolvedContext = Quiet[Check[Evaluate[context], context]];
    If[AssociationQ[resolvedProfile] && AssociationQ[resolvedContext],
      Return[
        ExtractLoopAntennaComponents[
          interference,
          resolvedProfile,
          resolvedContext,
          opts
        ]
      ]
    ];
    <|
      "Components" -> <|"Lead" -> $Failed, "SubLead" -> $Failed,
        "QuarkLoop" -> $Failed|>,
      "Diagnostics" -> <|"Failed" -> True,
        "Reason" -> "InvalidLoopExtractionInputs",
        "ProfileHead" -> Head[resolvedProfile],
        "ContextHead" -> Head[resolvedContext]|>,
      "NormalizedInterference" -> $Failed
    |>
  ];

ExtractLoopAntennaComponents[interference_, profile_Association, context_Association,
   OptionsPattern[]] :=
  Module[{applyDimRegOpt, bornInterference, colorNorm, extractionMode,
     antenna, colorCanonicalAntenna, leadAntenna, subLeadAntenna, quarkLoopAntenna,
     reconstructionResidual, components, diagnostics, output},
    applyDimRegOpt = OptionValue["ApplyDimReg"];
    bornInterference = Lookup[context, "BornInterference", profile["BornInterference"
      ]];
    colorNorm = Lookup[profile, "ColourNorm", SUNN - 1 / SUNN];
    extractionMode = profile["Extraction"];
    antenna =
      interference / (bornInterference colorNorm) //
      SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
      ReplaceAll[#, CasimirSubs]& //
      Simplify;
    antenna = LoopExpansionNormalization[1] antenna // Simplify;
    If[applyDimRegOpt === True,
      antenna = antenna /. D -> 4 - 2 Epsilon // Simplify
    ];
    output =
      Switch[extractionMode,
        "LoopScalar",
          components = <|"Antenna" -> antenna|>;
          diagnostics = <|"ScalarQ" -> !ListQ[antenna], "ColorFreeQ" 
            -> OneLoopColorFreeQ[antenna], "ResidualIsZero" -> True, "ResidualLeafCount"
             -> 1|>;
          <|"Components" -> components, "Diagnostics" -> diagnostics,
             "NormalizedInterference" -> antenna|>
        ,
        "LoopColorCoefficients",
          colorCanonicalAntenna =
            antenna //
            Together //
            Apart[#, SUNN]& //
            Expand;
          leadAntenna =
            Coefficient[colorCanonicalAntenna, SUNN] //
            Simplify //
            Expand;
          subLeadAntenna =
            Coefficient[colorCanonicalAntenna, 1 / SUNN] //
            Simplify //
            Expand;
          quarkLoopAntenna =
            Coefficient[colorCanonicalAntenna, Nf] //
            Simplify //
            Expand;
          reconstructionResidual =
            colorCanonicalAntenna - SUNN leadAntenna - subLeadAntenna
               / SUNN - Nf quarkLoopAntenna //
            Simplify //
            Expand;
          components = <|"Lead" -> leadAntenna, "SubLead" -> subLeadAntenna,
             "QuarkLoop" -> quarkLoopAntenna|>;
          diagnostics = <|"ReconstructionResidualIsZero" -> TrueQ[reconstructionResidual
             === 0], "FullLeafCount" -> LeafCount[colorCanonicalAntenna], "LeadLeafCount"
             -> LeafCount[leadAntenna], "SubLeadLeafCount" -> LeafCount[subLeadAntenna
            ], "QuarkLoopLeafCount" -> LeafCount[quarkLoopAntenna], "ResidualLeafCount"
             -> LeafCount[reconstructionResidual], "FullFreeOfSUNNQ" -> FreeQ[colorCanonicalAntenna,
             SUNN], "FullFreeOfNfQ" -> FreeQ[colorCanonicalAntenna, Nf], "FullFreeOfCAQ"
             -> FreeQ[colorCanonicalAntenna, CA], "FullFreeOfCFQ" -> FreeQ[colorCanonicalAntenna,
             CF], "LeadColorFreeQ" -> OneLoopColorFreeQ[leadAntenna], "SubLeadColorFreeQ"
             -> OneLoopColorFreeQ[subLeadAntenna], "QuarkLoopColorFreeQ" -> OneLoopColorFreeQ[
            quarkLoopAntenna]|>;
          <|"Components" -> components, "Diagnostics" -> diagnostics,
             "NormalizedInterference" -> colorCanonicalAntenna|>
        ,
        _,
          <|"Components" -> <||>, "Diagnostics" -> <|"Failed" -> True,
             "Reason" -> "UnknownLoopExtractionMode"|>|>
      ];
    output
  ];

(*************************************************)

(*
  Two-loop A22 component extraction.
  The two-loop/tree object has the same {N, 1/N, Nf} colour bracket pattern
  as other A-type virtual T terms.  The one-loop self-interference is a
  separate colour-normalised bracket, called Breve in this project.
*)

(*************************************************)

Options[ExtractTwoLoopAntennaComponents] = {ApplyDimReg -> True};

ExtractA22TwoLoopTreeComponents[twoLoopTreeInterference_, profile_Association,
   context_Association, OptionsPattern[ExtractTwoLoopAntennaComponents]] :=
  Module[{applyDimRegOpt, bornInterference, colorNorm, twoLoopBracket,
     colorCanonicalTwoLoop, lead, subLead, quarkLoop, reconstructionResidual,
     components, diagnostics},
    applyDimRegOpt = OptionValue["ApplyDimReg"];
    bornInterference = Lookup[context, "BornInterference",
      profile["BornInterference"]];
    colorNorm = Lookup[profile, "ColourNorm", SUNN - 1 / SUNN];
    twoLoopBracket =
      twoLoopTreeInterference / (bornInterference colorNorm) //
      SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
      ReplaceAll[#, CasimirSubs]& //
      Simplify;
    twoLoopBracket = LoopExpansionNormalization[2] twoLoopBracket //
      Simplify;
    If[applyDimRegOpt === True,
      twoLoopBracket = twoLoopBracket /. D -> 4 - 2 Epsilon // Simplify
    ];
    colorCanonicalTwoLoop =
      twoLoopBracket //
      Together //
      Apart[#, SUNN]& //
      Expand;
    lead = Coefficient[colorCanonicalTwoLoop, SUNN] // Simplify //
      Expand;
    subLead = Coefficient[colorCanonicalTwoLoop, 1 / SUNN] // Simplify //
      Expand;
    quarkLoop = Coefficient[colorCanonicalTwoLoop, Nf] // Simplify //
      Expand;
    reconstructionResidual =
      colorCanonicalTwoLoop - SUNN lead - subLead / SUNN - Nf quarkLoop //
      Simplify //
      Expand;
    components = <|"Lead" -> lead, "SubLead" -> subLead,
      "QuarkLoop" -> quarkLoop|>;
    diagnostics =
      <|"TwoLoopReconstructionResidualIsZero" ->
        TrueQ[reconstructionResidual === 0],
        "TwoLoopFullLeafCount" -> LeafCount[colorCanonicalTwoLoop],
        "LeadLeafCount" -> LeafCount[lead],
        "SubLeadLeafCount" -> LeafCount[subLead],
        "QuarkLoopLeafCount" -> LeafCount[quarkLoop],
        "ResidualLeafCount" -> LeafCount[reconstructionResidual],
        "LeadColorFreeQ" -> OneLoopColorFreeQ[lead],
        "SubLeadColorFreeQ" -> OneLoopColorFreeQ[subLead],
        "QuarkLoopColorFreeQ" -> OneLoopColorFreeQ[quarkLoop]|>;
    <|"Components" -> components, "Diagnostics" -> diagnostics,
      "TwoLoopNormalizedInterference" -> colorCanonicalTwoLoop|>
  ];

ExtractA22OneLoopSelfComponent[oneLoopSelfInterference_, profile_Association,
   context_Association, OptionsPattern[ExtractTwoLoopAntennaComponents]] :=
  Module[{applyDimRegOpt, bornInterference, colorNorm, selfBracket, breve,
     components, diagnostics},
    applyDimRegOpt = OptionValue["ApplyDimReg"];
    bornInterference = Lookup[context, "BornInterference",
      profile["BornInterference"]];
    colorNorm = Lookup[profile, "ColourNorm", SUNN - 1 / SUNN];
    selfBracket =
      oneLoopSelfInterference / (bornInterference colorNorm^2) //
      SUNSimplify[#, Explicit -> True, SUNNToCACF -> False]& //
      ReplaceAll[#, CasimirSubs]& //
      Simplify;
    selfBracket = LoopExpansionNormalization[2] selfBracket // Simplify;
    If[applyDimRegOpt === True,
      selfBracket = selfBracket /. D -> 4 - 2 Epsilon // Simplify
    ];
    breve = selfBracket // Simplify // Expand;
    components = <|"Breve" -> breve|>;
    diagnostics =
      <|"BreveLeafCount" -> LeafCount[breve],
        "BreveColorFreeQ" -> OneLoopColorFreeQ[breve]|>;
    <|"Components" -> components, "Diagnostics" -> diagnostics,
      "SelfNormalizedInterference" -> breve|>
  ];

ExtractTwoLoopAntennaComponents[twoLoopTreeInterference_, oneLoopSelfInterference_,
   profile_Association, context_Association, OptionsPattern[]] :=
  Module[{twoLoopExtraction, selfExtraction},
    twoLoopExtraction =
      ExtractA22TwoLoopTreeComponents[twoLoopTreeInterference, profile,
        context, ApplyDimReg -> OptionValue["ApplyDimReg"]];
    selfExtraction =
      ExtractA22OneLoopSelfComponent[oneLoopSelfInterference, profile,
        context, ApplyDimReg -> OptionValue["ApplyDimReg"]];
    <|"Components" -> Join[twoLoopExtraction["Components"],
        selfExtraction["Components"]],
      "Diagnostics" -> Join[twoLoopExtraction["Diagnostics"],
        selfExtraction["Diagnostics"]],
      "TwoLoopNormalizedInterference" ->
        twoLoopExtraction["TwoLoopNormalizedInterference"],
      "SelfNormalizedInterference" ->
        selfExtraction["SelfNormalizedInterference"]|>
  ];
