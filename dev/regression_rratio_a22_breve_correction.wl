(* Regression for the exact Breve A22 normalization.  The external expression
   below is a regression target only; it is not read by the integration path. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
breve = 1/(4 eps^4) + (7 - Pi^2/8 - 7 Zeta[3]/6)/eps;
ingredients = <|"intBreveA22" -> breve|>;
observable = ApplySMQCDRRatioObservableConvention[ingredients]["Ingredients"];
exactBreveFromMaster = Normal[Series[
  ((-2 + eps - 2 eps^2)^2/(16 Pi^4 eps^2)) *
    A22LOMasterCore[] A22OneLoopSelfVirtualConventionFactor[],
  {eps, 0, 0}]];
breveTarget = 1/(4 eps^4) + 3/(4 eps^3) +
  (41/16 - Pi^2/24)/eps^2 +
  (7 - Pi^2/8 - 7 Zeta[3]/6)/eps +
  (18 - 41 Pi^2/96 - 7 Zeta[3]/2 - 7 Pi^4/480);

checks = <|
  "ExactLoopMeasureConversion" ->
    TrueQ[FullSimplify[A22OneLoopSelfVirtualConventionFactor[] -
      Exp[2 EulerGamma eps]/Gamma[1 - eps]^2] === 0],
  "IntegratedBreveMatchesRegressionTargetThroughFiniteOrder" ->
    TrueQ[FullSimplify[exactBreveFromMaster - breveTarget] === 0],
  "BreveIsUnchangedByObservableAdapter" ->
    TrueQ[FullSimplify[observable["intBreveA22"] - breve] === 0],
  "BreveZetaPoleMatchesRegressionTarget" ->
    TrueQ[FullSimplify[
      Coefficient[exactBreveFromMaster, Zeta[3]/eps] === -7/6]]
|>;

Print[ExportString[<|"Regression" -> "RRatioA22BreveExactConversion",
  "Checks" -> checks, "Passed" -> And @@ Values[checks]|>, "JSON",
  "Compact" -> True]];
Quit[If[And @@ Values[checks], 0, 1]];
