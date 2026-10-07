# Repository structure and dependency boundaries

[Developer index](README.md) · [Workflow guide](../manual/kira-workflow.md) · [Test guide](../../tests/README.md)

AntCalc 0.3.5 is organised around the current runcard workflow. Python owns
operation routing; FORM and Kira own the current reduction path. The Wolfram
package is an explicit retained dependency for construction and legacy routes.

## Directory responsibilities

| Location | Responsibility |
|---|---|
| `src/antcalc/` | runner, build/integration adapters, FORM scripts, Kira templates and analytic masters |
| `legacy/wolfram/` | Wolfram package, paclet entry points, stage loaders and required assets |
| `tests/runcards/` | real operation checks, with optional before/after output comparison |
| `tests/kira/` | integrate-only physics comparisons and references |
| `docs/manual/`, `docs/development/` | current user and maintainer guides |
| `docs/legacy/` | Wolfram API, package maintenance and notebook tutorials |
| `research/` | historical notes, source snapshots and dated evidence |
| `runcards/` | user-facing JSON run configurations |
| `results/` | shared unintegrated and integrated calculation files |
| `requirements.txt` | pinned Python dependencies |

FORM scripts, Kira templates and analytic masters stay alongside their
integrator because they are required runtime inputs. Their location under
`src/antcalc/` reflects current functionality, rather than archival provenance.

## Runtime path boundary

`src/antcalc/paths.py` derives the repository root from its own location, then
identifies `legacy/wolfram/loaders/`. The orchestrator passes that directory
to the Wolfram adapters. The loaders set `$AntennaPipelineRoot` to
`legacy/wolfram/`, preserving the Wolfram package's internal paths to `src/`,
`bases/`, `generated_bases/`, `masterIntegrals/`, `dev/`, and `stored_results/`.

This allows the Python workflow to run from another shell directory without
requiring a paclet installation. The direct script entry point is:

```sh
python src/antcalc/orchestrator.py          # default runcard
python src/antcalc/orchestrator.py my_run   # runcards/my_run.json
```

From the repository root, Python module invocation is also available:

```sh
PYTHONPATH=src python -m antcalc my_run
```

The retained paclet must be archived from `legacy/wolfram/`. A project-root
paclet archive no longer describes the intended package root.

## Research and legacy maintenance

The old flat Wolfram snapshot and retired verification material are under
`research/wolfram/`. Existing evidence and session notes are grouped under
`research/`, retaining their content and historical dates.

The Wolfram `dev/` scripts stay under `legacy/wolfram/dev/`. This area contains
both maintained package regressions and derivation/provenance helpers, including
basis generators called by the runtime. Keeping the package and these scripts
together preserves their relative paths. As individual routes migrate, their
active tests can move to the main test tree alongside the new implementation.

## Behaviour retained by the move

Runcard fields, default card selection, method choices, input paths and result
names remain unchanged. In particular, legacy builds still write to
`results/unintegrated_legacy/`, Kira's automatic input still reads
`results/unintegrated/`, and legacy integration still rebuilds via Wolfram.
The stale-output behaviour is unchanged; FORM's scratch has since moved to one
folder per expression (see the Kira integration guide).

The restructuring changes entry-point and source locations, not physics
conventions. The old `src/next/` command has moved to `src/antcalc/`. Tests
have moved from `src/next/tests/` to `tests/kira/`; FORM scratch is now under
`src/antcalc/tmp/`. Historical paths in archived evidence are provenance,
not current commands.

## Verification

Use the [runcard operation matrix](../../tests/README.md#runcard-operations)
to compare build-only, integrate-only and combined runs before and after a
layout change. Use the separate Kira suite to compare supported antennae with
thesis references. Both matter: a valid file path alone does not establish a
successful operation or a correct physics result.

The [2026-10-07 verification record](../../research/evidence/restructure-2026-10-07/README.md)
contains the before/after runcard fingerprints, final operation report, and
supported Kira reference comparisons for this restructuring.
