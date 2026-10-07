(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(*
  Check if the code's Leading/Subleading color decomposition matches
  the paper's definition.

  Paper: T = N * Lead + (1/N) * Sub + Nf * Nf_term
  Code:  computes Lead and Sub separately via color component extraction.

  Test 1: Does Lead_code + Sub_code = Lead_paper + Sub_paper?  (sum should match regardless of basis)
  Test 2: Does a 2x2 recombination (a*Lead + b*Sub, c*Lead + d*Sub) recover the paper's Lead and Sub?
  Test 3: What are the IBP coefficient SUMS cL+cS for each master?
*)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
order = 0;

dataLead = Get["/private/tmp/a22_two_loop_tree_Leading_masters.mx"];
dataSub  = Get["/private/tmp/a22_two_loop_tree_Subleading_masters.mx"];
dataNf   = Get["/private/tmp/a22_two_loop_tree_Nf_masters.mx"];

(* toSeries: Script-local helper for this development or benchmarking utility. *)
toSeries[expr_] :=
  Normal[Series[expr /. {d -> 4 - 2 eps, q2 -> 1}, {eps, 0, order}]] //
    FunctionExpand // FullSimplify;

(* IBP coefficients *)
cLA22LO = toSeries[dataLead["CoefficientA22LO"]];
cLA3    = toSeries[dataLead["CoefficientA3"]];
cLA4    = toSeries[dataLead["CoefficientA4"]];
cSA22LO = toSeries[dataSub["CoefficientA22LO"]];
cSA3    = toSeries[dataSub["CoefficientA3"]];
cSA4    = toSeries[dataSub["CoefficientA4"]];
cNfA4   = toSeries[dataNf["CoefficientA4"]];

Print["=== IBP coefficient sums and differences ==="];
Print["cLA22LO: ", cLA22LO];
Print["cSA22LO: ", cSA22LO];
Print["Sum L+S A22LO: ", FullSimplify[cLA22LO + cSA22LO]];
Print["Diff L-S A22LO: ", FullSimplify[cLA22LO - cSA22LO]];
Print[""];
Print["cLA3: ", cLA3];
Print["cSA3: ", cSA3];
Print["Sum L+S A3: ", FullSimplify[cLA3 + cSA3]];
Print["Diff L-S A3: ", FullSimplify[cLA3 - cSA3]];
Print[""];
Print["cLA4: ", cLA4];
Print["cSA4: ", cSA4];
Print["cNfA4: ", cNfA4];
Print["Sum L+S A4: ", FullSimplify[cLA4 + cSA4]];

(* Paper targets *)
targetLead = toSeries[1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440)];
targetSub = toSeries[-1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288)];

Print[""];
Print["=== Paper target structure ==="];
Print["Lead + Sub: ", FullSimplify[targetLead + targetSub]];
Print["Lead - Sub: ", FullSimplify[targetLead - targetSub]];
Print["2*Lead + Sub: ", FullSimplify[2 targetLead + targetSub]];
Print["Lead + 2*Sub: ", FullSimplify[targetLead + 2 targetSub]];

(* Code uses A4val and validated master values. Let's see what the current
   TOTAL result is for Lead+Sub with the current (broken) master values *)
A22LOval = toSeries[A22TwoLoopTreeMasterValueA22LO[] /. {q2->1}];
A3val    = toSeries[A22TwoLoopTreeMasterValueA3[]    /. {q2->1}];
A4val    = toSeries[A22TwoLoopTreeMasterValueA4[]    /. {q2->1}];

leadA4 = toSeries[cLA4 * A4val];
subA4  = toSeries[cSA4 * A4val];

(* Current total result for Lead and Sub *)
leadRaw = toSeries[cLA22LO * A22LOval + cLA3 * A3val + cLA4 * A4val];
subRaw  = toSeries[cSA22LO * A22LOval + cSA3 * A3val + cSA4 * A4val];

Print[""];
Print["=== Current (broken) total results ==="];
Print["Current Lead: ", leadRaw];
Print["Current Sub:  ", subRaw];
Print["Current Lead+Sub: ", FullSimplify[leadRaw + subRaw]];
Print["Paper   Lead+Sub: ", FullSimplify[targetLead + targetSub]];
Print["Residual Lead+Sub: ", FullSimplify[leadRaw + subRaw - targetLead - targetSub]];

(* Test recombinations *)
Print[""];
Print["=== Recombination tests ==="];
Print["Does Lead_code = Lead_paper? ", FullSimplify[leadRaw - targetLead] === 0];
Print["Does Sub_code  = Sub_paper?  ", FullSimplify[subRaw  - targetSub]  === 0];
Print["Does Lead_code = Sub_paper?  ", FullSimplify[leadRaw - targetSub]  === 0];
Print["Does Sub_code  = Lead_paper? ", FullSimplify[subRaw  - targetLead] === 0];
Print["Does (Lead+Sub)/2 = Lead_paper? ", FullSimplify[(leadRaw+subRaw)/2 - targetLead] === 0];
Print["Does (Lead-Sub)/2 = Lead_paper? ", FullSimplify[(leadRaw-subRaw)/2 - targetLead] === 0];

(* Check if N^2 * Lead + Sub = something simple (C_F^2 * ...) *)
Print[""];
Print["Leading pole of code_Lead:  ", Coefficient[leadRaw, eps, -4]];
Print["Leading pole of code_Sub:   ", Coefficient[subRaw, eps, -4]];
Print["Leading pole of paper_Lead: ", Coefficient[targetLead, eps, -4]];
Print["Leading pole of paper_Sub:  ", Coefficient[targetSub, eps, -4]];

(* Try: does code_Lead match paper up to a simple overall rescaling? *)
Print[""];
Print["Ratio code_Lead / paper_Lead at each order:"];
Table[
  cl = Coefficient[leadRaw, eps, n];
  cp = Coefficient[targetLead, eps, n];
  ratio = If[cp =!= 0, FullSimplify[cl/cp], "target=0"];
  Print["  eps^", n, ": code/paper = ", ratio];
  , {n, -4, 0}
];

Print["Ratio code_Sub / paper_Sub at each order:"];
Table[
  cs = Coefficient[subRaw, eps, n];
  cp = Coefficient[targetSub, eps, n];
  ratio = If[cp =!= 0, FullSimplify[cs/cp], "target=0"];
  Print["  eps^", n, ": code/paper = ", ratio];
  , {n, -4, 0}
];
