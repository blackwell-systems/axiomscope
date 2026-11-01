"""Extract a narrow, auditable subset of Isabelle/ZF declaration signatures.

This does NOT inspect proof terms, transitive theorem dependencies, or
implicit Isabelle context. Only named, quoted premises and conclusions
from existing top-level lemma/theorem declarations are supported.

Unrecognized syntax fails closed; the Isabelle kernel still checks proofs.
"""
from __future__ import annotations

from dataclasses import dataclass
import re

_DECL = re.compile(r"(?m)^(?:lemma|theorem)\s+([A-Za-z_][A-Za-z_0-9]*)\s*:\s*$")
_END = re.compile(r"^\s*(?:proof|using|by|unfolding|apply|done|sorry|oops)\b")
_TOKEN = re.compile(r'\s+|"([^"]*)"|([A-Za-z_][A-Za-z_0-9]*):|\b(assumes|shows|and)\b')


@dataclass(frozen=True)
class Signature:
    premises: tuple[str, ...]
    conclusion: str


def extract_signature(source: str, theorem: str) -> Signature:
    """Parse one exact declaration header; reject unsupported Isabelle syntax."""
    declarations = [m for m in _DECL.finditer(source) if m.group(1) == theorem]
    if len(declarations) != 1:
        raise ValueError("Expected exactly one theorem declaration: " + theorem)

    tail = source[declarations[0].end():].splitlines()
    header_lines: list[str] = []
    terminated = False
    for line in tail:
        if _END.match(line):
            terminated = True
            break
        if _DECL.match(line):
            raise ValueError("Declaration lacks a recognized proof boundary: " + theorem)
        header_lines.append(line)
    if not terminated:
        raise ValueError("Unterminated declaration: " + theorem)

    header = "\n".join(header_lines)
    pos = 0
    stage = "start"
    premises: list[str] = []
    conclusions: list[str] = []
    while pos < len(header):
        match = _TOKEN.match(header, pos)
        if match is None:
            raise ValueError("Unsupported declaration syntax: " + theorem)
        pos = match.end()
        quote, label, keyword = match.groups()
        if quote is not None:
            if stage == "assumes":
                premises.append(quote)
            elif stage == "shows":
                conclusions.append(quote)
            else:
                raise ValueError("Quoted proposition outside a section: " + theorem)
        elif label is not None:
            if stage != "assumes":
                raise ValueError("Unsupported theorem label placement: " + theorem)
        elif keyword == "assumes":
            if stage != "start":
                raise ValueError("Duplicate or misplaced assumes section: " + theorem)
            stage = "assumes"
        elif keyword == "and":
            if stage != "assumes":
                raise ValueError("Conjunction outside assumptions: " + theorem)
        elif keyword == "shows":
            if stage not in ("assumes", "start"):
                raise ValueError("Duplicate or misplaced shows section: " + theorem)
            stage = "shows"

    if len(conclusions) != 1 or not conclusions[0]:
        raise ValueError("Exactly one quoted conclusion required: " + theorem)
    if any(not premise for premise in premises) or len(set(premises)) != len(premises):
        raise ValueError("Duplicate or empty theorem premises: " + theorem)
    return Signature(tuple(premises), conclusions[0])
