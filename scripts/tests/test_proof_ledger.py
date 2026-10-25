"""Tests for parsing Lean's dependency reports and detecting drift."""
import importlib.util
import json
import unittest
from pathlib import Path
from unittest.mock import patch

SOURCE = Path(__file__).resolve().parents[1] / "generate_proof_ledger.py"
spec = importlib.util.spec_from_file_location("ledger", SOURCE)
ledger = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ledger)

NAMES = {"Axiomscope.natEquivEven", "Axiomscope.natEquivInt", "Axiomscope.cantorDiagonal"} | {
    "Axiomscope.Experiment001." + name for name in (
        "doubleNegatedExcludedMiddle", "decidableExcludedMiddle",
        "classicalExcludedMiddle", "classicalDoubleNegationElim"
    )
}
RESULT = (
    "'Axiomscope.natEquivEven' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.natEquivInt' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.cantorDiagonal' does not depend on any axioms\n"
    "'Axiomscope.Experiment001.doubleNegatedExcludedMiddle' does not depend on any axioms\n"
    "'Axiomscope.Experiment001.decidableExcludedMiddle' does not depend on any axioms\n"
    "'Axiomscope.Experiment001.classicalExcludedMiddle' depends on axioms: [Classical.choice]\n"
    "'Axiomscope.Experiment001.classicalDoubleNegationElim' depends on axioms: [Classical.choice]\n"
)


class LedgerTests(unittest.TestCase):
    def test_extracts_real_lean_format(self):
        parsed = ledger.parse_axioms(RESULT, NAMES)
        self.assertEqual(parsed["Axiomscope.natEquivEven"], ["Quot.sound", "propext"])
        self.assertEqual(parsed["Axiomscope.cantorDiagonal"], [])

    def test_missing_report_rejected(self):
        with self.assertRaisesRegex(ledger.LedgerError, "Missing Lean"):
            ledger.parse_axioms(RESULT.splitlines()[0], NAMES)

    def test_duplicate_report_rejected(self):
        with self.assertRaisesRegex(ledger.LedgerError, "Duplicate"):
            ledger.parse_axioms(RESULT + RESULT.splitlines()[0], NAMES)

    def test_unregistered_report_rejected(self):
        with self.assertRaisesRegex(ledger.LedgerError, "Unexpected"):
            ledger.parse_axioms(RESULT + "'Other.thing' does not depend on any axioms", NAMES)

    def test_new_axiom_rejected(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        altered = RESULT.replace("[propext, Quot.sound]", "[propext, Quot.sound, sorryAx]", 1)
        with self.assertRaisesRegex(ledger.LedgerError, "unapproved"):
            ledger.collect(catalog, altered, "leanprover/lean4:v4.35.0")

    def test_json_markdown_agree(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        self.assertEqual(len(data["records"]), 7)
        self.assertEqual(sum(d["uses_classical_choice"] for d in data["records"]), 2)
        self.assertIn("Quot.sound", ledger.markdown(data))

    def test_classical_profile_rejects_missing_choice(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        altered = RESULT.replace(
            "'Axiomscope.Experiment001.classicalExcludedMiddle' depends on axioms: [Classical.choice]",
            "'Axiomscope.Experiment001.classicalExcludedMiddle' does not depend on any axioms",
        )
        with self.assertRaisesRegex(ledger.LedgerError, "does not exhibit required"):
            ledger.collect(catalog, altered, "leanprover/lean4:v4.35.0")

    def test_kernel_profile_rejects_choice(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        altered = RESULT.replace(
            "'Axiomscope.Experiment001.decidableExcludedMiddle' does not depend on any axioms",
            "'Axiomscope.Experiment001.decidableExcludedMiddle' depends on axioms: [Classical.choice]",
        )
        with self.assertRaisesRegex(ledger.LedgerError, "violates profile"):
            ledger.collect(catalog, altered, "leanprover/lean4:v4.35.0")

    def test_experiment_comparison_generated(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)["001-excluded-middle"])
        self.assertEqual(len(report["variants"]), 4)
        self.assertEqual(
            [e["uses_classical_choice"] for e in report["variants"]],
            [False, False, True, True],
        )

    def test_stale_artifact_rejected(self):
        with patch.object(ledger.Path, "exists", return_value=False):
            self.assertFalse(ledger.sync_file(ledger.OUTPUT_JSON, "something", True))


if __name__ == "__main__":
    unittest.main()
