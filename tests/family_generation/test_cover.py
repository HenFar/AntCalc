import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))

import itertools
import unittest

import sympy as sp

from antcalc import integrate_kira as kira
from antcalc.family_generation import cover, signatures

A, B, C, D, E, F = sp.symbols("a b c d e f")
Z = sp.Symbol("z")
S12, S13, S23 = sp.symbols("s12 s13 s23")
REAL_COVER_CASES = [
    ("A", 3, 1, 1),
    ("B", 4, 12, 1),
    ("C", 4, 1, 1),
    ("A", 4, 2, 5),
]


def make_run(antenna, multiplicity, loop_order=0):
    return kira.IntegrationRun(
        antenna_family=antenna,
        multiplicity=multiplicity,
        loop_order=loop_order,
        auto_input_path=True,
        manual_input_path=Path("."),
        substitute_masters=False,
    )


def _routed_cost(order, groups):
    total = 0
    for signature, monomials in groups.items():
        family = next(f for f in order if signature <= set(f))
        for _, powers in monomials:
            total += sum(p for inv, p in powers.items() if p > 0 and inv != kira.q2 and inv not in family)
    return total


def _brute_force_order(cover_families, groups):
    best = min(
        itertools.permutations(cover_families),
        key=lambda order: (_routed_cost(order, groups), [[str(s) for s in f] for f in order]),
    )
    return list(best)


class MinimumCoverTest(unittest.TestCase):
    def test_empty_signature_is_covered_by_any_candidate(self):
        sigs = [frozenset(), frozenset({A, B})]
        candidates = [(A, B), (C, D)]
        self.assertEqual(cover.minimum_cover(sigs, candidates), [((A, B),)])

    def test_greedy_trap_still_finds_true_minimum(self):
        # Greedy would take the 4-element set first and then need 3 more sets.
        sigs = [frozenset({s}) for s in (A, B, C, D, E, F)]
        candidates = [(A, B, D, E), (A, B, C), (D, E, F), (A, C, E), (B, D, F)]
        self.assertEqual(
            cover.minimum_cover(sigs, candidates),
            [((A, B, C), (D, E, F)), ((A, C, E), (B, D, F))],
        )

    def test_exactly_two_optimal_covers_are_both_returned(self):
        sigs = [frozenset({s}) for s in (A, B, C, D)]
        candidates = [(A, B), (C, D), (A, C), (B, D)]
        covers = cover.minimum_cover(sigs, candidates)
        self.assertEqual(len(covers), 2)
        self.assertEqual(covers, [((A, B), (C, D)), ((A, C), (B, D))])

    def test_no_candidates_raises(self):
        with self.assertRaises(ValueError):
            cover.minimum_cover([frozenset({A})], [])

    def test_empty_signature_without_candidates_raises(self):
        with self.assertRaises(ValueError):
            cover.minimum_cover([frozenset()], [])

    def test_uncoverable_signature_raises_naming_it(self):
        sigs = [frozenset({A}), frozenset({Z})]
        with self.assertRaises(ValueError) as ctx:
            cover.minimum_cover(sigs, [(A, B)])
        self.assertIn("z", str(ctx.exception))

    def test_n3_spec_example(self):
        sigs = [frozenset(), frozenset({S13}), frozenset({S23}), frozenset({S13, S23})]
        candidates = [(S12, S13), (S12, S23), (S13, S23)]
        self.assertEqual(cover.minimum_cover(sigs, candidates), [((S13, S23),)])


class NumeratorCostTest(unittest.TestCase):
    def test_numerator_outside_family_is_counted(self):
        groups = {frozenset({S13}): [(1, {S12: 2, S13: -1})]}
        self.assertEqual(cover.numerator_cost(frozenset({S13}), (S13, S23), groups), 2)

    def test_numerator_inside_family_costs_nothing(self):
        groups = {frozenset({S13}): [(1, {S12: 2, S13: -1})]}
        self.assertEqual(cover.numerator_cost(frozenset({S13}), (S12, S13), groups), 0)


class ChooseCoverTest(unittest.TestCase):
    def test_lower_numerator_cost_wins(self):
        groups = {frozenset({A}): [(1, {A: -1, D: 1})]}
        cover_with_d_outside = ((A, B, C),)
        cover_with_d_inside = ((A, D, E),)
        self.assertEqual(
            cover.choose_cover([cover_with_d_outside, cover_with_d_inside], groups),
            cover_with_d_inside,
        )

    def test_ties_break_lexicographically_regardless_of_order(self):
        groups = {frozenset({s}): [(1, {s: -1})] for s in (A, B, C, D)}
        first = ((A, B), (C, D))
        second = ((A, C), (B, D))
        for permutation in itertools.permutations([second, first]):
            with self.subTest(order=permutation):
                self.assertEqual(cover.choose_cover(list(permutation), groups), first)

    def test_order_families_matches_brute_force_optimum(self):
        # Ordering [(A,B),(A,C)] routes {A} to (A,B) (no numerator), the other order costs 1.
        groups = {frozenset({A}): [(1, {A: -1, B: 1})]}
        cover_families = [(A, C), (A, B)]
        ordered = cover.order_families(cover_families, groups)
        self.assertEqual(ordered, _brute_force_order(cover_families, groups))
        self.assertEqual(ordered, [(A, B), (A, C)])

    def test_first_fit_routing_picks_first_containing_family(self):
        ordered = [(B, C, D), (A, B), (A, C)]
        self.assertEqual(cover.first_fit_routing(frozenset({A}), ordered), (A, B))
        self.assertEqual(cover.first_fit_routing(frozenset({A, C}), ordered), (A, C))
        self.assertEqual(cover.first_fit_routing(frozenset({B, C}), ordered), (B, C, D))


class RealDataCoverTest(unittest.TestCase):
    def test_minimum_cover_sizes_and_counts_per_antenna(self):
        for antenna, multiplicity, n_covers, size in REAL_COVER_CASES:
            with self.subTest(antenna=antenna, multiplicity=multiplicity):
                kinematics = kira.build_kinematics(multiplicity)
                groups = signatures.group_by_signature(
                    signatures.load_monomials(make_run(antenna, multiplicity))
                )
                candidates = signatures.candidate_families(kinematics)
                covers = cover.minimum_cover(list(groups), candidates)
                self.assertEqual(len(covers), n_covers)
                for optimal in covers:
                    self.assertEqual(len(optimal), size)
                    for sig in groups:
                        self.assertTrue(any(sig <= set(family) for family in optimal))


if __name__ == "__main__":
    unittest.main()
