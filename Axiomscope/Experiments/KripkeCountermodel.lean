import Mathlib

/-!
# Experiment 002 — a two-world countermodel to excluded middle

A self-contained natural-deduction calculus for the one-atom fragment
{atom, bottom, disjunction, implication}, together with two-world Kripke
semantics. We prove soundness and derive nonderivability of the instance
`atom ∨ (atom → bottom)` in the empty context.

This is a nonderivability theorem for the *explicitly defined calculus*.
It is not a claim that Lean's ambient logic is intuitionistic, nor that a
failed proof search establishes independence.
-/

namespace Axiomscope.Experiment002

inductive Formula where
  | atom : Formula
  | bottom : Formula
  | disj : Formula → Formula → Formula
  | impl : Formula → Formula → Formula
  deriving DecidableEq, Repr

open Formula

/-- Two worlds, 0 (root) and 1 (future), ordered by their indices. -/
abbrev World := Fin 2

/-- Atomic truth begins at world 1 and persists to accessible worlds. -/
def forces (w : World) : Formula → Prop
  | .atom => 1 ≤ w.val
  | .bottom => False
  | .disj p q => forces w p ∨ forces w q
  | .impl p q => ∀ v : World, w.val ≤ v.val → forces v p → forces v q

/-- Truth is persistent from earlier to later worlds. -/
theorem forces_mono (p : Formula) :
    ∀ w v : World, w.val ≤ v.val → forces w p → forces v p := by
  induction p with
  | atom =>
      intro w v hwv hp
      exact Nat.le_trans hp hwv
  | bottom =>
      intro w v _ hp
      exact hp
  | disj p q ihp ihq =>
      intro w v hwv hpq
      rcases hpq with hp | hq
      · exact Or.inl (ihp w v hwv hp)
      · exact Or.inr (ihq w v hwv hq)
  | impl p q ihp ihq =>
      intro w v hwv hpq u hvu hpu
      exact hpq u (Nat.le_trans hwv hvu) hpu

/-- A finite-rule intuitionistic natural-deduction calculus. -/
inductive Provable : Set Formula → Formula → Prop where
  | assumption {Γ p} : p ∈ Γ → Provable Γ p
  | orLeft {Γ p q} : Provable Γ p → Provable Γ (.disj p q)
  | orRight {Γ p q} : Provable Γ q → Provable Γ (.disj p q)
  | orElim {Γ p q r} : Provable Γ (.disj p q) →
      Provable (Set.insert p Γ) r → Provable (Set.insert q Γ) r → Provable Γ r
  | implIntro {Γ p q} : Provable (Set.insert p Γ) q → Provable Γ (.impl p q)
  | implElim {Γ p q} : Provable Γ (.impl p q) → Provable Γ p → Provable Γ q
  | exFalso {Γ p} : Provable Γ .bottom → Provable Γ p

/-- All assumptions in the context hold at a world. -/
def holds (Γ : Set Formula) (w : World) : Prop :=
  ∀ p, p ∈ Γ → forces w p

/-- Every derivation in our calculus is valid in the two-world semantics. -/
theorem sound {Γ : Set Formula} {p : Formula} (d : Provable Γ p) :
    ∀ w : World, holds Γ w → forces w p := by
  induction d with
  | assumption hp =>
      intro w hΓ
      exact hΓ _ hp
  | orLeft hp ih =>
      intro w hΓ
      exact Or.inl (ih w hΓ)
  | orRight hq ih =>
      intro w hΓ
      exact Or.inr (ih w hΓ)
  | orElim hp hleft hright ihp ihleft ihright =>
      intro w hΓ
      rcases ihp w hΓ with h1 | h2
      · apply ihleft w
        intro x hx
        rcases Set.mem_insert_iff.mp hx with rfl | hxΓ
        · exact h1
        · exact hΓ x hxΓ
      · apply ihright w
        intro x hx
        rcases Set.mem_insert_iff.mp hx with rfl | hxΓ
        · exact h2
        · exact hΓ x hxΓ
  | implIntro hp ih =>
      intro w hΓ v hwv hPv
      apply ih v
      intro x hx
      rcases Set.mem_insert_iff.mp hx with rfl | hxΓ
      · exact hPv
      · exact forces_mono x w v hwv (hΓ x hxΓ)
  | implElim hp hq ihp ihq =>
      intro w hΓ
      exact (ihp w hΓ) w (Nat.le_refl _) (ihq w hΓ)
  | exFalso hp ih =>
      intro w hΓ
      exact (ih w hΓ).elim

/-- The excluded-middle instance for the one atomic proposition. -/
def emAtom : Formula := .disj .atom (.impl .atom .bottom)

/-- At the root the atom is not yet true, but its negation is also not true. -/
theorem root_not_forces_em : ¬ forces (0 : World) emAtom := by
  intro h
  rcases h with hAtom | hNeg
  · exact (by decide : ¬ (1 ≤ (0 : World).val)) hAtom
  · have hBottom : forces (1 : World) .bottom :=
      hNeg 1 (by decide) (by
        change 1 ≤ (1 : World).val
        decide)
    exact hBottom

/-- A sound derivation of excluded middle would contradict its countermodel. -/
theorem excludedMiddle_notDerivable :
    ¬ Provable (∅ : Set Formula) emAtom := by
  intro d
  have hRoot : forces (0 : World) emAtom :=
    sound d 0 (by
      intro p hp
      cases hp)
  exact root_not_forces_em hRoot

end Axiomscope.Experiment002

#print axioms Axiomscope.Experiment002.forces_mono
#print axioms Axiomscope.Experiment002.sound
#print axioms Axiomscope.Experiment002.root_not_forces_em
#print axioms Axiomscope.Experiment002.excludedMiddle_notDerivable
