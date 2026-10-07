# A31/A22 provenance audit

[Developer index](README.md) · [Runtime masters and literature provenance](runtime-masters-and-provenance.md) · [Conventions and normalisation](../manual/conventions-and-normalisation.md)

This is an evidence ledger for the massless integrated `A31` and `A22`
routes.  It records what is derived or explicitly mapped in the repository and
what still needs an equation-level literature cross-reference.  An encoded
target that agrees with a computed series is an **internal-consistency** check;
it is not, by itself, an external-literature validation.

The common source family is `hep-ph/0403057`.  This document does not invent
equation numbers where the current source comments do not identify them.

## Status summary

| Route / object | Current evidence | Validation meaning | External-literature tier? |
|---|---|---|---|
| `A31` raw masters and T terms | Runtime master artifact, a documented `2 Pi^2` paper-convention factor, and explicit lower-`A30` UV subtraction | Computation can be compared exactly with encoded T-term and final targets | No — the exact source equations and derivation of the bridge are not recorded here |
| `A31` final integrated components | Explicit extraction from the T terms using the `A21 A30` product | Exact residual to the encoded final target is meaningful as an internal closure test | No — target provenance still needs equation-level mapping |
| `A22` tree/two-loop bracket | Appendix A.1 is named for the master basis; timelike continuation and two-parton convention factors are explicit | The master-to-package convention route is substantially documented | No — component targets need source-equation/colour-bracket citations in the runtime source |
| `A22` one-loop-self (breve) bracket | Appendix A.1 is named for the disconnected two-bubble master and a separate virtual convention factor is explicit | Master provenance and normalisation intent are documented | No — target coefficient source and independent rederivation record remain absent |

Accordingly, the release/physics records for both routes must continue to use
`InternalConsistency`, not `ExternalLiterature`.

## A31 evidence chain

The extraction implementation in
[`src/engines/integrated_antenna_extraction.wl`](../../src/engines/integrated_antenna_extraction.wl)
states the following package-owned operations:

1. Raw backend components are mapped to paper normalisation with
   `A31PaperConventionFactor[] = 2 Pi^2`.
2. The leading component receives `-(11/(6 epsilon)) A30`; the `Nf`
   component receives `-(-2/(6 epsilon)) A30`; the subleading component has
   no such term.
3. Final components are extracted as
   `{TLeading - A21 A30, -(TSubleading + A21 A30), TNf}`.
4. `A31TTermTargets` and `A31IntegratedAntennaTargets` are exact Laurent
   comparison data, component by component.

This provides a clear executable bookkeeping chain, including its
lower-order subtraction inputs.  The missing external provenance is equally
specific:

| Required item | Present record | Gap to close |
|---|---|---|
| Master basis | `hep-ph/0403057` is recorded as the source family | Map each runtime master label to the paper's master definition/equation |
| Overall factor | `2 Pi^2` is explicit | Cite the paper convention and show the raw-backend-to-paper derivation |
| UV counterterms | Coefficients and `A30` dependence are explicit | Cite the renormalisation equation and colour decomposition |
| T-term targets | Full values are encoded | Cite the source equation/table for each colour component |
| Final target extraction | Package formula is explicit | Cite or derive the relation between the paper T objects and final antennae |

There is an additional source-text warning worth preserving: the `Nf`
T-term comment records that arXiv v2 prints `19/2` in one coefficient, while
the package uses `19/12` because it is said to be required by NNLO pole
cancellation.  Before any external-literature promotion, this must be backed
by a primary-source erratum/version comparison or a separately archived pole
closure derivation.

## A22 evidence chain

The legacy derivation source
[`dev/src_legacy_flat_2026-06-14/integration_ibp.wl`](../../dev/src_legacy_flat_2026-06-14/integration_ibp.wl)
contains the most detailed current audit trail.  It explicitly attributes the
following to Appendix A.1 of `hep-ph/0403057`:

- `A22,LO` is a product of two massless two-point functions after factoring
  out `S_Gamma`.
- The one-loop-self route reduces to this disconnected two-bubble master.
- The tree/two-loop master set is continued from timelike `(-q2)^alpha`
  powers using explicit cosine-phase rules.

The same source separately exposes the convention transformations:

| Transformation | Implementation record |
|---|---|
| one-loop self two-parton conversion | `A22VirtualTwoPartonConventionFactor[]` |
| tree/two-loop virtual conversion | `A22TwoLoopTreeVirtualConventionFactor[]` |
| timelike continuation | `A22TwoLoopTreePaperConventionRules` with `Cos[2 Pi epsilon]` |
| common tree/two-loop paper factor | `A22TwoLoopTreePaperConventionFactor[]` |
| compact values used by runtime IBP substitution | checked-in `masterIntegrals/master_values_runtime.wl` |

The public route deliberately treats the matched `T_{qq}^{(6)}` brackets as
its four final components rather than silently relabelling an unspecified
internal antenna.  `A22TTermTargets` therefore remains an exact internal
comparison set for `{Leading, Subleading, Nf, Breve}`.

## Minimum evidence required for promotion

Do not upgrade either route until the following are checked in (or placed in
a durable thesis evidence bundle):

1. A source-versioned copy or stable bibliographic reference for
   `hep-ph/0403057`, with exact equation/appendix/table identifiers.
2. A component matrix: package label, paper label, colour factor, source
   equation, and target Laurent series.
3. A convention matrix: `S_Gamma`, loop measure, `q2` sign/continuation,
   dimensional regulator, and every multiplicative bridge.
4. For A31, a derivation of the `2 Pi^2` bridge and the lower-`A30` UV terms.
5. For the disputed A31 `Nf` coefficient, an archived resolution of the
   `19/2` versus `19/12` source discrepancy.
6. A clean, uncached recomputation whose residual is zero against the
   documented source expression, not merely an in-code duplicate target.

Until then, the existing exact residual checks are valuable regression
evidence, but they are not independent physics-validation evidence.
