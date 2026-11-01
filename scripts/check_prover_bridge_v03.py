#!/usr/bin/env python3
"""Consume Isabelle-produced theorem signatures after kernel replay.

GateB_ProverBridge.ML first checks the elaborated theorem propositions
against generated source contracts and emits a session export. This tool
checks the export is complete, validates it against the registered
assumption vocabulary, and writes a scenario report with the observed
prover-rendered statements. It is NOT a theorem or dependency checker.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts import foundation_probe_v02 as probe

MANIFEST = ROOT / "research/gates/b/manifest.json"
SCENARIOS = ROOT / "research/foundations-v0.2/scenarios.json"


def parse_export(text: str, signatures: dict) -> dict:
    records = {}
    lines = text.splitlines()
    if len(lines) != len(probe.CONTRACTS):
        raise ValueError("Incomplete or extra prover-exported declarations")
    for line in lines:
        fields = line.split("\t")
        if len(fields) != 4:
            raise ValueError("Invalid Isabelle export row (expected four tab-separated fields)")
        claim_id, count, printed_premises, printed_conclusion = fields
        if claim_id in records or claim_id not in signatures:
            raise ValueError("Unknown or duplicate exported theorem " + claim_id)
        if not count.isdigit() or int(count) != len(signatures[claim_id].premises):
            raise ValueError("Isabelle premise count disagrees with source: " + claim_id)
        if not printed_conclusion.strip():
            raise ValueError("Empty Isabelle conclusion: " + claim_id)
        if (int(count) > 0 and not printed_premises.strip()) or (
            int(count) == 0 and printed_premises.strip()
        ):
            raise ValueError("Missing or extraneous Isabelle premises: " + claim_id)
        records[claim_id] = {
            "claim_id": claim_id,
            "premise_count": int(count),
            "prover_pretty_premises": printed_premises,
            "prover_pretty_conclusion": printed_conclusion,
        }
    if set(records) != {contract.claim_id for contract in probe.CONTRACTS}:
        raise ValueError("Missing certified registered theorem")
    return records


def consume(export: str, config: dict, manifest: dict) -> dict:
    _, signatures = probe.checked_claims(manifest)
    evidence = parse_export(export, signatures)
    report = probe.evaluate(config, manifest)
    for scenario in report["scenarios"]:
        for goal in scenario["goals"]:
            for item in goal["witnesses"] + goal["candidate_requirements"]:
                item["prover_export"] = evidence[item["claim_id"]]
    report["prover_evidence"] = {
        "kind": "Isabelle2026 exported theorem signatures after elaborated proposition check",
        "verified_by": "GateB_ProverBridge.ML / Isabelle session kernel build",
        "source": "GateB_ZF.GateB_ProverBridge:axiomscope_theorems.tsv",
        "limitations": (
            "Prover-rendered *statements*, not transitive proof-term dependencies. "
            "Applicability still uses explicitly registered source premise tags."
        ),
    }
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--export", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    try:
        export = args.export.read_text(encoding="utf-8")
        config = json.loads(SCENARIOS.read_text(encoding="utf-8"))
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        report = consume(export, config, manifest)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print("Consumed certified Isabelle theorem export for",
              len(probe.CONTRACTS), "registered theorems")
        return 0
    except (OSError, ValueError, KeyError, TypeError) as error:
        print("Prover evidence consumption FAILED:", error, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
