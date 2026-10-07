# AntCalc documentation

Choose the page that matches the task. The manual explains supported use; the
reference defines functions and options; the developer pages describe internal
design and maintenance.

| If you want to… | Start here |
|---|---|
| run the Python / FORM / Kira integration workflow | [Kira workflow guide](manual/kira-workflow.md) |
| inspect invariant mapping, Kira reduction closure, or analytic substitution | [Kira pipeline internals](development/kira-integration.md) |
| install, load, and use a supported route | [Manual](manual/index.md) |
| look up a function, option, record field, or return form | [Reference guide](reference/README.md) |
| understand route architecture, runtime masters, or maintenance rules | [Developer documentation](development/README.md) |
| follow a runnable narrative workflow | [Tutorials](tutorials/README.md) |
| understand software and physics-source acknowledgement | [Citation and provenance](manual/citation-and-provenance.md) |
| see how the former README was redistributed | [Migration ledger](migration-status.md) |

The repository-level [README](../README.md) gives a short introduction.
AntCalc 0.3.5 uses the Python runcard runner as its main entry point. Its
version is independent of the legacy Wolfram paclet. The Kira guides describe
the current integration path; the function reference documents the retained
Wolfram API and its own support scope.
[dev/README_old.md](../dev/README_old.md) is archived development material.
