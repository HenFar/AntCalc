(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

A22LO_curr = A22TwoLoopTreeMasterValueA22LO[] /. {q2 -> 1};

x2 = (-3*Pi^4)/8;
x1 = (-29*Pi^4)/4;
x0 = (Pi^4*(-1763 + 42*Pi^2))/96;
x1new = (Pi^4*(-567 + 261*Pi^2 - 544*Zeta[3]))/48;
x2new = (Pi^4*(1676425 + 188550*Pi^2 + 3468*Pi^4 - 308160*Zeta[3]))/17280;

A22LO_sol = x2/eps^2 + x1/eps + x0 + x1new * eps + x2new * eps^2;

seriesLO_curr = Series[A22LO_curr, {eps, 0, 2}] // Normal // FunctionExpand // FullSimplify;

Print["A22LO_sol: ", InputForm[A22LO_sol]];
Print["seriesLO_curr: ", InputForm[seriesLO_curr]];
Print["ratio: ", InputForm[FullSimplify[A22LO_sol / seriesLO_curr]]];

Quit[];
