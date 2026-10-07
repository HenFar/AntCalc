(* ::Section:: *)
(* Tree-level antenna extraction *)

(* Communicates with:
   - src/engines/interference_tree.wl, whose normalized interferences are
     consumed here.
   - src/core/kinematics_and_utilities.wl through ApplyFeynCalcRules and
     ColourTensorCounter.
   - src/core/profiles.wl through the `Extraction`, `ColourNorm`, and
     `SectorDefinitions` metadata fields.
   - src/routes/build_workflows.wl, which calls these helpers to turn raw tree
     sources into public antenna components.

   Why this file exists:
   Interference construction and antenna extraction are different steps.  The
   former produces a physical squared matrix element; the latter divides by the
   Born/current normalization and projects onto the public component structure
   required by each antenna family. *)

BCColorFreeQ::usage =
  "BCColorFreeQ[expr] tests whether an expression is free of the B/C color structures handled by the tree extractor.";

AmplitudeTerms::usage =
  "AmplitudeTerms[amp] expands an amplitude into the list of terms classified by the tree extractor.";

TermContainsAnyQ::usage =
  "TermContainsAnyQ[expr, vars] tests whether any variable from vars appears in expr.";

SectorMatchQ::usage =
  "SectorMatchQ[kinTerm, invariantGroups] tests whether a kinematic term belongs to one of the profile-defined invariant sectors.";

ClassifyAmplitudeTerm::usage =
  "ClassifyAmplitudeTerm[term, profile] classifies one tree-level amplitude term into the antenna sectors defined by the profile.";

ColorTensorCountSafe::usage =
  "ColorTensorCountSafe[expr] counts color tensors with a failure-safe wrapper used during tree extraction.";

SplitAmplitudeBySectors::usage =
  "SplitAmplitudeBySectors[amp, profile] partitions a tree amplitude into the sectors needed by the antenna profiles.";

ExtractAntennaComponents::usage =
  "ExtractAntennaComponents[amp, profile] extracts the public tree-level antenna components from a classified amplitude.";

(* BCColorFreeQ[expr]
   ==================
   Test whether a candidate extracted component is free of the residual colour
   structures that should have disappeared by the time the public antenna is
   formed. *)
BCColorFreeQ[expr_] :=
  FreeQ[expr, SUNN | CA | CF | Nf | _SUNTF | _SUNF | _SUNFDelta];

(* AmplitudeTerms[amp]
   ===================
   Expand an amplitude into an explicit term list so the sector classifier can
   inspect contributions one by one. *)
AmplitudeTerms[amp_] :=
  Module[{expanded},
    expanded = Expand[amp];
    If[Head[expanded] === Plus,
      List @@ expanded
      ,
      {expanded}
    ]
  ];

(* TermContainsAnyQ[expr, vars]
   ============================
   Small helper used by the sector matcher to ask whether one invariant group is
   represented in a kinematic term. *)
TermContainsAnyQ[expr_, vars_List] :=
  Or @@ (!FreeQ[expr, #]& /@ vars);
(*************************************************)

(*
  Amplitude-sector decomposition.
  Used by four-quark antennae to select physical current/contraction sectors
  before interference.  The sectors are supplied by AntennaProfile, so this
  logic is not tied to B40 or C40 by name.
*)

(*************************************************)

(* SectorMatchQ[kinTerm, invariantGroups]
   ======================================
   Decide whether a term belongs to one of the profile-defined invariant
   sectors.  This is deliberately profile-driven so B40/C40-specific sector
   logic does not get hard-wired into a generic extractor. *)
SectorMatchQ[kinTerm_, invariantGroups_List] :=
  And @@ (TermContainsAnyQ[kinTerm, #]& /@ invariantGroups);

(* ClassifyAmplitudeTerm[term, profile]
   ====================================
   Assign one amplitude term to a named sector, or mark it ambiguous /
   unclassified when the profile-defined invariant signatures do not isolate it
   cleanly. *)
ClassifyAmplitudeTerm[term_, profile_Association] :=
  Module[{kinTerm, definitions, hits},
    definitions = Lookup[profile, "SectorDefinitions", <||>];
    kinTerm = ApplyFeynCalcRules[term, Lookup[profile, "NumFinalParticles",
       4]] // Expand;
    hits = Select[Keys[definitions], SectorMatchQ[kinTerm, definitions[
      #]]&];
    Which[
      Length[hits] === 1,
        First[hits]
      ,
      Length[hits] === 0,
        "Unclassified"
      ,
      True,
        "Ambiguous"
    ]
  ];

(* ColorTensorCountSafe[expr]
   ==========================
   Safe wrapper around ColourTensorCounter for use in diagnostics, especially
   when a sector happens to be identically zero. *)
ColorTensorCountSafe[expr_] :=
  If[TrueQ[expr === 0],
    0
    ,
    ColourTensorCounter[expr]
  ];

(* SplitAmplitudeBySectors[amp, profile]
   =====================================
   Partition a tree amplitude into the sectors needed by the four-quark antenna
   profiles and record diagnostics about the completeness of that partition. *)
SplitAmplitudeBySectors[amp_, profile_Association] :=
  Module[{terms, classes, sectorNames, labels, sectorTerms, sectorAmps,
     partitionResidual, simplifiedResidual, countDiagnostics, colourDiagnostics,
     diagnostics, output},
    terms = AmplitudeTerms[amp];
    classes = ClassifyAmplitudeTerm[#, profile]& /@ terms;
    sectorNames = Keys[Lookup[profile, "SectorDefinitions", <||>]];
    labels = Join[sectorNames, {"Ambiguous", "Unclassified"}];
    sectorTerms = Association[Table[label -> Pick[terms, classes, label
      ], {label, labels}]];
    sectorAmps =
      Association[
        Table[
          label ->
            (
              Total[sectorTerms[label]] //
              SUNSimplify //
              Simplify
            )
          ,
          {label, labels}
        ]
      ];
    partitionResidual = Expand[amp] - Total[Flatten[Values[sectorTerms
      ]]] // Simplify;
    simplifiedResidual = amp - Total[Values[sectorAmps]] // Simplify;
      
    countDiagnostics = Association[Table[label <> "Terms" -> Length[sectorTerms[
      label]], {label, labels}]];
    colourDiagnostics = Association[Table[label <> "ColourTensorCount"
       -> ColorTensorCountSafe[sectorAmps[label]], {label, labels}]];
    diagnostics = Join[<|"TotalTerms" -> Length[terms]|>, countDiagnostics,
       colourDiagnostics, <|"ReconstructionResidualIsZero" -> TrueQ[partitionResidual
       === 0], "SimplifiedSectorResidualIsZero" -> TrueQ[simplifiedResidual
       === 0]|>];
    output = <|"Parts" -> sectorAmps, "Diagnostics" -> diagnostics, "Classes"
       -> classes, "Terms" -> sectorTerms|>;
    output
  ];

(*************************************************)

(*
  Tree-level antenna extraction.
  Converts a normalized interference into the component structure requested
  by the profile: scalar Born object, colour coefficients, B-type colourNorm
  scalar, or C-type -2 colourNorm/SUNN scalar.
*)

(*************************************************)

(* ExtractAntennaComponents[interference, profile, context]
   =======================================================
   Convert a normalized tree interference into the public component structure
   requested by the profile.

   Notes
     The different extraction modes correspond to genuinely different physics
     objects:
     - A20 is normalized to the trivial Born scalar,
     - A30/A40 expose colour coefficients,
     - B40/C40 extract scalar antennae only after family-specific colour
       normalization conventions are applied. *)
ExtractAntennaComponents[interference_, profile_Association, context_Association
  ] :=
  Module[{mode, bornInterference, norm, colorNorm, lead, subLead, quarkLoop,
     components, scalar, residual, diagnostics, output},
    If[interference === $Failed,
      Return[<|"Components" -> <||>, "Diagnostics" -> <|"Failed" -> True,
         "Reason" -> "InterferenceFailed"|>|>]
    ];
    mode = profile["Extraction"];
    bornInterference = Lookup[context, "BornInterference", BornInterference[]];
    colorNorm = Lookup[profile, "ColourNorm", colourNorm];
    output =
      Switch[mode,
        "BornScalar",
          components = <|"Antenna" -> 1|>;
          diagnostics = <|"ScalarQ" -> True, "ColorFreeQ" -> True, "ResidualIsZero"
             -> True, "ResidualLeafCount" -> 1|>;
          <|"Components" -> components, "Diagnostics" -> diagnostics|>
            
        ,
        "TreeColourCoefficients",
          norm =
            interference / (bornInterference colorNorm) //
            Simplify //
            Expand;
          lead =
            Coefficient[norm, SUNN] //
            Simplify //
            Expand;
          subLead =
            Coefficient[norm, 1 / SUNN] //
            Simplify //
            Expand;
          quarkLoop =
            Coefficient[norm, Nf] //
            Simplify //
            Expand;
          components =
            If[{lead, subLead, quarkLoop} === {0, 0, 0},
              <|"Antenna" -> norm|>
              ,
              <|"Lead" -> lead, "SubLead" -> subLead, "QuarkLoop" -> 
                quarkLoop|>
            ];
          diagnostics = <|"ScalarQ" -> And @@ (!ListQ[#]& /@ Values[components
            ]), "ColorFreeQ" -> And @@ (BCColorFreeQ /@ Values[components]), "ResidualIsZero"
             -> True, "ResidualLeafCount" -> 1|>;
          <|"Components" -> components, "Diagnostics" -> diagnostics,
             "NormalizedInterference" -> norm|>
        ,
        "ColourNormScalar",
          norm =
            interference / bornInterference //
            Simplify //
            Expand;
          scalar =
            norm / colorNorm //
            Simplify //
            Expand;
          residual =
            norm - colorNorm scalar //
            Simplify //
            Expand;
          diagnostics = <|"ScalarQ" -> !ListQ[scalar], "ColorFreeQ" ->
             BCColorFreeQ[scalar], "ResidualIsZero" -> TrueQ[residual === 0], "ResidualLeafCount"
             -> LeafCount[residual]|>;
          <|"Components" -> <|"Antenna" -> scalar|>, "Diagnostics" ->
             diagnostics, "NormalizedInterference" -> norm|>
        ,
        "MinusTwoColourNormOverSUNN",
          norm =
            interference / bornInterference //
            Simplify //
            Expand;
          scalar =
            -SUNN norm / (2 colorNorm) //
            Simplify //
            Expand;
          residual =
            norm + 2 colorNorm scalar / SUNN //
            Simplify //
            Expand;
          diagnostics = <|"ScalarQ" -> !ListQ[scalar], "ColorFreeQ" ->
             BCColorFreeQ[scalar], "ResidualIsZero" -> TrueQ[residual === 0], "ResidualLeafCount"
             -> LeafCount[residual]|>;
          <|"Components" -> <|"Antenna" -> scalar|>, "Diagnostics" ->
             diagnostics, "NormalizedInterference" -> norm|>
        ,
        _,
          <|"Components" -> <||>, "Diagnostics" -> <|"Failed" -> True,
             "Reason" -> "UnknownExtractionMode"|>|>
      ];
    output
  ];
