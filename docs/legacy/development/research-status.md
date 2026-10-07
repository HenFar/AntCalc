# Research-status ledger

[Developer index](README.md) · [Route status](../manual/route-status.md) · [Documentation home](../README.md)

This is a dated development snapshot, not the supported-route contract. For
what AntCalc currently promises to an external user, use the [route-status
matrix](../manual/route-status.md).

## Current position

AntCalc is in-progress thesis research software. Its supported massless routes
are suitable for inspection, testing, and academic evaluation; the repository
is not a frozen general-purpose release. Experimental branches and `dev/`
scripts record active work, not hidden promises of completeness.

## Recent milestones

- **2026-07-31:** fresh uncached A22 all-component acceptance passed after the
  public build-side unintegrated-A21 UV skin was separated from the prototype
  integration payload. All T-term and integrated-antenna residuals are zero,
  direct and one-shot routes agree exactly, and the `hep-ph/0403057v2`
  contract passes; this verifies that the integrated subtraction is not double
  counted.
- **2026-08-06:** massive A30 obtained a derived MX30-basis closure: the paper
  numerator representative was reduced explicitly, the common cut-measure
  factor was independently recovered from both master coefficients, and the
  public order-zero route matched its runtime reference in a fresh kernel.
- **2026-07-30:** all A22 prototype virtual colour components completed
  loop-only IBP reduction with zero unmatched terms. The leading component
  compacts from 70,899 to 567 leaves over seven exact-topology masters; the
  subleading component compacts from 69,511 to 857 leaves over nine; and the
  \(N_f\) component compacts from 7,515 to 87 leaves over a single master.
- **2026-07-29:** fresh uncached A31 release acceptance validates the public
  integrated leading, subleading, and \(N_f\) components against the independent
  `hep-ph/0505111v3` contract (Eqs. (5.18)--(5.20)); direct and one-shot
  integration agree exactly.
- **2026-07-28:** fresh uncached release acceptance externally validates both
  public A40 components (`Leading` and `Subleading`), with exact direct versus
  wrapper agreement and their declared literature checks passing.
- **2026-07-29:** fresh uncached release acceptance externally validates B40
  and C40, with exact direct versus wrapper agreement in each case.
- **2026-07-29:** fresh uncached NNLO `BuildRRatio[SMQCD]` validates its full
  massless assembly against the raw Laurent-pole and finite reference target.
- **2026-07-27:** fresh uncached release acceptance validates every massless
  A22 public component (`A22All`, `Leading`, `Subleading`, `Nf`, and `Breve`)
  against the independent `hep-ph/0403057v2` equation contract; all five cases
  pass direct and wrapper integration checks.
- **2026-07-15:** raw one-loop A31 Ward identity passes after PaVe tensor
  reduction.
- **2026-07-14:** massless A30 and both A40 external-gluon Ward replacements
  pass exactly.
- **2026-07-14:** fresh uncached NNLO `BuildRRatio` validation closes through
  epsilon^0 and agrees with the encoded SMQCD finite target.
- **2026-07-14:** A31 Appendix A.2 master phase/convention repair reproduces
  direct paper targets and removes EulerGamma from public series.
- **2026-07-11:** public integrated A22 first matched the
  `hep-ph/0403057` paper-facing `T_{qq}^{(6)}` components; that result was
  subsequently upgraded to fresh-kernel external validation on 2026-07-27.
- **2026-07-08:** A40/B40/C40 normalisation was aligned with the standard A30
  convention path.
- **2026-07-01:** package-wide defaults and stored-result semantics were
  consolidated and revalidated.
- **2026-06-29–30:** the A31 public build boundary and direct-expression
  public/prototype selector were introduced.

## Completed foundation

The following development tracks are complete enough to underpin the current
massless contract:

1. canonical convention metadata and route/environment reports;
2. explicit `D -> 4 - 2 Epsilon` declaration;
3. public/prototype output-boundary infrastructure;
4. A31 public build-side counterterm presentation and integrated target repair;
5. PaVe/Package-X and IBP convention bridges;
6. package-wide defaults with explicit precedence;
7. cache semantic-versioning and public/prototype cache separation;
8. exact massless validation slices for integrated routes, R-ratio closure,
   and applicable Ward identities.

## Active and deferred work

| Track | Status |
|---|---|
| A31 external literature contract | complete: fresh uncached acceptance passed on 2026-07-29 against `hep-ph/0505111v3`, Eqs. (5.18)--(5.20) |
| A22 loop-only IBP compaction | all three colour components reduce exactly with zero unmatched terms: leading is a 567-leaf seven-master expression, subleading an 857-leaf nine-master expression, and `N_f` an 87-leaf single-master expression; the presentation boundary now preserves those masters while using the public \(d=4-2\epsilon\) notation, guarded by exact reconstruction |
| A22 UV-renormalisation boundary | complete: the public build-side unintegrated-A21 skin is separated from the prototype payload consumed by integration, which retains the authoritative integrated-A21 subtraction; fresh all-component acceptance passed on 2026-07-31 |
| A22 loop-level master substitutions | complete for the public build boundary: loop dependence is reduced to its declared scalar-master representation, leaving only invariant dependence and PaVe scalar functions where applicable |
| Catani-operator validation | not yet implemented |
| Factorisation-limit validation | not yet implemented |
| Massive A30 second-master derivation | complete for the beta MX30 route: explicit numerator reduction plus independently matched cut-measure factor activate the runtime dotted-master substitution |
| User-facing examples/tutorial notebooks | planned separately from `dev/` scripts |
| Broader convention-regression coverage | deferred maintenance work |
| Systematic massive programme, massive B4/C4, initial-state antennae | research extensions |

The massive A30 beta route now has the paper/runtime master-basis derivation,
dedicated regression coverage, and fresh-kernel qualification through
`ExpansionOrder -> 2`. Its remaining release work is inclusion in the final
fresh-kernel acceptance run, not an unresolved master mapping.

## Experimental inspection

The massive A30 beta branch remains callable
for diagnostics. Only the former has a derived integrated master closure;
neither branch should be confused with a cached-result claim.

```wl
BuildAntenna[A, 3, 0, quarkMass -> mQ, ReturnRecord -> True]
BuildAntennaObject[A, 3, 0, quarkMass -> mQ]
BuildAndIntegrateAntenna[A, 3, 0, quarkMass -> mQ, ReturnDiagnostics -> True]

BuildAntenna[D, 3, 0, ReturnDiagnostics -> True]
BuildAntenna[D, 3, 0, ReturnRecord -> True]
```

Related derivation and source-route material is under
[`dev/massiveA30`](../../dev/massiveA30),
[`dev/massiveA30_sources`](../../dev/massiveA30_sources), and
the retained historical source material under `dev/`.

## Benchmarking is not acceptance

The benchmark harness is available locally:

```sh
/Applications/Wolfram.app/Contents/MacOS/WolframKernel -noprompt \\
  -script dev/run_public_route_benchmarks.wl
```

It records performance characteristics only. Release and physics acceptance
remain separate correctness-facing workflows; a timeout or a fast cached value
does not establish physics agreement.

## Transparency rules

- Supported, experimental, and prototype states must remain distinct.
- A route is not “complete” merely because a cached/stored expression matches
  a paper target.
- Diagnostics should report unresolved bridge status rather than mask it.
- Interface documentation should describe actual current behaviour and mark
  compatibility controls under redesign.

## Authorship note

The physics, package architecture, and profile/route design are thesis work by
the repository author. AI coding tools were used for implementation
acceleration, bug finding, stress testing, and documentation drafting from the
author's working notes and task tracking.
