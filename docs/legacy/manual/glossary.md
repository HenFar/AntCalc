# Glossary

[Manual index](index.md) · [Public API overview](public-api.md) · [Documentation home](../README.md)

This page defines the package terms used throughout the manual and reference.

| Term | Meaning |
|---|---|
| **Route** | A public or internal execution path identified by an antenna family and its route metadata. |
| **Route key** | The canonical identifier `{type, multiplicity, loopOrder}`, such as `{A, 3, 0}` for A30. |
| **Profile** | The registry entry defining how a route is built, normalised, integrated, and post-processed. |
| **Component** | A public structural piece of a multi-component antenna, for example `Leading`, `Subleading`, `Nf`, or `Breve`. |
| **Contribution** | An internal physics-source branch, such as a self-energy or loop-insertion branch. It is not a public option and is not interchangeable with `Component`. |
| **AntennaObject** | The metadata-carrying integration input produced by the build layer. |
| **AntennaRunRecord** | The inspectable result container returned by `ReturnRecord -> True`. |
| **Stored result** | An optional cached public output reused through `UseStoredResults` and `StoreResults`; it is never a derivation. |
| **Runtime master value** | A checked-in master-integral substitution required by an integration backend. It is a runtime asset, not a cached antenna answer. |
| **Open-master route** | An integration view that exposes a master combination without replacing all masters by closed values. |
| **Public branch** | The package-facing output convention for a build route. |
| **Prototype branch** | A direct-expression provenance/inspection view. It is not an alternative integration contract. |

For the public workflow, see the [API overview](public-api.md). For object,
record, and master-combination details, see the [records reference](../reference/records-and-diagnostics.md).
