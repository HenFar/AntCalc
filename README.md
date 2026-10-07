# AntCalc

AntCalc **0.3.5** builds and integrates QCD antenna functions. Its main entry
point is the Python runcard runner, which currently builds with Wolfram
Language and integrates with FORM and Kira. The Wolfram package is retained
for legacy routes as the workflow moves towards other tools.

```text
Python runcard → Wolfram build → invariant expression → FORM → Kira
              → master combination → analytic masters → epsilon series + scale
```

The current project version is **0.3.5**. The legacy Wolfram paclet is frozen
at **0.3.0-beta.1**: it is no longer released, and its version is not advanced.
Paclet installation is only needed when using its packaged Wolfram interface;
the Python runner loads the checkout's Wolfram build code directly. Selecting
`integrate_method: "kira"` in a runcard routes integration through FORM and Kira.
Different antennae can be integrated in parallel; the same antenna only one run
at a time (see the [Kira workflow guide](docs/manual/kira-workflow.md)).

AntCalc is active, unpublished thesis research software. It is shared for
evaluation and academic discussion; reuse, redistribution, and relicensing
require prior written permission from the relevant rights holder or holders.
See [NOTICE](NOTICE).

## Python / FORM / Kira quick start

Run these commands from the repository root. Python dependencies are pinned in
[requirements.txt](requirements.txt):

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
export FERMATPATH=/absolute/path/to/fermat/executable
python src/antcalc/orchestrator.py
```

Install FORM and Kira separately and make them available on `PATH`. Building
also requires `wolframscript`, a licensed Wolfram kernel, FeynCalc, FeynArts,
and FeynHelpers. See the [Kira workflow guide](docs/manual/kira-workflow.md)
for setup, integrate-only runs, input conventions, and troubleshooting.

The default command reads [runcards/runcard.json](runcards/runcard.json), which
currently builds and integrates massless `A40` using:

```json
{
  "build": 1,
  "build_method": "pythonToWl",
  "build_print_to_terminal": 1,
  "integrate": 1,
  "integrate_method": "kira",
  "integrate_print_to_terminal": 1,
  "substitute_masters": 1,
  "auto_input_path": 1,
  "manual_input_path": "",
  "family": "A",
  "multiplicity": 4,
  "loop_order": 0
}
```

Copy this card to `runcards/my_run.json` and run
`python src/antcalc/orchestrator.py my_run` to use your own settings. Set
`build` to `0` to integrate an existing input. Set `substitute_masters` to `0`
to stop after reduction and scale extraction.

Build outputs go to `results/unintegrated/unintegratedXij.m`. For each input
component, Kira integration writes to `results/integrated/`:

- `Xij_0_masters.inc`: the reduced master combination;
- `Xij_0_scale.json`: the separately checked scale factor;
- `Xij_0_integrated.inc`: the epsilon series, when master substitution is enabled.

Component indices start at zero. `A40` has leading and subleading components.
The integrated series is evaluated at `mu2 = q2`; use the separate scale factor
when restoring scale dependence.

## Scope and validation

| Workflow | Current scope |
|---|---|
| Python / Kira | massless `A30`, `A40` (leading and subleading), `B40`, `C40` |
| Kira epsilon depth | `A30` through `ep^2`; four-parton tree antennae through `ep^0` |
| `A31`, `A22` Kira templates | present, but incompatible with the current invariant-to-family mapper |
| Wolfram package | broader massless API, R-ratio and bulk helpers; beta massive `A30` |

The Kira [comparison suite](tests/kira/run_suite.py) integrates saved inputs
and compares their coefficients with thesis Appendix A references:

```sh
python tests/kira/run_suite.py A30 A40 B40 C40
```

It requires FORM, Kira, Fermat, and the Python dependencies. It writes logs and
`tests/kira/output/summary.md`, and replaces the selected antenna's files
in `results/integrated/`. The existence of a template or checked-in result is
not a fresh validation run. The Wolfram package's separate support contract
and verification procedure are in the [route-status matrix](docs/legacy/manual/route-status.md)
and [installation guide](docs/legacy/manual/installation.md).

## Legacy Wolfram Language package

For direct use of the legacy package interface, install the paclet from a
notebook or kernel:

```wl
legacyRoot = "/path/to/form-kira-lab/legacy/wolfram";
archive = CreatePacletArchive[legacyRoot, $TemporaryDirectory];
PacletInstall[archive];
```

Restart the kernel, then:

```wl
<< AntCalc`
a30 = BuildAntenna[A, 3, 0];
intA30 = BuildAndIntegrateAntenna[A, 3, 0];

(* Explicit build/integrate boundary. *)
a30Object = BuildAntenna[A, 3, 0, IntegrableForm -> True];
intA30Direct = IntegrateAntenna[a30Object];
```

While editing a checkout, load it directly with
`Get[FileNameJoin[{legacyRoot, "AntennaPipeline.wl"}]]`.
The package uses PaVe/IBP routes, including LiteRed2 where required. Retain the
bundled basis and runtime-master files. Its documented symbolic baseline is
FeynCalc 10.2.1, FeynArts 3.12, FeynHelpers 2.0.0, FeynCalcLegacy 1.0.0, and
LiteRed2 2.025 beta; see [installation](docs/legacy/manual/installation.md) for details.

## Documentation and code map

- [Documentation home](docs/README.md) and [manual](docs/manual/index.md)
- [Running the Kira workflow](docs/manual/kira-workflow.md)
- [How the Kira integration pipeline works](docs/development/kira-integration.md)
- [Repository structure and dependency boundaries](docs/development/repository-layout.md)
- [Regression tests](tests/README.md)
- [Python source overview](src/antcalc/README.md) and [Kira templates](src/antcalc/kira/README.md)
- [Wolfram API reference](docs/legacy/reference/README.md)
- [Route status](docs/legacy/manual/route-status.md)
- [Developer documentation](docs/development/README.md)
- [Citation and provenance](docs/legacy/manual/citation-and-provenance.md)

```text
src/antcalc/       current runner, Python adapters, FORM/Kira assets and masters
legacy/wolfram/   retained Wolfram package, loaders, bases and helper scripts
tests/            current runcard checks and Kira physics comparisons
docs/             current guides; Wolfram guides under docs/legacy/
research/         historical source, session notes and existing evidence
runcards/         user run configurations
results/          calculation inputs and outputs
requirements.txt  Python dependencies
```

The Wolfram code remains an active build dependency while its operations are
migrated. Its directory preserves the package-relative asset layout. See
[legacy/wolfram/README.md](legacy/wolfram/README.md) for direct use and maintenance.
