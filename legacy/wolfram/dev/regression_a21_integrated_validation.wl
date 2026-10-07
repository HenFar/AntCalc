(* Fresh-kernel regression: the A21 literature diagnostic must compare a
   public epsilon-truncated result with the target at the same order. *)

If[!ValueQ[$AntennaPipelineRoot],
  Get[FileNameJoin[{DirectoryName[$InputFileName], "..",
      "AntennaPipeline.wl"}]]
];

ClearAll[object, direct, wrapped, directResult, wrappedResult,
  directDiagnostics, wrappedDiagnostics, report];

object = BuildAntenna[A, 2, 1,
  IntegrableForm -> True,
  UseStoredResults -> False,
  StoreResults -> False];

direct = IntegrateAntenna[object,
  ReturnDiagnostics -> True,
  ExpansionOrder -> 0,
  UseStoredResults -> False,
  StoreResults -> False];

wrapped = BuildAndIntegrateAntenna[A, 2, 1,
  ReturnDiagnostics -> True,
  ExpansionOrder -> 0,
  UseStoredResults -> False,
  StoreResults -> False];

{directResult, directDiagnostics} = direct;
{wrappedResult, wrappedDiagnostics} = wrapped;

report = <|
  "Regression" -> "A21IntegratedValidationExpansionOrder",
  "Checks" -> <|
    "DirectA21IntegratedResidualIsZeroAtRequestedOrder" ->
      TrueQ[Lookup[directDiagnostics, "IntegratedResidualIsZero", False]],
    "WrapperA21IntegratedResidualIsZeroAtRequestedOrder" ->
      TrueQ[Lookup[wrappedDiagnostics, "IntegratedResidualIsZero", False]],
    "DirectAndWrapperA21ResultsMatch" ->
      TrueQ[Together[directResult - wrappedResult] === 0]
    |>
  |>;
report = Join[report, <|"Passed" -> And @@ Values[report["Checks"]]|>];
Print[report];
