#!/usr/bin/env python3
"""Reproducible *source/provenance* gate; never substitutes for an Isabelle build.

Re-fetches pinned GitHub source files, verifies their Git blob hashes, checks
the declaration/locale/model chain, and compares a deterministic JSON report.

Usage: python3 scripts/check_foundation_gate_a.py [--check|--write]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "research/gates/a/manifest.json"
REPORT = ROOT / "research/gates/a/comparison.json"

def git_blob_sha1(raw: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest()

def pinned_url(source: dict) -> str:
    return (
        "https://raw.githubusercontent.com/"
        + source["repository"] + "/" + source["revision"] + "/" + source["path"]
    )

def source_integrity(source: dict, raw: bytes) -> None:
    if not re.fullmatch(r"[a-f0-9]{40}", source["revision"]):
        raise ValueError("Revision must be a full 40-digit Git commit")
    actual = git_blob_sha1(raw)
    if source["git_blob_sha1"] != actual:
        raise ValueError("Pinned Git blob mismatch: " + source["id"])

def check_declarations(sources: dict[str, str]) -> None:
    zf = sources["isabelle_zf_base"]
    zf_axiom = r'infinity:\s*"0 \\<in> Inf \\<and> \(\\<forall>y\\<in>Inf\. succ\(y\) \\<in> Inf\)"'
    if not re.search(zf_axiom, zf) or "axiomatization" not in zf[:zf.index("infinity:")]:
        raise ValueError("ZF_Base.infinity axiom signature is missing or changed")
    fin = sources["zffin_theory"]
    fin_axiom = (
        r'locale L_fin = set_signature \+\s*'
        r'assumes fin: "\\<not> \(\\<exists> x\. \\<emptyset> \\<epsilon> x '
        r'\\<and> \(\\<forall> y\. y \\<epsilon> x \\<longrightarrow> '
        r'setsucM y y \\<epsilon> x\)\)"'
    )
    if not re.search(fin_axiom, fin):
        raise ValueError("L_fin.fin negated Infinity assumption missing or changed")
    if not re.search(r"locale ZFfin\s*=\s*[^\n]*\+ L_fin \+", fin):
        raise ValueError("ZFfin must explicitly inherit L_fin")
    hf = sources["zffin_hf_model"]
    if not re.search(r'interpretation zfhf: ZFfin\s+"\(\\<\^bold>\\<in>\)"', hf):
        raise ValueError("HF model interpretation of ZFfin is missing")
    if 'show "ZFfin (\\<^bold>\\<in>)"' not in hf or "\nqed" not in hf:
        raise ValueError("HF model must contain a completed ZFfin proof")
    if "imports HereditarilyFinite.Rank ZFfin" not in hf:
        raise ValueError("HF model theory imports changed")
    root = sources["zffin_session"]
    if not all(s in root for s in ("session ZF_finite", "HereditarilyFinite",
                                  "ZFfin\n", "ZFfin_HF")):
        raise ValueError("AFP session root does not include the model/dependencies")
    carrier = sources["hf_carrier"]
    if 'typedef hf = "UNIV :: nat set"' not in carrier or "definition hmem" not in carrier:
        raise ValueError("HereditarilyFinite carrier and membership changed")

def build_report(manifest: dict, sources: dict[str, str]) -> dict:
    if manifest["schema_version"] != 1 or manifest["gate"] != "A":
        raise ValueError("Unexpected manifest schema/gate")
    check_declarations(sources)
    expected = {"isabelle_zf_base", "zffin_theory", "zffin_hf_model",
                "zffin_session", "hf_carrier"}
    if {s["id"] for s in manifest["sources"]} != expected:
        raise ValueError("Missing or duplicate source")
    for source in manifest["sources"]:
        if not re.fullmatch(r"[a-f0-9]{40}", source["git_blob_sha1"]):
            raise ValueError("Invalid blob pin")
    if len(manifest["cases"]) != 2 or manifest["cases"][0]["positive_inductive_set"] != "assumed" or manifest["cases"][1]["positive_inductive_set"] != "refuted":
        raise ValueError("Unexpected comparison shape")
    return {
        "schema_version": 1,
        "gate": "A",
        "question": manifest["question"],
        "status": "PINNED_SOURCE_AND_DECLARATION_CHECK",
        "isabelle_replay": "NOT_RUN_BY_SOURCE_CHECKER",
        "same_object_logic": False,
        "source_integrity": [
            {"id": s["id"], "pinned_url": pinned_url(s), "git_blob_sha1": s["git_blob_sha1"]}
            for s in manifest["sources"]
        ],
        "cases": manifest["cases"],
        "declaration_checks": [
            "ZF_Base.infinity is an explicit Isabelle/FOL axiom",
            "L_fin.fin negates the existence of an inductive set",
            "ZFfin locale inherits L_fin",
            "ZFfin_HF interprets ZFfin using hereditarily finite membership",
            "AFP session imports the HF dependency and model theories",
        ],
        "upstream_build_evidence": manifest["upstream_build_evidence"],
        "limitations": manifest["limitations"],
    }

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--write", action="store_true")
    args = parser.parse_args()
    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        contents = {}
        for source in manifest["sources"]:
            url = pinned_url(source)
            req = urllib.request.Request(url, headers={"User-Agent": "axiomscope-gate-a/1"})
            with urllib.request.urlopen(req, timeout=45) as response:
                raw = response.read()
            source_integrity(source, raw)
            contents[source["id"]] = raw.decode("utf-8")
            print("Verified pinned Git blob:", source["id"], source["git_blob_sha1"])
        serialized = json.dumps(build_report(manifest, contents), ensure_ascii=False, indent=2) + "\n"
        if args.check:
            if not REPORT.is_file() or REPORT.read_text(encoding="utf-8") != serialized:
                raise ValueError("Stale comparison report; regenerate with --write")
            print("Gate A SOURCE/PROVENANCE PASSED; Isabelle replay is separate.")
        else:
            REPORT.parent.mkdir(parents=True, exist_ok=True)
            REPORT.write_text(serialized, encoding="utf-8")
            print("Wrote", REPORT)
        return 0
    except (OSError, UnicodeError, KeyError, ValueError) as error:
        print("Gate A FAILED:", error, file=sys.stderr)
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
