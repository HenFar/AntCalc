import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))

import dataclasses
import tempfile
import unittest

from antcalc import integrate_kira as kira
from antcalc.family_generation import pipeline

MONOMIALS = {"A30": 9, "B40": 103, "C40": 249, "A40": 1779}


def make_run(antenna, multiplicity, loop_order=0):
    return kira.IntegrationRun(
        antenna_family=antenna,
        multiplicity=multiplicity,
        loop_order=loop_order,
        auto_input_path=True,
        manual_input_path=Path("."),
        substitute_masters=False,
    )


class GenerateEndToEndTest(unittest.TestCase):
    def _check_antenna(self, antenna, multiplicity, n_families, n_covers, reconstruct=False):
        label = f"{antenna}{multiplicity}0"
        run = make_run(antenna, multiplicity)
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / f"test_{label}" / "integralfamilies.yaml"
            self._run_checks(run, path, label, multiplicity, n_families, n_covers, reconstruct)

    def _run_checks(self, run, path, label, multiplicity, n_families, n_covers, reconstruct):
        result = pipeline.generate_families(run, path)
        names = [family["name"] for family in result.families]

        self.assertTrue(path.exists())
        self.assertEqual(Path(result.path), path)
        self.assertEqual(len(result.families), n_families)
        self.assertEqual(names, [f"basis{i}" for i in range(1, n_families + 1)])
        self.assertEqual(result.n_monomials, MONOMIALS[label])
        self.assertEqual(result.dependent_signatures, [])
        self.assertEqual(result.n_candidates, 3 if multiplicity == 3 else 162)
        self.assertEqual(result.n_optimal_covers, n_covers)
        self.assertLessEqual(set(result.assignment.values()), set(names))

        coverage = pipeline.check_coverage(run, path)
        self.assertTrue(coverage["ok"])
        self.assertIsNone(coverage["error"])
        self.assertGreater(coverage["n_integrands"], 0)
        self.assertLessEqual(coverage["families_used"], set(names))

        generated = dataclasses.replace(run, families_path=path)
        families_list, _ = kira.kira_integral_families(generated, kira.build_kinematics(multiplicity))
        n_props = len(result.families[0]["propagators"])
        masters = f"basis1({','.join(['1'] * 4 + ['0'] * (n_props - 4))})"
        match = kira.masters_pattern(families_list).search(masters)
        self.assertIsNotNone(match)
        self.assertEqual(match.group(1), masters)
        if reconstruct:
            self.assertIs(pipeline.check_reconstruction(run, path), True)

    def test_a30_end_to_end(self):
        self._check_antenna("A", 3, n_families=1, n_covers=1, reconstruct=True)

    def test_b40_end_to_end(self):
        self._check_antenna("B", 4, n_families=1, n_covers=12, reconstruct=True)

    def test_c40_end_to_end(self):
        self._check_antenna("C", 4, n_families=1, n_covers=1)

    def test_a40_end_to_end(self):
        self._check_antenna("A", 4, n_families=5, n_covers=2)


class CompareWithHandwrittenTest(unittest.TestCase):
    def test_a40_comparison_numbers(self):
        run = make_run("A", 4)
        handwritten = kira.TEMPLATES_DIR / "A40" / "config" / "integralfamilies.yaml"
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "test_A40" / "integralfamilies.yaml"
            pipeline.generate_families(run, path)
            report = pipeline.compare_with_handwritten(run, path, handwritten)
        self.assertEqual(report["hand_families"], 72)
        self.assertEqual(report["gen_families"], 5)
        self.assertEqual(report["hand_distinct"], 653)
        self.assertEqual(report["gen_distinct"], 587)
        self.assertEqual(report["hand_max_dots"], 2)
        self.assertEqual(report["gen_max_dots"], 2)
        self.assertEqual(report["hand_max_s"], 3)
        self.assertEqual(report["gen_max_s"], 3)


if __name__ == "__main__":
    unittest.main()
