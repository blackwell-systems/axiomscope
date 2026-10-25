# Proof ledger

> **Generated file.** Do not edit directly. Regenerate with `python3 scripts/generate_proof_ledger.py --write`.

Axiom dependencies are extracted from Lean after successfully elaborating the declarations. Statements and construction descriptions come from [proofs/catalog.json](../proofs/catalog.json); machine-readable output: [proofs/dependencies.json](../proofs/dependencies.json).

| Declaration | Statement | Implementation | Axioms used |
| --- | --- | --- | --- |
| `Axiomscope.natEquivEven` | ℕ ≃ {n : ℕ // Even n} | Explicit doubling map and halving inverse (local construction) | `Quot.sound`, `propext` |
| `Axiomscope.natEquivInt` | ℕ ≃ ℤ | Reuses Mathlib's Equiv.intEquivNat.symm (Mathlib equivalence) | `Quot.sound`, `propext` |
| `Axiomscope.cantorDiagonal` | ∀ f : ℕ → Set ℕ, ¬ Function.Surjective f | Direct diagonal contradiction (local proof) | None reported |

## Scope of the audit

- The recorded dependencies are **axioms**, not the complete transitive graph of definitions and lemmas.
- An empty axiom list does **not** mean a theorem was proved without a logical system, trusted kernel, or definitions.
- Absence of `Classical.choice` in the report does not by itself guarantee executable content.
- The allowlist prevents newly introduced, unreviewed axioms from silently entering a verified record.

## Regenerate or verify

```sh
lake exe cache get
lake build
python3 scripts/generate_proof_ledger.py --write  # intentional updates
python3 scripts/generate_proof_ledger.py --check  # CI
```

CI fails if either generated file is missing or differs from a fresh successful Lean run.
