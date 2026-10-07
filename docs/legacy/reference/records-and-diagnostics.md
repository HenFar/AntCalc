# Records, objects, master combinations, and intermediate stages

[Reference index](README.md) · [Manual glossary](../manual/glossary.md) · [Documentation home](../README.md)

## `AntennaObject`

`AntennaObject[...]` transports a built antenna and the metadata needed for
integration. Its core fields include:

| Field | Meaning |
|---|---|
| `Key` | `{type, multiplicity, loopOrder}` route key |
| `Profile` | resolved route metadata |
| `BuildData` | route-owned build association |
| `FullAntenna` | full public result before selection |
| `Antenna` | currently selected antenna payload |
| `SelectedComponent` | active public component selection |
| `ContributionsUsed` | route-owned source branches used to obtain that component; `Missing["NotApplicable"]` when no decomposition applies |

Useful accessors are `AntennaKey`, `AntennaComponent`,
`AntennaContribution`, `AntennaExpression`, `AntennaFullExpression`, and
`AntennaObjectData`. `AntennaContribution[obj]` is retained as a historical
accessor name and returns the object's `ContributionsUsed` metadata, not a
user-selectable branch.

## `AntennaRunRecord`

`ReturnRecord -> True` returns an `AntennaRunRecord`. Its stable minimum is:

```text
RouteKind
Result
Diagnostics
IntermediateSteps
```

Build records can additionally include `BuildData`, `FullBuildResult`,
`SelectedBuildResult`, `AntennaObject`, `BuildDiagnostics`, and public/prototype
output-boundary information. Integration records can include `SourceObject`,
`InputAntenna`, `RawIntegrated`, `TTerms`, `FinalIntegrated`,
`SelectedIntegrated`, `BackendDiagnostics`, and `IntegrationDiagnostics`.
For an A22 combined integration, `ContributionDiagnostics` groups available
source diagnostics under `TwoLoopTree` and `OneLoopSelf`.

### Route-dependent integration aliases

When meaningful to the selected backend, an integration record can also expose
the following fields. These are route-dependent diagnostic aliases, not a
guarantee that every route has every representation.

| Field | Meaning |
|---|---|
| `IntegratedResultKind` | route/backend classification of the integrated result |
| `OpenMasterValuesQ` | whether open master values are in use |
| `RawLiteRedCombination`, `RawMasterCombination` | unreplaced backend master combination |
| `MasterMappedExpression`, `MasterSubstitutedExpression` | successive runtime-master mapping/substitution views |
| `MasterCombination`, `MasterCombinationView` | public inspectable master-combination payload and basis/provenance view |
| `NormalizedBeforeSeries`, `SeriesResult` | convention-normalised expression and its epsilon expansion |
| `OpenMasterRouteAvailable`, `OpenMasterRouteSucceeded` | availability and outcome of an open-master route |
| `OpenMasterSubstitutedExpression`, `OpenMasterSeriesResult`, `OpenMasterRouteDiagnostics` | open-master substitution, series, and diagnostic views |

`StoredResultCache` can appear when a stored-result mechanism participated in a
route. It records reuse provenance; it does not validate the physics result.

Not every route or backend supplies every field. Missing data must be treated
as an honest absence, not filled with a stored or literature expression.

## Master-combination views

`ReturnMasterCombination -> True` exposes an unreplaced runtime combination
when the integration route makes one available. Diagnostics/records attach a
`MasterCombinationView` that records basis information, master definitions,
and bridge status. The expression itself remains in runtime LiteRed notation,
which is essential when more than one basis occurs.

The public expression uses `d = 4 - 2 Epsilon` and `eps = Epsilon` before it
is displayed or returned. `MasterCombinationView["RawExpression"]` and the
backend `RawLiteRedCombination` retain LiteRed's original symbols for exact
runtime provenance.

For massive `A30`, the paper numerator master is reduced explicitly into the
MX30 basis and the common cut conversion is derived as
`I_paper = -j_MX30/4`. The runtime rules therefore substitute both MX30
masters directly; the raw master-combination view remains available for
provenance.

## Current intermediate-stage interface

`IntermediateSteps` captures selected named stages. Without
`ReturnDiagnostics` or `ReturnRecord`, a nonempty request returns:

```wl
{result, stagesAssociation}
```

`PrintIntermediateSteps -> True` additionally prints the captured association.
With `ReturnRecord`, the selected record stages are accessible through:

```wl
record["IntermediateSteps"]
```

The current build and integration labels are documented in the corresponding
[`BuildAntenna`](BuildAntenna.md) and [`IntegrateAntenna`](IntegrateAntenna.md)
pages. The all-stage capture and print split are retained for compatibility but
are under active public-interface redesign: the intended normal inspection
view is a small physical sequence such as amplitude, interference, antenna,
or input antenna, T terms, and integrated antenna.

On a stored replay, the current compatibility behaviour is to print the stored
stage payload when it is available. A missing payload remains missing; the
package must not regenerate or invent intermediate stages from a final cached
expression.
