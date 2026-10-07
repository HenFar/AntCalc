# AntCalc next: Python, FORM and Kira

The refit of AntCalc's integration stage (thesis, Chapter 6): the unintegrated antenna is built by
the Mathematica pipeline and integrated through FORM and Kira. Run from the repository root:

    python src/next/orchestrator.py [runcard]     # runcards/<runcard>.json, default runcard

## Runcard (`runcards/runcard.json`)

- `build`, `integrate`: 1 or 0. `build_method`: `pythonToWl` or `legacy`. `integrate_method`: `kira` or `legacy`.
- `family`, `multiplicity`, `loop_order`: the antenna, e.g. `A`, `4`, `0`.
- `substitute_masters`: 1 to substitute the analytic masters and expand in ep, 0 to stop at the master combination.
- `auto_input_path`: 1 to integrate `results/unintegrated/unintegratedXij.m`; 0 to use `manual_input_path`,
  relative to the repository root.

## Layout

- `orchestrator.py`: runcard, build and integrate routing. `build_methods.py`, `build_pipeline.wl`: the build.
- `integrate_kira.py`: the integrator. Each list element of the input is integrated separately; Kira's
  reduction is closed by re-reducing the masters until no new rule appears, with `jobs.yaml` generated from
  the integrals. The antenna's scale is read from the master combination, whose integer powers of q2 must cancel.
- `form/`: FORM scripts. `masters/`: analytic masters times C(ep,k)/Phi2 at mu^2 = q2 (`masters_R3.inc`, `masters_R4.inc`).
- `kira/templates/`: integral families per antenna. Kira itself runs in the system temp folder
  (`antcalc_kira/`, or `ANTCALC_KIRA_DIR`), never in the repository.
- `integrate_methods.py`, `integrate_pipeline.wl`: the legacy Mathematica integration.
- In the repository root, `results/`: `unintegrated/` (pythonToWl build), `unintegrated_legacy/`, `integrated/`
  (`<antenna>_<i>_masters.inc`, `_scale.json`, `_integrated.inc`) and `integrated_legacy/`.

## Tests

    python src/next/tests/run_suite.py [A30 A40 B40 C40]

Integrates each antenna from `results/unintegrated/` and compares it with the thesis (Appendix A), writing
`src/next/tests/output/summary.md`. Needs Kira, FORM and `FERMATPATH`.
