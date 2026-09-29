# Stage 05: Original Thesis Match

- Status: derived
- Object: direct paper-facing rewrite of the reconstructed massive antenna
- Script: `dev/massiveA30/05_check_match_to_thesis.wl`
- Comparison target: paper Eq. (3.1), as discussed in thesis Section 4.5

BlockedOn: None

ForcedStepUsed: None

WhyAcceptableTemporarily: Not applicable

WhatMustBeReplacedLater: Nothing at the build-side level

What the original transcription check established:

- The Born denominator was encoded as
  `4 ((1 - epsilon) q2 + 2 mf^2)`.
- The `mf^2` term in the kinematic bracket used the
  `- 4 s12/(s13 s23)` structure.
- The thesis-side convention used here is
  `s123 = s12 + s13 + s23`, while the massive invariant satisfies
  `q2 = s123 + 2 mf^2`.
- The thesis-facing comparison is a four-dimensional numerator comparison,
  so the successful bridge uses `epsilon -> 0`.

The original target transcription omitted the explicit numerator factor `4`
from paper Eq. (3.1). Restoring it makes the public massive antenna's
`quarkMass -> 0` limit agree with the massless `A30`. The thesis's separate
`1/4` coefficient ratio in Eqs. (4.43)--(4.45) was inferred using the same
undernormalized build, so it does not establish a pure cut-measure conversion.

What the final bridge is:

- Start from the notebook-style raw interference.
- Strip the couplings in the same way as the notebook route.
- Apply the explicit package-to-thesis normalization factor
  `4/3 * colourNorm`.
- Compare against the corrected thesis expression in paper convention.

Result:

- The validation script now reports an exact direct residual of `0`.
