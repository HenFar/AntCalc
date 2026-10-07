(* Fresh-kernel public API regression: component-wise integrable objects must
   reproduce the canonical combined A31 integration without cache reuse. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..",
    "AntennaPipeline.wl"}]];

ClearAll[a31Objects, a31Components, a31Integrated, a31Combined,
  a31ZeroQ, a31Report];

a31ZeroQ[expr_] := TrueQ[Simplify[expr] === 0];

a31Objects = BuildAntenna[A, 3, 1,
  IntegrableForm -> True,
  UseStoredResults -> False,
  StoreResults -> False];
a31Components = AntennaComponent /@ a31Objects;
a31Integrated = IntegrateAntenna[#, UseStoredResults -> False,
    StoreResults -> False] & /@ a31Objects;
a31Combined = BuildAndIntegrateAntenna[A, 3, 1,
  UseStoredResults -> False,
  StoreResults -> False];

a31Report = <|
  "Regression" -> "A31IntegrableContract",
  "Checks" -> <|
    "IntegrableFormReturnsThreeObjects" ->
      ListQ[a31Objects] && Length[a31Objects] === 3 &&
        And @@ (AntennaObjectQ /@ a31Objects),
    "CanonicalComponentOrder" ->
      a31Components === {Leading, Subleading, Nf},
    "ComponentIntegrationsMatchCombinedRoute" ->
      ListQ[a31Combined] && Length[a31Combined] === 3 &&
        And @@ MapThread[a31ZeroQ[#1 - #2] &, {a31Integrated, a31Combined}]
    |>
  |>;
a31Report = Join[a31Report,
  <|"Passed" -> And @@ Values[a31Report["Checks"]]|>];
Print[a31Report];
Quit[];
