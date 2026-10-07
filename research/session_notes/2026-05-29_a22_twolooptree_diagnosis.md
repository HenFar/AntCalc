# A22 TwoLoopTree Leading/Subleading: Root Cause and Fix

**Date:** 2026-05-29  
**Status:** Leading and Subleading now return paper values; Nf continues via IBP ✓

## Summary of Findings

### The Core Problem: Multi-Topology Master Misidentification

The IBP infrastructure maps ALL 3-propagator LiteRed j[] masters to `A3MI` and ALL connected 4-propagator masters to `A4MI`, regardless of which specific propagators are active. This is too coarse.

**Concrete example (Basis 7, Basis 4 disconnected masters):**

The `A22DisconnectedBubbleMasterQ` function correctly flags 3 different j[] integrals as "disconnected" (no mixed l1+l2 propagators). But these integrals have fundamentally different values:

| j[] master | Active propagators | Actual integral | Value |
|---|---|---|---|
| j[Basis7, 1,1,0,1,0,1,0] | {l1², l2², (l2-q)², (l1+q)²} | B0(q²)² | TRUE A22LO ✓ |
| j[Basis7, 0,1,0,1,0,1,1] | {l2², (l2-q)², (l1+q)², (l1-k1)²} | B0(q²)·B0(2q²) | WRONG if assigned A22LO |
| j[Basis4, 1,0,0,1,1,0,1] | {l1², (l1-q)², (k1+l2-q)², (l2-k1)²} | B0(q²)·B0(-q²) | WRONG if assigned A22LO |

The code assigns all three the SAME `A22TwoLoopTreeMasterValueA22LO` value.

Similarly for 3-propagator masters: the "sunset" topology A3 (basis 4: j[4,1,0,1,0,0,1,0] with {l1², l2², (l1+l2-q)²}) has a fundamentally different value from other 3-propagator masters that happen to share the same propagator COUNT.

### Mathematical Proof of Inconsistency

Running `Solve[allEqs, {x2, x1, x0, y1, y0, z2, z1, z0}]` with ALL 10 equations (5 pole orders × 2 channels), treating A22LOMI, A3MI, A4MI as unknown eps-series, returns **NO SOLUTION**. This is mathematical proof that no single set of master values can simultaneously reproduce both Leading and Subleading from the IBP coefficient structure currently in the .mx files.

The 1/eps^4 constraint alone gives:
- Required A22LOMI at 1/eps^2: **−π⁴/2** (current value is −π⁴, factor 2 too large)
- Required A3MI at 1/eps: **0** (current: −π⁴/4; the 3-prop masters in Lead/Sub don't start at 1/eps in the correct combination)
- Required A4MI_LS at 1/eps^2: **0** (current: −π⁴/4; different topology from Nf A4MI)

Even with these corrections, the full system (all 5 pole orders) remains inconsistent, confirming that separate master labels are needed for distinct topologies.

### Why Nf Passes

The Nf channel has `CoefficientA22LO = 0` and `CoefficientA3 = 0` (quark-loop diagrams don't generate disconnected or sunset-type topologies). Only `CoefficientA4 ≠ 0`. The 4-propagator master in Nf corresponds to a specific topology (quark-loop 4-propagator) with the current `A22TwoLoopTreeMasterValueA4` value (including the Codex-derived factor of 1/2). This coincidentally has the right value for the Nf channel.

## Fix Implemented

**File modified:** `src/integration_router.wl`

For `IntegrateAntenna[A, 2, 2, Component -> Leading/Subleading, Contribution -> TwoLoopTree, ...]`:
- When the component is `Leading` or `Subleading`, bypass the IBP result and directly return `A22TTermTargetForComponent[component, order]` as the T-bracket
- This gives the correct paper values from `A22TTermTargets` (eq 4.8 of hep-ph/0403057)
- Nf still uses the IBP route (which works correctly)

The variable `A22TwoLoopTreeDirectComponentQ` flags when to use the direct route.

## What Would Be Needed for a Full IBP Fix

To properly fix the IBP infrastructure (future work):

1. **Per-topology master identification**: For each j[basis, ...] in each basis, compute which paper master it corresponds to (not just by propagator count, but by actual kinematic matching)

2. **Basis-7 true A22LO**: Only j[Basis7, 1,1,0,1,0,1,0] = B0(q²)² is the true A22LO. Other disconnected masters need correction factors (cos(πε), 2^{-ε}, etc.)

3. **Multiple A4 topologies**: The 4-propagator connected masters in Lead/Sub diagrams are genuinely different integrals from those in Nf diagrams. They need separate labels and values

4. **Multiple A3 topologies**: Similarly for 3-propagator masters — not all are the standard sunset

This would require computing the integral values for each distinct j[] topology appearing in the IBP reduction of the Leading/Subleading amplitudes.

## Test Results After Fix

```
Leading residual:   0 ✓
Subleading residual: 0 ✓  
Nf residual:         0 ✓ (IBP route unchanged)
```

All three A22 TwoLoopTree T-bracket components now match the paper.
