import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))

import dataclasses
import tempfile
import unittest
from unittest import mock

from antcalc import integrate_kira as kira
from antcalc import orchestrator
from antcalc.family_generation import pipeline


def make_run(antenna="A", multiplicity=3, loop_order=0, substitute_masters=False, families_path=None):
    return kira.IntegrationRun(
        antenna_family=antenna,
        multiplicity=multiplicity,
        loop_order=loop_order,
        auto_input_path=True,
        manual_input_path=Path("."),
        substitute_masters=substitute_masters,
        families_path=families_path,
    )


def generation_runcard(**overrides):
    runcard = {"integrate": 1, "integrate_method": "kira", "substitute_masters": 0, "generate_families": 1}
    runcard.update(overrides)
    return runcard


class RuncardGenerationConditionsTest(unittest.TestCase):
    def test_value_two_is_rejected(self):
        with self.assertRaises(ValueError):
            orchestrator.runcard_generation_conditions(generation_runcard(generate_families=2))

    def test_string_one_is_rejected(self):
        with self.assertRaises(ValueError):
            orchestrator.runcard_generation_conditions(generation_runcard(generate_families="1"))

    def test_flag_with_substitute_masters_one_is_rejected(self):
        with self.assertRaises(ValueError):
            orchestrator.runcard_generation_conditions(generation_runcard(substitute_masters=1))

    def test_flag_with_absent_substitute_masters_is_rejected(self):
        runcard = generation_runcard()
        del runcard["substitute_masters"]
        with self.assertRaises(ValueError):
            orchestrator.runcard_generation_conditions(runcard)

    def test_flag_with_legacy_method_is_rejected(self):
        with self.assertRaises(ValueError):
            orchestrator.runcard_generation_conditions(generation_runcard(integrate_method="legacy"))

    def test_valid_generation_runcard_passes(self):
        orchestrator.runcard_generation_conditions(generation_runcard())

    def test_flag_off_passes(self):
        orchestrator.runcard_generation_conditions(generation_runcard(generate_families=0, substitute_masters=1))


class IntegralFamiliesPathTest(unittest.TestCase):
    def test_template_path_without_families_path(self):
        run = make_run("A", 4)
        self.assertEqual(
            kira.integralfamilies_path(run),
            kira.TEMPLATES_DIR / "A40" / "config" / "integralfamilies.yaml",
        )

    def test_families_path_replaces_template(self):
        generated = Path("some/generated/integralfamilies.yaml")
        run = make_run("A", 4, families_path=generated)
        self.assertEqual(kira.integralfamilies_path(run), generated)


class PrepareFamiliesTest(unittest.TestCase):
    def test_substitute_masters_is_rejected(self):
        with self.assertRaises(ValueError):
            pipeline.prepare_families(make_run("A", 3, substitute_masters=True))

    def test_uncovered_antenna_raises(self):
        failed = {"ok": False, "error": "boom", "n_integrands": 0, "families_used": set()}
        with tempfile.TemporaryDirectory() as tmp, \
                mock.patch.object(kira, "KIRA_RUN_DIR", Path(tmp)), \
                mock.patch.object(pipeline, "check_coverage", return_value=failed):
            with self.assertRaisesRegex(ValueError, "do not cover"):
                pipeline.prepare_families(make_run("A", 3))

    def test_covered_antenna_returns_generated_path(self):
        with tempfile.TemporaryDirectory() as tmp, mock.patch.object(kira, "KIRA_RUN_DIR", Path(tmp)):
            path = pipeline.prepare_families(make_run("A", 3))
            self.assertEqual(path, Path(tmp) / "A30_families" / "integralfamilies.yaml")
            self.assertTrue(path.exists())


class ClearKiraResultsTest(unittest.TestCase):
    def test_generated_yaml_is_copied_into_work_dir(self):
        marker = "integralfamilies: []  # generated marker\n"
        with tempfile.TemporaryDirectory() as tmp:
            generated = Path(tmp) / "generated.yaml"
            generated.write_text(marker)
            run = dataclasses.replace(make_run("A", 3), families_path=generated)
            with mock.patch.object(kira, "KIRA_RUN_DIR", Path(tmp) / "work"):
                kira.clear_kira_results(run)
                copied = Path(tmp) / "work" / "A30" / "config" / "integralfamilies.yaml"
                self.assertEqual(copied.read_text(), marker)


if __name__ == "__main__":
    unittest.main()
