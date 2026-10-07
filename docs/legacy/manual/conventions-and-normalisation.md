# Conventions and normalisation

[Manual index](index.md) · [Route status](route-status.md) · [Documentation home](../README.md)

This page states the conventions used by supported AntCalc routes. It separates
public antenna definitions from colour coefficients, backend expressions, and
experimental provenance bridges.

## Public convention boundary

`BuildAntenna` returns results in the package normalisation and renormalisation
convention. `IntegrateAntenna` and `BuildAndIntegrateAntenna` keep that
convention. Bare, pre-counterterm, and route-native expressions are for
provenance; they are not another public result.

Build records retain a `Public`/`Prototype` boundary for inspection. The
prototype branch is provisional and only supported for direct
`BuildAntenna[..., BuildOutputBranch -> "Prototype"]` expression inspection;
it is intentionally unavailable through integration-ready object forms.

## Colour components

For `A40`, `Leading` denotes one ordered `A4^0` antenna and `Subleading`
denotes `tilde A4^0` itself. The raw full-colour coefficient has the relation

```text
full-colour subleading coefficient = - tilde A4^0
```

The minus belongs to colour algebra at observable assembly; it is not absorbed
into the public antenna definition. The same separation between colour factors
and antenna definitions applies to analogous components.

## Dimensional regularisation and scales

The package declares one working continuation,

```text
D -> 4 - 2 Epsilon
```

controlled by `ApplyDimReg`. This is the package-wide convention for supported
workflows. The package does not independently validate `CDR`, `HV`, `GDR`, or
external-state prescriptions.

`q2` is the canonical public kinematic scale. The integration surface exposes
`KinematicScale -> q2` and `NormalizeKinematicScale`; inspect the route
environment report for the effective defaults of a specific route.

## Loop and backend bridges

Loop construction and integration are separate normalisation layers. The build
layer uses `LoopExpansionNormalization[1] = 8 Pi^2` and
`LoopExpansionNormalization[2] = (8 Pi^2)^2` when mapping loop objects into the
package expansion convention. A raw `PaVe` or IBP expression is therefore not
a public integrated antenna.

On relevant PaVe routes, `PaVeEvaluation -> "PaXEvaluate"` and
`ApplyFeynCalcMS -> True` are the public defaults. The massless `A21` route
uses an explicit Package-X-to-paper conversion rather than treating raw
`PaXEvaluate` output as final convention data. IBP loop families likewise use
an explicit backend-to-public convention bridge, reported in diagnostics as
`"ConventionBridgeFactor"` where applicable.

## A31 and A22

The public `A31` build branch applies the required lower-`A30` UV-counterterm
pattern; the prototype branch retains pre-counterterm route-native components
for provenance. The public integrated `A31` components match their encoded
targets after the master-convention repair.

The public `A22` build branch analogously presents an unintegrated lower-`A21`
UV-counterterm skin in its leading and `N_f` components. Its `AntennaObject`
retains the pre-skin prototype expression for integration, where the
authoritative integrated-`A21` subtraction is applied once in the T-term
layer. This prevents a public build correction from being counted twice by the
validated integrated route.

The final public integrated slots are compared to `hep-ph/0505111v3`,
Eqs. (5.18)--(5.20), at the package scale convention `s123 = 1`. They are
the paper's integrated `A_3^1`, `\tilde A_3^1`, and `\hat A_3^1` objects; the
route's intermediate T-terms are not public comparison objects.

For `A22`, the supported integrated object is the paper-facing
`T_{qq}^{(6)}` component set, not an unspecified package-internal final
antenna. The two-loop route is handled through dedicated master-integral
machinery rather than a generic PaVe basis.

Its four public slots use the convention of `hep-ph/0403057v2`: `Leading`,
`Subleading`, and `Nf` are the `N`, `1/N`, and `N_f` brackets in Eq. (4.9),
while `Breve` is the one-loop self-interference of Eq. (4.10). The common
`(N - 1/N) T_{q\bar q}^{(2)}` factor shown in Eqs. (4.8)--(4.9) is assembled
outside those component slots.

## Massive A30

The unintegrated massive `A30` route is package-derived. Its integrated beta
route reduces to the `MX30` basis and uses the derived common cut-measure
conversion

```text
I_paper = - j_MX30 / 4.
```

Together with the explicit reduction of the paper numerator master, this gives
the active dotted-master substitution rather than a backwards-fitted closed
form. Fresh-kernel public results through `ExpansionOrder -> 2` are checked
against their runtime references; deeper epsilon orders remain outside the
beta support claim. See the [route status](route-status.md) for the support
boundary.

## Inspecting convention state

```wl
AntennaPipelineConventionModel[]
AntennaPipelineConventionReport[]
AntennaPipelineDimRegDeclaration[]
AntennaRouteProfileReport[A, 3, 1]
AntennaRouteEnvironmentReport[A, 3, 1]
```
