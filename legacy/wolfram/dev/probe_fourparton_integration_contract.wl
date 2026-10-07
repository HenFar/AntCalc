(* Fresh-kernel diagnostic probe for the B40/C40 public integration contract.
   It intentionally mirrors the release gate's cache and expansion settings,
   but emits a compact report rather than full antenna expressions. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

ClearAll[caseLabel, key, paperBuild, build, object, direct, oneShot, unpack,
  summary, diagnostics, report];

caseLabel = Environment["ANTCALC_PROBE_CASE"];
If[caseLabel === "", caseLabel = "B40"];
key = Switch[caseLabel,
  "B40", {B, 4, 0},
  "C40", {C, 4, 0},
  _, Print["Unknown case: ", caseLabel]; Quit[64]
];

unpack[value_] := If[MatchQ[value, {_, _Association}], value,
  {value, <|"Failed" -> True, "Reason" -> "MissingDiagnostics"|>}];

summary[value_, diag_Association] := <|
  "ResultHead" -> ToString[Head[value], InputForm],
  "Succeeded" -> (value =!= $Failed),
  "Failed" -> Lookup[diag, "Failed", Missing["NotReported"]],
  "Reason" -> Lookup[diag, "Reason", Missing["NotReported"]],
  "Backend" -> Lookup[diag, "Backend", Missing["NotReported"]],
  "RawIntegratedHead" -> ToString[Head[Lookup[diag, "RawIntegrated",
    Missing["NotReported"]]], InputForm],
  "TTermsHead" -> ToString[Head[Lookup[diag, "TTerms",
    Missing["NotReported"]]], InputForm],
  "FinalIntegratedHead" -> ToString[Head[Lookup[diag, "FinalIntegrated",
    Missing["NotReported"]]], InputForm],
  "DiagnosticKeys" -> Keys[diag]
|>;

(* Match the release worker's call sequence.  The non-integrable paper-check
   build is intentionally retained here: it detects state/call-order defects
   that an isolated integration call would miss. *)
paperBuild = BuildAntenna @@ Join[key, {ReturnDiagnostics -> True,
  RunPaperCheck -> True, UseStoredResults -> False, StoreResults -> False}];

build = BuildAntenna @@ Join[key, {IntegrableForm -> True,
  ReturnDiagnostics -> True, UseStoredResults -> False,
  StoreResults -> False}];
{object, diagnostics} = unpack[build];

If[object === $Failed,
  Print[<|"Case" -> caseLabel, "Build" -> summary[object, diagnostics]|>];
  Quit[1]
];

direct = IntegrateAntenna[object, ReturnDiagnostics -> True,
  ExpansionOrder -> 0, UseStoredResults -> False, StoreResults -> False];
oneShot = BuildAndIntegrateAntenna @@ Join[key, {ReturnDiagnostics -> True,
  ExpansionOrder -> 0, UseStoredResults -> False, StoreResults -> False}];

report = <|"Case" -> caseLabel, "FreshKernel" -> True,
  "UseStoredResults" -> False, "StoreResults" -> False,
  "ExpansionOrder" -> 0,
  "PaperCheckBuild" -> With[{parts = unpack[paperBuild]},
    summary[parts[[1]], parts[[2]]]],
  "Direct" -> With[{parts = unpack[direct]}, summary[parts[[1]], parts[[2]]]],
  "OneShot" -> With[{parts = unpack[oneShot]}, summary[parts[[1]], parts[[2]]]],
  "ResultsSameQ" -> SameQ[First[unpack[direct]], First[unpack[oneShot]]]|>;
Print[report];
Quit[];
