(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
profile = IBPProfile["A22TwoLoopTree"];
basisLoad = LoadIBPBases[profile];

(* analyzeMaster: Script-local helper for this development or benchmarking utility. *)
analyzeMaster[basis_, master_] := Module[{indexList, activeDens, activeCount, l1Dens, l2Dens, mixedDens, loop1Ext, loop2Ext, totalExt},
  indexList = List @@ master // Rest;
  activeDens = Pick[LiteRed`Ds[basis], indexList, _?(# > 0 &)];
  activeCount = Length[activeDens];
  
  (* Group active denominators *)
  l1Dens = Select[activeDens, MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2] &];
  l2Dens = Select[activeDens, MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1] &];
  mixedDens = Select[activeDens, MemberQ[Cases[#, l1, Infinity], l1] && MemberQ[Cases[#, l2, Infinity], l2] &];
  
  Print["  j", indexList, " -> ", activeCount, " active"];
  Print["    l1 dens:    ", l1Dens];
  Print["    l2 dens:    ", l2Dens];
  Print["    mixed dens: ", mixedDens];
  
  (* If disconnected bubble *)
  If[Length[l1Dens] == 2 && Length[l2Dens] == 2 && Length[mixedDens] == 0,
    (* Bubble 1 momentum squared *)
    p1sq = (l1Dens[[1]] - l1Dens[[2]]) /. {l1 -> 0} // Simplify;
    (* Bubble 2 momentum squared *)
    p2sq = (l2Dens[[1]] - l2Dens[[2]]) /. {l2 -> 0} // Simplify;
    Print["    Type: Disconnected Bubble"];
    Print["    kinematics: p1^2 = ", p1sq, ", p2^2 = ", p2sq];
  ];
  
  (* If sunset *)
  If[Length[l1Dens] == 1 && Length[l2Dens] == 1 && Length[mixedDens] == 1,
    (* External momentum is the flow through the mixed propagator after setting l1=0, l2=0? *)
    extMom = mixedDens[[1]] /. {l1 -> 0, l2 -> 0} // Simplify;
    Print["    Type: Sunset"];
    Print["    kinematics: P^2 = ", extMom];
  ];
  
  Print["---"];
];

Do[
  basis = basisLoad["Bases"][[i]];
  masters = LiteRed`MIs[basis];
  Print["\n=========================================="];
  Print["Basis: ", basis];
  Print["=========================================="];
  Do[
    analyzeMaster[basis, masters[[k]]];
    , {k, Length[masters]}
  ];
  , {i, Length[basisLoad["Bases"]]}
];
Quit[];
