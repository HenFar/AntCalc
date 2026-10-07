(* Development diagnostic: reduce one A22 virtual component over loop momenta
   only. This intentionally stops before integrated master substitution. *)

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

buildData = record["BuildData"];
prototypeComponents = Lookup[
  Lookup[Lookup[buildData, "BuildOutputBoundary", <||>], "Prototype", <||>],
  "Components", <||>
];
publicComponents = Lookup[
  Lookup[Lookup[buildData, "BuildOutputBoundary", <||>], "Public", <||>],
  "Components", <||>
];

prototype = Lookup[prototypeComponents, componentKey, $Failed];
public = Lookup[publicComponents, componentKey, $Failed];
reduction = A22LoopOnlyIBPReduction[prototype, Contribution -> TwoLoopTree];

report = <|
  "Component" -> requestedComponent,
  "BuildSucceeded" -> (prototype =!= $Failed && public =!= $Failed),
  "PublicSkinPresentQ" -> TrueQ[public =!= prototype],
  "PrototypeLeafCount" -> If[prototype === $Failed, Missing["NotAvailable"],
    LeafCount[prototype]],
  "PublicLeafCount" -> If[public === $Failed, Missing["NotAvailable"],
    LeafCount[public]],
  "Reduction" -> reduction
|>;

summary = <|
  "Component" -> report["Component"],
  "BuildSucceeded" -> report["BuildSucceeded"],
  "PublicSkinPresentQ" -> report["PublicSkinPresentQ"],
  "PrototypeLeafCount" -> report["PrototypeLeafCount"],
  "PublicLeafCount" -> report["PublicLeafCount"],
  "ReductionSucceeded" -> Lookup[reduction, "Succeeded", False],
  "UnmatchedCount" -> Lookup[reduction, "UnmatchedCount", Missing["NotAvailable"]],
  "InputLeafCount" -> Lookup[reduction, "InputLeafCount", Missing["NotAvailable"]],
  "CompactMasterCombinationLeafCount" -> Lookup[reduction,
    "CompactMasterCombinationLeafCount", Missing["NotAvailable"]],
  "CompactReconstructionQ" -> Lookup[reduction,
    "CompactReconstructionQ", Missing["NotAvailable"]],
  "MasterLabels" -> Lookup[reduction, "MasterLabels", {}],
  "MasterCoefficientLeafCounts" -> Lookup[reduction,
    "MasterCoefficientLeafCounts", <||>],
  "RawMasterRepresentativeCounts" -> Map[Length,
    Lookup[reduction, "RawMasterCatalogue", <||>]],
  "CompactMasterCombination" -> Lookup[reduction,
    "CompactMasterCombination", Missing["NotAvailable"]],
  "PublicCompactMasterCombination" -> Lookup[reduction,
    "PublicCompactMasterCombination", Missing["NotAvailable"]]
|>;

Print[summary];

If[TrueQ[Lookup[reduction, "Succeeded", False]] &&
    TrueQ[Lookup[reduction, "CompactReconstructionQ", False]],
  Quit[0],
  Quit[1]
];
