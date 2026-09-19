(* One fresh-kernel measurement for the public massive-A30 route.
   Set ANTCALC_MX30_PUBLIC_BENCHMARK_STAGE to Build, Integrate, or EndToEnd.
   The shell driver starts a new Wolfram kernel for every stage. *)

repoRoot = Nest[DirectoryName, $InputFileName, 4];
stage = Environment["ANTCALC_MX30_PUBLIC_BENCHMARK_STAGE"];

If[!MemberQ[{"Build", "Integrate", "EndToEnd"}, stage],
  Print[ExportString[<|"Status" -> "Failed", "Reason" -> "InvalidStage"|>,
    "RawJSON"]];
  Exit[1]
];

Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

inputObject = If[stage === "Integrate",
  BuildAntenna[A, 3, 0,
    quarkMass -> mQ,
    IntegrableForm -> True,
    UseStoredResults -> False,
    StoreResults -> False],
  None
];
baseline = MaxMemoryUsed[];
{elapsed, value} = AbsoluteTiming[
  Switch[stage,
    "Build",
      BuildAntenna[A, 3, 0,
        quarkMass -> mQ,
        IntegrableForm -> True,
        UseStoredResults -> False,
        StoreResults -> False],
    "Integrate",
      IntegrateAntenna[
        inputObject,
        quarkMass -> mQ,
        ExpansionOrder -> 0,
        ReturnRecord -> True,
        UseStoredResults -> False,
        StoreResults -> False,
        DetailedTimingDiagnostics -> False],
    "EndToEnd",
      BuildAndIntegrateAntenna[A, 3, 0,
        quarkMass -> mQ,
        ExpansionOrder -> 0,
        ReturnRecord -> True,
        UseStoredResults -> False,
        StoreResults -> False,
        DetailedTimingDiagnostics -> False]
  ]
];
peak = MaxMemoryUsed[];
success = Switch[stage,
  "Build", value =!= $Failed && !MatchQ[value, _BuildAntenna],
  _, AntennaRunRecordQ[value] && value =!= $Failed &&
    Quiet[Check[value["Result"], $Failed]] =!= $Failed &&
    TrueQ[Quiet[Check[value["IntegratedResultKind"] ===
      "ClosedDerivedMX30Series", False]]]
];

Print[ExportString[<|
  "Antenna" -> "A30",
  "Variant" -> "Massive",
  "Stage" -> stage,
  "TimeSeconds" -> N[elapsed],
  "Success" -> success,
  "BaselineBytes" -> baseline,
  "PeakBytes" -> peak,
  "DeltaBytes" -> peak - baseline
|>, "RawJSON"]];
Exit[If[success, 0, 1]];
