(*
  One-component acceptance check for normalized A22/A31 master combinations.

  Run this in a fresh Wolfram kernel, once per component:
    $AntennaRegressionFamily = "A22";
    $AntennaRegressionComponent = "Leading";
    Get["/path/to/AntCalc/dev/regression_master_combination_component.wl"]

  A31 results carry one family prefactor in diagnostics.  This script applies
  it once after substituting the runtime master values.  The A22 prefactor is
  unity because the runtime master definitions already use the common real
  spacelike convention.
*)

packageRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{packageRoot, "AntennaPipeline.wl"}]];

familyFromEnvironment = Environment["ANTCALC_MASTER_FAMILY"];
componentFromEnvironment = Environment["ANTCALC_MASTER_COMPONENT"];
familyName = If[StringQ[familyFromEnvironment], familyFromEnvironment,
  If[ValueQ[$AntennaRegressionFamily], $AntennaRegressionFamily, Missing["Unset"]]];
componentName = If[StringQ[componentFromEnvironment], componentFromEnvironment,
  If[ValueQ[$AntennaRegressionComponent], $AntennaRegressionComponent,
    Missing["Unset"]]];
component = Switch[componentName,
  "Leading", Leading,
  "Subleading", Subleading,
  "Nf", Nf,
  "Breve", Breve,
  _, Missing["InvalidComponent", componentName]
];
route = Switch[familyName,
  "A22", {2, 2},
  "A31", {3, 1},
  _, Missing["InvalidFamily", familyName]
];

If[MissingQ[component] || MissingQ[route],
  Print["INPUT_ERROR = ", InputForm[{familyName, componentName}]];
  Abort[]
];

{elapsed, result} = AbsoluteTiming[TimeConstrained[
  BuildAndIntegrateAntenna[A, route[[1]], route[[2]],
    Component -> component,
    ReturnMasterCombination -> True,
    ReturnDiagnostics -> True,
    PrintComponentLegend -> False,
    ExpansionOrder -> 0,
    UseStoredResults -> False,
    StoreResults -> False],
  2700, $TimedOut]];

(* Keep the computed object available for follow-up master substitutions even
   if loading the pipeline changed the notebook's current context. *)
Global`AntennaRegressionMasterCombinationResult = result;

Print["FAMILY = ", familyName];
Print["COMPONENT = ", componentName];
Print["SECONDS = ", elapsed];
Print["STATUS = ", If[result === $TimedOut, "Timed out", Head[result]]];
Print["RESULT_SAVED_GLOBALLY = ",
  ValueQ[Global`AntennaRegressionMasterCombinationResult]];

If[MatchQ[result, {_, _Association}],
  Module[{masterRules, prefactor, substituted, residual, variables, latex,
      scalarSymbols, namedBare, bareResidual, countertermResidual,
      fullResidual, rawIntegrated, tTerms, epsilonRules},
    Print["SELECTED_COMPONENT = ",
      InputForm[Lookup[result[[2]], "BuildComponent", Missing[]]]];
    Print["RAW_MASTER_KEY = ",
      KeyExistsQ[result[[2]], "RawMasterCombination"]];
    Print["BARE_MASTER_KEY = ",
      KeyExistsQ[result[[2]], "BareMasterCombination"]];
    Print["MASTER_FREE_OF_Q2_S12 = ", FreeQ[result[[1]], q2 | s12]];
    scalarSymbols = DeleteDuplicates @ Cases[result[[1]],
      s_Symbol /; MemberQ[{"B0", "C0"},
        SymbolName[Unevaluated[s]]], Infinity];
    Print["MASTER_SCALAR_CONTEXTS = ",
      InputForm[DeleteDuplicates[Context /@ scalarSymbols]]];
    Print["NO_FEYNCALC_SCALARS = ",
      FreeQ[result[[1]], FeynCalc`B0 | FeynCalc`C0]];
    Print["FAMILY_PREFACTOR = ",
      InputForm[Lookup[result[[2]], "FamilyPrefactor",
        Lookup[result[[2]], "MasterCombinationPrefactor", Missing[]]]]];
    Print["MASTER_CONVENTION = ", InputForm[Lookup[result[[2]],
      "MasterCombinationConvention", Missing[]]]];
    masterRules = If[familyName === "A22",
      A22PublicMasterValueRules[], A31PublicMasterValueRules[]];
    epsilonRules = {eps -> Epsilon, FeynCalc`Epsilon -> Epsilon,
      q2 -> 1, s12 -> 1};
    prefactor = Lookup[result[[2]], "FamilyPrefactor",
      Lookup[result[[2]], "MasterCombinationPrefactor",
        Missing["NoFamilyPrefactor"]]];
    Print["FAMILY_PREFACTOR_AVAILABLE = ", !MissingQ[prefactor]];
    namedBare = Lookup[result[[2]], "NamedBareMasterCombination",
      Missing["NoNamedBareMasterCombination"]];
    rawIntegrated = Lookup[result[[2]], "RawIntegrated", Missing["NoRawIntegrated"]];
    tTerms = Lookup[result[[2]], "TTerms", Missing["NoTTerms"]];
    Print["NAMED_BARE_KEY = ", !MissingQ[namedBare]];
    residual = If[MissingQ[prefactor],
      Missing["NoMasterCombinationPrefactor"],
      substituted = prefactor (result[[1]] /. masterRules);
      TimeConstrained[
        FunctionExpand @ FullSimplify[
          Together[Normal[Series[substituted, {Epsilon, 0, 0}]] -
            result[[2, "TTerms"]]]],
        180, $TimedOut]
    ];
    Print["RESIDUAL_THROUGH_EPS0 = ", InputForm[residual]];
    Print["RESIDUAL_IS_ZERO = ", TrueQ[residual === 0]];
    If[!MissingQ[prefactor] && !MissingQ[namedBare] &&
        !MissingQ[rawIntegrated] && !MissingQ[tTerms],
      bareResidual = TimeConstrained[
        FunctionExpand @ FullSimplify[Together[
          Normal[Series[prefactor (namedBare /. masterRules),
            {Epsilon, 0, 0}]] -
          Normal[Series[rawIntegrated /. epsilonRules,
            {Epsilon, 0, 0}]]]],
        120, $TimedOut];
      countertermResidual = TimeConstrained[
        FunctionExpand @ FullSimplify[Together[
          Normal[Series[prefactor ((result[[1]] - namedBare) /.
              masterRules), {Epsilon, 0, 0}]] -
          Normal[Series[(tTerms - rawIntegrated) /. epsilonRules,
            {Epsilon, 0, 0}]]]],
        120, $TimedOut];
      fullResidual = TimeConstrained[
        FunctionExpand @ FullSimplify[Together[
          Normal[Series[prefactor (result[[1]] /. masterRules),
            {Epsilon, 0, 0}]] -
          Normal[Series[tTerms /. epsilonRules, {Epsilon, 0, 0}]]]],
        120, $TimedOut];
      Print["BARE_MINUS_RAW_THROUGH_EPS0 = ", InputForm[bareResidual]];
      Print["COUNTERTERM_MINUS_TTERM_DELTA_THROUGH_EPS0 = ",
        InputForm[countertermResidual]];
      Print["WHOLE_MINUS_TTERMS_THROUGH_EPS0 = ", InputForm[fullResidual]]
    ];
    Print["INTEGRATED_TARGET_RESIDUALS = ", InputForm[Lookup[
      result[[2]], "IntegratedTargetComparisonResiduals", Missing["Unavailable"]]]];
    If[familyName === "A31" && componentName === "Nf",
      Module[{lowerData, lowerResidual},
        lowerData = CouplingCountertermMasterData[{A, 3, 1}, Nf];
        lowerResidual = TimeConstrained[
          FullSimplify[Together[result[[1]] -
            lowerData["Coefficient"] lowerData["LowerMasterCombination"]]],
          120, $TimedOut];
        Print["A31_NF_EQUALS_A30_OVER_3EPS = ",
          TrueQ[lowerResidual === 0]];
        Print["A31_NF_A30_RESIDUAL = ", InputForm[lowerResidual]]
      ]
    ];
    variables = If[familyName === "A22",
      PublicNamedMasterVariables["A22"], PublicNamedMasterVariables["A31"]];
    latex = ToString[TeXForm[Collect[result[[1]], variables, Simplify]]];
    Print["MASTER_COMBINATION_INPUTFORM = ", InputForm[result[[1]]]];
    Print["MASTER_COMBINATION_LATEX = ", latex]
  ]
];
