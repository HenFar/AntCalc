# Fresh-kernel release acceptance evidence — 2026-07-22

This bundle preserves the target-backed massless acceptance reports used to
close Phase 1 of the thesis-readiness plan. All reports were generated with
stored results disabled.

| Case | Status |
|---|---|
| A20 | Validated |
| A21 | Validated |
| A30 | Validated |
| A40 Leading | Validated |
| A40 Subleading | Validated |
| B40 | Validated |
| C40 | Validated |

B40 and C40 were rerun after fixing the release worker so advisory route
messages are not converted into false `$Failed` results. The retired
`dev/run_release_verification.wl` was also executed on this date and exited
with code 2, confirming it cannot produce a release pass.
