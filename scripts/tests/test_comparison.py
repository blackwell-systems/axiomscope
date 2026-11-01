"""Tests for comparison joins: no theorem, no verified comparison."""
import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "scripts/build_comparison.py"
spec = importlib.util.spec_from_file_location("comparison", SOURCE)
comparison = importlib.util.module_from_spec(spec)
spec.loader.exec_module(comparison)


class ComparisonTests(unittest.TestCase):
    def setUp(self):
        self.specification = json.loads(comparison.SPEC.read_text(encoding="utf-8"))
        self.audit = {
            "schema_version": 1,
            "id": "007-comparative-infinity",
            "toolchain": "leanprover/lean4:v4.35.0",
            "variants": [
                {
                    "declaration": case["proof"],
                    "axioms": [],
                    "uses_classical_choice": False,
                    "provenance": "Test fixture",
                }
                for case in self.specification["cases"]
            ],
        }

    def test_combines_verified_proof_and_explicit_assumptions(self):
        report = comparison.compile_report(self.specification, self.audit)
        self.assertEqual(len(report["cases"]), 5)
        self.assertEqual(
            report["cases"][0]["assumptions"],
            ["FiniteAvoidance α: uniform fresh point for each finite list"],
        )
        self.assertTrue(all(c["verified"] for c in report["cases"]))

    def test_missing_theorem_cannot_pass(self):
        audit = copy.deepcopy(self.audit)
        audit["variants"].pop()
        with self.assertRaisesRegex(ValueError, "No audited theorem"):
            comparison.compile_report(self.specification, audit)

    def test_duplicate_proof_rejected(self):
        specification = copy.deepcopy(self.specification)
        specification["cases"][1]["proof"] = specification["cases"][0]["proof"]
        with self.assertRaisesRegex(ValueError, "Duplicate"):
            comparison.compile_report(specification, self.audit)

    def test_explicit_assumptions_required(self):
        specification = copy.deepcopy(self.specification)
        specification["cases"][0]["assumptions"] = []
        with self.assertRaisesRegex(ValueError, "Missing explicit assumptions"):
            comparison.compile_report(specification, self.audit)

    def test_wrong_experiment_rejected(self):
        audit = copy.deepcopy(self.audit)
        audit["id"] = "some-other-experiment"
        with self.assertRaisesRegex(ValueError, "mismatch"):
            comparison.compile_report(self.specification, audit)


if __name__ == "__main__":
    unittest.main()
