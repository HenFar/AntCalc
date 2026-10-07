# Kira templates

[User workflow](../../../docs/manual/kira-workflow.md) · [Reduction internals](../../../docs/development/kira-integration.md)

One directory per antenna (`A30`, `A40`, `B40`, `C40`, `A31`, `A22`), each holding only
`config/integralfamilies.yaml` and `config/kinematics.yaml`. Kira never runs here: for each
expression, `integrate_kira.py` copies the template's `config/` into a fresh folder in the system
temp directory (`antcalc_kira/<antenna>`, or `$ANTCALC_KIRA_DIR`), writes `toReduce` and `jobs.yaml`
there before each pass, and runs Kira in it.

- Families are the LiteRed bases of the legacy pipeline, with propagators in LiteRed `Ds[basis]`
  order, so `j[B, a1..an]` corresponds to `B[a1,..,an]`. `A40`, `B40` and `C40` hold the same 72
  families (chain, box and hybrid bases).
- Kira's convention: `[mom, m]` is `mom^2 - m`.
- `A30`, `A40`, `B40` and `C40` keep `q2` symbolic in Kira, which the integrator's scale check needs.
  `A31` and `A22` still set `symbol_to_replace_by_one: q2`; their families use bilinear numerators
  and no cuts, which the integrator does not handle yet.

The work directory for an antenna is deleted and recreated for each input
component; it is not a permanent reduction cache. `ANTCALC_KIRA_DIR` is a
scratch-root override read at Python import time. Generated `jobs.yaml` uses
the first `top_level_sectors` entry per family and seed bounds derived from
the actual targets; bounds only grow during a component's closure passes.
Keep template propagator order aligned with the analytic master rules in
`src/next/masters/`. A template alone does not establish integration support.
