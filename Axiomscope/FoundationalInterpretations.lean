import Mathlib

/-!
# AxiomScope: proof-preserving interpretations of deductive systems

A foundational interpretation maps statements and carries *derivations*
from one explicitly given deductive system to another. An arbitrary
map of formulas is not enough: the proof-preservation field is mandatory.

This is a minimal interface, not a general theory of models, languages,
or cross-kernel proof transport.
-/

namespace Axiomscope.FoundationalInterpretations

universe u v w

/-- A deductive system on a type of object-language formulas. -/
structure Calculus (Form : Type u) where
  derives : Set Form → Form → Prop

/-- Translate formulas and supply a derivation-preservation witness. -/
structure Interpretation {F : Type u} {G : Type v}
    (source : Calculus F) (target : Calculus G) where
  onFormula : F → G
  onProof : ∀ {Γ : Set F} {φ : F},
    source.derives Γ φ → target.derives (onFormula '' Γ) (onFormula φ)

namespace Interpretation

/-- Identity translation preserves every derivation. -/
def identity {F : Type u} (C : Calculus F) : Interpretation C C where
  onFormula := id
  onProof := by
    intro Γ φ derivation
    simpa using derivation

/-- Verified interpretations compose. Formula translations and proof transport
    compose together; the intermediate set of premises is mapped twice. -/
def compose {F : Type u} {G : Type v} {H : Type w}
    {A : Calculus F} {B : Calculus G} {C : Calculus H}
    (first : Interpretation A B) (second : Interpretation B C) :
    Interpretation A C where
  onFormula := second.onFormula ∘ first.onFormula
  onProof := by
    intro Γ φ derivation
    have intermediate := first.onProof derivation
    have translated := second.onProof intermediate
    simpa only [Set.image_image, Function.comp_apply] using translated

end Interpretation

end Axiomscope.FoundationalInterpretations
