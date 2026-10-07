(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

(* Extractor for vector inside sp[v, v] *)
(* getVector: Script-local helper for this development or benchmarking utility. *)
getVector[sp[v_, _]] := v;
(* getVector: Script-local helper for this development or benchmarking utility. *)
getVector[v_] := v;

(* Robust scalar product simplifier *)
(* simplifySp: Script-local helper for this development or benchmarking utility. *)
simplifySp[expr_] := expr // Expand /. {
  sp[x_ + y_, z_] :> sp[x, z] + sp[y, z],
  sp[x_, y_ + z_] :> sp[x, y] + sp[x, z],
  sp[a_ * x_, y_] :> a * sp[x, y],
  sp[x_, a_ * y_] :> a * sp[x, y],
  sp[0, _] -> 0,
  sp[_, 0] -> 0
} /. {
  sp[k1, k1] -> 0,
  sp[q, q] -> q2,
  sp[k1, q] -> q2/2,
  sp[q, k1] -> q2/2
} // Simplify;

(* Refined master values including kinematic scaling factors *)
(* refinedA22LOMI: Script-local helper for this development or benchmarking utility. *)
refinedA22LOMI[p1sq_, p2sq_] := Module[{val},
  val = A22TwoLoopTreeMasterValueA22LO[];
  (* scale is (p1sq * p2sq)^(-eps) *)
  val * (p1sq * p2sq / q2^2)^(-eps)
];

(* refinedA3MI: Script-local helper for this development or benchmarking utility. *)
refinedA3MI[Qsq_] := Module[{val},
  val = A22TwoLoopTreeMasterValueA3[];
  (* scale is (Qsq)^(1 - 2 eps) *)
  val * (Qsq / q2)^(1 - 2 eps)
];

(* refinedA4MI: Script-local helper for this development or benchmarking utility. *)
refinedA4MI[Qsq_] := Module[{val},
  val = A22TwoLoopTreeMasterValueA4[];
  (* scale is (Qsq)^(-2 eps) *)
  val * (Qsq / q2)^(-2 eps)
];

(* refinedA6MI: Script-local helper for this development or benchmarking utility. *)
refinedA6MI[Qsq_] := Module[{val},
  val = A22TwoLoopTreeMasterValueA6[];
  (* scale is (Qsq)^(-2 - 2 eps) *)
  val * (Qsq / q2)^(-2 - 2 eps)
];

(* Automatic master identifier and scaler *)
(* A22TwoLoopTreeRefinedMasterRules: Script-local helper for this development or benchmarking utility. *)
A22TwoLoopTreeRefinedMasterRules[basis_] := Module[{masters, rules},
  masters = LiteRed`MIs[basis];
  rules = Table[
    Module[{indices, activeDens, activeCount, l1Dens, l2Dens, mixedDens, p1sq, p2sq, extMom, val},
      indices = List @@ master // Rest;
      activeDens = Pick[LiteRed`Ds[basis], indices, _?(# > 0 &)];
      activeCount = Length[activeDens];
      
      l1Dens = Select[activeDens, MemberQ[Cases[#, l1, Infinity], l1] && FreeQ[#, l2] &];
      l2Dens = Select[activeDens, MemberQ[Cases[#, l2, Infinity], l2] && FreeQ[#, l1] &];
      mixedDens = Select[activeDens, MemberQ[Cases[#, l1, Infinity], l1] && MemberQ[Cases[#, l2, Infinity], l2] &];
      
      val = Which[
        activeCount == 3,
          (* Sunset *)
          v1 = If[Length[l1Dens] == 1, getVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
          v2 = If[Length[l2Dens] == 1, getVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
          v3 = If[Length[mixedDens] == 1, getVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
          Q = (v3 - v1 - v2) // Simplify;
          QsqVal = simplifySp[sp[Q, Q]];
          If[QsqVal === 0, 0, refinedA3MI[QsqVal]]
        ,
        A22DisconnectedBubbleMasterQ[activeDens],
          (* Disconnected Bubble *)
          u1 = getVector[l1Dens[[1]]] /. {l1 -> 0};
          u2 = getVector[l1Dens[[2]]] /. {l1 -> 0};
          p1 = (u2 - u1) // Simplify;
          w1 = getVector[l2Dens[[1]]] /. {l2 -> 0};
          w2 = getVector[l2Dens[[2]]] /. {l2 -> 0};
          p2 = (w2 - w1) // Simplify;
          p1sqVal = simplifySp[sp[p1, p1]];
          p2sqVal = simplifySp[sp[p2, p2]];
          If[p1sqVal === 0 || p2sqVal === 0, 0, refinedA22LOMI[p1sqVal, p2sqVal]]
        ,
        activeCount == 4,
          (* Connected 4-prop master *)
          v1 = If[Length[l1Dens] >= 1, getVector[l1Dens[[1]]] /. {l1 -> 0}, 0];
          v2 = If[Length[l2Dens] >= 1, getVector[l2Dens[[1]]] /. {l2 -> 0}, 0];
          v3 = If[Length[mixedDens] >= 1, getVector[mixedDens[[1]]] /. {l1 -> 0, l2 -> 0}, 0];
          Q = (v3 - v1 - v2) // Simplify;
          QsqVal = simplifySp[sp[Q, Q]];
          If[QsqVal === 0, 0, refinedA4MI[QsqVal]]
        ,
        activeCount >= 5,
          (* 5 or 6-prop double box *)
          refinedA6MI[q2]
        ,
        True,
          0
      ];
      master -> val
    ]
    , {master, masters}
  ];
  rules
];

(* Run test for components *)
(* testComponent: Script-local helper for this development or benchmarking utility. *)
testComponent[component_] := Module[{antenna, profile, basisLoad, reduction, rawLiteRed, rawMapped, integrated, tTerms, res},
  Print["\nTesting component: ", component];
  antenna = BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, Component -> component];
  profile = IBPProfile["A22TwoLoopTree"];
  basisLoad = LoadIBPBases[profile];
  
  reduction = ReduceAntennaIBP[antenna, basisLoad["Bases"], profile];
  
  (* Instead of standard mapping, apply our refined mapping *)
  rawReduced = reduction["RawReducedTerms"];
  records = reduction["TermRecords"];
  
  reducedRefined = Table[
    rawReduced[[i]] /. A22TwoLoopTreeRefinedMasterRules[records[[i, "Basis"]]]
    , {i, Length[rawReduced]}
  ];
  
  (* Perform normalization and series expansion *)
  raw = Total[reducedRefined];
  normalized = raw * IBPNormalization[profile] /. {d -> 4 - 2 eps, q2 -> 1} // Together // Simplify;
  
  integrated = Series[normalized, {eps, 0, 0}] // Normal // FullSimplify;
  integratedFC = integrated /. eps -> FeynCalc`Epsilon;
  
  tTerms = IntegratedAntennaTTerms[{A, 2, 2}, integratedFC, ExpansionOrder -> 0, Component -> component];
  res = A22TTermResiduals[tTerms, component, 0];
  
  Print["  integrated: ", integratedFC];
  Print["  t-terms:    ", tTerms];
  Print["  residual:   ", res];
];

testComponent[Nf];
testComponent[Leading];
testComponent[Subleading];

Quit[];
