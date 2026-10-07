# Installation, loading, and verification

[Manual index](index.md) · [Route status](route-status.md) · [Documentation home](../README.md)

## Requirements

For AntCalc 0.3.5's Python runcard workflow, including FORM, Kira, Fermat, and Python
dependencies, follow the [Kira workflow setup](kira-workflow.md#environment).
The installation and verification steps below describe the Wolfram package.

Supported workflows need a Wolfram Language kernel and these packages:

- FeynCalc;
- the FeynArts and FeynHelpers components used through FeynCalc;
- LiteRed2 for IBP-backed integration routes.

Some routes use Package-X through FeynCalc/FeynHelpers. Keep `bases/`,
`generated_bases/`, and `masterIntegrals/master_values_runtime.wl` when you
copy or clone the package. AntCalc reads these runtime files at use time; it
does not rebuild their derivations during startup.

The package has been exercised on macOS Apple Silicon and Windows Intel
systems. This is evidence of tested environments, not a cross-platform runtime
or memory guarantee.

## Current beta environment

The current beta release is exercised with this symbolic-backend baseline:

```text
FeynCalc 10.2.1 · FeynArts 3.12 (27 Mar 2025) ·
FeynHelpers 2.0.0 · FeynCalcLegacy 1.0.0
LiteRed2 2.025 β
```

`AntennaPipelineConventionReport[]` records this baseline. The startup banner
reports the versions in the current kernel. It does not validate other version
combinations.

## Install the paclet

After cloning the complete repository, install AntCalc once:

```wl
repoRoot = "/path/to/antenna_pipeline";
archive = CreatePacletArchive[repoRoot, $TemporaryDirectory];
PacletInstall[archive];
```

To reinstall a changed build with the same paclet version, use:

```wl
PacletInstall[archive, ForceVersionInstall -> True];
PacletDataRebuild[];
```

Restart the kernel after installation, then load the package:

```wl
<< AntCalc`
```

If the kernel was already running when you installed the paclet, run
`PacletDataRebuild[]` and restart the kernel.

## Develop from a checkout

While editing source files, load the checkout instead of the installed paclet:

```wl
repoRoot = "/path/to/antenna_pipeline";
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]]
```

Use `<< AntCalc`` to test the packaged copy. Rebuild and reinstall it after
changes. Start a new kernel so that old definitions cannot remain loaded.

## Verify an installation

The supported release acceptance command is:

```sh
cd /path/to/antenna_pipeline
bash dev/run_release_verification.sh
```

This command loads the checkout in fresh kernels. Its release-acceptance slice
covers the stable massless surface and the beta massive-`A30` public MX30
closure. The expensive forced-MX30 IBP regression
is deliberately separate from this release gate. It tests public build,
integration, record, and driver calls. Results are `Validated`, `Unvalidated`, `Failed`, or
`InconclusiveTimeout`; only `Validated` returns a successful exit status.
Each JSON record states the evidence tier and scope. The command needs the
configured `WolframKernel`; run time depends on the local backend.

The physics-validation harness is developer-facing:

```sh
cd /path/to/antenna_pipeline
bash dev/run_physics_validation.sh
```

It reports `Pass`, `Fail`, `KnownIssue`, `RouteEvaluationFailed`, or
`NotAvailableYet`. It does not replace the release-acceptance command.

## Troubleshooting

- A load failure in `src/core/setup.wl` usually indicates a missing or
  incompatible FeynCalc, FeynArts, or FeynHelpers installation.
- An IBP failure can indicate missing basis directories or runtime-master
  artifacts. For beta massive `A30`, retain the route diagnostics
  and master-basis report when reporting an issue.
- Bulk helpers currently reject nonzero `quarkMass`, lowercase `maxOrder`, and
  unsupported models such as `SUSY` and `HiggsEFT`.
- If derivation-side master-integral files change, refresh and validate the
  runtime-master artifact before attributing an integrated-route mismatch to
  the public runtime.
