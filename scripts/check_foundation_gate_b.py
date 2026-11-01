#!/usr/bin/env python3
"""Gate B evidence contract. Structural audit; Isabelle is the proof checker.

Never promotes published source evidence into machine-verified model results.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "research/gates/b/manifest.json"
THEORY = ROOT / "research/gates/b/GateB_ZF.thy"
REPORT = ROOT / "research/gates/b/comparison.json"

FORMAL = {"injection_to_infinite", "wellorderable_to_injection"}
PUBLISHED = {"countable_choice", "cohen_symmetric_countermodel"}


def validate(manifest: dict, theory: str) -> dict:
    if manifest.get("gate") != "B" or manifest.get("schema_version") != 1:
        raise ValueError("Invalid Gate B manifest")
    entries = manifest["claims"]
    ids = [c["id"] for c in entries]
    if len(ids) != len(set(ids)) or set(ids) != FORMAL | PUBLISHED:
        raise ValueError("Missing/duplicate benchmark claims")
    if not re.search(r"theory GateB_ZF\s+imports ZF\s+begin", theory):
        raise ValueError("Proof is not in the Isabelle/ZF object logic")
    if re.search(r"(?m)^\s*(sorry|oops|axiomatization)\b", theory):
        raise ValueError("Admitted proof or new axiom is forbidden")
    by_id = {claim["id"]: claim for claim in entries}
    for key in FORMAL:
        c = by_id[key]
        if c["status"] != "formal_isabelle_kernel":
            raise ValueError("Incorrect proof evidence class " + key)
        if c["source"] != "research/gates/b/GateB_ZF.thy" or not c.get("theorem"):
            raise ValueError("A formal claim must have exact source and theorem")
        local_name = c["theorem"].split(".")[-1]
        if not re.search(r"(?m)^lemma\s+" + re.escape(local_name) + r"\s*:", theory):
            raise ValueError("Formal theorem declaration missing " + key)
    for key in PUBLISHED:
        c = by_id[key]
        if c["status"] != "published_not_checked_here":
            raise ValueError("Published source was promoted to formal proof: " + key)
        if c.get("theorem") is not None or c.get("source") is not None:
            raise ValueError("Published claim must not invent a theorem identifier")
        if not c.get("evidence") or any(
            not item["url"].startswith("https://") for item in c["evidence"]
        ):
            raise ValueError("Published claim requires source URLs")
    if by_id["wellorderable_to_injection"]["assumptions"] != [
        "A is equipotent to an ordinal"
    ]:
        raise ValueError("The locally verified converse requires a well-order witness")
    if by_id["countable_choice"]["assumptions"] != ["Countable Choice (ACω)"]:
        raise ValueError("ACω and well-orderability must remain distinct")
    return {
        "schema_version": 1,
        "gate": "B",
        "status": "PARTIAL: ZF PROOF SOURCES + EXTERNAL MATHEMATICAL EVIDENCE",
        "scientific_gate_passed": False,
        "same_object_logic_for_formal_results": True,
        "claim": manifest["claim"],
        "definitions": manifest["definitions"],
        "claims": [
            {
                **c,
                "machine_check": (
                    "Isabelle2026 CI build of GateB_ZF required"
                    if c["id"] in FORMAL else "NOT_MACHINE_VERIFIED_HERE"
                ),
            } for c in entries
        ],
        "known_gaps": manifest["known_gaps"],
    }


def main() -> int:
    p = argparse.ArgumentParser()
    mode = p.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--write", action="store_true")
    a = p.parse_args()
    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        theory = THEORY.read_text(encoding="utf-8")
        out = json.dumps(validate(manifest, theory), ensure_ascii=False, indent=2) + "\n"
        if a.check:
            if not REPORT.is_file() or REPORT.read_text(encoding="utf-8") != out:
                raise ValueError("Comparison drift: regenerate with --write")
            print("Gate B evidence contract passed (scientific gate remains OPEN)")
        else:
            REPORT.parent.mkdir(parents=True, exist_ok=True)
            REPORT.write_text(out, encoding="utf-8")
            print("Wrote", REPORT)
    except (KeyError, OSError, ValueError) as error:
        print("Gate B evidence FAILED:", error, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
