(* Contribution-resolution contract
   ================================
   Fast, no-backend regression for the public-component/source-branch split.
   Run in a fresh kernel after loading AntCalc. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "AntennaPipeline.wl"}]];

expectedAll = <|
  "Leading" -> {TwoLoopTree},
  "Subleading" -> {TwoLoopTree},
  "Nf" -> {TwoLoopTree},
  "Breve" -> {OneLoopSelf}
|>;

checks = <|
  "ContributionIsNotAPublicBuildOption" ->
    FreeQ[First /@ Options[BuildAntenna], Contribution],
  "ContributionIsNotAPublicObjectBuildOption" ->
    FreeQ[First /@ Options[BuildAntennaObject], Contribution],
  "ContributionIsNotAPublicIntegrationOption" ->
    FreeQ[First /@ Options[IntegrateAntenna], Contribution],
  "ContributionIsNotAPublicOneShotOption" ->
    FreeQ[First /@ Options[BuildAndIntegrateAntenna], Contribution],
  "A22AllPlan" -> AntennaContributionsUsed[{A, 2, 2}, All] === expectedAll,
  "A22LeadingPlan" ->
    AntennaContributionsUsed[{A, 2, 2}, Leading] === {TwoLoopTree},
  "A22BrevePlan" ->
    AntennaContributionsUsed[{A, 2, 2}, Breve] === {OneLoopSelf},
  "A22LeadingSource" ->
    AntennaInternalContribution[{A, 2, 2}, Leading] === TwoLoopTree,
  "A22BreveSource" ->
    AntennaInternalContribution[{A, 2, 2}, Breve] === OneLoopSelf,
  "A20HasNoContributionDecomposition" ->
    AntennaContributionsUsed[{A, 2, 0}, All] === Missing["NotApplicable"]
|>;

<|"Regression" -> "ContributionResolutionContract", "Checks" -> checks,
  "Passed" -> And @@ Values[checks]|>
