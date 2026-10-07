## Paper numerator-master bridge

This script is the first honest bridge step between the literature master
basis and the package runtime basis.

### What it fixes conceptually

The paper uses a second master of numerator type, while the package currently
uses a dotted LiteRed basis master. The missing proof is the IBP basis-change
relation between those two descriptions.

### What this script does

1. identifies the natural reverse-unitarity representatives for the paper
   numerator master in the `MX30Basis123` language;
2. prints the current provisional paper-to-runtime basis relation implied by
   the already validated integrated target match;
3. records the explicit `jRules` plus `ZerojRule` reduction of the numerator
   representative into the two MX30 masters;
4. attempts a direct `Solvej` reduction of the negative-index representatives.

### Why this is useful even before the final reduction works

It makes the remaining gap precise:

- we now know exactly which numerator-sector objects should reduce;
- we now have the explicit basis relation obtained from the generated rules;
- the remaining technical gap is narrower: making the direct negative-sector
  `Solvej` path work cleanly, not discovering the relation from scratch.
