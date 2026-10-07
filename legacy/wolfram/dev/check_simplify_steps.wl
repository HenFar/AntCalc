(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

(* getVector: Script-local helper for this development or benchmarking utility. *)
getVector[LiteRed`sp[v_, _]] := v;
(* getVector: Script-local helper for this development or benchmarking utility. *)
getVector[v_] := v;

profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];

Q = k1 + q;
expr = LiteRed`sp[Q, Q];
Print["expr: ", InputForm[expr]];

exprExpanded = expr // Expand;
Print["exprExpanded: ", InputForm[exprExpanded]];

r1 = exprExpanded /. LiteRed`sp[x_ + y_, z_] :> LiteRed`sp[x, z] + LiteRed`sp[y, z];
Print["After r1: ", InputForm[r1]];

r2 = exprExpanded //. LiteRed`sp[x_ + y_, z_] :> LiteRed`sp[x, z] + LiteRed`sp[y, z];
Print["After r2: ", InputForm[r2]];

r3 = r2 //. LiteRed`sp[x_, y_ + z_] :> LiteRed`sp[x, y] + LiteRed`sp[x, z];
Print["After r3: ", InputForm[r3]];

Quit[];
