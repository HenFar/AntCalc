(*
  Regression checks for BuildRRatio result provenance and maxOrder selection.

  Fast default:
    WolframKernel -script dev/regression_rratio_result_forms.wl

  Include the fresh NLO antenna route:
    ANTCALC_RRATIO_SLOW=1 WolframKernel -script dev/regression_rratio_result_forms.wl
*)

packageRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{packageRoot, "AntennaPipeline.wl"}]];

checks = <||>;
computedLO = BuildRRatio[SMQCD, maxOrder -> LO,
  ResultForm -> "ComputedFiniteCoefficient", UseStoredResults -> False,
  StoreResults -> False, ReturnDiagnostics -> True];
rawLO = BuildRRatio[SMQCD, maxOrder -> LO,
  ResultForm -> "RawDimRegSeries", UseStoredResults -> False,
  StoreResults -> False, ReturnDiagnostics -> True];
referenceLO = BuildRRatio[SMQCD, maxOrder -> LO,
  ResultForm -> "ReferenceFiniteMSBar", UseStoredResults -> False,
  StoreResults -> False, ReturnDiagnostics -> True];

checks["LOComputedIsOne"] = MatchQ[computedLO, {1, _Association}];
checks["LORawIsOne"] = MatchQ[rawLO, {1, _Association}];
checks["LOReferenceIsOne"] = MatchQ[referenceLO, {1, _Association}];
checks["LOUsesNoIngredients"] = computedLO[[2, "IncludedIngredients"]] === {};
checks["LOReportsComputedOrigin"] =
  computedLO[[2, "ResultOrigin"]] === "ComputedFromIntegratedIngredients";
checks["ReferenceReportsReferenceOrigin"] =
  referenceLO[[2, "ResultOrigin"]] === "EncodedReferenceTarget";
checks["CacheKeySeparatesOrder"] =
  BuildRRatioStoredResultKey[SMQCD, <|"quarkMass" -> 0,
    "ResultForm" -> "ComputedFiniteCoefficient", "maxOrder" -> LO|>] =!=
  BuildRRatioStoredResultKey[SMQCD, <|"quarkMass" -> 0,
    "ResultForm" -> "ComputedFiniteCoefficient", "maxOrder" -> NLO|>];
checks["CacheKeySeparatesResultForm"] =
  BuildRRatioStoredResultKey[SMQCD, <|"quarkMass" -> 0,
    "ResultForm" -> "ComputedFiniteCoefficient", "maxOrder" -> LO|>] =!=
  BuildRRatioStoredResultKey[SMQCD, <|"quarkMass" -> 0,
    "ResultForm" -> "RawDimRegSeries", "maxOrder" -> LO|>];
checks["InvalidResultFormFails"] = Quiet[
  BuildRRatio[SMQCD, ResultForm -> "NotAResultForm"]] === $Failed;
checks["InvalidMaxOrderFails"] = Quiet[
  BuildRRatio[SMQCD, maxOrder -> "nlo"]] === $Failed;

If[Environment["ANTCALC_RRATIO_SLOW"] === "1",
  rawNLO = BuildRRatio[SMQCD, maxOrder -> NLO,
    ResultForm -> "RawDimRegSeries", UseStoredResults -> False,
    StoreResults -> False, ReturnDiagnostics -> True];
  computedNLO = BuildRRatio[SMQCD, maxOrder -> NLO,
    ResultForm -> "ComputedFiniteCoefficient", UseStoredResults -> False,
    StoreResults -> False, ReturnDiagnostics -> True];
  referenceNLO = BuildRRatio[SMQCD, maxOrder -> NLO,
    ResultForm -> "ReferenceFiniteMSBar", UseStoredResults -> False,
    StoreResults -> False];
  checks["NLOUsesOnlyNLOIngredients"] =
    Sort[rawNLO[[2, "IncludedIngredients"]]] === {"intA21", "intA30"};
  checks["NLOComputedMatchesRawFiniteCoefficient"] =
    TrueQ[FullSimplify[computedNLO[[1]] - RRatioFiniteCoefficient[rawNLO[[1]]]] === 0];
  checks["NLOComputedMatchesReference"] =
    TrueQ[FullSimplify[computedNLO[[1]] - referenceNLO] === 0];
];

Print[ExportString[<|"Regression" -> "BuildRRatioResultForms",
  "Checks" -> checks, "Passed" -> And @@ Values[checks]|>, "JSON", "Compact" -> True]];
Quit[If[And @@ Values[checks], 0, 1]];
