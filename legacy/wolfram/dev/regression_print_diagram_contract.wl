(* Regression: PrintDiagramContract
   --------------------------------
   Manual fresh-kernel visual regression for the public BuildAntenna option.
   The checks are deliberately split by source kind: tree routes must render
   despite AntennaAmplitude memoization, while loop routes must render their
   generated loop source.  The calls return their ordinary antenna result. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "AntennaPipeline.wl"}]];

Print["Expected visible output: one tree diagram cell for A30."];
a30 = BuildAntenna[A, 3, 0, printDiagram -> True,
  UseStoredResults -> False, StoreResults -> False];

Print["Expected visible output: tree and one-loop diagram cells for A31."];
a31 = BuildAntenna[A, 3, 1, printDiagram -> True,
  UseStoredResults -> False, StoreResults -> False];

<|"Regression" -> "PrintDiagramContract",
  "Checks" -> <|
    "A30ReturnedResult" -> FreeQ[a30, $Failed],
    "A31ReturnedResult" -> FreeQ[a31, $Failed]
  |>,
  "Note" -> "Visual acceptance: the labelled tree diagram output must be present for A30, and both tree and loop diagram output for A31."|>
