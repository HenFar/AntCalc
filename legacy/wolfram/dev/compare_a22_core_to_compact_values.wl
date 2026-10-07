(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

masters = {
  "A22LO" -> {A22TwoLoopTreeMasterCoreA22LO[], A22TwoLoopTreeMasterValueA22LO[]},
  "A3" -> {A22TwoLoopTreeMasterCoreA3[], A22TwoLoopTreeMasterValueA3[]},
  "A4" -> {A22TwoLoopTreeMasterCoreA4[], A22TwoLoopTreeMasterValueA4[]},
  "A6" -> {A22TwoLoopTreeMasterCoreA6[], A22TwoLoopTreeMasterValueA6[]}
};

KeyValueMap[
  (
    coreSeries =
      Normal[
        Series[
          A22TwoLoopTreePaperConventionFactor[] *
            A22TwoLoopTreePaperConventionRules[#2[[1]]] /. {q2 -> 1},
          {eps, 0, 0}
        ]
      ] // FunctionExpand // FullSimplify;
    compactSeries =
      Normal[Series[#2[[2]] /. {q2 -> 1}, {eps, 0, 0}]] //
        FunctionExpand // FullSimplify;
    Print[#1, " core-converted: ", coreSeries];
    Print[#1, " compact: ", compactSeries];
    Print[#1, " difference: ", FullSimplify[coreSeries - compactSeries]];
    Print["---"];
  )&,
  Association[masters]
];
