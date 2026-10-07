(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(*
  Test sign/normalization variants for A22LO and A3 master values.
  For each variant, check if the 2x2 system at eps^{-4} is consistent
  between Leading and Subleading, and whether it gives rational corrections.

  Key question: was Codex's sign flip on A22LOMasterCore correct?
  Original: A22LOMI -> +Pi^4/eps^2 (A22LOMasterCore × convention)
  Codex:    A22LOMI -> -Pi^4/eps^2 (A22TwoLoopTreeMasterValueA22LO)
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

cLA22LO = toSeries[dataLead["CoefficientA22LO"]];
cLA3    = toSeries[dataLead["CoefficientA3"]];
cLA4    = toSeries[dataLead["CoefficientA4"]];
cSA22LO = toSeries[dataSub["CoefficientA22LO"]];
cSA3    = toSeries[dataSub["CoefficientA3"]];
cSA4    = toSeries[dataSub["CoefficientA4"]];

targetLead = toSeries[1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440)];
targetSub = toSeries[-1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288)];

(* candidate master values to test *)
A22LO_variants = {
  "Codex (negative)" -> toSeries[A22TwoLoopTreeMasterValueA22LO[] /. {q2 -> 1}],
  "Original (positive)" -> toSeries[A22LOMasterCore[] A22VirtualTwoPartonConventionFactor[] /. {q2 -> 1}],
  "Original no-conv" -> toSeries[A22LOMasterCore[] /. {q2 -> 1}]
};

A3_variants = {
  "Codex A3" -> toSeries[A22TwoLoopTreeMasterValueA3[] /. {q2 -> 1}],
  "Original A3" -> toSeries[A3MasterCore[] A22VirtualTwoPartonConventionFactor[] /. {q2 -> 1}],
  "Negative A3" -> toSeries[-A3MasterCore[] A22VirtualTwoPartonConventionFactor[] /. {q2 -> 1}]
};

A4val = toSeries[A22TwoLoopTreeMasterValueA4[] /. {q2 -> 1}];
leadA4 = toSeries[cLA4 * A4val];
subA4  = toSeries[cSA4 * A4val];

residL4 = Coefficient[targetLead - leadA4, eps, -4];
residS4 = Coefficient[targetSub - subA4, eps, -4];

(* For each combination, solve the 1/eps^4 system *)
Print["Solving 1/eps^4 system for each A22LO x A3 combination:"];
Print["residL at 1/eps^4 (target - A4) = ", residL4];
Print["residS at 1/eps^4 (target - A4) = ", residS4];
Print[""];

Table[
  {nameA22, valA22} = A22LO_variants[[i]];
  {nameA3, valA3} = A3_variants[[j]];

  lA22 = Coefficient[cLA22LO * valA22, eps, -4];
  lA3  = Coefficient[cLA3 * valA3, eps, -4];
  sA22 = Coefficient[cSA22LO * valA22, eps, -4];
  sA3  = Coefficient[cSA3 * valA3, eps, -4];

  sol = Solve[{fA22 lA22 + fA3 lA3 == residL4,
               fA22 sA22 + fA3 sA3 == residS4}, {fA22, fA3}] // FullSimplify;

  If[Length[sol] > 0,
    sol1 = First[sol];
    fA22val = fA22 /. sol1 // FullSimplify;
    fA3val  = fA3 /. sol1 // FullSimplify;
    Print["A22LO=", nameA22, " + A3=", nameA3, " → fA22=", fA22val, "  fA3=", fA3val]
    ,
    Print["A22LO=", nameA22, " + A3=", nameA3, " → NO SOLUTION at 1/eps^4"]
  ]
  , {i, Length[A22LO_variants]}, {j, Length[A3_variants]}
];

(* Now test: with A22LO positive (original), does FULL consistency hold? *)
Print[""];
Print["=== Full series test: Original A22LO (positive) + Original A3 ==="];
A22LO_test = toSeries[A22LOMasterCore[] A22VirtualTwoPartonConventionFactor[] /. {q2 -> 1}];
A3_test    = toSeries[A3MasterCore[]    A22VirtualTwoPartonConventionFactor[] /. {q2 -> 1}];
Print["A22LO_test: ", A22LO_test];
Print["A3_test:    ", A3_test];

(* Solve the full 5x5 system with these *)
(* Xexpr: Script-local helper for this development or benchmarking utility. *)
Xexpr[x2_, x1_, x0_] := x2/eps^2 + x1/eps + x0;
(* Yexpr: Script-local helper for this development or benchmarking utility. *)
Yexpr[y1_, y0_]       := y1/eps + y0;

productL_test = toSeries[cLA22LO * Xexpr[x2, x1, x0] + cLA3 * Yexpr[y1, y0]];
productS_test = toSeries[cSA22LO * Xexpr[x2, x1, x0] + cSA3 * Yexpr[y1, y0]];

residL_full = toSeries[targetLead - leadA4];
residS_full = toSeries[targetSub - subA4];

eqsL = Table[Coefficient[productL_test, eps, n] == Coefficient[residL_full, eps, n], {n, -4, 0}];
eqsS = Table[Coefficient[productS_test, eps, n] == Coefficient[residS_full, eps, n], {n, -4, 0}];

sol_full = Solve[Join[eqsL, eqsS], {x2, x1, x0, y1, y0}] // FullSimplify;
If[Length[sol_full] > 0,
  sf = First[sol_full];
  Print["Full solution found:"];
  Print["  x2=", x2/.sf//FullSimplify];
  Print["  x1=", x1/.sf//FullSimplify];
  Print["  x0=", x0/.sf//FullSimplify];
  Print["  y1=", y1/.sf//FullSimplify];
  Print["  y0=", y0/.sf//FullSimplify];

  A22LO_correct = (x2/eps^2 + x1/eps + x0) /. sf // FullSimplify;
  A3_correct    = (y1/eps + y0) /. sf // FullSimplify;
  Print["Ratio A22LO correct/original: ", FullSimplify[A22LO_correct / A22LO_test]];
  Print["Ratio A3    correct/original: ", FullSimplify[A3_correct    / A3_test]];
  ,
  Print["No consistent solution with original-sign A22LO."]
];
