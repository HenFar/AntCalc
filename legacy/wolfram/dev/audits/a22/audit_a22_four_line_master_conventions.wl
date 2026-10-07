(* Development audit: compare the presently encoded values assigned to the
   four shift-equivalent scalar A4 representatives.  This checks conventions
   only; it does not modify the validated integrated route. *)

projectRoot = Nest[DirectoryName, $InputFileName, 4];
Get[FileNameJoin[{projectRoot, "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;

toSeries[expr_, order_:2] :=
  Normal[Series[expr /. q2 -> 1, {eps, 0, order}]] //
    FunctionExpand // FullSimplify;

a4 = toSeries[A22TwoLoopTreeMasterValueA4[], 2];
a4Nf = toSeries[A22TwoLoopTreeMasterValueA4NfLike[], 2];
a4Basis46 = toSeries[A22TwoLoopTreeMasterValueA4Basis46Like[], 2];
a4Basis7 = toSeries[A22TwoLoopTreeMasterValueA4Basis7Like[], 2];
a4Basis8 = toSeries[A22TwoLoopTreeMasterValueA4Basis8Like[], 2];

report = <|
  "Reference" -> "A22TwoLoopTreeMasterValueA4",
  "SeriesOrder" -> 2,
  "A4NfLikeMinusA4" -> FullSimplify[a4Nf - a4],
  "A4Basis46LikeMinusA4" -> FullSimplify[a4Basis46 - a4],
  "A4Basis7LikeMinusA4" -> FullSimplify[a4Basis7 - a4],
  "A4Basis8LikeMinusA4" -> FullSimplify[a4Basis8 - a4],
  "AllEncodedValuesAgreeQ" -> TrueQ[
    And @@ (FullSimplify[# - a4] === 0 & /@
      {a4Nf, a4Basis46, a4Basis7, a4Basis8})
  ],
  "IntegrandCrosswalk" -> <|
    "A4NfLike" -> "K=l1; L=l2",
    "A4Basis46Like" -> "K=l1-q; L=l2-k1",
    "A4Basis7Like" -> "K=l1+q; L=l2-(q-k1)",
    "A4Basis8Like" -> "K=l1+q; L=l2-k1"
  |>
|>;

Print[report];

If[TrueQ[report["AllEncodedValuesAgreeQ"]], Quit[0], Quit[2]];
