(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(*
  Solve for the EXACT series that A22LOMI and A3MI must have,
  using Leading and Subleading as simultaneous linear constraints.

  Method: treat A22LO_correct and A3_correct as unknown eps-series.
  Compute the "effective IBP coefficient" for each master in each component
  (as eps-series), then solve the 2x2 linear system at each order.
*)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
order = 0;

dataLead = Get["/private/tmp/a22_two_loop_tree_Leading_masters.mx"];
dataSub  = Get["/private/tmp/a22_two_loop_tree_Subleading_masters.mx"];

(* Helper: expand to series *)
(* toSeries: Script-local helper for this development or benchmarking utility. *)
toSeries[expr_] :=
  Normal[Series[expr /. {d -> 4 - 2 eps, q2 -> 1}, {eps, 0, order}]] //
    FunctionExpand // FullSimplify;

(* Effective IBP coefficients after d->4-2eps substitution.
   These are the rational-in-eps factors multiplying each master symbol. *)
cLA22LO = toSeries[dataLead["CoefficientA22LO"]];
cLA3    = toSeries[dataLead["CoefficientA3"]];
cLA4    = toSeries[dataLead["CoefficientA4"]];
cLA6    = toSeries[Coefficient[dataLead["RawMapped"], A6MI]];
cSA22LO = toSeries[dataSub["CoefficientA22LO"]];
cSA3    = toSeries[dataSub["CoefficientA3"]];
cSA4    = toSeries[dataSub["CoefficientA4"]];
cSA6    = toSeries[Coefficient[dataSub["RawMapped"], A6MI]];

Print["IBP coefficients (after d->4-2eps):"];
Print["  Leading  A22LO coeff: ", cLA22LO];
Print["  Leading  A3    coeff: ", cLA3];
Print["  Leading  A4    coeff: ", cLA4];
Print["  Leading  A6    coeff: ", cLA6];
Print["  Subleading A22LO coeff: ", cSA22LO];
Print["  Subleading A3    coeff: ", cSA3];
Print["  Subleading A4    coeff: ", cSA4];
Print["  Subleading A6    coeff: ", cSA6];

(* Validated A4 and A6 master values *)
A4val = toSeries[A22TwoLoopTreeMasterValueA4[] /. {q2 -> 1}];
A6val = toSeries[A22TwoLoopTreeMasterValueA6[] /. {q2 -> 1}];
Print["  A4 master value: ", A4val];
Print["  A6 master value: ", A6val];

(* A4 and A6 contributions *)
leadA4 = toSeries[cLA4 * A4val];
leadA6 = toSeries[cLA6 * A6val];
subA4  = toSeries[cSA4 * A4val];
subA6  = toSeries[cSA6 * A6val];

(* Targets minus A4 and A6 contributions *)
targetLead = toSeries[1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440)];
targetSub = toSeries[-1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288)];

residL = toSeries[targetLead - (leadA4 + leadA6)];
residS = toSeries[targetSub - (subA4 + subA6)];

Print[""];
Print["Residual targets (what A22LO+A3 must produce):"];
Print["  Leading:    ", residL];
Print["  Subleading: ", residS];

(*
  Represent X = A22LO_correct and Y = A3_correct as:
    X = x4/eps^4 + x3/eps^3 + x2/eps^2 + x1/eps + x0
    Y = y4/eps^4 + y3/eps^3 + y2/eps^2 + y1/eps + y0

  The equations are:
    cLA22LO * X + cLA3 * Y = residL
    cSA22LO * X + cSA3 * Y = residS

  We collect at each power of eps to get 2 equations × 5 orders = 10 equations
  in 10 unknowns {x4,x3,x2,x1,x0,y4,y3,y2,y1,y0}.

  Since cLA22LO starts at 1/eps^2 (A22LO coeff has at most eps^{-2} from (d-4)^2),
  and X has up to 1/eps^4, their product has up to 1/eps^6. But we only need up to
  eps^0. So the system at each order n gives:
    sum_{k+m=n} cLA22LO[k] * X[m] + cLA3[k] * Y[m] = residL[n]
  where we work from most negative n upward.
*)

(* Extract coefficients of eps^n *)
(* getCoeff: Script-local helper for this development or benchmarking utility. *)
getCoeff[expr_, n_] := Coefficient[expr, eps, n];

(* IBP coefficient series (indexed by eps power) *)
Print[""];
Print["IBP coefficient expansions:"];
cLA22LO_coeffs = Table[{n, getCoeff[cLA22LO, n]}, {n, -4, 0}];
cLA3_coeffs    = Table[{n, getCoeff[cLA3, n]}, {n, -4, 0}];
cSA22LO_coeffs = Table[{n, getCoeff[cSA22LO, n]}, {n, -4, 0}];
cSA3_coeffs    = Table[{n, getCoeff[cSA3, n]}, {n, -4, 0}];
Print["  cLA22LO: ", cLA22LO_coeffs];
Print["  cLA3:    ", cLA3_coeffs];
Print["  cSA22LO: ", cSA22LO_coeffs];
Print["  cSA3:    ", cSA3_coeffs];

(* Set up the linear system *)
vars = {x4, x3, x2, x1, x0, y4, y3, y2, y1, y0};
unknowns = AssociationThread[{-4,-3,-2,-1,0} -> {x4,x3,x2,x1,x0}];
unknownsY = AssociationThread[{-4,-3,-2,-1,0} -> {y4,y3,y2,y1,y0}];

(* Build equations at each pole order n = -4..0 *)
equations = Flatten[Table[
  lhs = Sum[
    getCoeff[cLA22LO, k] * unknowns[n - k] + getCoeff[cLA3, k] * unknownsY[n - k]
    , {k, -4, 0}
  ] /. {unknowns[m_] :> 0 /; m < -4 || m > 0, unknownsY[m_] :> 0 /; m < -4 || m > 0};
  slhs = Sum[
    getCoeff[cSA22LO, k] * unknowns[n - k] + getCoeff[cSA3, k] * unknownsY[n - k]
    , {k, -4, 0}
  ] /. {unknowns[m_] :> 0 /; m < -4 || m > 0, unknownsY[m_] :> 0 /; m < -4 || m > 0};
  {lhs == getCoeff[residL, n],
   slhs == getCoeff[residS, n]}
  , {n, -4, 0}
]];

Print[""];
Print["Solving 10x10 system..."];
sol = Solve[equations, vars] // FullSimplify;

If[Length[sol] > 0,
  sol1 = First[sol];
  Print["Solution found:"];
  Print["  x4 (A22LO at 1/eps^4): ", x4 /. sol1 // FullSimplify];
  Print["  x3 (A22LO at 1/eps^3): ", x3 /. sol1 // FullSimplify];
  Print["  x2 (A22LO at 1/eps^2): ", x2 /. sol1 // FullSimplify];
  Print["  x1 (A22LO at 1/eps^1): ", x1 /. sol1 // FullSimplify];
  Print["  x0 (A22LO at eps^0):   ", x0 /. sol1 // FullSimplify];
  Print["  y4 (A3   at 1/eps^4): ", y4 /. sol1 // FullSimplify];
  Print["  y3 (A3   at 1/eps^3): ", y3 /. sol1 // FullSimplify];
  Print["  y2 (A3   at 1/eps^2): ", y2 /. sol1 // FullSimplify];
  Print["  y1 (A3   at 1/eps^1): ", y1 /. sol1 // FullSimplify];
  Print["  y0 (A3   at eps^0):   ", y0 /. sol1 // FullSimplify];

  (* Reconstruct series *)
  A22LO_correct = Sum[(unknowns[n] /. sol1) / eps^(-n), {n, -4, 0}] // FullSimplify;
  A3_correct    = Sum[(unknownsY[n] /. sol1) / eps^(-n), {n, -4, 0}] // FullSimplify;

  Print[""];
  Print["Correct A22LO series: ", A22LO_correct];
  Print["Correct A3    series: ", A3_correct];

  (* Ratio to current values *)
  A22LO_current = toSeries[A22TwoLoopTreeMasterValueA22LO[] /. {q2 -> 1}];
  A3_current    = toSeries[A22TwoLoopTreeMasterValueA3[] /. {q2 -> 1}];
  Print[""];
  Print["Current A22LO: ", A22LO_current];
  Print["Current A3:    ", A3_current];
  Print["Ratio A22LO correct/current: ", FullSimplify[A22LO_correct / A22LO_current]];

  (* Verify *)
  testLead = toSeries[cLA22LO * A22LO_correct + cLA3 * A3_correct + leadA4];
  testSub  = toSeries[cSA22LO * A22LO_correct + cSA3 * A3_correct + subA4];
  Print[""];
  Print["Verification:"];
  Print["  Leading  residual: ", FullSimplify[testLead - targetLead]];
  Print["  Subleading residual: ", FullSimplify[testSub - targetSub]];
  ,
  Print["No solution found — system may be inconsistent or underdetermined."]
];
