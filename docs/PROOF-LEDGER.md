# Proof ledger

> **Generated file.** Do not edit directly. Regenerate with `python3 scripts/generate_proof_ledger.py --write`.

Axiom dependencies are extracted from Lean after successfully elaborating the declarations. Statements and construction descriptions come from [proofs/catalog.json](../proofs/catalog.json); machine-readable output: [proofs/dependencies.json](../proofs/dependencies.json).

| Declaration | Statement | Implementation | Profile | Axioms used |
| --- | --- | --- | --- | --- |
| `Axiomscope.natEquivEven` | ℕ ≃ {n : ℕ // Even n} | Explicit doubling map and halving inverse (local construction) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.natEquivInt` | ℕ ≃ ℤ | Reuses Mathlib's Equiv.intEquivNat.symm (Mathlib equivalence) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.cantorDiagonal` | ∀ f : ℕ → Set ℕ, ¬ Function.Surjective f | Direct diagonal contradiction (local proof) | `choice_free` | None reported |
| `Axiomscope.Experiment001.doubleNegatedExcludedMiddle` | ∀ P : Prop, ¬¬ (P ∨ ¬P) | Direct intuitionistic contradiction proof (Experiment 001 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment001.decidableExcludedMiddle` | ∀ P : Prop, [Decidable P] → (P ∨ ¬P) | Constructive disjunction from a Decidable instance (Experiment 001 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment001.classicalExcludedMiddle` | ∀ P : Prop, P ∨ ¬P | Unrestricted excluded middle under Lean classical reasoning (Experiment 001 local proof) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |
| `Axiomscope.Experiment001.classicalDoubleNegationElim` | ∀ P : Prop, ¬¬P → P | Unrestricted double-negation elimination under classical reasoning (Experiment 001 local proof) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |

## Scope of the audit

- The recorded dependencies are **axioms**, not the complete transitive graph of definitions and lemmas.
- An empty axiom list does **not** mean a theorem was proved without a logical system, trusted kernel, or definitions.
- Absence of `Classical.choice` in the report does not by itself guarantee executable content.
- The global allowlist and per-proof profiles reject unexpected axioms or missing required classical assumptions.
- Lean's `Classical.choice` is not the ZFC Axiom of Choice.
- This audits particular proofs; it does not prove alternative proofs or models are impossible.

## Regenerate or verify

```sh
lake exe cache get
lake build
python3 scripts/generate_proof_ledger.py --write  # intentional updates
python3 scripts/generate_proof_ledger.py --check  # CI
```

CI fails if either generated file is missing or differs from a fresh successful Lean run.
