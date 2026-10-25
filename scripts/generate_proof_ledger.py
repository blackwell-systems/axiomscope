#!/usr/bin/env python3
"""Generate machine-readable axiom dependencies from Lean.

Usage:
  python3 scripts/generate_proof_ledger.py --write
  python3 scripts/generate_proof_ledger.py --check

Axiom lists come from a *successful* Lean invocation, not from catalogue
metadata or a previously committed JSON file.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "proofs/catalog.json"
OUTPUT_JSON = ROOT / "proofs/dependencies.json"
OUTPUT_MD = ROOT / "docs/PROOF-LEDGER.md"
EXPERIMENTS_DIR = ROOT / "proofs/experiments"
B = chr(96)  # Markdown code delimiter
REPORT = re.compile(
    r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|(does not depend on any axioms))"
)


class LedgerError(Exception):
    pass


def parse_axioms(output: str, expected: set[str]) -> dict[str, list[str]]:
    """Require exactly one axiom report per registered Lean declaration."""
    results = {}
    for line in output.splitlines():
        for match in REPORT.finditer(line):
            name, listed, none = match.groups()
            if name not in expected:
                raise LedgerError(f"Unexpected declaration in Lean output: {name}")
            if name in results:
                raise LedgerError(f"Duplicate report for {name}")
            axioms = [item.strip() for item in listed.split(",")] if listed else []
            if any(not re.fullmatch(r"[\w.]+", x) for x in axioms):
                raise LedgerError(f"Malformed axiom list for {name}")
            if len(set(axioms)) != len(axioms):
                raise LedgerError(f"Repeated axiom for {name}")
            results[name] = sorted(axioms)
    missing = expected - results.keys()
    if missing:
        raise LedgerError("Missing Lean axiom reports: " + ", ".join(sorted(missing)))
    return results


def run_lean(sources: list[str]) -> str:
    """Elaborate every registered proof module, rejecting failures."""
    outputs = []
    for source in sources:
        try:
            process = subprocess.run(
                ["lake", "env", "lean", source],
                cwd=ROOT, capture_output=True, text=True, check=False
            )
        except FileNotFoundError as error:
            raise LedgerError("Lake is unavailable; install Lean and run lake build.") from error
        if process.returncode:
            raise LedgerError(
                f"Lean failed on {source} (exit {process.returncode}); refusing records:\n"
                + (process.stdout + process.stderr)[-3500:]
            )
        outputs.append(process.stdout + "\n" + process.stderr)
    return "\n".join(outputs)


def collect(catalog: dict, output: str, toolchain: str) -> dict:
    if catalog.get("schema_version") != 1:
        raise LedgerError("Unsupported catalog schema")
    entries = catalog.get("declarations")
    allowed = catalog.get("allowed_axioms")
    profiles = catalog.get("axiom_profiles", {})
    if not isinstance(profiles, dict):
        raise LedgerError("Invalid axiom profiles")
    if not isinstance(entries, list) or not entries:
        raise LedgerError("Empty or invalid declaration catalog")
    if not isinstance(allowed, list) or len(set(allowed)) != len(allowed):
        raise LedgerError("Invalid allowed_axioms")
    names = [e["declaration"] for e in entries]
    if len(set(names)) != len(names):
        raise LedgerError("Duplicate catalog declarations")
    for entry in entries:
        for key in ("declaration", "statement", "source", "kind", "construction", "provenance"):
            if not isinstance(entry.get(key), str) or not entry[key].strip():
                raise LedgerError(f"Missing {key} metadata")
        profile = entry.get("foundation_profile", "choice_free")
        if profile not in profiles:
            raise LedgerError(f"Unknown foundation profile: {profile}")
        source = (ROOT / entry["source"]).resolve()
        if not source.is_file() or not source.is_relative_to(ROOT):
            raise LedgerError(f"Missing/outside source file: {entry['source']}")
    parsed = parse_axioms(output, set(names))
    records = []
    for entry in entries:
        axioms = parsed[entry["declaration"]]
        unapproved = set(axioms) - set(allowed)
        if unapproved:
            raise LedgerError(
                entry["declaration"] + " uses unapproved axiom(s): "
                + ", ".join(sorted(unapproved))
                + ". Explicit review and catalog change required."
            )
        profile_name = entry.get("foundation_profile", "choice_free")
        profile = profiles[profile_name]
        permitted = set(profile["allowed_axioms"])
        required = set(profile["required_axioms"])
        if not permitted <= set(allowed) or not required <= permitted:
            raise LedgerError(f"Invalid profile rules: {profile_name}")
        if set(axioms) - permitted:
            raise LedgerError(
                entry["declaration"] + " violates profile " + profile_name
                + ": " + ", ".join(sorted(set(axioms) - permitted))
            )
        if required - set(axioms):
            raise LedgerError(
                entry["declaration"] + " does not exhibit required axioms for "
                + profile_name + ": " + ", ".join(sorted(required - set(axioms)))
            )
        records.append({
            "declaration": entry["declaration"],
            "statement": entry["statement"],
            "source": entry["source"],
            "kind": entry["kind"],
            "construction": entry["construction"],
            "provenance": entry["provenance"],
            "foundation_profile": profile_name,
            **({"experiment": entry["experiment"], "variant": entry["variant"]}
               if "experiment" in entry else {}),
            "axioms": axioms,
            "uses_classical_choice": "Classical.choice" in axioms,
        })
    return {
        "schema_version": 1,
        "toolchain": toolchain,
        "source_of_axioms": "Lean #print axioms (successful elaboration)",
        "generator": "scripts/generate_proof_ledger.py",
        "records": records,
    }


def markdown(data: dict) -> str:
    lines = [
        "# Proof ledger", "",
        "> **Generated file.** Do not edit directly. Regenerate with "
        + B + "python3 scripts/generate_proof_ledger.py --write" + B + ".",
        "",
        "Axiom dependencies are extracted from Lean after successfully elaborating "
        "the declarations. Statements and construction descriptions come from "
        + "[proofs/catalog.json](../proofs/catalog.json); machine-readable output: "
        + "[proofs/dependencies.json](../proofs/dependencies.json).",
        "",
        "| Declaration | Statement | Implementation | Profile | Axioms used |",
        "| --- | --- | --- | --- | --- |",
    ]
    for record in data["records"]:
        axioms = ", ".join(B + a + B for a in record["axioms"]) or "None reported"
        lines.append(
            "| " + B + record["declaration"] + B + " | "
            + record["statement"].replace("|", "\\|") + " | "
            + record["construction"].replace("|", "\\|") + " ("
            + record["provenance"] + ") | "
            + B + record["foundation_profile"] + B + " | " + axioms + " |"
        )
    lines.extend([
        "", "## Scope of the audit", "",
        "- The recorded dependencies are **axioms**, not the complete transitive "
        "graph of definitions and lemmas.",
        "- An empty axiom list does **not** mean a theorem was proved without "
        "a logical system, trusted kernel, or definitions.",
        "- Absence of " + B + "Classical.choice" + B
        + " in the report does not by itself guarantee executable content.",
        "- The global allowlist and per-proof profiles reject unexpected axioms or "
        "missing required classical assumptions.",
        "- Lean's " + B + "Classical.choice" + B + " is not the ZFC Axiom of Choice.",
        "- This audits particular proofs; it does not prove alternative proofs "
        "or models are impossible.",
        "", "## Regenerate or verify", "", B * 3 + "sh",
        "lake exe cache get",
        "lake build",
        "python3 scripts/generate_proof_ledger.py --write  # intentional updates",
        "python3 scripts/generate_proof_ledger.py --check  # CI",
        B * 3,
        "",
        "CI fails if either generated file is missing or differs from a fresh "
        "successful Lean run.", "",
    ])
    return "\n".join(lines)


def experiment_reports(catalog: dict, data: dict) -> dict[str, str]:
    """Build independently checkable comparison records from audited declarations."""
    by_name = {record["declaration"]: record for record in data["records"]}
    generated = {}
    for exp in catalog.get("experiments", []):
        exp_id = exp["id"]
        if not re.fullmatch(r"[0-9]{3}-[a-z0-9-]+", exp_id) or exp_id in generated:
            raise LedgerError(f"Invalid or duplicate experiment ID: {exp_id}")
        names = exp["variants"]
        if not names or len(set(names)) != len(names):
            raise LedgerError(f"Invalid variants in {exp_id}")
        for name in names:
            if name not in by_name or by_name[name].get("experiment") != exp_id:
                raise LedgerError(f"Experiment variant not registered: {name}")
        actual = {record["declaration"] for record in data["records"]
                  if record.get("experiment") == exp_id}
        if actual != set(names):
            raise LedgerError(f"Incomplete experiment variant list: {exp_id}")
        report = {
            "schema_version": 1,
            "id": exp_id,
            "question": exp["question"],
            "scope": exp["scope"],
            "toolchain": data["toolchain"],
            "variants": [by_name[name] for name in names],
        }
        generated[exp_id] = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    recorded = {record["experiment"] for record in data["records"]
                if "experiment" in record}
    if recorded != set(generated):
        raise LedgerError(f"Missing experiment registration: {recorded - set(generated)}")
    return generated


def sync_file(path: Path, content: str, check: bool) -> bool:
    if check:
        if not path.exists() or path.read_text(encoding="utf-8") != content:
            print(f"STALE: {path.relative_to(ROOT)} (run --write and commit)", file=sys.stderr)
            return False
        print(f"Verified {path.relative_to(ROOT)}")
        return True
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    print(f"Regenerated {path.relative_to(ROOT)}")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--check", action="store_true")
    group.add_argument("--write", action="store_true")
    args = parser.parse_args()
    try:
        catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
        output = run_lean(sorted({e["source"] for e in catalog["declarations"]}))
        toolchain = (ROOT / "lean-toolchain").read_text(encoding="utf-8").strip()
        data = collect(catalog, output, toolchain)
        as_json = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
        one = sync_file(OUTPUT_JSON, as_json, args.check)
        two = sync_file(OUTPUT_MD, markdown(data), args.check)
        additional = [
            sync_file(EXPERIMENTS_DIR / (exp_id + ".json"), report, args.check)
            for exp_id, report in experiment_reports(catalog, data).items()
        ]
        return 0 if one and two and all(additional) else 1
    except (LedgerError, ValueError, KeyError, OSError) as error:
        print(f"Proof ledger error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
