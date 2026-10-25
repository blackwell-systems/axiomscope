import Mathlib

/-!
# Experiment 001 — Excluded middle and assumptions

These declarations audit *specific Lean proofs*. Their dependency lists
are not a metatheoretic proof of nonderivability in another logical system.

Lean's `Classical.choice` and ZFC's Axiom of Choice are different notions.
-/

namespace Axiomscope.Experiment001

/-- Intuitionistic logic proves the double negation of excluded middle. -/
theorem doubleNegatedExcludedMiddle (P : Prop) : ¬¬ (P ∨ ¬ P) := by
  intro h
  apply h
  right
  intro hp
  exact h (Or.inl hp)

/-- When P has an explicit decision procedure, P ∨ ¬ P is constructible. -/
theorem decidableExcludedMiddle (P : Prop) [Decidable P] : P ∨ ¬ P :=
  Decidable.em P

/-- Unrestricted excluded middle using Lean's classical instance. -/
theorem classicalExcludedMiddle (P : Prop) : P ∨ ¬ P := by
  classical
  exact em P

/-- Unrestricted double-negation elimination under classical reasoning. -/
theorem classicalDoubleNegationElim (P : Prop) : ¬¬ P → P := by
  classical
  exact not_not.mp

end Axiomscope.Experiment001

#print axioms Axiomscope.Experiment001.doubleNegatedExcludedMiddle
#print axioms Axiomscope.Experiment001.decidableExcludedMiddle
#print axioms Axiomscope.Experiment001.classicalExcludedMiddle
#print axioms Axiomscope.Experiment001.classicalDoubleNegationElim
