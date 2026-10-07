(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(*
  Solve for A22LO_correct and A3_correct with correct starting orders.
  cLA22LO ~ 1/eps^2, A22LO ~ 1/eps^2 → product starts at 1/eps^4.
  cLA3    ~ 1/eps^3, A3    ~ 1/eps   → product starts at 1/eps^4.
  So: X = x2/eps^2 + x1/eps + x0     (3 unknowns)
      Y = y1/eps + y0                  (2 unknowns)
  Total 5 unknowns, 2 channels × 5 orders = 10 equations → overdetermined,
  expect consistent unique solution if physics is correct.
*)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
order = 0;

dataLead = Get["/private/tmp/a22_two_loop_tree_Leading_masters.mx"];
dataSub  = Get["/private/tmp/a22_two_loop_tree_Subleading_masters.mx"];

(* toSeries: Script-local helper for this development or benchmarking utility. *)
toSeries[expr_] :=
  Normal[Series[expr /. {d -> 4 - 2 eps, q2 -> 1}, {eps, 0, order}]] //
    FunctionExpand // FullSimplify;

(* IBP coefficients as eps series *)
cLA22LO = toSeries[dataLead["CoefficientA22LO"]];
cLA3    = toSeries[dataLead["CoefficientA3"]];
cLA4    = toSeries[dataLead["CoefficientA4"]];
cSA22LO = toSeries[dataSub["CoefficientA22LO"]];
cSA3    = toSeries[dataSub["CoefficientA3"]];
cSA4    = toSeries[dataSub["CoefficientA4"]];

A4val   = toSeries[A22TwoLoopTreeMasterValueA4[] /. {q2 -> 1}];
leadA4  = toSeries[cLA4 * A4val];
subA4   = toSeries[cSA4 * A4val];

targetLead = toSeries[1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440)];
targetSub = toSeries[-1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288)];

residL = toSeries[targetLead - leadA4];
residS = toSeries[targetSub - subA4];

Print["IBP coefficients (eps series):"];
Print["  cLA22LO = ", cLA22LO];
Print["  cLA3    = ", cLA3];
Print["  cSA22LO = ", cSA22LO];
Print["  cSA3    = ", cSA3];
Print["  residL  = ", residL];
Print["  residS  = ", residS];

(*
  Parameterize:
    X(eps) = x2/eps^2 + x1/eps + x0
    Y(eps) = y1/eps + y0

  Product contributions (collected at each power of eps):
    (cLA22LO)(eps) × X(eps) + (cLA3)(eps) × Y(eps) = residL(eps)
*)

(* Xexpr: Script-local helper for this development or benchmarking utility. *)
Xexpr[x2_, x1_, x0_] := x2/eps^2 + x1/eps + x0;
(* Yexpr: Script-local helper for this development or benchmarking utility. *)
Yexpr[y1_, y0_]       := y1/eps + y0;

vars = {x2, x1, x0, y1, y0};

productL = toSeries[cLA22LO * Xexpr[x2, x1, x0] + cLA3 * Yexpr[y1, y0]];
productS = toSeries[cSA22LO * Xexpr[x2, x1, x0] + cSA3 * Yexpr[y1, y0]];

Print[""];
Print["Product (Leading):    ", productL];
Print["Product (Subleading): ", productS];

(* Build equations by equating each power of eps *)
eqsL = Table[Coefficient[productL, eps, n] == Coefficient[residL, eps, n], {n, -4, 0}];
eqsS = Table[Coefficient[productS, eps, n] == Coefficient[residS, eps, n], {n, -4, 0}];
allEqs = Join[eqsL, eqsS];

Print[""];
Print["Equations (Leading):"];
Do[Print["  eps^", n, ": ", eqsL[[-n+1]]], {n, -4, 0}]; (* printing order *)
Print[""];
Print["Solving system for {x2,x1,x0,y1,y0}..."];

sol = Solve[allEqs, vars] // FullSimplify;

If[Length[sol] > 0,
  sol1 = First[sol];
  Print["Solution:"];
  Print["  x2 (A22LO coeff of 1/eps^2) = ", x2 /. sol1 // FullSimplify];
  Print["  x1 (A22LO coeff of 1/eps^1) = ", x1 /. sol1 // FullSimplify];
  Print["  x0 (A22LO coeff of eps^0)   = ", x0 /. sol1 // FullSimplify];
  Print["  y1 (A3 coeff of 1/eps^1)    = ", y1 /. sol1 // FullSimplify];
  Print["  y0 (A3 coeff of eps^0)      = ", y0 /. sol1 // FullSimplify];

  A22LO_correct = Xexpr[x2, x1, x0] /. sol1 // FullSimplify;
  A3_correct    = Yexpr[y1, y0]       /. sol1 // FullSimplify;
  Print[""];
  Print["A22LO_correct series: ", A22LO_correct];
  Print["A3_correct    series: ", A3_correct];

  (* Compare with current master values *)
  A22LO_current = toSeries[A22TwoLoopTreeMasterValueA22LO[] /. {q2 -> 1}];
  A3_current    = toSeries[A22TwoLoopTreeMasterValueA3[]    /. {q2 -> 1}];
  Print["Current A22LO: ", A22LO_current];
  Print["Current A3:    ", A3_current];
  Print[""];
  Print["Ratio A22LO: correct/current = ", FullSimplify[A22LO_correct / A22LO_current]];
  Print["Ratio A3:    correct/current = ", FullSimplify[A3_correct / A3_current]];

  (* Check consistency: all 10 equations should hold *)
  testL = toSeries[cLA22LO * A22LO_correct + cLA3 * A3_correct] - residL;
  testS = toSeries[cSA22LO * A22LO_correct + cSA3 * A3_correct] - residS;
  Print[""];
  Print["Verification residuals:"];
  Print["  Leading    = ", FullSimplify[testL]];
  Print["  Subleading = ", FullSimplify[testS]];
  ,
  Print["No solution or inconsistent system."];
  (* Check if system is inconsistent at some order *)
  Print["Checking equations individually:"];
  Do[
    s = Solve[{allEqs[[i]]}, vars];
    Print["  Eq ", i, ": ", If[Length[s] > 0, "solvable", "no solution"]];
    , {i, Length[allEqs]}
  ]
];
