# Route status and support contract

This page documents the legacy Wolfram package. Shell commands and package
asset paths below are relative to `legacy/wolfram/`; change to that directory
before running them. The current runner is described in the
[Kira workflow guide](../../manual/kira-workflow.md).

[Manual index](index.md) · [Public API overview](public-api.md) · [Documentation home](../../README.md)

AntCalc is active research software. A callable route is not necessarily
supported. The tables separate the tested massless release surface from
experimental work and beta extensions.

Each route exposes release-verification metadata through
`AntennaRouteProfileReport[A, 3, 0]["Verification"]`. It records the release,
last verification date, evidence scope, and any qualification. The table is
the public support contract; the profile data is its machine-readable record.

## Supported massless surface

This table describes the legacy Wolfram package API. AntCalc 0.3.5's Python /
FORM / Kira workflow currently covers massless `A30`, `A40`, `B40`, and `C40`; see
its [scope and input contract](../../manual/kira-workflow.md#supported-inputs).

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
| massive `A30` | dimensionally continued build, explicit MX30 numerator reduction, derived common cut factor, closed integrated route, and fresh-kernel epsilon-depth qualification through order 2 | beta |

The massive `A30` beta route has passed end-to-end public and forced-MX30
checks, plus fresh uncached runs at `ExpansionOrder -> 0`, `1`, and `2`. Each
matched its corresponding runtime reference and retained no runtime masters or
loop objects. Deeper epsilon orders are not yet claimed. Experimental routes
can return diagnostics, partial results, or `$Failed`.

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

- general `SUSY` or `HiggsEFT` R-ratio workflows;
- universal support for every research/provenance script under `dev/`.
