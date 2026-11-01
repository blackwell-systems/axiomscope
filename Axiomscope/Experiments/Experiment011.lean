import Axiomscope.Experiments.Experiment009
import Axiomscope.ModelInterpretations

/-!
# Experiment 011 — model and world transformations

A bounded back-and-forth map between Kripke preorders lets us pull back
any persistent atomic valuation. The *back* clause is essential for
implication: target worlds must cover every source future accessible
from the image of a target world.

We instantiate this with a nontrivial target world type Nat × Bool and
source worlds Nat. Different model classes and formula languages are
connected in one model-indexed certificate. A failing back-condition
example demonstrates why mere monotonicity is insufficient.
-/

namespace Axiomscope.Experiment011

open Axiomscope.Experiment003
open Axiomscope.Experiment008
open Axiomscope.Experiment009
open Axiomscope.FoundationalInterpretations
open Axiomscope.ModelInterpretations

universe u v w

/-- A Kripke bounded morphism: target worlds project monotonically into
    source worlds and every source future can be lifted to a target future. -/
structure BoundedMap (WA : Type v) (WB : Type w)
    [Preorder WA] [Preorder WB] where
  project : WB → WA
  forth : Monotone project
  back : ∀ (b : WB) (a : WA), project b ≤ a →
    ∃ b' : WB, b ≤ b' ∧ project b' = a

/-- Pull a source Kripke model back along a bounded world map. -/
def pullback {Atom : Type u} {WA : Type v} {WB : Type w}
    [Preorder WA] [Preorder WB]
    (M : Model Atom WA) (p : BoundedMap WA WB) : Model Atom WB where
  atomForces := fun b a => M.atomForces (p.project b) a
  persistent := by
    intro b c a hbc hb
    exact M.persistent a (p.forth hbc) hb

/-- Kripke satisfaction is invariant under a bounded-map pullback.
    Crucially, the implication case uses the back-lifting clause, not
    just monotonicity. -/
theorem pullback_forcing_equiv {Atom : Type u} {WA : Type v} {WB : Type w}
    [Preorder WA] [Preorder WB]
    (M : Model Atom WA) (p : BoundedMap WA WB)
    (b : WB) (φ : Formula Atom) :
    forces (pullback M p) b φ ↔ forces M (p.project b) φ := by
  induction φ generalizing b with
  | atom a =>
      rfl
  | bottom =>
      rfl
  | disj left right ihleft ihright =>
      change (forces (pullback M p) b left ∨
        forces (pullback M p) b right) ↔
        (forces M (p.project b) left ∨
         forces M (p.project b) right)
      exact or_congr (ihleft b) (ihright b)
  | impl left right ihleft ihright =>
      change
        (∀ z : WB, b ≤ z →
          forces (pullback M p) z left →
          forces (pullback M p) z right) ↔
        (∀ z : WA, p.project b ≤ z →
          forces M z left → forces M z right)
      constructor
      · intro h z hbz hz
        obtain ⟨lift, hbl, hproject⟩ := p.back b z hbz
        have hLift : forces (pullback M p) lift left :=
          (ihleft lift).mpr (by simpa only [hproject] using hz)
        have hRight : forces M (p.project lift) right :=
          (ihright lift).mp (h lift hbl hLift)
        simpa only [hproject] using hRight
      · intro h z hbz hz
        have hLeft : forces M (p.project z) left :=
          (ihleft z).mp hz
        exact (ihright z).mpr
          (h (p.project z) (p.forth hbz) hLeft)

/-- The target has distinct copies of each natural-number world. -/
abbrev CoverWorld := Nat × Bool

/-- The projection is a bounded map for the product preorder.
    To lift a new source world, keep the current Bool coordinate. -/
def coverProjection : BoundedMap Nat CoverWorld where
  project := Prod.fst
  forth := by
    intro b c hbc
    exact hbc.1
  back := by
    intro b a hba
    refine ⟨(a, b.2), ?_, rfl⟩
    exact ⟨hba, le_refl _⟩

/-- Translate both model class and formula language. Unlike Experiment
    010, source worlds are Nat and target worlds are Nat × Bool. -/
def certifiedCover (Atom : Type u) :
    ModelInterpretation
      (intuitionisticCalculus Atom) (expandedCalculus Atom)
      (fun (M : Model Atom Nat) (n : Nat) (φ : Formula Atom) =>
        forces M n φ)
      (fun (N : Model Atom CoverWorld) (point : CoverWorld)
        (ψ : ExpandedFormula Atom) => expandedForces N point ψ) where
  logic := embedding Atom
  onModel := fun M => pullback M coverProjection
  onWorld := fun _ point => point.1
  satisfaction := by
    intro M point φ
    exact (semantics_equiv (pullback M coverProjection) point φ).trans
      (pullback_forcing_equiv M coverProjection point φ)

/-- Contexts preserve satisfaction across BOTH a syntax translation and
    a nonidentity model/world translation. -/
theorem cover_context_equiv (Atom : Type u)
    (M : Model Atom Nat) (point : CoverWorld)
    (Γ : Set (Formula Atom)) :
    (∀ ψ, ψ ∈ (certifiedCover Atom).logic.onFormula '' Γ →
      expandedForces ((certifiedCover Atom).onModel M) point ψ) ↔
    holds M Γ ((certifiedCover Atom).onWorld M point) := by
  exact (certifiedCover Atom).context_equiv M point Γ

/-- Deduction transport does not need to re-prove Kripke soundness. -/
theorem cover_transports_derivation (Atom : Type u)
    {Γ : Set (Formula Atom)} {φ : Formula Atom}
    (d : Derives Γ φ) :
    (expandedCalculus Atom).derives
      ((certifiedCover Atom).logic.onFormula '' Γ)
      ((certifiedCover Atom).logic.onFormula φ) :=
  (certifiedCover Atom).transports_derivation d

/-- Model-level certificates compose with a model-level identity.
    This is checked on the concrete distinct-world interpretation. -/
def certifiedCoverComposition (Atom : Type u) :
    ModelInterpretation
      (intuitionisticCalculus Atom) (expandedCalculus Atom)
      (fun (M : Model Atom Nat) (n : Nat) (φ : Formula Atom) =>
        forces M n φ)
      (fun (N : Model Atom CoverWorld) (point : CoverWorld)
        (ψ : ExpandedFormula Atom) => expandedForces N point ψ) :=
  ModelInterpretation.compose (certifiedCover Atom)
    (ModelInterpretation.identity (expandedCalculus Atom)
      (fun (N : Model Atom CoverWorld) (point : CoverWorld)
        (ψ : ExpandedFormula Atom) => expandedForces N point ψ))

/-- The composite certificate still preserves and reflects forcing. -/
theorem composed_cover_satisfaction (Atom : Type u)
    (M : Model Atom Nat) (point : CoverWorld) (φ : Formula Atom) :
    expandedForces ((certifiedCoverComposition Atom).onModel M)
      point ((certifiedCoverComposition Atom).logic.onFormula φ) ↔
    forces M ((certifiedCoverComposition Atom).onWorld M point) φ :=
  (certifiedCoverComposition Atom).satisfaction M point φ

/-- A monotone map may fail to lift an accessible future. Singleton
    worlds mapping to the root of the two-world Kripke model have this
    defect. -/
def badProjection : Fin 1 → Fin 2 := fun _ => 0

theorem bad_projection_not_back :
    ¬ ∀ (b : Fin 1) (a : Fin 2), badProjection b ≤ a →
        ∃ b' : Fin 1, b ≤ b' ∧ badProjection b' = a := by
  intro h
  obtain ⟨b', _, hb'⟩ := h 0 1 (by decide)
  change (0 : Fin 2) = 1 at hb'
  exact (by decide : (0 : Fin 2) ≠ 1) hb'

/-- A model over a singleton world with the atom permanently false. -/
def singletonModel : Model Unit (Fin 1) where
  atomForces := fun _ _ => False
  persistent := by
    intro _ _ _ _ hf
    exact hf

/-- An explicit implication disagreement under the unbounded
    root-only projection: the singleton satisfies not-p, while the
    root of the original two-world model does not. -/
theorem bad_projection_changes_implication :
    forces singletonModel (0 : Fin 1)
      (.impl (.atom ()) .bottom) ∧
    ¬ forces twoWorldModel (0 : Fin 2)
      (.impl (.atom ()) .bottom) := by
  constructor
  · intro z _ h
    exact h
  · intro h
    exact h (1 : Fin 2) two_world_accessible two_world_later_atom

end Axiomscope.Experiment011

#print axioms Axiomscope.Experiment011.pullback_forcing_equiv
#print axioms Axiomscope.Experiment011.cover_context_equiv
#print axioms Axiomscope.Experiment011.cover_transports_derivation
#print axioms Axiomscope.Experiment011.composed_cover_satisfaction
#print axioms Axiomscope.Experiment011.bad_projection_not_back
#print axioms Axiomscope.Experiment011.bad_projection_changes_implication
