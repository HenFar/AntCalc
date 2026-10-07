`src/` is the canonical runtime source tree for the package. This directory is
the release-owned implementation of the public API loaded by
[AntennaPipeline.wl](../AntennaPipeline.wl).

The [src/antcalc/](../../../src/antcalc/README.md) subtree contains AntCalc 0.3.5's main Python runcard
workflow, FORM scripts, and Kira integrator. It has its own entry point and is
not loaded by the canonical Wolfram package loader. See the
[Kira workflow guide](../../../docs/manual/kira-workflow.md).

The architectural goal of `src/` is simple:

```text
keep the symbolic physics operations readable,
keep the package orchestration predictable,
and keep those two responsibilities separate.
```

That separation is what lets the package support both:

- a clean public API for external users
- enough internal structure for thesis/research inspection

## Release Scope

The runtime under `src/` is release-complete for the massless package target:

- massless tree-level `A20`, `A30`, `A40`, `tildeA40`, `B40`, `C40`
- integrated `A21`
- integrated `A30`
- integrated `A31`, `tildeA31`, `hatA31`
- integrated `A22`, `tildeA22`, `hatA22`, `breveA22`
- `BuildRRatio[SMQCD, quarkMass -> 0]`
- `BuildAllAntennae[SMQCD, maxOrder -> LO|NLO|NNLO]`
- `BuildAndIntegrateAllAntennae[SMQCD, maxOrder -> LO|NLO|NNLO, ...]`

The runtime also contains a beta extension:

- massive `A30` (beta)

Those branches are kept inside `src/` because they are genuine runtime code,
not just provenance material, but they are not part of the package release
guarantee.

## Why The Code Is Split Into Layers

The package is organized into four layers:

- `core/`
- `engines/`
- `routes/`
- `interface/`

Each layer answers a different question.

### `core/`

`core/` defines package-wide conventions and shared infrastructure:

- kinematics helpers
- profiles and routing metadata
- diagnostics helpers
- cache helpers

This layer exists so that normalization choices, profile metadata, and cache
policy are defined once and reused consistently. The design reason is
maintainability: if each route redefined its own conventions locally, the
package would become impossible to audit after enough special cases
accumulated.

### `engines/`

`engines/` performs the raw symbolic work:

- FeynArts diagram/amplitude generation
- FeynCalc interference construction
- tree and loop extraction logic
- PaVe / Package-X integration
- LiteRed / IBP reduction
- integrated-antenna post-processing

The design reason for isolating this layer is readability. Engine code should
say “perform this physics operation,” not “format this return value” or
“rebuild this cached record.”

### `routes/`

`routes/` turns engine operations into antenna-family workflows.

This is the layer that answers questions like:

- which amplitude is built for this antenna family?
- which interference is formed?
- how is the object normalized?
- which backend is used for integration?
- which stages are meaningful to expose to the user?

The design reason is that different antenna families are physically different,
but the public API should still look uniform. The route layer absorbs that
difference.

### `interface/`

`interface/` owns the public contract:

- option parsing
- public dispatch
- result formatting
- `AntennaObject[...]`
- `AntennaRunRecord[...]`
- diagnostics shaping
- stored-result reconstruction

The design reason is user stability. The interface layer makes sure the user
sees one consistent API even when the underlying route logic differs sharply
between, say, `A40`, `A22`, and the massive `A30` branch.

## The Four Canonical Public Functions

The runtime is organized around four public functions:

- `BuildAntenna[...]`
- `BuildAntennaObject[...]`
- `IntegrateAntenna[...]`
- `BuildAndIntegrateAntenna[...]`

The interface layer also provides two quality-of-life batch wrappers for the
massless SMQCD release target:

- `BuildAllAntennae[...]`
- `BuildAndIntegrateAllAntennae[...]`

### `BuildAntenna[...]`

This is the public constructor for unintegrated antenna results.

It returns the symbolic antenna expression the user usually wants to inspect.
It can also expose diagnostics, intermediate steps, or a run record. The
design reason for keeping this function focused is usability: unintegrated work
should not force users to think about backend routing or integration metadata.

### `BuildAntennaObject[...]`

This wraps a build result together with the metadata needed for downstream
integration:

- the antenna key
- component and contribution information
- the full build result
- route provenance

The design reason is physical correctness. Integration needs more than a bare
expression; it needs to know what family the object came from and how it was
built.

### `IntegrateAntenna[...]`

This consumes an `AntennaObject[...]` and performs the integrated route:

- backend selection
- raw integration
- master-combination handling when relevant
- T-term construction
- final integrated-antenna extraction

The design reason is explicitness. Integration is not just “apply an integral
operator”; it is a pipeline with backend-specific intermediate objects that the
package needs to preserve and optionally expose.

### `BuildAndIntegrateAntenna[...]`

This is the one-shot user route. It exists for convenience only. Internally it
still composes the same build and integration layers rather than creating a
second independent physics path.

The design reason is API clarity: one-shot usage should be easy, but it should
not fork the implementation story.

### `BuildAllAntennae[...]` and `BuildAndIntegrateAllAntennae[...]`

These are convenience wrappers defined in
[interface/build_all_antennae.wl](interface/build_all_antennae.wl).
They enumerate the current SMQCD release-owned antenna list through `LO`,
`NLO`, or `NNLO` and delegate to `BuildAntenna[...]` or
`BuildAndIntegrateAntenna[...]` for each item.

The current implementation status is:

- fully usable for massless `SMQCD`
- uppercase `LO`, `NLO`, and `NNLO` order tags only
- scaffolded but intentionally aborting for `SUSY` and `HiggsEFT`
- not yet the entry point for massive work, since nonzero `quarkMass`
  currently aborts there

## End-To-End Data Flow

The runtime story is:

1. the public interface identifies an antenna key
2. `core/profiles.wl` resolves the route metadata
3. a route module chooses the workflow
4. engine functions perform the symbolic physics operations
5. the route module assembles a stable stage association
6. the interface formats the public result, diagnostics, object, or record

So the actual shape is:

```text
interface -> routes -> engines -> routes -> interface
```

This is deliberate. The route layer is where antenna-specific physics choices
belong. The interface layer should not need to know how to reduce an `A31`
integrand or how `A22` is stitched from multiple physical sources.

## Major Files By Responsibility

### `core/`

- [core/setup.wl](core/setup.wl)
  initializes the shared runtime environment
- [core/kinematics_and_utilities.wl](core/kinematics_and_utilities.wl)
  defines invariant and simplification helpers
- [core/profiles.wl](core/profiles.wl)
  is the physics-facing routing table
- [core/result_cache.wl](core/result_cache.wl)
  owns stored-result policy and reconstruction
- [core/diagnostics.wl](core/diagnostics.wl)
  centralizes validation and comparison helpers

### `engines/`

- `amplitudes_tree.wl`, `amplitudes_loop.wl`
- `interference_tree.wl`, `interference_loop.wl`
- `extraction_tree.wl`, `extraction_loop.wl`
- `integration_pave.wl`
- `integration_ibp.wl`
- `integrated_antenna_extraction.wl`
- `color_ordered_a40.wl`

These files are intentionally the closest to raw FeynArts/FeynCalc/LiteRed
operations.

### `routes/`

Route physics is edited in `routes/families/`: one declaration file per
supported family. `route_resolution.wl` selects a named variant and exposes
the resolved funnel and adapter through `AntennaRouteReport[...]`.

- [routes/build_workflows.wl](routes/build_workflows.wl)
  owns the build-side family workflows
- [routes/integration_workflows.wl](routes/integration_workflows.wl)
  owns the integration-side workflow selection
- [routes/route_catalog.wl](routes/route_catalog.wl)
  stores route descriptions attached to diagnostics/records
- the `massive_a30_*.wl` files isolate the massive provenance-aware runtime
  branch

### `interface/`

- [interface/build_router.wl](interface/build_router.wl)
  exposes the build-side public API
- [interface/integration_router.wl](interface/integration_router.wl)
  exposes the integration-side public API
- [interface/rratio_driver.wl](interface/rratio_driver.wl)
  builds the massless `SMQCD` NNLO `R`-ratio from the validated public routes
- [interface/paper_targets.wl](interface/paper_targets.wl)
  stores comparison targets used by diagnostics

## Special Runtime Branches

### Massive A30 (beta)

The massive `A30` runtime branch is real code and therefore lives in `src/`,
not in `dev/`. It is a beta route with a derived MX30 master closure, qualified
through `ExpansionOrder -> 2`; it is not part of the stable massless surface.
With the default `ExpansionOrder -> Automatic`, its public result remains in
the compact all-epsilon literature form (under the declared paper-to-package
invariant bridge).  Supplying an explicit integer `ExpansionOrder` requests a
derived epsilon-series representation instead.

Its split files exist for a reason:

- `massive_a30_unintegrated.wl`
  stores bibliography/provenance data for the unintegrated result
- `massive_a30_reconstruction.wl`
  rebuilds the unintegrated antenna through the package chain
- `massive_a30_integrated.wl`
  records the integrated provenance layer and derived MX30 master-basis closure

The design reason is traceability: the package retains the derivation chain
while exposing the closed beta result through the public route.

## Records And Intermediate Steps

The package now has an explicit inspection layer:

- `ReturnRecord -> True`
- `IntermediateSteps -> {...}`
- `PrintIntermediateSteps -> True`
- `PrintComponentLegend -> Automatic`

`ReturnRecord -> True` returns an `AntennaRunRecord[...]` wrapper whose
`"Result"` field matches the historical public return exactly.

For an all-component list returned in an interactive notebook,
`PrintComponentLegend -> Automatic` prints its component order (for example,
`{Leading, Subleading, Nf}` for A31). Set it to `True` or `False` to force the
legend on or off; records remain self-describing and do not print a legend.

The design reason is transparency. Users should be able to ask for the final
answer by default, but also recover already-computed intermediate objects
without rerunning heavy routes.

## Loader Policy

[AntennaPipeline.wl](../AntennaPipeline.wl)
is the only canonical runtime loader. It loads only from `src/`.

Any archival compatibility tree now belongs under `dev/` as provenance, not as
part of the active package surface.

## Relationship To `dev/`

`src/` owns runtime code.

`dev/` owns:

- release verification scripts
- benchmarks
- research notes
- provenance checks
- historical exploratory scripts

That boundary is intentional. Anything required for the public runtime should
be callable from `src/` through the canonical loader. Anything under `dev/`
should be optional support material, not a runtime dependency.
