import Mathlib

/-!
# First experiment: infinity and cardinality

The initial formal results intentionally use established Lean/Mathlib foundations.
Nothing in this file defines a new set theory or resolves an independent statement.

The examples concern equivalences of types: a bijection witnesses equal cardinality.
-/-

namespace Axiomscope

/-- The subtype consisting of natural numbers that are even. -/
abbrev EvenNat := { n : ℕ // Even n }

/-- Double a natural number, retaining a proof that the result is even. -/
def twice (n : ℕ) : EvenNat :=
  ⟨2 * n, ⟨n, by omega⟩⟩

/--
An explicit equivalence between the naturals and their even subset.

The inverse halves each even number. Both inverse laws are checked, rather
than inferring them from a sample of values.
-/
def natEquivEven : ℕ ≃ EvenNat where
  toFun := twice
  invFun := fun e => e.val / 2
  left_inv := by
    intro n
    simp [twice]
  right_inv := by
    intro e
    apply Subtype.ext
    obtain ⟨k, hk⟩ := e.property
    dsimp [twice]
    omega

/--
A constructive equivalence between the naturals and the integers.

This initial implementation delegates to Mathlib's established explicit
equivalence, built via a sum-of-naturals encoding. It does *not* depend on
any assertion that the integers are exhausted by a finite prefix.
-/
def natEquivInt : ℕ ≃ ℤ :=
  Equiv.intEquivNat.symm

/--
Cantor's diagonal theorem, stated as the impossibility of enumerating
all subsets of natural numbers.

For any proposed enumeration f, the diagonal subset
    D = { n | n ∉ f n }
cannot appear at its own index. This is a constructive contradiction.
-/
theorem cantorDiagonal (f : ℕ → Set ℕ) : ¬ Function.Surjective f := by
  intro hf
  obtain ⟨a, ha⟩ := hf { n | n ∉ f n }
  exact iff_not_self (Iff.of_eq (congrArg (a ∈ ·) ha))

end Axiomscope

-- Inspect the actual trusted axioms used by each declaration.
#print axioms Axiomscope.natEquivEven
#print axioms Axiomscope.natEquivInt
#print axioms Axiomscope.cantorDiagonal
