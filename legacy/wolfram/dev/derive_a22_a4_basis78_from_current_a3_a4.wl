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

(* seriesCoeffRules: Script-local helper for this development or benchmarking utility. *)
seriesCoeffRules[prefix_String, expr_, min_Integer, max_Integer] :=
  Flatten@Table[
    ToExpression[prefix <> If[n < 0, "m" <> ToString[-n], ToString[n]]] ->
      FullSimplify[Coefficient[expr, eps, n]],
    {n, min, max}
  ];

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
fixedA3 = toSeries[A22TwoLoopTreeMasterValueA3[], 3];
fixedA4 = toSeries[A22TwoLoopTreeMasterValueA4[], 2];
fixedA6 = toSeries[A22TwoLoopTreeMasterValueA6[], 0];

V47 = valueSeries["a47", -2, 2];
V48 = valueSeries["a48", -2, 2];

leadExpr = toSeries[
  leadData[a22Key] fixedA22 +
  leadData[a3Basis15Key] fixedA3 +
  leadData[a3SunsetKey] fixedA3 +
  leadData[a3Basis7Key] fixedA3 +
  leadData[a4NfKey] fixedA4 +
  leadData[a4Basis46Key] fixedA4 +
  leadData[a4Basis7Key] V47,
  0
];

subExpr = toSeries[
  subData[a22Key] fixedA22 +
  subData[a3Basis15Key] fixedA3 +
  subData[a3SunsetKey] fixedA3 +
  subData[a3Basis7Key] fixedA3 +
  subData[a3Basis8Key] fixedA3 +
  subData[a4Basis46Key] fixedA4 +
  subData[a4Basis7Key] V47 +
  subData[a4Basis8Key] V48 +
  subData[a6Key] fixedA6,
  0
];

nfExpr = toSeries[nfData[a4NfKey] fixedA4, 0];

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

eqs = Join[
  Table[Coefficient[leadExpr - targetLead, eps, n] == 0, {n, -4, 0}],
  Table[Coefficient[subExpr - targetSub, eps, n] == 0, {n, -4, 0}],
  Table[Coefficient[nfExpr - targetNf, eps, n] == 0, {n, -3, 0}]
];

vars = Cases[{V47, V48}, s_Symbol /; Context[s] === "Global`", Infinity] //
  DeleteDuplicates;

sol = Solve[eqs, vars] // FullSimplify;

If[Length[sol] > 0,
  sample = First[sol];
  V47Solved = FullSimplify[V47 /. sample];
  V48Solved = FullSimplify[V48 /. sample];
  Print["SOLVED"];
  Print["A22A4Basis7Like = ", InputForm[V47Solved]];
  Print["A22A4Basis8Like = ", InputForm[V48Solved]];
  Print["Lead residual = ", InputForm[FullSimplify[leadExpr - targetLead /. sample]]];
  Print["Sub residual = ", InputForm[FullSimplify[subExpr - targetSub /. sample]]];
  Print["Nf residual = ", InputForm[FullSimplify[nfExpr - targetNf /. sample]]];
  ,
  Print["NO SOLUTION"]
];

Quit[];
