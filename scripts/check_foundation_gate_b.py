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
ASSEMBLE_THEORY = ROOT / "research/gates/b/GateB_Assemble.thy"
ENUM_INTRO = ROOT / "research/gates/b/GateB_EnumerationIntro.thy"
ENUM_LEAST = ROOT / "research/gates/b/GateB_EnumerationLeast.thy"
ENUM_THEORY = ROOT / "research/gates/b/GateB_Enumeration.thy"
CONVERSE_THEORY = ROOT / "research/gates/b/GateB_CountableConverse.thy"
SESSION_ROOT = ROOT / "research/gates/b/ROOT"
CHOICE_THEORY = ROOT / "research/gates/b/GateB_CountableChoice.thy"
REPORT = ROOT / "research/gates/b/comparison.json"

FORMAL = {"injection_to_infinite", "wellorderable_to_injection",
          "finite_injection_candidates", "countable_choice_finite_witnesses",
          "selected_union_infinite", "countable_choice_yields_infinite_enumerated_union",
          "selected_union_lepoll_nat", "selected_union_has_nat_injection",
          "countable_choice", "dedekind_forward", "dedekind_reverse",
          "dedekind_equivalence"}
PUBLISHED = {"cohen_symmetric_countermodel"}


def validate(manifest: dict, theory: str, choice_theory: str | None = None,
             assemble_theory: str | None = None, extra_theories: dict[str, str] | None = None) -> dict:
    if choice_theory is None:
        choice_theory = CHOICE_THEORY.read_text(encoding="utf-8")
    if assemble_theory is None:
        assemble_theory = ASSEMBLE_THEORY.read_text(encoding="utf-8")
    if extra_theories is None:
        extra_theories = {
            "research/gates/b/GateB_EnumerationIntro.thy": ENUM_INTRO.read_text(encoding="utf-8"),
            "research/gates/b/GateB_EnumerationLeast.thy": ENUM_LEAST.read_text(encoding="utf-8"),
            "research/gates/b/GateB_Enumeration.thy": ENUM_THEORY.read_text(encoding="utf-8"),
            "research/gates/b/GateB_CountableConverse.thy": CONVERSE_THEORY.read_text(encoding="utf-8"),
        }
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
    if not re.search(r"theory GateB_CountableChoice\s+imports GateB_ZF\s+begin", choice_theory):
        raise ValueError("Countable choice must be within the Isabelle/ZF object theory")
    if "definition countable_choice :: o" not in choice_theory:
        raise ValueError("Missing explicit ZF countable-choice proposition")
    if re.search(r"(?m)^\s*(sorry|oops|axiomatization)\b", choice_theory):
        raise ValueError("Untrusted choice theory proof or new axiom forbidden")
    if not re.search(r"theory GateB_Assemble\s+imports GateB_CountableChoice\s+begin", assemble_theory):
        raise ValueError("Assembly must import checked Isabelle/ZF choice theory")
    if re.search(r"(?m)^\s*(sorry|oops|axiomatization)\b", assemble_theory):
        raise ValueError("Admitted assembly proof or new axiom forbidden")
    imports = {
        "research/gates/b/GateB_EnumerationIntro.thy": "theory GateB_EnumerationIntro\n  imports GateB_Assemble\nbegin",
        "research/gates/b/GateB_EnumerationLeast.thy": "theory GateB_EnumerationLeast\n  imports GateB_EnumerationIntro\nbegin",
        "research/gates/b/GateB_Enumeration.thy": "theory GateB_Enumeration\n  imports GateB_EnumerationLeast\nbegin",
        "research/gates/b/GateB_CountableConverse.thy": "theory GateB_CountableConverse\n  imports GateB_Enumeration\nbegin",
    }
    if set(extra_theories) != set(imports):
        raise ValueError("Missing or unexpected Isabelle/ZF theory")
    for path, expected_header in imports.items():
        source_text = extra_theories[path]
        if not source_text.startswith(expected_header):
            raise ValueError("Broken object-logic import chain: " + path)
        if re.search(r"(?m)^\s*(sorry|oops|axiomatization)\b", source_text):
            raise ValueError("Admitted proof or extra axiom in " + path)
    converse = extra_theories["research/gates/b/GateB_CountableConverse.thy"]
    if not all(s in converse for s in (
        "theorem countable_choice_infinite_has_nat_injection:",
        'assumes inf: "\\<not> Finite(A)" and cc: "countable_choice"',
        'shows "has_nat_injection(A)"',
    )):
        raise ValueError("Positive theorem signature must assert ZF plus object-level ACω only")
    bridge_signatures = (
        'lemma nat_injection_gives_proper_self_embedding:',
        'assumes countable: "has_nat_injection(A)"',
        'shows "has_proper_self_embedding(A)"',
        'lemma proper_self_embedding_gives_nat_injection:',
        'assumes proper: "has_proper_self_embedding(A)"',
        'theorem dedekind_infinity_equivalence:',
        '"has_nat_injection(A) \<longleftrightarrow> has_proper_self_embedding(A)"',
    )
    if not all(fragment in converse for fragment in bridge_signatures):
        raise ValueError("Dedekind-infinity bridge signature must remain explicit")
    if "GateB_CountableConverse" not in SESSION_ROOT.read_text(encoding="utf-8"):
        raise ValueError("Gate B Isabelle session does not compile the positive theorem")
    by_id = {claim["id"]: claim for claim in entries}
    for key in FORMAL:
        c = by_id[key]
        if c["status"] != "formal_isabelle_kernel":
            raise ValueError("Incorrect proof evidence class " + key)
        sources = {
            "research/gates/b/GateB_ZF.thy": ("GateB_ZF.", theory),
            "research/gates/b/GateB_CountableChoice.thy": ("GateB_CountableChoice.", choice_theory),
            "research/gates/b/GateB_Assemble.thy": ("GateB_Assemble.", assemble_theory),
            **{p: (p.rsplit("/", 1)[-1].removesuffix(".thy") + ".", t) for p, t in extra_theories.items()},
        }
        if c.get("source") not in sources or not c.get("theorem"):
            raise ValueError("A formal claim must have exact source and theorem")
        prefix, theorem_source = sources[c["source"]]
        if not c["theorem"].startswith(prefix):
            raise ValueError("Theorem name and declared theory source do not match")
        local_name = c["theorem"].split(".")[-1]
        if not re.search(r"(?m)^(?:lemma|theorem)\s+" + re.escape(local_name) + r"\s*:", theorem_source):
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
        "status": "POSITIVE_COUNTABLE_CHOICE_AND_DEDEKIND_EQUIVALENCE_VERIFIED; NEGATIVE_MODEL_PUBLISHED_ONLY",
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
        choice_theory = CHOICE_THEORY.read_text(encoding="utf-8")
        assemble_theory = ASSEMBLE_THEORY.read_text(encoding="utf-8")
        out = json.dumps(validate(manifest, theory, choice_theory, assemble_theory), ensure_ascii=False, indent=2) + "\n"
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
