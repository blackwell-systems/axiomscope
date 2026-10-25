# Experiment 001 — Excluded middle under changing assumptions

## Research question

What can we show about excluded middle *without importing a classical decision principle*, and which additional axioms do the unrestricted classical proofs actually use?

This is a controlled **proof-dependency experiment within Lean**. It is **not** a new set theory, proof of logical independence, or formal comparison between alternative models of ZFC.

## Four statements and the distinctions they test

| Proof | Logical statement | Context |
| --- | --- | --- |
| `doubleNegatedExcludedMiddle` | `¬¬ (P ∨ ¬P)` | Arbitrary proposition `P`; no classical axiom invoked |
| `decidableExcludedMiddle` | `P ∨ ¬P` | Requires an explicit `[Decidable P]` argument |
| `classicalExcludedMiddle` | `P ∨ ¬P` | Arbitrary `P`; uses Lean's classical machinery |
| `classicalDoubleNegationElim` | `¬¬P → P` | Arbitrary `P`; uses Lean's classical machinery |

The second and third rows have the same conclusion but **different contexts**. A `Decidable P` instance represents extra data: a way to decide `P`. It is not implicitly available for every proposition in constructive reasoning.

The first and fourth rows illustrate the gap: constructive logic can prove the **double negation of excluded middle**, but using double-negation elimination for arbitrary propositions is a classical step.

## Evidence

- [Lean source](../../Axiomscope/Experiments/ExcludedMiddle.lean): four checked proof declarations and `#print axioms` directives
- [Generated proof ledger](../PROOF-LEDGER.md): human-readable observed axiom dependencies
- [Generated comparison JSON](../../proofs/experiments/001-excluded-middle.json): source of machine-readable, proof-checked comparison data
- [CI verification](../../.github/workflows/lean.yml): builds Lean, tests the parser, checks that the generated reports match a fresh run

The generator rejects a classical proof whose report no longer contains `Classical.choice`, and rejects a kernel-only proof that begins using an additional axiom. That is a policy for *these proofs*, not a universal theorem.

## What this establishes—and what it doesn't

**Establishes:** These four particular proofs elaborate under Lean 4.35.0. Their `#print axioms` reports reveal exactly which of Lean's additional axiom declarations each proof references. Their profile declarations are enforced automatically.

**Does not establish:** That no alternative constructive proof could exist; that the result is independent of a formal theory; or that Lean's `Classical.choice` equals ZFC's Axiom of Choice. A claim of nonderivability needs a separate semantic or proof-theoretic argument, such as an appropriate countermodel.

**Next experiment:** formalize an intuitionistic countermodel to unrestricted excluded middle, then use it to support a genuine nonderivability claim rather than just an empirical proof audit.
