(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

Clear[eps];

A22LOcurr = A22TwoLoopTreeMasterValueA22LO[] /. {q2 -> 1};
A3curr    = A22TwoLoopTreeMasterValueA3[] /. {q2 -> 1};

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

A22LOsol = x2/eps^2 + x1/eps + x0 + x1new * eps + x2new * eps^2;
A3sol    = y1/eps + y0 + y1new * eps + y2new * eps^2 + y3new * eps^3;

seriesLOcurr = Series[A22LOcurr, {eps, 0, 2}] // Normal // FunctionExpand // FullSimplify;
seriesA3curr = Series[A3curr, {eps, 0, 3}] // Normal // FunctionExpand // FullSimplify;

ratioLO = Series[A22LOsol / seriesLOcurr, {eps, 0, 2}] // Normal // FullSimplify;
ratioA3 = Series[A3sol / seriesA3curr, {eps, 0, 2}] // Normal // FullSimplify;

Print["Ratio A22LO (sol/current): ", ratioLO // InputForm];
Print["Ratio A3    (sol/current): ", ratioA3 // InputForm];

A22LOorig = A22LOMasterCore[] * A22VirtualTwoPartonConventionFactor[] /. {q2 -> 1};
seriesLOorig = Series[A22LOorig, {eps, 0, 2}] // Normal // FunctionExpand // FullSimplify;
ratioLOorig = Series[A22LOsol / seriesLOorig, {eps, 0, 2}] // Normal // FullSimplify;
Print["Ratio A22LO (sol/original): ", ratioLOorig // InputForm];

Quit[];
