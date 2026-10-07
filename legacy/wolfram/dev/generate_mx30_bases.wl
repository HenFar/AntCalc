(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(* ::Package:: *)

(*
  Standalone LiteRed generator for the massive A30 reverse-unitarity bases.

  This script intentionally does not load AntennaPipeline.wl.  It follows the
  same clean-kernel workflow as the other basis-generation scripts.
*)

If[$FrontEnd === Null,
  $FeynCalcStartupMessages = False;
];

Get["LiteRed2`"];

basisRoot =
  FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]],
    "generated_bases", "MX30"}];

If[!DirectoryQ[basisRoot],
  CreateDirectory[basisRoot, CreateIntermediateDirectories -> True]
];

SetDim[d];
Declare[{p1, p2, q}, Vector];
Declare[{q2, m2}, Number];

sp[q, q] = q2;

basisSpecs = {
  {MX30Basis123,
    {
      m2 - sp[p1, p1],
      m2 - sp[p2, p2],
      sp[-p1 - p2 + q, -p1 - p2 + q],
      m2 - sp[-p2 + q, -p2 + q],
      m2 - sp[-p1 + q, -p1 + q]
    }},
  {MX30Basis132,
    {
      m2 - sp[p1, p1],
      m2 - sp[p2, p2],
      sp[-p1 - p2 + q, -p1 - p2 + q],
      2 m2 - sp[p1 + p2, p1 + p2],
      m2 - sp[-p1 + q, -p1 + q]
    }},
  {MX30Basis213,
    {
      m2 - sp[p1, p1],
      m2 - sp[p2, p2],
      sp[-p1 - p2 + q, -p1 - p2 + q],
      m2 - sp[-p1 + q, -p1 + q],
      m2 - sp[-p2 + q, -p2 + q]
    }},
  {MX30Basis231,
    {
      m2 - sp[p1, p1],
      m2 - sp[p2, p2],
      sp[-p1 - p2 + q, -p1 - p2 + q],
      2 m2 - sp[p1 + p2, p1 + p2],
      m2 - sp[-p2 + q, -p2 + q]
    }},
  {MX30Basis312,
    {
      m2 - sp[p1, p1],
      m2 - sp[p2, p2],
      sp[-p1 - p2 + q, -p1 - p2 + q],
      m2 - sp[-p1 + q, -p1 + q],
      2 m2 - sp[p1 + p2, p1 + p2]
    }},
  {MX30Basis321,
    {
      m2 - sp[p1, p1],
      m2 - sp[p2, p2],
      sp[-p1 - p2 + q, -p1 - p2 + q],
      m2 - sp[-p2 + q, -p2 + q],
      2 m2 - sp[p1 + p2, p1 + p2]
    }}
};

Do[
  With[{basis = basisSpecs[[i, 1]], denominators = basisSpecs[[i, 2]]},
    Clear[basis];
    NewDsBasis[
      basis,
      denominators,
      {p1, p2},
      CutDs -> {1, 1, 1, 0, 0},
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

Print["MX30 bases generated at ", basisRoot];
