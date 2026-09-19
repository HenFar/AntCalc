repoRoot = DirectoryName[$InputFileName];

archive = CreatePacletArchive[repoRoot, $TemporaryDirectory];

(* PacletInstall replaces a matching version but deliberately permits several
   versions of a paclet to coexist.  AntCalc` would then resolve to the
   highest installed version, which can be an older checkout's release.
   This development updater is intended to make this checkout authoritative,
   so remove every user-installed AntCalc copy before installing its archive. *)
Scan[PacletUninstall, PacletFind["AntCalc"]];

PacletInstall[archive, ForceVersionInstall -> True];

PacletDataRebuild[];
