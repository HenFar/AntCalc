(* Development audit: compare the existing A22 loop-only master substitution
   with the canonical scalar-integral choice that identifies all four-line
   representatives with A4.  This is diagnostic-only and does not alter the
   integrated route. *)

projectRoot = Nest[DirectoryName, $InputFileName, 4];
Get[FileNameJoin[{projectRoot, "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

currentRules = (# -> A22TwoLoopTreeValueForExactTopology[#]) & /@
  A22TwoLoopTreeExactTopologyLabels[];
canonicalRules = currentRules /. {
  HoldPattern[Rule[A22A4Basis7LikeMI, _]] :>
    (A22A4Basis7LikeMI -> A22TwoLoopTreeMasterValueA4[]),
  HoldPattern[Rule[A22A4Basis8LikeMI, _]] :>
    (A22A4Basis8LikeMI -> A22TwoLoopTreeMasterValueA4[])
};

toSeries[expr_, order_:2] :=
  Normal[Series[
    expr /. {d -> 4 - 2 eps, q2 -> 1},
    {eps, 0, order}
  ]] // FunctionExpand // FullSimplify;

componentReport[component_, componentKey_] :=
  Module[{record, prototypeComponents, prototype, reduction, compact,
     current, canonical, difference},
    record = BuildAntenna[
      A, 2, 2,
      Component -> component,
      ReturnRecord -> True,
      UseStoredResults -> False,
      StoreResults -> False,
      RefreshStoredResults -> False
    ];
    prototypeComponents = Lookup[
      Lookup[
        Lookup[record["BuildData"], "BuildOutputBoundary", <||>],
        "Prototype", <||>
      ],
      "Components", <||>
    ];
    prototype = Lookup[prototypeComponents, componentKey, $Failed];
    reduction = A22LoopOnlyIBPReduction[prototype, Contribution -> TwoLoopTree];
    compact = Lookup[reduction, "CompactMasterCombination", $Failed];
    current = toSeries[compact /. currentRules];
    canonical = toSeries[compact /. canonicalRules];
    difference = FullSimplify[current - canonical];
    <|
      "ReductionSucceeded" -> Lookup[reduction, "Succeeded", False],
      "UnmatchedCount" -> Lookup[reduction, "UnmatchedCount", Missing["NotAvailable"]],
      "CurrentMinusCanonicalThroughEpsilon2" -> difference,
      "CanonicalMatchesCurrentThroughFiniteQ" ->
        TrueQ[Normal[Series[difference, {eps, 0, 0}]] === 0]
    |>
  ];

report = <|
  "Leading" -> componentReport[Leading, "Lead"],
  "Subleading" -> componentReport[Subleading, "SubLead"]
|>;

Print[report];

If[And @@ (TrueQ[Lookup[#, "ReductionSucceeded", False]] & /@ Values[report]),
  Quit[0],
  Quit[1]
];
