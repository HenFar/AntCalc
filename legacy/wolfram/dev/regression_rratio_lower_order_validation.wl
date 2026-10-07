(* Fresh-kernel regression for the lower-order SMQCD R-ratio reference targets.
   The comparison uses the computed antenna-assembled form, never the explicit
   reference-result form. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

ClearAll[lo, nlo, unpack, report];

unpack[value_] := If[MatchQ[value, {_, _Association}], value,
  {value, <||>}];

lo = unpack[BuildRRatio[SMQCD, quarkMass -> 0, maxOrder -> LO,
  ReturnDiagnostics -> True, UseStoredResults -> False, StoreResults -> False]];
nlo = unpack[BuildRRatio[SMQCD, quarkMass -> 0, maxOrder -> NLO,
  ReturnDiagnostics -> True, UseStoredResults -> False, StoreResults -> False]];

report = <|
  "Regression" -> "RRatioLowerOrderReferenceValidation",
  "Checks" -> <|
    "LOComputedResultReturned" -> (lo[[1]] =!= $Failed),
    "LOReferenceAgreementQ" -> TrueQ[Lookup[lo[[2]], "ReferenceAgreementQ", False]],
    "NLOComputedResultReturned" -> (nlo[[1]] =!= $Failed),
    "NLOReferenceAgreementQ" -> TrueQ[Lookup[nlo[[2]], "ReferenceAgreementQ", False]]
    |>
  |>;
report = Join[report, <|"Passed" -> And @@ Values[report["Checks"]]|>];
Print[report];
Quit[];
