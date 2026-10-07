# Legacy Wolfram implementation

[Project README](../../README.md) · [Legacy documentation](../../docs/legacy/README.md)

This directory preserves the Wolfram package, its paclet entry points, and
its dependent runtime assets. The paclet is frozen at `0.3.0-beta.1`: it is no
longer released, and its version and release ledger are not advanced. AntCalc's
project version (currently 0.3.5) is the Python runner's.

## Active dependency boundary

AntCalc's `pythonToWl` build and `legacy` build/integration methods load
`loaders/build_pipeline.wl` and `loaders/integrate_pipeline.wl` directly.
Those loaders set `$AntennaPipelineRoot` to this directory. Consequently,
`src/`, `bases/`, `generated_bases/`, `masterIntegrals/`, and `stored_results/`
retain their package-relative paths. Keep them together until the associated
operations are converted to other tools.

- `src/`: Wolfram core, engines, routes and interfaces.
- `loaders/`: build-only and integration loaders used by the Python runner.
- `AntennaPipeline.wl`, `AntCalc.wl`, `Kernel/`, `PacletInfo.wl`: direct and
  packaged Wolfram entry points.
- `bases/`, `generated_bases/`: LiteRed basis assets.
- `masterIntegrals/`: analytic derivations and the runtime master artifact.
- `stored_results/`: legacy Wolfram replay caches.
- `dev/`: retained Wolfram regressions, benchmarks, derivation helpers and
  provenance investigations. Some basis generators are runtime helpers, so
  this directory remains alongside the legacy package.

The retired verification scripts and old flat source snapshot are in
[research/wolfram/](../../research/wolfram/). The package's maintained helper
scripts remain here to preserve their existing relative-path relationships.

## Direct Wolfram use

Load the checkout with:

```wl
Get["/path/to/form-kira-lab/legacy/wolfram/AntennaPipeline.wl"]
```

To build a paclet, pass `/path/to/form-kira-lab/legacy/wolfram` to
`CreatePacletArchive`, rather than the project root. The normal Python
runcard workflow does not require installing the paclet.

For legacy verification, from the project root:

```sh
cd legacy/wolfram
bash dev/run_release_verification.sh
```

That package-wide acceptance gate is distinct from the current runner tests
under repository-root `tests/`.
