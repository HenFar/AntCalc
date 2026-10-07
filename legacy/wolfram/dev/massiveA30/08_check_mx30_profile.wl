(* Development script: validate the explicit massive-X30 reduction-family data. *)

(* ::Package:: *)

If[!ValueQ[$AntennaPipelineRoot],
  Get[
    FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
      "AntennaPipeline.wl"}]
  ];
];

profile = IBPProfile["MX30"];
topologies = Permutations[{1, 2, 3}];
massSymbol = m2;

sameUpToSignQ[left_, right_] :=
  TrueQ[Simplify[left - right] === 0] || TrueQ[Simplify[left + right] === 0];

phaseSpaceCheck =
  TrueQ[
    profile["PhaseSpace"] === Apply[Times, MX30CutDenominators[]]
  ];

masslessLimitChecks =
  Table[
    And @@ MapThread[
      sameUpToSignQ,
      {
        Simplify[MX30BasisTopologyDenominators[topology, massSymbol] /. massSymbol -> 0],
        X30BasisTopologyDenominators[topology]
      }
    ]
    ,
    {topology, topologies}
  ];

bridgeChecks =
  {
    Simplify[(s12 /. MX30InvariantBridgeRules[massSymbol]) /. massSymbol -> 0] ===
      LiteRed`sp[p1 + p2, p1 + p2],
    Simplify[(s13 /. MX30InvariantBridgeRules[massSymbol]) /. massSymbol -> 0] ===
      LiteRed`sp[-p2 + q, -p2 + q],
    Simplify[(s23 /. MX30InvariantBridgeRules[massSymbol]) /. massSymbol -> 0] ===
      LiteRed`sp[-p1 + q, -p1 + q]
  };

If[
  !phaseSpaceCheck || !And @@ masslessLimitChecks || !And @@ bridgeChecks,
  Print["MX30 profile check failed."];
  Print["Phase space check: ", phaseSpaceCheck];
  Print["Massless limit checks: ", masslessLimitChecks];
  Print["Bridge checks: ", bridgeChecks];
  Exit[1];
];

Print["MX30 profile check passed."];
Print["Topologies: ", topologies];
Print["Cut denominators: ", MX30CutDenominators[massSymbol]];
Print["Invariant bridge: ", MX30InvariantBridgeRules[massSymbol]];
