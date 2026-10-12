"""Kira family dictionaries, propagator momenta and rendering of integralfamilies yaml."""

from itertools import combinations
from pathlib import Path

import sympy as sp

from .signatures import count_propagators

PROPAGATOR_COLUMN = 53   # column of the "#" comment, as in kira/templates/A40


def invariant_subset(invariant):
    """Particle labels of an invariant: s134 -> (1, 3, 4)."""
    return tuple(int(digit) for digit in str(invariant)[1:])


def propagator_momentum(subset, multiplicity):
    """Kira momentum string whose square is the invariant s_subset."""
    if multiplicity not in subset:
        return "+".join(f"p{i}" for i in subset)
    complement = [i for i in range(1, multiplicity) if i not in subset]
    return "".join(f"-p{i}" for i in complement) + "+q"


def cut_momenta(multiplicity):
    """Momentum strings of the n cut propagators: p1..p_{n-1} and (q-p1-...-p_{n-1})."""
    loops = [f"p{i}" for i in range(1, multiplicity)]
    return loops + ["-" + "-".join(loops) + "+q"]


def build_family(name, free_invariants, multiplicity):
    """Kira family dict: cut propagators first, then the free invariants in the given order."""
    free = [propagator_momentum(invariant_subset(inv), multiplicity) for inv in free_invariants]
    total, _ = count_propagators(multiplicity)
    return {
        "name": name,
        "loop_momenta": [f"p{i}" for i in range(1, multiplicity)],
        "top_level_sectors": [2 ** total - 1],
        "cut_propagators": list(range(1, multiplicity + 1)),
        "propagators": [[momentum, 0] for momentum in cut_momenta(multiplicity) + free],
    }


def family_name(index):
    """Family name for the 1-based index: basis1, basis2, ..."""
    return f"basis{index}"


def _invariant_labels(multiplicity):
    """Map each free propagator momentum string to its invariant name."""
    labels = {}
    for size in range(2, multiplicity):
        for subset in combinations(range(1, multiplicity + 1), size):
            labels[propagator_momentum(subset, multiplicity)] = "s" + "".join(map(str, subset))
    return labels


def render_yaml(families, header_lines):
    """Render Kira integralfamilies yaml in the layout of the hand-written A40 template."""
    lines = [line if line.startswith("#") else f"# {line}" for line in header_lines]
    lines.append("integralfamilies:")
    for family in families:
        multiplicity = len(family["loop_momenta"]) + 1
        labels = _invariant_labels(multiplicity)
        cuts = set(family["cut_propagators"])
        lines.append(f'  - name: "{family["name"]}"')
        lines.append(f"    loop_momenta: [{', '.join(family['loop_momenta'])}]")
        lines.append(f"    top_level_sectors: [{', '.join(map(str, family['top_level_sectors']))}]")
        lines.append(f"    cut_propagators: [{', '.join(map(str, family['cut_propagators']))}]")
        lines.append("    propagators:")
        for position, (momentum, _) in enumerate(family["propagators"], start=1):
            label = "cut" if position in cuts else labels.get(momentum, momentum)
            entry = f'      - ["{momentum}", 0]'
            lines.append(f"{entry.ljust(PROPAGATOR_COLUMN)}#{position}  {label}")
    return "\n".join(lines) + "\n"


def write_integralfamilies(text, output_path):
    """Write yaml text to output_path, creating parent directories, and return the path."""
    path = Path(output_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path
