# AXIOMSCOPE

**Proofs carry their assumptions.**

AXIOMSCOPE is an experimental project in foundations of mathematics. Its first goal is not to replace ZFC or introduce unsupported new axioms: it is to make the objects, proof principles, constructions, and limitations behind familiar theorems explicit and mechanically checkable.

The initial work uses **Lean 4 and Mathlib**, which provide an established logical foundation and a small trusted kernel. AxiomScope v0.1 is a research *scaffold*, not yet a distinct axiomatic system.

## First experiment: three facts about infinity

| Result | Formal artifact | Interpretation |
| --- | --- | --- |
| The natural numbers correspond bijectively to the even natural numbers | `Axiomscope.natEquivEven` | Cardinality need not measure natural density |
| The natural numbers correspond bijectively to the integers | `Axiomscope.natEquivInt` | Adding infinitely many negative integers need not increase cardinality |
| No function from the naturals onto their power set is surjective | `Axiomscope.cantorDiagonal` | The power set is strictly larger in the relevant cardinal sense |

The even-number bijection is written out explicitly. The integer bijection initially reuses Mathlib's constructive equivalence `Equiv.intEquivNat`; rewriting it from scratch is a later educational exercise. Cantor's diagonal argument is written out directly.

## Build

Install [Lean 4 through elan](https://lean-lang.org/install/manual/), then run:

```sh
lake exe cache get
lake build
lake env lean Axiomscope/CardinalExamples.lean
python3 -m unittest discover -s scripts/tests -v
python3 scripts/generate_proof_ledger.py --check
```

The `lean-toolchain`, Mathlib dependency, and committed `lake-manifest.json` are pinned to **v4.35.0** and its exact dependency revisions. Run `lake update` only when intentionally updating and recommitting the lockfile. **All three initial formal results have passed Lean compilation and axiom inspection** in the [successful CI run](https://github.com/blackwell-systems/axiomscope/actions/runs/40219540458). See the [proof ledger](docs/PROOF-LEDGER.md) for the observed axiom dependencies.

The proof ledger is **generated**, not manually maintained. After editing proofs, run `python3 scripts/generate_proof_ledger.py --write` and commit both `proofs/dependencies.json` and `docs/PROOF-LEDGER.md`. CI recomputes their axiom lists from Lean and rejects drift or unapproved axioms. Only the mathematical descriptions and construction provenance in `proofs/catalog.json` are manually curated. This is an *axiom-dependency* report, not yet a complete transitive lemma-dependency graph.

## Working principles

1. **Precision first.** State the underlying universe, type, equivalence relation, and proof obligations.
2. **Construction provenance.** Distinguish a witness-producing proof from existence inferred by other principles.
3. **Explicit dependency accounting.** Audit which axioms a theorem actually uses; do not confuse library imports with proof dependencies.
4. **No conflation of sizes.** Cardinality, density, measure, and order type answer different questions.
5. **Independent results stay independent.** Changing foundations does not automatically resolve ZFC-independent propositions.
6. **Compatibility before novelty.** Document what Mathlib, ZFC, ETCS, constructive set theory, and type theory already provide before claiming any new result.

## Documents

- [Foundations v0.1 specification](docs/FOUNDATIONS-v0.1.md)
- [Generated proof ledger](docs/PROOF-LEDGER.md)
- [Machine-readable axiom dependencies](proofs/dependencies.json)
- [Declaration metadata catalogue](proofs/catalog.json)
- [Research roadmap](docs/ROADMAP.md)

## Status

**Experimental / v0.1.** The three baseline infinity results are machine-verified, with observed axiom dependencies documented. The proposed foundational framework itself is not established as a new mathematical theory; no new independence theorem is claimed.
