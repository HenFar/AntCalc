# Stage 05: Match to Thesis

- Status: derived
- Object: direct paper-facing rewrite of the reconstructed massive antenna
- Script: `dev/massiveA30/05_check_match_to_thesis.wl`
- Comparison target: thesis Chapter 5, especially eq. `(5.1.3)`

BlockedOn: None

ForcedStepUsed: None

WhyAcceptableTemporarily: Not applicable

WhatMustBeReplacedLater: Nothing at the build-side level

What was corrected before the match closed:

- The denominator in eq. `(5.1.2)` had to be encoded as
  `4 ((1 - epsilon) q2 + 2 mf^2)`.
- The `mf^2` term in eq. `(5.1.1)` had to be transcribed with the
  `- 4 s12/(s13 s23)` structure that appears on the page.
- The thesis-side convention used here is
  `s123 = s12 + s13 + s23`, while the massive invariant satisfies
  `q2 = s123 + 2 mf^2`.
- The thesis-facing comparison is a four-dimensional numerator comparison,
  so the successful bridge uses `epsilon -> 0`.

What the final bridge is:

- Start from the notebook-style raw interference.
- Strip the couplings in the same way as the notebook route.
- Apply the explicit package-to-thesis normalization factor
  `4/3 * colourNorm`.
- Compare against the corrected thesis expression in paper convention.

Result:

- The validation script now reports an exact direct residual of `0`.
