# Runtime masters and literature provenance

[Developer index](README.md) · [Research status](research-status.md) · [Documentation home](../README.md)

The runtime loads checked-in A31/A22 master substitutions from:

```text
masterIntegrals/master_values_runtime.wl
```

This avoids rebuilding the derivation layer at package startup. It does not
make the artifact a cache of final antenna answers: it is a required runtime
input with its own provenance and validation workflow.

## Refresh and validate runtime values

After changing derivation-side files, refresh the runtime artifact:

```sh
cd /path/to/antenna_pipeline
bash masterIntegrals/run_kernel.sh -run 'Get["masterIntegrals/export_runtime_master_values.wl"]; Exit[]'
```

Validate it against the live derivation layer:

```sh
cd /path/to/antenna_pipeline
bash masterIntegrals/run_kernel.sh -run 'Get["dev/validate_runtime_master_values.wl"]; Exit[]'
```

## Source map

| Source | Role in the runtime/provenance layer |
|---|---|
| `hep-ph/0403057` | R-ratio and T-object construction; A31/A22 master provenance |
| `hep-ph/0311276` | A40/B40/C40 master-integral provenance |
| `hep-ph/0505111` | remaining main antenna targets and comparison objects |

The runtime distinguishes package-owned routing, normalisation, diagnostics,
and integration plumbing from imported targets and master values. Literature
expressions are comparison/provenance data unless the route has a documented
derivation to the corresponding runtime basis.

## A22 external release contract

The massless A22 release checks fresh, uncached direct integration and the
`BuildAndIntegrateAntenna` wrapper against an independent transcription in
[`dev/a22_literature_reference.wl`](../../dev/a22_literature_reference.wl).
That contract is `hep-ph/0403057v2`, Eqs. (4.8)--(4.10): its `Leading`,
`Subleading`, and `Nf` slots are the `N`, `1/N`, and `N_f` brackets of
Eq. (4.9), and `Breve` is the one-loop self-interference in Eq. (4.10).
The paper's common `(N - 1/N) T_{q\bar q}^{(2)}` factor is deliberately not
included in any public component slot. Equation (A.1) records the common
two-loop loop-normalisation convention.

The external reference is deliberately separate from `A22TTermTargets` and
the route's internal residual diagnostics. This makes its agreement a genuine
release-evidence check rather than an assertion that a route matches itself.

## A31 external release contract

The massless A31 release compares freshly integrated public output with the
independent reference in
[`dev/a31_literature_reference.wl`](../../dev/a31_literature_reference.wl).
It transcribes `hep-ph/0505111v3`, Eqs. (5.18)--(5.20), which define the
integrated leading, subleading, and `N_f` one-loop antennae (with their
definition in Eq. (2.35)). The public integration surface sets `s123 = 1`, so
the paper's common `(s123)^(-2 epsilon)` factor is one. Route-local A31
T-terms remain internal bookkeeping and are not the external comparison
object.

The corrected v3 source gives the `19/12` single-pole coefficient in Eq.
(5.20). This supersedes the older v2 TeX typo and is the convention used by
the runtime and the source contract.

## Massive A30

The massive route has a real runtime `MX30` reduction and a legitimate
unintegrated antenna. The paper numerator master is explicitly reduced in the
MX30 basis, and independent coefficient comparisons fix the common cut-measure
conversion to `I_paper = -j_MX30/4`. The resulting undotted and dotted runtime
master rules are active in the beta integration route. The retained reports
record this derivation chain; they are not a fit performed from the final
closed expression.

## Repository roles

| Directory | Role |
|---|---|
| `src/` | runtime source tree |
| `dev/` | release checks, benchmarks, and research/provenance scripts |
| `masterIntegrals/` | derivation-owned master-integral provenance |
| `bases/`, `generated_bases/` | integration backend assets |
| `stored_results/` | optional public-route replay cache, not source of truth |
