import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))

import dataclasses
import unittest

import sympy as sp
import yaml

from antcalc import integrate_kira as kira
from antcalc.family_generation import signatures

Q2 = kira.q2
S12, S13, S14, S23, S24, S34 = sp.symbols("s12 s13 s14 s23 s24 s34")
S123, S124, S134, S234 = sp.symbols("s123 s124 s134 s234")
KIN3 = kira.build_kinematics(3)
KIN4 = kira.build_kinematics(4)
REAL_DATA = [("A", 3, 9, 4), ("B", 4, 103, 6), ("C", 4, 249, 16), ("A", 4, 1779, 76)]


def make_run(antenna, multiplicity, loop_order=0, auto=True, manual="."):
    return kira.IntegrationRun(
        antenna_family=antenna,
        multiplicity=multiplicity,
        loop_order=loop_order,
        auto_input_path=auto,
        manual_input_path=Path(manual),
        substitute_masters=False,
    )


class DenominatorSignatureTest(unittest.TestCase):
    def test_negative_powers_form_signature(self):
        monomial = (2 / Q2, {S12: 2, S13: -1, S23: -1})
        self.assertEqual(signatures.denominator_signature(monomial), frozenset({S13, S23}))

    def test_q2_is_excluded_from_signature(self):
        monomial = (sp.Integer(1), {Q2: -1, S13: -1})
        self.assertEqual(signatures.denominator_signature(monomial), frozenset({S13}))

    def test_constant_has_empty_signature(self):
        self.assertEqual(signatures.denominator_signature((sp.Integer(3), {})), frozenset())

    def test_positive_powers_form_numerator(self):
        monomial = (2 / Q2, {S12: 2, S13: -1, S23: -1})
        self.assertEqual(signatures.numerator_powers(monomial), {S12: 2})

    def test_numerator_excludes_q2_and_denominators(self):
        monomial = (sp.Integer(1), {Q2: 1, S13: -1})
        self.assertEqual(signatures.numerator_powers(monomial), {})


class GroupBySignatureTest(unittest.TestCase):
    def test_monomials_grouped_by_denominator_signature(self):
        monomials = [
            (1, {S13: -1}),
            (2, {S13: -1, S12: 1}),
            (3, {S23: -1}),
            (4, {}),
        ]
        groups = signatures.group_by_signature(monomials)
        self.assertEqual(set(groups), {frozenset({S13}), frozenset({S23}), frozenset()})
        self.assertCountEqual(groups[frozenset({S13})], [monomials[0], monomials[1]])
        self.assertEqual(groups[frozenset()], [monomials[3]])


class CountPropagatorsTest(unittest.TestCase):
    def test_counts_for_three_four_five_partons(self):
        self.assertEqual(signatures.count_propagators(3), (5, 2))
        self.assertEqual(signatures.count_propagators(4), (9, 5))
        self.assertEqual(signatures.count_propagators(5), (14, 9))


class IsIndependentTest(unittest.TestCase):
    def test_n3_pair_invariants_are_independent(self):
        self.assertTrue(signatures.is_independent([S13, S23], KIN3))

    def test_n3_single_invariant_is_independent(self):
        self.assertTrue(signatures.is_independent([S12], KIN3))

    def test_n3_all_three_invariants_are_dependent(self):
        # s12 + s13 + s23 = q2, so the set with q2 has rank 3 < 4.
        self.assertFalse(signatures.is_independent([S12, S13, S23], KIN3))

    def test_empty_set_is_independent(self):
        self.assertTrue(signatures.is_independent([], KIN3))

    def test_n4_four_triples_are_dependent(self):
        # Each of the six pairs lies in exactly two of the four triples, so
        # s123 + s124 + s134 + s234 = 2 q2: q2 is in their span and five vectors have rank 4.
        self.assertFalse(signatures.is_independent([S123, S124, S134, S234], KIN4))

    def test_n4_triple_is_sum_of_pair_triples_dependent(self):
        # s123 = s12 + s13 + s23 as vectors, so the set with q2 has rank 4 < 5.
        self.assertFalse(signatures.is_independent([S12, S13, S23, S123], KIN4))

    def test_duplicated_invariant_is_dependent(self):
        # Repeated vector: rank of [q2, s12, s12] is 2 < 3.
        self.assertFalse(signatures.is_independent([S12, S12], KIN4))

    def test_n4_three_triples_are_independent(self):
        # p23, p24, p34 each appear in one triple only, so the three triples are independent.
        # q2 in their span would need coefficient 1 on each of p23, p24, p34, which gives
        # coefficient 2 on p12 (not 1), so q2 is not in the span.
        self.assertTrue(signatures.is_independent([S123, S124, S134], KIN4))


class FindDependentSignaturesTest(unittest.TestCase):
    def test_reports_n3_triple_with_q2(self):
        sigs = [frozenset({S12, S13, S23}), frozenset({S13, S23})]
        self.assertEqual(
            signatures.find_dependent_signatures(sigs, KIN3),
            [frozenset({S12, S13, S23})],
        )

    def test_reports_n4_dependent_four_triples(self):
        sigs = [frozenset({S123, S124, S134}), frozenset({S123, S124, S134, S234})]
        self.assertEqual(
            signatures.find_dependent_signatures(sigs, KIN4),
            [frozenset({S123, S124, S134, S234})],
        )

    def test_two_dependent_signatures_reported_deterministically(self):
        dependent_a = frozenset({S12, S13, S23, S123})
        dependent_b = frozenset({S123, S124, S134, S234})
        sigs = [dependent_a, frozenset({S13, S23}), dependent_b]
        forward = signatures.find_dependent_signatures(sigs, KIN4)
        backward = signatures.find_dependent_signatures(list(reversed(sigs)), KIN4)
        self.assertEqual(forward, backward)
        self.assertCountEqual(forward, [dependent_a, dependent_b])

    def test_no_dependent_signatures_gives_empty_list(self):
        sigs = [frozenset({S13, S23}), frozenset()]
        self.assertEqual(signatures.find_dependent_signatures(sigs, KIN3), [])


class CandidateFamiliesTest(unittest.TestCase):
    def test_n3_has_exactly_three_candidates(self):
        self.assertEqual(
            signatures.candidate_families(KIN3),
            [(S12, S13), (S12, S23), (S13, S23)],
        )

    def test_n4_has_162_candidates_of_size_five_all_independent(self):
        candidates = signatures.candidate_families(KIN4)
        self.assertEqual(len(candidates), 162)
        self.assertEqual(len({tuple(c) for c in candidates}), 162)
        for family in candidates:
            self.assertEqual(len(family), 5)
            self.assertTrue(signatures.is_independent(list(family), KIN4))

    def test_each_candidate_sorted_by_default_sort_key(self):
        for family in signatures.candidate_families(KIN4):
            self.assertEqual(tuple(sorted(family, key=sp.default_sort_key)), family)

    def test_candidates_sorted_lexicographically_by_string(self):
        candidates = signatures.candidate_families(KIN4)
        as_text = [[str(s) for s in family] for family in candidates]
        self.assertEqual(as_text, sorted(as_text))

    def test_oversized_pool_raises(self):
        # n=5: C(25, 9) = 2042975 > 10**6
        with self.assertRaises(ValueError):
            signatures.candidate_families(kira.build_kinematics(5))


class RealDataTest(unittest.TestCase):
    def test_load_monomials_and_groups_match_expected_counts(self):
        for antenna, multiplicity, n_monomials, n_signatures in REAL_DATA:
            with self.subTest(antenna=antenna, multiplicity=multiplicity):
                monomials = signatures.load_monomials(make_run(antenna, multiplicity))
                groups = signatures.group_by_signature(monomials)
                self.assertEqual(len(monomials), n_monomials)
                self.assertEqual(len(groups), n_signatures)

    def test_all_real_signatures_are_independent(self):
        for antenna, multiplicity, _, _ in REAL_DATA:
            with self.subTest(antenna=antenna, multiplicity=multiplicity):
                kinematics = kira.build_kinematics(multiplicity)
                groups = signatures.group_by_signature(
                    signatures.load_monomials(make_run(antenna, multiplicity))
                )
                self.assertEqual(signatures.find_dependent_signatures(list(groups), kinematics), [])


class UnknownInvariantTest(unittest.TestCase):
    def test_coefficient_with_unknown_symbol_raises(self):
        # unintegratedA40.m holds n=4 invariants (e.g. s1234-type symbols), unknown to n=3 kinematics.
        run = make_run("A", 3, auto=False, manual="results/unintegrated/unintegratedA40.m")
        with self.assertRaises(ValueError):
            signatures.load_monomials(run)


class HandWrittenA40Test(unittest.TestCase):
    def test_hand_written_a40_free_invariants_are_independent(self):
        handwritten = kira.TEMPLATES_DIR / "A40" / "config" / "integralfamilies.yaml"
        families = yaml.safe_load(handwritten.read_text())
        run = dataclasses.replace(make_run("A", 4), families_path=handwritten)
        families_list, _ = kira.kira_integral_families(run, KIN4)
        self.assertEqual(len(families_list), len(families["integralfamilies"]))
        for name, free in families_list:
            with self.subTest(family=name):
                self.assertEqual(len(free), 5)
                self.assertTrue(signatures.is_independent(list(free), KIN4))


if __name__ == "__main__":
    unittest.main()
