(*************************************************)

(*
  File role and communication map
  -------------------------------
  This file is intentionally peripheral to the production pipeline.

  It communicates with:
    - AntennaPipeline.wl, which loads it last so the patch can see the public
      build and integration functions without influencing their definitions.
    - src/interface/build_router.wl through BuildAntenna[...].
    - src/interface/integration_router.wl through BuildAndIntegrateAntenna[...].
    - src/interface/paper_targets.wl through A21IntegratedPaper.

  Why this file is separate:
  The A21 Package-X convention check is useful for physics validation, but it
  is deliberately kept out of the public route logic.  Mixing this notebook-like
  validation path into production routing would obscure the difference between
  the real supported backend workflow and an as-written reproduction of a
  historical cross-check.

  A21 PaXEvaluate convention patch, written out as a notebook-style block.

  This is deliberately not part of the production router.  It is a transparent
  linear implementation of the PaVe route for A21, starting from the already
  normalized PaVe antenna and using Package-X as the only integral evaluator.

  To run it from a Wolfram session:

    RunA21PaXAsIsPatch = True;
    Get[".../automate_draft.wl"];
    A21PaXAsIsCheck

  No Print statements are used here.  The final quantities to inspect are
  A21PaXAsIsIntegrated, A21PaXAsIsResidual, and A21PaXAsIsCheck.
*)

(*************************************************)

If[!ValueQ[RunA21PaXAsIsPatch],
  RunA21PaXAsIsPatch = False
];

If[RunA21PaXAsIsPatch === True,
  Quiet[
    A21PaXAsIsEpsilon = Epsilon;
    A21PaXAsIsScaleMu = FeynCalc`ScaleMu;

    (* Start from the public build route rather than from hand-entered PaVe
       objects.  That makes the cross-check sensitive to the same normalization
       and reduction choices that the user-facing pipeline applies. *)
    A21PaXAsIsPaVeAntenna =
      BuildAntenna[A, 2, 1, ReductionBackend -> "PaVe",
        ApplyDimReg -> True];

    (* Package-X is used here only as the scalar-integral evaluator.  Keeping
       the algebraic path linear helps isolate whether a mismatch comes from
       the PaVe-to-Package-X convention bridge rather than from route logic. *)
    A21PaXAsIsPackageXResult =
      FeynCalc`PaXEvaluate[A21PaXAsIsPaVeAntenna];

    (* Package-X returns its own scale and logarithm convention.  This is the
       paper's real massless two-parton convention, written as branch/scale
       choices, not as B0/C0 replacement rules. *)
    A21PaXAsIsPaperConventionResult =
      A21PaXAsIsPackageXResult /.
        {
          Log[-(A21PaXAsIsScaleMu^2 / q2)] -> EulerGamma + Log[Pi]
          ,
          Log[-(A21PaXAsIsScaleMu^2 / (Pi q2))] -> EulerGamma
        } /. q2 -> 1;

    (* The conversion factor is expanded deeper than the final answer because
       infrared poles multiply higher epsilon terms.  Physically this is the
       standard bookkeeping issue that finite and subleading pieces can descend
       from higher-order convention factors once the Laurent series is
       multiplied out. *)
    A21PaXAsIsConventionFactor =
      1 - Pi^2 / 2 A21PaXAsIsEpsilon^2
        + (8 - Pi^2 / 8 - 7 Zeta[3] / 3) A21PaXAsIsEpsilon^3
        + (4 - 7 Pi^2 / 48 + 13 Pi^4 / 1440) A21PaXAsIsEpsilon^4;

    (* Store the full residual explicitly instead of reducing directly to a
       boolean so that a future investigation can see whether a mismatch is a
       pure convention offset, a missing transcendental term, or a wrong pole
       structure. *)
    A21PaXAsIsIntegrated =
      Normal[
        Series[
          A21PaXAsIsConventionFactor A21PaXAsIsPaperConventionResult
          ,
          {A21PaXAsIsEpsilon, 0, 2}
        ]
      ] //
      FunctionExpand //
      FullSimplify;

    A21PaXAsIsResidual =
      A21PaXAsIsIntegrated - A21IntegratedPaper //
      FunctionExpand //
      FullSimplify;

    A21PaXAsIsCheck =
      TrueQ[A21PaXAsIsResidual === 0];
  ]
];
