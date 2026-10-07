(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

eps = Epsilon;

cLA22LO = -1/8*(-2 + eps - 2*eps^2)^2/(eps^2*Pi^4);
cLA3    = (-6 + eps*(21 - 2*eps*(13 + 2*(-9 + eps)*eps)))/(4*eps^3*Pi^4);
cLA4    = (-648 + eps*(3672 + eps*(-900 + eps*(5502 + 1913*eps))))/(2592*eps^2*Pi^4);
cLA6    = 0;

cSA22LO = (-2 + eps - 2*eps^2)^2/(8*eps^2*Pi^4);
cSA3    = (36 + eps*(-114 + eps*(238 + eps*(-136 + 585*eps))))/(8*eps^3*Pi^4);
cSA4    = (40 + eps*(-56 + eps*(196 + eps*(178 + 1121*eps))))/(32*eps^2*Pi^4);
cSA6    = (2 + eps*(6 + eps*(28 + 113*eps*(1 + 4*eps))))/(8*Pi^4);

(* A22VirtualTwoPartonConventionFactor: Script-local helper for this development or benchmarking utility. *)
A22VirtualTwoPartonConventionFactor[] := 
  1 - Pi^2 eps^2 / 6 + (26 Zeta[3] / 3) eps^3 + (Pi^4 / 120 - 28 Zeta[3]) eps^4;

(* A22TwoLoopTreeVirtualConventionFactor: Script-local helper for this development or benchmarking utility. *)
A22TwoLoopTreeVirtualConventionFactor[] := 
  1 - 2 Pi^2 eps^2 - (28 Zeta[3] eps^3) / 3 + (2 (Pi^4 + 42 Zeta[3]) eps^4) / 3;

A4val = (-(Pi^4/2) A22VirtualTwoPartonConventionFactor[] * A22TwoLoopTreeVirtualConventionFactor[] *
    Gamma[1 - 2 eps] Gamma[1 + eps] Gamma[1 - eps]^4 Gamma[1 + 2 eps]) /
    (2 (1 - 2 eps) eps^2 Gamma[2 - 3 eps]);

A6val = -Pi^4 A22VirtualTwoPartonConventionFactor[] *
    A22TwoLoopTreeVirtualConventionFactor[] *
    (-1 / eps^4 + 5 Pi^2 / (6 eps^2) + 27 Zeta[3] / eps + 23 Pi^4 / 36);

A4valSeries = Series[A4val, {eps, 0, 2}] // Normal;
A6valSeries = Series[A6val, {eps, 0, 2}] // Normal;

targetLead = 1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440);

targetSub = -1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288);

residL = targetLead - (cLA4 * A4valSeries + cLA6 * A6valSeries);
residS = targetSub - (cSA4 * A4valSeries + cSA6 * A6valSeries);

(* We solve order by order *)
(* Let's expand everything *)
vars = {};
eqs = {};

Do[
  lhsL = Series[cLA22LO * Sum[a[k] eps^k, {k, -2, n}] + cLA3 * Sum[b[k] eps^k, {k, -1, n}] - residL, {eps, 0, n}];
  lhsS = Series[cSA22LO * Sum[a[k] eps^k, {k, -2, n}] + cSA3 * Sum[b[k] eps^k, {k, -1, n}] - residS, {eps, 0, n}];
  
  eqL = Coefficient[lhsL, eps, n - 2];
  eqS = Coefficient[lhsS, eps, n - 2];
  
  Print["\n=== Order eps^(", n - 2, ") ==="];
  Print["Leading Eq: ", eqL == 0 // Simplify // InputForm];
  Print["Subleading Eq: ", eqS == 0 // Simplify // InputForm];
  
  (* Try to solve with all equations so far *)
  AppendTo[eqs, eqL == 0];
  AppendTo[eqs, eqS == 0];
  AppendTo[vars, a[n]];
  AppendTo[vars, b[n]];
  
  sol = Solve[eqs, vars] // FullSimplify;
  Print["Solution at this order: ", sol // InputForm];
  , {n, -2, 0}
];

Quit[];
