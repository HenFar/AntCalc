(* Regression for the corrected Breve A22 observable convention.

   arXiv:2211.08446v2 Eq. (B.7) corrects the integrated one-loop-self target.
   The observable adapter must therefore leave the corrected target unchanged. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

eps = FeynCalc`Epsilon;
breve = 1/(4 eps^4) + (7 - Pi^2/8 - 7 Zeta[3]/6)/eps;
ingredients = <|"intBreveA22" -> breve|>;
ledger = SMQCDRRatioObservableConventionLedger[];
observable = ApplySMQCDRRatioObservableConvention[ingredients]["Ingredients"];
correctedBreveFromMaster = Normal[Series[
  ((-2 + eps - 2 eps^2)^2 Gamma[1 - eps]^6 Gamma[1 + eps]^2 *
    (120 - 20 eps^2 Pi^2 - 80 eps^3 Zeta[3] + eps^4 Pi^4)) /
    (1920 eps^4 Gamma[2 - 2 eps]^2),
  {eps, 0, 0}]];

checks = <|
  "CorrectionSourceRecorded" ->
    ledger["CorrectionSource"] === "arXiv:2211.08446v2",
  "BreveShiftIsZero" ->
    TrueQ[FullSimplify[ledger["A22OneLoopSelfPoleShift"]] === 0],
  "CorrectedMasterConventionFactor" ->
    TrueQ[FullSimplify[
      Coefficient[A22OneLoopSelfVirtualConventionFactor[], Zeta[3] eps^3] ===
        -2/3],
  "FiniteBreveConventionIsCorrected" ->
    TrueQ[FullSimplify[
      Coefficient[A22OneLoopSelfVirtualConventionFactor[], Zeta[3] eps^4] ===
        0],
  "IntegratedBreveMatchesCorrectedLiteraturePole" ->
    TrueQ[FullSimplify[correctedBreveFromMaster - breve] === 0],
  "BreveIsUnchangedByObservableAdapter" ->
    TrueQ[FullSimplify[observable["intBreveA22"] - breve] === 0],
  "CorrectedBreveZetaPoleIsRetained" ->
    TrueQ[FullSimplify[
      Coefficient[observable["intBreveA22"], Zeta[3]/eps] === -7/6]
|>;

Print[ExportString[<|"Regression" -> "RRatioA22BreveCorrection",
  "Checks" -> checks, "Passed" -> And @@ Values[checks]|>, "JSON",
  "Compact" -> True]];
Quit[If[And @@ Values[checks], 0, 1]];
