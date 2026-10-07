# Repository restructure verification — 2026-10-07

The current workflow moved from `src/next/` to `src/antcalc/`; the retained
Wolfram package and its assets moved together under `legacy/wolfram/`.
Runcards and result locations were preserved. This record covers the layout
change on the local installed toolchain, not a new package-wide qualification.

## Real runcard operations

Ten A30 cases were run before and after the move: both build methods, both
integration methods, all four combined method pairs, manual Kira input, and
reduction-only Kira integration. All exit statuses were zero, with no missing
or unevaluated outputs. Output fingerprints match after removing whitespace.
The final reusable operation test additionally removes expected outputs before
each case, to prevent stale results from satisfying a check, and exercises the
Python module entry point from another working directory.

- [Before-move fingerprints](runcards-before.json)
- [After-move fingerprints](runcards-after.json)
- [Final operation-matrix report](runcards-final.json)

## Default card and physics references

The original `runcards/runcard.json` was run unchanged after the move. Its A40
build matches the saved pre-move input. Both leading and subleading integrated
components match the thesis Appendix A references through the available
finite term, with scale `(q2/mu2)^(-2*ep)`.

- [Default A40 reference checks](a40-default-summary.json)
- [A30, B40 and C40 Kira comparisons](kira-summary.md)

## Layout and legacy checks

The direct legacy Wolfram loader was tested in a fresh kernel: package version,
normalised package-root location, runtime-master artifact, X30 basis directory,
and public build/integration definitions were all present. All moved tracked
files remain present and visible to Git. Legacy scientific assets outside
Markdown documentation were verified byte-for-byte against the original Git
revision. Current Python syntax, documented JSON cards, and repository-local
Markdown links passed checks; one pre-existing external link remains in the
historical README archive.

Original result files were restored after the checks. Temporary runcards were
removed. Logs remain in the ignored local test-output directories.
