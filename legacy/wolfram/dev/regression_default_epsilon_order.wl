(* Regression: route defaults follow the depth supported by their master data.
   A21/A30 retain terms through epsilon^2; A31, A22, and the shared X40
   four-parton family stop at epsilon^0. *)

projectRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{projectRoot, "AntennaPipeline.wl"}]];

routeKeys = {{A, 2, 1}, {A, 3, 0}, {A, 4, 0}, {B, 4, 0}, {C, 4, 0},
  {A, 3, 1}, {A, 2, 2}};
ibpFamilies = {"X30", "MX30", "X40", "A31", "A22OneLoopSelf",
  "A22TwoLoopTree"};

optionValue[head_, option_] := option /. Options[head];

profileOrders = Association @ Map[
   ToString[#, InputForm] ->
     Lookup[AntennaIntegrationProfile[#], "ExpansionOrder", Missing["Absent"]]&,
   routeKeys
];

ibpOrders = Association @ Map[
   # -> Lookup[IBPProfile[#], "ExpansionOrder", Missing["Absent"]]&,
   ibpFamilies
];

publicOptionOrders = <|
  "IntegrateViaIBP" -> optionValue[IntegrateViaIBP, ExpansionOrder],
  "IntegratedAntennaTTerms" -> optionValue[IntegratedAntennaTTerms, ExpansionOrder],
  "ExtractIntegratedAntenna" -> optionValue[ExtractIntegratedAntenna, ExpansionOrder],
  "BuildAndIntegrateAntennaOrderFromList" ->
    optionValue[BuildAndIntegrateAntennaOrderFromList, ExpansionOrder],
  "BuildAndIntegrateAllAntennae" ->
    optionValue[BuildAndIntegrateAllAntennae, ExpansionOrder]
|>;

expectedProfileOrders = <|
  "{A, 2, 1}" -> 2, "{A, 3, 0}" -> 2,
  "{A, 4, 0}" -> 0, "{B, 4, 0}" -> 0, "{C, 4, 0}" -> 0,
  "{A, 3, 1}" -> 0, "{A, 2, 2}" -> 0
|>;

expectedIBPOrders = <|
  "X30" -> 2, "MX30" -> 2, "X40" -> 0, "A31" -> 0,
  "A22OneLoopSelf" -> 0, "A22TwoLoopTree" -> 0
|>;

expectedPublicOptionOrders = <|
  "IntegrateViaIBP" -> 2, "IntegratedAntennaTTerms" -> 2,
  "ExtractIntegratedAntenna" -> 2,
  "BuildAndIntegrateAntennaOrderFromList" -> Automatic,
  "BuildAndIntegrateAllAntennae" -> Automatic
|>;

report = <|
  "ExpectedIntegrationProfileOrders" -> expectedProfileOrders,
  "IntegrationProfileOrders" -> profileOrders,
  "ExpectedIBPProfileOrders" -> expectedIBPOrders,
  "IBPProfileOrders" -> ibpOrders,
  "ExpectedPublicOptionOrders" -> expectedPublicOptionOrders,
  "PublicOptionOrders" -> publicOptionOrders,
  "Passed" -> And @@ {
    profileOrders === expectedProfileOrders,
    ibpOrders === expectedIBPOrders,
    publicOptionOrders === expectedPublicOptionOrders
  }
|>;

Print[report];
If[TrueQ[report["Passed"]], Quit[0], Quit[1]];
