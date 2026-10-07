# AntCalc developer documentation

[Documentation home](../README.md) · [Manual](../manual/index.md)

- [Repository structure and dependency boundaries](repository-layout.md)
- [FORM / Kira integration internals](kira-integration.md)
- [Regression tests](../../tests/README.md)
- [Legacy Wolfram development guides](../legacy/development/README.md)

The current runner belongs in `src/antcalc/`. Wolfram implementation changes
belong in `legacy/wolfram/` until those operations are migrated to other tools.
Retain the physics references and validation evidence when changing a backend.

## Planned changes

- **One entry point, one import style.** `orchestrator.py` and `integrate_kira.py`
  can run both as plain scripts (`python src/antcalc/orchestrator.py`) and as a
  package (`python -m antcalc`). Python resolves imports differently in the two
  cases, so each module imports its siblings twice, under `if __package__:`.
  Every new module must be added to both branches, and one missed is only noticed
  when the other command is used. The plan is a single entry point, for instance a
  short `run.py` at the repository root that puts `src/` on the path and calls
  `antcalc.orchestrator`, so the package uses only relative imports.
- **Concurrent runs of one antenna.** FORM's include files are per expression,
  but an antenna's Kira folder (`antcalc_kira/<antenna>`) and its output names in
  `results/integrated/` are shared, so the same antenna cannot be integrated twice
  at once. Per-run Kira folders and output names would lift this.
