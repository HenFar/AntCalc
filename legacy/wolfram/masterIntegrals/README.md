## Scope

This directory contains Wolfram-language source files for the master integrals
used in the NNLO derivation work.

The directory is the derivation and provenance layer for the package master
values. The main package does not recompute these derivations on load; instead,
the compact runtime master substitutions are exported from this directory into a
checked-in Wolfram data file that the package reads directly.

## Source groups

### Virtual two-loop masters

Source: `0403057v2-2.pdf`, Appendix `A.1`

- `A22LO.wl`
- `A3.wl`
- `A4.wl`
- `A6.wl`

### Three-particle / one-loop masters

Source: `0403057v2-2.pdf`, Appendix `A.2`

- `V5a.wl`
- `V5b.wl`
- `V8.wl`

### Four-particle phase-space masters

Primary source: `0311276v1.pdf`

Supporting thesis source: `main_old.pdf`

- `R3.wl`
- `R4.wl`
- `R8a.wl`
- `R6.wl`
- `R8b.wl`

### Support files

- `common.wl`
- `index.wl`
- `runtime_values.wl`
- `export_runtime_master_values.wl`
- `master_values_runtime.wl`
- `run_kernel.sh`
- `nnloMIs.wl`

### Massive A30 trial masters

These are first-pass provenance files for the two LiteRed masters that appear
in the current massive `A30` integration route.

- `MX30I1.wl`
- `MX30I2.wl`

## File roles

### `common.wl`

Shared helper definitions:

- epsilon-series expansion helpers;
- beta-function / unit-interval integral helpers;
- shared `S_Gamma` normalization helper;
- selected target expressions used by local checks.

### `index.wl`

Directory loader and registry definition.

Exports:

- `MasterIntegralRegistry[]`

### `runtime_values.wl`

Export-facing runtime-value collector.

Exports:

- `LoadRuntimeMasterValueSources[]`
- `MasterIntegralRuntimeValuesAssociation[]`

### `export_runtime_master_values.wl`

Developer script that loads the runtime-relevant derivation sources and writes
the checked-in runtime artifact.

### `master_values_runtime.wl`

Checked-in runtime artifact consumed by the main package. This file is data
only and is intended to be loaded via `Get[...]`.

### `run_kernel.sh`

Wrapper for local `WolframKernel` execution.

### `nnloMIs.wl`

Legacy notebook-style transcript retained as a reference log.

## File convention

Each master file is intended to function as an executable derivation record.

Preferred structure:

- source metadata;
- master definition;
- explicit intermediate objects;
- imported formulas, if any;
- local checks;
- report association.

Preferred naming split:

- `...Source[]` for source metadata;
- `...Definition` or `...init` for starting expressions;
- `...ClosedForm[]` or `...Series[]` for final results;
- `...Check[]` for local algebraic checks;
- `...Report[]` for file-level output;
- `NotYetEncoded` entries for incomplete derivation segments.

## Provenance rule

Imported formulas are not to be relabeled as locally derived formulas.

If a step is taken from:

- a paper;
- a thesis note;
- an older notebook;
- an already validated backend expression;

then the file should state that explicitly.

## Current status convention

The files in this directory are not required to satisfy a single uniform proof
standard.

Accepted statuses include:

- locally derived and locally checked;
- imported exact formula with local reduction/checks;
- imported series target with local reconstruction of poles or normalization;
- partially encoded derivation with explicit `NotYetEncoded` notes.

## Usage

### Load one file

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["masterIntegrals/R4.wl"]; Print[R4Report[2]]; Exit[]'
```

### Load the registry

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["masterIntegrals/index.wl"]; Print[Keys[MasterIntegralRegistry[]]]; Exit[]'
```

### Export the runtime artifact

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["masterIntegrals/export_runtime_master_values.wl"]; Exit[]'
```

### Validate the runtime artifact

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/validate_runtime_master_values.wl"]; Exit[]'
```

### Inspect one separated virtual master

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["masterIntegrals/A3.wl"]; Print[A3Report[3]]; Exit[]'
```

## Master map

### A22 tree / two-loop backend masters

- `R3 -> P3`
- `R4 -> A22LO`
- `R8a -> A3`
- `R6 -> A4`
- `R8b -> A6`

### A31 one-loop / three-particle backend masters

- `V5a -> qMI`
- `V5b -> qkMI`
- `V8 -> qsMI`

## Notes

- `R6` and `R8b` are encoded in optical-theorem form.
- `V8` is currently encoded as a literature series object rather than a compact
  closed gamma-function form.
- `MX30I1` now records the bridged literature phase-space master
  `I1^(m,0,m)` together with the generated-basis identification of the
  undotted runtime master.
- `MX30I2` is now explicitly labeled as a provisional runtime-basis bridge:
  the paper second master is a numerator master, while the package second
  master is the dotted LiteRed basis representative
  `j[MX30Basis123, 2, 1, 1, 0, 0]`.
- The current integrated acceptance check for the `MX30` pair is therefore the
  massive `A30` integrated target match, not the old massless-limit-only
  ansatz.
- Some package-convention bridges are encoded directly in the file; others are
  documented as inherited normalization layers.
- The runtime package loads `masterIntegrals/master_values_runtime.wl`, not the
  full derivation tree, so normal package startup remains lightweight.
