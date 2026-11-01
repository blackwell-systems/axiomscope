"""Tests that a published independence theorem cannot be relabeled as checked."""
import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
module = importlib.util.spec_from_file_location("gate_b", ROOT / "scripts/check_foundation_gate_b.py")
gate = importlib.util.module_from_spec(module)
module.loader.exec_module(gate)


class GateBTests(unittest.TestCase):
    def setUp(self):
        self.manifest = json.loads(gate.MANIFEST.read_text(encoding="utf-8"))
        self.theory = gate.THEORY.read_text(encoding="utf-8")

    def test_partial_report_never_claims_complete_gate(self):
        report = gate.validate(self.manifest, self.theory)
        self.assertFalse(report["scientific_gate_passed"])
        published = [c for c in report["claims"] if c["status"] == "published_not_checked_here"]
        self.assertEqual(len(published), 2)
        self.assertTrue(all(c["machine_check"] == "NOT_MACHINE_VERIFIED_HERE" for c in published))

    def test_published_countermodel_cannot_be_upgraded(self):
        altered = copy.deepcopy(self.manifest)
        altered["claims"][3]["status"] = "formal_isabelle_kernel"
        with self.assertRaisesRegex(ValueError, "promoted"):
            gate.validate(altered, self.theory)

    def test_syntactic_theorem_source_is_required(self):
        with self.assertRaisesRegex(ValueError, "declaration missing"):
            gate.validate(self.manifest, self.theory.replace(
                "lemma countable_injection_implies_infinite:", "lemma other_lemma:"
            ))

    def test_cannot_conflate_countable_choice_with_wellorderability(self):
        altered = copy.deepcopy(self.manifest)
        altered["claims"][1]["assumptions"] = ["Countable Choice (ACω)"]
        with self.assertRaisesRegex(ValueError, "well-order"):
            gate.validate(altered, self.theory)

    def test_new_axioms_or_admitted_proofs_are_rejected(self):
        with self.assertRaisesRegex(ValueError, "forbidden"):
            gate.validate(self.manifest, self.theory.replace("end\n", "sorry\nend\n"))


if __name__ == "__main__":
    unittest.main()
