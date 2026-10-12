"""Minimum covers of denominator signatures by Kira families, with cost-based choice and routing."""

from itertools import permutations

from .signatures import numerator_powers


def _family_key(family):
    """Lexicographic sort key for a family."""
    return [str(s) for s in family]


def _cover_key(cover):
    """Lexicographic sort key for a cover."""
    return [_family_key(f) for f in cover]


def _signature_text(signature):
    """Readable form of a signature for error messages."""
    return "{" + ", ".join(sorted(str(s) for s in signature)) + "}"


def _search_covers(targets, covers_of, covered_by, k):
    """All covers of exactly k candidate indices, found by branching on the most constrained signature."""
    found = set()
    seen = set()

    def dfs(uncovered, chosen):
        if not uncovered:
            if len(chosen) == k:
                found.add(chosen)
            return
        if len(chosen) == k or chosen in seen:
            return
        seen.add(chosen)
        pivot = min(uncovered, key=lambda D: len(covers_of[D]))
        for index in covers_of[pivot]:
            dfs(uncovered - covered_by[index], chosen | {index})

    dfs(frozenset(targets), frozenset())
    return found


def minimum_cover(signatures, candidates):
    """Every minimum-cardinality set of candidate families covering all signatures."""
    targets = sorted({frozenset(D) for D in signatures}, key=lambda D: sorted(str(s) for s in D))
    families = [tuple(f) for f in candidates]
    if not families:
        raise ValueError("No candidate families given")
    family_sets = [set(f) for f in families]

    covers_of = {D: [i for i, fs in enumerate(family_sets) if D <= fs] for D in targets}
    for D in targets:
        if not covers_of[D]:
            raise ValueError(f"No candidate family covers signature {_signature_text(D)}")

    covered_by = [frozenset(D for D in targets if D <= fs) for fs in family_sets]
    pending = [D for D in targets if D]
    if not pending:
        return sorted({(f,) for f in families}, key=_cover_key)

    k = 1
    while True:
        found = _search_covers(pending, covers_of, covered_by, k)
        if found:
            break
        k += 1

    covers = {frozenset(families[i] for i in indices) for indices in found}
    result = [tuple(sorted(cover, key=_family_key)) for cover in covers]
    return sorted(result, key=_cover_key)


def numerator_cost(signature, family, groups):
    """Total numerator power, over monomials of the signature, outside the family."""
    free = set(family)
    return sum(
        power
        for monomial in groups[signature]
        for s, power in numerator_powers(monomial).items()
        if s not in free
    )


def _covering(signature, cover):
    """Families of the cover whose invariants contain the signature."""
    return [f for f in cover if signature <= set(f)]


def choose_cover(covers, groups):
    """Cheapest cover by total numerator cost; ties broken lexicographically."""
    def cost(cover):
        total = 0
        for D in groups:
            options = _covering(D, cover)
            if not options:
                raise ValueError(f"Cover does not cover signature {_signature_text(D)}")
            total += min(numerator_cost(D, f, groups) for f in options)
        return total, _cover_key(cover)

    return tuple(min((tuple(c) for c in covers), key=cost))


def _min_cost_family(signature, cover, groups):
    """Cheapest covering family of the cover for a signature, ties lexicographic."""
    return min(_covering(signature, cover), key=lambda f: (numerator_cost(signature, f, groups), _family_key(f)))


def _order_by_counts(cover, groups):
    """Fallback ordering: most-assigned families first, then lexicographic."""
    counts = {tuple(f): 0 for f in cover}
    for D in groups:
        counts[tuple(_min_cost_family(D, cover, groups))] += 1
    return sorted(counts, key=lambda f: (-counts[f], _family_key(f)))


def _cost_table(cover, groups):
    """Numerator cost of every signature against every cover family that covers it."""
    return {(D, tuple(f)): numerator_cost(D, f, groups) for D in groups for f in _covering(D, cover)}


def _first_fit_cost(ordering, groups, table):
    """Total numerator cost when each signature is routed by first fit in the ordering."""
    return sum(table[(D, tuple(first_fit_routing(D, ordering)))] for D in groups)


def order_families(cover, groups):
    """Yaml order minimising total first-fit numerator cost; lexicographic ties."""
    families = [tuple(f) for f in cover]
    if len(families) > 7:
        return _order_by_counts(families, groups)
    table = _cost_table(families, groups)
    best = None
    for ordering in permutations(families):
        key = (_first_fit_cost(ordering, groups, table), _cover_key(ordering))
        if best is None or key < best[0]:
            best = (key, list(ordering))
    return best[1]


def first_fit_routing(signature, ordered_families):
    """First family in the given order that contains the signature."""
    for family in ordered_families:
        if signature <= set(family):
            return tuple(family)
    raise ValueError(f"No family contains signature {_signature_text(signature)}")
