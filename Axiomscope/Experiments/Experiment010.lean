import Axiomscope.Experiments.Experiment009
import Axiomscope.SemanticInterpretations

/-!
# Experiment 010 — reusable semantic interpretation certificates

Repackage Experiment 009's proof translation and independently proved
Kripke semantic equivalence into one certificate. Verify the generic
composition construction on this concrete embedding.

The shared semantic index is a world in one given Kripke model. This
does NOT translate models between arbitrary foundations or prove a
theorem unknown to existing interpretation theory.
-/

namespace Axiomscope.Experiment010

open Axiomscope.Experiment003
open Axiomscope.Experiment008
open Axiomscope.Experiment009
open Axiomscope.FoundationalInterpretations
open Axiomscope.SemanticInterpretations

universe u v

/-- A single object contains both the rule-by-rule proof translation
    and the model-indexed equivalence of forcing from Experiment 009. -/
def certifiedEmbedding {Atom : Type u} {World : Type v}
    [Preorder World] (M : Model Atom World) :
    SemanticInterpretation
      (intuitionisticCalculus Atom) (expandedCalculus Atom)
      (fun point φ => forces M point φ)
      (fun point ψ => expandedForces M point ψ) where
  logic := embedding Atom
  semantics := by
    intro point φ
    exact semantics_equiv M point φ

/-- Semantically certified interpretations compose with a certified
    identity without losing either part of the certificate. -/
def certifiedComposition {Atom : Type u} {World : Type v}
    [Preorder World] (M : Model Atom World) :
    SemanticInterpretation
      (intuitionisticCalculus Atom) (expandedCalculus Atom)
      (fun point φ => forces M point φ)
      (fun point ψ => expandedForces M point ψ) :=
  SemanticInterpretation.compose (certifiedEmbedding M)
    (SemanticInterpretation.identity (expandedCalculus Atom)
      (fun point ψ => expandedForces M point ψ))

/-- Source derivations transport through the certificate, not just through
    separately imported, manually paired theorems. -/
theorem certified_derivation {Atom : Type u} {World : Type v}
    [Preorder World] (M : Model Atom World)
    {Γ : Set (Formula Atom)} {φ : Formula Atom}
    (d : Derives Γ φ) :
    (expandedCalculus Atom).derives
      ((certifiedEmbedding M).logic.onFormula '' Γ)
      ((certifiedEmbedding M).logic.onFormula φ) :=
  (certifiedEmbedding M).transports_derivation d

/-- Context satisfaction is a consequence of the generic semantic
    certificate, rather than a separate Kripke-specific proof. -/
theorem certified_contexts {Atom : Type u} {World : Type v}
    [Preorder World] (M : Model Atom World)
    (point : World) (Γ : Set (Formula Atom)) :
    (∀ ψ, ψ ∈ (certifiedEmbedding M).logic.onFormula '' Γ →
      expandedForces M point ψ) ↔ holds M Γ point := by
  exact (certifiedEmbedding M).context_equiv point Γ

/-- The *composed* certificate still preserves and reflects meaning
    at arbitrary worlds of the chosen Kripke model. -/
theorem composed_semantics {Atom : Type u} {World : Type v}
    [Preorder World] (M : Model Atom World)
    (point : World) (φ : Formula Atom) :
    expandedForces M point
      ((certifiedComposition M).logic.onFormula φ) ↔
      forces M point φ :=
  (certifiedComposition M).semantics point φ

/-- Composition simultaneously transports the formal proof. -/
theorem composed_derivation {Atom : Type u} {World : Type v}
    [Preorder World] (M : Model Atom World)
    {Γ : Set (Formula Atom)} {φ : Formula Atom}
    (d : Derives Γ φ) :
    (expandedCalculus Atom).derives
      ((certifiedComposition M).logic.onFormula '' Γ)
      ((certifiedComposition M).logic.onFormula φ) :=
  (certifiedComposition M).transports_derivation d

end Axiomscope.Experiment010

#print axioms Axiomscope.Experiment010.certified_derivation
#print axioms Axiomscope.Experiment010.certified_contexts
#print axioms Axiomscope.Experiment010.composed_semantics
#print axioms Axiomscope.Experiment010.composed_derivation
