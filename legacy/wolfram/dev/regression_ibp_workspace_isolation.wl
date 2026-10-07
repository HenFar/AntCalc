(* Fresh-kernel regression for LiteRed's implicit IBPReduction* cache output.
   Run from the repository root with:
     wolfram -script dev/regression_ibp_workspace_isolation.wl
   The test deliberately preserves any pre-existing diagnostic directories. *)

repoRoot = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]];

ClearAll[ibpDirectories, a31Result, ibpWorkspaceReport];

ibpDirectories[root_] :=
  Sort @ Select[FileNames["IBPReduction*", root], DirectoryQ];

repositoryBefore = ibpDirectories[repoRoot];
temporaryBefore = Sort @ Select[
   FileNames["AntCalc-IBP-*", $TemporaryDirectory], DirectoryQ];
workingDirectoryBefore = Directory[];

a31Result = BuildAndIntegrateAntenna[A, 3, 1,
  UseStoredResults -> False,
  StoreResults -> False];

repositoryAfter = ibpDirectories[repoRoot];
temporaryAfter = Sort @ Select[
   FileNames["AntCalc-IBP-*", $TemporaryDirectory], DirectoryQ];

ibpWorkspaceReport = <|
  "Regression" -> "IBPWorkspaceIsolation",
  "Checks" -> <|
    "A31IntegrationReturned" -> FreeQ[a31Result, $Failed],
    "WorkingDirectoryRestored" -> (Directory[] === workingDirectoryBefore),
    "NoNewRepositoryIBPReductionDirectory" ->
      Complement[repositoryAfter, repositoryBefore] === {},
    "TemporaryWorkspaceCleaned" ->
      Complement[temporaryAfter, temporaryBefore] === {}
    |>,
  "RepositoryIBPDirectoriesBefore" -> repositoryBefore,
  "RepositoryIBPDirectoriesAfter" -> repositoryAfter
  |>;
ibpWorkspaceReport = Join[ibpWorkspaceReport,
  <|"Passed" -> And @@ Values[ibpWorkspaceReport["Checks"]]|>];
Print[ibpWorkspaceReport];
