# Route status and support contract

[Manual index](index.md) · [Public API overview](public-api.md) · [Documentation home](../README.md)

AntCalc is active research software. A callable route is not necessarily
supported. The tables separate the tested massless release surface from
experimental work and beta extensions.

Each route exposes release-verification metadata through
`AntennaRouteProfileReport[A, 3, 0]["Verification"]`. It records the release,
last verification date, evidence scope, and any qualification. The table is
the public support contract; the profile data is its machine-readable record.

## Supported massless surface

| Family or workflow | Build | Integrate | Status |
|---|---:|---:|---|
| `A20` | yes | n/a | supported |
| `A30` | yes | yes | supported |
| `A40`, `tildeA40` | yes | yes | supported |
| `B40`, `C40` | yes | yes | supported |
| `A21` | yes | yes | supported |
| `A31`, `tildeA31`, `hatA31` | yes | yes | supported |
| `A22`, `tildeA22`, `hatA22`, `breveA22` | yes | yes | supported |
| `BuildRRatio[SMQCD, quarkMass -> 0]` | n/a | n/a | supported |
| `BuildAllAntennae[SMQCD, ...]` | yes | n/a | supported convenience workflow |
| `BuildAndIntegrateAllAntennae[SMQCD, ...]` | yes | yes | supported convenience workflow |

For a multi-component route, `Component` selects one named public component;
the component order and meaning are part of the route's public contract. The
package does not treat a stored expression that matches a target as evidence
of correctness by itself.

## Beta and experimental research tracks

| Route | Current scope | Status |
|---|---|---|
| massive `A30` | corrected build normalization, explicit MX30 numerator reduction, effective master bridge, and closed integrated route; corrected build/integration checks are pending | beta |
| `D30` | source-model and diagnostic work exists; validated public antenna extraction and integration are unfinished | experimental |

The previous massive `A30` normalization passed end-to-end public and
forced-MX30 checks, plus fresh uncached runs at `ExpansionOrder -> 0`, `1`, and
`2`. Those checks predate the factor-four correction and do not validate the
corrected route. Rerun them before relying on the current beta implementation.
Deeper epsilon orders are not claimed. Experimental routes can return
diagnostics, partial results, or `$Failed`; `D30` must not be treated as
supported.

## Contract principles

- `BuildAntenna[...]` constructs the package-facing unintegrated antenna.
- `IntegrateAntenna[...]` integrates an integrable antenna object.
- `BuildAndIntegrateAntenna[...]` composes those two operations; it is not a
  separate physics convention.
- Colour-coefficient signs and antenna definitions are reported separately.
  In particular, the sign associated with the `tilde A4^0` colour coefficient
  is not absorbed into the public antenna definition.
- Diagnostic records and intermediate-stage views expose provenance; they do
  not by themselves upgrade an experimental route into a validated one.

## Current non-goals

AntCalc does not currently claim:

- a finished public `D30` antenna or integration route;
- general `SUSY` or `HiggsEFT` R-ratio workflows;
- universal support for every research/provenance script under `dev/`.
