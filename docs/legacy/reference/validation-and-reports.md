# Validation and introspection reports

[Reference index](README.md) · [Manual route status](../manual/route-status.md) · [Documentation home](../README.md)

## Route and driver validation

```wl
AntennaPhysicsValidationReport[A, 3, 0]
BuildRRatioPhysicsValidationReport[]
RunSupportedMasslessPhysicsValidation[]
```

`AntennaPhysicsValidationReport` runs the available physics-aware validation
for a public route. Exact integrated target coverage includes `A21`, `A30`,
`A31`, `A22`, `A40`, `B40`, and `C40`; a route that itself returns `$Failed`
is reported as `RouteEvaluationFailed`, not mislabeled as a physics mismatch.

`BuildRRatioPhysicsValidationReport` evaluates the raw dimensional series,
checks Laurent cancellation through epsilon^0, and compares the finite
coefficient with the public massless SMQCD expression. It reports a structured
status rather than a notebook-only visual comparison.

`RunSupportedMasslessPhysicsValidation` aggregates the current supported
integrated massless validation and the R-ratio validation slice. Use
`PhysicsValidationStatusCounts[report]` to summarise it.

## Ward identities

```wl
VerifyWardIdentity[]
VerifyWardIdentity[A, 3, 0]
VerifyWardIdentity[A, 4, 0, GluonLeg -> 3]
VerifyWardIdentity[A, 3, 1, ReturnDiagnostics -> True]
```

The validator replaces an external gluon polarisation by its momentum in a
full unsquared amplitude. Current verified scope is massless `A30`, both
applicable `A40` gluons, and raw one-loop `A31`; `A20`, `A22`, `B40`, and
`C40` report `NotApplicable`. Massive `A30` is outside this scope.
The `A31` check can take substantially longer and does not write stored-result
artifacts.

## Convention and route reports

```wl
AntennaPipelineConventionReport[]
AntennaPipelineDimRegDeclaration[]
AntennaRouteProfileReport[A, 3, 1]
AntennaRouteEnvironmentReport[A, 3, 1]
```

These return associations rather than executing a route. They respectively
describe package conventions, the code-level dimensional declaration,
route profiles/stories, and the effective build/integration/one-shot defaults.

`AntennaRouteProfileReport[A, 3, 0]["Verification"]` additionally
returns the release-verification ledger for that route: release identity, last
verification date, evidence scope, and qualifications such as the beta massive
A30 extension. This metadata records evidence; it never promotes a cached
result into a supported physics claim.

## Package-wide defaults

```wl
AntennaPipelineDefaults[]
SetAntennaPipelineDefaults[<|"UseStoredResults" -> True|>]
ResetAntennaPipelineDefaults[]
```

The defaults report records built-in defaults, user overrides, supported keys,
managed public heads, and precedence. Per-call options take precedence over
package-wide user defaults, which in turn take precedence over built-ins.
