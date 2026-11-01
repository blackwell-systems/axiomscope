"""Regressions for Foundations v0.2: proof usability is not theorem validity."""
from __future__ import annotations

import copy
import json
import unittest

from scripts import foundation_probe_v02 as probe
from scripts.isabelle_premises_v02 import extract_signature


class FoundationProbeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = json.loads(probe.SCENARIOS.read_text(encoding="utf-8"))
        cls.manifest = json.loads(probe.MANIFEST.read_text(encoding="utf-8"))
        cls.report = probe.evaluate(cls.config, cls.manifest)
        cls.by_id = {s["id"]: s for s in cls.report["scenarios"]}

    @staticmethod
    def goal(scenario: dict, name: str) -> dict:
        return next(g for g in scenario["goals"] if g["goal"] == name)

    def test_zf_without_choice_has_no_registered_converse_witness(self):
        result = self.goal(self.by_id["zf_nonfinite"], "nonfinite_to_nat_injection")
        self.assertEqual(result["status"], "no_registered_witness")
        self.assertEqual(result["witnesses"], [])
        self.assertIn("does not establish", result["caveat"])
        self.assertEqual(
            {m for proof in result["candidate_requirements"]
             for m in proof["missing_conditions"]},
            {"AComega", "wellorder_A"},
        )

    def test_countable_choice_makes_verified_proof_applicable(self):
        result = self.goal(self.by_id["zf_acomega"], "nonfinite_to_nat_injection")
        self.assertEqual(result["status"], "supported_by_registered_proof")
        self.assertEqual(
            [proof["claim_id"] for proof in result["witnesses"]],
            ["countable_choice"],
        )

    def test_local_wellorder_is_an_alternative_not_global_choice(self):
        result = self.goal(self.by_id["zf_wellordered"], "nonfinite_to_nat_injection")
        self.assertEqual(result["status"], "supported_by_registered_proof")
        self.assertEqual(result["witnesses"][0]["claim_id"], "wellorderable_to_injection")

    def test_multiple_proofs_retained(self):
        result = self.goal(self.by_id["zf_both"], "nonfinite_to_nat_injection")
        self.assertEqual(
            [p["claim_id"] for p in result["witnesses"]],
            ["countable_choice", "wellorderable_to_injection"],
        )

    def test_nat_injection_supports_nonfiniteness_without_choice(self):
        result = self.goal(self.by_id["zf_nat_witness"], "nat_injection_to_nonfinite")
        self.assertEqual(result["status"], "supported_by_registered_proof")
        self.assertEqual(result["witnesses"][0]["claim_id"], "injection_to_infinite")

    def test_contrasts_do_not_claim_nonderivability(self):
        for contrast in self.report["contrasts"]:
            self.assertTrue(contrast["lost_registered_support"])
            self.assertIn("not a proof of nonderivability", contrast["interpretation"])
        self.assertNotIn("proved_independent", json.dumps(self.report))

    def test_reject_cross_logic_transport(self):
        wrong = copy.deepcopy(self.config)
        wrong["logic"] = "Lean/TypeTheory"
        with self.assertRaisesRegex(ValueError, "Only Isabelle/ZF"):
            probe.evaluate(wrong, self.manifest)

    def test_unknown_context_principle_fails_closed(self):
        wrong = copy.deepcopy(self.config)
        wrong["scenarios"][0]["conditions"].append("arbitrary_axiom")
        with self.assertRaisesRegex(ValueError, "Unknown"):
            probe.evaluate(wrong, self.manifest)

    def test_no_promotion_of_published_countermodel(self):
        wrong = copy.deepcopy(self.manifest)
        for claim in wrong["claims"]:
            if claim["id"] == "cohen_symmetric_countermodel":
                claim["status"] = "formal_isabelle_kernel"
        with self.assertRaisesRegex(ValueError, "promoted"):
            probe.evaluate(self.config, wrong)

    def test_cannot_silently_drop_choice_assumption(self):
        wrong = copy.deepcopy(self.manifest)
        for claim in wrong["claims"]:
            if claim["id"] == "countable_choice":
                claim["assumptions"] = []
        with self.assertRaisesRegex(ValueError, "ACω.*distinct|contract changed"):
            probe.evaluate(self.config, wrong)

    def test_requirements_are_extracted_from_isabelle_source(self):
        by_id, signatures = probe.checked_claims(self.manifest)
        self.assertEqual(
            signatures["countable_choice"].premises,
            (r"\<not> Finite(A)", "countable_choice"),
        )
        self.assertEqual(
            signatures["wellorderable_to_injection"].premises,
            (r"\<not> Finite(A)", r"\<exists>a. Ord(a) \<and> A \<approx> a"),
        )
        self.assertEqual(
            signatures["injection_to_infinite"].premises,
            ("has_nat_injection(A)",),
        )
        self.assertEqual(
            by_id["countable_choice"]["status"], "formal_isabelle_kernel"
        )

    def test_report_displays_source_signatures(self):
        witness = self.goal(
            self.by_id["zf_acomega"], "nonfinite_to_nat_injection"
        )["witnesses"][0]
        self.assertEqual(
            witness["source_premises"], [r"\<not> Finite(A)", "countable_choice"]
        )
        self.assertEqual(witness["source_conclusion"], "has_nat_injection(A)")

    def test_unknown_extra_assumption_is_rejected_not_ignored(self):
        source = (
            'lemma target:\n'
            '  assumes "has_nat_injection(A)" and "unregistered_principle"\n'
            '  shows "\\<not> Finite(A)"\n'
            '  by blast\n'
        )
        signature = extract_signature(source, "target")
        with self.assertRaises(KeyError):
            for premise in signature.premises:
                _ = probe.PREMISE_TAGS[premise]
        
    def test_unsupported_unquoted_syntax_fails_closed(self):
        source = (
            'lemma target:\n'
            '  assumes "has_nat_injection(A)" and SOME_UNQUOTED_TERM\n'
            '  shows "\\<not> Finite(A)"\n'
            '  by blast\n'
        )
        with self.assertRaisesRegex(ValueError, "Unsupported declaration"):
            extract_signature(source, "target")

    def test_no_fallback_to_manual_requirements(self):
        self.assertFalse(
            hasattr(probe.CONTRACTS[0], "requires"),
            "Applicability requirements must originate from source propositions",
        )

    def test_deterministic_report(self):
        self.assertEqual(
            json.dumps(probe.evaluate(self.config, self.manifest), ensure_ascii=False, indent=2),
            json.dumps(self.report, ensure_ascii=False, indent=2),
        )


if __name__ == "__main__":
    unittest.main()
