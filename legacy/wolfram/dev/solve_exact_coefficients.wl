(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

eps = Epsilon;

(* Dynamically computed IBP coefficients *)
cLA22LO = -1/8*(-2 + eps - 2*eps^2)^2/(eps^2*Pi^4);
cLA3    = (-6 + eps*(21 - 2*eps*(13 + 2*(-9 + eps)*eps)))/(4*eps^3*Pi^4);
cLA4    = (-648 + eps*(3672 + eps*(-900 + eps*(5502 + 1913*eps))))/(2592*eps^2*Pi^4);
cLA6    = 0;

cSA22LO = (-2 + eps - 2*eps^2)^2/(8*eps^2*Pi^4);
cSA3    = (36 + eps*(-114 + eps*(238 + eps*(-136 + 585*eps))))/(8*eps^3*Pi^4);
cSA4    = (40 + eps*(-56 + eps*(196 + eps*(178 + 1121*eps))))/(32*eps^2*Pi^4);
cSA6    = (2 + eps*(6 + eps*(28 + 113*eps*(1 + 4*eps))))/(8*Pi^4);

(* Validated master values *)
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

(* Expand A4 and A6 to high enough order *)
A4valSeries = Series[A4val, {eps, 0, 2}] // Normal;
A6valSeries = Series[A6val, {eps, 0, 2}] // Normal;

(* Target values from hep-ph/0403057 *)
targetLead = 1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440);

targetSub = -1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288);

(* Subtract A4 and A6 contributions *)
residL = targetLead - (cLA4 * A4valSeries + cLA6 * A6valSeries);
residS = targetSub - (cSA4 * A4valSeries + cSA6 * A6valSeries);

(* Solve for A22LO and A3 as series *)
(* A22LO and A3 can be represented as series starting at eps^-2 and eps^-1 respectively (since A3 has 1/eps pole and A22LO has 1/eps^2 pole) *)
A22LO_sol = Sum[a[i] eps^i, {i, -2, 2}];
A3_sol = Sum[b[i] eps^i, {i, -1, 2}];

eqL = Series[cLA22LO * A22LO_sol + cLA3 * A3_sol - residL, {eps, 0, 1}];
eqS = Series[cSA22LO * A22LO_sol + cSA3 * A3_sol - residS, {eps, 0, 1}];

eqs = Flatten[Table[
  {Coefficient[eqL, eps, i] == 0,
   Coefficient[eqS, eps, i] == 0}
  , {i, -4, 0}
]];

vars = Flatten[Table[{a[i], b[i]}, {i, -2, 2}]];
sol = Solve[eqs, vars] // FullSimplify;

If[Length[sol] > 0,
  Print["Solution found!"];
  Print["A22LO solved series: ", Series[A22LO_sol /. sol[[1]], {eps, 0, 2}] // Normal // InputForm];
  Print["A3 solved series: ", Series[A3_sol /. sol[[1]], {eps, 0, 2}] // Normal // InputForm];
  
  (* Compare to the current package values *)
  A22LO_package = (-3*Pi^4)/(8*eps^2) - Pi^4/eps + (Pi^4*(-53 + 14*Pi^2))/32 - (1/288*(Pi^4*(-2239 + 6*Pi^2 + 3264*Zeta[3]))) * eps + ((Pi^4*(1338445 - 141690*Pi^2 + 3468*Pi^4 - 888480*Zeta[3]))/17280) * eps^2;
  A3_package = -Pi^4/72 + ((Pi^4*(-11 + 24*Pi^2))/216) * eps + ((Pi^4*(-14047 + 3666*Pi^2 + 8784*Zeta[3]))/2592) * eps^2 + ((Pi^4*(-480097 + 114348*Pi^2 - 2934*Pi^4 + 332928*Zeta[3]))/15552) * eps^3;
  
  Print["\nPackage A22LO: ", A22LO_package // InputForm];
  Print["Package A3: ", A3_package // InputForm];
  
  Print["\nDifference A22LO solved - package: ", Series[(A22LO_sol /. sol[[1]]) - A22LO_package, {eps, 0, 1}] // Normal // Simplify // InputForm];
  Print["Difference A3 solved - package: ", Series[(A3_sol /. sol[[1]]) - A3_package, {eps, 0, 1}] // Normal // Simplify // InputForm];
  ,
  Print["No solution found!"]
];

Quit[];
