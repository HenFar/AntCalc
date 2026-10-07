(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

Q = k1 + q;
expr = LiteRed`sp[Q, Q];
Print["expr: ", InputForm[expr]];

r1 = expr //. {
  LiteRed`sp[x_ + y_, z_] :> LiteRed`sp[x, z] + LiteRed`sp[y, z]
};
Print["After r1 (expand first arg): ", InputForm[r1]];

r2 = r1 //. {
  LiteRed`sp[x_, y_ + z_] :> LiteRed`sp[x, y] + LiteRed`sp[x, z]
};
Print["After r2 (expand second arg): ", InputForm[r2]];

r3 = r2 //. {
  LiteRed`sp[b_, a_] /; !OrderedQ[{b, a}] :> LiteRed`sp[a, b]
};
Print["After r3 (sort arguments): ", InputForm[r3]];

Quit[];
