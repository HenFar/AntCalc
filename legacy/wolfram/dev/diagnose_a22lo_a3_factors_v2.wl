(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(*
  Corrected diagnostic: find correction factors for A22LOMI and A3MI at each pole order.
  Properly accounts for A4MI's (already-correct) contribution when setting up constraints.
  Solves at 1/eps^4, 1/eps^3, 1/eps^2, 1/eps^1 separately to check consistency.
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

(* individual master contributions (with current values) *)
leadA22LO = toSeries[dataLead["CoefficientA22LO"] * A22TwoLoopTreeMasterValueA22LO[]];
leadA3    = toSeries[dataLead["CoefficientA3"]    * A22TwoLoopTreeMasterValueA3[]];
leadA4    = toSeries[dataLead["CoefficientA4"]    * A22TwoLoopTreeMasterValueA4[]];

subA22LO  = toSeries[dataSub["CoefficientA22LO"]  * A22TwoLoopTreeMasterValueA22LO[]];
subA3     = toSeries[dataSub["CoefficientA3"]      * A22TwoLoopTreeMasterValueA3[]];
subA4     = toSeries[dataSub["CoefficientA4"]      * A22TwoLoopTreeMasterValueA4[]];

targetLead = toSeries[1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440)];

targetSub = toSeries[-1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288)];

(* residual targets: what A22LO+A3 must provide after A4 is subtracted *)
residL = toSeries[targetLead - leadA4];
residS = toSeries[targetSub  - subA4];

Print["=== Residual targets (target minus A4 contribution) ==="];
Print["Leading  residual target: ", residL];
Print["Subleading residual target: ", residS];

Print[""];
Print["=== Current A22LO and A3 contributions ==="];
Print["Leading  A22LO: ", leadA22LO];
Print["Leading  A3:    ", leadA3];
Print["Subleading A22LO: ", subA22LO];
Print["Subleading A3:    ", subA3];

(* solve at each pole order: fA22, fA3 such that
   fA22 * lA22_n + fA3 * lA3_n = residL_n
   fA22 * sA22_n + fA3 * sA3_n = residS_n
   for n = 4, 3, 2, 1 *)

Print[""];
Print["=== Correction factors at each pole order ==="];
Table[
  lA22n = Coefficient[leadA22LO, eps, -n];
  lA3n  = Coefficient[leadA3,    eps, -n];
  sA22n = Coefficient[subA22LO,  eps, -n];
  sA3n  = Coefficient[subA3,     eps, -n];
  rLn   = Coefficient[residL,    eps, -n];
  rSn   = Coefficient[residS,    eps, -n];

  sol = Solve[{fA22 lA22n + fA3 lA3n == rLn,
               fA22 sA22n + fA3 sA3n == rSn},
              {fA22, fA3}] // FullSimplify;

  Print["1/eps^", n, ":  fA22=", fA22 /. First[sol, {}], "  fA3=", fA3 /. First[sol, {}],
        "  (system: ", {lA22n, lA3n, rLn, sA22n, sA3n, rSn}, ")"];

  , {n, 4, 1, -1}
];

(* check: if fA22 = 5/8 and fA3 = -1/3 globally, does Leading work? *)
Print[""];
Print["=== Test with fA22=5/8, fA3=-1/3 (from 1/eps^4 pole, corrected) ==="];
testLead = toSeries[(5/8) leadA22LO + (-1/3) leadA3 + leadA4];
testSub  = toSeries[(5/8) subA22LO  + (-1/3) subA3  + subA4];
Print["Leading  result: ", testLead];
Print["Leading  target: ", targetLead];
Print["Leading  residual: ", FullSimplify[testLead - targetLead]];
Print["Subleading result: ", testSub];
Print["Subleading target: ", targetSub];
Print["Subleading residual: ", FullSimplify[testSub - targetSub]];
