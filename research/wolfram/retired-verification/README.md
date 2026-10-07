# Retired verification entrypoints

The former `../run_release_verification.wl` single-kernel smoke suite was
retired on 2026-07-21. Its only general pass condition was that a selected
call did not return `$Failed`; it did not establish physics agreement, cache
independence, or fresh-kernel state isolation.

The filename remains as a failing explanatory stub so old notes and commands
cannot produce a misleading green result. The supported release command is:

```sh
bash dev/run_release_verification.sh
```

Its per-case worker records the structural composition check and declared
validation evidence separately. Only cases with the `Validated` status can
contribute to a successful release gate.
