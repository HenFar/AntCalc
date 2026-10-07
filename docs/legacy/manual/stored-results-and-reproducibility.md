# Stored results and reproducibility

[Manual index](index.md) · [Glossary](glossary.md) · [Documentation home](../README.md)

Stored results are an optional replay mechanism for public-route outputs. They
are not a derivation engine and must never be used to conceal a route that no
longer computes correctly.

## Controls

| Option | Meaning |
|---|---|
| `UseStoredResults` | reuse a matching stored public result when available |
| `StoreResults` | persist a successful newly computed public result |
| `RefreshStoredResults` | recompute and refresh a matching entry |
| `ResultsCacheRoot` | select a non-default cache root |

The public defaults are `UseStoredResults -> False`,
`StoreResults -> False`, `RefreshStoredResults -> False`, and
`ResultsCacheRoot -> Automatic`.

## Semantics

- Fresh and stored routes are formatted into the same public return shape.
- Diagnostics identify stored reuse when it occurs.
- Cache identity includes more than visible arguments: it includes route kind,
  route-semantic versioning, and convention-critical nested defaults.
- A semantics repair intentionally makes incompatible older entries stale.
- `UseStoredResults -> True` is read-only: on a miss it computes normally but
  does not create an entry. Add `StoreResults -> True` to seed or refresh the
  exact current request for later reuse.
- Public and prototype build-output branches use different cache identities.
- `BuildRRatio` and `TObject` cache identity also captures effective nested
  `BuildAndIntegrateAntenna` convention defaults.
- One-shot integration is a composition of `BuildAntenna` and
  `IntegrateAntenna`. It forwards cache controls to those two stages and has
  no separate `BuildAndIntegrateAntenna` cache entry.

The main build, object, integration, one-shot, R-ratio, and `TObject` routes
expose cache controls. Bulk helpers do not yet expose the full cache-option
family.

When `PrintIntermediateSteps -> True` is used on a stored replay, the current
compatibility behaviour is to print the stored stage payload when one exists.
It must not reconstruct hidden intermediate physics from a stored final
expression; absent provenance remains absent.

## Examples

```wl
BuildAntenna[A, 3, 1, UseStoredResults -> True, StoreResults -> True]
BuildAntenna[A, 3, 1, UseStoredResults -> True]
BuildRRatio[SMQCD, quarkMass -> 0, UseStoredResults -> True]
```

The first A31 call above computes and writes a current entry if no exact entry
exists. The second should print `Using stored result for ...` and return
without entering the build backend.

For a reproducibility test or physics validation, prefer a fresh computation:

```wl
UseStoredResults -> False
StoreResults -> False
```

## Runtime artifacts versus cache entries

The repository distinguishes cache entries under `stored_results/` from
required runtime assets. The latter include `bases/`, `generated_bases/`, and
`masterIntegrals/master_values_runtime.wl`; they support integration backend
operation and are not disposable cached answers.

Normal users do not regenerate master values during ordinary use. Derivation
and backend-maintenance procedures will be documented in the developer section.
