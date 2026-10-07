(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

(* Clear eps to make sure it is a symbol *)
Clear[eps];

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

(* We expand the current values in series of Global`eps *)
seriesLO_curr = Series[A22LO_curr, {eps, 0, 2}] // Normal // FunctionExpand // FullSimplify;
seriesA3_curr = Series[A3_curr, {eps, 0, 3}] // Normal // FunctionExpand // FullSimplify;

ratioLO = Series[A22LO_sol / seriesLO_curr, {eps, 0, 2}] // Normal // FullSimplify;
ratioA3 = Series[A3_sol / seriesA3_curr, {eps, 0, 2}] // Normal // FullSimplify;

Print["Ratio A22LO: sol/current = ", ratioLO];
Print["Ratio A3:    sol/current = ", ratioA3];

(* Also compare with original A22LO (positive) *)
A22LO_orig = A22LOMasterCore[] * A22VirtualTwoPartonConventionFactor[] /. {q2 -> 1};
seriesLO_orig = Series[A22LO_orig, {eps, 0, 2}] // Normal // FunctionExpand // FullSimplify;
ratioLO_orig = Series[A22LO_sol / seriesLO_orig, {eps, 0, 2}] // Normal // FullSimplify;
Print["Ratio A22LO: sol/original = ", ratioLO_orig];

Quit[];
