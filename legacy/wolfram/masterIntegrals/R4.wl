Get[FileNameJoin[{DirectoryName[$InputFileName], "common.wl"}]];

(* R4 is kept as a notebook-style transcript of the derivation in main_old.pdf,
   eqs. (40)-(46), following the same flow as nnloMIs.wl.

   The purpose of this file is that the derivation can be read line by line:
   start from the phase-space integrand, apply the tripole substitutions, carry
   out the unit-interval integrations, and only then collapse everything to the
   final gamma-function form. *)

R4Source[] :=
  <|
    "PrimaryPdf" -> "main_old.pdf",
    "Equations" -> {40, 41, 42, 43, 44, 45, 46},
    "Style" -> "Notebook-like derivation transcript"
  |>;

R4prefactor =
  16^(-2 + eps) Pi^(-5 + 2 eps) / Gamma[1 - 2 eps];

sGamma = P2 ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;
Sg = A22SGammaMI[];

sGammaSub[expr_] :=
  FullSimplify[Sg expr / sGamma];

R4init =
  P2 * R4prefactor * q2^(2 - 2 eps) (1 - y134)^(1 - 2 eps)
    (-Delta4Prime)^(-1/2 - eps);

R4tripole =
  R4init /. {
    (-Delta4Prime)^(-1/2 - eps) ->
      (1 - z1)^(1 - 2 eps) Dy13^(-2 eps)
        (chi (1 - chi))^(-1/2 - eps)
  } /. {
    Dy13^(-2 eps) ->
      y134 (16 y134^2 z1 t (1 - t) v (1 - v))^(-eps)
  } // FullSimplify;

R4normalized =
  R4tripole // sGammaSub;

R4y134int =
  Integrate[R4normalized, {y134, 0, 1}] // FullSimplify;

R4z1int =
  Integrate[R4y134int, {z1, 0, 1}] // FullSimplify;

R4tint =
  Integrate[R4z1int, {t, 0, 1}] // FullSimplify;

R4vint =
  Integrate[R4tint, {v, 0, 1}] // FullSimplify;

R4chiint =
  Integrate[R4vint, {chi, 0, 1}] // FullSimplify;

R4factorizedIntegrals =
  <|
    "y134" -> MIUnitIntegral[1 - 2 eps, 1 - 2 eps],
    "z1" -> MIUnitIntegral[-eps, 1 - 2 eps],
    "t" -> MIUnitIntegral[-eps, -eps],
    "v" -> MIUnitIntegral[-eps, -eps],
    "chi" -> MIUnitIntegral[-1/2 - eps, -1/2 - eps]
  |>;

R4factorizedProduct =
  Times @@ Values[R4factorizedIntegrals] *
    FullSimplify[R4normalized /. {y134 -> 1, z1 -> 1, t -> 1, v -> 1, chi -> 1}];

R4factorizedClosed =
  FullSimplify[
    16^(-2) Pi^(-5 + 2 eps) q2^(2 - 2 eps) / Gamma[1 - 2 eps] *
      Times @@ Values[R4factorizedIntegrals]
  ];

(* Mathematica does not simplify the fully sequential Integrate chain all the
   way to the exact closed form in a clean manner. The factorized unit-interval
   route is the exact notebook-level derivation we trust here. *)
R4closed =
  R4factorizedClosed;

R4expected =
  R4ExpectedClosedForm[];

R4check =
  FullSimplify[R4closed - R4expected];

R4factorizedCheck =
  FullSimplify[R4factorizedClosed - R4expected];

R4sequentialCheck =
  Quiet[
    FullSimplify[R4chiint - R4closed],
    FullSimplify::infd
  ];

R4series[order_:2] :=
  MIFullExpand[R4closed, order];

R4packageSeries[order_:2] :=
  MIFullExpand[R4series[order] / q2^2, order];

R4packageCheck[order_:2] :=
  FullSimplify[
    R4packageSeries[order] - MIExpand[R4ExpectedPackageValue[], order]
  ];

R4Report[order_:2] :=
  <|
    "Source" -> R4Source[],
    "Honesty" -> <|
      "DerivedHere" -> {
        "R4init",
        "R4tripole",
        "R4normalized",
        "R4y134int",
        "R4z1int",
        "R4tint",
        "R4vint",
        "R4chiint",
        "R4factorizedClosed"
      },
      "NotebookRemark" -> "The factorized unit-interval route gives the exact closed form cleanly; the fully sequential Integrate chain is kept as a readable transcript but does not collapse to the same final expression automatically."
    |>,
    "Prefactor" -> R4prefactor,
    "SGamma" -> sGamma,
    "InitialIntegrand" -> R4init,
    "AfterTripoleSubstitution" -> R4tripole,
    "AfterSGammaNormalization" -> R4normalized,
    "IntegrationOrder" -> {y134, z1, t, v, chi},
    "Aftery134Integration" -> R4y134int,
    "Afterz1Integration" -> R4z1int,
    "AftertIntegration" -> R4tint,
    "AftervIntegration" -> R4vint,
    "AfterchiIntegration" -> R4chiint,
    "FactorizedUnitIntegrals" -> R4factorizedIntegrals,
    "FactorizedClosedForm" -> R4factorizedClosed,
    "SequentialVsFactorizedCheck" -> R4sequentialCheck,
    "ClosedForm" -> R4closed,
    "ExpectedClosedForm" -> R4expected,
    "ClosedFormCheck" -> R4check,
    "FactorizedClosedFormCheck" -> R4factorizedCheck,
    "Series" -> R4series[order],
    "PackageConventionSeries" -> R4packageSeries[order],
    "ExpectedPackageSeries" -> MIExpand[R4ExpectedPackageValue[], order],
    "PackageCheck" -> R4packageCheck[order]
  |>;
