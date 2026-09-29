# AntCalc

> **New in 0.3.2 β6 - Thesis Version:** restored the explicit numerator factor
> `4` in massive `A30` paper Eq. (3.1), fixing its massless limit. The earlier
> coefficient comparison gave `1/4` with the undernormalised build. Restoring
> the factor makes the effective build/integration bridge unit-normalised,
> `I_paper = j_MX30`; this does not independently determine a cut-measure
> normalisation for the masters. The corrected build passes its
> soft, collinear, and massless-limit checks; fresh integration release checks
> remain pending. Massive `A30` is the first public massive route, while
> `D30` remains experimental.

AntCalc is a Wolfram Language package that builds and integrates QCD antenna
functions. The main workflow has two steps:

```wl
BuildAntenna[...] → IntegrateAntenna[...]
```

`BuildAndIntegrateAntenna[...]` runs these steps in sequence. AntCalc is
thesis research software. The massless routes are the stable release surface.
Massive `A30` is the first public massive route; its beta qualification records
pending post-correction integration release checks, not a comparison of its
scientific maturity with the massless routes. `D30` remains experimental.

## Status

Current development release: **AntCalc 0.3.2 β6 - Thesis Version**.

The current release target is the massless antenna workflow for the NNLO SMQCD
R-ratio. The first massive `A30` route is also public, with its corrected
integrated release checks still pending. Before using a route in a calculation,
read the [route-status matrix](docs/manual/route-status.md).

AntCalc is active, unpublished thesis research software. It is shared for
evaluation and academic discussion; reuse, redistribution, and relicensing
require prior written permission from the relevant rights holder or holders.
See [NOTICE](NOTICE) for the current distribution position.

## Install and load

After cloning the repository, install the paclet once from a Wolfram notebook
or kernel:

```wl
repoRoot = "/path/to/antenna_pipeline";
archive = CreatePacletArchive[repoRoot, $TemporaryDirectory];
PacletInstall[archive];
```

Then restart the kernel and load AntCalc normally:

```wl
<< AntCalc`
```

If the paclet was installed while the notebook kernel was already running,
evaluate `PacletDataRebuild[]`, restart the kernel, and try again.

While actively editing a cloned checkout, load its current source directly
instead of the installed paclet copy:

```wl
repoRoot = "/path/to/antenna_pipeline";
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]]
```

## Quick start

```wl
<< AntCalc`

(* Unintegrated tree-level NLO antenna. *)
a30 = BuildAntenna[A, 3, 0];

(* One-shot construction and integration. *)
intA30 = BuildAndIntegrateAntenna[A, 3, 0];

(* The explicitly modular equivalent. *)
a30Object = BuildAntenna[A, 3, 0, IntegrableForm -> True];
intA30Direct = IntegrateAntenna[a30Object];
```

## Documentation

Use these pages:

- [Documentation home](docs/README.md)
- [Manual index](docs/manual/index.md)
- [Route status and support contract](docs/manual/route-status.md)
- [Tutorials and runnable examples](docs/tutorials/README.md)
- [Reference guide](docs/reference/README.md)
- [Developer documentation](docs/development/README.md)
- [Citation and provenance](docs/manual/citation-and-provenance.md)
- [Documentation migration ledger](docs/migration-status.md)

[dev/README_old.md](dev/README_old.md) is retained as a development archive. Start with the
manual instead.

## Dependencies

Supported workflows require Wolfram Language, FeynCalc, FeynArts, and
FeynHelpers. IBP-backed integration also requires LiteRed2. Keep the bundled
basis and runtime-master files when copying or cloning the repository.

The current beta toolchain is:

```text
FeynCalc 10.2.1 · FeynArts 3.12 (27 Mar 2025) ·
FeynHelpers 2.0.0 · FeynCalcLegacy 1.0.0
LiteRed2 2.025 β
```

## Scope

AntCalc does not currently provide a public `D30` route or complete
`SUSY`/`HiggsEFT` R-ratio workflows. The first massive `A30` route has a
derived master substitution. Its corrected build passes the soft, collinear,
and massless-limit checks; fresh post-correction integration release checks
remain pending. See the [route-status matrix](docs/manual/route-status.md) for
the exact verification scope.
