# AntCalc

`AntCalc` is the official package name of this Wolfram Language project.
The repository is still named `antenna_pipeline`, and the current canonical
loader file remains `AntennaPipeline.wl`, but the package should be referred to
in the README and in ordinary use as `AntCalc`, in the style of established
field-standard names such as `FeynCalc`, which also inspired the naming.

`AntCalc` is a Wolfram Language package for building and integrating QCD
antenna functions through a small public API. The release target of this repo
is now explicit:

```text
Load one package, call a small set of public functions, and reproduce the
massless A-type antenna story needed for the NNLO SMQCD R-ratio workflow.
```

This repo should be read as active research software under ongoing
development, not as a finished or release-ready general-purpose package.
Its current value is that it already exposes a real executable package core,
an honest supported-versus-experimental split, and a documented implementation
roadmap inside a live thesis project.

This repo is no longer presented as an open-ended “finish every branch”
research notebook. It is a package, `AntCalc`, with one defended massless
target, two callable experimental branches that are intentionally outside the
current release guarantee, and several clearly marked unfinished sections that
remain part of the active development process.

## Project Status

Status summary:

- this is an in-progress research package tied to an active thesis codebase
- it is suitable for inspection, testing, and academic evaluation
- it is not yet a polished general release or a frozen final public version
- supported routes are already usable, but the repository as a whole should be
  understood as under active development

Practical reading rule:

- the supported release matrix defines what is currently defended
- experimental branches and `dev/` workflows show ongoing work, not hidden
  promises of completeness
- unfinished checklist items are intentional status markers, not accidental
  omissions

## Recent Development Notes

- `2026-07-15`: the raw one-loop `A31` Ward identity now passes exactly after
  PaVe tensor reduction, completing all applicable supported massless A-family
  external-gluon checks
- `2026-07-14`: amplitude-level Ward checks now pass exactly for the massless
  `A30` gluon and both independent `A40` gluon replacements
- `2026-07-14`: a fresh uncached full NNLO `BuildRRatio` validation now passes
  exactly: all raw Laurent residuals through epsilon^0 vanish and the finite
  coefficient agrees with the encoded SMQCD target
- `2026-07-14`: the `A31` Appendix A.2 master phase/convention repair now
  reproduces the direct paper targets and removes EulerGamma from public series
- `2026-07-11`: the public integrated `A22` route now matches the exact
  `hep-ph/0403057` paper `T_{qq}^{(6)}` target component by component
- `2026-07-11`: `AntennaPhysicsValidationReport[A, 2, 2]` now passes exactly
- `2026-07-11`: `BuildAndIntegrateAntenna[A, 2, 2, ReturnDiagnostics -> True]`
  now completes successfully on the combined route
- `2026-07-10`: the raw `BuildRRatio[...]` validation route was added and the
  current NNLO observable-level failure was isolated and documented
- `2026-07-08`: the `A40` / `B40` / `C40` normalization route was aligned with
  the standard `A30` convention path
- `2026-07-01`: supported package-wide defaults and stored-result semantics
  were consolidated and revalidated
- `2026-06-30`: `BuildAntenna[...]` gained an explicit public/prototype branch
  selector for direct expression output
- `2026-06-29`: the public `A31` build-side route was repaired so UV
  counterterms are applied at the package-facing boundary

## How To Read This README

This README is meant to serve three readers at once:

- package users who want to know what is supported and how to run it
- thesis/supervision readers who need to understand the package contract and
  current status honestly
- contributors who want to inspect or extend the runtime

The guiding rule is:

- supported routes are documented as the intended public package contract
- experimental routes are documented as callable but outside the release
  guarantee
- known contract mismatches are called out explicitly rather than silently
  normalized as if they were correct public behavior
- the repository should be read as an honest development snapshot of a serious
  research-software project, not as a completed archival release

## Transparency Index

This section is the shortest “what is really here?” map for both users and
developers.

- supported public physics routes:
  the massless release matrix in `## Supported Release Matrix`
- callable but non-release branches:
  `## Experimental Branches`
- intended public physics contract versus current implementation reality:
  `## Current Contract Notes`
- public functions, options, objects, and reports:
  `## Public API`, `### Public Options Reference`, and `## Record And Object Appendix`
- stored-result and cache behavior:
  `### Stored Results And Transparent Reuse`
- route metadata, conventions, and environment inspection:
  `AntennaPipelineConventionReport[]`,
  `AntennaPipelineDimRegDeclaration[]`,
  `AntennaRouteProfileReport[...]`,
  `AntennaRouteEnvironmentReport[...]`,
  and `AntennaPipelineDefaults[]`
- contributor-facing implementation structure:
  `## Internal Architecture For Modifying Routes`

Strict transparency rule:

- if a function, option, object field, route family, or workflow switch is not
  described in the public API, option reference, experimental-branch notes, or
  implementation notes below, it should be treated as internal rather than as a
  hidden supported feature
- internal developer globals and internal helper symbols may exist in the code,
  but they are not part of the public contract unless they are documented here
- this README is intended to be complete enough that a physicist can determine
  what the package promises, what it merely exposes for inspection, and what it
  does not yet claim

## Active Implementation Plan

This repository is currently being advanced through a strict task-by-task
implementation checklist rather than through unrelated opportunistic edits. The
current execution order is:

1. convention and public-contract foundation
2. build-side semantics repair
3. defaults, cache, and validation
4. massive `A30`, validation expansion, and user-facing examples
5. longer-term exploratory extensions

The active task list is:

- Task 1: stabilize the convention metadata model (done)
- Task 2: add effective route/environment resolution reporting (done)
- Task 3: declare dimensional-regularization scheme status in code (done)
- Task 4: introduce an explicit public vs bare/prototype output boundary (done)
- Task 5: repair `A31` build-side normalization and renormalization semantics (`5a` complete; longer-term convention-regression coverage remains in Task 13)
- Task 6: clean up `PaXEvaluate` / `PaVe` convention handling (done)
- Task 7: add an explicit bare/prototype public option (done for direct `BuildAntenna[...]` expression output)
- Task 8: add a supported global default environment mechanism (done)
- Task 9: re-audit stored-result semantics after semantics repair (done)
- Task 10: physics validation and NNLO observable-repair track
- Task 10a: contain and document the raw `BuildRRatio[...]` failure (done)
- Task 10b: audit and repair `AssembleSMQCDRRatio[...]` against the
  thesis/paper formula and route-level conventions (done)
- Task 10c: make the public integrated `A22` route reproduce the exact
  `hep-ph/0403057` paper `T_{qq}^{(6)}` component set (done)
- Task 10d: encode exact package-facing `A40` / `B40` / `C40` pole targets
  (done)
- Task 10e: extend the validator to Catani-operator structure (not yet done)
- Task 10f: add massless tree-level Ward-identity checks (done)
- Task 10h: extend the Ward validator to the massless one-loop `A31` amplitude
  (done)
- Task 10g: add factorization-limit validation (not yet done)
- Task 11: complete the massive `A30` second-master derivation, together with explicit master-integral provenance, basis-bridge checks, and artifact-verification tests
- Task 12: create a user-facing `examples/` directory with runnable workflow
  files, add one canonical interactive quickstart notebook and thesis-facing
  end-to-end example, finish benchmarks, and expose a dependency/environment
  report plus backend-failure diagnostics for user installs
- Task 13: prototype longer-term extensions, including deferred `5b`
  convention-regression coverage, exploratory Slavnov-Taylor / BRST-aware
  validation, package-boundary cleanup, and broader repo-hygiene /
  pacletization work

Current execution status:

- done
  Task 1: stabilize the convention metadata model
  Task 2: add effective route/environment resolution reporting
  Task 3: declare dimensional-regularization scheme status in code
  Task 4: introduce an explicit public vs bare/prototype output boundary
  Task 5: repair `A31` build-side normalization and renormalization semantics (`5a` complete; broader regression coverage moved to longer-term work)
  Task 6: clean up `PaXEvaluate` / `PaVe` convention handling
  Task 7: add an explicit bare/prototype public option (direct `BuildAntenna[...]` expression output only)
  Task 8: add a supported global default environment mechanism
  Task 9: re-audit stored-result semantics after semantics repair
  Task 10a: contain and document the raw `BuildRRatio[...]` failure
  Task 10b: repair the observable-level NNLO convention assembly and verify a
  fresh raw `BuildRRatio[...]` pass
  Task 10c: reproduce the exact paper `A22` `T_{qq}^{(6)}` component set
  Task 10d: encode exact package-facing `A40` / `B40` / `C40` targets
  Task 10f: validate the A30 and A40 massless tree-level Ward identities
  Task 10h: validate the raw one-loop A31 Ward identity
- not yet done
  Tasks 10e, 10g, and 11-13

Task 10 urgency note:

- Task 10 is not a quick single-step finish anymore
- the full scope is medium-to-large because it now includes a real
  observable-level NNLO semantics audit, not only validator plumbing
- `10b` is complete: the observable adapter, A31 master conventions, and
  four-parton package-facing mappings now give a fresh raw NNLO closure with
  zero pole and finite residuals
- `10c` is now complete:
  the public integrated `A22` route reproduces the exact paper
  `T_{qq}^{(6)}` component targets and the previously broken combined
  diagnostics route now completes successfully
- `10d` is complete: exact package-facing `A40`, `B40`, and `C40` targets are
  encoded and participate in the successful full observable check
- `10f` is complete: the public amplitude-level checker proves the Ward
  replacement for `A30`/`k3` and independently for `A40`/`k3` and `A40`/`k4`,
  with exact zero residuals after physical-polarization transversality is
  imposed on the un-replaced gluon
- `10h` is complete: the raw massless one-loop `A31` amplitude is exposed
  separately from the tree-only `AntennaAmplitude[...]` accessor and its
  external `k3` replacement passes exactly. The validation layer maps the
  contracted raw amplitude to a common PaVe tensor basis; this diagnostic
  reduction does not alter the public route.
- `10e` and `10g` remain part of Task 10; they can now build on a verified
  observable-level and tree-level gauge-invariance baseline

Task 12 example-delivery note:

- create a tracked `examples/` directory separate from `dev/`; its files are
  user documentation, not research diagnostics
- include a minimal load-and-environment check, an `A30` build/integration
  workflow, cache and diagnostics inspection, validation usage, and one
  clearly marked longer-running `BuildRRatio[...]` example
- provide the same first workflow as a runnable Wolfram notebook so a new user
  can evaluate it cell by cell without translating the README into code

The checklist is intentionally dependency-driven. In particular, semantics
repair happens before cache re-audits, broader validation, or user-facing
polish that would otherwise document the wrong boundary.

## Completed Work Index

This is the short ledger of what the completed tasks have already changed in the
public package surface.

- Task 1:
  one canonical convention metadata model now feeds the code-level convention
  reports, so intended contract, current implementation reality, and prototype
  status are described from one source of truth
- Task 2:
  route-level environment reporting now exposes effective defaults and route
  metadata for build, integration, and one-shot calls
- Task 3:
  the dimensional-regularization declaration is now explicit in code and
  inspectable through `AntennaPipelineDimRegDeclaration[]`
- Task 4:
  build routes now carry an explicit public/prototype boundary internally rather
  than conflating the route-native payload with the intended public output
- Task 5a:
  the default `BuildAntenna[A, 3, 1, ...]` public branch now applies the
  repaired build-side presentation boundary, while the route-native branch is
  preserved for integration-facing work
- Task 5b:
  moved to longer-term work; the current public-facing `A31` fix is treated as
  the accepted sensible boundary for the present release, while nonzero
  integrated residual cleanup and deeper structural renormalization work remain
  future physics-side tasks
- Task 6:
  the integration convention bridge is now explicit and inspectable in backend
  diagnostics rather than depending on implicit backend normalization accidents
- Task 7:
  `BuildAntenna[..., BuildOutputBranch -> "Public"|"Prototype"]` is now a
  documented public selector for direct expression output, with its support
  boundary stated honestly
- Task 8:
  supported package-wide defaults now exist through
  `AntennaPipelineDefaults[]`, `SetAntennaPipelineDefaults[...]`, and
  `ResetAntennaPipelineDefaults[]`, with explicit precedence and inspectable
  effective per-head resolutions
- Task 9:
  stored-result identity now includes a route-semantic version barrier and
  driver-level nested-default fingerprints, so repaired public semantics do not
  silently collide with older cache entries; the one-shot `A22` route and the
  top-level `BuildRRatio[SMQCD, quarkMass -> 0]` driver have now also been
  revalidated through fresh and cached public-route checks

## Release Promise

The release-complete package surface is:

- massless tree-level `A20`, `A30`, `A40`, `tildeA40`, `B40`, and `C40`
- integrated `A21`
- integrated `A30`
- integrated `A31`, `tildeA31`, and `hatA31`
- integrated `A22`, `tildeA22`, `hatA22`, and `breveA22`
- the massless `SMQCD` high-level driver
  `BuildRRatio[SMQCD, quarkMass -> 0]`
- the massless SMQCD bulk convenience routes
  `BuildAllAntennae[SMQCD, maxOrder -> LO|NLO|NNLO]`
  and `BuildAndIntegrateAllAntennae[SMQCD, ...]`
- the record/inspection layer built around `ReturnRecord` and
  `IntermediateSteps`

These are the routes the package claims as supported for external use.

## Experimental Branches

Two branches remain public-callable, but they are not part of the release
guarantee:

- massive `A30`
- `D30`

They remain in the runtime because they are useful research tracks, but they
must be understood as experimental:

- they expose diagnostics and records honestly;
- they may return unfinished results or `$Failed`;
- they are documented separately from the supported massless package promise;
- they are not the package acceptance target.

### Massive A30

The current massive `A30` status is:

- `BuildAntenna[A, 3, 0, quarkMass -> mQ]` is legitimate and package-derived
- `BuildAntennaObject[A, 3, 0, quarkMass -> mQ]` is available as the
  integration-ready public wrapper for that massive build result
- the bibliography-facing integrated result is encoded and checked as
  provenance
- the package can reduce the massive integrand to the `MX30` master
  combination
- the fully internal closed master-substitution derivation is still not
  complete

Why the integrated massive branch remains experimental:

- the package runtime basis is not identical to the canonical literature basis
  used for the published integrated massive `A30` result
- the first runtime master is naturally identified with the bridged paper
  `I1^(m,0,m)` object, but the second runtime master is a dotted `LiteRed`
  basis master whereas the paper `I2^(m,0,m)` object is a numerator master
- the package therefore already has a real target-level bridge:
  it can reduce the massive integrand to the runtime `MX30` basis and match the
  final integrated literature target through a provisional second-master bridge
- what is still missing is the fully derived, defensible paper-to-runtime basis
  relation for that second master; until that is completed, the integrated
  massive branch is kept as an experimental runtime/provenance path rather than
  promoted to a release-guaranteed closed derivation

So the honest endpoint today is:

- correct unintegrated massive antenna
- explicit literature/provenance bridge for the integrated result
- package-owned reduction to masters
- no release-guaranteed closed integrated runtime result

### D30

The current `D30` status is:

- the effective source-model infrastructure exists under `src/`
- source amplitudes and source interferences are built by the runtime
- the default `BuildAntenna[D, 3, 0, ...]` call remains callable through the
  source-model route
- `AllowPrototypeTargets -> True` switches the build toward the prototype or
  paper-style branch instead of the default source-model route
- the public `BuildAntenna[D, 3, 0, ...]` route exposes that started work
  through diagnostics and run records
- the final symbolic extraction into a validated public `D30` antenna is still
  unfinished
- there is no public integration route

So `D30` is a runtime research branch, not a finished package feature.

## Supported Release Matrix

```text
Family / object                  build   integrate   release status
-------------------------------------------------------------------
A20                             yes     n/a         supported
A30                             yes     yes         supported
A40                             yes     yes         supported
tildeA40                        yes     yes         supported
B40                             yes     yes         supported
C40                             yes     yes         supported
A21                             yes     yes         supported
A31                             yes     yes         supported
tildeA31                        yes     yes         supported
hatA31                          yes     yes         supported
A22                             yes     yes         supported
tildeA22                        yes     yes         supported
hatA22                          yes     yes         supported
breveA22                        yes     yes         supported
BuildRRatio[SMQCD, m=0]         n/a     n/a         supported
BuildAllAntennae[SMQCD, ...]    yes     n/a         supported convenience
BuildAndIntegrateAllAntennae    yes     yes         supported convenience
massive A30                     yes     partial     experimental
D30                             partial no          experimental
```

## Current Contract Notes

The intended public contract of the package is:

- `BuildAntenna[...]` should expose package-facing antenna objects in the
  package normalization/renormalization convention
- `IntegrateAntenna[...]` and `BuildAndIntegrateAntenna[...]` should consume and
  return objects in that same public convention
- bare or pre-counterterm intermediate expressions are provenance-level objects,
  not the default public endpoint
- integrated `A22` should be read more narrowly than a generic “final antenna”:
  its supported public endpoint is the paper-facing two-parton
  `T_{qq}^{(6)}` object, component by component, in the convention tracked back
  to `hep-ph/0403057`

Not yet implemented or not yet repaired:

- the repaired `A31` integrated public route now matches its encoded paper
  target. Future work should extend validation depth rather than redefine this
  established package boundary
- object-facing and integration-facing prototype output is not yet a supported
  public route; `BuildAntennaObject[...]`, `ReturnAntennaObject -> True`, and
  `IntegrableForm -> True` remain pinned to the public branch intentionally
- the `A22` repair is still an active code track: the intended contract is the
  exact paper `T_{qq}^{(6)}` object, and that exact-target validation is now
  passing component by component on the public integrated route
- any future residual mismatch against that target should be treated as a live
  bug rather than as accepted package semantics

## Route Status Notes

- supported massless routes are the ones in the release matrix and in
  `dev/run_release_verification.sh`
- massive `A30` is callable and useful, but experimental
- `D30` is callable for diagnostics and source-route inspection, but
  experimental
- loop-route normalization and renormalization notes matter for interpreting the
  public contract, especially for `A21` and `A31`

## Prerequisites

The package is a Wolfram Language runtime that delegates substantial symbolic
work to the standard high-energy-physics toolchain used by the repo.

For the supported massless release workflow, you should assume the following
are available in the Wolfram environment used to load the package:

- Wolfram Kernel / `wolframscript`
- `FeynCalc`
- `FeynHelpers`
- `FeynArts`
- `LiteRed2`

The runtime checks the `FeynCalc` version it was validated against and currently
expects `FeynCalc 9.3.1`.

Dependency note:

- `FeynHelpers` and `FeynArts` are used through the `FeynCalc` environment
- `LiteRed2` is required by the IBP-backed integration routes
- once the AntCalc paclet is installed, package startup is only
  `<<AntCalc``
- `Get["AntennaPipeline.wl"]` remains the repository-development loader

Some supported integration routes also rely on checked-in repo-owned basis or
master-value artifacts already present in the repository:

- `bases/`
- `generated_bases/`
- `masterIntegrals/master_values_runtime.wl`

Additional integration and development workflows may require the following
tools as well:

- `LiteRed` for IBP basis loading or basis generation
- `Package-X`, used through `FeynCalc`/`FeynHelpers` for `PaVe` evaluation

These extra tools are part of the runtime architecture even when a particular
user session does not touch every backend.

## Environment Assumptions

The repository is designed to be loaded from a checked-out working tree, not as
an installed paclet. The normal expectation is:

- you have the full repository locally
- the bundled `bases/`, `generated_bases/`, and `masterIntegrals/` directories
  are present
- you load [AntennaPipeline.wl](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/AntennaPipeline.wl)
  from that checkout

The package does not require the full derivation tree to be recomputed on
startup. In particular, the runtime loads the checked-in
`masterIntegrals/master_values_runtime.wl` artifact rather than rebuilding the
master-integral provenance layer on each load.

## Tested Environments

The package has been tested in at least the following local environments:

- macOS on an Apple Silicon MacBook Pro M4
- Windows on an Intel desktop PC

The README does not currently make detailed runtime or memory promises across
machines. Treat those environments as confirmed test platforms, not as a full
compatibility matrix.

## Loading

`AntCalc` is distributed as a Wolfram paclet. After cloning the repository,
install it once from a Wolfram notebook or kernel:

```wl
repoRoot = "/path/to/antenna_pipeline";
archive = CreatePacletArchive[repoRoot, $TemporaryDirectory];
PacletInstall[archive];
```

Thereafter, load it in any notebook or kernel with:

```wl
<< AntCalc`
```

If a notebook kernel was already running while the paclet was installed and
does not find it, evaluate `PacletDataRebuild[]`, restart that kernel, and try
again. This is a one-time Wolfram paclet-index refresh, not a normal startup
step.

### Development fallback

During active work on a cloned checkout, use the repository loader instead.
This immediately reads your saved local changes and does not require rebuilding
or reinstalling the paclet:

```wl
repoRoot = "/path/to/antenna_pipeline";
Get[FileNameJoin[{repoRoot, "AntennaPipeline.wl"}]]
```

Rebuild and reinstall the paclet when you want to test the version an external
user receives.

From the terminal:

```sh
cd /path/to/antenna_pipeline
/Applications/Wolfram.app/Contents/MacOS/WolframKernel -noprompt -run '<<AntCalc`; Exit[]'
```

If you want the shortest realistic first-run sequence from the terminal:

```sh
cd /path/to/antenna_pipeline
bash dev/run_release_verification.sh
```

That command is intended to answer the practical question “does this checkout
work as a supported package installation?”

## Public API

The main public entry points are:

```wl
BuildAntenna[type, numFinalParticles, loopOrder, ...]
BuildAntennaObject[type, numFinalParticles, loopOrder, ...]
IntegrateAntenna[antennaObject, ...]
BuildAndIntegrateAntenna[type, numFinalParticles, loopOrder, ...]
BuildRRatio[model, ...]
TObject[order, finalState, ...]
BuildAllAntennae[model, ...]
BuildAndIntegrateAllAntennae[model, ...]
AntennaPipelineConventionReport[]
AntennaRouteProfileReport[type, numFinalParticles, loopOrder]
AntennaRouteEnvironmentReport[type, numFinalParticles, loopOrder]
AntennaPhysicsValidationReport[type, numFinalParticles, loopOrder]
BuildRRatioPhysicsValidationReport[]
VerifyWardIdentity[]
VerifyWardIdentity[type, numFinalParticles, loopOrder, ...]
RunSupportedMasslessPhysicsValidation[]
```

The usual user-facing story is:

1. build an unintegrated antenna with `BuildAntenna[...]`
2. optionally build an integration-ready object with `BuildAntennaObject[...]`
3. integrate with `IntegrateAntenna[...]`
4. or use `BuildAndIntegrateAntenna[...]` for the one-shot route

### API Reference

`BuildAntenna[type, numFinalParticles, loopOrder, ...]`

- Purpose: build the public unintegrated antenna result for one route key.
- Input shape: an antenna key such as `{A,3,0}` written as
  `BuildAntenna[A, 3, 0, ...]`.
- Normal result shape: a scalar antenna expression, or a list of ordered public
  components when that family has a multi-component public output.
- Contract note: for some loop families, especially around `A31`, the intended
  public normalization/renormalization boundary is documented below and is not
  yet enforced uniformly by the current implementation.
- Inspection variants: may instead return diagnostics, raw build data,
  an `AntennaObject[...]`, or an `AntennaRunRecord[...]` depending on options.
- Scope: this is the main build-side public function for both supported
  massless routes and callable experimental branches.

`BuildAntennaObject[type, numFinalParticles, loopOrder, ...]`

- Purpose: wrap a build result together with the metadata required by
  `IntegrateAntenna[...]`.
- Input shape: same route key as `BuildAntenna[...]`.
- Normal result shape: `AntennaObject[...]`.
- Scope: use this when you want explicit control over build and integration as
  separate stages.

`IntegrateAntenna[antennaObject, ...]`

- Purpose: integrate a built antenna object through the route-selected backend.
- Input shape: an `AntennaObject[...]` produced by `BuildAntennaObject[...]` or
  by `BuildAntenna[..., ReturnAntennaObject -> True]`.
- Normal result shape: an integrated scalar or integrated component list in the
  public package convention.
- Inspection variants: may return diagnostics, T-terms, master combinations,
  intermediate stages, or a full run record.
- Scope: this is the canonical explicit integration entry point.

`BuildAndIntegrateAntenna[type, numFinalParticles, loopOrder, ...]`

- Purpose: run the build and integration pipeline in one public call.
- Input shape: same route key as `BuildAntenna[...]`.
- Normal result shape: the same public integrated result you would obtain by
  composing `BuildAntennaObject[...]` and `IntegrateAntenna[...]`.
- Scope: this is the easiest way to reach the supported integrated endpoints.

`BuildRRatio[model, ...]`

- Purpose: assemble the symbolic NNLO observable-level driver result from the
  supported antenna ingredients.
- Input shape: currently the supported release target is
  `BuildRRatio[SMQCD, quarkMass -> 0, ...]`.
- Normal result shape: by default the finite `MSbar`-convention result, or the
  raw dimensional-regularization series when requested.
- Scope: this is a massless release driver, not an experimental massive route.

`TObject[order, finalState, ...]`

- Purpose: build one public symbolic `T` object from the integrated antenna
  ingredients used by the massless `SMQCD` driver layer.
- Input shape: currently supported public calls use perturbative orders `2`,
  `4`, or `6` together with one of the supported final-state selectors such as
  `qqbar`, `qqbarg`, `qqbarqprimeqprimebar`, `qqbarqqbar`, or `qqbargg`.
- Normal result shape: a symbolic expression in the package's presented public
  convention, or `{result, diagnostics}` when requested.
- Scope: this is a literature-facing massless helper built on top of the same
  validated integrated ingredients as `BuildRRatio[...]`.

`AntennaPipelineConventionReport[]`

- Purpose: report the package-wide public defaults, backend expectations, and
  the current convention state in a code-inspectable association.
- Scope: this is an introspection helper, not a route executor.
- Contract note: it distinguishes intended public contract from current
  implementation reality and does not pretend unresolved dim-reg or
  renormalization questions are already settled.

`AntennaPipelineDimRegDeclaration[]`

- Purpose: report the explicit code-level dimensional-regularization
  declaration used by the package convention model.
- Scope: this is a focused introspection helper for the current package-wide
  `D -> 4 - 2 Epsilon` continuation and its support status.
- Contract note: it does not claim that separately supported `CDR`, `HV`,
  `GDR`, or similar user-selectable variants already exist.

`AntennaRouteProfileReport[type, numFinalParticles, loopOrder]`

- Purpose: report the resolved build profile, integration profile, route
  stories, and route-level contract notes for one antenna key.
- Scope: this is an introspection helper for users, thesis readers, and route
  developers who want to inspect metadata without stepping through the routing
  code manually.

`AntennaRouteEnvironmentReport[type, numFinalParticles, loopOrder]`

- Purpose: report the effective build, integration, and one-shot pipeline
  defaults that would govern one route key under the current package
  environment.
- Scope: this is an introspection helper for users who want to know not only
  what a route is, but how the package currently resolves backend, scale,
  cache, prototype-routing, and mass-handling defaults for it.

`BuildAllAntennae[model, ...]`

- Purpose: bulk-build the supported massless antenna list up to `LO`, `NLO`, or
  `NNLO`.
- Input shape: `BuildAllAntennae[SMQCD, maxOrder -> LO|NLO|NNLO, ...]`.
- Normal result shape: a list of built public antenna results.
- Scope: a convenience wrapper for supported massless `SMQCD` routes only.

`BuildAndIntegrateAllAntennae[model, ...]`

- Purpose: bulk-build and bulk-integrate the supported massless antenna list.
- Input shape: `BuildAndIntegrateAllAntennae[SMQCD, maxOrder -> LO|NLO|NNLO,
  ExpansionOrder -> 0, ...]`.
- Normal result shape: a list of integrated public antenna results.
- Scope: a convenience wrapper over the one-shot route, not an independent
  physics implementation.

### Public Options Reference

The public API uses one shared family of option names. Not every option is
meaningful for every route, so the most useful way to read them is by behavior.

Selection options:

- `Component`
  Select one public component such as `Leading`, `Subleading`, `Nf`, or
  `Breve` when the chosen route has a component split.
- `Contribution`
  Select one internal contribution, such as `TwoLoopTree` or `OneLoopSelf`,
  when the route exposes a contribution-level split.

Inspection and return-shape options:

- `ReturnDiagnostics`
  Return `{result, diagnostics}` rather than only the result.
- `ReturnRecord`
  Return an `AntennaRunRecord[...]` with the result, diagnostics, and stable
  intermediate-stage view.
- `IntermediateSteps`
  Request selected named intermediate stages.
- `PrintIntermediateSteps`
  Print the requested stages to the kernel output.

Inspection default values:

- `IntermediateSteps -> {}`
- `PrintIntermediateSteps -> False`
- `ReturnBuildData`
  Return the internal build-side association used by the route layer.
- `ReturnAntennaObject`
  Return an `AntennaObject[...]` instead of only the plain antenna expression.
- `IntegrableForm`
  Request the build-side expression in the form used by downstream integration
  plumbing.
- `BuildOutputBranch`
  Select `"Public"` or `"Prototype"` for direct `BuildAntenna[...]`
  expression output. `"Prototype"` is currently an internal/provisional
  inspection path and is rejected on object/integrable returns.
- `ReturnMasterCombination`
  Return the unreplaced runtime master combination when the chosen integration
  route has one. With `ReturnDiagnostics -> True` or `ReturnRecord -> True`,
  inspect `"MasterCombinationView"` for its stable provenance object: basis,
  definitions, and any bridge status. This option never derives or assumes a
  paper-basis relation. It also prints a compact runtime basis legend before
  the returned expression: propagators, cut propagators, and the masters that
  occur. The expression itself remains unchanged in LiteRed syntax, including
  when more than one basis occurs. Where the route momentum rules prove an
  exact identification, the legend also adds a display-only alias such as
  `p3^2` or `s13`; otherwise it prints only the raw LiteRed propagator.
- `ReturnTTerms`
  Return the T-term object from the integration layer when meaningful.

Stored-result options:

- `UseStoredResults`
  Reuse a matching stored public result when available.
- `StoreResults`
  Persist a newly computed public result to the stored-results cache.
- `RefreshStoredResults`
  Force recomputation and refresh the stored cache entry.
- `ResultsCacheRoot`
  Override the default repo-local stored-results directory.

Stored-result default values:

- `UseStoredResults -> False`
- `StoreResults -> False`
- `RefreshStoredResults -> False`
- `ResultsCacheRoot -> Automatic`

Build and integration routing options:

- `quarkMass`
  Selects the massive branch when supported; the release target is massless
  unless stated otherwise.
- `ReductionBackend`
  Build-side loop reduction selector.
- `PaVeEvaluation`
  Controls whether the `PaVe` route is evaluated through `PaXEvaluate`.
- `ApplyFeynCalcMS`
  Controls whether the `FeynCalc`/`Package-X` normalization bridge is applied on
  the relevant `PaVe` integration routes.
- `ExpansionOrder`
  Sets the target epsilon-series order.
- `KinematicScale`
  Selects the symbolic scale variable used by the integration normalization
  layer.
- `NormalizeKinematicScale`
  Controls whether the selected kinematic scale is normalized to `1` in the
  final result.
- `GenerateMissingBases`
  Allow the IBP backend to generate a missing basis when that route supports it.
- `BasisFamily`, `BasisRoot`
  Low-level integration-backend overrides for IBP-family routing.
- `LoopMomentum`, `LoopMomenta`
  Loop-momentum selectors used by loop routes.
- `ApplyDimReg`
  Apply the package’s dimensional-regularization substitution.
- `ApplyStripCouplings`
  Control build-side coupling stripping.
- `ApplyCasimirSubstitution`
  Control replacement of abstract Casimirs by explicit `SU(N)` expressions.

Workflow and diagnostics options:

- `RunPaperCheck`
  Request paper-target validation when that route has a paper-check layer.
- `AllowPrototypeTargets`
  Permit explicitly prototype or provisional target routes when supported.
- `UseSourceModelRoute`
  Force the source-model route where that experimental branch supports it.
- `DetailedTimingDiagnostics`
  Request extended timing diagnostics from heavy integration routes.
- `printDiagram`, `Verbose`, `prefactor`
  Build-side workflow controls used mainly for route inspection and derivation.

Public-versus-internal note:

- the options listed in this reference are the supported user-visible switches
- options documented here may still be marked experimental or provisional in
  meaning, but they are not hidden features
- symbols or globals that are not documented here should be treated as internal
  implementation controls for developers rather than as part of the external
  package contract

Driver-specific options:

- `ResultForm`
  For `BuildRRatio[...]`, the public forms are `"ComputedFiniteCoefficient"`
  (the default), `"RawDimRegSeries"`, and `"ReferenceFiniteMSBar"`.
  The first two are assembled from the requested integrated antenna
  ingredients; the reference form is an explicitly requested encoded target
  for comparison only.
- `maxOrder`
  For bulk helpers and `BuildRRatio[...]`, choose `LO`, `NLO`, or `NNLO`
  either as uppercase symbols or as the corresponding uppercase strings.

Function-to-option notes:

- `BuildAntenna[...]` has the richest build-side option surface.
- `BuildAntennaObject[...]` uses the `BuildAntenna[...]` option set except for
  `ReturnRecord`.
- `IntegrateAntenna[...]` and `BuildAndIntegrateAntenna[...]` share the same
  integration option surface.
- `BuildRRatio[...]` exposes inspection and stored-result options, but not the
  full low-level integration-routing surface.
- bulk helpers currently expose only `quarkMass`, `maxOrder`, and
  `ExpansionOrder` where relevant; they do not currently expose the full
  stored-result option family directly.

### Components And Contributions

Several public routes return more than one physically meaningful piece. The
README should be read with a distinction between component splits and
contribution splits.

Component split:

- a route returns multiple public package-facing pieces that all belong to the
  same family
- these are selected with `Component -> ...`

Contribution split:

- a route is assembled from multiple build or integration contributions that are
  meaningful to inspect separately
- these are selected with `Contribution -> ...`

The current canonical component orders are:

- `A40`: `{Leading, Subleading}` = `{A4^0(1,3,4,2), tilde A4^0}`
- `A31`: `{Leading, Subleading, Nf}`
- `A22`: `{Leading, Subleading, Nf, Breve}`

How to read those names:

- for `A40`, `Leading` is one explicitly ordered antenna, while `Subleading`
  is `tilde A4^0` itself. The raw full-colour subleading coefficient is
  `-tilde A4^0`; that minus sign belongs to colour algebra and is applied only
  when an observable is assembled.
- `Nf` is the fermion-flavor contribution exposed as its own public component
  on routes such as `A31` and `A22`
- `Breve` is the extra public `A22` component associated with the one-loop/self
  route contribution

The most important route-shape cases are:

- `A40`-family routes return a two-component public structure
- `A31` returns three public integrated components, which feed the
  `BuildRRatio[...]` assembly as `intA31`, `intTildeA31`, and `intHatA31`
- `A22` returns four public integrated components, which feed
  `BuildRRatio[...]` as `intA22`, `intTildeA22`, `intHatA22`, and
  `intBreveA22`
- `A22` also has a contribution split at the route level, most notably
  `TwoLoopTree` and `OneLoopSelf`
- the intended meaning of those four integrated public outputs is not merely
  “the package’s own final A22 antenna pieces”, but the exact paper-facing
  `T_{qq}^{(6)}` component set: `Leading`, `Subleading`, and `Nf` from the
  `T_{qq}^{(6,[2x0])}` branch together with `Breve` from
  `T_{qq}^{(6,[1x1])}`

Examples:

```wl
BuildAndIntegrateAntenna[A, 4, 0, Component -> Leading]
BuildAndIntegrateAntenna[A, 3, 1, Component -> Nf]
BuildAntenna[A, 2, 2, Contribution -> TwoLoopTree, ReturnDiagnostics -> True]
BuildAndIntegrateAntenna[A, 2, 2, Contribution -> OneLoopSelf, ReturnRecord -> True]
BuildAndIntegrateAntenna[A, 3, 1, ReturnDiagnostics -> True]
```

For `A22`, the build/integration distinction matters more than for the one-loop
routes. `BuildAntenna[A, 2, 2, ...]` returns the unintegrated two-loop object
split into its public components; it does not promise a generic
`PaVe`-reduced form. The reduced `A22` route lives on the integration side,
where the two-loop branch is handled through the package’s dedicated
master-integral machinery rather than through a generic one-loop `PaVe` basis.
On the integrated side, the package contract is specifically the paper-facing
`T_{qq}^{(6)}` object rather than a looser package-internal approximation that
is only later identified with that literature quantity.

### Normalization And Renormalization State

Task 1 status:

- done: the package now has a canonical code-level convention model in the core
  metadata registry rather than relying only on README prose or ad hoc runtime
  report assembly
- done: build and integration profiles now carry route-level convention
  subrecords
- not yet done: the actual loop-family build-side boundary repair, especially
  around `A31`

Task 2 status:

- done: the package now exposes a separate route-environment report so users
  can inspect effective build/integration defaults rather than only raw option
  declarations or route-profile metadata
- done: the report includes effective backend, `PaVeEvaluation`, scale
  normalization, cache-policy defaults, prototype-routing defaults, and
  mass-handling notes
- done: configurable package-wide default overrides are now supported through a
  dedicated defaults layer, and the route-environment report now includes that
  global-default state explicitly

Task 3 status:

- done: the package now declares its dim-reg state explicitly in code rather
  than leaving it as an unresolved placeholder
- done: the declaration records one package-wide
  `D -> 4 - 2 Epsilon` continuation controlled by `ApplyDimReg`
- done: the declaration explicitly says this is not yet a supported
  user-selectable `CDR` / `HV` / `GDR` distinction
- not yet done: validated convention toggles or route-selectable
  external-state prescriptions

Task 4 status:

- done: build-route data now carries an explicit output-boundary record with
  separate `Public` and `Prototype` branches
- done: `BuildAntenna[...]` and `BuildAntennaObject[...]` now read the public
  branch intentionally instead of treating the route-native component payload
  as an implicit contract by accident
- done: build records, diagnostics, and `ReturnBuildData -> True` now retain
  the prototype branch alongside the public branch for inspection and later
  semantic repair work
- not yet done: route-specific cases where the public and prototype branches
  should differ physically still need the actual semantics repair, especially
  for loop routes such as `A31`

Task 5 status:

- done: the `A31` build route now distinguishes its public branch from the raw
  prototype branch in a physically meaningful way rather than only structurally
- done: the public `A31` build branch now applies the explicit lower-`A30` UV
  counterterm pattern, while the prototype branch preserves the pre-counterterm
  extracted one-loop components
- done: the previously suspicious `A31` quark-loop / `Nf` build-side behavior
  is now confined to the prototype branch; the public branch carries a nonzero
  `Nf` contribution as intended
- done: Task `5a` is treated as complete; default public
  `BuildAntenna[A, 3, 1, ...]` now exposes the repaired build-side branch
  while the older route-native object flow is left intact
- resolved during Task `10b`: the integrated `A31` leading, subleading, and
  `Nf` targets now match exactly after repairing the Appendix A.2 master
  conventions and removing the redundant observable bridge
- longer-term Task `5b` work is now limited to broader convention-regression
  coverage, not a known public `A31` residual

The intended public contract is:

- `BuildAntenna[...]` should expose package-facing results in the package
  normalization and renormalization convention
- `IntegrateAntenna[...]` and `BuildAndIntegrateAntenna[...]` should preserve
  that same public convention
- raw pre-counterterm or bare algebra is an internal/provenance object unless a
  future explicit option exposes it intentionally

Why `A31` is still architecturally unfinished:

- the package already knows the public-facing lower-`A30` UV-counterterm
  pattern that should be applied to the `A31` components
- however, the current pipeline still realizes that boundary most cleanly in
  route-specific extraction/integration logic rather than from one fully
  separated bare-to-renormalized build module
- that is why the current public `BuildAntenna[A, 3, 1, ...]` repair is a
  branch-level package-facing correction, while the prototype branch preserves
  the pre-counterterm route-native extracted components for provenance and
  debugging
- the remaining debt is therefore not uncertainty about which public
  counterterms are intended, but the lack of a deeper refactor that would make
  that renormalized public boundary structural throughout the pipeline

The package currently uses `q2` as the canonical kinematic normalization scale
for public integrated routes. The integration layer exposes this explicitly
through:

- `KinematicScale -> q2` by default
- `NormalizeKinematicScale -> True` by default on the integration surface

For loop routes there are two distinct normalization layers to keep separate:

- build-side loop-amplitude normalization inside the package extraction logic
- integration-side convention conversion after `PaVe` or `IBP` reduction

In particular:

- the loop build/extraction layer uses `LoopExpansionNormalization[1] = 8 Pi^2`
  and `LoopExpansionNormalization[2] = (8 Pi^2)^2` when converting loop objects
  into the package expansion convention
- a `PaVe`-reduced loop antenna is therefore not automatically identical to the
  final public integrated result seen by users
- when the package evaluates a `PaVe` object through `PaXEvaluate`, the result
  must still pass through the route-specific normalization/convention bridge
  rather than being interpreted as the final public package value “as is”

On the `PaVe` / `Package-X` side:

- `PaVeEvaluation -> "PaXEvaluate"` is the default public evaluation mode
- `ApplyFeynCalcMS -> True` is the default integration-side setting
- for the massless two-parton `A21` route, the integration backend applies an
  explicit Package-X-to-paper conversion factor rather than treating the raw
  `PaXEvaluate` output as already in the final package convention

Task 6 status:

- done: the integration backend now distinguishes raw IBP master-substituted
  expressions from the final public integrated convention instead of treating
  them as automatically identical
- done: the IBP layer now applies an explicit backend-to-public convention
  factor for loop families such as `A31` and `A22`
- done: `KinematicScale`, `NormalizeKinematicScale`, and `ApplyFeynCalcMS` now
  flow through the IBP normalization stage itself rather than only through the
  higher-level integration interface
- done: backend diagnostics now expose the applied
  `"ConventionBridgeFactor"` so convention debugging is inspectable in code
- verified locally: a direct `WolframKernel` probe confirms that the A31 IBP
  convention factor is now present in `NormalizeIBPIntegratedResult[...]`
- not yet verified end to end: the heavy full-route `BuildAndIntegrateAntenna[A, 3, 1,
  ReturnDiagnostics -> True]` residual recheck still needs a completed run

Dimensional-regularization declaration:

- the package now explicitly declares a single code-level dimensional
  continuation of the form `D -> 4 - 2 Epsilon`
- that continuation is activated through `ApplyDimReg`
- it is currently a package-wide working assumption, not a menu of separately
  supported external-state prescriptions
- the code now says something more precise than “undeclared”, while still not
  overclaiming support for `CDR`, `HV`, `GDR`, or related toggles

Current implementation status:

- the intended contract is that public build results are already in the package
  renormalization state
- the supported `A31` build and integrated routes now satisfy their encoded
  public paper targets after the Task `10b` convention repair
- the integration-side convention bridge for `A21` and the IBP loop families is
  explicit in code and the heavy `A31` end-to-end recheck is now complete
- this does not claim that every possible regularization prescription is
  supported; it records the verified package convention for the supported
  massless workflow

The same state is now inspectable in code:

```wl
AntennaPipelineConventionModel[]
AntennaPipelineConventionReport[]
AntennaPipelineDimRegDeclaration[]
AntennaRouteProfileReport[A, 3, 1]
AntennaRouteEnvironmentReport[A, 3, 1]
```

Not yet implemented:

- object-facing and integration-facing prototype output selection
- any stable public promise that every route's prototype branch already carries
  a physics-clean derivation payload beyond provenance inspection

The current stable claim is narrower:

- `BuildAntenna[..., BuildOutputBranch -> "Prototype"]` is now a supported
  prototype-facing inspection path for direct expression output
- that prototype branch is documented as internal/provisional in meaning, not
  as a second stable public physics contract
- `BuildAntennaObject[...]`, `ReturnAntennaObject -> True`, and
  `IntegrableForm -> True` continue to expose only the public branch

### Stored Results And Transparent Reuse

The runtime includes a stored-result layer for public-route reuse. The intended
contract is that stored results should be usable transparently across the public
route family rather than as a private notebook trick.

The user-facing controls are:

- `UseStoredResults`
  Attempt to load a matching stored public result instead of recomputing it.
- `StoreResults`
  Save a successful newly computed public result.
- `RefreshStoredResults`
  Recompute the route and overwrite the matching stored entry.
- `ResultsCacheRoot`
  Use a non-default cache root.

Behavioral notes:

- stored results are replays of public-route outputs, not a second derivation
  engine
- when a stored result is used, the route still formats the return into the same
  public shape expected by the caller
- diagnostics are annotated so callers can distinguish cached reuse from a fresh
  run
- cache identity is not just the visible call arguments; it also includes the
  route kind, a route-semantic version, and any convention-critical nested
  defaults that can change the public meaning of the result
- after a semantics repair, older stored entries are intentionally treated as
  stale rather than silently replayed under the new contract
- `BuildAntenna[..., BuildOutputBranch -> "Public"]` and
  `BuildAntenna[..., BuildOutputBranch -> "Prototype"]` are stored under
  different cache identities and therefore do not collide
- driver-level stored results for `BuildRRatio[...]` and `TObject[...]` also
  encode the effective nested `BuildAndIntegrateAntenna[...]` convention
  defaults they depend on, so package-wide environment changes do not reuse a
  semantically stale top-level cache hit
- `PrintIntermediateSteps -> True` prints fresh intermediate stages on a fresh
  run; on a stored-result replay it prints the stored intermediate-stage payload
  when that payload is present rather than silently suppressing the stage view
- the one-shot `BuildAndIntegrateAntenna[...]` route forwards its stored-result
  controls consistently into the delegated build stage as well as its own
  top-level cache layer

Current public coverage:

- explicit stored-result options exist on `BuildAntenna[...]`
- explicit stored-result options exist on `BuildAntennaObject[...]`
- explicit stored-result options exist on `IntegrateAntenna[...]`
- explicit stored-result options exist on `BuildAndIntegrateAntenna[...]`
- explicit stored-result options exist on `BuildRRatio[...]`
- explicit stored-result options exist on `TObject[...]`
- bulk helper wrappers do not currently expose the full stored-result option
  family directly

Not yet implemented:

- transparent stored-result controls on the bulk helper wrappers
- a fully uniform user-facing cache story across every top-level public entry
  point

Examples:

```wl
BuildAndIntegrateAntenna[A, 3, 0, UseStoredResults -> True]
BuildAndIntegrateAntenna[A, 3, 0, StoreResults -> True]
BuildRRatio[SMQCD, quarkMass -> 0, UseStoredResults -> True]
BuildAntenna[A, 3, 1, ReturnRecord -> True, StoreResults -> True]
```

## Happy Path

The canonical onboarding workflow is:

1. Load the package.
2. Run one build example.
3. Run one integrated example.
4. Run the release verification script.
5. Optionally inspect records and intermediate stages.

Representative examples:

```wl
BuildAntenna[A, 2, 0]
BuildAndIntegrateAntenna[A, 3, 0]
BuildAndIntegrateAntenna[A, 3, 0, ReturnRecord -> True]
BuildRRatio[SMQCD, quarkMass -> 0]
BuildRRatio[SMQCD, quarkMass -> 0, ResultForm -> "RawDimRegSeries"]
BuildRRatio[SMQCD, maxOrder -> NLO]
BuildRRatio[SMQCD, ResultForm -> "ReferenceFiniteMSBar"]
BuildAllAntennae[SMQCD, maxOrder -> NNLO]
BuildAndIntegrateAllAntennae[SMQCD, maxOrder -> NNLO, ExpansionOrder -> 0]
```

## What Success Looks Like

For a basic external-user installation check, the important thing is not the
exact algebraic form of every expression, but whether the public routes return
the expected kind of object without manual setup beyond `Get[...]`.

Typical successful result shapes are:

- `BuildAntenna[A, 2, 0]`
  returns a plain Wolfram expression for the selected antenna.
- `BuildAntenna[A, 3, 1]`
  returns a multi-part list corresponding to the route's public component
  structure unless `Component` or `Contribution` narrows it.
- `BuildAntennaObject[...]`
  returns an `AntennaObject[...]` suitable for later integration.
- `IntegrateAntenna[...]` and `BuildAndIntegrateAntenna[...]`
  return the plain integrated result by default and an `AntennaRunRecord[...]`
  when `ReturnRecord -> True`.
- `BuildRRatio[SMQCD, quarkMass -> 0]`
  returns the assembled public `R`-ratio expression in the selected
  `ResultForm`.
- `BuildAllAntennae[...]` and `BuildAndIntegrateAllAntennae[...]`
  return ordered lists following the documented route order for the supported
  massless release set.

If you ask for a record:

```wl
rec = BuildAndIntegrateAntenna[A, 3, 0, ReturnRecord -> True];
Keys[rec]
```

you should expect stable top-level entries such as `"Result"`,
`"Diagnostics"`, and `"IntermediateSteps"`, with additional route-dependent
fields documented later in this README.

## Bulk Workflows

For the fully implemented massless SMQCD release target, the package also
ships two convenience drivers that walk the supported antenna list up to a
chosen perturbative order:

- `BuildAllAntennae[SMQCD, maxOrder -> LO|NLO|NNLO]`
- `BuildAndIntegrateAllAntennae[SMQCD, maxOrder -> LO|NLO|NNLO,
  ExpansionOrder -> 0]`

Their current scope is intentionally narrow:

- they are implemented for `SMQCD`
- they accept either uppercase order symbols `LO`, `NLO`, and `NNLO` or the
  corresponding uppercase strings
- their massless target is the same supported `A`, `B`, and `C` release set
- they are convenience wrappers over `BuildAntenna[...]` and
  `BuildAndIntegrateAntenna[...]`, not independent physics routes

The current SMQCD lists are:

- `LO`: `A20`
- `NLO`: `A20`, `A30`, `A21`
- `NNLO`: `A20`, `A30`, `A21`, `A40`, `B40`, `C40`, `A31`, `A22`

The return value follows that order directly:

- `BuildAllAntennae[...]` returns a list of built results in the `LO`, `NLO`,
  or `NNLO` route order above
- `BuildAndIntegrateAllAntennae[...]` returns a list of integrated results in
  the same order
- keyed wrappers may be added later, but they are not the current public
  contract

They are not yet the right entry point for experimental massive work:

- nonzero `quarkMass` currently aborts in these bulk helpers
- `SUSY` and `HiggsEFT` bulk enumeration are scaffolded but not implemented

If you want inspectable state rather than only the final result:

```wl
rec = BuildAndIntegrateAntenna[A, 3, 0, ReturnRecord -> True];
rec["Result"]
rec["IntermediateSteps"]
rec["Diagnostics"]
rec["MasterCombination"]
```

The default behavior is unchanged: without `ReturnRecord -> True`, the public
functions still return the same plain result shapes as before.

## Release Verification

The canonical package acceptance script is:

```sh
cd /path/to/antenna_pipeline
bash dev/run_release_verification.sh
```

That script checks only the supported release matrix. It is the intended
“does this package installation work?” command for external users.

The first physics-aware validation harness is now separate:

```sh
cd /path/to/antenna_pipeline
bash dev/run_physics_validation.sh
```

That script is developer-facing rather than the external-user acceptance test.
Its current scope is the first `Task 10` slice:
integrated pole-structure validation plus massless tree-level Ward checks,
with honest `Pass`, `Fail`, `KnownIssue`, `RouteEvaluationFailed`, and
`NotAvailableYet` statuses.

Operational notes:

- it requires `wolframscript` on `PATH`
- it uses the repo-local `AntennaPipeline.wl` loader for each test case
- it excludes experimental massive `A30` and `D30`
- it is more than a trivial smoke test: it exercises representative supported
  build, integrate, record, and driver routes

The exact runtime depends strongly on the local Wolfram setup and symbolic
backend performance, so the README does not promise a fixed duration. Treat it
as the canonical acceptance run rather than as a near-instant probe.

Long-running public routes now emit lightweight start/finish progress prints so
users can tell the difference between a genuinely active heavy computation and a
silent stall.

A lighter smoke test is:

```sh
cd /path/to/antenna_pipeline
/Applications/Wolfram.app/Contents/MacOS/WolframKernel -noprompt -run 'Get["AntennaPipeline.wl"]; Print[BuildAntenna[A,2,0]]; Print[BuildAndIntegrateAntenna[A,3,0]]; Exit[]'
```

The benchmark harness remains available, but it is not the acceptance test:

```sh
cd /path/to/antenna_pipeline
/Applications/Wolfram.app/Contents/MacOS/WolframKernel -noprompt -script dev/run_public_route_benchmarks.wl
```

Tracked future work:

- publish representative timing benchmarks for the supported release routes on
  the tested environments
- keep those timings separate from the correctness-facing acceptance workflow so
  performance notes do not get confused with release validation
- widen the physics-validation harness beyond the current integrated
  pole-structure layer to Catani-operator, Ward-identity, and factorization
  checks once those applicability boundaries are encoded honestly

## Glossary

- `Route`
  One public or internal execution path identified by an antenna family and
  the metadata needed to build or integrate it.
- `Profile`
  The registry entry that tells the package how a route should be built,
  normalized, integrated, and post-processed.
- `Component`
  A structural part of a multi-piece antenna family such as `Leading`,
  `Subleading`, `Nf`, or `Breve`.
- `Contribution`
  A physics-source selector used on routes that split by origin, for example a
  self-energy or loop-insertion contribution.
- `AntennaObject`
  The metadata-carrying wrapper used to transport a built antenna cleanly into
  the integration layer.
- `AntennaRunRecord`
  The inspectable result container returned by `ReturnRecord -> True`.
- `Stored result`
  A cached build or integration result reused through
  `UseStoredResults` / `StoreResults`.
- `Open master values`
  Runtime master-integral replacements loaded from the checked-in
  `master_values_runtime.wl` artifact rather than regenerated on the fly.

## Experimental Inspection

The experimental branches remain callable, but should be used with that status
in mind.

Massive `A30` build-side route:

```wl
BuildAntenna[A, 3, 0, quarkMass -> mQ, ReturnRecord -> True]
BuildAntennaObject[A, 3, 0, quarkMass -> mQ]
```

Massive `A30` integrated-route diagnostics:

```wl
BuildAndIntegrateAntenna[A, 3, 0, quarkMass -> mQ, ReturnDiagnostics -> True]
```

`D30` source-route diagnostics:

```wl
BuildAntenna[D, 3, 0, ReturnDiagnostics -> True]
BuildAntenna[D, 3, 0, ReturnRecord -> True]
```

Research and provenance material for those branches lives under:

- [dev/massiveA30](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/dev/massiveA30)
- [dev/massiveA30_sources](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/dev/massiveA30_sources)
- [dev/d30](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/dev/d30)

## Runtime Master Values

The runtime `A31` and `A22` master substitutions are intentionally loaded from
a checked-in artifact rather than recomputed on package load:

- artifact:
  [masterIntegrals/master_values_runtime.wl](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/masterIntegrals/master_values_runtime.wl)
- provenance layer:
  [masterIntegrals/](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/masterIntegrals)

Refresh the artifact after changing the derivation-side files:

```sh
cd /path/to/antenna_pipeline
bash masterIntegrals/run_kernel.sh -run 'Get["masterIntegrals/export_runtime_master_values.wl"]; Exit[]'
```

Validate it against the live derivation layer:

```sh
cd /path/to/antenna_pipeline
bash masterIntegrals/run_kernel.sh -run 'Get["dev/validate_runtime_master_values.wl"]; Exit[]'
```

## Provenance And Source Mapping

The runtime is package code, but several targets and master-integral inputs are
deliberately tied to explicit literature provenance. The current top-level map
is:

- `hep-ph/0403057`
  source for the `R`-ratio and `T`-object construction, and for the `A31` and
  `A22` master-integral provenance used by the package
- `hep-ph/0311276`
  source for the `A40`, `B40`, and `C40` master-integral provenance
- `hep-ph/0505111`
  source for the remaining main antenna targets and comparison objects used by
  the package

This does not mean every runtime expression is merely copied from the papers.
The package distinguishes between:

- package-owned routing, normalization, diagnostics, and integration plumbing
- imported or provenance-tied targets and master values
- explicit experimental branches where the package still exposes honest partial
  or literature-bridged results rather than claiming a fully internal
  derivation

That distinction is important for thesis use, supervision, and open-source
readers: the package is meant to be both executable software and an honest map
of where each result comes from.

## Stored Results And Runtime Artifacts

The runtime includes a repo-local stored-result cache under `stored_results/`.
This is a usability feature, not a second source of truth: cached results are
replays of public-route outputs, while the route implementations remain the
authoritative computation layer.

Checked-in runtime artifacts matter in two different ways:

- `stored_results/` contains reusable public-route outputs
- `bases/`, `generated_bases/`, and
  `masterIntegrals/master_values_runtime.wl` support integration backends and
  runtime master substitution

Normal users do not need to regenerate these on every run. If you are doing
derivation or backend work, then the relevant `dev/` and `masterIntegrals/`
scripts become part of the workflow.

## Repository Layout

The release-facing surface is intentionally small:

- [AntennaPipeline.wl](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/AntennaPipeline.wl)
  is the canonical loader
- [src/](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/src)
  is the canonical runtime source tree
- [dev/](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/dev)
  contains release verification, benchmarks, and research/provenance scripts
- [masterIntegrals/](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/masterIntegrals)
  contains derivation-owned master-integral provenance for runtime values

See
[src/README.md](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/src/README.md)
for the runtime architecture walkthrough and
[dev/README.md](/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/dev/README.md)
for the development-script map.

## Troubleshooting

- If `bash dev/run_release_verification.sh` fails immediately with
  `wolframscript was not found on PATH`, make sure the Wolfram command-line
  tools are installed and visible in the shell environment running the script.
- If package load fails early inside `src/core/setup.wl`, the most likely cause
  is a missing or incompatible `FeynCalc` / `FeynArts` / `FeynHelpers`
  installation.
- If a route fails inside the `IBP` backend, check that the repository basis
  directories are present and that the required runtime artifacts have not been
  removed from `bases/`, `generated_bases/`, or `masterIntegrals/`.
- If an experimental route such as massive `A30` or `D30` returns `$Failed`,
  that is not automatically an installation failure. Those branches are
  intentionally callable but outside the supported release guarantee.
- If a bulk helper aborts on nonzero `quarkMass`, lowercase `maxOrder`, or
  unsupported models such as `SUSY` / `HiggsEFT`, that is current package
  behavior rather than a broken installation.
- If you modify derivation-side master-integral files and then see mismatches in
  integrated routes, refresh and revalidate
  `masterIntegrals/master_values_runtime.wl` before assuming the runtime route
  is wrong.

## Known Non-Goals

This release does not claim:

- a fully internal closed massive `A30` master-substitution derivation
- a finished public `D30` antenna extraction
- a finished `SUSY` or `HiggsEFT` `R`-ratio route
- that every research/provenance script under `dev/` is part of the supported
  user workflow

The project is considered complete around the massless package goal, not
around finishing every exploratory physics branch.

## API Appendix

This appendix is the function-by-function reference complement to the earlier
grouped option overview. It is intentionally exhaustive at the option-name
level, so users and supervisors can cross-check the public API against the live
package surface directly.

### `BuildAntenna[...]`

Purpose:

- build the public unintegrated antenna result for one route key

Options:

- `ReturnDiagnostics`
  Return `{result, diagnostics}`.
- `ReturnBuildData`
  Return the route-owned build association instead of only the public result.
- `ReturnAntennaObject`
  Return an `AntennaObject[...]`.
- `IntegrableForm`
  Request the build-side expression in the form used for downstream
  integration.
- `ReturnRecord`
  Return an `AntennaRunRecord[...]`.
- `RunPaperCheck`
  Enable route-specific paper-target validation when available.
- `Verbose`
  Enable extra route-level printing where implemented.
- `printDiagram`
  Print or expose the diagram-generation stage on routes that support it.
- `prefactor`
  Override the build-side overall prefactor.
- `quarkMass`
  Select the massive branch when that route supports it.
- `ApplyStripCouplings`
  Control coupling stripping.
- `ApplyCasimirSubstitution`
  Control replacement of abstract Casimirs by explicit `SU(N)` expressions.
- `ApplyDimReg`
  Apply the package dimensional-regularization substitution.
- `LoopMomentum`
  Choose the one-loop momentum symbol.
- `ReductionBackend`
  Choose the build-side loop reduction backend.
- `Component`
  Select one public component from a multi-component route.
- `IntermediateSteps`
  Request named build-side intermediate stages.
- `PrintIntermediateSteps`
  Print the requested intermediate stages.
- `LoopMomenta`
  Choose the two-loop momentum pair.
- `Contribution`
  Select one route contribution where exposed.
- `BuildOutputBranch`
  Choose `"Public"` or `"Prototype"` for direct `BuildAntenna[...]`
  expression output. The default is `"Public"`. The prototype branch is
  intentionally unavailable with `BuildAntennaObject[...]`,
  `ReturnAntennaObject -> True`, and `IntegrableForm -> True`.
- `AllowPrototypeTargets`
  Permit prototype or provisional targets where that branch allows them.
- `UseSourceModelRoute`
  Force the source-model route where implemented.
- `UseStoredResults`
  Reuse a matching stored public result if available.
- `StoreResults`
  Store the computed public result.
- `ResultsCacheRoot`
  Override the default stored-result root.
- `RefreshStoredResults`
  Recompute and refresh a matching stored result.

### `BuildAntennaObject[...]`

Purpose:

- build an `AntennaObject[...]` carrying the metadata needed by
  `IntegrateAntenna[...]`

Options:

- identical to `BuildAntenna[...]` except `ReturnRecord`

### `IntegrateAntenna[...]`

Purpose:

- integrate an `AntennaObject[...]` through the route-selected backend

Options:

- `ApplyFeynCalcMS`
  Apply the `FeynCalc`/`Package-X` convention bridge on relevant `PaVe` routes.
- `quarkMass`
  Select the massive branch when supported.
- `PaVeEvaluation`
  Select the `PaVe` evaluation mode, currently defaulting to
  `"PaXEvaluate"`.
- `ExpansionOrder`
  Set the target epsilon-series order.
- `KinematicScale`
  Set the symbolic kinematic scale, default `q2`.
- `NormalizeKinematicScale`
  Normalize the chosen scale to `1` in the final result.
- `ReturnDiagnostics`
  Return `{result, diagnostics}`.
- `ReturnRecord`
  Return an `AntennaRunRecord[...]`.
- `ReturnMasterCombination`
  Return the master-combination view when available.
- `LoopMomentum`
  Set the loop momentum symbol for `PaVe` routes.
- `ApplyDimReg`
  Apply the package dimensional-regularization substitution.
- `BasisFamily`
  Override the IBP basis family.
- `BasisRoot`
  Override the IBP basis root on disk.
- `GenerateMissingBases`
  Allow missing basis generation where the route supports it.
- `ReturnTTerms`
  Return the T-term object where meaningful.
- `Component`
  Select one public component.
- `Contribution`
  Select one contribution-level route branch.
- `IntermediateSteps`
  Request named integration-side intermediate stages.
- `PrintIntermediateSteps`
  Print the requested intermediate stages.
- `DetailedTimingDiagnostics`
  Request extended timing diagnostics from heavy integration routes.
- `UseStoredResults`
  Reuse a matching stored public result.
- `StoreResults`
  Store the computed public result.
- `ResultsCacheRoot`
  Override the stored-result root.
- `RefreshStoredResults`
  Recompute and refresh a matching stored result.

### `BuildAndIntegrateAntenna[...]`

Purpose:

- run the public build and integration pipeline in one call

Options:

- identical to `IntegrateAntenna[...]`

### `BuildRRatio[...]`

Purpose:

- assemble the supported symbolic NNLO R-ratio driver

Options:

- `quarkMass`
  Currently the supported release target is `quarkMass -> 0`.
- `ReturnDiagnostics`
  Return `{result, diagnostics}`.
- `IntermediateSteps`
  Request named driver-side intermediate stages.
- `PrintIntermediateSteps`
  Print the requested stages.
- `UseStoredResults`
  Reuse cached public driver results and ingredient calls where applicable.
- `StoreResults`
  Store the resulting public driver output.
- `ResultsCacheRoot`
  Override the stored-result root.
- `RefreshStoredResults`
  Recompute and refresh a matching stored result.
- `ResultForm`
  Select `"ComputedFiniteCoefficient"` (default), `"RawDimRegSeries"`, or
  `"ReferenceFiniteMSBar"`.
  The computed finite coefficient is extracted from the antenna-assembled raw
  dimensional-regularisation series. The raw form exposes that series for
  convention and pole-closure inspection. The reference form returns the
  compact encoded target directly and is never used to replace a computed
  result.
- `maxOrder`
  Select `LO`, `NLO`, or `NNLO` (or the corresponding uppercase string).
  `LO` evaluates no integrated antenna, `NLO` evaluates only integrated A21
  and A30, and `NNLO` evaluates the complete existing ingredient set.
- current contract note:
  diagnostics state the result origin, requested order, included/skipped
  ingredients, reference target, and residual. A finite-reference agreement
  is evidence about the assembled result; it does not make a cached or
  encoded expression the computation source.

### `TObject[...]`

Purpose:

- build one public symbolic `T` object from the massless `SMQCD` integrated
  antenna ingredients

Options:

- `quarkMass`
  Currently the supported release target is `quarkMass -> 0`.
- `ExpansionOrder`
  Set the epsilon-series order used by the assembled public expression.
- `ReturnDiagnostics`
  Return `{result, diagnostics}`.
- `UseStoredResults`
  Reuse cached public `T`-object results and nested ingredient calls where
  applicable.
- `StoreResults`
  Store the resulting public `T`-object output.
- `ResultsCacheRoot`
  Override the stored-result root.
- `RefreshStoredResults`
  Recompute and refresh a matching stored result.

### `BuildAllAntennae[...]`

Purpose:

- bulk-build the supported massless antenna list for `SMQCD`

Normal return shape:

- an ordered list following the documented `LO`, `NLO`, or `NNLO` route order

Options:

- `maxOrder`
  Choose `LO`, `NLO`, or `NNLO`, either as symbols or uppercase strings.
- `quarkMass`
  Present in the signature, but nonzero mass currently aborts in the bulk
  helper.

### `BuildAndIntegrateAllAntennae[...]`

Purpose:

- bulk-build and bulk-integrate the supported massless antenna list for `SMQCD`

Normal return shape:

- an ordered list following the documented `LO`, `NLO`, or `NNLO` route order

Options:

- `ExpansionOrder`
  Set the target epsilon-series order for the integrated outputs.
- `maxOrder`
  Choose `LO`, `NLO`, or `NNLO`, either as symbols or uppercase strings.
- `quarkMass`
  Present in the signature, but nonzero mass currently aborts in the bulk
  helper.

### `AntennaPipelineConventionReport[]`

Purpose:

- return a structured package-level report of public defaults, backend startup
  expectations, and current convention-status notes

Normal return shape:

- an association grouped into package-wide defaults, backend environment, and
  convention-state notes

### `AntennaPipelineDimRegDeclaration[]`

Purpose:

- return the explicit code-level dimensional-regularization declaration used by
  the package convention model

Normal return shape:

- an association describing the current package-wide `D -> 4 - 2 Epsilon`
  continuation, its activation control, and its present support boundaries

### `AntennaRouteProfileReport[...]`

Purpose:

- return a structured route-level report of the resolved build and integration
  metadata for one antenna key

Normal return shape:

- an association containing the build profile, build reduction profile,
  integration profile, route stories, and contract-status notes

### `AntennaRouteEnvironmentReport[...]`

Purpose:

- return a structured route-level report of the effective build,
  integration, and one-shot pipeline defaults for one antenna key

Normal return shape:

- an association containing separate `BuildAntenna`,
  `IntegrateAntenna`, and `BuildAndIntegrateAntenna` environment summaries,
  together with route contract-status notes

### `AntennaPhysicsValidationReport[...]`

Purpose:

- run the current physics-aware validation layer for one public route

Current scope:

- the first implemented slice is integrated pole-structure validation
- exact encoded pole targets are currently available for:
  `A21`, `A30`, `A31`, `A22`, `A40`, `B40`, and `C40`
- the `A31` target and the four-parton package-facing targets are exact encoded
  checks, not placeholders
- routes without an exact target are skipped by default in the aggregate
  validation harness unless explicitly requested
- if a public route itself returns `$Failed`, the validation layer reports
  `RouteEvaluationFailed` rather than mislabeling that as a physics mismatch

Representative usage:

```wl
AntennaPhysicsValidationReport[A, 3, 0]
AntennaPhysicsValidationReport[A, 3, 1, UseStoredResults -> True]
```

### `BuildRRatioPhysicsValidationReport[]`

Purpose:

- validate the massless `BuildRRatio[SMQCD, quarkMass -> 0]` route at the raw
  Laurent-series level

Current scope:

- evaluate `BuildRRatio[...]` with `ResultForm -> "RawDimRegSeries"`
- extract the explicit epsilon-pole coefficients through epsilon^0
- check that the observable-level poles cancel through epsilon^-1
- compare the epsilon^0 coefficient against the known public finite SMQCD
  expression
- report a structured `Pass` / `Fail` / `RouteEvaluationFailed` status rather
  than reducing this to a notebook-only spot check
- current implementation status:
  a fresh uncached run on `2026-07-14` returned `ValidationStatus -> Pass`,
  zero residual coefficients from epsilon^-4 through epsilon^0, and zero
  finite residual. Cached reuse is separately available for practical use.

Representative usage:

```wl
BuildRRatioPhysicsValidationReport[]
BuildRRatioPhysicsValidationReport[UseStoredResults -> True]
```

### `VerifyWardIdentity[...]`

Purpose:

- validate a full unsquared supported massless A-family amplitude by replacing
  one external gluon polarization vector with its own momentum

Verified scope:

- `VerifyWardIdentity[A, 3, 0]` checks the `A30` gluon on leg `3`
- `VerifyWardIdentity[A, 4, 0]` checks each `A40` gluon on legs `3` and `4`
- `VerifyWardIdentity[A, 3, 1]` checks raw one-loop `A31` on leg `3`, before
  interference, counterterm presentation, or integration; the diagnostic
  simplifier uses standard PaVe tensor reduction to establish the loop identity
- all four current gluon checks return an exact zero residual
- `A20`, `A22`, `B40`, and `C40` report `NotApplicable`; massive `A30` and
  experimental `D30` remain outside this validation scope

Options and return shape:

- `GluonLeg -> All` selects every applicable gluon leg; pass one leg number or
  a list to inspect selected replacements
- `VerifyWardIdentity[]` prints the `A30`/`A40`/`A31` suite; a route call
  prints only the selected route's row or rows, with its exact residual
- the suite now generates and simplifies a one-loop amplitude for `A31`; it
  can take substantially longer than the tree-only suite and writes no
  stored-result artifacts
- `ReturnDiagnostics -> True` returns the full association with one residual
  report per selected gluon and an overall `Pass`, `Fail`, `NotApplicable`,
  `NotAvailableYet`, or `RouteEvaluationFailed` status
- this is a diagnostic validation API: it does not alter build, integration, or
  stored-result behavior

Representative usage:

```wl
VerifyWardIdentity[]
VerifyWardIdentity[A, 3, 0]
VerifyWardIdentity[A, 4, 0]
VerifyWardIdentity[A, 3, 1]
VerifyWardIdentity[A, 4, 0, GluonLeg -> 3]
VerifyWardIdentity[A, 4, 0, ReturnDiagnostics -> True]
```

### `RunSupportedMasslessPhysicsValidation[]`

Purpose:

- run the current physics-aware validation layer across the supported
  integrated massless release routes together with the current observable-level
  `BuildRRatio[...]` validation slice, and return one association of route
  reports

Representative usage:

```wl
report = RunSupportedMasslessPhysicsValidation[]
PhysicsValidationStatusCounts[report]
```

### `AntennaPipelineDefaults[]`

Purpose:

- inspect the currently active supported package-wide default environment

Normal return shape:

- an association containing:
  the current user-installed defaults,
  the supported option keys,
  the managed public heads,
  the explicit precedence model,
  and per-head built-in versus effective default-resolution summaries

### `SetAntennaPipelineDefaults[...]`

Purpose:

- install supported package-wide default option overrides across the public API

Representative usage:

```wl
SetAntennaPipelineDefaults[<|
  "UseStoredResults" -> True,
  "KinematicScale" -> q2,
  "NormalizeKinematicScale" -> True
|>]
```

### `ResetAntennaPipelineDefaults[]`

Purpose:

- restore the built-in public option defaults after package-wide overrides

### Option Meaning Notes

- `Component` only matters on routes with public component splits such as
  `A40`, `A31`, and `A22`.
- `Contribution` only matters on routes with a contribution-level split, most
  notably `A22`.
- `UseStoredResults`, `StoreResults`, `ResultsCacheRoot`, and
  `RefreshStoredResults` are first-class public controls on the main build,
  integration, and driver routes, but not yet exposed through the bulk helper
  wrappers.
- the public defaults for the cache and inspection controls are:
  `UseStoredResults -> False`,
  `StoreResults -> False`,
  `RefreshStoredResults -> False`,
  `ResultsCacheRoot -> Automatic`,
  `IntermediateSteps -> {}`,
  `PrintIntermediateSteps -> False`
- `PrintIntermediateSteps -> True` prints requested intermediate stages on fresh
  runs, and on stored-result replays it prints the stored intermediate-stage
  payload when available.
- `AllowPrototypeTargets` and `UseSourceModelRoute` are branch-level
  or derivation-level controls and should not be read as part of the stable
  release contract.

## Record And Object Appendix

The package exposes two important metadata wrappers:

- `AntennaObject[...]`
- `AntennaRunRecord[...]`

These are part of the inspection and workflow surface and should be understood
as public containers, even though many of their fields are route-owned.

### `AntennaObject[...]`

Purpose:

- carry a built antenna together with the route metadata needed by
  `IntegrateAntenna[...]`

Core fields:

- `Key`
  The route key `{type, multiplicity, loopOrder}`.
- `Profile`
  The resolved `AntennaProfile[...]` metadata.
- `BuildData`
  The route-owned internal build association.
- `FullAntenna`
  The full unselected public build result.
- `Antenna`
  The currently selected antenna payload.
- `SelectedComponent`
  The current component selector.
- `SelectedComponentName`
  The normalized string form of the selected component.
- `Contribution`
  The current contribution selector.
- `ContributionName`
  The normalized string form of the selected contribution.

Related accessors:

- `AntennaKey[obj]`
- `AntennaComponent[obj]`
- `AntennaContribution[obj]`
- `AntennaExpression[obj]`
- `AntennaFullExpression[obj]`
- `AntennaObjectData[obj]`

### `AntennaRunRecord[...]`

Purpose:

- package the result, diagnostics, and a stable view of intermediate stages for
  a completed public route

Guaranteed minimal fields:

- `RouteKind`
  The public route that produced the record, such as `BuildAntenna` or
  `IntegrateAntenna`.
- `Result`
  The final selected public result.
- `Diagnostics`
  The route diagnostics association.
- `IntermediateSteps`
  The stable stage view exposed for record inspection.

Build-side record fields:

- `BuildData`
  The route-owned internal build association.
- `BuildOutputBoundarySummary`
  A compact summary of the public/prototype build boundary, showing the
  contract roles, normalization state, and which components coincide or differ.
- `BuildOutputBoundary`
  The explicit public/prototype build boundary record, including the
  route-facing renormalization/output split when that route defines one.
- `FullBuildResult`
  The full public build result before component selection.
- `SelectedBuildResult`
  The selected build result.
- `AntennaObject`
  The integration-ready `AntennaObject[...]` when relevant.
- `BuildDiagnostics`
  The build diagnostics alias.

Integration-side record fields:

- `SourceObject`
  The build-side source object used as integration input.
- `AntennaObject`
  The integration input object.
- `StoredResultCache`
  Stored-result metadata when the output came from cache machinery.
- `InputAntenna`
  The antenna expression fed into the integration route.
- `RawIntegrated`
  The pre-T-term integrated expression.
- `TTerms`
  The T-term object.
- `FinalIntegrated`
  The integrated result before final selection.
- `SelectedIntegrated`
  The selected integrated result.
- `BackendDiagnostics`
  The backend-specific diagnostics association.
- `IntegrationDiagnostics`
  The top-level integration diagnostics alias.

Route-dependent integration aliases that may appear when meaningful:

- `IntegratedResultKind`
- `OpenMasterValuesQ`
- `RawLiteRedCombination`
- `MasterMappedExpression`
- `RawMasterCombination`
- `MasterCombination`
- `MasterCombinationView`
- `MasterSubstitutedExpression`
- `NormalizedBeforeSeries`
- `SeriesResult`
- `OpenMasterRouteAvailable`
- `OpenMasterRouteSucceeded`
- `OpenMasterSubstitutedExpression`
- `OpenMasterSeriesResult`
- `OpenMasterRouteDiagnostics`

Important interpretation note:

- not every record contains every field above
- some fields are guaranteed by record kind
- others appear only when the chosen route and backend make them meaningful
- missing values are represented honestly rather than hidden
- `MasterCombinationView` always distinguishes an available unreplaced runtime
  combination from an unavailable one. For massive A30 it explicitly labels
  the dotted-runtime-master to paper-numerator-master relation as provisional.

### `IntermediateSteps`

`IntermediateSteps` is the stable inspection view intended for human reading and
notebook-style debugging. The exact contents depend on route kind, but the
record helpers deliberately preserve a small set of canonical stage names.

Typical build-side stages include:

- `Amplitude`
- `Interference`
- `BuildOutputBoundarySummary`
- `BuildOutputBoundary`
- `Result`
- `Diagnostics`

Typical integration-side stages include:

- `BuiltAntenna`
- `Method`
- `MasterCombination`
- `DimensionExpression`
- `Result`

Driver-side `BuildRRatio[...]` intermediate-step labels currently include:

- `IngredientCalls`
- `Ingredients`
- `AssemblyExpression`
- `FinalExpression`
- `DriverDiagnostics`

### Record Usage Examples

```wl
rec = BuildAntenna[A, 3, 1, ReturnRecord -> True];
rec["Result"]
rec["Diagnostics"]
rec["IntermediateSteps"]

intRec = BuildAndIntegrateAntenna[A, 3, 0, ReturnRecord -> True];
intRec["MasterCombination"]
intRec["MasterCombinationView"]
intRec["TTerms"]
intRec["IntermediateSteps"]
```

## Internal Architecture For Modifying Routes

Users who want to extend the package, add a new branch, or change the behavior
of an existing antenna family should read the code as a profile-driven system
rather than as one long chain of direct function calls.

The shortest accurate mental model is:

```text
public API call
  -> normalize a route key {type, multiplicity, loop order}
  -> look up metadata for that key
  -> run the workflow selected by that metadata
  -> format the result into a stable public shape
```

That metadata lookup is the center of gravity of the runtime.

If you want the shortest contributor path through the codebase, start in this
order:

1. `src/core/profiles.wl`
2. `src/routes/build_workflows.wl`
3. `src/routes/integration_workflows.wl`
4. `src/interface/build_router.wl`
5. `src/interface/integration_router.wl`

That sequence shows the package in the order it actually thinks: declare route
metadata first, then define route workflows, then adapt those workflows into a
stable public API.

### Why the package is profile-centric

The package supports several antenna families that are close enough to share a
public API but different enough that they should not be forced through one
hard-coded production formula.

Examples:

- `A30` tree level is a straightforward self-interference route.
- `A40` needs a color-ordered reconstruction layer.
- `B40` and `C40` are easier to build sector by sector.
- `A21` is naturally built through a one-loop `PaVe`-style route.
- `A31` and `A22` need different extraction logic and different integration
  backends even though they are both loop-level objects.
- massive `A30` and `D30` are genuine runtime branches, but they need to carry
  explicit honesty about experimental status.

If all of those choices were written directly into the public functions, the
API layer would become a long nest of family-specific `Switch` statements and
special cases. The profile-centric design avoids that. Instead, the public and
workflow layers ask a registry:

- what family is this?
- how should it be produced?
- how should it be extracted?
- what normalization applies?
- which backend should integration use?
- which diagnostics and route story should be attached?

That design makes the code easier to audit. It also makes branch work much
safer: most modifications are localized to metadata plus one workflow, instead
of requiring invasive edits across the entire package.

### The central object: the route key

Nearly all runtime dispatch starts from a key of the form:

```wl
{type, numFinalParticles, loopOrder}
```

Typical examples are:

- `{A, 3, 0}` for `A30`
- `{A, 2, 1}` for `A21`
- `{A, 2, 2}` for `A22`
- `{B, 4, 0}` for `B40`

That key is the compact identifier passed between the public interface, the
profile registry, the route workflows, and the integration layer.

### What lives in the profile registry

The main registry lives in `src/core/profiles.wl`. It is split into a few
closely related functions.

`AntennaProfile[key]` is the main build-side metadata record. Depending on the
family, it can specify:

- a readable name such as `A30` or `C40`
- the antenna type and multiplicity
- the production mode, such as `SelfInterference`,
  `ColorOrderedAntenna`, `SectorSelfInterference`, or
  `SectorSymmetrizedInterference`
- the extraction mode, such as `BornScalar`, `TreeColorCoefficients`,
  `LoopScalar`, `LoopColorCoefficients`, or `TwoLoopTTermComponents`
- normalization data such as `ColourNorm`
- sector definitions for routes that are built from sector splits
- component and contribution lists for multi-part routes such as `A22`
- implementation-status markers for experimental branches

`AntennaReductionProfile[key]` stores build-side loop-reduction preferences.
This is separate because “how to reduce the loop object before extraction” is
not always the same question as “how to integrate the final antenna later.”

`AntennaIntegrationProfile[key]` stores integration-side routing metadata:

- default backend, usually `PaVe` or `IBP`
- basis family, when the route is basis-driven
- expansion order
- convention metadata for routes such as `A21`
- branch-specific integration status when the route is still scaffolded or
  experimental

The same registry file now also owns the canonical package convention model used
by the runtime reports. In other words, the top-level convention story is no
longer meant to live only in README prose or ad hoc report assembly; it is part
of the core metadata layer alongside the route profiles themselves.

Two further helpers live in the same file and are important to understand:

- `AntennaAmplitude[key]`
- `AntennaSelfInterference[key]`

Task 1 implementation note:

- the same metadata registry now also owns `AntennaPipelineConventionModel[]`,
  `BuildAntennaConventionProfile[...]`, and
  `IntegrationAntennaConventionProfile[...]`
- in other words, the top-level convention story is now part of the core code
  metadata layer itself, not only part of documentation prose

Task 2 implementation note:

- the runtime now also exposes `AntennaRouteEnvironmentReport[...]` as the
  companion to `AntennaRouteProfileReport[...]`
- the profile report answers “what kind of route is this?”, while the
  environment report answers “how would the current package defaults resolve if
  I called this route now?”

Task 3 implementation note:

- the metadata registry now also owns `AntennaPipelineDimRegDeclaration[]`
- the convention model consumes that declaration directly instead of storing an
  unresolved “not yet explicitly declared” placeholder
- the declaration is intentionally narrow: it records the actual
  `D -> 4 - 2 Epsilon` continuation in use without pretending that separately
  supported `CDR` / `HV` / `GDR` branches already exist

Task 4 implementation note:

- build-side route associations now carry a canonical `BuildOutputBoundary`
  subrecord with explicit `Public` and `Prototype` branches
- the default public build formatter reads only the `Public` branch, while
  records and build data keep the `Prototype` branch attached for provenance
- this does not yet mean all routes have distinct prototype physics payloads;
  on routes that have not been semantically repaired yet, the prototype branch
  may still coincide with the current route-native payload

Task 5 implementation note:

- the `A31` build route now specializes its public branch instead of exposing
  the raw extracted one-loop color decomposition as the default package result
- the public `A31` branch applies the lower-`A30` UV counterterm pattern to
  the leading and `Nf` components, while the prototype branch preserves the
  pre-counterterm route-native output for inspection
- the older route-native object/integrable flow has been restored for
  integration-facing work, so the public/default `BuildAntenna[...]` repair is
  now a build-side presentation boundary rather than a redefinition of the
  object route
- the former integrated `A31` residual has been resolved during Task `10b` by
  aligning the Appendix A.2 masters, their LiteRed phase map, and the public
  convention boundary; deferred Task `5b` work is now regression-focused

Task 6 implementation note:

- the IBP backend now has an explicit `NormalizeIBPIntegratedResult[...]`
  boundary that applies the family-dependent backend-to-public convention
  factor before epsilon-series truncation
- `IntegrateViaIBP[...]`, `IBPToSeriesWithDiagnostics[...]`, and the interface
  routing code now propagate `ApplyFeynCalcMS`, `KinematicScale`, and
  `NormalizeKinematicScale` all the way into that normalization boundary
- backend diagnostics now record the applied `"ConventionBridgeFactor"` beside
  the raw master-substituted and normalized pre-series expressions
- for `A31`, the post-repair bridge is explicitly the identity: the runtime
  master normalization already supplies the public convention, so no second
  FeynCalc-MS conversion is applied at the observable boundary
- a repeatable local verifier for this task now lives at
  `dev/verify_task6_convention_bridge.wl`; it checks the explicit A21 public
  target match and the presence of inspectable A31 convention-bridge backend
  diagnostics on the restored route-native object flow

Task 7 implementation note:

- `BuildAntenna[...]` now accepts `BuildOutputBranch -> "Public"|"Prototype"`
  as an explicit top-level selector
- the default public branch remains the stable package-facing result
- the prototype branch exposes the route-owned prototype/pre-counterterm view
  only for direct expression output, so derivation work can inspect it without
  silently changing object or integration semantics
- stored-result keys and diagnostics now record the requested
  `BuildOutputBranch`, so public and prototype replays do not collide
- `BuildAntennaObject[...]`, `ReturnAntennaObject -> True`, and
  `IntegrableForm -> True` currently reject the prototype branch on purpose,
  because those flows still define the integration-facing public contract

Task 8 implementation note:

- the package now exposes a supported package-wide defaults layer through
  `AntennaPipelineDefaults[]`, `SetAntennaPipelineDefaults[...]`, and
  `ResetAntennaPipelineDefaults[]`
- this layer works by managing the public `Options[...]` surfaces of the main
  supported entry points rather than by smuggling hidden per-call overrides
- the resulting precedence is explicit and deterministic:
  built-in defaults < package-wide user defaults < per-call options
- `AntennaPipelineDefaults[]` now also reports the built-in supported defaults
  and the currently effective supported defaults for each managed public head,
  so users can inspect which package-wide overrides are actively in force
- `AntennaPipelineConventionReport[]` and
  `AntennaRouteEnvironmentReport[...]` now both expose the active global
  defaults state, so runtime inspection and actual call behavior stay aligned

Task 10 implementation note:

- the first physics-aware validation slice now exists as a separate public
  layer through `AntennaPhysicsValidationReport[...]` and
  `RunSupportedMasslessPhysicsValidation[]`
- the current implemented family is integrated pole-structure validation for
  the supported massless integrated routes
- exact encoded targets are wired for `A21`, `A30`, `A31`, `A22`, `A40`,
  `B40`, and `C40`
- the validation layer now also includes
  `BuildRRatioPhysicsValidationReport[]`, which checks the raw SMQCD
  Laurent-series output for explicit pole cancellation and epsilon^0 agreement
  with the known public finite expression
- current Task 10 status:
  `10b` is complete. A fresh uncached `BuildRRatioPhysicsValidationReport[]`
  now returns `ValidationStatus -> Pass`, with zero pole residuals through
  epsilon^-1 and exact epsilon^0 agreement. The repair keeps direct public
  `A22` outputs paper-facing while applying only the required observable-level
  convention map during R-ratio assembly.
- `10c` status:
  done; `AntennaPhysicsValidationReport[A, 2, 2, UseStoredResults -> False]`
  now returns `ValidationStatus -> Pass`, the observed and target pole
  coefficients agree exactly for `Leading`, `Subleading`, `Nf`, and `Breve`,
  and `BuildAndIntegrateAntenna[A, 2, 2, ReturnDiagnostics -> True]` no longer
  fails on the combined route
- `10a` status:
  done as a containment/documentation step; the raw
  `BuildRRatio[..., ResultForm -> "RawDimRegSeries"]` route remains a
  diagnostic representation, now backed by an exact fresh closure check rather
  than an unresolved observable mismatch
- the validator now distinguishes a genuine comparison failure from a route
  evaluation failure, and it skips exact-target-unavailable routes by default
- the developer harness for this slice now lives at
  `dev/run_physics_validation.sh`

These lazily memoize reusable tree-level ingredients. The point is not only
speed. It also makes the source of shared Born objects explicit, so different
routes do not quietly drift toward different normalizations or “almost the same”
tree inputs.

### How build routing works

The public build functions live in `src/interface/build_router.wl`, but they do
not directly perform the physics work. Their main job is:

1. build the route key
2. collect options into a normalized association
3. ask for route data
4. format that route data into a plain result, an `AntennaObject`, diagnostics,
   or an `AntennaRunRecord`

The actual route orchestration happens in `src/routes/build_workflows.wl`.

At that layer the package asks `AntennaProfile[key]` what kind of route it is
dealing with. The crucial field is usually `Production`.

That `Production` field selects the workflow branch:

- `SelfInterference` means “build the amplitude, form the self-interference,
  then extract the antenna.”
- `ColorOrderedAntenna` means “build the full object, but also run the
  color-ordered reconstruction layer and expose its diagnostics.”
- `SectorSelfInterference` means “split the amplitude into named sectors and
  interfere only the route-relevant pieces.”
- `SectorSymmetrizedInterference` means “build the sector decomposition and
  then combine it through the symmetrized interference story required by that
  family.”

The extraction step is profile-driven too. The workflow does not hard-code one
universal “turn interference into antenna” rule. Instead it passes the raw
production object plus the profile to the extraction layer, whose behavior is
chosen by profile metadata such as `Extraction`, `ColourNorm`, components, and
contributions.

This is one of the main reasons the package is maintainable: the route layer
knows the family story, while the engine layer only has to know how to perform
one physical operation at a time.

### How integration routing works

The integration side follows the same architecture, but with a different
registry.

`IntegrateAntenna[...]` and `BuildAndIntegrateAntenna[...]` live in
`src/interface/integration_router.wl`. They consume an `AntennaObject`, recover
its key and selection metadata, and then ask `AntennaIntegrationProfile[key]`
how that object should be integrated.

That profile decides things such as:

- whether the route defaults to `PaVe` or `IBP`
- which basis family is the natural one for the route
- which expansion order is the default target
- whether a branch needs route-specific handling

The orchestration itself lives in `src/routes/integration_workflows.wl`. That
file coordinates:

- backend selection
- special-route handling such as the current massive `A30` integrated bridge
- contribution-by-contribution stitching for routes like `A22`
- backend diagnostics
- T-term construction
- final integrated-antenna extraction

The important design point is that build metadata and integration metadata are
deliberately separate. An object may be most natural to build in one symbolic
language and most natural to integrate in another. `A21` is the clearest
example: its build-side and integration-side stories are related, but not
identical, and the architecture keeps that distinction explicit.

### Why records and diagnostics matter in this design

Because the package is profile-driven, the internal data returned by each route
is association-shaped before it is turned into a public result. That is not an
accident and it is not just for debugging.

Those associations let the package carry:

- the resolved profile
- the route story
- intermediate amplitudes or interferences
- extracted components
- backend diagnostics
- component and contribution metadata
- stored-result reconstruction data

That is what makes `ReturnRecord`, `IntermediateSteps`, and diagnostics useful
without forcing the normal user-facing API to expose raw internal machinery by
default.

For branch work, this is especially valuable. When a new route is not yet
release-complete, the code can still return an honest structured record that
explains:

- what was built successfully
- what is still provisional
- where the route stopped
- whether the result is experimental, partial, or fully supported

That is exactly how the current massive `A30` and `D30` branches are kept
callable without pretending they are finished massless release routes.

### How to think about adding a new branch

The intended extension path is usually:

1. decide the new route key
2. add or extend its `AntennaProfile[key]`
3. add or extend its `AntennaIntegrationProfile[key]` if integration is needed
4. teach the build workflow how to interpret the chosen `Production` and
   `Extraction` settings
5. add any route-specific helper module if the branch is exceptional enough to
   deserve its own file
6. expose stable diagnostics and route stories
7. only then widen the public “supported” claim in the README and verification
   scripts

In practice, the easiest way to go wrong is to skip step 2 and encode branch
behavior directly in the interface layer. That usually feels faster at first,
but it weakens the architecture quickly because future readers can no longer
see the route definition in one place.

### Why this architecture is a good fit for this repository

This repository sits in an awkward but productive middle ground:

- it is not just a one-off notebook;
- it is not a generic symbolic algebra framework;
- and it is not a package where every family is physically interchangeable.

The profile-centric design is what lets it behave like a package without
flattening away the physical differences between antenna families.

It gives the codebase:

- one stable public API
- one auditable metadata layer where family-specific choices are declared
- reusable engine functions for the small symbolic operations
- route files that read like workflow stories rather than backend tangles
- an honest place to keep experimental branches inside the runtime without
  overstating their status

If you are modifying the code into new branches, that is the main principle to
preserve. Try to add new physics by teaching the registry and route layer about
the branch, not by letting branch-specific assumptions leak outward into every
public function.

### Dev Notes

The physics, the package architecture, and the profile/route design in
`AntCalc` are my own work, developed over the course of my thesis. AI coding
tools (primarily Codex/Claude Code) were used for implementation
acceleration on that design, through bug-hunting, stress-testing and drafting this
README, from my own working notes and task tracking. Concept learning and
proofreading during development also made use of general-purpose AI
assistants.
