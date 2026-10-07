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

values = <|
  "A22A22LOQQMI" -> valueSeries["a22lo", -2, 2],
  "A22A3Basis15LikeMI" -> valueSeries["a3b15", -1, 3],
  "A22A3SunsetMI" -> valueSeries["a3sun", -1, 3],
  "A22A3Basis7LikeMI" -> valueSeries["a37", -1, 3],
  "A22A3Basis8LikeMI" -> valueSeries["a38", -1, 3],
  "A22A4NfLikeMI" -> valueSeries["a4nf", -2, 2],
  "A22A4Basis46LikeMI" -> valueSeries["a446", -2, 2],
  "A22A4Basis7LikeMI" -> valueSeries["a47", -2, 2],
  "A22A4Basis8LikeMI" -> valueSeries["a48", -2, 2],
  "A22A6Basis8LikeMI" -> valueSeries["a6", -4, 0]
|>;

vars = Cases[Values[values], s_Symbol /; Context[s] === "Global`", Infinity] //
  DeleteDuplicates;

leadExpr = toSeries[
  leadData[a22Key] values["A22A22LOQQMI"] +
  leadData[a3Basis15Key] values["A22A3Basis15LikeMI"] +
  leadData[a3SunsetKey] values["A22A3SunsetMI"] +
  leadData[a3Basis7Key] values["A22A3Basis7LikeMI"] +
  leadData[a4NfKey] values["A22A4NfLikeMI"] +
  leadData[a4Basis46Key] values["A22A4Basis46LikeMI"] +
  leadData[a4Basis7Key] values["A22A4Basis7LikeMI"],
  0
];

subExpr = toSeries[
  subData[a22Key] values["A22A22LOQQMI"] +
  subData[a3Basis15Key] values["A22A3Basis15LikeMI"] +
  subData[a3SunsetKey] values["A22A3SunsetMI"] +
  subData[a3Basis7Key] values["A22A3Basis7LikeMI"] +
  subData[a3Basis8Key] values["A22A3Basis8LikeMI"] +
  subData[a4Basis46Key] values["A22A4Basis46LikeMI"] +
  subData[a4Basis7Key] values["A22A4Basis7LikeMI"] +
  subData[a4Basis8Key] values["A22A4Basis8LikeMI"] +
  subData[a6Key] values["A22A6Basis8LikeMI"],
  0
];

nfExpr = toSeries[
  nfData[a4NfKey] values["A22A4NfLikeMI"],
  0
];

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

(* eqSetThrough: Script-local helper for this development or benchmarking utility. *)
eqSetThrough[pole_Integer] :=
  Join[
    Table[Coefficient[leadExpr - targetLead, eps, n] == 0, {n, -4, pole}],
    Table[Coefficient[subExpr - targetSub, eps, n] == 0, {n, -4, pole}],
    Table[Coefficient[nfExpr - targetNf, eps, n] == 0, {n, -3, Min[pole, 0]}]
  ];

Do[
  eqs = eqSetThrough[pole];
  sol = Solve[eqs, vars] // FullSimplify;
  Print["through pole eps^", pole, ": equations=", Length[eqs],
    ", solution count=", Length[sol]];
  If[Length[sol] == 0,
    Print["status: NO SOLUTION"];
    Break[];
    ,
    sample = First[sol];
    free = Complement[Variables[Last /@ sample], vars];
    Print["status: SOLVED"];
    Print["free parameters: ", InputForm[free]];
  ];
  Print["---"];
  ,
  {pole, -4, 0}
];

Quit[];
