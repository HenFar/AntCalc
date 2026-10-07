# Route map

This page documents the legacy Wolfram package. Shell commands and package
asset paths below are relative to `legacy/wolfram/`; change to that directory
before running them. The current runner is described in the
[Kira workflow guide](../../manual/kira-workflow.md).

| Family | Editable declaration | Build funnel | Integration funnel |
| --- | --- | --- | --- |
| A20 | `families/A20.wl` | tree self-interference | IBP |
| A30 | `families/A30.wl` | tree self-interference | IBP / MX30 variant |
| A21, A31 | corresponding family file | loop interference | PaVe / IBP |
| A22 | `families/A22.wl` | two-loop assembly | IBP |
| A40 | `families/A40.wl` | colour ordered | IBP |
| B40, C40 | corresponding family file | sector interference | IBP |

Use `AntennaRouteReport` before changing a route: it is the authoritative map
from public options to the declaration, funnel, and local adapter.
