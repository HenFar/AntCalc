# Stage 10: MX30 Reduction Readiness

- Status: derived
- Object: first successful reduction of the package-built massive `A30`
  integrand to a linear combination of `MX30` masters
- Code areas:
  - `src/integration_ibp.wl`
  - `dev/massiveA30/10_check_mx30_reduction_readiness.wl`

## What was required

Generating the bases was not enough. The package-side preparation had to be
made genuinely `MX30`-aware:

- the profile now carries the actual heavy-mass symbol through merged options;
- the prep step rewrites the result into the same `{m2, q2, d}` parameter
  language used by the generated bases;
- numerator factors like `s12`, `s13`, and `s23` are expanded into scalar
  products when they appear as positive-power numerators, while denominator
  factors stay in the shifted basis form.

## Result

The readiness script now passes:

- basis files load successfully;
- the package-built massive `A30` is reduced with `UnmatchedCount = 0`;
- the reduced answer is a linear combination of the first `MX30` masters.

Current reduced master symbols seen in the first working reduction:

- `j[MX30Basis123, 1, 1, 1, 0, 0]`
- `j[MX30Basis123, 2, 1, 1, 0, 0]`

## Developer command

```sh
bash masterIntegrals/run_kernel.sh -run 'Get["dev/massiveA30/10_check_mx30_reduction_readiness.wl"]; Exit[]'
```

## Honest boundary

This confirms the reduction milestone.

It does **not** yet mean:

- the public integrated massive route is activated;
- the resulting masters are mapped to paper names;
- closed-form master substitutions are known.

What we do have now is the exact fallback you said was acceptable:
the massive integrated `A30` can be reduced to a clean linear combination of
identified masters.
