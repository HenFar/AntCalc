(* Fresh-kernel advisor-facing API contract regression.

   This script deliberately loads the installed AntCalc paclet rather than the
   checkout entry point.  Run it only after installing/reinstalling the paclet
   from the intended source tree, in a new kernel.  It exercises the exact
   three public calls used in the advisor-facing contract. *)

<<AntCalc`

ClearAll[MasterCombinationAvailableQ, A31FiniteEpsilonTermQ];

MasterCombinationAvailableQ[value_] := !MissingQ[value] && value =!= $Failed;

A31FiniteEpsilonTermQ[expression_] :=
  Module[{eps = FeynCalc`Epsilon, series, finiteCoefficient},
    series = Quiet[Check[Normal[Series[expression, {eps, 0, 0}]], $Failed]];
    If[series === $Failed,
      Return[False]
    ];
    finiteCoefficient = Collect[Coefficient[series, eps, 0], eps];
    finiteCoefficient =!= 0
  ];

c40Record = BuildAndIntegrateAntenna[C, 4, 0,
  ReturnRecord -> True,
  UseStoredResults -> False,
  StoreResults -> False
];
c40MasterCombination = c40Record["MasterCombination"];

a31Result = BuildAndIntegrateAntenna[A, 3, 1,
  UseStoredResults -> False,
  StoreResults -> False
];

a22Record = BuildAndIntegrateAntenna[A, 2, 2,
  ReturnRecord -> True,
  UseStoredResults -> False,
  StoreResults -> False
];
a22MasterCombination = a22Record["MasterCombination"];
expectedA22Components = {"Leading", "Subleading", "Nf", "Breve"};

report = <|
  "Regression" -> "AdvisorAPIContract",
  "PacletPublicSymbolsAvailableQ" ->
    And @@ (NameQ /@ {"BuildAndIntegrateAntenna", "AntennaRunRecordQ"}),
  "C40RecordReturnedQ" -> AntennaRunRecordQ[c40Record],
  "C40MasterCombinationAvailableQ" ->
    MasterCombinationAvailableQ[c40MasterCombination],
  "C40MasterCombinationContainsLiteRedMastersQ" ->
    MasterCombinationAvailableQ[c40MasterCombination] &&
      !FreeQ[c40MasterCombination, _LiteRed`j],
  "A31PublicResultHasThreeComponentsQ" ->
    ListQ[a31Result] && Length[a31Result] === 3,
  "A31DefaultResultIncludesFiniteEpsilonTermQ" ->
    ListQ[a31Result] && AnyTrue[a31Result, A31FiniteEpsilonTermQ],
  "A22RecordReturnedQ" -> AntennaRunRecordQ[a22Record],
  "A22MasterCombinationAssociationQ" -> AssociationQ[a22MasterCombination],
  "A22ExpectedMasterComponentsPresentQ" ->
    AssociationQ[a22MasterCombination] &&
      ContainsAll[Keys[a22MasterCombination], expectedA22Components],
  "A22NoComponentMasterMissingQ" ->
    AssociationQ[a22MasterCombination] &&
      AllTrue[Values[a22MasterCombination], MasterCombinationAvailableQ]
|>;

report["Passed"] = And @@ Values[KeyDrop[report, "Regression"]];
Print[report];
Quit[If[TrueQ[report["Passed"]], 0, 1]];
