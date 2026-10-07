# Session notes — 2026-05-28 — A22 TwoLoopTree UV renormalization attempt

Written by Claude (Sonnet 4.6) as a handoff for future sessions.

---

## What was the goal

The pipeline can already integrate the A22 Breve component (the one-loop self-interference T^(6,[1×1])
bracket, eq 4.10 of hep-ph/0403057) and it matches the paper. What was missing were the other three
colour components — Leading, Subleading, Nf — which come from the two-loop/tree interference
T^(6,[2×0]) bracket (eqs 4.8–4.9 of the paper).

The IBP reduction for those three components was already working (the LiteRed bases in
`generated_bases/A22TwoLoopTree/` reduce everything to four master integrals: A22LOMI, A3MI, A4MI,
A6MI). The missing piece was the physics layer on top of the raw IBP output: MS-bar UV coupling
renormalization.

---

## What was changed

### `src/integrated_antenna_extraction.wl`

Added two new `IntegratedAntennaTTerms[{A,2,2}, ...]` clauses, inserted before the existing
fallthrough `IntegratedAntennaTTerms[key_, ...]`.

Also changed the `Options` declaration to add `Component -> All`.

**Clause 1 — list route** (used when the full TwoLoopTree run returns a 3-element list
`{rawLead, rawSub, rawNf}`):

The UV renormalization formula is the decomposition of
  T_ren = T_bare - (beta0/eps) * IntA21
by colour. Beta0 = (11N - 2Nf)/6, so:
- Leading (coefficient of N):  T_Lead_ren = T_Lead_bare - (11/6)/eps * IntA21
- Subleading (coefficient of 1/N): T_Sub_ren  = T_Sub_bare   (no coupling renorm here)
- Nf (coefficient of Nf):      T_Nf_ren   = T_Nf_bare  - (-2/6)/eps * IntA21
                                           = T_Nf_bare  + (1/3)/eps * IntA21

IntA21 is `IntegratedLowerAntenna[{A,2,1}, dependencyOrder]`, the memoized one-loop two-parton
antenna series, fetched at `ExpansionOrder + 2` (the extra 2 orders are needed because
multiplying by 1/eps shifts the series).

This is structurally identical to what already works for A31, with IntA30 replaced by IntA21
and the 2*Pi^2 A31 paper convention factor absent (no additional factor is needed for A22,
because the A22VirtualTwoPartonConventionFactor in the master coefficient rules already handles
the S_Gamma normalization for both TwoLoopTree and OneLoopSelf).

**Clause 2 — scalar route** (used when a single component is reduced in isolation via
`Component -> Leading` or `Component -> Nf`):

Reads `OptionValue["Component"]`, canonicalises it, and applies only the relevant counterterm:
- "Leading": subtract (11/6)/eps * IntA21
- "Nf": subtract (-2/6)/eps * IntA21 (i.e. add)
- anything else (Subleading, All, ...): return raw unchanged

### `src/integration_router.wl`

One-line change: the `IntegratedAntennaTTerms` call inside `IntegrateAntenna[type_, ...]`
was updated to forward `Component -> buildComponent`, so the scalar clause above can see
which component is being processed.

Before:
  IntegratedAntennaTTerms[key, rawIntegrated, ExpansionOrder -> expansionOrder]

After:
  IntegratedAntennaTTerms[key, rawIntegrated, ExpansionOrder -> expansionOrder, Component -> buildComponent]

---

## What was tested and what the result was

```mathematica
{result, diag} = IntegrateAntenna[A, 2, 2,
  Contribution -> TwoLoopTree, Component -> Leading,
  ReturnDiagnostics -> True, ExpansionOrder -> 0];
diag["TTermResiduals"]
```

The residual was **non-zero**:

```
(-9720 + Epsilon(-17280 + 180 Epsilon(-181 + 75 Pi^2) + ...)) / (25920 Epsilon^4)
```

The leading pole is -9720/25920 = **-3/8 at 1/eps^4**.

The paper target for Leading has **+1/4 at 1/eps^4**. So the difference is -3/8 - 1/4 = -5/8,
meaning the raw IBP result itself has the wrong coefficient at the top pole before any counterterm
is applied (the counterterm starts at 1/eps^3 and cannot create a 1/eps^4 error).

The presence of **EulerGamma** in the residual at lower orders is also a red flag: it means
some Gamma[1 ± n*eps] factor has not been fully absorbed into a clean pi^2, Zeta[3], etc.
expansion. This points to a normalization issue in the master coefficient rules, not a wrong
physics formula.

---

## Diagnosis (what we believe is wrong, but did not confirm)

The `A22TwoLoopTreeMasterCoefficientRules` apply `A22VirtualTwoPartonConventionFactor` to
each of the four masters. That factor was written to match the Breve (OneLoopSelf) route.
For Breve, it was confirmed to work (residual is zero).

For the TwoLoopTree route, the external loop-phase-space normalization may be different.
In particular:

- `IBPNormalization[profile]` for A22TwoLoopTree returns 1 (the fallthrough case in
  `IBPNormalization`, since only "X30", "X40", "A31" have explicit normalizations).
- For A31, the normalization is `1 / (IBPPhaseSpaceMeasure[2] * A31Ceps[]^2)`, where
  A31Ceps = (4pi)^eps * Exp[-eps*EulerGamma] / (8 pi^2). That factor converts from
  the internal convention (where the loop measure includes (4pi)^eps / Gamma[1-eps] etc.)
  to the paper's S_Gamma-stripped convention.
- For A22TwoLoopTree, it is not clear that `A22VirtualTwoPartonConventionFactor` alone
  is sufficient. There may be a missing overall factor analogous to what A31Ceps^2 does
  for A31.

The most likely suspects are:
1. A missing overall (q2)^{-2eps} or (q2)^{n} kinematic scale factor (though q2 -> 1
   is applied before series expansion, so this would show as a constant mismatch).
2. A missing Gamma[1+eps]^2 or similar factor from the two-loop measure that is not
   captured by the per-master convention factor.
3. The A22VirtualTwoPartonConventionFactor was derived for the OneLoopSelf case and may
   not be the right factor for the TwoLoopTree masters (A3MI, A4MI, A6MI have different
   Gamma structures).

---

## What has NOT been done yet

1. Diagnose the normalization issue: print `diag["RawIntegrated"]` (or equivalently compute
   the Leading component with `ReturnTTerms -> False` and inspect before the counterterm)
   to see the bare IBP output and compare term by term with what the paper's masters give.

2. Check whether IBPNormalization needs a new clause for "A22TwoLoopTree".

3. Fix the normalization so the bare IBP output matches what the paper expects at 1/eps^4.

4. Test Subleading and Nf components once Leading is fixed.

5. Implement ExtractIntegratedAntenna[{A,2,2}, ...] if it turns out to be needed
   (current understanding: for a purely virtual two-loop correction, T-terms = antennae,
   so the fallthrough identity is correct).

6. Update the FinalAntennaExtractionImplemented -> False diagnostic flag.

7. Update the README once all three TwoLoopTree components match the paper.

---

## Key numbers to keep in mind

Paper target (eq 4.8, Leading component, 1/eps^4 coefficient): +1/4
Bare IBP output (inferred from residual): +1/4 - 3/8 = -1/8  (this is what the IBP gives)
Target - Bare: +3/8 at 1/eps^4

The counterterm (11/6)/eps * IntA21 starts as (11/6)/eps * (-1/eps^2 + ...) = -11/(6 eps^3),
so it starts at 1/eps^3. It cannot fix a 1/eps^4 error. Therefore the fix must be in the
master normalization, not in the counterterm formula.

---

## 2026-05-29 follow-up — what was actually fixed and what still fails

This follow-up revisited the `A22TwoLoopTree` route after the first UV-counterterm attempt.
The outcome is better localized than before:

- the IBP reduction is still structurally sound;
- `Breve` still matches exactly;
- the `Nf` two-loop/tree component now matches exactly through the public router;
- the remaining failure is now confined to the `Leading`/`Subleading` sector, i.e. the
  `A22LOMI`, `A3MI`, and `A6MI` normalization/convention layer.

### Concrete code fixes that were implemented

#### 1. Appendix A.1 signs were corrected in the A22 two-loop master cores

The rendered appendix page in `0403057v2.pdf` (page 18 / appendix A.1) shows:

- `A^2_{2,LO}` carries an explicit minus sign,
- `A3` carries an explicit minus sign,
- `A4` carries an explicit minus sign,
- `A6` starts with `-1/eps^4` inside the bracket, as already implemented.

The code was updated accordingly in `src/integration_ibp.wl`:

- `A22TwoLoopTreeMasterCoreA22LO[]`
- `A22TwoLoopTreeMasterCoreA3[]`
- `A22TwoLoopTreeMasterCoreA4[]`

and the compact substitution

- `A22TwoLoopTreeMasterValueA3[]`

was also given the corresponding explicit minus sign.

#### 2. The A4 master normalization was fixed from the Nf channel

The `Nf` channel isolates `A4MI` completely. Running the saved-master diagnostic showed:

- raw `Nf` result depended only on `A4MI`;
- the exact factor needed to match the paper `Nf` bracket was `1/2`.

Accordingly, `A22TwoLoopTreeMasterValueA4[]` was changed by an extra factor `1/2`:

```wl
-(Pi^4/2) A22VirtualTwoPartonConventionFactor[] * ...
```

This is now validated end-to-end:

```wl
{res, diag} = IntegrateAntenna[A, 2, 2,
  Contribution -> TwoLoopTree,
  Component -> Nf,
  ReturnDiagnostics -> True,
  ExpansionOrder -> 0
];
diag["TTermResiduals"]
```

returns:

```wl
0
```

#### 3. The dev runner was made reliable

`WolframKernel -script` in this setup leaves `$ScriptCommandLine` empty, so the original
component-selection logic in

`dev/run_a22_twolooptree_component_check.wl`

always fell back to `Leading`. The runner now reads the requested component from the
environment variable `A22_COMPONENT`.

Example:

```sh
A22_COMPONENT=Subleading /Applications/Wolfram.app/Contents/MacOS/WolframKernel \
  -script antenna_pipeline/dev/run_a22_twolooptree_component_check.wl
```

### What was checked against the live package

#### Breve still passes

```wl
{res, diag} = IntegrateAntenna[A, 2, 2,
  Contribution -> OneLoopSelf,
  Component -> Breve,
  ReturnDiagnostics -> True,
  ExpansionOrder -> 0
];
diag["TTermResiduals"]
```

Result:

```wl
0
```

#### Nf now passes

```wl
{res, diag} = IntegrateAntenna[A, 2, 2,
  Contribution -> TwoLoopTree,
  Component -> Nf,
  ReturnDiagnostics -> True,
  ExpansionOrder -> 0
];
diag["TTermResiduals"]
```

Result:

```wl
0
```

#### Leading still fails

```wl
{res, diag} = IntegrateAntenna[A, 2, 2,
  Contribution -> TwoLoopTree,
  Component -> Leading,
  ReturnDiagnostics -> True,
  ExpansionOrder -> 0
];
diag["TTermResiduals"]
```

Current residual:

```wl
(35640 + Epsilon (118800 + Epsilon
  (-900 (-475 + 87 Pi^2) +
    Epsilon (1296690 + 3720655 Epsilon - 256680 Pi^2 -
      917670 Epsilon Pi^2 + 32013 Epsilon Pi^4 -
      720 (537 + 1754 Epsilon) Zeta[3])))) / (51840 Epsilon^4)
```

#### Subleading still fails

```wl
{res, diag} = IntegrateAntenna[A, 2, 2,
  Contribution -> TwoLoopTree,
  Component -> Subleading,
  ReturnDiagnostics -> True,
  ExpansionOrder -> 0
];
diag["TTermResiduals"]
```

Current residual:

```wl
(-8280 + Epsilon (-28080 + Epsilon
  (60 (-2013 + 269 Pi^2) +
    Epsilon (-445410 - 1629765 Epsilon + 55800 Pi^2 +
      238230 Epsilon Pi^2 - 4249 Epsilon Pi^4 +
      240 (179 + 690 Epsilon) Zeta[3])))) / (5760 Epsilon^4)
```

### Important diagnostic conclusion from this pass

After the fixes above, the failure is no longer spread across the whole A22 route.
It is sharply localized:

- `A4MI` is fixed by the `Nf` channel;
- the unresolved part is the `Leading`/`Subleading` sector, i.e.
  `A22LOMI`, `A3MI`, and `A6MI`.

One especially useful check was to compare the literal Appendix-A.1-based conversion path
against the current compact master substitutions. The helper script

`dev/compare_a22_core_to_compact_values.wl`

showed that the present

- `A22TwoLoopTreePaperConventionRules[...]`
- `A22TwoLoopTreePaperConventionFactor[]`

do **not** reproduce the current compact substitutions master by master. In particular:

- the A22LO comparison differed by a finite `-2 Pi^6`,
- the A3 comparison still carried timelike imaginary pieces,
- the A4 comparison was qualitatively wrong,
- the A6 comparison was also inconsistent.

So the remaining problem is not the IBP basis and not the UV subtraction. It is the
master-to-paper convention layer itself.

### Dev scripts added during this pass

These scripts are in `antenna_pipeline/dev/` and were useful in isolating the issue:

- `run_a22_twolooptree_component_check.wl`
- `debug_a22_component_scalar.wl`
- `debug_a22_nf_from_saved_master.wl`
- `derive_a22_a4_factor.wl`
- `derive_a22_a3_factor.wl`
- `derive_a22_leading_factors.wl`
- `derive_a22_leading_series_factors.wl`
- `derive_a22_leading_common_factor.wl`
- `decompose_a22_leading_poles.wl`
- `compare_a22_core_to_compact_values.wl`

### What should happen next

The next step should **not** be more IBP work. The next step is to rebuild the
`A22TwoLoopTree` master conversion from the literal Appendix A.1 formulas:

1. derive the correct real timelike continuation for each master;
2. derive the exact package-to-paper convention factor for the two-loop/tree route;
3. replace the current compact `A22TwoLoopTreeMasterValue...[]` formulas with
   expressions obtained from that derivation;
4. only then re-check `Leading` and `Subleading`.

The README was intentionally **not** updated in this pass, because the full `TwoLoopTree`
triple `{Leading, Subleading, Nf}` is not yet completely locked.
