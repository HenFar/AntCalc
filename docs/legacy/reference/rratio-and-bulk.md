# R-ratio, T objects, and bulk helpers

[Reference index](README.md) · [Manual API overview](../manual/public-api.md) · [Documentation home](../README.md)

## `BuildRRatio`

```wl
BuildRRatio[SMQCD, opts]
```

Builds the massless symbolic NNLO R-ratio from public integrated antenna
ingredients. The supported release target is `quarkMass -> 0`.

| Option | Meaning |
|---|---|
| `ResultForm` | `"ComputedFiniteCoefficient"` (default), `"RawDimRegSeries"`, or `"ReferenceFiniteMSBar"` |
| `maxOrder` | `LO`, `NLO`, or `NNLO`, also accepted as uppercase strings |
| `ReturnDiagnostics` | return `{result, diagnostics}` |
| `IntermediateSteps`, `PrintIntermediateSteps` | driver-stage inspection and compatibility printing |
| cache controls | `UseStoredResults`, `StoreResults`, `ResultsCacheRoot`, `RefreshStoredResults` |

The computed forms are antenna-assembled. The reference form is an explicitly
requested encoded comparison target and is never used to replace a computation.
Driver diagnostics report origin, requested order, included/skipped
ingredients, reference target, and residual.

`LO` evaluates no integrated antenna; `NLO` requests `A21` and `A30`; `NNLO`
requests the complete current massless ingredient set.

## `TObject`

```wl
TObject[order, finalState, opts]
```

Builds a public symbolic T object from the same integrated massless SMQCD
ingredients. Supported perturbative orders are `2`, `4`, and `6`; supported
final-state selectors include `qqbar`, `qqbarg`,
`qqbarqprimeqprimebar`, `qqbarqqbar`, and `qqbargg`.

Its controls are `quarkMass` (currently only `0` is supported),
`ExpansionOrder`, `ReturnDiagnostics`, and the standard cache controls.

## Bulk helpers

```wl
BuildAllAntennae[SMQCD, maxOrder -> NNLO]
BuildAndIntegrateAllAntennae[SMQCD, maxOrder -> NNLO,
  ExpansionOrder -> 0]
```

These return ordered lists of supported massless public outputs. `maxOrder`
accepts `LO`, `NLO`, and `NNLO` (or uppercase strings). Nonzero `quarkMass`
currently aborts in the bulk helpers. The full stored-result control family is
not yet exposed directly by these wrappers. The route order is `A20` at LO;
`A20`, `A30`, `A21` at NLO; and those routes followed by `A40`, `B40`, `C40`,
`A31`, and `A22` at NNLO. `SUSY` and `HiggsEFT` enumeration is scaffolded but
not implemented; the supported bulk target is massless `SMQCD` only.
