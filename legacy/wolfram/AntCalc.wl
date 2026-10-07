(* ::Package:: *)
(* AntCalc paclet loader.

   This first paclet boundary deliberately evaluates the established runtime
   unchanged. The FeynArts/FeynCalc backend currently relies on its legacy
   Global` state, so moving its implementation symbols into AntCalc` requires
   a separate context-isolation migration and route regression suite. *)

If[!NameQ["Global`BuildAntenna"],
  Block[{$Context = "Global`"},
    Get[FileNameJoin[{DirectoryName[$InputFileName], "AntennaPipeline.wl"}]]
  ]
];
