# Proof ledger

The three baseline formal results were checked by Lean 4.35.0 and Mathlib v4.35.0 in the [successful CI run on October 25, 2026](https://github.com/blackwell-systems/axiomscope/actions/runs/40219540458). The recorded dependencies are the **actual output of Lean's `#print axioms`**, not guesses based on imported modules.

| Declaration | Statement | Implementation | Observed axioms | Verification |
| --- | --- | --- | --- | --- |
| `natEquivEven` | `ℕ ≃ {n : ℕ // Even n}` | Explicit doubling/halving inverse | `propext`, `Quot.sound` | Passed |
| `natEquivInt` | `ℕ ≃ ℤ` | Reuses `Equiv.intEquivNat.symm` from Mathlib | `propext`, `Quot.sound` | Passed |
| `cantorDiagonal` | `¬ Function.Surjective (f : ℕ → Set ℕ)` for any `f` | Diagonal subset `{n | n ∉ f n}` | None listed | Passed |

## Observed Lean output

```text
'Axiomscope.natEquivEven' depends on axioms: [propext, Quot.sound]
'Axiomscope.natEquivInt' depends on axioms: [propext, Quot.sound]
'Axiomscope.cantorDiagonal' does not depend on any axioms
```

None of the three declarations lists `Classical.choice`. “No axioms listed” for the diagonal theorem refers to Lean's extra axiom declarations; it **does not** mean the result needs no logical system, definitions, or trusted proof checker.

The comparison uses *bijection*. The even positive integers have natural density one-half among the positive integers, but the same cardinality. No definition of density is used to prove the bijection.

## Reproduce

```sh
lake exe cache get
lake build
lake env lean Axiomscope/CardinalExamples.lean
```

Check that the last command prints the dependencies above. The manifest is intentionally committed; `lake update` is for deliberate dependency changes, not routine verification.

## Remaining work

- Audit the proofs' intended constructivity claims beyond the presence or absence of `Classical.choice`.
- Implement the natural–integer bijection without delegating to Mathlib.
- Generate a structured machine-readable ledger rather than maintaining this record manually.
