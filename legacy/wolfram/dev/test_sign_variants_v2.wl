(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(*
  Test sign variants for A22LO and A3 master values.
  For each combination, set up the full 10-equation system and check consistency.
  A22LO ~ 1/eps^2, A3 ~ 1/eps. Parameterize:
    X = x2/eps^2 + x1/eps + x0
    Y = y1/eps + y0
  and solve. Report whether the system is consistent.
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

A4val  = toSeries[A22TwoLoopTreeMasterValueA4[] /. {q2 -> 1}];
leadA4 = toSeries[cLA4 * A4val];
subA4  = toSeries[cSA4 * A4val];

targetLead = toSeries[1/(4 eps^4) + 17/(8 eps^3) + (433/144 - Pi^2/2)/eps^2 +
  (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
  (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 + 263 Pi^4/1440)];
targetSub = toSeries[-1/(4 eps^4) - 3/(4 eps^3) + (-41/16 + 13 Pi^2/24)/eps^2 +
  (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
  (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 - 59 Pi^4/288)];

residL = toSeries[targetLead - leadA4];
residS = toSeries[targetSub  - subA4];

(* Check consistency of the 10-equation system for a given A22LO and A3 series *)
(* checkConsistency: Script-local helper for this development or benchmarking utility. *)
checkConsistency[a22lo_, a3_, label_] :=
  Module[{cA22lo, cA3, Xfn, Yfn, productL, productS, eqs, sol},
    cA22lo = toSeries[a22lo];
    cA3    = toSeries[a3];
    Xfn = x2/eps^2 + x1/eps + x0;
    Yfn = y1/eps + y0;
    productL = toSeries[cLA22LO * cA22lo * Xfn + cLA3 * cA3 * Yfn];
    productS = toSeries[cSA22LO * cA22lo * Xfn + cSA3 * cA3 * Yfn];

    (* Hmm this is wrong - let me compute contributions directly *)
    (* leadA22lo = cLA22LO * cA22lo is contribution of A22LOMI when master=cA22lo*xfn *)
    (* Actually: leadA22lo = cLA22LO * cA22lo is NOT right — Xfn is the unknown master value *)
    (* Correct: cLA22LO * Xfn where Xfn = x2/eps^2 + x1/eps + x0 *)
    productL = toSeries[cLA22LO * Xfn + cLA3 * Yfn];
    productS = toSeries[cSA22LO * Xfn + cSA3 * Yfn];

    eqs = Join[
      Table[Coefficient[productL, eps, n] == Coefficient[residL, eps, n], {n, -4, 0}],
      Table[Coefficient[productS, eps, n] == Coefficient[residS, eps, n], {n, -4, 0}]
    ];
    sol = Solve[eqs, {x2, x1, x0, y1, y0}] // FullSimplify;

    If[Length[sol] > 0,
      s1 = First[sol];
      Print[label, ": CONSISTENT. x2=", x2/.s1//FullSimplify, ", y1=", y1/.s1//FullSimplify,
            ", x0=", x0/.s1//FullSimplify];
      True
      ,
      Print[label, ": INCONSISTENT."];
      False
    ]
  ];

(* The IBP coefficients already encode the sign of A22LOMI.
   The MASTER VALUE just sets the overall scale.
   So we just need to solve for X = A22LOMI and Y = A3 as series. *)
Xfn = x2/eps^2 + x1/eps + x0;
Yfn = y1/eps + y0;
productL = toSeries[cLA22LO * Xfn + cLA3 * Yfn];
productS = toSeries[cSA22LO * Xfn + cSA3 * Yfn];

eqsL = Table[Coefficient[productL, eps, n] == Coefficient[residL, eps, n], {n, -4, 0}];
eqsS = Table[Coefficient[productS, eps, n] == Coefficient[residS, eps, n], {n, -4, 0}];

Print["=== Full 10-equation system (treating A22LOMI and A3MI as unknowns) ==="];
Print["System structure:"];
Print["  5 equations from Leading, 5 from Subleading"];
Print["  5 unknowns: x2, x1, x0, y1, y0"];
Print["  => overdetermined: consistent iff all eqs are compatible"];

sol = Solve[Join[eqsL, eqsS], {x2, x1, x0, y1, y0}] // FullSimplify;

If[Length[sol] > 0,
  s1 = First[sol];
  Print["SOLUTION FOUND:"];
  Print["  A22LOMI series:"];
  Print["    1/eps^2 coeff: ", x2/.s1 // FullSimplify];
  Print["    1/eps^1 coeff: ", x1/.s1 // FullSimplify];
  Print["    eps^0   coeff: ", x0/.s1 // FullSimplify];
  Print["  A3MI series:"];
  Print["    1/eps^1 coeff: ", y1/.s1 // FullSimplify];
  Print["    eps^0   coeff: ", y0/.s1 // FullSimplify];

  A22LO_sol = (x2/eps^2 + x1/eps + x0) /. s1 // FullSimplify;
  A3_sol    = (y1/eps + y0) /. s1 // FullSimplify;

  (* Compare to current values *)
  A22LO_curr = toSeries[A22TwoLoopTreeMasterValueA22LO[] /. {q2->1}];
  A3_curr    = toSeries[A22TwoLoopTreeMasterValueA3[]    /. {q2->1}];
  A22LO_orig = toSeries[A22LOMasterCore[] A22VirtualTwoPartonConventionFactor[] /. {q2->1}];
  A3_orig    = toSeries[A3MasterCore[]    A22VirtualTwoPartonConventionFactor[] /. {q2->1}];

  Print[""];
  Print["Current (Codex) A22LO:  ", A22LO_curr];
  Print["Original A22LO:         ", A22LO_orig];
  Print["Solution A22LO:         ", A22LO_sol];
  Print[""];
  Print["Current (Codex) A3:     ", A3_curr];
  Print["Original A3:            ", A3_orig];
  Print["Solution A3:            ", A3_sol];
  Print[""];
  Print["Ratio sol/current A22LO: ", FullSimplify[A22LO_sol / A22LO_curr]];
  Print["Ratio sol/original A22LO:", FullSimplify[A22LO_sol / A22LO_orig]];
  Print["Ratio sol/current A3:    ", FullSimplify[A3_sol / A3_curr]];
  Print["Ratio sol/original A3:   ", FullSimplify[A3_sol / A3_orig]];

  (* Verify *)
  testL = toSeries[cLA22LO * A22LO_sol + cLA3 * A3_sol] - residL;
  testS = toSeries[cSA22LO * A22LO_sol + cSA3 * A3_sol] - residS;
  Print[""];
  Print["Verification (should be 0):"];
  Print["  Leading residual:    ", FullSimplify[testL]];
  Print["  Subleading residual: ", FullSimplify[testS]];
  ,
  Print["NO SOLUTION — the system is INCONSISTENT."];
  Print["This means A22LO and A3 alone cannot reproduce the paper targets."];
  Print["Investigating which equations conflict..."];

  (* Try solving Leading only, then check if Subleading is satisfied *)
  solL = Solve[eqsL, {x2, x1, x0, y1, y0}] // FullSimplify;
  If[Length[solL] > 0,
    sL = First[solL];
    Print["Leading-only solution:"];
    Print["  x2=", x2/.sL//FullSimplify, ", x1=", x1/.sL//FullSimplify];
    Print["  x0=", x0/.sL//FullSimplify];
    Print["  y1=", y1/.sL//FullSimplify, ", y0=", y0/.sL//FullSimplify];

    (* Check each Subleading equation *)
    Print["Subleading check (residuals, should be 0 if consistent):"];
    Do[
      residual = (eqsS[[i, 1]] - eqsS[[i, 2]]) /. sL // FullSimplify;
      Print["  Subleading eps^", -5+i, ": residual = ", residual];
      , {i, Length[eqsS]}
    ]
    ,
    Print["Even Leading-only system has no solution!"]
  ]
];
