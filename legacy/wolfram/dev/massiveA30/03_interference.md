# Stage 03: Interference

- Status: derived
- Object: massive self-interference and its normalized version
- Script: `dev/massiveA30/03_check_interference.wl`
- Comparison target: internal consistency between raw self-interference and
  normalized interference after division by the born object and `colourNorm`

BlockedOn: None

ForcedStepUsed: None

WhyAcceptableTemporarily: Not applicable

WhatMustBeReplacedLater: Nothing

What matters physically:

- This is the first point where the package produces the squared matrix
  element-like object from the amplitude rather than borrowing it from the
  thesis.

What convention issue appears here:

- The raw interference is naturally expressed in FeynCalc propagator language,
  so the reconstruction helper applies an explicit massive `A30` canonicalization
  step into the invariant language.
