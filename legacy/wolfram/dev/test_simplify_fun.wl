(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

(* simplifySp: Script-local helper for this development or benchmarking utility. *)
simplifySp[expr_] := Module[{e = expr, r1, r2, r3, r4, r5},
  Print["Inside simplifySp: input = ", InputForm[e]];
  r1 = e //. {LiteRed`sp[x_ + y_, z_] :> LiteRed`sp[x, z] + LiteRed`sp[y, z]};
  Print["Inside simplifySp: r1 = ", InputForm[r1]];
  r2 = r1 //. {LiteRed`sp[x_, y_ + z_] :> LiteRed`sp[x, y] + LiteRed`sp[x, z]};
  Print["Inside simplifySp: r2 = ", InputForm[r2]];
  r3 = r2 //. {LiteRed`sp[b_, a_] /; !OrderedQ[{b, a}] :> LiteRed`sp[a, b]};
  Print["Inside simplifySp: r3 = ", InputForm[r3]];
  r4 = r3 //. {
    LiteRed`sp[a_?NumberQ * x_, y_] /; a =!= 1 :> a * LiteRed`sp[x, y],
    LiteRed`sp[x_, a_?NumberQ * y_] /; a =!= 1 :> a * LiteRed`sp[x, y],
    LiteRed`sp[0, _] -> 0,
    LiteRed`sp[_, 0] -> 0
  };
  Print["Inside simplifySp: r4 = ", InputForm[r4]];
  r5 = r4 /. {
    LiteRed`sp[k1, k1] -> 0,
    LiteRed`sp[q, q] -> q2,
    LiteRed`sp[k1, q] -> q2/2,
    LiteRed`sp[q, k1] -> q2/2
  };
  Print["Inside simplifySp: r5 = ", InputForm[r5]];
  r5 // Simplify
];

Q = k1 + q;
expr = LiteRed`sp[Q, Q];
Print["Outer call result: ", InputForm[simplifySp[expr]]];
Quit[];
