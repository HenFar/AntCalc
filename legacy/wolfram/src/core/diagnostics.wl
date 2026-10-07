(* ::Section:: *)
(* Diagnostic and paper-comparison utilities *)

(* Communicates with:
   - src/interface/paper_targets.wl, which supplies the encoded comparison
     targets such as A20Paper, A40Paper, and A21Paper.
   - src/interface/build_router.wl through BuildAntenna[...] in
     RunAntennaDiagnostics[...].
   - src/interface/integration_router.wl through BuildAndIntegrateAntenna[...]
     in the loop-level regression checks.
   - src/routes/build_workflows.wl, whose outputs are
     validated by PaperDiagnosticsFor[...].

   Why this file exists:
   Diagnostic logic is intentionally kept outside the production routes because
   physics validation often needs convention bridges, label scans, and numeric
   probes that would make the build workflow harder to read if they were mixed
   directly into it. *)

KinematicChanges::usage =
  "KinematicChanges[expr, numFinalParticles] rewrites an expression into the package kinematic convention used by the diagnostics layer.";

TestEqualAntennaeQ::usage =
  "TestEqualAntennaeQ[paperAnt, compAnt, numFinalParticles] returns True when the computed and target antennae agree under the package comparison rules.";

TestEqualAntennae::usage =
  "TestEqualAntennae[paperAnt, compAnt, numFinalParticles] returns the simplified comparison residual between a paper target and a computed antenna.";

ExactNumericResidual::usage =
  "ExactNumericResidual[paperAnt, compAnt, numFinalParticles] evaluates a numeric residual used when symbolic comparison is inconclusive.";

SwapFourQuarkPairs::usage =
  "SwapFourQuarkPairs[expr] applies the pair-exchange relabeling used in four-parton diagnostics.";

PermuteSInvariants::usage =
  "PermuteSInvariants[expr, perm] permutes Mandelstam invariants according to a momentum-label permutation.";

FourPartonMomentumLabelPermutations::usage =
  "FourPartonMomentumLabelPermutations[] returns the momentum permutations scanned by the four-parton diagnostics.";

MomentumLabelScan::usage =
  "MomentumLabelScan[paperAnt, compAnt] scans the allowed momentum relabelings to help identify equivalent four-parton expressions.";

PrintAntennaDiagnostics::usage =
  "PrintAntennaDiagnostics[label, diagnostics, paperAnt, compAnt] prints a human-readable summary of a diagnostic comparison.";

PaperCheckAvailableQ::usage =
  "PaperCheckAvailableQ[key] returns True when an encoded paper target exists for the requested antenna key.";

PaperDiagnosticsFor::usage =
  "PaperDiagnosticsFor[key, result] constructs the encoded paper-comparison diagnostics for a built or integrated antenna result.";

RunAntennaDiagnostics::usage =
  "RunAntennaDiagnostics[...] runs the package's built-in regression and paper-check suite.";

(* KinematicChanges[expr, numFinalParticles]
   =========================================
   Rewrite both target and computed expressions into one canonical kinematic
   convention before comparing them.  The point is not algebraic prettiness;
   it is to avoid mistaking different choices of dependent invariants for a real
   physics mismatch. *)
KinematicChanges[expr_, numFinalParticles_] :=
  Module[{changedExpr},
    Which[
      numFinalParticles == 2,
        changedExpr = expr
      ,
      numFinalParticles == 3,
        changedExpr = expr /. {s123 -> s12 + s13 + s23, D -> 4 - 2 Epsilon
          } /. s12 -> q2 - s13 - s23
      ,
      numFinalParticles == 4,
        changedExpr = expr /. {s123 -> s12 + s13 + s23, s124 -> s12 +
           s14 + s24, s134 -> s13 + s14 + s34, s234 -> s23 + s24 + s34, D -> 4 
          - 2 Epsilon} /. s12 -> q2 - s13 - s14 - s23 - s24 - s34;
    ];
    changedExpr
  ];

(* TestEqualAntennaeQ[paperAnt, compAnt, numFinalParticles]
   ========================================================
   Return a strict boolean comparison after both expressions have been pushed
   into the same kinematic convention and expanded. *)
TestEqualAntennaeQ[paperAnt_, compAnt_, numFinalParticles_] :=
  Module[{paperAntKin, compAntKin, output},
    paperAntKin =
      paperAnt //
      KinematicChanges[#, numFinalParticles]& //
      Simplify //
      Expand;
    compAntKin =
      compAnt //
      KinematicChanges[#, numFinalParticles]& //
      Simplify //
      Expand;
    output = Equal[paperAntKin, compAntKin];
    TrueQ[output]
  ];

(* TestEqualAntennae[paperAnt, compAnt, numFinalParticles]
   =======================================================
   Notebook-oriented printing wrapper around TestEqualAntennaeQ[...].  This is
   retained for interactive usability even though the boolean-returning helper
   is what the automated diagnostics primarily use. *)
TestEqualAntennae[paperAnt_, compAnt_, numFinalParticles_] :=
  Module[{output},
    output = TestEqualAntennaeQ[paperAnt, compAnt, numFinalParticles]
      ;
    If[!TrueQ[output],
      Print[False]
      ,
      Print[True]
    ]
  ];

(* ExactNumericResidual[paperAnt, compAnt, numFinalParticles]
   ==========================================================
   Evaluate the residual at one fixed non-singular phase-space point.  This is
   a pragmatic fallback for cases where symbolic equality is expensive or
   inconclusive. *)
ExactNumericResidual[paperAnt_, compAnt_, numFinalParticles_] :=
  Module[{pointRules, residual},
    pointRules = {q2 -> 23, s13 -> 2, s14 -> 3, s23 -> 5, s24 -> 7, s34
       -> 1, Epsilon -> 1/10};
    residual = KinematicChanges[paperAnt, numFinalParticles] - KinematicChanges[
      compAnt, numFinalParticles] /. pointRules;
    TimeConstrained[Simplify[residual], 60, $Failed]
  ];

(* SwapFourQuarkPairs[expr]
   ========================
   Apply the quark-pair exchange used in four-parton diagnostics.  This is
   physically motivated by the symmetry structure of the B40/C40 families. *)
SwapFourQuarkPairs[expr_] :=
  Module[{u12, u13, u14, u23, u24, u34},
    expr /. {s12 -> u12, s13 -> u13, s14 -> u14, s23 -> u23, s24 -> u24,
       s34 -> u34} /. {u12 -> s34, u13 -> s13, u14 -> s23, u23 -> s14, u24 
      -> s24, u34 -> s12}
  ];

(* PermuteSInvariants[expr, perm]
   ==============================
   Relabel Mandelstam invariants according to a momentum permutation so
   convention-level mismatches can be separated from true formula mismatches. *)
PermuteSInvariants[expr_, perm_List] :=
  Module[{u12, u13, u14, u23, u24, u34, sij},
    sij[i_, j_] := Symbol["s" <> ToString[Min[perm[[i]], perm[[j]]]] 
      <> ToString[Max[perm[[i]], perm[[j]]]]];
    expr /. {s12 -> u12, s13 -> u13, s14 -> u14, s23 -> u23, s24 -> u24,
       s34 -> u34} /. {u12 -> sij[1, 2], u13 -> sij[1, 3], u14 -> sij[1, 4],
       u23 -> sij[2, 3], u24 -> sij[2, 4], u34 -> sij[3, 4]}
  ];

(* FourPartonMomentumLabelPermutations[]
   =====================================
   Enumerate the restricted set of physically relevant four-parton relabelings
   scanned by MomentumLabelScan[...]. *)
FourPartonMomentumLabelPermutations[] :=
  {{"identity", {1, 2, 3, 4}}, {"k1<->k2", {2, 1, 3, 4}}, {"k3<->k4",
     {1, 2, 4, 3}}, {"both pair flips", {2, 1, 4, 3}}, {"pair swap", {3, 
    4, 1, 2}}, {"pair swap + first pair flip", {4, 3, 1, 2}}, {"pair swap + second pair flip",
     {3, 4, 2, 1}}, {"pair swap + both flips", {4, 3, 2, 1}}};

(* MomentumLabelScan[paperAnt, compAnt]
   ====================================
   Scan allowed four-parton relabelings and report which one, if any, restores
   agreement.  This is intentionally verbose because its job is to diagnose why
   a comparison failed, not just whether it failed. *)
MomentumLabelScan[paperAnt_, compAnt_] :=
  Module[{pointRules, paperKin, compKin, scans, name, perm, permutedPaper,
     numericResidual, exactResidual},
    pointRules = {q2 -> 23, s13 -> 2, s14 -> 3, s23 -> 5, s24 -> 7, s34
       -> 1, Epsilon -> 1/10};
    paperKin = KinematicChanges[paperAnt, 4];
    compKin = KinematicChanges[compAnt, 4];
    scans =
      Table[
        name = FourPartonMomentumLabelPermutations[][[i, 1]];
        perm = FourPartonMomentumLabelPermutations[][[i, 2]];
        permutedPaper = KinematicChanges[PermuteSInvariants[paperAnt,
           perm], 4];
        numericResidual = permutedPaper - compKin /. pointRules // TimeConstrained[
          Simplify[#], 60, $Failed]&;
        exactResidual =
          If[TrueQ[numericResidual === 0],
            permutedPaper - compKin //
            TimeConstrained[Simplify[#], 300, $Failed]& //
            Expand
            ,
            "Skipped"
          ];
        <|"Name" -> name, "Permutation" -> perm, "NumericResidual" ->
           numericResidual, "ExactResidual" -> exactResidual, "ExactMatchQ" -> 
          TrueQ[exactResidual === 0]|>
        ,
        {i, Length[FourPartonMomentumLabelPermutations[]]}
      ];
    Print["Momentum-label scan: ", scans];
    scans
  ];

(* PrintAntennaDiagnostics[label, diagnostics, paperAnt, compAnt]
   ===============================================================
   Print an expanded four-parton diagnostic summary, including swapped-pair and
   numeric checks that are often more informative than a single exact-match
   boolean when debugging B40/C40 sector logic. *)
PrintAntennaDiagnostics[label_, diagnostics_, paperAnt_, compAnt_] :=
  Module[{pointRules, paperValue, compValue, numericResidual, swappedValue,
     paperPlusSwappedResidual},
    pointRules = {q2 -> 23, s13 -> 2, s14 -> 3, s23 -> 5, s24 -> 7, s34
       -> 1, Epsilon -> 1/10};
    paperValue = KinematicChanges[paperAnt, 4] /. pointRules // TimeConstrained[
      Simplify[#], 60, $Failed]&;
    compValue = KinematicChanges[compAnt, 4] /. pointRules // TimeConstrained[
      Simplify[#], 60, $Failed]&;
    swappedValue = KinematicChanges[SwapFourQuarkPairs[paperAnt], 4] 
      /. pointRules // TimeConstrained[Simplify[#], 60, $Failed]&;
    paperPlusSwappedResidual =
      If[MemberQ[{paperValue, swappedValue, compValue}, $Failed],
        $Failed
        ,
        Simplify[paperValue + swappedValue - compValue]
      ];
    numericResidual = ExactNumericResidual[paperAnt, compAnt, 4];
    Print[
      label
      ,
      " diagnostics: "
      ,
      Join[
        diagnostics
        ,
        <|
          "PaperNumericValue" -> paperValue
          ,
          "ComputedNumericValue" -> compValue
          ,
          "ComputedOverPaper" ->
            If[paperValue === 0 || paperValue === $Failed || compValue
               === $Failed,
              $Failed
              ,
              Simplify[compValue / paperValue]
            ]
          ,
          "SwappedPaperNumericValue" -> swappedValue
          ,
          "PaperPlusSwappedMinusComputed" -> paperPlusSwappedResidual
            
          ,
          "PaperNumericResidual" -> numericResidual
        |>
      ]
    ]
  ];

(* PaperCheckAvailableQ[key]
   =========================
   Report whether the package has an encoded literature target for the requested
   antenna family. *)
PaperCheckAvailableQ[key_] :=
  Switch[key,
    {A, 2, 0},
      ValueQ[A20Paper]
    ,
    {A, 3, 0},
      ValueQ[A30Paper]
    ,
    {A, 4, 0},
      ValueQ[A40Paper] && ValueQ[tA40Paper]
    ,
    {B, 4, 0},
      ValueQ[B40Paper]
    ,
    {C, 4, 0},
      ValueQ[C40Paper]
    ,
    {A, 2, 1},
      ValueQ[A21Paper]
    ,
    _,
      False
  ];

(* PaperDiagnosticsFor[key, result]
   ================================
   Build the family-specific paper-comparison diagnostics.  The definitions are
   specialized because different antennae require different comparison logic:
   A40 has multiple colour components, A21 may still be in PaVe form, and some
   routes only admit numeric residual checks rather than one exact identity. *)
PaperDiagnosticsFor[{A, 2, 0}, result_] :=
  <|"PaperCheckAvailable" -> True, "ExactMatchQ" -> TestEqualAntennaeQ[
    A20Paper, result, 2]|>;

PaperDiagnosticsFor[{A, 3, 0}, result_] :=
  <|"PaperCheckAvailable" -> True, "ExactMatchQ" -> TestEqualAntennaeQ[
    A30Paper, result, 3]|>;

PaperDiagnosticsFor[{A, 4, 0}, result_List] :=
  <|"PaperCheckAvailable" -> True, "A40ExactMatchQ" -> TestEqualAntennaeQ[
    A40Paper, result[[1]], 4], "tA40ExactMatchQ" -> TestEqualAntennaeQ[tA40Paper,
     result[[2]], 4], "A40NumericResidual" -> ExactNumericResidual[A40Paper,
     result[[1]], 4], "tA40NumericResidual" -> ExactNumericResidual[tA40Paper,
     result[[2]], 4]|>;

PaperDiagnosticsFor[{B, 4, 0}, result_] :=
  <|"PaperCheckAvailable" -> True, "ExactMatchQ" -> TestEqualAntennaeQ[
    B40Paper, result, 4], "NumericResidual" -> ExactNumericResidual[B40Paper,
     result, 4]|>;

PaperDiagnosticsFor[{C, 4, 0}, result_] :=
  <|"PaperCheckAvailable" -> True, "ExactMatchQ" -> TestEqualAntennaeQ[
    C40Paper, result, 4], "NumericResidual" -> ExactNumericResidual[C40Paper,
     result, 4]|>;

PaperDiagnosticsFor[{A, 2, 1}, result_] :=
  Module[{target, mode},
    If[!FreeQ[result, B0 | C0],
      target = A21PaperPaVe /. D -> 4 - 2 Epsilon;
      mode = "PaVe"
      ,
      target = A21Paper;
      mode = "Raw"
    ];
    <|"PaperCheckAvailable" -> True, "ComparisonMode" -> mode,
      "ExactMatchQ" -> TrueQ[Simplify[result - target] === 0]|>
  ];

PaperDiagnosticsFor[{A, 3, 1}, _] :=
  <|"PaperCheckAvailable" -> False, "Reason" -> "NoFullUnintegratedPaperExpression"
    |>;

PaperDiagnosticsFor[_, _] :=
  <|"PaperCheckAvailable" -> False|>;

(*************************************************)

(*
  Public diagnostic runner.
  This is the replacement for the old training flag.  It explicitly calls the
  BuildAntenna diagnostic option and prints the compact checks used during
  development.
*)

(*************************************************)

Options[RunAntennaDiagnostics] = {LoopOrder -> 0, C40Diagnostic -> False
  };

(* RunAntennaDiagnostics[OptionsPattern[]]
   =======================================
   Exercise the public routes and print the compact regression checks used
   during development.  It goes through the interface layer on purpose so the
   diagnostics cover routing, normalization, and return-shape decisions rather
   than only private algebra kernels. *)
RunAntennaDiagnostics[OptionsPattern[]] :=
  Module[{loopOrder, c40Diagnostic, a20, a20Diag, a30, a30Diag, a40, 
    a40Diag, b40, b40Diag, c40, c40Diag, a21, a21Diag, a21Integrated,
    a21IntegratedDiag, a31, a31Diag, c40Data},
    loopOrder = OptionValue[LoopOrder];
    c40Diagnostic = OptionValue[C40Diagnostic];
    If[loopOrder === 1,
      {a21, a21Diag} = BuildAntenna[A, 2, 1, ReturnDiagnostics -> True,
         ReductionBackend -> None];
      Print["A21"];
      Print[a21Diag["PaperDiagnostics"]["ExactMatchQ"]];
      {a21Integrated, a21IntegratedDiag} = BuildAndIntegrateAntenna[A, 2, 1,
         ReturnDiagnostics -> True];
      Print["A21 integrated"];
      Print[a21IntegratedDiag["IntegratedResidualIsZero"]];
      {a31, a31Diag} = BuildAntenna[A, 3, 1, ReturnDiagnostics -> True,
         ReductionBackend -> None];
      Print["A31 reconstruction"];
      Print[a31Diag["ReconstructionResidualIsZero"]];
      Print["hatA31 raw"];
      Print[TrueQ[Simplify[a31[[3]]] === 0]];
      Print["A31 color-free"];
      Print[And[a31Diag["LeadColorFreeQ"], a31Diag["SubLeadColorFreeQ"
        ], a31Diag["QuarkLoopColorFreeQ"]]];
      ,
      {a20, a20Diag} = BuildAntenna[A, 2, 0, ReturnDiagnostics -> True
        ];
      Print["A20"];
      Print[a20Diag["PaperDiagnostics"]["ExactMatchQ"]];
      {a30, a30Diag} = BuildAntenna[A, 3, 0, ReturnDiagnostics -> True
        ];
      Print["A30"];
      Print[a30Diag["PaperDiagnostics"]["ExactMatchQ"]];
      {a40, a40Diag} = BuildAntenna[A, 4, 0, ReturnDiagnostics -> True
        ];
      Print["A40"];
      Print[a40Diag["PaperDiagnostics"]["A40ExactMatchQ"]];
      Print["tA40"];
      Print[a40Diag["PaperDiagnostics"]["tA40ExactMatchQ"]];
      {b40, b40Diag} = BuildAntenna[B, 4, 0, ReturnDiagnostics -> True
        ];
      Print["B40"];
      Print[b40Diag["PaperDiagnostics"]["ExactMatchQ"]];
      {c40, c40Diag} = BuildAntenna[C, 4, 0, ReturnDiagnostics -> True
        ];
      If[c40Diagnostic,
        c40Data = BuildAntenna[C, 4, 0, ReturnRecord -> True]["BuildData"];
        PrintAntennaDiagnostics["C40 direct-primary square as B-like",
           c40Data["ReferenceSquareDiagnostics"], B40Paper,
           c40Data["ReferenceSquareComponents"]["Antenna"]];
        Print["C40 candidate diagnostics: ", c40Data["Diagnostics"]]
          
      ];
      Print["C40"];
      Print[c40Diag["PaperDiagnostics"]["ExactMatchQ"]]
    ]
  ];
