# A22 loop-only master crosswalk

This note records the provenance status of the masters exposed by the A22
loop-only IBP diagnostic. It is intentionally stricter than the integrated
route's acceptance status: an integrated antenna can agree with its paper
target while an individual loop-topology substitution still lacks an
independent derivation.

## Kinematics and target

The A22 virtual channel is a massless two-parton form factor. With
\(k_1^2=(q-k_1)^2=0\), its only physical invariant is
\(q^2=2k_1\mathbin{\cdot}q\). A completed loop-level substitution library
must therefore express every exact-topology master in terms of \(q^2\),
\(\epsilon\), and the declared loop-measure/continuation convention, before
any antenna assembly occurs.

## Literature anchors already present in the repository

Appendix A.1 of Gehrmann-De Ridder, Gehrmann and Glover,
[*Infrared Structure of \(e^+e^-\to2\) jets at NNLO*](https://arxiv.org/abs/hep-ph/0403057),
gives the canonical virtual masters used by the A22 calculation. The
repository preserves their loop definitions and formulas in
`masterIntegrals/A22LO.wl`, `A3.wl`, `A4.wl`, and `A6.wl`:

| Canonical master | Analytic status |
|---|---|
| A22LO | closed Gamma-function form |
| A3 | closed Gamma-function form |
| A4 | closed Gamma-function form |
| A6 | published epsilon series; higher terms can be obtained from its hypergeometric representation |

The independent massless two-loop form-factor calculation of Gehrmann, Huber
and Maître gives the same class of masters in closed Gamma/hypergeometric
form and expansions to arbitrary required epsilon order. See
[*Two-Loop Quark and Gluon Form Factors in Dimensional Regularisation*](https://arxiv.org/abs/hep-ph/0507061).

## Exact topology labels

The loop-only reduction retains ten labels, defined by their active
denominators in `src/engines/integration_ibp.wl`. The labels are intentionally
more specific than the old A3/A4 buckets.

| Exact topology labels | Current canonical-value candidate | Provenance status |
|---|---|---|
| `A22A22LOQQMI` | A22LO | established: factorised two-bubble topology |
| `A22A3Basis15LikeMI`, `A22A3SunsetMI`, `A22A3Basis7LikeMI`, `A22A3Basis8LikeMI` | A3 | established by the recorded unit-Jacobian shifts |
| `A22A4NfLikeMI`, `A22A4Basis46LikeMI`, `A22A4Basis7LikeMI`, `A22A4Basis8LikeMI` | A4 | established by the recorded unit-Jacobian shifts and the four-propagator Appendix-A.1 definition |
| `A22A6Basis8LikeMI` | A6 | established: \(K=-l_1, L=l_2, p_1=k_1, p_2=q-k_1\) |

## First representative audit: leading component

The fresh leading catalogue run on 2026-08-01 found one or more representatives
for each of its seven labels, all with indices zero or one. Consequently the
leading channel contains neither dotted propagators nor irreducible numerator
slots. This is an important simplification: each label can be compared first
with an ordinary scalar integral, rather than a general indexed family.

Two mappings are already explicit at the integrand level.

- `A22A22LOQQMI` is represented by
  \[
    \frac{1}{l_1^2(l_1+q)^2\,l_2^2(l_2-q)^2},
  \]
  and factorises into two massless bubbles. This is the direct A22LO anchor.
- The three representatives of `A22A3Basis15LikeMI` are the same integral in
  different bases. For the first representative, set
  \(L_1=l_1-q\) and \(L_2=l_2-k_1\). Its denominators become
  \(L_1^2,L_2^2,(L_1+L_2+q)^2\), the single-scale massless two-loop sunset.
  The same shift-equivalence check is now required for the other A3 labels.

## Completed representative audit: all virtual colour components

The fresh subleading catalogue run on 2026-08-01 adds
`A22A3Basis8LikeMI`, `A22A4Basis8LikeMI`, and `A22A6Basis8LikeMI`.
Across the union of all leading, subleading, and \(N_f\) representatives,
every index is zero or one: there are no dotted propagators and no
irreducible numerator slots. The loop-level problem is therefore a
single-scale scalar-integral crosswalk.

All five A3 labels are integrand-level representations of the same sunset
class. In particular:

| Label | Shift to \(L_1^2L_2^2(L_1+L_2+q)^2\) |
|---|---|
| `A22A3Basis15LikeMI` | \(L_1=l_1-q,\ L_2=l_2-k_1\) |
| `A22A3SunsetMI` | direct, up to \(q\to-q\) |
| `A22A3Basis7LikeMI` | \(L_1=l_1-k_1,\ L_2=l_2-(q-k_1)\) |
| `A22A3Basis8LikeMI` | \(L_1=l_1-k_1,\ L_2=l_2\) |

The four-line labels expose a critical audit point. After shifts and the
exchange of the two massless external legs, `A22A4NfLikeMI`,
`A22A4Basis46LikeMI`, `A22A4Basis7LikeMI`, and `A22A4Basis8LikeMI` appear to
be the same scalar four-propagator vertex topology. For example,
`A22A4Basis7LikeMI` becomes
\[
  \frac{1}{K^2(K-q)^2L^2(K+L-k_1)^2}
\]
under \(K=l_1+q\), \(L=l_2-(q-k_1)\), which is the Nf-like representative
after a relabelling of loop variables.

The primary Appendix-A.1 definition of \(A_4\) itself has four propagators,
\[
  \frac{1}{k^2 l^2 (k-q)^2 (k-l-p_1)^2}.
\]
Thus the scalar topology matches the published \(A_4\) class after the
displayed shifts (and, where needed, \(L\to-L\)). Earlier repository notes
and the local `A4LoopDefinition` incorrectly recorded a six-propagator
integral; this has been corrected. The remaining issue is therefore not the
graph topology but the backend convention: a direct proof must still account
for the measure, timelike continuation, and any basis normalisation.

The old runtime table gave Basis7/Basis8 separately fitted series. Those
entries were obtained by solving against the assembled antenna target and are
not an independent value assignment for a scalar integral. They have been
removed from the substitution boundary: the labels remain diagnostic aliases,
and all four-line representatives now receive the single literature A4 value.

The historical stitched integrated route need not agree term by term after
this correction: its fitted bridge absorbed a pole-level residual. Any such
residual is therefore a validation signal for the upstream source or its
normalisation, not a reason to reinstate topology-dependent master values.

## Consequence for implementation

`A22TwoLoopTreeValueForExactTopology` is now an invariant-level substitution
boundary: the ten backend labels map to the four published single-scale
masters. The historical stitched route remains a separate regression
comparison because it used the removed fitted bridge.
