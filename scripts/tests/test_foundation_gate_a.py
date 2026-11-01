"""Gate A contract validation is deliberately separate from theorem checking."""
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("gate_a", ROOT / "scripts/check_foundation_gate_a.py")
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)


def minimal_source_evidence():
    return {
        "isabelle_zf_base": '''axiomatization
where
  infinity: "0 \\<in> Inf \\<and> (\\<forall>y\\<in>Inf. succ(y) \\<in> Inf)" and
''',
        "zffin_theory": '''locale L_fin = set_signature +
  assumes fin: "\\<not> (\\<exists> x. \\<emptyset> \\<epsilon> x \\<and> (\\<forall> y. y \\<epsilon> x \\<longrightarrow> setsucM y y \\<epsilon> x))"
locale ZFfin = L_setext + L_empty + L_fin + L_epsind
''',
        "zffin_hf_model": '''theory ZFfin_HF
imports HereditarilyFinite.Rank ZFfin
begin
interpretation zfhf: ZFfin "(\\<^bold>\\<in>)"
proof-
  show "ZFfin (\\<^bold>\\<in>)"
    by blast
qed
''',
        "zffin_session": "session ZF_finite = HOL +\n  sessions\n    HereditarilyFinite\n  theories\n    ZFfin\n    ZFfin_HF\n",
        "hf_carrier": 'typedef hf = "UNIV :: nat set" ..\ndefinition hmem :: "hf"\n',
    }


class GateATests(unittest.TestCase):
    def test_git_blob_integrity(self):
        raw = b"abcdef"
        import hashlib
        want = hashlib.sha1(b"blob 6\0abcdef").hexdigest()
        self.assertEqual(gate.git_blob_sha1(raw), want)

    def test_contracts_accept_expected_declarations(self):
        gate.check_declarations(minimal_source_evidence())

    def test_missing_interpretation_fails_closed(self):
        sources = minimal_source_evidence()
        sources["zffin_hf_model"] = sources["zffin_hf_model"].replace(
            'interpretation zfhf: ZFfin', 'interpretation x: Other'
        )
        with self.assertRaisesRegex(ValueError, "interpretation"):
            gate.check_declarations(sources)

    def test_missing_fin_axiom_fails_closed(self):
        sources = minimal_source_evidence()
        sources["zffin_theory"] = sources["zffin_theory"].replace(
            "assumes fin", "assumes unrelated"
        )
        with self.assertRaisesRegex(ValueError, "negated Infinity"):
            gate.check_declarations(sources)

    def test_source_pins_required(self):
        source = {"id": "bad", "revision": "not-a-commit", "git_blob_sha1": "0"*40}
        with self.assertRaisesRegex(ValueError, "full 40-digit"):
            gate.source_integrity(source, b"some-content")

    def test_report_refuses_cross_logic_equivalence_claim(self):
        manifest = json.loads((ROOT / "research/gates/a/manifest.json").read_text())
        report = gate.build_report(manifest, minimal_source_evidence())
        self.assertFalse(report["same_object_logic"])
        self.assertEqual(report["isabelle_replay"], "NOT_RUN_BY_SOURCE_CHECKER")
        self.assertEqual(report["cases"][0]["proof_kind"], "object_logic_axiom")
        self.assertEqual(report["cases"][1]["proof_kind"], "model_interpretation")

if __name__ == "__main__":
    unittest.main()
