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
    "Axiomscope.Experiment002." + name for name in (
        "forces_mono", "sound", "root_not_forces_em", "excludedMiddle_notDerivable"
    )
} | {
    "Axiomscope.Experiment001." + name for name in (
        "doubleNegatedExcludedMiddle", "decidableExcludedMiddle",
        "classicalExcludedMiddle", "classicalDoubleNegationElim"
    )
} | {
    "Axiomscope.Experiment003." + name for name in (
        "forces_mono", "sound", "generic_em_not_derivable",
        "two_world_em_not_derivable"
    )
} | {
    "Axiomscope.Experiment004." + name for name in (
        "induction_rule", "recurse_unique", "zero_ne_succ", "succ_injective",
        "toNat_ofNat", "ofNat_toNat", "equivNat", "toNat_injective",
        "toNat_add", "toNat_mul", "add_assoc", "add_comm",
        "mul_assoc", "mul_add"
    )
} | {
    "Axiomscope.Experiment005." + name for name in (
        "encode_succ", "encode_unique", "encode_injective", "encode_surjective",
        "encode_bijective", "equivalence", "encode_add", "encode_mul",
        "twoTracks_not_inductive"
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
    "'Axiomscope.Experiment002.forces_mono' does not depend on any axioms\n"
    "'Axiomscope.Experiment002.sound' does not depend on any axioms\n"
    "'Axiomscope.Experiment002.root_not_forces_em' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment002.excludedMiddle_notDerivable' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment003.forces_mono' does not depend on any axioms\n"
    "'Axiomscope.Experiment003.sound' does not depend on any axioms\n"
    "'Axiomscope.Experiment003.generic_em_not_derivable' does not depend on any axioms\n"
    "'Axiomscope.Experiment003.two_world_em_not_derivable' depends on axioms: [propext, Classical.choice, Quot.sound]\n"
    "'Axiomscope.Experiment004.induction_rule' does not depend on any axioms\n"
    "'Axiomscope.Experiment004.recurse_unique' does not depend on any axioms\n"
    "'Axiomscope.Experiment004.zero_ne_succ' does not depend on any axioms\n"
    "'Axiomscope.Experiment004.succ_injective' does not depend on any axioms\n"
    "'Axiomscope.Experiment004.toNat_ofNat' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment004.ofNat_toNat' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment004.equivNat' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment004.toNat_injective' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment004.toNat_add' does not depend on any axioms\n"
    "'Axiomscope.Experiment004.toNat_mul' does not depend on any axioms\n"
    "'Axiomscope.Experiment004.add_assoc' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment004.add_comm' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment004.mul_assoc' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment004.mul_add' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment005.encode_succ' does not depend on any axioms\n"
    "'Axiomscope.Experiment005.encode_unique' does not depend on any axioms\n"
    "'Axiomscope.Experiment005.encode_injective' does not depend on any axioms\n"
    "'Axiomscope.Experiment005.encode_surjective' does not depend on any axioms\n"
    "'Axiomscope.Experiment005.encode_bijective' does not depend on any axioms\n"
    "'Axiomscope.Experiment005.equivalence' depends on axioms: [Classical.choice]\n"
    "'Axiomscope.Experiment005.encode_add' does not depend on any axioms\n"
    "'Axiomscope.Experiment005.encode_mul' does not depend on any axioms\n"
    "'Axiomscope.Experiment005.twoTracks_not_inductive' does not depend on any axioms\n"
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
        self.assertEqual(len(data["records"]), 38)
        self.assertEqual(sum(d["uses_classical_choice"] for d in data["records"]), 4)
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

    def test_kripke_countermodel_report(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)[
            "002-kripke-countermodel"])
        self.assertEqual(len(report["variants"]), 4)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [[], [], ["propext"], ["propext"]],
        )
        self.assertTrue(all(not r["uses_classical_choice"] for r in report["variants"]))

    def test_general_kripke_report(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)["003-general-kripke"])
        self.assertEqual(len(report["variants"]), 4)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [[], [], [], ["Classical.choice", "Quot.sound", "propext"]],
        )
        self.assertEqual(
            [r["uses_classical_choice"] for r in report["variants"]],
            [False, False, False, True],
        )

    def test_reconstructed_naturals_report(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)["004-natural-numbers"])
        self.assertEqual(len(report["variants"]), 14)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [[], [], [], [], ["propext"], ["propext"], ["propext"], ["propext"],
             [], [], ["propext"], ["propext"], ["propext"], ["propext"]],
        )
        self.assertTrue(all(not r["uses_classical_choice"] for r in report["variants"]))

    def test_peano_axioms_comparison(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)["005-peano-axioms"])
        self.assertEqual(len(report["variants"]), 9)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [[], [], [], [], [], ["Classical.choice"], [], [], []],
        )
        self.assertEqual(sum(r["uses_classical_choice"] for r in report["variants"]), 1)

    def test_stale_artifact_rejected(self):
        with patch.object(ledger.Path, "exists", return_value=False):
            self.assertFalse(ledger.sync_file(ledger.OUTPUT_JSON, "something", True))


if __name__ == "__main__":
    unittest.main()
