#!/usr/bin/env python3
"""Join a curated assumption comparison to independently audited Lean proof records.

Usage: python3 scripts/build_comparison.py --check | --write
No conclusion is inferred from missing proofs or from an axiom's absence.
"""
import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SPEC = ROOT / "proofs/comparisons/007.spec.json"
AUDIT = ROOT / "proofs/experiments/007-comparative-infinity.json"
OUTPUT = ROOT / "proofs/comparisons/007-comparative-infinity.json"


def compile_report(spec: dict, audit: dict) -> dict:
    if spec.get("schema_version") != 1 or audit.get("schema_version") != 1:
        raise ValueError("Unsupported comparison/audit schema")
    if spec.get("experiment_id") != audit.get("id"):
        raise ValueError("Comparison/audit experiment mismatch")
    verified = {r["declaration"]: r for r in audit["variants"]}
    cases = spec["cases"]
    ids = [case["id"] for case in cases]
    proofs = [case["proof"] for case in cases]
    if not cases or len(ids) != len(set(ids)) or len(proofs) != len(set(proofs)):
        raise ValueError("Duplicate or missing comparison cases")
    result_cases = []
    for case in cases:
        if not case.get("assumptions") or not case.get("conclusion"):
            raise ValueError("Missing explicit assumptions or conclusion")
        if case["proof"] not in verified:
            raise ValueError("No audited theorem for " + case["proof"])
        proof = verified[case["proof"]]
        result_cases.append({
            "id": case["id"],
            "assumptions": case["assumptions"],
            "conclusion": case["conclusion"],
            "proof": case["proof"],
            "verified": True,
            "axioms": proof["axioms"],
            "uses_classical_choice": proof["uses_classical_choice"],
            "provenance": proof["provenance"],
            "interpretation": case["interpretation"],
        })
    return {
        "schema_version": 1,
        "experiment_id": spec["experiment_id"],
        "title": spec["title"],
        "claim": spec["claim"],
        "toolchain": audit["toolchain"],
        "proof_source": str(AUDIT.relative_to(ROOT)),
        "cases": result_cases,
        "limitations": spec["limitations"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        spec = json.loads(SPEC.read_text(encoding="utf-8"))
        audit = json.loads(AUDIT.read_text(encoding="utf-8"))
        expected = json.dumps(compile_report(spec, audit), ensure_ascii=False, indent=2) + "\n"
        if args.check:
            if not OUTPUT.is_file() or OUTPUT.read_text(encoding="utf-8") != expected:
                print("STALE comparison (run --write)", file=sys.stderr)
                return 1
            print("Verified " + str(OUTPUT.relative_to(ROOT)))
        else:
            OUTPUT.parent.mkdir(parents=True, exist_ok=True)
            OUTPUT.write_text(expected, encoding="utf-8")
            print("Regenerated " + str(OUTPUT.relative_to(ROOT)))
        return 0
    except (OSError, KeyError, ValueError) as error:
        print("Comparison error: " + str(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
