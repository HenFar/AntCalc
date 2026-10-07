(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

(* simplifySp: Script-local helper for this development or benchmarking utility. *)
simplifySp[expr_] := expr // Expand //. {
  LiteRed`sp[x_ + y_, z_] :> LiteRed`sp[x, z] + LiteRed`sp[y, z],
  LiteRed`sp[x_, y_ + z_] :> LiteRed`sp[x, y] + LiteRed`sp[x, z],
  LiteRed`sp[a_ * x_, y_] /; a =!= 1 :> a * LiteRed`sp[x, y],
  LiteRed`sp[x_, a_ * y_] /; a =!= 1 :> a * LiteRed`sp[x, y],
  LiteRed`sp[0, _] -> 0,
  LiteRed`sp[_, 0] -> 0,
  LiteRed`sp[b_, a_] /; !OrderedQ[{b, a}] :> LiteRed`sp[a, b]
} // Simplify;

Q = k1 + q;
expr = LiteRed`sp[Q, Q];
Print["Simplified: ", InputForm[simplifySp[expr]]];
Quit[];
