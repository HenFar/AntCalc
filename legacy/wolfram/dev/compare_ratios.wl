(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

A22LO_curr = A22TwoLoopTreeMasterValueA22LO[] /. {q2 -> 1};
A3_curr    = A22TwoLoopTreeMasterValueA3[] /. {q2 -> 1};

(* Solution values *)
x2 = (-3*Pi^4)/8;
x1 = (-29*Pi^4)/4;
x0 = (Pi^4*(-1763 + 42*Pi^2))/96;
x1new = (Pi^4*(-567 + 261*Pi^2 - 544*Zeta[3]))/48;
x2new = (Pi^4*(1676425 + 188550*Pi^2 + 3468*Pi^4 - 308160*Zeta[3]))/17280;

y1 = 0;
y0 = (61*Pi^4)/72;
y1new = (Pi^4*(997 + 24*Pi^2))/216;
y2new = (Pi^4*(21823 + 798*Pi^2 + 8784*Zeta[3]))/2592;
y3new = -1/7776*(Pi^4*(44209 + 12*Pi^2 + 1467*Pi^4 - 101592*Zeta[3]));

A22LO_sol = x2/eps^2 + x1/eps + x0 + x1new * eps + x2new * eps^2;
A3_sol    = y1/eps + y0 + y1new * eps + y2new * eps^2 + y3new * eps^3;

(* We want to compare with A22LO_curr and A3_curr *)
seriesLO_curr = Normal[Series[A22LO_curr, {eps, 0, 2}]] // FunctionExpand // FullSimplify;
seriesA3_curr = Normal[Series[A3_curr, {eps, 0, 3}]] // FunctionExpand // FullSimplify;

ratioLO = Series[A22LO_sol / seriesLO_curr, {eps, 0, 2}] // Normal // FullSimplify;
ratioA3 = Series[A3_sol / seriesA3_curr, {eps, 0, 2}] // Normal // FullSimplify;

Print["Ratio A22LO: sol/current = ", ratioLO];
Print["Ratio A3:    sol/current = ", ratioA3];

(* What about comparing with original values (OneLoopSelf ones)? *)
(* A22LOMI in OneLoopSelf is: A22LOMasterCore[] * A22VirtualTwoPartonConventionFactor[] *)
A22LO_orig = A22LOMasterCore[] * A22VirtualTwoPartonConventionFactor[] /. {q2 -> 1};
A3_orig    = A3MasterCore[] * A22VirtualTwoPartonConventionFactor[] /. {q2 -> 1};

(* Let's see if A3MasterCore is defined - if not, we can check how A3 was defined in OneLoopSelf *)
(* A3 is not in OneLoopSelf, but A3MasterCore[] is defined in integration_ibp.wl as the sunset? *)
(* Let's check if A3MasterCore exists by trying to evaluate it *)
Print["A22LO_orig evaluation: ", Normal[Series[A22LO_orig, {eps, 0, 2}]] // FunctionExpand // FullSimplify];

ratioLO_orig = Series[A22LO_sol / A22LO_orig, {eps, 0, 2}] // Normal // FullSimplify;
Print["Ratio A22LO: sol/original = ", ratioLO_orig];

Quit[];
