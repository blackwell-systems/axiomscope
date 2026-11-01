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

    def test_infinite_union_verified_without_promoting_converse(self):
        report = gate.validate(self.manifest, self.theory)
        by_id = {c["id"]: c for c in report["claims"]}
        self.assertEqual(by_id["selected_union_infinite"]["status"], "formal_isabelle_kernel")
        self.assertEqual(
            by_id["countable_choice_yields_infinite_enumerated_union"]["status"],
            "formal_isabelle_kernel",
        )
        self.assertEqual(by_id["countable_choice"]["status"], "published_not_checked_here")
        self.assertFalse(report["scientific_gate_passed"])

    def test_published_countermodel_cannot_be_upgraded(self):
        altered = copy.deepcopy(self.manifest)
        next(c for c in altered["claims"] if c["id"] == "cohen_symmetric_countermodel")["status"] = "formal_isabelle_kernel"
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

    def test_finite_injection_chain_is_classified_as_formal(self):
        report = gate.validate(self.manifest, self.theory)
        by_id = {c["id"]: c for c in report["claims"]}
        for key in ("finite_injection_candidates", "countable_choice_finite_witnesses"):
            self.assertEqual(by_id[key]["status"], "formal_isabelle_kernel")
            self.assertIn("CountableChoice.thy", by_id[key]["source"])
        self.assertFalse(report["scientific_gate_passed"])

    def test_no_implicit_choice_or_unspecified_source(self):
        with self.assertRaisesRegex(ValueError, "within the Isabelle/ZF"):
            gate.validate(self.manifest, self.theory, "theory Other imports Main begin end")

    def test_new_axioms_or_admitted_proofs_are_rejected(self):
        with self.assertRaisesRegex(ValueError, "forbidden"):
            gate.validate(self.manifest, self.theory.replace("end\n", "sorry\nend\n"))


if __name__ == "__main__":
    unittest.main()
