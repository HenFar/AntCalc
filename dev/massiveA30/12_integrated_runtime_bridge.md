## Integrated bridge note

This check is the current acceptance gate for the integrated massive `A30`
provenance layer.

### What it checks

1. load the encoded paper target from `dev/massiveA30_sources/integrated.wl`;
2. apply the explicit paper-to-package bridge;
3. load the actual current package master combination from
   `BuildAndIntegrateAntenna[A,3,0,quarkMass->mQ,ReturnRecord->True]`;
4. identify the undotted runtime master with the bridged paper
   `I1^(m,0,m)` master;
5. solve the dotted runtime master against the bridged integrated target;
6. verify that the substituted runtime combination reproduces the bridged
   target exactly.

### What failed before

- the older `MX30I1` and `MX30I2` trial files only enforced the massless
  limit and a derivative-style dotted-master guess;
- that was not enough to reproduce the actual integrated massive
  literature target;
- the paper second master is a numerator master, while the package second
  master is a dotted LiteRed basis master, so a direct identification was
  incorrect.

### What changed

- the exact paper target is now encoded explicitly;
- the target-level normalization bridge is explicit and separate;
- the runtime second master is now marked honestly as a provisional
  bridge-derived object rather than a proven literature master.

### Direct-basis promotion gate

The paper master `I2^(m,0,m)` is the `s_ij`-weighted antenna phase-space
integral.  With the paper's `(i,j,k)=(1,3,2)` ordering, the corresponding
`MX30Basis123` reverse-unitarity representative is
`-j[MX30Basis123,1,1,1,-1,0]`.  Its reduction to the undotted and dotted
`MX30` masters is explicit.

`MassiveA30IntegratedCutMeasureConsistencyReport[]` compares the effective
paper-to-runtime master conversion from the undotted and dotted coefficients
before substituting master values. Its ratio includes the overall antenna
normalization; LiteRed's `CutDs` flags do not independently define a cut
measure.

The earlier ratio `C_cut = +1/4` was found while the unintegrated expression
was missing the explicit numerator factor `4` in paper Eq. (3.1). Scaling the
build-side integrand by four therefore predicts `C_eff = 1`; the active rules
use `j11100 = I1` and `j21100 = (I2 - a I1)/b`, where `a` and `b` are the
explicit numerator-reduction coefficients. Rerun the coefficient and
integrated-target checks before treating the corrected bridge as validated.
No dotted master is solved from the final integrated antenna.

### Dimensional numerator requirement

The consistency test also guards against an apparently harmless but fatal
shortcut: projecting the reconstructed massive antenna to `Epsilon -> 0`
before the reverse-unitarity reduction.  That projection reproduces the
four-dimensional paper antenna, but it cannot reproduce the all-epsilon
integrated masters.  The public massive build therefore retains the
d-dimensional FeynCalc numerator and uses the paper expression only as an
`Epsilon -> 0` validation target.
