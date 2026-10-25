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
```

The `lean-toolchain`, Mathlib dependency, and committed `lake-manifest.json` are pinned to **v4.35.0** and its exact dependency revisions. Run `lake update` only when intentionally updating and recommitting the lockfile. **All three initial formal results have passed Lean compilation and axiom inspection** in the [successful CI run](https://github.com/blackwell-systems/axiomscope/actions/runs/40219540458). See the [proof ledger](docs/PROOF-LEDGER.md) for the observed axiom dependencies.

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

**Experimental / v0.1.** The three baseline infinity results are machine-verified, with observed axiom dependencies documented. The proposed foundational framework itself is not established as a new mathematical theory; no new independence theorem is claimed.
