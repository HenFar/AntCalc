(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];
expr = LiteRed`sp[k1 + q, k1 + q];
Print["Original: ", InputForm[expr]];
r1 = expr /. LiteRed`sp[x_ + y_, z_] :> LiteRed`sp[x, z] + LiteRed`sp[y, z];
Print["After r1: ", r1 // InputForm];
r2 = r1 /. LiteRed`sp[x_, y_ + z_] :> LiteRed`sp[x, y] + LiteRed`sp[x, z];
Print["After r2: ", r2 // InputForm];
Quit[];
