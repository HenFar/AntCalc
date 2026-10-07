(*
  Independent Laurent-series check of the NNLO massless R-ratio.

  The antennae below are transcribed from thesis/appendices/appendixA.tex at
  q^2 = 1.  No antenna construction or integration is performed here.

  The NNLO formula includes the observable-level convention map required by
  BuildRRatio:
    tilde A4^0 -> tilde A4^0/2,
    C4^0 -> 2 C4^0,
    breve A2^2 -> breve A2^2 - 7 Zeta[3]/(3 epsilon).

  Success means that every epsilon^-4 through epsilon^-1 coefficient vanishes
  and that the epsilon^0 term agrees with the standard finite NNLO result.
*)

ClearAll[eps, alphaS, nc, nf, cf, a21, a30, a22, at22, ah22, ab22, a31, at31,
  ah31, a40, at40, b40, c40, rNLO, rNNLO, rRatio, laurent, poleCoefficients,
  referenceFinite, finiteResidual, passedQ];

eps = \[Epsilon];
cf = (nc^2 - 1)/(2 nc);

(* NLO *)
a21 = -1/eps^2 - 3/(2 eps) - 4 + 7 Pi^2/12 +
  eps (-8 + 7 Pi^2/8 + 7 Zeta[3]/3) +
  eps^2 (-16 + 7 Pi^2/3 + 7 Zeta[3]/2 - 73 Pi^4/1440);

a30 = 1/eps^2 + 3/(2 eps) + 19/4 - 7 Pi^2/12 +
  eps (109/8 - 7 Pi^2/8 - 25 Zeta[3]/3) +
  eps^2 (639/16 - 133 Pi^2/48 - 25 Zeta[3]/2 - 71 Pi^4/1440);

(* NNLO two-parton components.  The first A2^2 pole is epsilon^-4. *)
a22 = 1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps - 9083/5184 -
  2153 Pi^2/864 + 263 Pi^4/1440 + 13 Zeta[3]/9;

at22 = -1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps - 1151/64 +
  475 Pi^2/96 - 59 Pi^4/288 + 29 Zeta[3]/4;

ah22 = -1/(4 eps^3) - 1/(9 eps^2) + (65/216 + Pi^2/24)/eps +
  4085/1296 - 91 Pi^2/216 + Zeta[3]/18;

ab22 = 1/(4 eps^4) + 3/(4 eps^3) + (41/16 - Pi^2/24)/eps^2 +
  (7 - Pi^2/8 + 7 Zeta[3]/6)/eps + 18 - 41 Pi^2/96 -
  7 Pi^4/480 - 7 Zeta[3]/2;

(* NNLO one-loop three-parton components. *)
a31 = -1/(4 eps^4) - 31/(12 eps^3) + (-53/8 + 11 Pi^2/24)/eps^2 +
  (-647/24 + 22 Pi^2/9 + 23 Zeta[3]/3)/eps - 5231/48 +
  17 Pi^2/2 - 41 Pi^4/480 + 689 Zeta[3]/18;

at31 = (-5/8 + Pi^2/6)/eps^2 +
  (-19/4 + Pi^2/4 + 7 Zeta[3])/eps - 105/4 + 27 Pi^2/16 +
  7 Pi^4/90 + 27 Zeta[3]/2;

ah31 = 1/(3 eps^3) + 1/(2 eps^2) + (19/12 - 7 Pi^2/36)/eps +
  109/24 - 7 Pi^2/24 - 25 Zeta[3]/9;

(* NNLO four-parton components. *)
a40 = 3/(4 eps^4) + 65/(24 eps^3) + (217/18 - 13 Pi^2/12)/eps^2 +
  (43223/864 - 589 Pi^2/144 - 71 Zeta[3]/4)/eps + 1076717/5184 -
  7955 Pi^2/432 + 373 Pi^4/1440 - 1327 Zeta[3]/18;

at40 = 1/eps^4 + 3/eps^3 + (13 - 3 Pi^2/2)/eps^2 +
  (845/16 - 9 Pi^2/2 - 80 Zeta[3]/3)/eps + 6921/32 -
  473 Pi^2/24 + 17 Pi^4/72 - 80 Zeta[3];

b40 = -1/(12 eps^3) - 7/(18 eps^2) + (-407/216 + 11 Pi^2/72)/eps -
  11753/1296 + 77 Pi^2/108 + 67 Zeta[3]/18;

c40 = (-13/32 + Pi^2/16 - Zeta[3]/4)/eps - 339/64 +
  17 Pi^2/48 - Pi^4/45 + 21 Zeta[3]/8;

rNLO = 2 cf (a21 + a30);
rNNLO = 2 cf (
    nc (a21 a30 + a31 + a40 + a22) -
    1/nc (a21 a30 + at31 + at40/2 + 2 c40 - at22) +
    nf (b40 + ah31 + ah22) +
    2 cf (ab22 - 7 Zeta[3]/(3 eps))
  );

rRatio = 1 + alphaS/(2 Pi) rNLO + (alphaS/(2 Pi))^2 rNNLO;
laurent = Normal @ Series[rRatio, {eps, 0, 0}] // FullSimplify;
poleCoefficients = Association @ Table[
    power -> FullSimplify[Coefficient[laurent, eps, power]],
    {power, -4, -1}
  ];

referenceFinite = 1 + alphaS/(2 Pi) (3 cf/2) +
  (alphaS/(2 Pi))^2 cf (
    nc (243/16 - 11 Zeta[3]) + 3/(16 nc) +
    nf (-11/4 + 2 Zeta[3])
  );
finiteResidual = FullSimplify[Coefficient[laurent, eps, 0] - referenceFinite];
passedQ = And @@ (TrueQ[# === 0] & /@ Values[poleCoefficients]) &&
  TrueQ[finiteResidual === 0];

Print["R-ratio pole coefficients (must all be zero):"];
Print[poleCoefficients];
Print["Finite-coefficient residual (must be zero):"];
Print[finiteResidual];
Print["Validation status: ", If[passedQ, "PASS", "FAIL"]];

If[!passedQ, Exit[1]];
