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
} | {
    "Axiomscope.Experiment006." + name for name in (
        "bind_same", "bind_other", "zeroOrSuccessor_iff",
        "full_induction_implies_first_order", "twoTracks_not_first_order_inductive"
    )
} | {
    "Axiomscope.Experiment007." + name for name in (
        "earlier_mem_prefix", "chosen_injective", "finite_avoidance_suffices",
        "countable_subset_implies_infinite", "ambient_infinite_has_countable_subset",
        "nat_has_proper_self_embedding", "proper_self_embedding_of_equiv_nat"
    )
} | {
    "Axiomscope.Experiment008." + name for name in (
        "intuitionistic_to_classical", "inclusion_preserves",
        "inclusion_composed_with_identity", "no_reverse_identity_interpretation"
    )
} | {
    "Axiomscope.Experiment009." + name for name in (
        "translate_derivation", "semantics_equiv", "context_semantics_equiv",
        "top_not_in_image", "embedding_compose_identity"
    )
} | {
    "Axiomscope.Experiment010." + name for name in (
        "certified_derivation", "certified_contexts",
        "composed_semantics", "composed_derivation"
    )
} | {
    "Axiomscope.Experiment011." + name for name in (
        "pullback_forcing_equiv", "cover_context_equiv",
        "cover_transports_derivation", "composed_cover_satisfaction",
        "bad_projection_not_back", "bad_projection_changes_implication"
    )
} | {
    "Axiomscope.Experiment012." + name for name in (
        "sentence_id", "sentence_comp", "reduct_comp",
        "satisfaction_condition", "satisfaction_comp",
        "context_satisfaction", "wrong_reduct_counterexample"
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
    "'Axiomscope.Experiment006.bind_same' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment006.bind_other' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment006.zeroOrSuccessor_iff' depends on axioms: [Quot.sound, propext]\n"
    "'Axiomscope.Experiment006.full_induction_implies_first_order' does not depend on any axioms\n"
    "'Axiomscope.Experiment006.twoTracks_not_first_order_inductive' depends on axioms: [Quot.sound, propext]\n"
    "'Axiomscope.Experiment007.earlier_mem_prefix' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment007.chosen_injective' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment007.finite_avoidance_suffices' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment007.countable_subset_implies_infinite' depends on axioms: [Classical.choice, Quot.sound, propext]\n"
    "'Axiomscope.Experiment007.ambient_infinite_has_countable_subset' depends on axioms: [Classical.choice, Quot.sound, propext]\n"
    "'Axiomscope.Experiment007.nat_has_proper_self_embedding' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment007.proper_self_embedding_of_equiv_nat' depends on axioms: [Quot.sound, propext]\n"
    "'Axiomscope.Experiment008.intuitionistic_to_classical' does not depend on any axioms\n"
    "'Axiomscope.Experiment008.inclusion_preserves' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment008.inclusion_composed_with_identity' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment008.no_reverse_identity_interpretation' depends on axioms: [propext, Classical.choice, Quot.sound]\n"
    "'Axiomscope.Experiment009.translate_derivation' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment009.semantics_equiv' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment009.context_semantics_equiv' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment009.top_not_in_image' does not depend on any axioms\n"
    "'Axiomscope.Experiment009.embedding_compose_identity' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment010.certified_derivation' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment010.certified_contexts' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment010.composed_semantics' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment010.composed_derivation' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment011.pullback_forcing_equiv' does not depend on any axioms\n"
    "'Axiomscope.Experiment011.cover_context_equiv' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment011.cover_transports_derivation' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment011.composed_cover_satisfaction' depends on axioms: [propext, Quot.sound]\n"
    "'Axiomscope.Experiment011.bad_projection_not_back' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment011.bad_projection_changes_implication' depends on axioms: [propext, Classical.choice, Quot.sound]\n"
    "'Axiomscope.Experiment012.sentence_id' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment012.sentence_comp' depends on axioms: [propext]\n"
    "'Axiomscope.Experiment012.reduct_comp' does not depend on any axioms\n"
    "'Axiomscope.Experiment012.satisfaction_condition' does not depend on any axioms\n"
    "'Axiomscope.Experiment012.satisfaction_comp' does not depend on any axioms\n"
    "'Axiomscope.Experiment012.context_satisfaction' does not depend on any axioms\n"
    "'Axiomscope.Experiment012.wrong_reduct_counterexample' does not depend on any axioms\n"
)


class LedgerTests(unittest.TestCase):
    def test_extracts_real_lean_format(self):
        parsed = ledger.parse_axioms(RESULT, NAMES)
        self.assertEqual(parsed["Axiomscope.natEquivEven"], ["Quot.sound", "propext"])
        self.assertEqual(parsed["Axiomscope.cantorDiagonal"], [])

    def test_multiline_axiom_report(self):
        output = (
            "'Demo.theorem' depends on axioms: [propext,\n"
            " Classical.choice,\n"
            " Quot.sound]\n"
        )
        parsed = ledger.parse_axioms(output, {"Demo.theorem"})
        self.assertEqual(
            parsed["Demo.theorem"],
            ["Classical.choice", "Quot.sound", "propext"],
        )

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
        self.assertEqual(len(data["records"]), 76)
        self.assertEqual(sum(d["uses_classical_choice"] for d in data["records"]), 8)
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

    def test_first_order_induction_report(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)["006-first-order-induction"])
        self.assertEqual(len(report["variants"]), 5)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [["propext"], ["propext"], ["Quot.sound", "propext"],
             [], ["Quot.sound", "propext"]],
        )
        self.assertFalse(any(r["uses_classical_choice"] for r in report["variants"]))

    def test_comparative_infinity_assumption_profiles(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)["007-comparative-infinity"])
        self.assertEqual(len(report["variants"]), 7)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [["propext"], ["propext"], ["propext"],
             ["Classical.choice", "Quot.sound", "propext"],
             ["Classical.choice", "Quot.sound", "propext"],
             ["propext"], ["Quot.sound", "propext"]],
        )
        self.assertEqual(
            [r["uses_classical_choice"] for r in report["variants"]],
            [False, False, False, True, True, False, False],
        )

    def test_interpretation_preservation_and_strictness_report(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)[
            "008-foundational-interpretations"])
        self.assertEqual(len(report["variants"]), 4)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [[], ["Quot.sound", "propext"], ["Quot.sound", "propext"],
             ["Classical.choice", "Quot.sound", "propext"]],
        )
        self.assertEqual(
            [r["uses_classical_choice"] for r in report["variants"]],
            [False, False, False, True],
        )

    def test_nonidentity_semantic_preservation_report(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)[
            "009-nonidentity-translation"])
        self.assertEqual(len(report["variants"]), 5)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [["Quot.sound", "propext"], ["propext"], ["propext"], [],
             ["Quot.sound", "propext"]],
        )
        self.assertTrue(all(
            not r["uses_classical_choice"] for r in report["variants"]
        ))

    def test_semantic_interpretation_certificates_report(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)[
            "010-semantic-certificates"])
        self.assertEqual(len(report["variants"]), 4)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [["Quot.sound", "propext"]] * 4,
        )
        self.assertTrue(all(
            not r["uses_classical_choice"] for r in report["variants"]
        ))

    def test_kripke_model_translation_profiles(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)[
            "011-kripke-model-translation"])
        self.assertEqual(len(report["variants"]), 6)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [[], ["Quot.sound", "propext"], ["Quot.sound", "propext"],
             ["Quot.sound", "propext"], ["propext"],
             ["Classical.choice", "Quot.sound", "propext"]],
        )
        self.assertEqual(
            [r["uses_classical_choice"] for r in report["variants"]],
            [False, False, False, False, False, True],
        )

    def test_signature_satisfaction_baseline(self):
        catalog = json.loads(ledger.CATALOG.read_text(encoding="utf-8"))
        data = ledger.collect(catalog, RESULT, "leanprover/lean4:v4.35.0")
        report = json.loads(ledger.experiment_reports(catalog, data)[
            "012-signature-satisfaction"])
        self.assertEqual(len(report["variants"]), 7)
        self.assertEqual(
            [r["axioms"] for r in report["variants"]],
            [["propext"], ["propext"], [], [], [], [], []],
        )
        self.assertFalse(any(
            r["uses_classical_choice"] for r in report["variants"]
        ))

    def test_stale_artifact_rejected(self):
        with patch.object(ledger.Path, "exists", return_value=False):
            self.assertFalse(ledger.sync_file(ledger.OUTPUT_JSON, "something", True))


if __name__ == "__main__":
    unittest.main()
