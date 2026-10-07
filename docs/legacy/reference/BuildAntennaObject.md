# `BuildAntennaObject`

[Reference index](README.md) · [`BuildAntenna`](BuildAntenna.md) · [Documentation home](../README.md)

```wl
BuildAntennaObject[type, numFinalParticles, loopOrder, opts]
```

Builds an `AntennaObject[...]` for direct use with
[`IntegrateAntenna`](IntegrateAntenna.md). It is the explicit object-building
form of the modular workflow:

```wl
obj = BuildAntennaObject[A, 3, 0];
result = IntegrateAntenna[obj];
```

It accepts the build controls of [`BuildAntenna`](BuildAntenna.md), except for
`ReturnRecord`, `ReturnBuildData`, and `ReturnAntennaObject`. It always uses
the public build branch. Prototype output is not available in an object for
public integration.

For most ordinary workflows,

```wl
BuildAntenna[A, 3, 0, IntegrableForm -> True]
```

is the shorter build-to-integrate call. Use `BuildAntennaObject` when you need
one full object for orchestration or inspection.
