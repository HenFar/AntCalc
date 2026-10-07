# `IntegrateAntenna`

This page documents the legacy Wolfram package. Shell commands and package
asset paths below are relative to `legacy/wolfram/`; change to that directory
before running them. The current runner is described in the
[Kira workflow guide](../../manual/kira-workflow.md).

[Reference index](README.md) · [`BuildAntenna`](BuildAntenna.md) · [Documentation home](../../README.md)

```wl
IntegrateAntenna[antennaObject, opts]
```

Integrates an `AntennaObject` with its route-selected PaVe or IBP backend.
The Python runcard setting `integrate_method: "kira"` belongs to a separate
[checkout workflow](../../manual/kira-workflow.md); it is not an option of this function.
Obtain an object with either:

```wl
BuildAntennaObject[A, 3, 0]
BuildAntenna[A, 3, 0, IntegrableForm -> True]
```

It also accepts an ordered list of integrable objects.
`IntegrateAntenna[objects, opts]` returns the same shapes as
`IntegrateAntenna[#, opts]& /@ objects`.

The ordinary result is an integrated scalar or ordered public component list.

## Shared integration contract

`IntegrateAntenna` and `BuildAndIntegrateAntenna` expose the same integration
option set. The latter builds an integrable object and delegates integration;
it is not a different backend or convention path.

The one-shot wrapper forwards physics and backend controls to
`IntegrateAntenna`. It assembles `ReturnDiagnostics` and `ReturnRecord` at its
outer boundary and forwards cache controls to the build and integration stages.
These return-shape differences do not create a second calculation route.

## Main options

| Option | Default | Meaning |
|---|---:|---|
| `ExpansionOrder` | `Automatic` | requested epsilon-series depth |
| `Component` | `All` | select one public integrated component |
| `ReturnTTerms` | `False` | expose the route T-term object when meaningful |
| `ReturnMasterCombination` | `False` | expose an unreplaced runtime-master combination when available |
| `ReturnDiagnostics` | `False` | return `{result, diagnostics}` |
| `ReturnRecord` | `False` | return an `AntennaRunRecord` |
| `IntermediateSteps` | `{}` | request selected integration-stage data |
| `UseStoredResults`, `StoreResults` | `False` | cache controls |

`ReturnMasterCombination -> True` returns the IBP master-combination payload
when the route provides it. It does not derive a literature-basis relation. The
returned expression keeps runtime LiteRed syntax; its coefficient functions use
`d = 4 - 2 Epsilon` and the public spelling `Epsilon`. Raw LiteRed `d`/`eps`
notation remains in backend diagnostics.

## Backend and convention controls

| Option | Meaning |
|---|---|
| `ApplyFeynCalcMS` | apply the FeynCalc/Package-X convention bridge where relevant |
| `KinematicScale`, `NormalizeKinematicScale` | control integration-scale presentation |
| `quarkMass` | select a massive branch where experimentally supported |
| `LoopMomentum` | PaVe loop-momentum selector |
| `ApplyDimReg` | activate package dimensional continuation |
| `BasisFamily`, `BasisRoot`, `GenerateMissingBases` | expert IBP basis routing controls |
| `DetailedTimingDiagnostics` | request extended heavy-route timing diagnostics |
| `ResultsCacheRoot`, `RefreshStoredResults` | advanced cache controls |

## Integration stage names

The current collector recognises:

```text
InputAntenna
RawIntegrated
TTerms
FinalIntegrated
SelectedIntegrated
BackendDiagnostics
IntegrationDiagnostics
```

See [records and diagnostics](records-and-diagnostics.md) for return shapes
and [conventions](../manual/conventions-and-normalisation.md) for the meaning
of PaVe and IBP bridge factors.

The A21 PaVe/Package-X scalar evaluation is route-owned (`"PaXEvaluate"` in
the supported profile), not a public option. The public API does not integrate
raw PaVe or IBP expressions; build an `AntennaObject` first.
