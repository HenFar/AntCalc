# AntCalc tests

Run from the repository root with the Python dependencies installed and
FORM, Kira, Fermat, and (for builds or legacy integration) Wolfram available.
Set `FERMATPATH` explicitly.

## Runcard operations

```sh
python tests/runcards/run_operations.py
```

This runs ten real `A30` runcards: both build methods, both integration
methods, all four combined method pairs, manual Kira input, and reduction-only
Kira integration.
Manual input also exercises the `python -m antcalc` entry point from another
working directory. The suite preserves the original A30 result files and writes a
report plus subprocess logs to `tests/runcards/output/`. Run it sequentially
with other integrations because FORM scratch files are shared.

To compare across a future restructure, save the first report outside the
checkout, then run against it after the change:

```sh
python tests/runcards/run_operations.py --output-dir /tmp/antcalc-before
python tests/runcards/run_operations.py --compare /tmp/antcalc-before/summary.json
```

The comparison checks exit status and output content after removing whitespace.
This protects operational behaviour; it is separate from physics validation.

## Kira physics comparisons

```sh
python tests/kira/run_suite.py
python tests/kira/run_suite.py A30 A40 B40 C40
```

The suite integrates existing inputs and compares the results with thesis
Appendix A references. It covers A30, A40 leading/subleading, B40, and C40.
It writes `tests/kira/output/summary.md` and individual logs, and replaces
selected files in `results/integrated/`.
NNLO calculations can take several minutes; this suite does not impose a
subprocess timeout.

## Legacy Wolfram tests

The retained package regressions and acceptance driver live in
`legacy/wolfram/dev/`, where their package-relative asset paths remain valid:

```sh
cd legacy/wolfram
bash dev/run_release_verification.sh
```

See the [legacy script map](../legacy/wolfram/dev/README.md) for their scope.
