import Axiomscope.SemanticInterpretations

/-!
# Model-indexed interpretation certificates

Experiment 010 used a common world/index type. Here the source and target
have separately typed model classes *and* world types. A certificate maps
source models to target models, target worlds back to source worlds, and
proves a satisfaction condition as well as derivation preservation.

This is a deliberately small interpretation interface, not an
institution-morphism implementation: we do not formalize signatures,
natural transformations, or general categories of models.
-/

namespace Axiomscope.ModelInterpretations

open Axiomscope.FoundationalInterpretations

universe u v w x y z a b c

/-- Verified proof translation and satisfaction correspondence between
    separate model classes, with target worlds mapped to source worlds. -/
structure ModelInterpretation
    {F : Type u} {G : Type v}
    {SourceModel : Type w} {TargetModel : Type x}
    {SourceWorld : Type y} {TargetWorld : Type z}
    (source : Calculus F) (target : Calculus G)
    (sourceSat : SourceModel → SourceWorld → F → Prop)
    (targetSat : TargetModel → TargetWorld → G → Prop) where
  logic : Interpretation source target
  onModel : SourceModel → TargetModel
  onWorld : SourceModel → TargetWorld → SourceWorld
  satisfaction : ∀ (M : SourceModel) (point : TargetWorld) (φ : F),
    targetSat (onModel M) point (logic.onFormula φ) ↔
      sourceSat M (onWorld M point) φ

namespace ModelInterpretation

/-- Identity needs no change of syntax, model, or world. -/
def identity
    {F : Type u} {M : Type w} {W : Type y}
    (C : Calculus F) (S : M → W → F → Prop) :
    ModelInterpretation C C S S where
  logic := Interpretation.identity C
  onModel := id
  onWorld := fun _ point => point
  satisfaction := by
    intro model point φ
    exact Iff.rfl

/-- Composable model translations must match at their intermediate model,
    world and formula types, as well as at the intermediate satisfaction
    predicate. Proof-translation and truth-translation both compose. -/
def compose
    {F : Type u} {G : Type v} {H : Type a}
    {MA : Type w} {MB : Type x} {MC : Type b}
    {WA : Type y} {WB : Type z} {WC : Type c}
    {A : Calculus F} {B : Calculus G} {C : Calculus H}
    {SA : MA → WA → F → Prop}
    {SB : MB → WB → G → Prop}
    {SC : MC → WC → H → Prop}
    (first : ModelInterpretation A B SA SB)
    (second : ModelInterpretation B C SB SC) :
    ModelInterpretation A C SA SC where
  logic := Interpretation.compose first.logic second.logic
  onModel := fun m => second.onModel (first.onModel m)
  onWorld := fun m point =>
    first.onWorld m (second.onWorld (first.onModel m) point)
  satisfaction := by
    intro m point φ
    exact (second.satisfaction (first.onModel m) point
      (first.logic.onFormula φ)).trans
      (first.satisfaction m
        (second.onWorld (first.onModel m) point) φ)

/-- Satisfaction of arbitrary translated assumptions follows from the
    pointwise correspondence without requiring an injective formula map. -/
theorem context_equiv
    {F : Type u} {G : Type v}
    {MA : Type w} {MB : Type x}
    {WA : Type y} {WB : Type z}
    {A : Calculus F} {B : Calculus G}
    {SA : MA → WA → F → Prop}
    {SB : MB → WB → G → Prop}
    (cert : ModelInterpretation A B SA SB)
    (M : MA) (point : WB) (Γ : Set F) :
    (∀ ψ, ψ ∈ cert.logic.onFormula '' Γ →
      SB (cert.onModel M) point ψ) ↔
      (∀ φ, φ ∈ Γ → SA M (cert.onWorld M point) φ) := by
  constructor
  · intro h φ hφ
    exact (cert.satisfaction M point φ).mp
      (h _ ⟨φ, hφ, rfl⟩)
  · intro h ψ hψ
    rcases hψ with ⟨φ, hφ, rfl⟩
    exact (cert.satisfaction M point φ).mpr (h φ hφ)

/-- The model-indexed certificate retains the proof transport obligation. -/
theorem transports_derivation
    {F : Type u} {G : Type v}
    {MA : Type w} {MB : Type x}
    {WA : Type y} {WB : Type z}
    {A : Calculus F} {B : Calculus G}
    {SA : MA → WA → F → Prop}
    {SB : MB → WB → G → Prop}
    (cert : ModelInterpretation A B SA SB)
    {Γ : Set F} {φ : F} (d : A.derives Γ φ) :
    B.derives (cert.logic.onFormula '' Γ) (cert.logic.onFormula φ) :=
  cert.logic.onProof d

end ModelInterpretation
end Axiomscope.ModelInterpretations
