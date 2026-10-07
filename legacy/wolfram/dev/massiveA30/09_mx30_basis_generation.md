# Stage 09: MX30 Basis Generation

- Status: derived
- Object: generated LiteRed basis family for the massive integrated `A30`
- Code areas:
  - `dev/generate_mx30_bases.wl`
  - `generated_bases/MX30/`

## What was achieved

- The six topology variants of the `MX30` family were generated with LiteRed.
- Each basis now exists on disk under `generated_bases/MX30/`.
- LiteRed identified the first massive master sets for those bases.

## Important implementation choice

The basis was regenerated in the same sign convention that the prepared
massive-antenna integrand naturally lands on:

- `m2 - sp[p1, p1]`
- `m2 - sp[p2, p2]`
- `m2 - sp[q - p2, q - p2]`
- `m2 - sp[q - p1, q - p1]`
- `2 m2 - sp[p1 + p2, p1 + p2]`

That ended up being cleaner than keeping the earlier opposite-sign convention
and then fighting repeated sign flips during term preparation.

## Developer command

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/generate_mx30_bases.wl"]; Exit[]'
```

## Boundary

This stage means the family is real and generated.

It does not yet, by itself, mean the public `IntegrateAntenna[...]` route
should expose the result. The next gate is reduction-readiness against the
actual massive `A30` build output.
