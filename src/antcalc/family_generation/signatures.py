"""Monomials of an unintegrated antenna, their denominator signatures and candidate Kira families."""

from collections import defaultdict
from itertools import combinations
from math import comb

import sympy as sp

if __package__.partition(".")[0] == "antcalc":
    from .. import integrate_kira as kira
else:
    import integrate_kira as kira

q2 = kira.q2
MAX_CANDIDATES = 10**6


def load_monomials(run):
    """Union of the monomials of every component of the unintegrated antenna."""
    kin = kira.build_kinematics(run.multiplicity)
    known = set(kin.invariants) | {q2}
    monomials = []

    for component in kira.read_input(kira.get_input_path(run)):
        for monomial in kira.read_to_dict_tuple((component,), kin.invariants):
            stray = sp.sympify(monomial[0]).free_symbols - {q2, kira.d}
            if stray:
                raise ValueError(f"Symbols {sorted(map(str, stray))} in coefficient are not invariants of multiplicity {run.multiplicity}: {monomial}")
            unknown = set(monomial[1]) - known
            if unknown:
                raise ValueError(f"Unknown invariants {sorted(map(str, unknown))} in monomial {monomial}")
            non_integer = [s for s, power in monomial[1].items() if not isinstance(power, (int, sp.Integer))]
            if non_integer:
                raise ValueError(f"Non-integer powers for {sorted(map(str, non_integer))} in monomial {monomial}")
            monomials.append(monomial)

    return tuple(monomials)


def denominator_signature(monomial):
    """Set of non-q2 invariants appearing with negative power."""
    return frozenset(s for s, power in monomial[1].items() if power < 0 and s != q2)


def numerator_powers(monomial):
    """Non-q2 invariants appearing with positive power, with their powers."""
    return {s: power for s, power in monomial[1].items() if power > 0 and s != q2}


def group_by_signature(monomials):
    """Group monomials by their denominator signature."""
    groups = defaultdict(list)
    for monomial in monomials:
        groups[denominator_signature(monomial)].append(monomial)
    return dict(groups)


def count_propagators(multiplicity):
    """Return (N, F): total propagators and free invariants of the family."""
    loops = multiplicity - 1
    total = loops * (loops + 1) // 2 + loops
    return total, total - multiplicity


def is_independent(invariants, kinematics):
    """True if q2 and the given invariants are linearly independent over the integers."""
    rows = [list(kinematics.invariant_vectors[q2])]
    rows += [list(kinematics.invariant_vectors[s]) for s in invariants]
    return sp.Matrix(rows).rank() == len(rows)


def find_dependent_signatures(signatures, kinematics):
    """Signatures whose invariants are dependent together with q2, in deterministic order."""
    dependent = [D for D in set(signatures) if not is_independent(D, kinematics)]
    return sorted(dependent, key=lambda D: sorted(str(s) for s in D))


def candidate_families(kinematics):
    """All independent free-invariant sets of the family size, sorted lexicographically."""
    pool = tuple(kinematics.invariants)
    _, size = count_propagators(kinematics.multiplicity)
    if comb(len(pool), size) > MAX_CANDIDATES:
        raise ValueError(f"Too many candidate families: C({len(pool)}, {size}) exceeds {MAX_CANDIDATES}")

    families = [
        tuple(sorted(subset, key=sp.default_sort_key))
        for subset in combinations(pool, size)
        if is_independent(subset, kinematics)
    ]
    return sorted(families, key=lambda f: [str(s) for s in f])
