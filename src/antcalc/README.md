# AntCalc 0.3.5: Python, FORM and Kira

This directory implements AntCalc 0.3.5's main runcard workflow. Wolfram
constructs the unintegrated antenna; FORM and Kira integrate its invariant
expression. The project version is independent of the legacy Wolfram paclet.
Legacy routes remain available while they are progressively converted to
other tools; the runner loads Wolfram source from the checkout directly.

From the repository root, with dependencies installed:

```sh
python src/next/orchestrator.py            # runcards/runcard.json
python src/next/orchestrator.py my_run     # runcards/my_run.json
```

The default card builds and integrates massless `A40`. The implemented Kira
scope is `A30`, `A40`, `B40`, and `C40`; `A31`/`A22` templates are preparatory.

Read the full documentation:

- [User guide: setup, runcards, input/output, scale and troubleshooting](../../docs/manual/kira-workflow.md)
- [Developer guide: mapping, dynamic jobs, closure and analytic masters](../../docs/development/kira-integration.md)
- [Kira template conventions](kira/README.md)

## Layout

- `orchestrator.py`: runcard selection and build/integrate method dispatch.
- `build_methods.py`, `build_pipeline.wl`: Wolfram construction and conversion.
- `integrate_kira.py`: invariant mapping, reduction, scale checks and substitution.
- `form/`: FORM scripts; generated includes live in shared `tmp/` scratch state.
- `kira/templates/`: configurations copied to disposable Kira working directories.
- `masters/`: analytic masters times `C(ep,k)/Phi2` at `mu2 = q2`.
- `integrate_methods.py`, `integrate_pipeline.wl`: legacy Wolfram integration.
- `tests/`: integrate-only comparisons with thesis Appendix A.
- `requirements.txt`: pinned Python dependencies.

Build results go to repository-root `results/unintegrated/` or
`results/unintegrated_legacy/`. Kira writes component-indexed `_masters.inc`,
`_scale.json`, and optional `_integrated.inc` files to `results/integrated/`;
legacy integration writes to `results/integrated_legacy/`.

Kira runs in `<system temp>/antcalc_kira/<antenna>/` or
`$ANTCALC_KIRA_DIR/<antenna>/`. That antenna directory is deleted and recreated
for every component. FORM scratch files and output names are shared; run
integrations sequentially within a checkout.

## Comparison suite

```sh
python src/next/tests/run_suite.py [A30 A40 B40 C40]
```

With no antenna arguments, all four cases run. Requires FORM, Kira, Fermat,
and the Python dependencies. Set `FERMATPATH` explicitly. The suite replaces
selected integrated outputs and writes logs plus `tests/output/summary.md`.
`A30` is compared through `ep^2`, four-parton tree antennae through `ep^0`.
