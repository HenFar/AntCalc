(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(*
  Diagnostic: find correction factors for A22LOMI and A3MI.
  Uses saved IBP coefficients (no IBP run needed).
  For each of Leading and Subleading, compute individual master contributions,
  then solve for the scalar correction factors needed.
*)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
order = 0;

(* ---- load saved IBP coefficients ---- *)
dataLead = Get["/private/tmp/a22_two_loop_tree_Leading_masters.mx"];
dataSub  = Get["/private/tmp/a22_two_loop_tree_Subleading_masters.mx"];

(* ---- helper: expand a single master contribution to series ---- *)
(* toSeries: Script-local helper for this development or benchmarking utility. *)
toSeries[expr_] :=
  Normal[Series[expr /. {d -> 4 - 2 eps, q2 -> 1}, {eps, 0, order}]] //
    FunctionExpand // FullSimplify;

(* ---- Leading: individual contributions ---- *)
Print["=== LEADING ==="];
leadA22LO = toSeries[dataLead["CoefficientA22LO"] * A22TwoLoopTreeMasterValueA22LO[]];
leadA3    = toSeries[dataLead["CoefficientA3"]    * A22TwoLoopTreeMasterValueA3[]];
leadA4    = toSeries[dataLead["CoefficientA4"]    * A22TwoLoopTreeMasterValueA4[]];
leadTotal = toSeries[dataLead["RawMapped"] /. A22TwoLoopTreeMasterCoefficientRules[]];

Print["  A22LO contribution: ", leadA22LO];
Print["  A3   contribution: ", leadA3];
Print["  A4   contribution: ", leadA4];
Print["  Total (current):   ", leadTotal];

targetLead = 1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440);
targetLead = toSeries[targetLead];

Print["  Target:            ", targetLead];
Print["  Residual:          ", FullSimplify[leadTotal - targetLead]];

(* pole-by-pole *)
Print["  Pole breakdown:"];
Do[
  coef = Coefficient[leadTotal, eps, -n];
  tcoef = Coefficient[targetLead, eps, -n];
  ratio = If[tcoef =!= 0, FullSimplify[coef/tcoef], "target=0"];
  Print["    1/eps^", n, ":  current=", coef, "  target=", tcoef, "  ratio=", ratio];
  , {n, 4, 1, -1}
];

(* contribution at 1/eps^4 from each master *)
Print["  1/eps^4 breakdown:"];
Print["    A22LO: ", Coefficient[leadA22LO, eps, -4]];
Print["    A3:    ", Coefficient[leadA3, eps, -4]];
Print["    A4:    ", Coefficient[leadA4, eps, -4]];

(* ---- Subleading: individual contributions ---- *)
Print[""];
Print["=== SUBLEADING ==="];
subA22LO = toSeries[dataSub["CoefficientA22LO"] * A22TwoLoopTreeMasterValueA22LO[]];
subA3    = toSeries[dataSub["CoefficientA3"]    * A22TwoLoopTreeMasterValueA3[]];
subA4    = toSeries[dataSub["CoefficientA4"]    * A22TwoLoopTreeMasterValueA4[]];
subTotal = toSeries[dataSub["RawMapped"] /. A22TwoLoopTreeMasterCoefficientRules[]];

Print["  A22LO contribution: ", subA22LO];
Print["  A3   contribution: ", subA3];
Print["  A4   contribution: ", subA4];
Print["  Total (current):   ", subTotal];

targetSub = -1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288);
targetSub = toSeries[targetSub];

Print["  Target:            ", targetSub];
Print["  Residual:          ", FullSimplify[subTotal - targetSub]];

Print["  1/eps^4 breakdown:"];
Print["    A22LO: ", Coefficient[subA22LO, eps, -4]];
Print["    A3:    ", Coefficient[subA3, eps, -4]];
Print["    A4:    ", Coefficient[subA4, eps, -4]];

(* ---- Solve for correction factors at 1/eps^4 ---- *)
Print[""];
Print["=== SOLVING FOR CORRECTION FACTORS AT 1/eps^4 ==="];
(* We want f_A22LO * leadA22LO_coef + f_A3 * leadA3_coef = target_lead_coef *)
(* AND      f_A22LO * subA22LO_coef  + f_A3 * subA3_coef  = target_sub_coef  *)

lA22 = Coefficient[leadA22LO, eps, -4];
lA3  = Coefficient[leadA3, eps, -4];
sA22 = Coefficient[subA22LO, eps, -4];
sA3  = Coefficient[subA3, eps, -4];
tL   = Coefficient[targetLead, eps, -4];
tS   = Coefficient[targetSub, eps, -4];

sol = Solve[{fA22 lA22 + fA3 lA3 == tL, fA22 sA22 + fA3 sA3 == tS}, {fA22, fA3}];
Print["  Correction factors: ", sol // FullSimplify];

(* ---- Check: with the same factor for both masters ---- *)
Print[""];
Print["=== CHECK: same factor for A22LO and A3 ==="];
(* Does a single global factor f satisfy both equations? *)
solGlobal = Solve[{f (lA22 + lA3) == tL, f (sA22 + sA3) == tS}, {f}];
Print["  Single global factor (if consistent): ", solGlobal // FullSimplify];
Print["  Leading:    f*(A22LO+A3) = ", FullSimplify[lA22 + lA3],
      "  target = ", tL, "  ratio = ", FullSimplify[tL / (lA22 + lA3)]];
Print["  Subleading: f*(A22LO+A3) = ", FullSimplify[sA22 + sA3],
      "  target = ", tS, "  ratio = ", FullSimplify[tS / (sA22 + sA3)]];
