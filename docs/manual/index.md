# AntCalc manual

[Documentation home](../README.md) · [Developer documentation](../development/README.md)

The current entry point is `src/antcalc/orchestrator.py`. It reads a runcard,
builds with the selected method, and integrates with Kira or the legacy
Wolfram route.

- [Running the FORM / Kira workflow](kira-workflow.md): setup, cards, inputs,
  outputs, normalisation and troubleshooting.
- [Repository structure](../development/repository-layout.md): where current
  code, legacy dependencies, tests and research material live.
- [Test guide](../../tests/README.md): operational and physics comparisons.

For direct use of the retained Wolfram API, use the
[legacy package documentation](../legacy/README.md). Its version and route
support contract are independent of AntCalc 0.3.5's runner.
