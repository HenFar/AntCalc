# Stage 06: Reduction Plan

- Status: planned
- Object: reduction-only milestone for the integrated massive `A30`
- Scope: stop at a verified linear combination of masters if closed master
  values are not yet available

## Flag legend

- `[SAME-AS-MASSLESS]`
  This step follows the same logic already used in the massless `A30` route.
- `[MASSIVE-NEW]`
  This is a genuine massive-specific ingredient that the massless route did not
  have to solve.
- `[HARD-GATE]`
  We should not pretend this step is done without a concrete artifact or check.
- `[SAFE-TO-DEFER]`
  This can wait until after the reduction itself is working.
- `[DO-NOT-FAKE]`
  If this is missing, we must stop honestly instead of silently inventing a
  convention or basis.
- `[OUTPUT]`
  The artifact we should aim to leave behind at that stage.

## Goal

Reach the point where the massive integrated `A30` can be produced as

- either a fully substituted integrated expression, if the masters are known;
- or a clean linear combination of identified master integrals, if they are
  not yet known.

The reduction itself is already a valid milestone.

## Thought process

The overall design should stay as close as possible to the massless `A30`
integration route:

- `[SAME-AS-MASSLESS]` build an integrable object;
- `[SAME-AS-MASSLESS]` translate it into the IBP/LiteRed convention;
- `[SAME-AS-MASSLESS]` match terms to a basis;
- `[SAME-AS-MASSLESS]` reduce through LiteRed;
- `[MASSIVE-NEW]` inspect the surviving masters before deciding whether master
  substitution is available.

So the philosophy does not change. The main difference is where certainty
starts:

- massless `A30`: the family `X30`, its bases, and its master `R3` are already
  known;
- massive `A30`: the family, basis, and master set are part of what we still
  need to establish.

## Planned stages

### 06.1 Integrable source object

- `[SAME-AS-MASSLESS]` Decide what the integration route should consume from
  `BuildAntenna[A, 3, 0, quarkMass -> mQ]`.
- `[HARD-GATE]` Freeze the exact object before any IBP work starts.
- `[OUTPUT]` one reproducible Wolfram expression representing the massive
  integrand to be reduced.

Notes:

- For the massless route, the package already knows how to hand the tree-level
  antenna to the IBP backend.
- For the massive route, we should first decide whether the integrand is built
  from the thesis-facing public expression or from a more native pre-bridge
  internal object.
- My preference is to reduce a native integrable object and keep the
  thesis-facing convention as a later presentation layer.

### 06.2 Massive IBP kinematics

- `[MASSIVE-NEW]` Encode the external kinematics for a massive
  `Q Qbar g` final state.
- `[HARD-GATE]` This must be explicit in the profile, not inferred loosely.
- `[OUTPUT]` one massive phase-space/kinematics rule set for the future IBP
  profile.

Essential relations:

- `p1^2 = mQ^2`
- `p2^2 = mQ^2`
- `p3^2 = 0`
- `q^2 = 2 mQ^2 + s12 + s13 + s23`

Difference from the massless route:

- The massless `X30` profile uses only null external legs.
- The massive route must carry the heavy-mass shell conditions throughout the
  profile and basis algebra.

### 06.3 New IBP profile and basis family

- `[MASSIVE-NEW]` Create a new family instead of forcing the problem into
  `X30`.
- `[DO-NOT-FAKE]` We should not reuse `X30` unless the denominators and
  kinematics really match, which they do not.
- `[OUTPUT]` one new profile, conceptually something like `MX30` or
  `A30Massive`.

What the profile should eventually own:

- basis family name
- basis root on disk
- external momenta and loop/phase-space variables
- invariant rules
- phase-space cut structure
- expansion order policy

### 06.4 Basis generation

- `[MASSIVE-NEW]` Generate LiteRed bases for the new massive family.
- `[HARD-GATE]` No reduction milestone should claim success until the basis can
  actually be loaded and matched.
- `[OUTPUT]` a dedicated on-disk basis folder, parallel in spirit to
  `bases/X30`.

What matters here:

- the denominators must reflect the true massive cut structure;
- the basis must be generated from the same kinematics we plan to reduce with;
- the resulting files should be reproducible from a script, not only from an
  interactive notebook.

### 06.5 Term preparation and basis matching

- `[SAME-AS-MASSLESS]` We will need a family-specific analogue of the current
  `PrepareIBPTerm` path.
- `[MASSIVE-NEW]` The invariant rewrite and denominator absorption will almost
  certainly differ from `X30`.
- `[OUTPUT]` one adapter that maps the massive integrand terms into LiteRed
  basis language.

This is the stage where we should expect trial and error.

That is acceptable, but:

- `[DO-NOT-FAKE]` if a term does not match the basis, we record that mismatch
  explicitly rather than forcing it into a guessed denominator structure.

### 06.6 First successful reduction

- `[SAME-AS-MASSLESS]` Once terms match a basis, use LiteRed reduction as usual.
- `[HARD-GATE]` The first true milestone is not “integrated result,” but
  “reduced to a stable linear combination of masters.”
- `[OUTPUT]` one raw reduced master combination with backend diagnostics.

This is the point where we learn:

- which masters actually appear;
- whether the family choice was good;
- whether the result is compact enough to work with.

### 06.7 Master inspection and naming

- `[MASSIVE-NEW]` Identify and name the surviving masters from the reduction.
- `[SAFE-TO-DEFER]` closed-form substitution can wait until after the basis is
  stable.
- `[OUTPUT]` one clear master registry for the massive `A30` reduction output.

This is where we answer honestly:

- do we already know these masters from the literature?
- do we know only some of them?
- do we know none of them yet?

### 06.8 Public stopping policy

- `[HARD-GATE]` If master values are not available, the package should stop at
  the linear combination of masters rather than inventing substitutions.
- `[OUTPUT]` a public-facing reduction result that is still useful and honest.

This is the key policy decision:

- reduction success is enough to expose a meaningful result;
- master substitution is an extra layer, not a requirement for the reduction
  milestone to count.

## What is the same as your massless design

- The route still starts from a build-side object.
- The route still translates into a LiteRed/IBP convention.
- The route still matches terms to bases and reduces them.
- The route still separates reduction from master substitution.

## What is different from your massless design

- `[MASSIVE-NEW]` the external kinematics are not null;
- `[MASSIVE-NEW]` the phase-space cut structure is not the same as `X30`;
- `[MASSIVE-NEW]` the basis family is not already known;
- `[MASSIVE-NEW]` the master set is part of what we are trying to discover.

## Recommended immediate next step

- `[HARD-GATE]` do not begin by writing master substitutions.
- Start by defining the massive IBP profile and basis-generation target.
- The first real deliverable should be:
  `[OUTPUT]` “one massive `A30` term successfully matched to a new LiteRed
  basis and reduced.”

## Current boundary

- We already know the unintegrated massive `A30`.
- We do not yet know the massive integrated master basis in a package-owned
  verified form.
- That is not a problem.
- The reduction-only milestone is still meaningful and worth implementing.
