(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(* ::Package:: *)

(*
  Standalone LiteRed generator for the A22 tree/two-loop interference bases.

  This script is intentionally separate from AntennaPipeline.wl.  It should be
  run in a clean kernel with LiteRed only, exactly like the A22 one-loop-self
  basis generator.
*)

If[$FrontEnd === Null,
  $FeynCalcStartupMessages = False;
];

Get["LiteRed2`"];

basisRoot =
  FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]],
    "generated_bases", "A22TwoLoopTree"}];

If[!DirectoryQ[basisRoot],
  CreateDirectory[basisRoot, CreateIntermediateDirectories -> True]
];

SetDim[d];
Declare[{l1, l2, k1, q}, Vector];
Declare[q2, Number];

(* sp: Script-local helper for this development or benchmarking utility. *)
sp[q, q] = q2;
(* sp: Script-local helper for this development or benchmarking utility. *)
sp[k1, k1] = 0;
(* sp: Script-local helper for this development or benchmarking utility. *)
sp[q, k1] = q2 / 2;
(* sp: Script-local helper for this development or benchmarking utility. *)
sp[k1, q] = q2 / 2;

basisSpecs = {
  {A22TwoLoopTreeBasis1,
    {l1, -k1 + l1, l2, l1 - q, -k1 + l1 + l2,
      -l1 + l2 + q, -k1 + l2}},
  {A22TwoLoopTreeBasis2,
    {l1, -k1 + l1, l2, -k1 + l1 + l2, l1 - q,
      -l1 + l2 + q, -k1 + l2}},
  {A22TwoLoopTreeBasis3,
    {l1, -k1 + l1, l2, l1 - q, -l1 + l2 + q,
      -k1 + l1 + l2, -k1 + l2}},
  {A22TwoLoopTreeBasis4,
    {l1, -k1 + l1, l2, l1 - q, k1 + l2 - q,
      l1 + l2 - q, -k1 + l2}},
  {A22TwoLoopTreeBasis5,
    {l1, l2, l1 - q, k1 + l1 - q, -l1 + l2 + q,
      -k1 + l1 + l2, -k1 + l2}},
  {A22TwoLoopTreeBasis6,
    {l1, l2, -k1 + l2, l1 - q, k1 + l1 - q,
      l1 + l2 - q, -k1 + l1 + l2}},
  {A22TwoLoopTreeBasis7,
    {l1, l2, l1 + l2, l2 - q, k1 + l2 - q, l1 + q,
      -k1 + l1}},
  {A22TwoLoopTreeBasis8,
    {l1, l2, -k1 + l2, l1 + l2, l1 + q,
      -k1 + l1 + l2 + q, -k1 + l1}}
};

Do[
  With[{basis = basisSpecs[[i, 1]], denominators = basisSpecs[[i, 2]]},
    Clear[basis];
    NewDsBasis[
      basis,
      denominators,
      {l1, l2},
      Append -> True,
      Directory -> basisRoot
    ];
    GenerateIBP[basis];
    AnalyzeSectors[basis];
    FindSymmetries[basis];
    SolvejSector /@ UniqueSectors[basis];
    DiskSave[basis];
    Print["Generated ", basis, " at ", basisRoot];
  ];
  ,
  {i, Length[basisSpecs]}
];

Print["A22TwoLoopTree bases generated at ", basisRoot];
