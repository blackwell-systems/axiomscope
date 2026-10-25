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
| `Axiomscope.Experiment002.forces_mono` | ∀ φ w v, w.val ≤ v.val → forces w φ → forces v φ | Induction on formulas: truth persists to accessible worlds (Experiment 002 local semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment002.sound` | Provable Γ φ → ∀ w, holds Γ w → forces w φ | Induction over every rule of the explicit natural-deduction calculus (Experiment 002 local semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment002.root_not_forces_em` | ¬ forces root (atom ∨ (atom → ⊥)) | Two-world Kripke countermodel with atom forced only in the future (Experiment 002 local semantic proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment002.excludedMiddle_notDerivable` | ¬ Provable ∅ (atom ∨ (atom → ⊥)) | Soundness plus root countermodel yields a contradiction (Experiment 002 local semantic proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment003.forces_mono` | ∀ φ w z, w ≤ z → forces M w φ → forces M z φ | Induction proving formula persistence (General semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment003.sound` | Derives Γ φ → ∀ w, holds M Γ w → forces M w φ | Soundness by induction over the deduction rules (General semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment003.generic_em_not_derivable` | atom unforced at w, forced at z ≥ w → ¬ Derives ∅ (atom ∨ ¬atom) | Countermodel criterion using general soundness (General semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment003.two_world_em_not_derivable` | ¬ Derives ∅ (atom ∨ ¬atom) in a specific two-world model | Two-world instance with accessibility and atomic witness proofs (Concrete specialization) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |
| `Axiomscope.Experiment004.induction_rule` | ∀ P : Number → Prop, P zero → (∀ n, P n → P (succ n)) → ∀ n, P n | Structural induction over the fresh inductive type (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.recurse_unique` | A recursive function with specified zero and successor equations is unique | Induction on Number with recursion equations (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.zero_ne_succ` | ∀ n : Number, zero ≠ succ n | Constructor disjointness by case analysis (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.succ_injective` | Injective Number.succ | Constructor injectivity via equality elimination (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.toNat_ofNat` | ∀ n : Nat, toNat (ofNat n) = n | Induction on built-in Nat (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.ofNat_toNat` | ∀ n : Number, ofNat (toNat n) = n | Induction on custom Number (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.equivNat` | Number ≃ Nat | Explicit forward/inverse functions with inverse laws (Local recursive definitions and inverse proofs) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.toNat_injective` | Injective toNat | Apply inverse function to an equality (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.toNat_add` | ∀ a b, toNat (add a b) = toNat a + toNat b | Induction on second argument and Nat addition recursion (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.toNat_mul` | ∀ a b, toNat (mul a b) = toNat a * toNat b | Induction on second argument and Nat multiplication recursion (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.add_assoc` | ∀ a b c, add (add a b) c = add a (add b c) | Transport Nat associativity across injective conversion (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.add_comm` | ∀ a b, add a b = add b a | Transport Nat commutativity across injective conversion (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.mul_assoc` | ∀ a b c, mul (mul a b) c = mul a (mul b c) | Transport Nat associativity across injective conversion (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.mul_add` | ∀ a b c, mul a (add b c) = add (mul a b) (mul a c) | Transport Nat distributivity across injective conversion (Experiment 004 local proof) | `choice_free` | `propext` |

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
