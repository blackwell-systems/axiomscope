"""Fail-closed regression tests for Isabelle-generated theorem statement evidence."""
from __future__ import annotations

import copy
import json
import unittest

from scripts import check_prover_bridge_v03 as bridge
from scripts import foundation_probe_v02 as probe
from scripts import generate_prover_bridge_v03 as generator


class ProverBridgeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = json.loads(bridge.SCENARIOS.read_text(encoding="utf-8"))
        cls.manifest = json.loads(bridge.MANIFEST.read_text(encoding="utf-8"))
        _, cls.signatures = probe.checked_claims(cls.manifest)

    def sample(self):
        return "\n".join(
            f"{claim}\t{len(signature.premises)}\t"
            f"{' || '.join(signature.premises)}\t{signature.conclusion}"
            for claim, signature in self.signatures.items()
        ) + "\n"

    def test_export_consumed_by_scenario_engine(self):
        output = bridge.consume(self.sample(), self.config, self.manifest)
        self.assertEqual(len(output["scenarios"]), 5)
        goal = next(g for g in output["scenarios"][1]["goals"]
                    if g["goal"] == "nonfinite_to_nat_injection")
        witness = goal["witnesses"][0]
        self.assertEqual(witness["prover_export"]["claim_id"], "countable_choice")
        self.assertEqual(witness["prover_export"]["premise_count"], 2)
        self.assertIn("not transitive", output["prover_evidence"]["limitations"])

    def test_missing_theorem_fails(self):
        lines = self.sample().splitlines()
        with self.assertRaisesRegex(ValueError, "Incomplete"):
            bridge.parse_export("\n".join(lines[1:]), self.signatures)

    def test_extra_theorem_fails(self):
        with self.assertRaisesRegex(ValueError, "Incomplete"):
            bridge.parse_export(self.sample() + "fake\t0\t\ttruth\n", self.signatures)

    def test_theorem_premise_count_changed_fails(self):
        altered = self.sample().replace("countable_choice\t2\t", "countable_choice\t1\t")
        with self.assertRaisesRegex(ValueError, "premise count"):
            bridge.parse_export(altered, self.signatures)

    def test_blank_conclusion_rejected(self):
        altered = self.sample().replace("has_nat_injection(A)\n", "\n", 1)
        with self.assertRaisesRegex(ValueError, "conclusion"):
            bridge.parse_export(altered, self.signatures)

    def test_unknown_claim_rejected(self):
        altered = self.sample().replace("countable_choice\t2\t", "invented_theorem\t2\t")
        with self.assertRaisesRegex(ValueError, "Unknown"):
            bridge.parse_export(altered, self.signatures)

    def test_bogus_proof_classification_rejected(self):
        m = copy.deepcopy(self.manifest)
        for c in m["claims"]:
            if c["id"] == "cohen_symmetric_countermodel":
                c["status"] = "formal_isabelle_kernel"
        with self.assertRaisesRegex(ValueError, "promoted"):
            bridge.consume(self.sample(), self.config, m)

    def test_generator_embeds_elaborated_proposition_checks(self):
        ml = generator.generate()
        self.assertIn("Thm.prop_of theorem", ml)
        self.assertIn("Pattern.matches thy (actual, expected)", ml)
        self.assertIn("Thm.prems_of theorem", ml)
        self.assertIn('Export.export thy', ml)
        self.assertEqual(ml.count("    certify ("), 3)

    def test_generator_matches_committed_isabelle_ml(self):
        self.assertEqual(
            generator.generate(),
            generator.OUTPUT.read_text(encoding="utf-8"),
        )


if __name__ == "__main__":
    unittest.main()
