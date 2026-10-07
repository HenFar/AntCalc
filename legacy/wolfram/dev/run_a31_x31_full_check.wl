(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

ClearAll[ReduceA31ComponentWithProgress];

(* ReduceA31ComponentWithProgress: Script-local helper for this development or benchmarking utility. *)
ReduceA31ComponentWithProgress[expr_, label_, targets_Association] :=
  Module[
    {profile, basisLoad, bases, terms, reducedTerms, term, match, redTerm,
      masterRules, unmatched, t0, tLast, integrated, paperIntegrated,
      residuals, checkpoint},

    profile = IBPProfile["A31"];
    basisLoad = LoadIBPBases[profile];
    bases = basisLoad["Bases"];
    terms = List @@ Expand[expr];
    reducedTerms = {};
    unmatched = {};
    t0 = AbsoluteTime[];
    tLast = t0;
    checkpoint =
      FileNameJoin[{
        "/private/tmp",
        "a31_" <> label <> "_checkpoint.mx"
      }];

    Print[label, " term count: ", Length[terms]];

    Do[
      term = terms[[i]];
      match = MatchIBPBasis[term, bases, profile];
      If[! TrueQ[match["MatchedQ"]],
        AppendTo[
          unmatched,
          <|"Index" -> i, "Reason" -> "NoMatch", "Match" -> match,
            "InputTerm" -> term|>
        ];
        Continue[];
      ];

      redTerm =
        Check[
          Quiet[
            Block[{Print},
              Print[___] := Null;
              LiteRed`IBPReduce[match["JTerm"]]
            ]
          ],
          $Failed
        ];

      If[redTerm === $Failed,
        AppendTo[
          unmatched,
          <|"Index" -> i, "Reason" -> "IBPReduceFailed", "Match" -> match,
            "InputTerm" -> term|>
        ];
        Continue[];
      ];

      masterRules = IBPMasterRulesForBasis[match["Basis"], profile];
      AppendTo[reducedTerms, redTerm /. masterRules];

      If[Mod[i, 25] == 0 || i == Length[terms],
        Print[
          label, " ", i, "/", Length[terms],
          " elapsed=", NumberForm[AbsoluteTime[] - t0, {8, 1}],
          " delta=", NumberForm[AbsoluteTime[] - tLast, {8, 1}],
          " unmatched=", Length[unmatched]
        ];
        tLast = AbsoluteTime[];
        Put[
          <|"Label" -> label, "Index" -> i,
            "ReducedTerms" -> reducedTerms, "Unmatched" -> unmatched|>,
          checkpoint
        ];
      ];
      ,
      {i, Length[terms]}
    ];

    integrated =
      If[Length[unmatched] == 0,
        IBPToSeries[reducedTerms, profile],
        $Failed
      ];

    (* The A31 notebook/PDF convention strips the 1/(2 Pi^2) carried by the
       package IBP normalization.  Keep both values so the reduction output and
       the paper comparison remain explicit. *)
    paperIntegrated =
      If[integrated === $Failed,
        $Failed,
        FullSimplify[2 Pi^2 integrated]
      ];

    residuals =
      If[integrated === $Failed,
        <||>,
        Map[FullSimplify[paperIntegrated - #] &, targets]
      ];

    Print[label, " final unmatched: ", Length[unmatched]];
    Print[label, " integrated: ", integrated];
    Print[label, " paper-normalized integrated: ", paperIntegrated];
    Print[label, " residuals: ", residuals];

    <|"Integrated" -> integrated, "PaperIntegrated" -> paperIntegrated,
      "Residuals" -> residuals,
      "Unmatched" -> unmatched, "ReducedTerms" -> reducedTerms|>
  ];

eps = FeynCalc`Epsilon;

a31RawLeadingTarget =
  -5/(4 eps^4) - 15/(4 eps^3) + (13 Pi^2 - 119)/(8 eps^2);

a31FinalLeadingTarget =
  -1/(4 eps^4) - 31/(12 eps^3) +
   (-53/8 + 11 Pi^2/24)/eps^2 +
   (-647/24 + 22 Pi^2/9 + 23 Zeta[3]/3)/eps +
   (-5231/48 + 17 Pi^2/2 + 689 Zeta[3]/18 - 41 Pi^4/480);

a31RawSubleadingTarget =
  1/eps^4 + 3/eps^3 + (279 - 32 Pi^2)/(24 eps^2);

a31FinalSubleadingTarget =
  (-5/8 + Pi^2/6)/eps^2 +
   (-19/4 + Pi^2/4 + 7 Zeta[3])/eps +
   (-105/4 + 27 Pi^2/16 + 27 Zeta[3]/2 + 7 Pi^4/90);

a31HatTarget =
  1/(3 eps^3) + 1/(2 eps^2) +
   (19/12 - 7 Pi^2/36)/eps +
   (109/24 - 7 Pi^2/24 - 25 Zeta[3]/9);

intA21PDF =
  -1/eps^2 - 3/(2 eps) - 4 + 7 Pi^2/12 +
   eps (-8 + 7 Pi^2/8 + 7 Zeta[3]/3) +
   eps^2 (-16 + 7 Pi^2/3 + 7 Zeta[3]/2 - 73 Pi^4/1440);

intA30PDF =
  1/eps^2 + 3/(2 eps) + 19/4 - 7 Pi^2/12 +
   eps (109/8 - 7 Pi^2/8 - 25 Zeta[3]/3) +
   eps^2 (639/16 - 133 Pi^2/48 - 25 Zeta[3]/2 - 71 Pi^4/1440);

antennae = BuildAntenna[A, 3, 1];

leadingReport =
  ReduceA31ComponentWithProgress[
    antennae[[1]],
    "leading",
    <|"RawPDF" -> a31RawLeadingTarget|>
  ];

subleadingReport =
  ReduceA31ComponentWithProgress[
    antennae[[2]],
    "subleading",
    <|"RawPDF" -> a31RawSubleadingTarget|>
  ];

finalReport =
  Module[{leadingFinal, subleadingFinal, hatFinal},
    leadingFinal =
      Normal[
        Series[
          leadingReport["PaperIntegrated"] -
           11/(6 eps) intA30PDF - intA21PDF intA30PDF,
          {eps, 0, 0}
        ]
      ];
    subleadingFinal =
      Normal[
        Series[
          -(subleadingReport["PaperIntegrated"] + intA21PDF intA30PDF),
          {eps, 0, 0}
        ]
      ];
    hatFinal =
      Normal[
        Series[
          antennae[[3]] - (-2/(6 eps)) intA30PDF,
          {eps, 0, 0}
        ]
      ];

    <|"Leading" -> leadingFinal,
      "LeadingResidual" -> FullSimplify[leadingFinal - a31FinalLeadingTarget],
      "Subleading" -> subleadingFinal,
      "SubleadingResidual" ->
        FullSimplify[subleadingFinal - a31FinalSubleadingTarget],
      "Hat" -> hatFinal,
      "HatResidual" -> FullSimplify[hatFinal - a31HatTarget]|>
  ];

Print["final antenna report: ", finalReport];

hatReport =
  <|"UnintegratedHat" -> antennae[[3]],
    "FinalPDFTarget" -> a31HatTarget|>;

Print["hat report: ", hatReport];

Put[
  <|"Leading" -> leadingReport, "Subleading" -> subleadingReport,
    "Final" -> finalReport, "Hat" -> hatReport|>,
  "/private/tmp/a31_x31_full_check.mx"
];
