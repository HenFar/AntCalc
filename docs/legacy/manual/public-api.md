# Public API overview

[Manual index](index.md) · [Glossary](glossary.md) · [Function reference](../reference/README.md)

AntCalc has two main operations:

```wl
BuildAntenna[type, numFinalParticles, loopOrder, ...]
IntegrateAntenna[antennaObject, ...]
```

The one-shot form runs them in sequence:

```wl
BuildAndIntegrateAntenna[type, numFinalParticles, loopOrder, ...]
```

It uses the same convention and integration options as the two-step call.

## Main workflow

| Function | Role | Usual return |
|---|---|---|
| `BuildAntenna` | Build a public unintegrated antenna | expression or ordered component list |
| `BuildAntenna[..., IntegrableForm -> True]` | Build the integration-ready view | `AntennaObject` or component-wise objects |
| `BuildAntennaObject` | Explicit object-building convenience form | `AntennaObject` |
| `IntegrateAntenna` | Integrate an antenna object with the route backend | integrated expression or component list |
| `BuildAndIntegrateAntenna` | Build, then integrate | same result as the explicit composition |

`AntennaObject` contains the route key, profile, build data, full antenna,
selected component, and route-owned source branches. See [records and
diagnostics](../reference/records-and-diagnostics.md).

## Higher-level helpers

| Function | Scope |
|---|---|
| `BuildRRatio[SMQCD, ...]` | massless symbolic NNLO R-ratio driver |
| `TObject[order, finalState, ...]` | one public symbolic T object assembled from integrated ingredients |
| `BuildAllAntennae[SMQCD, ...]` | bulk massless build convenience workflow |
| `BuildAndIntegrateAllAntennae[SMQCD, ...]` | bulk massless one-shot workflow |
| `AntennaPhysicsValidationReport[...]` | route-level physics-aware validation report |
| `BuildRRatioPhysicsValidationReport[]` | raw Laurent-series R-ratio validation |
| `VerifyWardIdentity[...]` | supported A-family Ward-identity diagnostic |

The supported `BuildRRatio` target is `SMQCD` with `quarkMass -> 0`.
`ResultForm -> "ComputedFiniteCoefficient"` is the default. The alternatives
`"RawDimRegSeries"` returns the assembled dimensional series.
`"ReferenceFiniteMSBar"` returns a requested comparison target. It does not
replace a computed result.

For bulk workflows, `maxOrder -> LO | NLO | NNLO` determines the requested
work. `LO` does not evaluate integrated antennae; `NLO` evaluates the NLO
ingredients; `NNLO` requests the complete current massless ingredient set.

## Components and source contributions

`Component` selects one public piece of a multi-component antenna. The current
canonical orders are:

- `A40`: `{Leading, Subleading}` = one ordered `A4^0` antenna and `tilde A4^0`;
- `A31`: `{Leading, Subleading, Nf}`;
- `A22`: `{Leading, Subleading, Nf, Breve}`.

Source contributions are internal physical branches, not a public option. For
`A22`, `Leading`, `Subleading`, and `Nf` use `TwoLoopTree`; `Breve` uses
`OneLoopSelf`. A record or diagnostics payload reports this as
`"ContributionsUsed"`; the combined route also reports available
`"ContributionDiagnostics"`. This keeps the public request aligned with the
published antenna component rather than an implementation branch.

The `A22` integrated public endpoint is specifically the paper-facing
`T_{qq}^{(6)}` component set: `Leading`, `Subleading`, and `Nf` from the
`[2x0]` branch and `Breve` from `[1x1]`. It is not a generic one-loop PaVe
reduction.

## Expected return forms

Calls return an expression or component list by default. Request a record when
you need provenance or diagnostics.

| Call | Default return form |
|---|---|
| `BuildAntenna[A, 2, 0]` | one Wolfram-language expression |
| `BuildAntenna` on a multi-component route with `Component -> All` | an ordered public component list |
| `BuildAntenna[..., IntegrableForm -> True]` | an `AntennaObject`, or a component-wise list of objects where the route exposes multiple components |
| `BuildAntennaObject[...]` | one `AntennaObject` suitable for `IntegrateAntenna` |
| `IntegrateAntenna[...]` or `BuildAndIntegrateAntenna[...]` | one integrated expression or the corresponding ordered component list |
| any public route with `ReturnRecord -> True` | an `AntennaRunRecord` whose `"Result"` is the normal public output |
| `BuildRRatio[...]` | the selected assembled R-ratio `ResultForm` |
| `BuildAllAntennae[...]` / `BuildAndIntegrateAllAntennae[...]` | an ordered list in the documented massless route order |

`ReturnDiagnostics -> True` supplies a compact `{result, diagnostics}` pair.
For stable record fields and route-dependent aliases, see [records and diagnostics](../reference/records-and-diagnostics.md).

## Inspection

Use `ReturnDiagnostics -> True` for `{result, diagnostics}`. Use
`ReturnRecord -> True` for a full provenance record. `IntermediateSteps` gives
a selected stage view. `IntermediateSteps -> True` currently captures a broad
backend-oriented set; this interface may change to a smaller physical-stage
view. See [records and diagnostics](../reference/records-and-diagnostics.md).

## Introspection

These functions expose package and route metadata without executing a physics
route:

```wl
AntennaPipelineConventionReport[]
AntennaPipelineDimRegDeclaration[]
AntennaRouteProfileReport[A, 3, 1]
AntennaRouteEnvironmentReport[A, 3, 1]
AntennaPipelineDefaults[]
```

The convention report separates the public contract from current implementation
status. It does not mark open research questions as settled conventions.
