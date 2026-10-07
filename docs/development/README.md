# AntCalc developer documentation

[Documentation home](../README.md) · [Manual](../manual/index.md)

- [Repository structure and dependency boundaries](repository-layout.md)
- [FORM / Kira integration internals](kira-integration.md)
- [Regression tests](../../tests/README.md)
- [Legacy Wolfram development guides](../legacy/development/README.md)

The current runner belongs in `src/antcalc/`. Wolfram implementation changes
belong in `legacy/wolfram/` until those operations are migrated to other tools.
Retain the physics references and validation evidence when changing a backend.
