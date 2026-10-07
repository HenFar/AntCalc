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

`MassiveA30IntegratedCutMeasureConsistencyReport[]` now infers the one
possible common paper-phase-space-to-LiteRed-cut factor independently from
the undotted and dotted coefficients, before any master values are inserted.
The direct substitution may only be activated if its `MatchQ` is `True` and
that factor is tied to a declared cut-measure convention.  This prevents a
target-solved dotted master from being relabelled as a first-principles basis
conversion.

The gate now passes exactly: both determinations give
`C_cut = -1/4`.  The active runtime rules are consequently
`j11100 = -4 I1` and `j21100 = -4 (I2 - a I1)/b`, where `a` and `b` are the
explicit numerator-reduction coefficients.  No dotted master is solved from
the final integrated antenna.

### Dimensional numerator requirement

The consistency test also guards against an apparently harmless but fatal
shortcut: projecting the reconstructed massive antenna to `Epsilon -> 0`
before the reverse-unitarity reduction.  That projection reproduces the
four-dimensional paper antenna, but it cannot reproduce the all-epsilon
integrated masters.  The public massive build therefore retains the
d-dimensional FeynCalc numerator and uses the paper expression only as an
`Epsilon -> 0` validation target.
