(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(*
  Print the actual LiteRed masters for each A22TwoLoopTree basis,
  with their active propagator counts and topology classification.
  Key question: are there any >=5 active propagator masters (A6MI) being
  misclassified as lower masters?
*)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];

Print["Loaded ", Length[basisLoad["Bases"]], " bases."];

Do[
  basis = basisLoad["Bases"][[i]];
  masters = LiteRed`MIs[basis];
  Print[""];
  Print["=== Basis ", basis, " ==="];
  Print["  Denominators: ", LiteRed`Ds[basis]];
  Print["  Masters (", Length[masters], " total):"];

  Do[
    master = masters[[k]];
    indexList = List @@ master // Rest;  (* drop basis symbol *)
    activeDens = Pick[LiteRed`Ds[basis], indexList, _?(# > 0 &)];
    activeCount = Length[activeDens];
    classification = A22TwoLoopTreeMasterForIntegral[master];
    isDisc = A22DisconnectedBubbleMasterQ[activeDens];
    Print["  j", indexList, " → ", activeCount, " active, disconnected=", isDisc,
          " → ", classification];
    , {k, Length[masters]}
  ]
  , {i, Length[basisLoad["Bases"]]}
];

(* Also check: what are the leading poles of each master value? *)
Print[""];
Print["=== Master value leading poles ==="];
masterVals = A22TwoLoopTreeMasterCoefficientRules[];
Do[
  sym = masterVals[[i, 1]];
  val = masterVals[[i, 2]];
  s = Normal[Series[val /. {d -> 4 - 2 eps, q2 -> 1}, {eps, 0, -4}]];
  Print["  ", sym, " starts at: ", s // FullSimplify];
  , {i, Length[masterVals]}
];
