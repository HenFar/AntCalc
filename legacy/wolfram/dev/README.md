# `dev/` Script Map

`dev/` is not part of the canonical runtime. It contains support material for
verification, benchmarking, provenance, and historical exploration.

Use this directory in three modes.

## 1. Release Verification

The canonical release acceptance script is:

- [run_release_verification.sh](run_release_verification.sh)

This checks the supported massless release matrix and the beta massive-`A30`
closure. It is the only supported release gate; `run_release_verification.wl` is a retired explanatory
stub, kept solely to stop old commands from producing a misleading smoke-pass.

It starts one fresh Wolfram kernel per case, writes one JSON evidence report per
case. It distinguishes `Validated`, `Unvalidated`, `Failed`, and
`InconclusiveTimeout`: a completed calculation or an empty diagnostics
association is not a validation pass. The driver exits nonzero if any case is
unvalidated, failed, or times out. The default timeout is two hours; override
it with `ANTCALC_RELEASE_TIMEOUT`. For a final defence evidence bundle, retain
the reports with:

```sh
ANTCALC_RELEASE_KEEP_OUTPUT=1 \
ANTCALC_RELEASE_OUTPUT_DIR=/path/to/release-evidence \
./dev/run_release_verification.sh
```

The route-level worker is
[release_acceptance_worker.wl](release_acceptance_worker.wl).
For a short selected rerun, set `ANTCALC_RELEASE_CASES`, for example
`ANTCALC_RELEASE_CASES=A20,A21,A30 ./dev/run_release_verification.sh`.

Each JSON report records the validation tier, scope, declared required checks,
and observed evidence. `ExternalLiterature` is eligible for `Validated` when
all declared checks pass. `InternalConsistency` is deliberately reported as
`Unvalidated` even when its residual checks pass; it is useful evidence but not
a substitute for an independent target. A22 is checked against the separately
declared `hep-ph/0403057v2` equations in
[`a22_literature_reference.wl`](a22_literature_reference.wl), while A31 uses
[`a31_literature_reference.wl`](a31_literature_reference.wl) for
`hep-ph/0505111v3`; each requires a successful fresh-kernel acceptance run to
be reported as validated. R-ratio LO/NLO remain unvalidated until explicit
external lower-order targets are added.

## 2. Performance / Benchmarks

The main benchmark entrypoint is:

- [run_public_route_benchmarks.wl](run_public_route_benchmarks.wl)
- [benchmarks/massive_a30/](benchmarks/massive_a30/), for the fresh-kernel
  massive-`A30` epsilon-depth benchmark

Use it when you want timing data, not when you want a release pass/fail check.

## 3. Research / Provenance

The main structured research areas are:

- [audits/a22/](audits/a22/), for convention and master-provenance audits
- [diagnostics/a22/](diagnostics/a22/), for focused loop-reduction and
  release-residual diagnosis
- [massiveA30/](massiveA30)
- [massiveA30_sources/](massiveA30_sources)
- [src_legacy_flat_2026-06-14/](src_legacy_flat_2026-06-14)

Top-level `regression_*.wl` scripts protect focused public contracts. Other
one-off historical derivations remain retained for provenance, but are not
part of the supported package workflow.

If you are new to the repo, start from:

1. the top-level [README.md](../README.md)
2. [src/README.md](../src/README.md)
3. [run_release_verification.sh](run_release_verification.sh)
