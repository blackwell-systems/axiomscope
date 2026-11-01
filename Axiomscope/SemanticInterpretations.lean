import Axiomscope.FoundationalInterpretations

/-!
# Semantic certificates for proof-preserving interpretations

An interpretation between abstract calculi must preserve derivations.
A semantic certificate additionally asserts pointwise preservation AND
reflection of satisfaction over one explicitly shared index type.

The common index can be a Kripke world for a fixed model. This interface
does not yet transport models or quantify across *different* model classes,
so it is not an institution morphism or a general foundation equivalence.
-/

namespace Axiomscope.SemanticInterpretations

open Axiomscope.FoundationalInterpretations

universe u v w x

/-- A derivation-preserving formula translation with a checked semantic
    equivalence at every designated world/interpretation index. -/
structure SemanticInterpretation {F : Type u} {G : Type v} {World : Type w}
    (source : Calculus F) (target : Calculus G)
    (sourceSatisfies : World → F → Prop)
    (targetSatisfies : World → G → Prop) where
  logic : Interpretation source target
  semantics : ∀ (point : World) (φ : F),
    targetSatisfies point (logic.onFormula φ) ↔ sourceSatisfies point φ

namespace SemanticInterpretation

/-- The identity translation has a trivial semantic certificate. -/
def identity {F : Type u} {World : Type w}
    (C : Calculus F) (S : World → F → Prop) :
    SemanticInterpretation C C S S where
  logic := Interpretation.identity C
  semantics := by
    intro point φ
    exact Iff.rfl

/-- Certificates compose: the second equivalence is followed by the first.
    Derivation preservation is obtained from the already checked
    composition of underlying proof interpretations. -/
def compose {F : Type u} {G : Type v} {H : Type x}
    {World : Type w}
    {A : Calculus F} {B : Calculus G} {C : Calculus H}
    {S : World → F → Prop} {T : World → G → Prop}
    {U : World → H → Prop}
    (first : SemanticInterpretation A B S T)
    (second : SemanticInterpretation B C T U) :
    SemanticInterpretation A C S U where
  logic := Interpretation.compose first.logic second.logic
  semantics := by
    intro point φ
    exact (second.semantics point (first.logic.onFormula φ)).trans
      (first.semantics point φ)

/-- Pointwise semantic equivalence automatically extends to the image of
    an arbitrary set of assumptions, with no injectivity requirement. -/
theorem context_equiv {F : Type u} {G : Type v} {World : Type w}
    {A : Calculus F} {B : Calculus G}
    {S : World → F → Prop} {T : World → G → Prop}
    (cert : SemanticInterpretation A B S T)
    (point : World) (Γ : Set F) :
    (∀ ψ, ψ ∈ cert.logic.onFormula '' Γ → T point ψ) ↔
      (∀ φ, φ ∈ Γ → S point φ) := by
  constructor
  · intro h φ hφ
    exact (cert.semantics point φ).mp (h _ ⟨φ, hφ, rfl⟩)
  · intro h ψ hψ
    rcases hψ with ⟨φ, hφ, rfl⟩
    exact (cert.semantics point φ).mpr (h φ hφ)

/-- The proof part of the certificate remains available for open contexts. -/
theorem transports_derivation {F : Type u} {G : Type v} {World : Type w}
    {A : Calculus F} {B : Calculus G}
    {S : World → F → Prop} {T : World → G → Prop}
    (cert : SemanticInterpretation A B S T)
    {Γ : Set F} {φ : F} (d : A.derives Γ φ) :
    B.derives (cert.logic.onFormula '' Γ) (cert.logic.onFormula φ) :=
  cert.logic.onProof d

/-- A concrete semantic mismatch prohibits a certificate for the given
    formula translation. This rejects *actual* disagreements; mere lack
    of a proof cannot establish a mismatch. -/
theorem no_certificate_of_mismatch {F : Type u} {G : Type v}
    {World : Type w}
    {A : Calculus F} {B : Calculus G}
    {S : World → F → Prop} {T : World → G → Prop}
    (translation : Interpretation A B)
    (point : World) (φ : F)
    (sourceTrue : S point φ)
    (targetFalse : ¬ T point (translation.onFormula φ)) :
    ¬ ∃ cert : SemanticInterpretation A B S T,
      cert.logic.onFormula = translation.onFormula := by
  rintro ⟨cert, hagree⟩
  have h : T point (cert.logic.onFormula φ) :=
    (cert.semantics point φ).mpr sourceTrue
  rw [hagree] at h
  exact targetFalse h

end SemanticInterpretation
end Axiomscope.SemanticInterpretations
