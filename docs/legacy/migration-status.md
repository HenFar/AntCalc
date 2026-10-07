# Documentation migration ledger

[Documentation home](README.md) · [Manual](manual/index.md) · [Developer documentation](development/README.md)

`dev/README_old.md` is preserved as the source archive while the documentation is
being reorganised. This ledger records where each substantive section belongs;
it prevents a shorter README from becoming an accidental loss of technical or
scientific information. A migrated entry means its core content has a new
home—not that every archival implementation detail has necessarily been
rewritten into the public manual.

| Former README material | Destination | Status |
|---|---|---|
| Package identity, release promise, supported matrix, experimental branches and non-goals | [manual/route-status.md](manual/route-status.md) | migrated |
| Prerequisites, environments, loading, release verification and troubleshooting | [manual/installation.md](manual/installation.md) | migrated |
| Public API overview, components, return forms, and bulk workflow overview | [manual/public-api.md](manual/public-api.md) | migrated |
| Normalisation, renormalisation, dimensional regularisation and PaVe/IBP bridges | [manual/conventions-and-normalisation.md](manual/conventions-and-normalisation.md) | migrated |
| Stored results, cache identity and runtime artifacts | [manual/stored-results-and-reproducibility.md](manual/stored-results-and-reproducibility.md) | migrated |
| API appendix and option meanings | [reference/](reference/README.md) | migrated |
| Objects, records, master-combination views and intermediate stages | [reference/records-and-diagnostics.md](reference/records-and-diagnostics.md) | migrated; interface redesign noted |
| Validation reports and Ward checks | [reference/validation-and-reports.md](reference/validation-and-reports.md) | migrated |
| Recent development notes, completed-work index, experimental inspection, benchmarks, and active implementation plan | [development/research-status.md](development/research-status.md) | migrated |
| Runtime-master derivation operations and literature source mapping | [development/runtime-masters-and-provenance.md](development/runtime-masters-and-provenance.md) | migrated |
| Repository architecture, profile model, IBP convention boundary, and route-maintenance guidance | [development/architecture.md](development/architecture.md) and [route-maintenance.md](development/route-maintenance.md) | migrated |
| Shared terminology | [manual/glossary.md](manual/glossary.md) | migrated |
| Narrative, runnable walkthroughs | `docs/tutorials/` and `examples/` | authored separately |

During the transition, consult [dev/README_old.md](../dev/README_old.md) for archival
detail or historical implementation notes that do not belong in the stable
manual. A document is removed from that archive only after its destination has
been reviewed.
