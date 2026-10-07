(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

(* runComponent: Script-local helper for this development or benchmarking utility. *)
runComponent[component_] := Module[{res, diag, eps},
  eps = FeynCalc`Epsilon;
  Print["\n========================================"];
  Print["Integrating component: ", component];
  
  {res, diag} = IntegrateAntenna[A, 2, 2,
    Contribution -> TwoLoopTree, Component -> component,
    ReturnDiagnostics -> True, ExpansionOrder -> 0
  ];
  
  Print["Raw Integrated: ", diag["RawIntegrated"]];
  Print["TTerms: ", diag["TTerms"]];
  Print["TTerm Residual: ", diag["TTermResiduals"]];
  Print["Is Zero: ", diag["TTermResidualIsZero"]];
];

runComponent[Leading];
runComponent[Subleading];

Quit[];
