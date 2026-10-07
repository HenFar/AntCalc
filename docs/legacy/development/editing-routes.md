# Editing routes

AntCalc route physics is declared in `src/routes/families/`.  Each supported
family has exactly one file and starts with an **EDIT HERE** association.

1. Edit a family file to change a family-specific process, sector, extraction,
   convention, basis, or validation setting.
2. Edit a funnel only when the same operation should change for multiple
   families.  Funnels consume resolved route data and must never branch on an
   antenna name.
3. Edit an adapter only for mechanics unique to one family or named variant.

`AntennaRouteReport[key, options]` shows the file, variant, funnels, adapters,
and resolved settings used by a call.  A30 has explicit `Massless` and
`Massive` variants; a nonzero `quarkMass` selects the latter.

The compatibility functions `AntennaProfile` and `AntennaIntegrationProfile`
remain available for existing notebooks, but their values are derived from the
family declarations.
