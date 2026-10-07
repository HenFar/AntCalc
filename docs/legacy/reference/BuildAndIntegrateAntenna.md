# `BuildAndIntegrateAntenna`

[Reference index](README.md) · [`BuildAntenna`](BuildAntenna.md) · [`IntegrateAntenna`](IntegrateAntenna.md) · [Documentation home](../README.md)

```wl
BuildAndIntegrateAntenna[type, numFinalParticles, loopOrder, opts]
```

This is the one-shot entry point. It performs:

```wl
obj = BuildAntenna[type, numFinalParticles, loopOrder,
  IntegrableForm -> True, ...];
IntegrateAntenna[obj, ...]
```

It follows this build-then-integrate workflow. It uses no separate convention
or hidden integration options. Cache controls apply to the build and
integration stages, not to a separate one-shot cache.

## Options and return forms

It accepts the [`IntegrateAntenna`](IntegrateAntenna.md) options, including
`ReturnMasterCombination`, `ExpansionOrder`, `ReturnTTerms`, cache controls,
component selection, records, and intermediate-stage requests.

Build-side controls required to construct the input object—such as
`quarkMass`, `ApplyDimReg`, and `LoopMomentum`—are forwarded through the
workflow. For detailed option meaning, use the direct integration reference
together with [`BuildAntenna`](BuildAntenna.md).

By default it returns the integrated public result. `ReturnDiagnostics` returns
`{result, diagnostics}`. `ReturnRecord` returns an `AntennaRunRecord` with
build and integration provenance.

## Example equivalence

```wl
oneShot = BuildAndIntegrateAntenna[A, 3, 0];

obj = BuildAntenna[A, 3, 0, IntegrableForm -> True];
explicit = IntegrateAntenna[obj];
```

For a supported route with identical options, `oneShot` and `explicit` return
the same public result. Regression checks cover component-wise integrable forms
and master-combination returns.
