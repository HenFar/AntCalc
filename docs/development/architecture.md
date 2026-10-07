# Architecture

[Developer index](README.md) · [Route maintenance](route-maintenance.md) · [Documentation home](../README.md)

This page describes the legacy Wolfram package architecture. AntCalc 0.3.5's Python
runcard workflow builds through a Wolfram loader and integrates through FORM
and Kira; see [Kira integration internals](kira-integration.md) for that path.

The Wolfram package is profile-driven. Its core execution model is:

```text
public API call
  -> route key {type, multiplicity, loop order}
  -> profile lookup
  -> selected build or integration workflow
  -> stable public result, diagnostics, or record
```

The public interface is intentionally small; family-specific physics belongs in
profiles and route workflows rather than in a growing interface-level `Switch`.

## Read the code in this order

1. `src/core/profiles.wl`
2. `src/routes/build_workflows.wl`
3. `src/routes/integration_workflows.wl`
4. `src/interface/build_router.wl`
5. `src/interface/integration_router.wl`

This is the order in which the package reasons: metadata, workflow, then
public adaptation.

## Route keys and profiles

A route key has the form:

```wl
{type, numFinalParticles, loopOrder}
```

Examples are `{A, 3, 0}` (`A30`), `{A, 2, 1}` (`A21`), `{A, 2, 2}`
(`A22`), and `{B, 4, 0}` (`B40`).

`AntennaProfile[key]` owns build-side metadata: name, family, production mode,
extraction mode, colour normalisation, sectors, components, contributions, and
experimental implementation status. `AntennaReductionProfile[key]` stores
build-time loop-reduction choices separately. `AntennaIntegrationProfile[key]`
owns the integration backend, basis family, expansion depth, convention data,
and branch status.

The profile registry also owns the code-level convention model,
`AntennaPipelineConventionModel[]`, the build/integration convention profiles,
and the dimensional-regularisation declaration. `AntennaRouteProfileReport`
answers “what is this route?”, while `AntennaRouteEnvironmentReport` answers
“how would current defaults execute it?”.

## Build routing

`src/interface/build_router.wl` normalises public options, constructs a key,
requests route data, and formats it as an expression, object, diagnostics, or
record. `src/routes/build_workflows.wl` owns physical orchestration.

The `Production` profile field selects the construction story:

- `SelfInterference`: build amplitude, form self-interference, extract;
- `ColourOrderedAntenna`: use the colour-ordered reconstruction layer;
- `SectorSelfInterference`: construct and interfere route-relevant sectors;
- `SectorSymmetrisedInterference`: combine a sector decomposition through its
  required symmetrised interference.

Extraction is profile-driven too: it depends on metadata such as `Extraction`,
`ColourNorm`, components, and contributions. This accommodates the genuine
differences between tree A30, colour-ordered A40, sector-built B40/C40,
one-loop A21, and the distinct A31/A22 paths.

## Integration routing

`IntegrateAntenna` recovers key and selections from an `AntennaObject`, then
consults `AntennaIntegrationProfile[key]`. The integration workflow coordinates
PaVe/IBP selection, special routes such as massive A30, A22 contribution
stitching, backend diagnostics, T terms, and final extraction.

Build and integration metadata are deliberately separate. A route can be most
natural to construct in one symbolic representation and integrate in another;
A21 is the canonical example.

`BuildAndIntegrateAntenna` must build an integrable object and then call the
same integration workflow. It must share the direct integration option contract
and the same master-combination/diagnostic behaviour.

## IBP convention boundary

IBP routes apply backend-to-public normalisation at the explicit
`NormalizeIBPIntegratedResult[...]` boundary, before epsilon-series
truncation. `IntegrateViaIBP[...]`, `IBPToSeriesWithDiagnostics[...]`, and the
interface routing propagate `ApplyFeynCalcMS`, `KinematicScale`, and
`NormalizeKinematicScale` to that boundary. Backend diagnostics retain the
`"ConventionBridgeFactor"`, the master-substituted expression, and the
normalised pre-series expression.

For A31, the current post-repair bridge is the identity: runtime master
normalisation already supplies the public convention, so no second
FeynCalc-MS conversion is applied at the observable boundary. The local
regression [`dev/verify_task6_convention_bridge.wl`](../../dev/verify_task6_convention_bridge.wl)
checks the explicit A21 public target and inspectable A31 convention-bridge
diagnostics. This is a regression aid, not a substitute for broader physics
validation.

## Boundary and record design

Build associations carry `BuildOutputBoundary` with `Public` and `Prototype`
branches. The public formatter selects the public branch; records retain both
for provenance. This does not imply every route has distinct prototype physics.

Association-shaped internal data is intentional. It carries profile, route
story, amplitudes/interferences, components, backend diagnostics, selections,
and cache provenance. It enables `ReturnDiagnostics`, records, and experimental
branches to report what occurred without making backend machinery the normal
public result.

## Why this design fits AntCalc

AntCalc is neither a one-off notebook nor a generic symbolic-algebra system.
It needs one stable public API while preserving genuine family-specific physics.
The profile/route split provides an auditable metadata layer, reusable engines,
workflow files that tell physical stories, and an honest place for incomplete
research branches.
