(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
order = 0;

dataLead = Get["/private/tmp/a22_two_loop_tree_Leading_masters.mx"];
dataSub  = Get["/private/tmp/a22_two_loop_tree_Subleading_masters.mx"];

(* toSeries: Script-local helper for this development or benchmarking utility. *)
toSeries[expr_] :=
  Normal[Series[expr /. {d -> 4 - 2 eps, q2 -> 1}, {eps, 0, order}]] //
    FunctionExpand // FullSimplify;

cLA22LO = toSeries[dataLead["CoefficientA22LO"]];
cLA3    = toSeries[dataLead["CoefficientA3"]];
cLA4    = toSeries[dataLead["CoefficientA4"]];
cLA6    = toSeries[Coefficient[dataLead["RawMapped"], A6MI]];
cSA22LO = toSeries[dataSub["CoefficientA22LO"]];
cSA3    = toSeries[dataSub["CoefficientA3"]];
cSA4    = toSeries[dataSub["CoefficientA4"]];
cSA6    = toSeries[Coefficient[dataSub["RawMapped"], A6MI]];

A4val   = toSeries[A22TwoLoopTreeMasterValueA4[] /. {q2 -> 1}];
A6val   = toSeries[A22TwoLoopTreeMasterValueA6[] /. {q2 -> 1}];

leadA4  = toSeries[cLA4 * A4val];
leadA6  = toSeries[cLA6 * A6val];
subA4   = toSeries[cSA4 * A4val];
subA6   = toSeries[cSA6 * A6val];

targetLead = toSeries[1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440)];
targetSub = toSeries[-1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288)];

residL = toSeries[targetLead - (leadA4 + leadA6)];
residS = toSeries[targetSub - (subA4 + subA6)];

(* Xexpr: Script-local helper for this development or benchmarking utility. *)
Xexpr[x2_, x1_, x0_] := x2/eps^2 + x1/eps + x0;
(* Yexpr: Script-local helper for this development or benchmarking utility. *)
Yexpr[y1_, y0_]       := y1/eps + y0;

vars = {x2, x1, x0, y1, y0};

productL = toSeries[cLA22LO * Xexpr[x2, x1, x0] + cLA3 * Yexpr[y1, y0]];
productS = toSeries[cSA22LO * Xexpr[x2, x1, x0] + cSA3 * Yexpr[y1, y0]];

eqsL = Table[Coefficient[productL, eps, n] == Coefficient[residL, eps, n], {n, -4, 0}];
eqsS = Table[Coefficient[productS, eps, n] == Coefficient[residS, eps, n], {n, -4, 0}];
allEqs = Join[eqsL, eqsS];

sol = Solve[allEqs, vars] // FullSimplify;

If[Length[sol] > 0,
  sol1 = First[sol];
  Print["Solution found:"];
  Print["  x2 (A22LO at 1/eps^2): ", x2 /. sol1 // FullSimplify];
  Print["  x1 (A22LO at 1/eps^1): ", x1 /. sol1 // FullSimplify];
  Print["  x0 (A22LO at eps^0):   ", x0 /. sol1 // FullSimplify];
  Print["  y1 (A3   at 1/eps^1): ", y1 /. sol1 // FullSimplify];
  Print["  y0 (A3   at eps^0):   ", y0 /. sol1 // FullSimplify];

  A22LO_correct = Xexpr[x2, x1, x0] /. sol1 // FullSimplify;
  A3_correct    = Yexpr[y1, y0]       /. sol1 // FullSimplify;
  
  A22LO_current = toSeries[A22TwoLoopTreeMasterValueA22LO[] /. {q2 -> 1}];
  A3_current    = toSeries[A22TwoLoopTreeMasterValueA3[]    /. {q2 -> 1}];
  
  Print[""];
  Print["A22LO correct: ", A22LO_correct];
  Print["A22LO current: ", A22LO_current];
  Print["Ratio correct/current A22LO: ", FullSimplify[A22LO_correct / A22LO_current]];
  Print[""];
  Print["A3 correct: ", A3_correct];
  Print["A3 current: ", A3_current];
  Print["Ratio correct/current A3:    ", FullSimplify[A3_correct / A3_current]];
  ,
  Print["NO SOLUTION found."];
];

Quit[];
