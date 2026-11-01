"""Adversarial tests for the Isabelle native dependency baseline export."""
import unittest
from scripts import benchmark_native_gate_b as bench


class NativeBaselineTests(unittest.TestCase):
    def sample(self):
        return "\n".join(
            f"{id_}\t2\t4\tGateB_CountableChoice.sample\t0\tDependency excerpt"
            for id_ in bench.EXPECTED
        ) + "\n"

    def test_accepts_exact_native_rows(self):
        found = bench.parse_export(self.sample())
        self.assertEqual(len(found), 7)
        self.assertEqual(found["finite_witnesses"]["native_oracle_count"], 0)

    def test_missing_theorem_rejected(self):
        with self.assertRaisesRegex(ValueError, "Incomplete"):
            bench.parse_export("\n".join(self.sample().splitlines()[1:]) + "\n")

    def test_duplicate_rejected(self):
        lines = self.sample().splitlines()
        lines[1] = lines[0]
        with self.assertRaisesRegex(ValueError, "duplicate"):
            bench.parse_export("\n".join(lines) + "\n")

    def test_bogus_dependency_count_rejected(self):
        with self.assertRaisesRegex(ValueError, "exceeds"):
            bench.parse_export(self.sample().replace("\t2\t4\t", "\t2\t0\t"))

    def test_unknown_local_name_rejected(self):
        with self.assertRaisesRegex(ValueError, "Invalid local"):
            bench.parse_export(self.sample().replace(
                "GateB_CountableChoice.sample", "SomeArbitraryClaim"
            ))

    def test_no_automatic_originality_claim(self):
        native = bench.parse_export(self.sample())
        scenarios = {
            "experiment": "foundations-v0.2-assumption-probe",
            "scenarios": [
                {
                    "id": key,
                    "goals": [{
                        "goal": "nonfinite_to_nat_injection",
                        "witnesses": [
                            {"claim_id": route} for route in routes
                        ],
                        "status": "supported_by_registered_proof" if routes
                        else "no_registered_witness",
                    }],
                } for key, routes in [
                    ("zf_nonfinite", []),
                    ("zf_acomega", ["countable_choice"]),
                    ("zf_wellordered", ["wellorderable_to_injection"]),
                    ("zf_nat_witness", []),
                    ("zf_both", ["countable_choice", "wellorderable_to_injection"]),
                ]
            ],
        }
        result = bench.compare(native, scenarios)
        self.assertFalse(result["assessment"]["distinguishing_capability_demonstrated"])
        self.assertEqual(result["assessment"]["verdict"], "NO_DIFFERENTIATION_DEMONSTRATED")


if __name__ == "__main__":
    unittest.main()
