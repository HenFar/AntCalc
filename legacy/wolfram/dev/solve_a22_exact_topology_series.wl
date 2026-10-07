(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

leadData = Get["/private/tmp/a22_signature_coeffs_Leading.mx"]["NormalizedCoefficients"];
subData = Get["/private/tmp/a22_signature_coeffs_Subleading.mx"]["NormalizedCoefficients"];
nfData = Get["/private/tmp/a22_signature_coeffs_Nf.mx"]["NormalizedCoefficients"];

(* findByDens: Script-local helper for this development or benchmarking utility. *)
findByDens[assoc_, dens_List] :=
  SelectFirst[Keys[assoc], Lookup[#, "ActiveDenominators", {}] === Sort[dens] &];

(* toSeries: Script-local helper for this development or benchmarking utility. *)
toSeries[expr_, order_:0] :=
  Normal[Series[expr /. {q2 -> 1}, {eps, 0, order}]] //
    FunctionExpand // FullSimplify;

(* valueSeries: Script-local helper for this development or benchmarking utility. *)
valueSeries[name_String, min_Integer, max_Integer] :=
  Sum[ToExpression[name <> If[i < 0, "m" <> ToString[-i], ToString[i]]] eps^i,
    {i, min, max}];

a22Key = findByDens[leadData, {
  "sp[l1, l1]", "sp[l1 + q, l1 + q]", "sp[l2, l2]", "sp[l2 - q, l2 - q]"
}];

a3Basis15Key = findByDens[leadData, {
  "sp[-k1 + l1 + l2, -k1 + l1 + l2]",
  "sp[-k1 + l2, -k1 + l2]",
  "sp[l1 - q, l1 - q]"
}];

a3SunsetKey = findByDens[leadData, {
  "sp[l1, l1]",
  "sp[l1 + l2 - q, l1 + l2 - q]",
  "sp[l2, l2]"
}];

a3Basis7Key = findByDens[leadData, {
  "sp[-k1 + l1, -k1 + l1]",
  "sp[k1 + l2 - q, k1 + l2 - q]",
  "sp[l1 + l2, l1 + l2]"
}];

a3Basis8Key = findByDens[subData, {
  "sp[-k1 + l1, -k1 + l1]",
  "sp[-k1 + l1 + l2 + q, -k1 + l1 + l2 + q]",
  "sp[l2, l2]"
}];

a4NfKey = findByDens[leadData, {
  "sp[-k1 + l1 + l2, -k1 + l1 + l2]",
  "sp[l1, l1]",
  "sp[l1 - q, l1 - q]",
  "sp[l2, l2]"
}];

a4Basis46Key = findByDens[leadData, {
  "sp[-k1 + l2, -k1 + l2]",
  "sp[l1, l1]",
  "sp[l1 + l2 - q, l1 + l2 - q]",
  "sp[l1 - q, l1 - q]"
}];

a4Basis7Key = findByDens[leadData, {
  "sp[k1 + l2 - q, k1 + l2 - q]",
  "sp[l1, l1]",
  "sp[l1 + l2, l1 + l2]",
  "sp[l1 + q, l1 + q]"
}];

a4Basis8Key = findByDens[subData, {
  "sp[-k1 + l2, -k1 + l2]",
  "sp[l1, l1]",
  "sp[l1 + l2, l1 + l2]",
  "sp[l1 + q, l1 + q]"
}];

a6Key = SelectFirst[Keys[subData], Lookup[#, "ActiveCount", 0] === 6 &];

fixedA22 = toSeries[A22TwoLoopTreeMasterValueA22LO[], 2];
fixedA4Nf = toSeries[A22TwoLoopTreeMasterValueA4[], 2];
fixedA6 = toSeries[A22TwoLoopTreeMasterValueA6[], 0];

targetLead = toSeries[
  A22TTermTargetForComponent[Leading, 0] +
    11/(6 eps) IntegratedLowerAntenna[{A, 2, 1}, 2],
  0
];
targetSub = toSeries[A22TTermTargetForComponent[Subleading, 0], 0];
targetNf = toSeries[
  A22TTermTargetForComponent[Nf, 0] -
    2/(6 eps) IntegratedLowerAntenna[{A, 2, 1}, 2],
  0
];

(* buildChannelExpressions: Script-local helper for this development or benchmarking utility. *)
buildChannelExpressions[valueRules_Association] :=
  Module[{leadExpr, subExpr, nfExpr},
    leadExpr = toSeries[
      leadData[a22Key] valueRules["A22A22LOQQMI"] +
      leadData[a3Basis15Key] valueRules["A22A3Basis15LikeMI"] +
      leadData[a3SunsetKey] valueRules["A22A3SunsetMI"] +
      leadData[a3Basis7Key] valueRules["A22A3Basis7LikeMI"] +
      leadData[a4NfKey] valueRules["A22A4NfLikeMI"] +
      leadData[a4Basis46Key] valueRules["A22A4Basis46LikeMI"] +
      leadData[a4Basis7Key] valueRules["A22A4Basis7LikeMI"],
      0
    ];
    subExpr = toSeries[
      subData[a22Key] valueRules["A22A22LOQQMI"] +
      subData[a3Basis15Key] valueRules["A22A3Basis15LikeMI"] +
      subData[a3SunsetKey] valueRules["A22A3SunsetMI"] +
      subData[a3Basis7Key] valueRules["A22A3Basis7LikeMI"] +
      subData[a3Basis8Key] valueRules["A22A3Basis8LikeMI"] +
      subData[a4Basis46Key] valueRules["A22A4Basis46LikeMI"] +
      subData[a4Basis7Key] valueRules["A22A4Basis7LikeMI"] +
      subData[a4Basis8Key] valueRules["A22A4Basis8LikeMI"] +
      subData[a6Key] valueRules["A22A6Basis8LikeMI"],
      0
    ];
    nfExpr = toSeries[
      nfData[a4NfKey] valueRules["A22A4NfLikeMI"],
      0
    ];
    <|"Leading" -> leadExpr, "Subleading" -> subExpr, "Nf" -> nfExpr|>
  ];

(* equationsFor: Script-local helper for this development or benchmarking utility. *)
equationsFor[channelExprs_Association] :=
  Join[
    Table[Coefficient[channelExprs["Leading"] - targetLead, eps, n] == 0,
      {n, -4, 0}],
    Table[Coefficient[channelExprs["Subleading"] - targetSub, eps, n] == 0,
      {n, -4, 0}],
    Table[Coefficient[channelExprs["Nf"] - targetNf, eps, n] == 0,
      {n, -3, 0}]
  ];

(* runStage: Script-local helper for this development or benchmarking utility. *)
runStage[name_String, valueRules_Association, solveVars_List] :=
  Module[{channelExprs, eqs, sol},
    channelExprs = buildChannelExpressions[valueRules];
    eqs = equationsFor[channelExprs];
    Print["== ", name, " =="];
    Print["equation count: ", Length[eqs]];
    Print["solve variable count: ", Length[solveVars]];
    sol = Solve[eqs, solveVars] // FullSimplify;
    If[Length[sol] > 0,
      Print["status: SOLVED"];
      Print["solution count: ", Length[sol]];
      Print["assignment count in sample solution: ", Length[First[sol]]];
      Print["sample residual Leading: ",
        FullSimplify[channelExprs["Leading"] - targetLead /. First[sol]] //
          InputForm];
      Print["sample residual Subleading: ",
        FullSimplify[channelExprs["Subleading"] - targetSub /. First[sol]] //
          InputForm];
      Print["sample residual Nf: ",
        FullSimplify[channelExprs["Nf"] - targetNf /. First[sol]] //
          InputForm];
      Print["free parameters in sample solution: ",
        Complement[Variables[Last /@ First[sol]], solveVars] // InputForm];
      Print["sample solution: ", InputForm[First[sol]]];
      ,
      Print["status: NO SOLUTION"]
    ];
    Print[""];
    sol
  ];

stage1Values = <|
  "A22A22LOQQMI" -> fixedA22,
  "A22A3Basis15LikeMI" -> valueSeries["a3b15", -1, 3],
  "A22A3SunsetMI" -> valueSeries["a3sun", -1, 3],
  "A22A3Basis7LikeMI" -> valueSeries["a37", -1, 3],
  "A22A3Basis8LikeMI" -> valueSeries["a38", -1, 3],
  "A22A4NfLikeMI" -> fixedA4Nf,
  "A22A4Basis46LikeMI" -> valueSeries["a446", -2, 2],
  "A22A4Basis7LikeMI" -> valueSeries["a47", -2, 2],
  "A22A4Basis8LikeMI" -> valueSeries["a48", -2, 2],
  "A22A6Basis8LikeMI" -> fixedA6
|>;

stage1Vars = Cases[Values[stage1Values], s_Symbol /; Context[s] === "Global`",
  Infinity] // DeleteDuplicates;

stage2Values = Join[stage1Values, <|
  "A22A3Basis8LikeMI" -> stage1Values["A22A3Basis15LikeMI"],
  "A22A4Basis8LikeMI" -> stage1Values["A22A4Basis46LikeMI"]
|>];

stage2Vars = Cases[Values[stage2Values], s_Symbol /; Context[s] === "Global`",
  Infinity] // DeleteDuplicates;

stage3Values = Join[stage1Values, <|
  "A22A22LOQQMI" -> valueSeries["a22lo", -2, 2],
  "A22A6Basis8LikeMI" -> valueSeries["a6", -4, 0]
|>];

stage3Vars = Cases[Values[stage3Values], s_Symbol /; Context[s] === "Global`",
  Infinity] // DeleteDuplicates;

stage4Values = Join[stage3Values, <|
  "A22A4NfLikeMI" -> valueSeries["a4nf", -2, 2]
|>];

stage4Vars = Cases[Values[stage4Values], s_Symbol /; Context[s] === "Global`",
  Infinity] // DeleteDuplicates;

sol1 = runStage["Stage 1: fixed A22LO/A6 and fixed Nf-like A4", stage1Values,
  stage1Vars];
sol2 = runStage["Stage 2: merge Basis8 with Basis15/Basis46 groups", stage2Values,
  stage2Vars];
sol3 = runStage["Stage 3: free A22LO and A6 as well", stage3Values, stage3Vars];
sol4 = runStage["Stage 4: also free Nf-like A4", stage4Values, stage4Vars];

Quit[];
