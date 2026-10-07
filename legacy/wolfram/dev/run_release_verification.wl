(*
  RETIRED ENTRYPOINT

  This former single-kernel smoke suite only established that selected calls
  returned without $Failed.  It did not test fresh-kernel state isolation,
  wrapper composition, or declared physics evidence, and therefore must not be
  used as a release check.

  Use instead:
    bash dev/run_release_verification.sh

  That driver runs dev/release_acceptance_worker.wl once per fresh kernel and
  distinguishes Validated, Unvalidated, Failed, and InconclusiveTimeout cases.
*)

Print["This entrypoint is retired: it was a single-kernel smoke suite, not a physics-validation gate."];
Print["Run: bash dev/run_release_verification.sh"];
Exit[2];
