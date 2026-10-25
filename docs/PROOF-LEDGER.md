# Proof ledger

This ledger records **what is implemented**, what the proof means, and what remains to be checked. Successful compilation must be established by CI before a result is labelled machine-verified.

| Declaration | Statement | Construction | Expected extra axioms | Verification |
| --- | --- | --- | --- | --- |
| `natEquivEven` | `ℕ ≃ {n : ℕ // Even n}` | Explicit doubling and halving inverse | None beyond Lean's foundations anticipated; audit required | Awaiting CI |
| `natEquivInt` | `ℕ ≃ ℤ` | Reuses `Equiv.intEquivNat.symm` from Mathlib | Audit required | Awaiting CI |
| `cantorDiagonal` | `¬Surjective (f : ℕ → Set ℕ)` | Diagonal subset constructed from arbitrary `f` | No classical reasoning intended; audit required | Awaiting CI |

The comparison of sets uses *bijection*. Even integers have natural density one-half among the positive integers, but this does not imply smaller cardinality.

## Audit procedure

```sh
lake build
lake env lean Axiomscope/CardinalExamples.lean
```

The three `#print axioms` commands at the bottom of the Lean file display the dependencies. Document the **observed** output here after a successful run; don't infer it from the import list.
