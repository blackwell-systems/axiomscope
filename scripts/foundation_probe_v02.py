#!/usr/bin/env python3
"""Foundations v0.2: conservative applicability queries over verified Gate B proofs.

This is not a theorem prover. It reports which *registered* formal proof
witnesses can discharge stated premises in a given Isabelle/ZF context.
It never infers nonderivability, independence, or cross-logic transport.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path

from scripts import check_foundation_gate_b as gate_b

ROOT = Path(__file__).resolve().parent.parent
SCENARIOS = ROOT / "research/foundations-v0.2/scenarios.json"
REPORT = ROOT / "research/foundations-v0.2/report.json"
MANIFEST = ROOT / "research/gates/b/manifest.json"

CONDITION_IDS = frozenset(("nonfinite_A", "nat_injection_A", "AComega", "wellorder_A"))
LIMITATION = (
    "No registered witness applies in this context; this does not establish "
    "non-provability, a countermodel, or independence."
)


@dataclass(frozen=True)
class ProofContract:
    goal: str
    claim_id: str
    theorem: str
    statement: str
    manifest_assumptions: tuple[str, ...]
    requires: tuple[str, ...]


# These exact contracts are checked against the machine-audited Gate B manifest.
# An arbitrary new JSON record cannot grant a theorem formal status.
CONTRACTS = (
    ProofContract(
        "nonfinite_to_nat_injection",
        "countable_choice",
        "GateB_CountableConverse.countable_choice_infinite_has_nat_injection",
        "ZF + ACω ⊢ ∀A(¬Finite(A) ⇒ nat ≲ A)",
        ("Countable Choice (ACω)",),
        ("nonfinite_A", "AComega"),
    ),
    ProofContract(
        "nonfinite_to_nat_injection",
        "wellorderable_to_injection",
        "GateB_ZF.wellorderable_infinite_has_nat_injection",
        "¬Finite(A) ∧ (∃a. Ord(a) ∧ A≈a) ⇒ nat ≲ A",
        ("A is equipotent to an ordinal",),
        ("nonfinite_A", "wellorder_A"),
    ),
    ProofContract(
        "nat_injection_to_nonfinite",
        "injection_to_infinite",
        "GateB_ZF.countable_injection_implies_infinite",
        "nat ≲ A ⇒ ¬Finite(A)",
        (),
        ("nat_injection_A",),
    ),
)
GOALS = ("nonfinite_to_nat_injection", "nat_injection_to_nonfinite")


def checked_claims(manifest: dict) -> dict[str, dict]:
    """Reject tampering and refuse claims that lack kernel-verified classification."""
    gate_b.validate(manifest, gate_b.THEORY.read_text(encoding="utf-8"))
    by_id = {c["id"]: c for c in manifest["claims"]}
    for contract in CONTRACTS:
        c = by_id[contract.claim_id]
        if (
            c["status"] != "formal_isabelle_kernel"
            or c["theorem"] != contract.theorem
            or c["statement"] != contract.statement
            or c["assumptions"] != list(contract.manifest_assumptions)
            or not c["foundational_scope"].startswith("Isabelle/ZF")
        ):
            raise ValueError("Formal proof contract changed: " + contract.claim_id)
        path = ROOT / c["source"]
        if path.parent != ROOT / "research/gates/b":
            raise ValueError("Untrusted theory source for: " + contract.claim_id)
        if not re.search(
            r"(?m)^(lemma|theorem)\s+" + re.escape(contract.theorem.split(".")[-1]) + r":",
            path.read_text(encoding="utf-8"),
        ):
            raise ValueError("Theorem declaration missing: " + contract.claim_id)
    return by_id


def evaluate(config: dict, manifest: dict) -> dict:
    if config.get("schema_version") != 1 or config.get("logic") != "Isabelle/ZF":
        raise ValueError("Only Isabelle/ZF schema v1 is supported")
    claims = checked_claims(manifest)
    scenarios = config.get("scenarios")
    if not isinstance(scenarios, list) or not scenarios:
        raise ValueError("At least one scenario is required")
    names: set[str] = set()
    results = []
    for scenario in scenarios:
        name = scenario.get("id")
        conditions = scenario.get("conditions")
        if not isinstance(name, str) or not re.fullmatch(r"[a-z][a-z0-9_]*", name):
            raise ValueError("Invalid scenario identifier")
        if name in names:
            raise ValueError("Duplicate scenario: " + name)
        names.add(name)
        if (
            not isinstance(conditions, list)
            or len(set(conditions)) != len(conditions)
            or any(not isinstance(c, str) or c not in CONDITION_IDS for c in conditions)
        ):
            raise ValueError("Unknown or duplicated scenario conditions: " + name)
        available = set(conditions)
        goal_results = []
        for goal in GOALS:
            usable = []
            missing = []
            for proof in CONTRACTS:
                if proof.goal != goal:
                    continue
                needed = set(proof.requires)
                detail = {
                    "claim_id": proof.claim_id,
                    "theorem": claims[proof.claim_id]["theorem"],
                    "source": claims[proof.claim_id]["source"],
                }
                if needed <= available:
                    usable.append(detail)
                else:
                    missing.append({
                        **detail,
                        "missing_conditions": sorted(needed - available),
                    })
            goal_results.append({
                "goal": goal,
                "status": "supported_by_registered_proof" if usable else "no_registered_witness",
                "witnesses": usable,
                "candidate_requirements": [] if usable else missing,
                "caveat": None if usable else LIMITATION,
            })
        results.append({
            "id": name,
            "conditions": sorted(conditions),
            "goals": goal_results,
        })

    contrast_results = []
    by_scenario = {s["id"]: s for s in results}
    for contrast in config.get("contrasts", []):
        start, end = contrast.get("from"), contrast.get("to")
        if start not in names or end not in names or start == end:
            raise ValueError("Invalid scenario contrast")
        start_goals = {g["goal"]: g for g in by_scenario[start]["goals"]}
        end_goals = {g["goal"]: g for g in by_scenario[end]["goals"]}
        contrast_results.append({
            "from": start,
            "to": end,
            "lost_registered_support": [
                goal for goal in GOALS
                if start_goals[goal]["status"] == "supported_by_registered_proof"
                and end_goals[goal]["status"] == "no_registered_witness"
            ],
            "interpretation": "Loss of a registered usable proof, not a proof of nonderivability.",
        })
    return {
        "schema_version": 1,
        "experiment": "foundations-v0.2-assumption-probe",
        "logic": "Isabelle/ZF",
        "source_manifest": "research/gates/b/manifest.json",
        "scope": (
            "Conditional application of known, formally classified proofs within "
            "one object logic; not proof translation, theorem search, or independence."
        ),
        "scenarios": results,
        "contrasts": contrast_results,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--check", action="store_true")
    action.add_argument("--write", action="store_true")
    options = parser.parse_args()
    try:
        config = json.loads(SCENARIOS.read_text(encoding="utf-8"))
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        output = json.dumps(evaluate(config, manifest), ensure_ascii=False, indent=2) + "\n"
        if options.check:
            if not REPORT.exists() or REPORT.read_text(encoding="utf-8") != output:
                raise ValueError("Foundations v0.2 report drift; regenerate with --write")
            print("Foundations v0.2 scenario report is consistent")
        else:
            REPORT.write_text(output, encoding="utf-8")
            print("Regenerated", REPORT)
        return 0
    except (ValueError, OSError, KeyError, TypeError) as error:
        print("Foundations v0.2 validation FAILED:", error, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
