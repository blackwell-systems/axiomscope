import Mathlib

/-!
# Experiment 003 — parameterized Kripke semantics

Generalize Experiment 002 from one atom and two fixed worlds to
arbitrary types of atoms and preordered worlds. A model supplies a
persistent valuation for atoms. We prove semantic persistence and
soundness of a small intuitionistic natural deduction calculus.

A general countermodel criterion demonstrates why a proposition
that is undecided at one world but becomes true at an accessible
world refutes its excluded-middle instance.

This is a standard metatheorem, not a novelty or ZFC independence claim.
-/

namespace Axiomscope.Experiment003

universe u v

inductive Formula (Atom : Type u) where
  | atom : Atom → Formula Atom
  | bottom : Formula Atom
  | disj : Formula Atom → Formula Atom → Formula Atom
  | impl : Formula Atom → Formula Atom → Formula Atom

inductive Derives {Atom : Type u} : Set (Formula Atom) → Formula Atom → Prop where
  | assumption {Γ p} : p ∈ Γ → Derives Γ p
  | orLeft {Γ p q} : Derives Γ p → Derives Γ (.disj p q)
  | orRight {Γ p q} : Derives Γ q → Derives Γ (.disj p q)
  | orElim {Γ p q r} : Derives Γ (.disj p q) →
      Derives (Set.insert p Γ) r → Derives (Set.insert q Γ) r → Derives Γ r
  | implIntro {Γ p q} : Derives (Set.insert p Γ) q → Derives Γ (.impl p q)
  | implElim {Γ p q} : Derives Γ (.impl p q) → Derives Γ p → Derives Γ q
  | exFalso {Γ p} : Derives Γ .bottom → Derives Γ p

/-- A persistent atomic valuation on a preorder of worlds. -/
structure Model (Atom : Type u) (World : Type v) [Preorder World] where
  atomForces : World → Atom → Prop
  persistent : ∀ {w v : World} (a : Atom), w ≤ v →
    atomForces w a → atomForces v a

/-- Implication must hold in every accessible future world. -/
def forces {Atom : Type u} {World : Type v} [Preorder World]
    (M : Model Atom World) (w : World) : Formula Atom → Prop
  | .atom a => M.atomForces w a
  | .bottom => False
  | .disj p q => forces M w p ∨ forces M w q
  | .impl p q => ∀ z : World, w ≤ z → forces M z p → forces M z q

/-- Every formula inherits persistence from its atomic valuation. -/
theorem forces_mono {Atom : Type u} {World : Type v} [Preorder World]
    (M : Model Atom World) (φ : Formula Atom) :
    ∀ {w z : World}, w ≤ z → forces M w φ → forces M z φ := by
  induction φ with
  | atom a =>
      intro w z hwz ha
      exact M.persistent a hwz ha
  | bottom =>
      intro w z _ hf
      exact hf
  | disj p q ihp ihq =>
      intro w z hwz hpq
      rcases hpq with hp | hq
      · exact Or.inl (ihp hwz hp)
      · exact Or.inr (ihq hwz hq)
  | impl p q ihp ihq =>
      intro w z hwz hpq t hzt hpt
      exact hpq t (le_trans hwz hzt) hpt

/-- A context holds when all its assumptions are forced. -/
def holds {Atom : Type u} {World : Type v} [Preorder World]
    (M : Model Atom World) (Γ : Set (Formula Atom)) (w : World) : Prop :=
  ∀ φ, φ ∈ Γ → forces M w φ

/-- The deduction calculus is sound in every persistent Kripke model. -/
theorem sound {Atom : Type u} {World : Type v} [Preorder World]
    (M : Model Atom World) {Γ : Set (Formula Atom)} {φ : Formula Atom}
    (d : Derives Γ φ) : ∀ w : World, holds M Γ w → forces M w φ := by
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
      intro w hΓ z hwz hPz
      apply ih z
      intro x hx
      rcases Set.mem_insert_iff.mp hx with rfl | hxΓ
      · exact hPz
      · exact forces_mono M x hwz (hΓ x hxΓ)
  | implElim hp hq ihp ihq =>
      intro w hΓ
      exact (ihp w hΓ) w (le_refl w) (ihq w hΓ)
  | exFalso hp ih =>
      intro w hΓ
      exact (ih w hΓ).elim

/--
If an atom becomes true in a future world but is not yet true now,
its excluded-middle instance cannot be derived from no assumptions.
-/
theorem generic_em_not_derivable {Atom : Type u} {World : Type v}
    [Preorder World] (M : Model Atom World) (a : Atom) (w z : World)
    (hwz : w ≤ z) (hnot : ¬ M.atomForces w a)
    (hlater : M.atomForces z a) :
    ¬ Derives (∅ : Set (Formula Atom))
        (.disj (.atom a) (.impl (.atom a) .bottom)) := by
  intro d
  have hnow : forces M w (.disj (.atom a) (.impl (.atom a) .bottom)) :=
    sound M d w (by
      intro x hx
      cases hx)
  rcases hnow with hp | hnp
  · exact hnot hp
  · exact hnp z hwz hlater

/-- The two-world example is an instance of the general criterion. -/
def twoWorldModel : Model Unit (Fin 2) where
  atomForces := fun w _ => 1 ≤ w.val
  persistent := by
    intro w z _ hwz hp
    exact Nat.le_trans hp hwz

/-- Root is accessible to the later world. -/
theorem two_world_accessible : (0 : Fin 2) ≤ (1 : Fin 2) := by decide

/-- The atom does not hold at the root. -/
theorem two_world_root_not_atom :
    ¬ twoWorldModel.atomForces (0 : Fin 2) () := by
  change ¬ (1 ≤ (0 : Fin 2).val)
  omega

/-- The atom holds at the later world. -/
theorem two_world_later_atom :
    twoWorldModel.atomForces (1 : Fin 2) () := by
  change 1 ≤ (1 : Fin 2).val
  omega

theorem two_world_em_not_derivable :
    ¬ Derives (∅ : Set (Formula Unit))
        (.disj (.atom ()) (.impl (.atom ()) .bottom)) := by
  exact generic_em_not_derivable twoWorldModel () (0 : Fin 2) (1 : Fin 2)
    two_world_accessible two_world_root_not_atom two_world_later_atom

end Axiomscope.Experiment003

#print axioms Axiomscope.Experiment003.forces_mono
#print axioms Axiomscope.Experiment003.sound
#print axioms Axiomscope.Experiment003.generic_em_not_derivable
#print axioms Axiomscope.Experiment003.two_world_em_not_derivable
