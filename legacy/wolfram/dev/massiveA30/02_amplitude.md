# Stage 02: Amplitude

- Status: derived
- Object: stripped tree amplitude for `\gamma^* -> Q \bar{Q} g`
- Script: `dev/massiveA30/02_check_amplitude.wl`
- Comparison target: explicit heavy-mass appearance in the generated spinors and propagators

BlockedOn: None

ForcedStepUsed: None

WhyAcceptableTemporarily: Not applicable

WhatMustBeReplacedLater: Nothing

What failed before the current version:

- Replacing the quark mass only at the end was not enough.
- The amplitude still came out massless because the old builder also hardcoded
  the external on-shell conditions as `k_i^2 = 0`.

What finally worked:

- Use a dedicated heavy-quark field choice in the reconstruction helper.
- Insert the heavy mass both in the field-level mass substitution and in the
  external on-shell conditions before the amplitude is converted.

Important defense point:

- The heavy mass is introduced at amplitude-construction level, not only later
  through kinematic rewriting.
