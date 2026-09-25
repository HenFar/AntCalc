(*
  Family-wide convention regression for the seven public A22/A31 master
  combinations.  This is intentionally an explicit component-by-component
  test: it guards against a Component -> X request returning another
  component's combination.

  Run in a fresh Wolfram kernel with:
    Get["/path/to/AntCalc/dev/regression_master_combination_family_conventions.wl"]

  The test performs the existing build and integration routes.  A31
  Subleading can take several minutes.  It prints each returned combination
  in InputForm and TeXForm after checking its public structure and its
  master-substituted T-term series through epsilon^0.
*)

packageRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{packageRoot, "AntennaPipeline.wl"}]];

ClearAll[AntennaFamilyRegressionNamedJCalls,
  AntennaFamilyRegressionScaleSymbols,
  AntennaFamilyRegressionNoA31PrefactorPiecesQ,
  AntennaFamilyRegressionExpectedPrefactor,
  AntennaFamilyRegressionRunCase,
  AntennaFamilyRegressionStructuralPassQ,
  AntennaFamilyRegressionT1PassQ];

AntennaFamilyRegressionNamedJCalls[expr_] :=
  Cases[expr,
    head_Symbol[___] /; SymbolName[Unevaluated[head]] === "j",
    Infinity];

AntennaFamilyRegressionScaleSymbols[expr_] :=
  DeleteDuplicates @ Cases[expr,
    symbol_Symbol /; MemberQ[{"q2", "s12"},
      SymbolName[Unevaluated[symbol]]], Infinity];

(* Gamma[2 - 2 Epsilon] can occur intrinsically in the A22 Breve master
   coefficient, so the A31-specific signature is checked on A31 expressions.
   The exponential and power signatures are checked for every component. *)
AntennaFamilyRegressionNoA31PrefactorPiecesQ[expr_, family_] :=
  Module[{commonPieces, a31Pieces},
    commonPieces =
      HoldPattern[8^(3 - 2 Epsilon)] |
      HoldPattern[2^(10 - 6 Epsilon)] |
      HoldPattern[E^(2 Epsilon EulerGamma)] |
      HoldPattern[Pi^(7 - 3 Epsilon)];
    a31Pieces = commonPieces | HoldPattern[Gamma[2 - 2 Epsilon]];
    FreeQ[expr, commonPieces] &&
      (family =!= "A31" || FreeQ[expr, a31Pieces])
  ];

AntennaFamilyRegressionExpectedPrefactor["A22"] := 1;
AntennaFamilyRegressionExpectedPrefactor["A31"] :=
  A31MasterCombinationPrefactor[];

AntennaFamilyRegressionRunCase[case_Association] :=
  Module[{family, label, key, component, elapsed, result, expression,
      diagnostics, prefactor, expectedPrefactor, masterRules, epsilonRules,
      tTerms, mappedTTerms, residual, structural, tex},
    family = case["Family"];
    label = case["Label"];
    key = case["Key"];
    component = case["Component"];
    {elapsed, result} = AbsoluteTiming[TimeConstrained[
      BuildAndIntegrateAntenna @@ Join[key, {
        Component -> component,
        ReturnMasterCombination -> True,
        ReturnDiagnostics -> True,
        PrintComponentLegend -> False,
        ExpansionOrder -> 0,
        UseStoredResults -> False,
        StoreResults -> False
      }], 2700, $TimedOut]];
    Print["CASE = ", family, " / ", label];
    Print["SECONDS = ", elapsed];
    If[!MatchQ[result, {_, _Association}],
      Print["STATUS = ", If[result === $TimedOut, "Timed out", InputForm[result]]];
      Return[<|"Status" -> If[result === $TimedOut, "TimedOut", "Failed"],
        "Result" -> result|>]
    ];
    expression = result[[1]];
    diagnostics = result[[2]];
    prefactor = Lookup[diagnostics, "FamilyPrefactor",
      Lookup[diagnostics, "MasterCombinationPrefactor", Missing["NoFamilyPrefactor"]]];
    expectedPrefactor = AntennaFamilyRegressionExpectedPrefactor[family];
    epsilonRules = {d -> 4 - 2 Epsilon, eps -> Epsilon,
      FeynCalc`Epsilon -> Epsilon, q2 -> 1, s12 -> 1};
    masterRules = If[family === "A22",
      A22PublicMasterValueRules[], A31PublicMasterValueRules[]];
    tTerms = Lookup[diagnostics, "TTerms", Missing["NoTTerms"]];
    mappedTTerms = If[MissingQ[tTerms], tTerms, tTerms /. epsilonRules];
    structural = <|
      "CorrectComponent" ->
        (CanonicalAntennaComponentName[
          Lookup[diagnostics, "BuildComponent", Missing["NoComponent"]]] === label),
      "ScaleFree" -> (AntennaFamilyRegressionScaleSymbols[expression] === {}),
      "NoLiteRedMasters" ->
        (AntennaFamilyRegressionNamedJCalls[expression] === {}),
      "NoEmbeddedFamilyPrefactorPieces" ->
        TrueQ[AntennaFamilyRegressionNoA31PrefactorPiecesQ[expression, family]],
      "FamilyPrefactorMatches" ->
        TrueQ[FullSimplify[prefactor - expectedPrefactor] === 0]
    |>;
    residual = If[MissingQ[tTerms] || MissingQ[prefactor],
      Missing["NoTTermsOrFamilyPrefactor"],
      TimeConstrained[
        FunctionExpand @ FullSimplify[Together[
          Normal[Series[prefactor (expression /. masterRules),
            {Epsilon, 0, 0}]] -
          Normal[Series[mappedTTerms, {Epsilon, 0, 0}]]]],
        240, $TimedOut]
    ];
    tex = ToString[TeXForm[expression]];
    Print["SELECTED_COMPONENT = ",
      InputForm[Lookup[diagnostics, "BuildComponent", Missing[]]]];
    Print["FAMILY_PREFACTOR = ", InputForm[prefactor]];
    Print["STRUCTURAL_CHECKS = ", InputForm[structural]];
    Print["T1_RESIDUAL_THROUGH_EPS0 = ", InputForm[residual]];
    Print["INPUTFORM = ", InputForm[expression]];
    Print["TEXFORM = ", tex];
    <|"Status" -> "Complete", "Seconds" -> elapsed,
      "Expression" -> expression, "FamilyPrefactor" -> prefactor,
      "StructuralChecks" -> structural, "T1Residual" -> residual,
      "TeXForm" -> tex,
      "SelectedComponent" -> Lookup[diagnostics, "BuildComponent", Missing[]]|>
  ];

AntennaFamilyRegressionStructuralPassQ[entry_] :=
  AssociationQ[entry] && Lookup[entry, "Status", "Failed"] === "Complete" &&
    (And @@ Values[Lookup[entry, "StructuralChecks", <||>]]);

AntennaFamilyRegressionT1PassQ[entry_] :=
  AssociationQ[entry] && Lookup[entry, "Status", "Failed"] === "Complete" &&
    TrueQ[Lookup[entry, "T1Residual", Missing[]] === 0];

Global`AntennaMasterConventionRegressionResults = <||>;
Do[
  AssociateTo[Global`AntennaMasterConventionRegressionResults,
    case["Family"] <> "/" <> case["Label"] ->
      AntennaFamilyRegressionRunCase[case]],
  {case, {
    <|"Family" -> "A22", "Label" -> "Leading", "Key" -> {A, 2, 2},
      "Component" -> Leading|>,
    <|"Family" -> "A22", "Label" -> "Subleading", "Key" -> {A, 2, 2},
      "Component" -> Subleading|>,
    <|"Family" -> "A22", "Label" -> "Nf", "Key" -> {A, 2, 2},
      "Component" -> Nf|>,
    <|"Family" -> "A22", "Label" -> "Breve", "Key" -> {A, 2, 2},
      "Component" -> Breve|>,
    <|"Family" -> "A31", "Label" -> "Leading", "Key" -> {A, 3, 1},
      "Component" -> Leading|>,
    <|"Family" -> "A31", "Label" -> "Subleading", "Key" -> {A, 3, 1},
      "Component" -> Subleading|>,
    <|"Family" -> "A31", "Label" -> "Nf", "Key" -> {A, 3, 1},
      "Component" -> Nf|>
  }}
];

Print["ALL_CASES_FINISHED = ",
  Length[Global`AntennaMasterConventionRegressionResults] === 7];
Print["ALL_STRUCTURAL_CHECKS_PASS = ",
  Length[Global`AntennaMasterConventionRegressionResults] === 7 &&
    AllTrue[Values[Global`AntennaMasterConventionRegressionResults],
      AntennaFamilyRegressionStructuralPassQ]];
Print["ALL_T1_RESIDUALS_ZERO = ",
  Length[Global`AntennaMasterConventionRegressionResults] === 7 &&
    AllTrue[Values[Global`AntennaMasterConventionRegressionResults],
      AntennaFamilyRegressionT1PassQ]];
Null;
