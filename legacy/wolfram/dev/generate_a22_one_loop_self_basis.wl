(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

(* ::Package:: *)

(*
  Standalone LiteRed generator for the A22 one-loop self-interference basis.

  This file intentionally does not load AntennaPipeline.wl, FeynCalc, or
  FeynArts.  LiteRed basis generation is context-sensitive, so the safest
  workflow is to generate bases in a clean LiteRed kernel and let the package
  load the saved definitions afterwards.
*)

If[$FrontEnd === Null,
  $FeynCalcStartupMessages = False;
];

Get["LiteRed2`"];

basisRoot =
  FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]],
    "generated_bases", "A22OneLoopSelf"}];

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

Clear[A22OneLoopSelfBasis];

NewDsBasis[
  A22OneLoopSelfBasis,
  {l1, l1 - k1, l1 - q, l2, l2 - k1, l2 - q, l1 - l2},
  {l1, l2},
  Append -> True,
  Directory -> basisRoot
];

GenerateIBP[A22OneLoopSelfBasis];
AnalyzeSectors[A22OneLoopSelfBasis];
FindSymmetries[A22OneLoopSelfBasis];
SolvejSector /@ UniqueSectors[A22OneLoopSelfBasis];
DiskSave[A22OneLoopSelfBasis];

Print["A22OneLoopSelfBasis generated at ", basisRoot];
