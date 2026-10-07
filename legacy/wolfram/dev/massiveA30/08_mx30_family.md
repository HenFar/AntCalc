# Stage 08: MX30 Family Encoding

- Status: derived
- Object: explicit massive `A30` reduction-family data, without pretending the
  LiteRed basis is already generated
- Code areas:
  - `src/integration_ibp.wl`
  - `dev/massiveA30/08_check_mx30_profile.wl`

## Flag summary

- `[DERIVED]`
  The massive cut structure and topology table are now encoded in code.
- `[MASSIVE-NEW]`
  The mass shifts are explicit and are the real difference from `X30`.
- `[HARD-GATE]`
  This is still not a finished reduction path.
- `[DO-NOT-FAKE]`
  No generated basis or master data are claimed here.

## What was added

- `MX30CutDenominators[mass]`
  The three cut denominators:
  - `p1^2 - m^2`
  - `p2^2 - m^2`
  - `p3^2`

- `MX30InvariantBridgeRules[mass]`
  The explicit bridge between package invariants and massive quadratic forms:
  - `s12 = (p1 + p2)^2 - 2 m^2`
  - `s13 = (q - p2)^2 - m^2`
  - `s23 = (q - p1)^2 - m^2`

- `MX30BasisTopologyDenominators[topology, mass]`
  A topology-by-topology candidate family mirroring the six existing massless
  `X30` basis files, but with the correct heavy-mass shifts.

## What this buys us

- The massive route is no longer only “some future family called MX30”.
- We now have a concrete answer to:
  - what the on-shell cut structure should be;
  - how the invariants sit inside the massive kinematics;
  - what the massless limit should reduce to.

## What was checked

`dev/massiveA30/08_check_mx30_profile.wl` verifies:

- the profile phase-space factor is the product of the three massive cut
  denominators;
- the `mass -> 0` limit of each topology reproduces the existing concrete
  `X30` topology denominators;
- the invariant bridge reduces to the expected massless quadratic forms.

## What is still missing

- a real LiteRed `NewDsBasis[...]` generation step for the shifted
  denominators;
- basis loading from `generated_bases/MX30/`;
- term preparation and matching against those generated bases;
- the first actual reduction to masters.

## Honest boundary

This stage makes the family inspectable and testable.

It does **not** yet mean:

- LiteRed has accepted the shifted basis;
- the basis files exist on disk;
- `IntegrateAntenna[..., quarkMass -> mQ]` can already reduce.
