(* Development diagnostic: emit the full LiteRed representatives behind one
   A22 loop-only reduction.  This deliberately preserves dots and numerator
   slots that the compact topology labels hide. *)

projectRoot = Nest[DirectoryName, $InputFileName, 4];
Get[FileNameJoin[{projectRoot, "AntennaPipeline.wl"}]];

requestedComponent = SelectFirst[
  $ScriptCommandLine,
  MemberQ[{"Leading", "Subleading", "Nf"}, #] &,
  "Leading"
];
{component, componentKey} = Switch[requestedComponent,
  "Leading", {Leading, "Lead"},
  "Subleading", {Subleading, "SubLead"},
  "Nf", {Nf, "QuarkLoop"}
];

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
catalogue = Lookup[reduction, "RawMasterCatalogue", <||>];

report = <|
  "Component" -> requestedComponent,
  "BuildSucceeded" -> (prototype =!= $Failed),
  "ReductionSucceeded" -> Lookup[reduction, "Succeeded", False],
  "UnmatchedCount" -> Lookup[reduction, "UnmatchedCount", Missing["NotAvailable"]],
  "MasterRepresentativeCounts" -> Map[Length, catalogue],
  "RawMasterCatalogue" -> catalogue
|>;

Print[report];

If[TrueQ[Lookup[reduction, "Succeeded", False]], Quit[0], Quit[1]];
