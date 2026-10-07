# Stage 04: Extraction

- Status: derived
- Object: extracted massive antenna and explicit born normalization object
- Script: `dev/massiveA30/04_check_extraction.wl`
- Comparison target: exact recovery of the existing package `A30` in the
  `quarkMass -> 0` limit

BlockedOn: None

ForcedStepUsed: None

WhyAcceptableTemporarily: Not applicable

WhatMustBeReplacedLater: Nothing

What matters physically:

- The antenna is not treated as a standalone formula.
- It is reconstructed as the normalized interference divided by the massive
  born object and the usual color normalization.

Important defense point:

- The massless limit is exact:
  `MassiveA30ExtractedAntenna[quarkMass -> 0] == BuildAntenna[A, 3, 0]`.
