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
lake update
lake exe cache get
lake build
lake env lean Axiomscope/CardinalExamples.lean
```

The `lean-toolchain` and Mathlib dependency are paired at **v4.35.0**. The CI workflow checks the build automatically. **Until CI passes, treat the source as a formalization candidate, not as a verified theorem.**

## Working principles

1. **Precision first.** State the underlying universe, type, equivalence relation, and proof obligations.
2. **Construction provenance.** Distinguish a witness-producing proof from existence inferred by other principles.
3. **Explicit dependency accounting.** Audit which axioms a theorem actually uses; do not confuse library imports with proof dependencies.
4. **No conflation of sizes.** Cardinality, density, measure, and order type answer different questions.
5. **Independent results stay independent.** Changing foundations does not automatically resolve ZFC-independent propositions.
6. **Compatibility before novelty.** Document what Mathlib, ZFC, ETCS, constructive set theory, and type theory already provide before claiming any new result.

## Documents

- [Foundations v0.1 specification](docs/FOUNDATIONS-v0.1.md)
- [Proof ledger](docs/PROOF-LEDGER.md)
- [Research roadmap](docs/ROADMAP.md)

## Status

**Experimental / v0.1.** Formal proof compilation and assumption auditing are the first acceptance gates. No replacement theory or new independence theorem is claimed.
