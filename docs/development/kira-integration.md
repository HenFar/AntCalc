# FORM / Kira integration internals

[Developer index](README.md) · [User workflow](../manual/kira-workflow.md) · [Python source](../../src/antcalc/README.md)

AntCalc 0.3.5's checkout runner separates construction from integration. Wolfram builds
an invariant expression; Python maps its monomials to cut integral families;
FORM combines rational coefficients; Kira reduces integrals; FORM applies
reduction rules and analytic masters. The Python workflow does not dispatch
through `AntennaIntegrationProfile` or return `AntennaRunRecord` objects.

## Source map

| File or directory under `src/antcalc/` | Responsibility |
|---|---|
| `orchestrator.py` | card loading, antenna checks, method dispatch, tool discovery for builds |
| `build_methods.py` | Wolfram session and expression conversion via the legacy build loader |
| `integrate_methods.py` | legacy Wolfram build-and-integrate adapter |
| `paths.py` | checkout and legacy-loader path boundary |
| `integrate_kira.py` | input parsing, family mapping, FORM/Kira execution, closure, scale and output checks |
| `form/simplify_before_kira.frm` | canonicalise the input using `PolyRatFun rat` |
| `form/simplify_after_kira.frm` | apply accumulated Kira rules and convert `num*den` to `rat` |
| `form/substitute_masters.frm` | include the multiplicity-selected analytic masters |
| `kira/templates/` | immutable family and kinematics inputs copied into scratch state |
| `masters/masters_R3.inc`, `masters_R4.inc` | normalised analytic masters and fixed epsilon expansions |

Wolfram stage loaders live in repository-root `legacy/wolfram/loaders/`.
The comparison harness and references live in `tests/kira/`, outside source.

## Input and family mapping

`IntegrationRun` records family, multiplicity, loop order, input selection,
and master-substitution choice. `run_integration` checks perturbative order,
parses the input with `parse_mathematica`, then processes each top-level list
element as a separate antenna component. It returns a list of
`(master_combination, scale_dict, integrated_or_None)` tuples as well as
writing files. There is no direct command-line entry point in
`integrate_kira.py`; use the orchestrator or call this Python function.

`build_kinematics(n)` represents each invariant by a vector over all pair
invariants. A subset invariant is the sum of pairs inside it; `q2` has a one
in every position. This representation supplies the linear relations used
when a family lacks an explicit numerator invariant.

`kira_integral_families` reads `integralfamilies.yaml` in template order. It
requires massless list-form propagators and `n-1` integration momenta. For
non-cut propagators, it rewrites `q` as the sum of final-state momenta and
recognises squared sums of subsets, including their overall negatives.
A one-parton momentum is on-shell and must be marked as a cut. Bilinear
numerator strings and general loop momenta are outside this mapping.

`read_to_dict_tuple` splits the numerator into monomials and separates
coefficients from invariant powers. `list_to_basis` takes the first family
whose invariants cover the denominators. If numerator invariants are missing,
`numerator_expand` solves their linear relation in the family's invariants
plus `q2`, expands it, and checks coverage again. If no family represents a
term, the integrator raises `ValueError`.

`term_to_form` negates invariant powers to obtain integral indices. Cut
positions are inserted with index one, preserving the YAML propagator order.
For example, denominator factors give positive indices and numerator factors
give negative indices. Coefficients become `rat(numerator,denominator)`.
Declarations include every configured family, allowing Kira to introduce a
master from a different family.

## FORM boundary

All scripts read `../tmp/declarations.inc` and `../tmp/antenna.inc` relative
to `src/antcalc/form/`. `run_form` captures FORM's printed `antenna = ...;`,
removes whitespace, and overwrites `antenna.inc` with the latest expression.
The pre-reduction FORM stage combines the input before Kira targets are
chosen. `form_to_pairs` expects top-level coefficient–integral products with
`rat` coefficients.

The shared scratch includes are overwritten by each stage and component.
They are diagnostic working state, not immutable run artifacts. Parallel
runs in one checkout can interfere even when Kira work roots differ.

## Dynamic Kira jobs and reduction closure

Every component begins with `clear_kira_results`: delete
`KIRA_RUN_DIR / antenna_name`, then copy the template's `config/` into it.
The default root is the system temporary directory's `antcalc_kira/`;
`ANTCALC_KIRA_DIR` is read when the module is imported. This avoids reusing
Kira databases and sector mappings from a previous expression.

The reduction loop is:

1. Write integral targets in bracket notation to `toReduce`.
2. Derive per-family seed limits from target indices. For each integral,
   `r` is the sum of positive indices, `s` the absolute sum of negative
   indices, and dots are `r` minus the number of positive indices.
3. Write `jobs.yaml` with `reduce_sectors`, mandatory targets, and `kira2form`.
   Initial limits are `max(top_sector_lines, r)+1`, `s+1`, and `dots+1`.
   The first configured top-level sector is used for each family.
4. Run Kira, deleting the expected export beforehand so a stale export cannot
   be accepted. The export is `results/<target>/kira_toReduce.inc`.
5. Collect master candidates from rule right-hand sides and requested integrals
   without a rule. Remove integrals appearing on rule left-hand sides.
6. Feed candidates back to Kira, keeping seed limits nondecreasing and the
   original export target fixed. Append each export to
   `tmp/kira_substitutions.inc` with a `.sort` boundary.
7. Stop when a pass adds no substitution rules.

The initial export target is the first sorted seeded family. Subsequent
passes preserve it so one export carries the requested rules. Closure is
measured by the accumulated rule count, not by a physics assertion that all
remaining integrals are known masters. There is no configured pass limit or
subprocess timeout. Analytic coverage is checked separately when substitution
is enabled.

The retained Kira directory belongs to the last processed component. To audit
an earlier component's raw Kira state, run that component alone and preserve
its scratch directory before the next run.

## Scale extraction

After FORM applies the accumulated rules, the integrator saves the master
combination and checks its dimensions. An integral with `L` integration
momenta and indices `a_i` scales as

```text
(q2)^(2 L - Sum[a_i] - L ep).
```

`q2_power` requires numerator and denominator coefficients to be homogeneous
in `q2`. For each term, its coefficient's `q2` degree plus
`2 L - Sum[a_i]` must vanish. All terms must share the same `L`.
Dividing by `Phi2` leaves `k = L-1`, checked against
`multiplicity - 2 + loop_order`. The saved record is:

```json
{
  "q2_power": 0,
  "q2_ep_power": -1,
  "factor": "(q2/mu2)^(-1*ep)",
  "terms_checked": 1
}
```

This is an illustrative one-term NLO record; the term count comes from the
actual reduced expression. Keep `q2` symbolic in Kira for this check.
Setting it to one during reduction would discard dimensional information.

## Analytic closure and epsilon series

When `substitute_masters` is enabled, `masters_file` selects by multiplicity:
`masters_R3.inc` for three partons and `masters_R4.inc` for four. It does not
select by loop order; template presence cannot supply support for loop antennae.

`check_masters_covered` requires a matching analytic `id` rule for every
remaining integral. Its error also identifies missing candidates marked as
unreduced in `kira.log`. FORM substitutes the masters, sets `d = 4-2*ep`,
and sets `q2 = 1` after dimensional checking. The normalised masters already
include `C(ep,k)/Phi2` at `mu2 = q2`. R3 retains antenna terms through `ep^2`;
R4 retains terms through `ep^0`. `check_fully_substituted` rejects remaining
configured family calls before the final `.inc` is saved.

Reduction-only mode skips analytic coverage and substitution, but still
requires the scale check. It is useful for inspecting a master combination;
it does not certify that all remaining integrals have analytic expressions.

## Maintenance and evidence

For a new route, the template must satisfy the mapper's massless propagator,
cut-position, momentum-count, and invariant-coverage assumptions. Its
propagator order must agree with both exported integral indices and analytic
master rules. Extend those assumptions explicitly for loop or massive routes;
copying a template alone is insufficient.

Keep scale information through Kira, supply normalised analytic masters to
the needed epsilon depth, and add an independent component reference and
suite case. Changes to family ordering can change which basis a monomial
uses, so compare both reduction closure and final series.

The existing suite covers `A30`, both `A40` components, `B40`, and `C40`.
It compares coefficients from powers -4 through 2 against thesis Appendix A
series and records scales. It does not rebuild inputs or qualify the broader
Wolfram package. Checked-in outputs and a documented suite are not evidence
of a fresh successful run; retain logs and the summary for any validation claim.
