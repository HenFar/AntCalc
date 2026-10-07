(*************************************************)

(*
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

    (* This is the PaVe-level object equivalent to the notebook antenna after
       the 18 Pi^2 normalization factor has been applied. *)
    A21PaXAsIsPaVeAntenna =
      BuildAntenna[A, 2, 1, ReductionBackend -> "PaVe",
        ApplyDimReg -> True];

    (* Package-X performs the actual B0/C0 evaluation. *)
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

    (* The Package-X epsilon expansion is converted to the paper convention.
       The factor must be kept through Epsilon^4 because the result begins at
       1/Epsilon^2 and we compare terms through Epsilon^2. *)
    A21PaXAsIsConventionFactor =
      1 - Pi^2 / 2 A21PaXAsIsEpsilon^2
        + (8 - Pi^2 / 8 - 7 Zeta[3] / 3) A21PaXAsIsEpsilon^3
        + (4 - 7 Pi^2 / 48 + 13 Pi^4 / 1440) A21PaXAsIsEpsilon^4;

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
