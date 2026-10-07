# 2026-06-03 X40 validation and benchmark pass

## Fresh-kernel public-route checks

Commands run from a clean kernel:

```wl
BuildAndIntegrateAntenna[B, 4, 0, ReturnDiagnostics -> True, ExpansionOrder -> 0]
BuildAndIntegrateAntenna[C, 4, 0, ReturnDiagnostics -> True, ExpansionOrder -> 0]
```

Observed behavior after correcting the earlier `Check[...]` wrapper mistake:

```text
A40 Leading        public route succeeds; backend diagnostics report
                   UnmatchedCount -> 0 and RemainingTojSpOrDotQ -> False

A40 Subleading     treated as already verified in the package regression notes

B40                BuildAntennaObject[B, 4, 0] succeeds in about 10 s
                   IntegrateAntenna[obj, ...] succeeds in about 81 s
                   BuildAndIntegrateAntenna[...] succeeds in about 90 s
                   Returns the expected {integrated expression, diagnostics}
                   pair through both public routes

C40                BuildAntennaObject[C, 4, 0] succeeds in about 6 s
                   IntegrateAntenna[obj, ...] succeeds in about 252 s
                   BuildAndIntegrateAntenna[...] succeeds in about 255 s
                   Returns the expected {integrated expression, diagnostics}
                   pair through both public routes
```

The earlier `$Failed` conclusion for `B40` and `C40` was a false negative from
wrapping the calls in `Check[..., $Failed]`, which caught the intentional
`IntegrateAntenna::heavy` warning message.

## Benchmark harness

Added:

```text
dev/run_public_route_benchmarks.wl
```

Current behavior:

```text
- Loads the package from a clean kernel
- Runs only public entrypoints
- Measures BuildAntenna, BuildAntennaObject, IntegrateAntenna, and
  BuildAndIntegrateAntenna
- Covers the baseline route set agreed for the benchmark phase
- Emits a JSON report with route label, entrypoint, wall-clock time,
  success/failure, timeout flag, and diagnostic summary fields when available
```

Follow-up after the first benchmark pass:

```text
- The initial A21 benchmark failure exposed a real public inconsistency:
  BuildAntennaObject[A, 2, 1] with the old default build settings produced a
  raw loop object that later mixed 4- and D-dimensional quantities inside the
  object-based IntegrateAntenna route.
- The fix was to move the PaVe-reduced loop-shape choice fully onto the build
  side: one-loop BuildAntenna now defaults to the PaVe form, integrable
  one-loop objects now choose the backend-compatible build shape they need,
  and IntegrateAntenna always performs integration rather than serving as a
  PaVe-shape toggle.
```

## Timing diagnostics and X40 performance investigation

Added public investigation support for IBP-backed routes:

```text
- `DetailedTimingDiagnostics -> True`
- `BackendDiagnostics["TimingDiagnostics"]`
- `BackendDiagnostics["TermRecords"]` for optional per-term match/reduce timing
```

The first timing split on `A40 Leading` and `A40 Subleading` showed:

```text
- basis loading was negligible compared with the reduction stage
- the final series/simplification stage was negligible
- the dominant cost was `MatchIBPBasis`, not `IBPReduce`
```

Representative object-first fresh-kernel timings before any X40 reordering:

```text
A40 Leading      EndToEndSeconds about 690
                 MatchSeconds about 613
                 IBPReduceSeconds about 74

A40 Subleading   EndToEndSeconds about 1823
                 MatchSeconds about 1645
                 IBPReduceSeconds about 175
```

Basis-use summaries then showed that the worst `A40 Subleading` match-time
offenders were late-scanned chain/hybrid bases such as:

```text
chainBasis1432
chainBasis1342
hybridBasis1234
hybridBasis1243
```

## Shared X40 basis-order optimization

Rather than introducing route-specific `X40` heuristics immediately, the
package now adopts one shared reordered `X40` basis scan for the whole family.
This preserves one common family structure while still targeting the dominant
matching bottleneck.

Fresh-kernel object-first timings after the shared reorder:

```text
A40 Leading      EndToEndSeconds about 194
A40 Subleading   EndToEndSeconds about 582
B40              EndToEndSeconds about 16
C40              EndToEndSeconds about 308
```

Interpretation:

```text
- The shared reorder gives a major speedup for A40 Leading, A40 Subleading,
  and B40.
- C40 becomes somewhat slower than the earlier baseline, but remains clean and
  operationally bounded.
- The current project choice is to keep one uniform X40 basis-order structure
  rather than split the family into route-specific basis-order heuristics.
```

## Next investigation target

The next family-level performance question was then pushed to `A31 Leading`.

Fresh-kernel object-first timing diagnostics for `A31 Leading` gave:

```text
EndToEndSeconds about 695
MatchSeconds about 647
IBPReduceSeconds about 47
```

So the `A31` family shows the same dominant bottleneck shape as the heavy
`X40` routes: basis loading and final simplification are negligible compared
with `MatchIBPBasis`.

The leading basis-use summaries were:

```text
Counts:
A31Basis9  -> 219
A31Basis12 -> 101
A31Basis10 -> 101
A31Basis6  -> 51
A31Basis3  -> 47
A31Basis2  -> 46
A31Basis5  -> 34
A31Basis4  -> 30

Match time:
A31Basis9  -> about 249 s
A31Basis10 -> about 159 s
A31Basis12 -> about 158 s
A31Basis2  -> about 48 s
```

From that evidence the package now adopts one family-level reordered `A31`
basis scan, prioritizing:

```text
A31Basis9, A31Basis10, A31Basis12, A31Basis2,
then A31Basis6, A31Basis5, A31Basis4, A31Basis3,
followed by the remaining A31 bases
```

The remaining measurement task is now straightforward:

```text
- rerun the fresh-kernel A31 Leading object-first timing with the reordered
  family basis order
```

That follow-up run now gives:

```text
EndToEndSeconds about 197
MatchSeconds about 149
IBPReduceSeconds about 47
```

So the family-level reorder reduces the fresh-kernel `A31 Leading`
object-first route from about 695 s to about 197 s on the benchmark MacBook
Pro M4, while leaving the post-reduction symbolic work essentially unchanged.
