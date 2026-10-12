import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))

import re
import tempfile
import unittest

import sympy as sp
import yaml

from antcalc import integrate_kira as kira
from antcalc.family_generation import kira_yaml

PROPAGATOR_LINE = re.compile(r'^      - \["[^"]+", 0\] +#\d+', re.MULTILINE)
A40_YAML = kira.TEMPLATES_DIR / "A40" / "config" / "integralfamilies.yaml"
S12, S13, S14, S23, S34 = sp.symbols("s12 s13 s14 s23 s34")
S123, S234 = sp.symbols("s123 s234")
S13_S23 = (S13, S23)


class InvariantSubsetTest(unittest.TestCase):
    def test_digits_of_invariant_name(self):
        self.assertEqual(kira_yaml.invariant_subset(sp.Symbol("s134")), (1, 3, 4))
        self.assertEqual(kira_yaml.invariant_subset(sp.Symbol("s12")), (1, 2))


class PropagatorMomentumTest(unittest.TestCase):
    def test_n3_examples(self):
        self.assertEqual(kira_yaml.propagator_momentum((1, 2), 3), "p1+p2")
        self.assertEqual(kira_yaml.propagator_momentum((1, 3), 3), "-p2+q")
        self.assertEqual(kira_yaml.propagator_momentum((2, 3), 3), "-p1+q")

    def test_n4_examples(self):
        self.assertEqual(kira_yaml.propagator_momentum((1, 2), 4), "p1+p2")
        self.assertEqual(kira_yaml.propagator_momentum((1, 2, 3), 4), "p1+p2+p3")
        self.assertEqual(kira_yaml.propagator_momentum((3, 4), 4), "-p1-p2+q")
        self.assertEqual(kira_yaml.propagator_momentum((2, 3, 4), 4), "-p1+q")
        self.assertEqual(kira_yaml.propagator_momentum((1, 4), 4), "-p2-p3+q")

    def test_strings_map_back_to_their_invariants(self):
        for multiplicity in (3, 4):
            kinematics = kira.build_kinematics(multiplicity)
            loop_momenta = [f"p{i}" for i in range(1, multiplicity)]
            for invariant in kinematics.invariants:
                with self.subTest(invariant=str(invariant)):
                    momentum = kira_yaml.propagator_momentum(
                        kira_yaml.invariant_subset(invariant), multiplicity
                    )
                    self.assertEqual(
                        kira.propagator_invariant(momentum, loop_momenta, multiplicity),
                        invariant,
                    )

    def test_all_n4_invariants_match_hand_written_a40_yaml(self):
        loop_momenta = ["p1", "p2", "p3"]
        expected = {}
        families = yaml.safe_load(A40_YAML.read_text())["integralfamilies"]
        for family in families:
            cuts = set(family.get("cut_propagators", []))
            for position, (momentum, _) in enumerate(family["propagators"], start=1):
                if position in cuts:
                    continue
                invariant = kira.propagator_invariant(momentum, loop_momenta, 4)
                expected.setdefault(invariant, set()).add(momentum)

        kinematics = kira.build_kinematics(4)
        self.assertEqual(set(expected), set(kinematics.invariants))
        for invariant in kinematics.invariants:
            with self.subTest(invariant=str(invariant)):
                self.assertEqual(len(expected[invariant]), 1)
                (momentum,) = expected[invariant]
                self.assertEqual(
                    kira_yaml.propagator_momentum(kira_yaml.invariant_subset(invariant), 4),
                    momentum,
                )


class BuildFamilyTest(unittest.TestCase):
    def test_n3_example(self):
        family = kira_yaml.build_family("basis1", S13_S23, 3)
        self.assertEqual(
            list(family),
            ["name", "loop_momenta", "top_level_sectors", "cut_propagators", "propagators"],
        )
        self.assertEqual(family["name"], "basis1")
        self.assertEqual(family["loop_momenta"], ["p1", "p2"])
        self.assertEqual(family["top_level_sectors"], [31])
        self.assertEqual(family["cut_propagators"], [1, 2, 3])
        self.assertEqual(
            family["propagators"],
            [["p1", 0], ["p2", 0], ["-p1-p2+q", 0], ["-p2+q", 0], ["-p1+q", 0]],
        )

    def test_n4_cuts_and_sectors(self):
        free = (S12, S13, S14, S123, S234)
        family = kira_yaml.build_family("basis2", free, 4)
        self.assertEqual(family["loop_momenta"], ["p1", "p2", "p3"])
        self.assertEqual(family["top_level_sectors"], [511])
        self.assertEqual(family["cut_propagators"], [1, 2, 3, 4])
        self.assertEqual(
            family["propagators"],
            [
                ["p1", 0],
                ["p2", 0],
                ["p3", 0],
                ["-p1-p2-p3+q", 0],
                ["p1+p2", 0],
                ["p1+p3", 0],
                ["-p2-p3+q", 0],
                ["p1+p2+p3", 0],
                ["-p1+q", 0],
            ],
        )


class FamilyNameTest(unittest.TestCase):
    def test_one_based_names(self):
        self.assertEqual(kira_yaml.family_name(1), "basis1")
        self.assertEqual(kira_yaml.family_name(12), "basis12")


class RenderYamlTest(unittest.TestCase):
    def test_n3_round_trip_and_propagator_lines(self):
        families = [
            kira_yaml.build_family(kira_yaml.family_name(1), S13_S23, 3),
            kira_yaml.build_family(kira_yaml.family_name(2), (S12, S13), 3),
        ]
        text = kira_yaml.render_yaml(families, ["generated header line"])
        self.assertIn("generated header line", text)
        self.assertEqual(yaml.safe_load(text), {"integralfamilies": families})
        self.assertEqual(len(PROPAGATOR_LINE.findall(text)), 10)

    def test_exact_label_text_on_cut_and_free_lines(self):
        families = [kira_yaml.build_family("basis1", (S12, S13, S14, S123, S234), 4)]
        text = kira_yaml.render_yaml(families, [])
        for pattern in (
            r'^      - \["p1", 0\] +#1  cut$',
            r'^      - \["p2", 0\] +#2  cut$',
            r'^      - \["p3", 0\] +#3  cut$',
            r'^      - \["-p1-p2-p3\+q", 0\] +#4  cut$',
            r'^      - \["p1\+p2", 0\] +#5  s12$',
        ):
            with self.subTest(pattern=pattern):
                self.assertRegex(text, re.compile(pattern, re.MULTILINE))

    def test_n4_round_trip_and_propagator_lines(self):
        families = [
            kira_yaml.build_family(kira_yaml.family_name(1), (S12, S13, S14, S123, S234), 4),
            kira_yaml.build_family(kira_yaml.family_name(2), (S12, S13, S14, S23, S34), 4),
        ]
        text = kira_yaml.render_yaml(families, ["generated header line"])
        self.assertEqual(yaml.safe_load(text), {"integralfamilies": families})
        self.assertEqual(len(PROPAGATOR_LINE.findall(text)), 18)


class WriteIntegralFamiliesTest(unittest.TestCase):
    def test_creates_parent_dirs_and_returns_path(self):
        text = "integralfamilies: []\n"
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "nested" / "dir" / "integralfamilies.yaml"
            written = kira_yaml.write_integralfamilies(text, output)
            self.assertEqual(Path(written), output)
            self.assertEqual(output.read_text(), text)


if __name__ == "__main__":
    unittest.main()
