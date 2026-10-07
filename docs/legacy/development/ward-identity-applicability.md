# Ward-identity applicability matrix

[Developer index](README.md) · [Research-status ledger](research-status.md) · [Route status](../manual/route-status.md)

This matrix states where an amplitude-level Ward replacement is meaningful in
the supported massless workflow.  It is deliberately narrower than the route
validation matrix: it replaces one external-gluon polarisation by its momentum
on an **unsquared amplitude**, before interference, reduction, or integration.
It is not a test of an already integrated expression or of an R-ratio
combination.

| Supported route / object | Applicability | Evidence / reason |
|---|---|---|
| `A20` | NotApplicable | The initial validator is restricted to massless A-type source amplitudes with external gluons; this two-parton tree route has none. |
| `A21` | NotApplicable | No external-gluon amplitude is exposed in the initial Ward-validation scope.  Its integrated checks are separate convention/target evidence. |
| `A30` | Applicable — Pass expected | Raw massless tree amplitude; external gluon leg `{3}`.  The research ledger records an exact Ward replacement pass on 2026-07-14. |
| `A31` | Applicable — Pass expected | Raw massless one-loop amplitude; external gluon leg `{3}`; the validation path includes PaVe tensor reduction.  The research ledger records a pass on 2026-07-15. |
| `A22` `T_{q\\bar q}^{(6)}` components | NotApplicable | The supported public object is a matched integrated virtual T-component set, not an unsquared external-gluon source amplitude. |
| `A40` Leading / Subleading | Applicable — Pass expected | Raw massless tree amplitude; external gluon legs `{3,4}`.  The research ledger records exact Ward replacement passes for both legs on 2026-07-14. |
| `B40`, `C40` | NotApplicable | These routes do not expose external-gluon amplitudes in the initial validator’s scope. |
| Massless SMQCD R-ratio | NotApplicable | It is an assembled inclusive observable, not a single external-gluon amplitude. |

Massive A30, massive four-parton routes, and initial-state families are
outside the supported thesis scope; no statement here promotes their
experimental diagnostics to supported validation.

## Implementation boundary

`AntennaWardIdentityProfile` declares exactly three applicable keys:

- `{A, 3, 0}`: raw tree amplitude, leg `3`;
- `{A, 4, 0}`: raw tree amplitude, legs `3` and `4`;
- `{A, 3, 1}`: raw one-loop amplitude, leg `3`, with PaVe tensor reduction.

All other keys receive `NotApplicable` with the reason
`NoExternalGluonInInitialWardScope`.  This makes absence of a Ward test an
explicit physics-boundary decision rather than silent missing coverage.

## Reconfirmation command

Run this in a fresh kernel when reconfirming the recorded applicable-route
results:

```sh
/Applications/Wolfram.app/Contents/MacOS/WolframKernel -script dev/check_ward_identities.wl
echo $?
```

It should report `PASS` for A30, A40, and A31 and return `0`.  It does not
test print diagrams.  If A31 takes appreciably longer, that is expected: its
validator performs one-loop PaVe tensor reduction under its 900-second
simplification limit.
