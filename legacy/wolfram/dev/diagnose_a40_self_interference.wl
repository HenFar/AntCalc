(*
  Isolate the cold A40 full-colour self-interference path.

  This is a diagnostic only: it reproduces the structured two-colour-chain
  branch used by InterfereMAmplitudes and records timings without changing a
  route, a physics convention, or a stored result.

  Usage:
    ANTCALC_A40_STAGE_TIMEOUT=120 WolframKernel -script \
      dev/diagnose_a40_self_interference.wl
*)

packageRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{packageRoot, "AntennaPipeline.wl"}]];

stageTimeout = ToExpression[Environment["ANTCALC_A40_STAGE_TIMEOUT"]];
If[!IntegerQ[stageTimeout] || stageTimeout <= 0, stageTimeout = 120];
reductionOrder = Environment["ANTCALC_A40_REDUCTION_ORDER"];
If[!MemberQ[{"Direct", "ContractFirst", "LocalTrace"}, reductionOrder],
  reductionOrder = "Direct"
];
traceProgressEvery = ToExpression[Environment["ANTCALC_A40_TRACE_PROGRESS_EVERY"]];
If[!IntegerQ[traceProgressEvery] || traceProgressEvery <= 0,
  traceProgressEvery = 25
];

ClearAll[A40StageCheckpointQ];
A40StageCheckpointQ[label_String] :=
  Module[{traceNumber},
    If[!StringContainsQ[label, " trace "], Return[True]];
    traceNumber = Quiet[Check[ToExpression[Last[StringSplit[label]]], 0]];
    Mod[traceNumber, traceProgressEvery] === 0
  ];

ClearAll[RunA40Stage];
SetAttributes[RunA40Stage, HoldRest];
RunA40Stage[label_String, expression_] :=
  Module[{seconds, result, timedOut},
    If[A40StageCheckpointQ[label],
      WriteString[$Output, "ANTCALC_A40_STAGE_BEGIN=", label, "\n"];
      Flush[$Output];
    ];
    {seconds, result} = AbsoluteTiming[
      TimeConstrained[expression, stageTimeout, $TimedOut]
    ];
    timedOut = TrueQ[result === $TimedOut];
    AppendTo[stageRecords, <|
      "Stage" -> label,
      "Seconds" -> seconds,
      "TimedOutQ" -> timedOut,
      "FailedQ" -> TrueQ[result === $Failed],
      "ByteCount" -> If[timedOut, Missing["TimedOut"],
        Quiet[Check[ByteCount[result], Missing["Unavailable"]]]]
    |>];
    If[A40StageCheckpointQ[label] || timedOut || result === $Failed,
      WriteString[$Output, "ANTCALC_A40_STAGE_END=", label,
        " seconds=", ToString[seconds, InputForm],
        " timedOut=", ToString[timedOut, InputForm], "\n"];
      Flush[$Output];
    ];
    If[timedOut || result === $Failed, halted = True];
    result
  ];

ClearAll[ContinueA40ProbeQ];
ContinueA40ProbeQ[] := !TrueQ[halted];

stageRecords = {};
halted = False;

amp = RunA40Stage["A40 amplitude", AntennaAmplitude[{A, 4, 0}]];
If[ContinueA40ProbeQ[],
  profile = AntennaProfile[{A, 4, 0}];
  colourCount = RunA40Stage["Colour-tensor count", ColourTensorCounter[amp]];
];

If[ContinueA40ProbeQ[],
  couples = RunA40Stage["Separate colour/spin chains", ReturnColourSpinCouples[amp]];
];

If[ContinueA40ProbeQ[],
  chainCount = Length[couples];
  AppendTo[stageRecords, <|"Stage" -> "Chain summary", "ChainCount" -> chainCount,
    "PairCount" -> chainCount^2|>];
  colours = couples[[All, 1]];
  spins = couples[[All, 2]];
  KinematicRules[4];
  colourCouples = {};
  spinCouples = {};
  Do[
    pairLabel = "pair " <> ToString[i] <> "," <> ToString[j];
    colour = RunA40Stage[pairLabel <> " colour algebra",
      FeynCalc`ComplexConjugate[colours[[i]]] colours[[j]] //
        FeynCalc`SUNSimplify];
    If[!ContinueA40ProbeQ[], Break[]];
    spin = RunA40Stage[pairLabel <> " spin and virtual-boson sum",
      FeynCalc`ComplexConjugate[spins[[i]]] spins[[j]] //
        FeynCalc`SUNSimplify[#, FeynCalc`Explicit -> True,
          FeynCalc`SUNNToCACF -> False]& //
        FeynCalc`FermionSpinSum // SafeDoPolarizationSums[#, p, 0,
          FeynCalc`VirtualBoson -> True]&];
    If[!ContinueA40ProbeQ[], Break[]];
    spin = RunA40Stage[pairLabel <> " gluon-polarisation sums",
      spin // SafeDoPolarizationSums[#, k3, k4]& //
        SafeDoPolarizationSums[#, k4, k3]&];
    If[!ContinueA40ProbeQ[], Break[]];
    If[reductionOrder === "LocalTrace",
      spin = RunA40Stage[pairLabel <> " Contract", spin // FeynCalc`Contract];
      If[!ContinueA40ProbeQ[], Break[]];
      traces = DeleteDuplicates @ Cases[spin, _FeynCalc`DiracTrace, Infinity];
      traceRules = {};
      Do[
        reducedTrace = RunA40Stage[pairLabel <> " trace " <> ToString[traceIndex],
          FeynCalc`DiracSimplify[traces[[traceIndex]]]];
        If[!ContinueA40ProbeQ[], Break[]];
        AppendTo[traceRules, traces[[traceIndex]] -> reducedTrace];
        , {traceIndex, Length[traces]}
      ];
      If[!ContinueA40ProbeQ[], Break[]];
      spin = RunA40Stage[pairLabel <> " substitute reduced traces",
        spin /. traceRules];
      ,
      If[reductionOrder === "ContractFirst",
        spin = RunA40Stage[pairLabel <> " Contract", spin // FeynCalc`Contract];
      ];
      If[!ContinueA40ProbeQ[], Break[]];
      spin = RunA40Stage[pairLabel <> " DiracSimplify",
        spin // FeynCalc`DiracSimplify];
    ];
    If[!ContinueA40ProbeQ[], Break[]];
    spin = RunA40Stage[pairLabel <> " Simplify", spin // Simplify];
    If[!ContinueA40ProbeQ[], Break[]];
    spin = RunA40Stage[pairLabel <> " Calc", spin // FeynCalc`Calc];
    If[!ContinueA40ProbeQ[], Break[]];
    AppendTo[colourCouples, colour];
    AppendTo[spinCouples, spin];
    , {i, chainCount}, {j, chainCount}
  ];
];

If[ContinueA40ProbeQ[],
  mixed = RunA40Stage["Recombine colour and spin pairs",
    Total[MapThread[Times, {colourCouples, spinCouples}]]];
];
If[ContinueA40ProbeQ[],
  ruled = RunA40Stage["Apply four-parton kinematic rules",
    ApplyFeynCalcRules[mixed, 4]];
];
If[ContinueA40ProbeQ[],
  final = RunA40Stage["Final simplification",
    (ruled /. CasimirSubs /. D -> 4 - 2 Epsilon) // Simplify];
];

report = <|
  "SchemaVersion" -> 1,
  "Diagnostic" -> "A40FullColourSelfInterference",
  "StageTimeoutSeconds" -> stageTimeout,
  "ReductionOrder" -> reductionOrder,
  "ColourTensorCount" -> If[ValueQ[colourCount], colourCount,
    Missing["NotReached"]],
  "CompletedQ" -> !halted,
  "Stages" -> stageRecords
|>;

WriteString[$Output, "ANTCALC_A40_INTERFERENCE_REPORT=",
  ExportString[report, "JSON", "Compact" -> True], "\n"];
Quit[If[halted, 2, 0]];
