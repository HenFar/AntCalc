(* Focused fresh-kernel diagnostic for the A22 public-integration residual
   contract.  Run one component at a time, for example:

     ANTCALC_A22_COMPONENT=Leading wolframscript -file \
     dev/diagnostics/a22/diagnose_a22_release_residuals.wl

   It deliberately uses the same public BuildAndIntegrateAntenna path as the
   release acceptance worker and prints only the target comparisons needed to
   explain a failing release check. *)

repoRoot = Nest[DirectoryName, $InputFileName, 4];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

componentName = Environment["ANTCALC_A22_COMPONENT"];
component = Switch[componentName,
  "Leading", Leading,
  "Subleading", Subleading,
  "Nf", Nf,
  "Breve", Breve,
  _, Print["Set ANTCALC_A22_COMPONENT to Leading, Subleading, Nf, or Breve."]; Exit[2]
];

{result, diagnostics} = BuildAndIntegrateAntenna[
  A, 2, 2,
  Component -> component,
  ExpansionOrder -> 0,
  ReturnDiagnostics -> True,
  UseStoredResults -> False,
  StoreResults -> False
];

Print["Component: ", componentName];
Print["Result: ", InputForm[result]];
Print["TTerm residual: ", InputForm[Lookup[diagnostics, "TTermResiduals", Missing["Absent"]]]];
Print["TTerm residual is zero: ", Lookup[diagnostics, "TTermResidualIsZero", Missing["Absent"]]];
Print["Integrated residual: ", InputForm[Lookup[diagnostics, "IntegratedAntennaResiduals", Missing["Absent"]]]];
Print["Integrated residual is zero: ", Lookup[diagnostics, "IntegratedAntennaResidualIsZero", Missing["Absent"]]];
Print["Raw integrated: ", InputForm[Lookup[diagnostics, "RawIntegrated", Missing["Absent"]]]];
Print["TTerms: ", InputForm[Lookup[diagnostics, "TTerms", Missing["Absent"]]]];

Exit[If[result === $Failed, 1, 0]];
