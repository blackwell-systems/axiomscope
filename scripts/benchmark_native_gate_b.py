#!/usr/bin/env python3
"""Compare existing AxiomScope Gate B witness reporting to native Isabelle APIs.

The TSV is exported by GateB_NativeBaseline.ML after a successful Isabelle/ZF
session build. Native theorem dependencies, proof bodies and oracle summaries
are produced by Isabelle, not reconstructed from source files.

This is a *benchmark*, not a new proof checker. It never infers necessity,
independence or the weakest possible assumptions from dependency records.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

EXPECTED = (
    "finite_witnesses",
    "countable_family",
    "selected_family",
    "selected_union",
    "selected_to_injection",
    "choice_to_injection",
    "wellorder_to_injection",
)
SCENARIOS = ROOT / "research/foundations-v0.2/report.json"

def parse_export(raw: str) -> dict[str, dict]:
    lines = raw.splitlines()
    if len(lines) != len(EXPECTED):
        raise ValueError("Incomplete or extra native Isabelle theorem records")
    output = {}
    for line in lines:
        cells = line.split("\t")
        if len(cells) != 6:
            raise ValueError("Bad native dependency TSV field count")
        key, direct, total, local, oracles, direct_description = cells
        if key not in EXPECTED or key in output:
            raise ValueError("Unregistered or duplicate theorem ID: " + key)
        if not all(s.isdecimal() for s in (direct, total, oracles)):
            raise ValueError("Invalid dependency or oracle count")
        deps = [x for x in local.split(",") if x]
        if any(not x.startswith("GateB_") for x in deps) or len(set(deps)) != len(deps):
            raise ValueError("Invalid local named theorem dependencies")
        if len(deps) > int(total):
            raise ValueError("Local named theorem count exceeds total")
        output[key] = {
            "id": key,
            "native_immediate_theorem_count": int(direct),
            "native_transitive_named_theorem_count": int(total),
            "native_local_named_theorems": deps,
            "native_oracle_count": int(oracles),
            "native_immediate_report": direct_description,
        }
    if set(output) != set(EXPECTED):
        raise ValueError("Missing Isabelle theorem entry")
    return output


def compare(native: dict[str, dict], scenarios: dict) -> dict:
    if scenarios.get("experiment") != "foundations-v0.2-assumption-probe":
        raise ValueError("Wrong registered-proof scenario report")
    if len(scenarios.get("scenarios", [])) != 5:
        raise ValueError("Unexpected scenario count")
    outcome = {}
    for row in scenarios["scenarios"]:
        goal = next(g for g in row["goals"] if g["goal"] == "nonfinite_to_nat_injection")
        outcome[row["id"]] = {
            "registered_witness_count": len(goal["witnesses"]),
            "registered_witness_ids": [item["claim_id"] for item in goal["witnesses"]],
            "status": goal["status"],
        }
    if outcome["zf_nonfinite"]["registered_witness_count"] != 0:
        raise ValueError("Bare ZF scenario must not fabricate positive support")
    for id_ in ("zf_acomega", "zf_wellordered"):
        if outcome[id_]["registered_witness_count"] != 1:
            raise ValueError("Expected one alternate verified proof route")
    local_edges = sum(len(row["native_local_named_theorems"]) for row in native.values())
    return {
        "schema_version": 1,
        "benchmark": "native-isabelle-vs-axiomscope-assumption-witness",
        "object_logic": "Isabelle/ZF",
        "source": "Isabelle2026 Thm_Deps, Proofterm.fold_body_thms, Thm_Deps.all_oracles",
        "native": {
            "theorems_examined": len(native),
            "theorems_with_named_proof_dependencies": sum(
                bool(row["native_transitive_named_theorem_count"])
                for row in native.values()
            ),
            "local_named_dependency_references_observed": local_edges,
            "theorems_with_oracle_dependencies": sum(
                bool(row["native_oracle_count"]) for row in native.values()
            ),
            "rows": [native[key] for key in EXPECTED],
        },
        "axiomscope_existing": {
            "registered_applicability_contexts": outcome,
            "registered_witness_routes": [
                "countable_choice_infinite_has_nat_injection",
                "wellorderable_infinite_has_nat_injection",
            ],
            "prover_elaborated_signatures_checked": 3,
            "limitations": (
                "The context tags and proof routes are registered; the current "
                "engine does not infer a proof-body witness dependency graph, "
                "prove globally minimal assumptions, or derive independence."
            ),
        },
        "assessment": {
            "native_coverage_observed": local_edges > 0,
            "distinguishing_capability_demonstrated": False,
            "verdict": "NO_DIFFERENTIATION_DEMONSTRATED",
            "reason": (
                "Native Isabelle already exposes named proof dependencies and "
                "oracle evidence, whereas the AxiomScope scenario engine queries "
                "three manually registered proof contracts. The experiment has "
                "not established a new verified assumption/witness analysis."
            ),
            "limitations": (
                "Transitive proof dependencies are not a proof of minimality, "
                "logical necessity, or a negative model. If Isabelle's proof "
                "recording omits names, report missing coverage instead of "
                "inventing dependencies. Cross-system portability is untested."
            ),
            "next_decision": (
                "Do not scale the assumption-registry architecture yet; compare "
                "one second independently chosen mathematical construction and "
                "define a capability that native prover exports cannot supply."
            ),
        },
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--export", type=Path, required=True)
    ap.add_argument("--output", type=Path, required=True)
    args = ap.parse_args()
    try:
        native = parse_export(args.export.read_text(encoding="utf-8"))
        scenarios = json.loads(SCENARIOS.read_text(encoding="utf-8"))
        report = compare(native, scenarios)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print("Native Isabelle benchmark: ", report["assessment"]["verdict"])
        print("Local named references:", report["native"]["local_named_dependency_references_observed"])
        return 0
    except (ValueError, OSError, KeyError, TypeError) as e:
        print("Native Isabelle benchmark FAILED:", e, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
