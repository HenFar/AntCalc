# Stage 07: Reduction Scaffold

- Status: derived
- Object: public/package scaffold for the massive `A30` reduction route
- Code areas:
  - `src/integration_router.wl`
  - `src/integration_ibp.wl`
  - `generated_bases/MX30/README.md`

## Flag summary

- `[DERIVED]`
  The scaffold itself is implemented and testable.
- `[HARD-GATE]`
  The route still stops before reduction, on purpose.
- `[DO-NOT-FAKE]`
  No basis or master data are invented here.

## What was implemented

- A new massive IBP family placeholder, `MX30`.
- Public integration-side routing for `{A, 3, 0}` with `quarkMass != 0`.
- An explicit early-stop diagnostic in the IBP backend when the profile is
  only a scaffold.
- A stable future basis root under `generated_bases/MX30/`.

## What this means in practice

If we call the massive integrated route now, the package should not silently
fall back to the massless `X30` family.

Instead, it should fail honestly with a profile that says, in effect:

- this is a massive `A30` reduction request;
- the intended family is `MX30`;
- the basis generation and term-preparation steps are still missing.

## Why this is the right first implementation

- `[SAME-AS-MASSLESS]` We are preserving the architecture of the massless IBP
  route: profile -> basis family -> reduction -> masters.
- `[MASSIVE-NEW]` We are not pretending the old `X30` family works for the
  massive kinematics.
- `[DO-NOT-FAKE]` We stop before reduction instead of producing a misleading
  answer in the wrong family.

## What is still missing

- the explicit massive phase-space cut structure;
- the actual LiteRed denominator family;
- the massive term-preparation adapter;
- the first successful basis match;
- the first reduced master combination.

## Immediate next target

- derive and encode the true `MX30` denominator family;
- then generate the first real LiteRed basis for that family.
