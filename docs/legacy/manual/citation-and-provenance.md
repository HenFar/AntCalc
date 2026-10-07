# Citation and provenance

[Manual index](index.md) · [Conventions and normalisation](conventions-and-normalisation.md) · [Documentation home](../README.md)

## AntCalc status

AntCalc is active thesis research software and does **not** yet have a preferred
scholarly citation. Its current author is Henrique Farinha (FCUL; LIP,
Phenomenology Group; [ORCID](https://orcid.org/0009-0004-2709-899X)).

The repository's [`CITATION.cff`](../../CITATION.cff) records this authorship
and release identity, but deliberately does not present AntCalc as a published
research result. When a thesis, preprint, DOI, or software release becomes the
preferred scholarly reference, this page and `CITATION.cff` should be updated
together.

Machine-readable BibTeX entries for the software and physics sources below are
available in [`docs/citations.bib`](../citations.bib).

## Software acknowledgement

AntCalc uses FeynCalc and its FeynArts/FeynHelpers environment for symbolic
amplitude work, and LiteRed2 for IBP-backed integration routes. Work using
those parts of AntCalc should cite the relevant upstream software publications:

- V. Shtabovenko, R. Mertig, and F. Orellana, *FeynCalc 10: Do multiloop
  integrals dream of computer codes?*, Computer Physics Communications 109357
  (2024), [arXiv:2312.14089](https://arxiv.org/abs/2312.14089).
- V. Shtabovenko, R. Mertig, and F. Orellana, *FeynCalc 9.3: New features and
  improvements*, Computer Physics Communications **256** (2020) 107478,
  [arXiv:2001.04407](https://arxiv.org/abs/2001.04407).
- R. N. Lee, *Presenting LiteRed: a tool for the Loop InTEgrals REDuction*,
  [arXiv:1212.2685](https://arxiv.org/abs/1212.2685).
- R. N. Lee, *LiteRed 1.4: a powerful tool for the reduction of the multiloop
  integrals*, Journal of Physics: Conference Series **523** (2014) 012059,
  [arXiv:1310.1145](https://arxiv.org/abs/1310.1145).

Use the upstream projects' current citation guidance as authoritative if it
changes. This list identifies the software provenance relevant to AntCalc; it
does not replace citation requirements imposed by FeynArts, FeynHelpers,
Package-X, or other tools used in a particular calculation.

## Physics and master-integral provenance

The following sources are the principal antenna and master-integral references
used by the current route/provenance documentation. A route's public result is
not automatically a transcription of any listed expression: AntCalc keeps
runtime derivation, normalisation, and literature comparison distinct.

- A. Gehrmann-De Ridder, T. Gehrmann, and E. W. N. Glover, *Antenna
  Subtraction at NNLO*, JHEP **09** (2005) 056,
  [arXiv:hep-ph/0505111](https://arxiv.org/abs/hep-ph/0505111).
- A. Gehrmann-De Ridder, T. Gehrmann, and E. W. N. Glover, *Infrared Structure
  of e⁺e⁻ → 2 jets at NNLO*, Nuclear Physics B **691** (2004) 195–222,
  [arXiv:hep-ph/0403057](https://arxiv.org/abs/hep-ph/0403057).
- A. Gehrmann-De Ridder, T. Gehrmann, and G. Heinrich, *Four-Particle Phase
  Space Integrals in Massless QCD*, Nuclear Physics B **682** (2004) 265–288,
  [arXiv:hep-ph/0311276](https://arxiv.org/abs/hep-ph/0311276).
- A. Gehrmann-De Ridder and M. Ritzmann, *NLO Antenna Subtraction with Massive
  Fermions*, JHEP **07** (2009) 041,
  [arXiv:0904.3297](https://arxiv.org/abs/0904.3297).

For route-specific use, consult [runtime masters and literature
provenance](../development/runtime-masters-and-provenance.md),
[route status](route-status.md), and the diagnostics/record provenance attached
by the relevant integration route.
