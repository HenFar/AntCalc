# Running the FORM / Kira integration workflow

[Manual index](index.md) · [Pipeline internals](../development/kira-integration.md) · [Repository README](../../README.md)

AntCalc 0.3.5's Python runner in `src/antcalc/orchestrator.py` selects build and integration
methods from a JSON runcard. `integrate_method: "kira"` sends a massless
invariant expression through FORM, Kira IBP reduction, scale checking, and
optional analytic-master substitution. The runner is the project's main
entry point and does not require paclet installation. Its Wolfram stages load
source directly from the checkout. The legacy paclet retains its own version
and `IntegrateAntenna` routes while those routes are converted to other tools.

## Supported inputs

| Antenna | Input components | Analytic output depth |
|---|---|---|
| `A30` | one scalar | through `ep^2` |
| `A40` | ordered list: leading, subleading | through `ep^0` |
| `B40` | one scalar | through `ep^0` |
| `C40` | one scalar | through `ep^0` |

This is the implemented Kira scope and comparison-suite coverage, not an
extension of the Wolfram package release guarantee. `A31` and `A22` have
configuration templates, but their loop-momentum layouts and numerator
representations are not supported by the current mapper. `A21` has no Kira
template. Massive antennae are outside this workflow.

The order check accepts only `k = multiplicity - 2 + loop_order` equal to 1
or 2. Passing that check does not establish template or master support.
Epsilon depth is fixed in the master include files; there is no runcard
`ExpansionOrder` setting.

## Environment

From the repository root:

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
export FERMATPATH=/absolute/path/to/fermat/executable
```

The pinned dependencies include `wolframclient`, SymPy, PyYAML, and ipykernel.
The implementation uses Python's `match` syntax and requires Python 3.10 or
newer; the selected interpreter must also satisfy the pinned packages'
requirements.

External tools:

- FORM: the runner searches `PATH` for `form`, then `tform`, then `parform`.
- Kira: `kira` must be on `PATH`.
- Fermat: `FERMATPATH` must name the executable used by Kira. The integrator
  checks that the variable is set; it does not validate the executable itself.
- For builds and legacy integration: `wolframscript`, a licensed Wolfram
  kernel, and the symbolic packages described in [installation](../legacy/manual/installation.md).

An integrate-only Kira run does not launch Wolfram, although the orchestrator
imports the Wolfram client at startup. `pythonToWl` builds also perform a FORM
availability check, even though the current build function does its expression
conversion in Wolfram.

## A complete runcard

Save this as `runcards/kira_a30.json`:

```json
{
  "build": 0,
  "build_method": "pythonToWl",
  "build_print_to_terminal": 1,
  "integrate": 1,
  "integrate_method": "kira",
  "integrate_print_to_terminal": 1,
  "family": "A",
  "multiplicity": 3,
  "loop_order": 0,
  "auto_input_path": 1,
  "manual_input_path": "",
  "substitute_masters": 1
}
```

Run:

```sh
python src/antcalc/orchestrator.py kira_a30
```

Supply the card's basename without `.json`. With no argument, the runner uses
`runcards/runcard.json`, currently configured to build and integrate `A40`.
Card and result paths are resolved relative to the repository, not the shell's
current directory.

| Field | Behaviour |
|---|---|
| `build`, `integrate` | use integer `0` or `1`; valid combinations are build-only, integrate-only, or both |
| `build_method` | `pythonToWl` or `legacy` |
| `integrate_method` | `kira` or `legacy` |
| `family`, `multiplicity`, `loop_order` | identify the antenna; family spelling is uppercase `A`, `B`, or `C` |
| `auto_input_path` | defaults to `1` for Kira; reads `results/unintegrated/unintegratedXij.m` |
| `manual_input_path` | used when automatic input is off; relative paths resolve from the repository root, absolute paths also work |
| `substitute_masters` | defaults to `1`; `0` returns only the master combination and scale |
| `build_print_to_terminal`, `integrate_print_to_terminal` | required by the current card reader, but not used to suppress output |

Keep the build and integration method fields and both print fields even when
a stage is disabled: the card reader accesses them unconditionally. Use
numeric toggles; nonempty JSON strings such as `"0"` become true in the Kira
options' boolean conversion.

## Building or supplying an expression

Set `build: 1` and `build_method: "pythonToWl"` to create Kira's default input.
This calls `BuildAntenna[..., ReductionBackend -> None]`, converts
`Epsilon` to `(4-d)/2`, rewrites propagators and scalar products, and applies
`Together`. Output goes to `results/unintegrated/`.

A manual input should contain a Wolfram expression or a top-level list of
expressions parseable by SymPy's Mathematica parser. For example, the saved
`A30` input is:

```wl
(4*s12^2 + 4*s12*s13 - 2*s13^2 + d*s13^2 + 4*s12*s23 -
 8*s13*s23 + 2*d*s13*s23 - 2*s23^2 + d*s23^2)/(2*q2*s13*s23)
```

The mapper expects rational monomials in massless invariants `s12`, `s13`,
`s23`, and, for four partons, the other pair and triple invariants. It uses
`s_I = Sum[s_ij]` over pairs inside `I`, and `q2` is the sum over all pairs.
Unconverted FeynCalc heads, antenna objects, and arbitrary loop-integral
expressions are not this input contract. Each list element is integrated
separately; the files retain its positional index, without component metadata.

To use a custom input, set `auto_input_path: 0` and, for example,
`manual_input_path: "results/unintegrated/customA30.m"`.

`build_method: "legacy"` writes to `results/unintegrated_legacy/`, while
Kira's automatic input still reads `results/unintegrated/`. Combining these
settings does not forward the newly built legacy expression to Kira. Manual
selection only works if the expression has the required invariant form.

`integrate_method: "legacy"` calls Wolfram's `BuildAndIntegrateAntenna`
and writes `results/integrated_legacy/integratedXij.m`; it rebuilds the antenna
rather than consuming the Kira input settings.

## Outputs and normalisation

For component `i`, a successful full run creates:

| File in `results/integrated/` | Contents |
|---|---|
| `Xij_i_masters.inc` | `Local antenna = ...;` with rational coefficients in `d`, `q2` and master-family calls |
| `Xij_i_scale.json` | checked integer and epsilon powers of `q2`, scale factor, and number of checked terms |
| `Xij_i_integrated.inc` | `Local antenna = ...;` with `ep`, `pi`, and `z3 = zeta(3)` |

The analytic masters include `C(ep,k)/Phi2` at `mu2 = q2`, with
`d = 4 - 2*ep`. The scale record supplies `(q2/mu2)^(-k*ep)` separately:
`k = 1` for `A30` and `k = 2` for four-parton tree antennae. To restore scale
dependence, multiply the saved series by this factor and expand to the desired
available order. The integrator does not multiply it into the `.inc` result.

The scale check requires the integer `q2` powers of every master term to
cancel and all terms to have the expected number of integration momenta.
Missing analytic masters or leftover integrals cause a failure rather than a
partly substituted final result.

Files are written in stages: a failed scale check can leave a master file,
and a failed master substitution can leave both masters and scale. The runner
does not remove old `_integrated.inc` files when substitution is disabled or
fails. Check the current run's completion and settings before reusing outputs.

## Scratch files and repeat runs

FORM's include files go to a folder of their own for each input component,
`src/antcalc/tmp/<antenna>_<i>_<time>_<id>/`. The folder is deleted when the
component integrates successfully and kept when it fails; the error message
names it, so the files FORM was working on can be inspected. Kira uses
`<system temp>/antcalc_kira/Xij/`, or `$ANTCALC_KIRA_DIR/Xij/` when the override
is set before starting Python. Keep Kira's work directory outside synced
folders: its database must remain consistent during reduction.

For every input component, the integrator deletes that antenna's Kira work
folder and copies a fresh template configuration into it. Use
`ANTCALC_KIRA_DIR` only for disposable scratch data. After a multi-component
run, the folder holds the last component's Kira state. The Kira folder and
the output names are shared per antenna: different antennae can run in
parallel, the same antenna only sequentially.

## Comparing with the thesis

```sh
python tests/kira/run_suite.py          # all four supported antennae
python tests/kira/run_suite.py A30      # one antenna
```

The suite runs integrate-only runcards against `results/unintegrated/`, clears
the selected antenna's existing integrated outputs, and compares the series
with `tests/kira/references.py`. It checks coefficients from `ep^-4`
through `ep^2` (the four-parton references end at `ep^0`). Scale factors are
reported in the summary; the integrator itself enforces their order check.
References for `A31` and `A22` exist in the reference file but are not suite cases.

Logs and `summary.md` go to `tests/kira/output/`. Exit status is zero only
if every selected antenna matches. The suite creates and then removes
`runcards/_suite.json`; do not use that name for a personal card. If
`FERMATPATH` is unset, the suite supplies a machine-specific default under
`~/opt/fermat/Ferm7a/fer64`; set your own path explicitly.

## Troubleshooting

- Missing input: build with `pythonToWl`, or check the automatic/manual path
  selection and antenna key.
- No suitable family: inspect the invariant form and denominators; the mapper
  must represent every monomial in an available family.
- Unsupported propagator or momentum layout: check the scope table before
  trying loop or massive templates.
- Kira or FORM subprocess failure: inspect the exception and Kira's work
  folder, especially `jobs.yaml`, `toReduce`, and `kira.log`. Successful tool
  output is captured internally rather than streamed.
- Missing analytic master: inspect the reported integral and Kira's unreduced
  warnings; stopping with `substitute_masters: 0` preserves the reduction for
  investigation but does not establish analytic closure.
- Scale mismatch: retain the master combination and template; do not bypass
  the check by setting `q2` to one in the Kira configuration.
