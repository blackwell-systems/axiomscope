import Axiomscope.Experiments.GeneralKripke

/-!
# Experiment 012 — a signature-indexed satisfaction condition

The signature of a propositional language is its type of atomic symbols.
Signature morphisms are functions on atoms. Sentences are formulas indexed
by their atom type, while models are valuations into Prop.

Sentence transport is covariant; model reduct is contravariant.
We prove their identity/composition laws and the central satisfaction
condition. This is the *object-level fragment* of a propositional
institution, not an original invention or a full category/functor-valued
institution (no model morphism categories are defined).
-/

namespace Axiomscope.Experiment012

open Axiomscope.Experiment003

universe u v w

/-- A signature morphism changes the vocabulary of atomic symbols. -/
abbrev SignatureHom (A : Type u) (B : Type v) := A → B

/-- Covariant translation of formulas along a signature morphism. -/
def sentenceMap {A : Type u} {B : Type v} (f : SignatureHom A B) :
    Formula A → Formula B
  | .atom a => .atom (f a)
  | .bottom => .bottom
  | .disj p q => .disj (sentenceMap f p) (sentenceMap f q)
  | .impl p q => .impl (sentenceMap f p) (sentenceMap f q)

/-- A model of a signature is a propositional valuation. -/
abbrev Valuation (A : Type u) := A → Prop

/-- Contravariant model reduct: interpret source atoms via their
    images in the target signature. -/
def reduct {A : Type u} {B : Type v}
    (f : SignatureHom A B) (M : Valuation B) : Valuation A :=
  fun a => M (f a)

/-- A propositional satisfaction relation, independent of Kripke worlds. -/
def satisfied {A : Type u} (M : Valuation A) : Formula A → Prop
  | .atom a => M a
  | .bottom => False
  | .disj p q => satisfied M p ∨ satisfied M q
  | .impl p q => satisfied M p → satisfied M q

/-- Identity signature maps leave formulas unchanged. -/
theorem sentence_id {A : Type u} (φ : Formula A) :
    sentenceMap (fun a : A => a) φ = φ := by
  induction φ with
  | atom a => rfl
  | bottom => rfl
  | disj p q ihp ihq => simp only [sentenceMap, ihp, ihq]
  | impl p q ihp ihq => simp only [sentenceMap, ihp, ihq]

/-- Sentence translation is covariantly compositional. -/
theorem sentence_comp {A : Type u} {B : Type v} {C : Type w}
    (f : SignatureHom A B) (g : SignatureHom B C)
    (φ : Formula A) :
    sentenceMap g (sentenceMap f φ) =
      sentenceMap (g ∘ f) φ := by
  induction φ with
  | atom a => rfl
  | bottom => rfl
  | disj p q ihp ihq => simp only [sentenceMap, ihp, ihq]
  | impl p q ihp ihq => simp only [sentenceMap, ihp, ihq]

/-- Identity reduct leaves the valuation unchanged. -/
theorem reduct_id {A : Type u} (M : Valuation A) :
    reduct (fun a : A => a) M = M := rfl

/-- Model reducts compose in the opposite direction to signature maps. -/
theorem reduct_comp {A : Type u} {B : Type v} {C : Type w}
    (f : SignatureHom A B) (g : SignatureHom B C)
    (M : Valuation C) :
    reduct f (reduct g M) = reduct (g ∘ f) M := rfl

/-- The institution satisfaction condition: translating a sentence and
    reducing a model produce exactly the same truth value. -/
theorem satisfaction_condition {A : Type u} {B : Type v}
    (f : SignatureHom A B) (M : Valuation B)
    (φ : Formula A) :
    satisfied (reduct f M) φ ↔
      satisfied M (sentenceMap f φ) := by
  induction φ with
  | atom a => rfl
  | bottom => rfl
  | disj p q ihp ihq =>
      change (satisfied (reduct f M) p ∨
        satisfied (reduct f M) q) ↔
        (satisfied M (sentenceMap f p) ∨
         satisfied M (sentenceMap f q))
      exact or_congr ihp ihq
  | impl p q ihp ihq =>
      change (satisfied (reduct f M) p →
        satisfied (reduct f M) q) ↔
        (satisfied M (sentenceMap f p) →
         satisfied M (sentenceMap f q))
      constructor
      · intro h hp
        exact ihq.mp (h (ihp.mpr hp))
      · intro h hp
        exact ihq.mpr (h (ihp.mp hp))

/-- The condition follows any two successive signature changes. -/
theorem satisfaction_comp {A : Type u} {B : Type v} {C : Type w}
    (f : SignatureHom A B) (g : SignatureHom B C)
    (M : Valuation C) (φ : Formula A) :
    satisfied (reduct f (reduct g M)) φ ↔
      satisfied M (sentenceMap g (sentenceMap f φ)) :=
  (satisfaction_condition f (reduct g M) φ).trans
    (satisfaction_condition g M (sentenceMap f φ))

/-- Arbitrary sets of translated premises satisfy the same condition. -/
theorem context_satisfaction {A : Type u} {B : Type v}
    (f : SignatureHom A B) (M : Valuation B)
    (Γ : Set (Formula A)) :
    (∀ ψ, ψ ∈ sentenceMap f '' Γ → satisfied M ψ) ↔
    (∀ φ, φ ∈ Γ → satisfied (reduct f M) φ) := by
  constructor
  · intro h φ hφ
    exact (satisfaction_condition f M φ).mpr
      (h _ ⟨φ, hφ, rfl⟩)
  · intro h ψ hψ
    rcases hψ with ⟨φ, hφ, rfl⟩
    exact (satisfaction_condition f M φ).mp (h φ hφ)

/-- Nontrivial morphism between two genuinely distinct vocabularies. -/
def renameUnitBool : SignatureHom Unit Bool := fun _ => true

def positiveBool : Valuation Bool := fun b => b = true

/-- A deliberately wrong reduct does not preserve the atom's truth;
    the satisfaction condition is a real constraint, not automatic for
    arbitrary choices of model map. -/
theorem wrong_reduct_counterexample :
    ¬ (satisfied (fun _ : Unit => False) (.atom ()) ↔
        satisfied positiveBool
          (sentenceMap renameUnitBool (.atom ()))) := by
  intro h
  have targetTrue :
      satisfied positiveBool (sentenceMap renameUnitBool (.atom ())) := by
    change true = true
    rfl
  have sourceTrue : satisfied (fun _ : Unit => False) (.atom ()) :=
    h.mpr targetTrue
  exact sourceTrue

end Axiomscope.Experiment012

#print axioms Axiomscope.Experiment012.sentence_id
#print axioms Axiomscope.Experiment012.sentence_comp
#print axioms Axiomscope.Experiment012.reduct_comp
#print axioms Axiomscope.Experiment012.satisfaction_condition
#print axioms Axiomscope.Experiment012.satisfaction_comp
#print axioms Axiomscope.Experiment012.context_satisfaction
#print axioms Axiomscope.Experiment012.wrong_reduct_counterexample
