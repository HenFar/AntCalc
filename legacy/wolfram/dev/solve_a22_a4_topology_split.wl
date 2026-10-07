(* Development script: local exploratory or benchmark utility for the antenna pipeline. Script-local helpers below are intentionally narrow and only support this file. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[]], "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

lead = Get["/private/tmp/a22_signature_coeffs_Leading.mx"]["NormalizedCoefficients"];
sub = Get["/private/tmp/a22_signature_coeffs_Subleading.mx"]["NormalizedCoefficients"];
nf  = Get["/private/tmp/a22_signature_coeffs_Nf.mx"]["NormalizedCoefficients"];

(* findByDens: Script-local helper for this development or benchmarking utility. *)
findByDens[assoc_, dens_List] :=
  SelectFirst[Keys[assoc], Lookup[#, "ActiveDenominators", {}] === Sort[dens] &];

(* Exact signatures *)
a22Key = findByDens[lead, {
  "sp[l1, l1]", "sp[l1 + q, l1 + q]", "sp[l2, l2]", "sp[l2 - q, l2 - q]"
}];

a3aKey = findByDens[lead, {
  "sp[-k1 + l1 + l2, -k1 + l1 + l2]", "sp[-k1 + l2, -k1 + l2]", "sp[l1 - q, l1 - q]"
}];
a3bKey = findByDens[lead, {
  "sp[l1, l1]", "sp[l1 + l2 - q, l1 + l2 - q]", "sp[l2, l2]"
}];
a3cKey = findByDens[lead, {
  "sp[-k1 + l1, -k1 + l1]", "sp[k1 + l2 - q, k1 + l2 - q]", "sp[l1 + l2, l1 + l2]"
}];
a3dKey = findByDens[sub, {
  "sp[-k1 + l1, -k1 + l1]", "sp[-k1 + l1 + l2 + q, -k1 + l1 + l2 + q]", "sp[l2, l2]"
}];

a4aKey = findByDens[lead, {
  "sp[-k1 + l1 + l2, -k1 + l1 + l2]", "sp[l1, l1]", "sp[l1 - q, l1 - q]", "sp[l2, l2]"
}];
a4bKey = findByDens[lead, {
  "sp[-k1 + l2, -k1 + l2]", "sp[l1, l1]", "sp[l1 + l2 - q, l1 + l2 - q]", "sp[l1 - q, l1 - q]"
}];
a4cKey = findByDens[lead, {
  "sp[k1 + l2 - q, k1 + l2 - q]", "sp[l1, l1]", "sp[l1 + l2, l1 + l2]", "sp[l1 + q, l1 + q]"
}];
a4dKey = findByDens[sub, {
  "sp[-k1 + l2, -k1 + l2]", "sp[l1, l1]", "sp[l1 + l2, l1 + l2]", "sp[l1 + q, l1 + q]"
}];

a6Key = SelectFirst[Keys[sub], Lookup[#, "ActiveCount", 0] === 6 &];

(* toSeries: Script-local helper for this development or benchmarking utility. *)
toSeries[expr_, order_:0] :=
  Normal[Series[expr /. {q2 -> 1}, {eps, 0, order}]] //
    FunctionExpand // FullSimplify;

(* Known master values *)
V22 = toSeries[A22TwoLoopTreeMasterValueA22LO[]];
V3  = toSeries[A22TwoLoopTreeMasterValueA3[]];
V4a = toSeries[A22TwoLoopTreeMasterValueA4[]];
V6  = toSeries[A22TwoLoopTreeMasterValueA6[]];

(* Unknown A4 topologies *)
V4b = b2/eps^2 + b1/eps + b0;
V4c = c2/eps^2 + c1/eps + c0;
V4d = d2/eps^2 + d1/eps + d0;

leadExpr =
  toSeries[
    lead[a22Key] V22 +
    (lead[a3aKey] + lead[a3bKey] + lead[a3cKey]) V3 +
    lead[a4aKey] V4a +
    lead[a4bKey] V4b +
    lead[a4cKey] V4c
  ];

subExpr =
  toSeries[
    sub[a22Key] V22 +
    (sub[a3aKey] + sub[a3bKey] + sub[a3cKey] + sub[a3dKey]) V3 +
    sub[a4bKey] V4b +
    sub[a4cKey] V4c +
    sub[a4dKey] V4d +
    sub[a6Key] V6
  ];

targetLead = toSeries[A22TTermTargetForComponent[Leading, 0] + 11/(6 eps) IntegratedLowerAntenna[{A, 2, 1}, 2]];
targetSub  = toSeries[A22TTermTargetForComponent[Subleading, 0]];

eqs = Join[
  Table[Coefficient[leadExpr - targetLead, eps, n] == 0, {n, -4, 0}],
  Table[Coefficient[subExpr - targetSub, eps, n] == 0, {n, -4, 0}]
];

sol = Solve[eqs, {b2, b1, b0, c2, c1, c0, d2, d1, d0}] // FullSimplify;

If[Length[sol] > 0,
  s = First[sol];
  Print["SOLVED"];
  Print["V4b = ", FullSimplify[V4b /. s] // InputForm];
  Print["V4c = ", FullSimplify[V4c /. s] // InputForm];
  Print["V4d = ", FullSimplify[V4d /. s] // InputForm];
  Print["Lead residual = ", FullSimplify[leadExpr - targetLead /. s] // InputForm];
  Print["Sub residual = ", FullSimplify[subExpr - targetSub /. s] // InputForm];
  ,
  Print["NO SOLUTION"]
];

Quit[];
