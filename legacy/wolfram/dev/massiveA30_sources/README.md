## Scope

This directory contains bibliography-facing source files for the massive
three-parton `A30` antenna milestone.

The purpose of this layer is to encode the thesis/paper expressions in a form
that can be checked and discussed independently of the public package routing.
The public package now loads its runtime-owned massive `A30` definitions from
`src/`, just like the other supported antennae.  This directory is the moved
development/provenance archive for the massive track.

## Files

- `unintegrated.wl`
- `integrated.wl`
- `index.wl`
- `reconstruction.wl`

## Current status

- The unintegrated massive `A30` result is encoded from the thesis Chapter 5
  `QQ̄g` formula and exposed in both:
  - a thesis-facing paper convention;
  - a package-convention candidate chosen to preserve the same mass-dependent
    structure while reproducing the existing massless `A30` target in the
    `quarkMass -> 0` limit.
- `BuildAntenna[A, 3, 0, quarkMass -> mQ]` now returns the thesis-facing
  massive tree-level `A30` expression that was validated in the dedicated
  `dev/massiveA30/` reconstruction track.
- The integrated massive `A30` source is encoded from
  Gehrmann-De Ridder and Ritzmann in two layers:
  - a paper-facing exact result using the literature variable `r0` and the
    paper masters `I1^(m,0,m)` and `I2^(m,0,m)`;
  - a package-facing candidate obtained only through an explicit bridge layer.
- The integration-side reduction track now has an explicit package-owned
  `MX30` family scaffold with:
  - massive reverse-unitarity cut denominators;
  - massive invariant bridge rules;
  - topology-by-topology denominator candidates whose `mass -> 0` limit
    reproduces the checked-in massless `X30` family.
- The `MX30` LiteRed bases are now generated under `generated_bases/MX30/`,
  and the package-side reduction-readiness check now passes against the
  package-built massive `A30`, reducing it to a linear combination of
  identified LiteRed masters.
- The reconstruction track now reproduces the build-side chain through:
  - explicit heavy-quark tree diagrams;
  - package-derived tree amplitude;
  - package-derived self-interference;
  - package-derived antenna extraction.
- The thesis-facing match is now reproduced explicitly through the notebook-style
  brute-force bridge used in `dev/massiveA30/my_tryout_bruteforce.wl`:
  - the thesis denominator is `4 ((1 - epsilon) q2 + 2 mf^2)`;
  - the thesis `s123` convention is the pair-invariant sum
    `s123 = s12 + s13 + s23`;
  - the thesis-facing comparison is performed on the four-dimensional
    numerator (`Epsilon -> 0`);
  - the package self-interference is related to the thesis normalization by
    an explicit factor `4/3 * colourNorm`.

## Unfinished boundary

This track is intentionally left unfinished.

The correct claim is not "the massive `A30` case is fully integrated inside
the package." The correct claim is:

- the build-side massive `A30` reconstruction is complete enough to use and
  defend;
- the integrated literature result is encoded correctly and can be compared
  consistently to package conventions;
- the package `MX30` IBP route can reduce the package-built massive antenna to
  a linear combination of package masters;
- the final fully enclosed master-basis bridge is still missing.

The unresolved point is specific and technical:

- the paper integrated result is written in a paper master basis
  `I1^(m,0,m)`, `I2^(m,0,m)`;
- the package reduction lands in the LiteRed `MX30` basis, whose public
  representatives are the undotted and dotted `MX30Basis123` masters;
- the first master is well aligned with the phase-space master;
- the second paper master is numerator-type, while the package runtime master
  is dotted;
- the exact basis-change proof between those descriptions is not yet finished.

Because of that, the massive integration work currently stops at the following
honest level:

- genuine package-derived build-side reconstruction;
- genuine package-owned IBP reduction to the `MX30` master combination;
- correctly encoded bibliography target;
- explicit normalization/convention bridge;
- developer-side investigation material for the missing master relation.

What is not yet justified strongly enough to count as finished:

- claiming that the package already derives the final closed integrated
  massive `A30` result internally from its own master basis in the same
  self-contained way as the massless closed routes;
- claiming that the package-side master substitutions are already proven in a
  thesis-defense-ready way.

So if you use this directory now, the correct workflow is:

1. Use [`reconstruction.wl`](reconstruction.wl)
   for the genuine build-side massive antenna reconstruction.
2. Use [`integrated.wl`](integrated.wl)
   to inspect the encoded integrated literature result and the explicit bridge
   to package convention.
3. Use the scripts in
   [`dev/massiveA30/`](../../dev/massiveA30)
   to generate the `MX30` bases, reduce the package-built antenna, and inspect
   the remaining basis-matching problem.
4. Treat the final integrated closed result as bibliography/provenance rather
   than as a fully closed package-native runtime result.

## Usage

Load the bibliography bundle:

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/massiveA30_sources/index.wl"]; Print[Keys[MassiveA30BibliographyResults[]]]; Exit[]'
```

Run the dedicated validation suite:

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/massiveA30/run_all.wl"]; Exit[]'
```

Run the explicit `MX30` family check:

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/massiveA30/08_check_mx30_profile.wl"]; Exit[]'
```

Generate the `MX30` bases:

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/generate_mx30_bases.wl"]; Exit[]'
```

Run the first reduction-readiness check:

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/massiveA30/10_check_mx30_reduction_readiness.wl"]; Exit[]'
```

Run the integrated target bridge check:

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/massiveA30/12_check_integrated_runtime_bridge.wl"]; Exit[]'
```

Inspect the paper numerator-master bridge scaffold:

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/massiveA30/13_reduce_paper_numerator_master.wl"]; Exit[]'
```

Check the shifted paper-`I2` relation:

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/massiveA30/14_check_paper_i2_shift.wl"]; Exit[]'
```

Load the reconstruction helper:

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/massiveA30_sources/reconstruction.wl"]; Print[Keys[MassiveA30ReconstructionRecord[quarkMass -> mQ]]]; Exit[]'
```

## Provenance

### Unintegrated massive `A30`

Primary source: Chapter 5 of the thesis
`TM_Joana_Reis.pdf`, especially eqs. `(5.1.1)` to `(5.1.3)`.

### Integrated massive `A30`

Primary literature source:

- A. Gehrmann-De Ridder and M. Ritzmann, JHEP 07 (2009) 041,
  [arXiv:0904.3297](https://arxiv.org/abs/0904.3297)

## Boundary

This directory is not a finished runtime data artifact for a fully enclosed
massive integration route. It is a provenance and validation layer for an
unfinished research track whose current honest endpoint is:

- reconstructed unintegrated massive `A30`;
- reduced `MX30` master combination;
- encoded integrated bibliography result;
- explicit record of the unresolved master-basis bridge.
