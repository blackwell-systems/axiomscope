import Axiomscope.Experiments.Experiment008

/-!
# Experiment 009 — translating between different object languages

The source is Experiment 003's small intuitionistic formula language.
The target is a *different*, richer language with explicit top and
conjunction. Atoms are intentionally translated nontrivially:
  p |-> p AND top.
The translation respects bottom, disjunction, and implication and carries
every source deduction into the target calculus.

We verify preservation and reflection of Kripke forcing at every world.
This is a conservative definitional encoding inside Lean, not cross-kernel
proof transport, a model of ZF, or a new theorem in mathematical logic.
-/

namespace Axiomscope.Experiment009

open Axiomscope.Experiment003
open Axiomscope.Experiment008
open Axiomscope.FoundationalInterpretations

universe u v

/-- The target has genuinely different syntax and additional connectives. -/
inductive ExpandedFormula (Atom : Type u) where
  | atom : Atom → ExpandedFormula Atom
  | top : ExpandedFormula Atom
  | bottom : ExpandedFormula Atom
  | conj : ExpandedFormula Atom → ExpandedFormula Atom → ExpandedFormula Atom
  | disj : ExpandedFormula Atom → ExpandedFormula Atom → ExpandedFormula Atom
  | impl : ExpandedFormula Atom → ExpandedFormula Atom → ExpandedFormula Atom

/-- Intentionally nonidentity: each source atom maps to atom ∧ ⊤. -/
def translate {Atom : Type u} : Formula Atom → ExpandedFormula Atom
  | .atom a => .conj (.atom a) .top
  | .bottom => .bottom
  | .disj p q => .disj (translate p) (translate q)
  | .impl p q => .impl (translate p) (translate q)

/-- Target natural deduction with extra rules for truth and conjunction. -/
inductive ExpandedDerives {Atom : Type u} :
    Set (ExpandedFormula Atom) → ExpandedFormula Atom → Prop where
  | assumption {Γ p} : p ∈ Γ → ExpandedDerives Γ p
  | topIntro {Γ} : ExpandedDerives Γ .top
  | conjIntro {Γ p q} : ExpandedDerives Γ p → ExpandedDerives Γ q →
      ExpandedDerives Γ (.conj p q)
  | conjLeft {Γ p q} : ExpandedDerives Γ (.conj p q) → ExpandedDerives Γ p
  | conjRight {Γ p q} : ExpandedDerives Γ (.conj p q) → ExpandedDerives Γ q
  | orLeft {Γ p q} : ExpandedDerives Γ p → ExpandedDerives Γ (.disj p q)
  | orRight {Γ p q} : ExpandedDerives Γ q → ExpandedDerives Γ (.disj p q)
  | orElim {Γ p q r} : ExpandedDerives Γ (.disj p q) →
      ExpandedDerives (Set.insert p Γ) r →
      ExpandedDerives (Set.insert q Γ) r → ExpandedDerives Γ r
  | implIntro {Γ p q} : ExpandedDerives (Set.insert p Γ) q →
      ExpandedDerives Γ (.impl p q)
  | implElim {Γ p q} : ExpandedDerives Γ (.impl p q) →
      ExpandedDerives Γ p → ExpandedDerives Γ q
  | exFalso {Γ p} : ExpandedDerives Γ .bottom → ExpandedDerives Γ p

/-- Every source proof has a translated proof, including translated contexts. -/
theorem translate_derivation {Atom : Type u}
    {Γ : Set (Formula Atom)} {φ : Formula Atom}
    (d : Derives Γ φ) :
    ExpandedDerives (translate '' Γ) (translate φ) := by
  induction d with
  | assumption hp =>
      exact ExpandedDerives.assumption (Set.mem_image_of_mem translate hp)
  | orLeft _ ih => exact ExpandedDerives.orLeft ih
  | orRight _ ih => exact ExpandedDerives.orRight ih
  | orElim _ _ _ ihp ihleft ihright =>
      apply ExpandedDerives.orElim ihp
      · simpa using ihleft
      · simpa using ihright
  | implIntro _ ih =>
      apply ExpandedDerives.implIntro
      simpa using ih
  | implElim _ _ ihp ihq =>
      exact ExpandedDerives.implElim ihp ihq
  | exFalso _ ih =>
      exact ExpandedDerives.exFalso ih

/-- The distinct target-language calculus. -/
def expandedCalculus (Atom : Type u) : Calculus (ExpandedFormula Atom) where
  derives := ExpandedDerives

/-- The first nonidentity proof-preserving interpretation in AxiomScope. -/
def embedding (Atom : Type u) :
    Interpretation (intuitionisticCalculus Atom) (expandedCalculus Atom) where
  onFormula := translate
  onProof := by
    intro Γ φ derivation
    exact translate_derivation derivation

/-- Target-language Kripke forcing, with ⊤ and ∧ interpreted directly. -/
def expandedForces {Atom : Type u} {World : Type v} [Preorder World]
    (M : Model Atom World) (w : World) : ExpandedFormula Atom → Prop
  | .atom a => M.atomForces w a
  | .top => True
  | .bottom => False
  | .conj p q => expandedForces M w p ∧ expandedForces M w q
  | .disj p q => expandedForces M w p ∨ expandedForces M w q
  | .impl p q =>
      ∀ z : World, w ≤ z → expandedForces M z p → expandedForces M z q

/-- Translation preserves AND reflects forcing at every Kripke world. -/
theorem semantics_equiv {Atom : Type u} {World : Type v}
    [Preorder World] (M : Model Atom World) (w : World)
    (φ : Formula Atom) :
    expandedForces M w (translate φ) ↔ forces M w φ := by
  induction φ generalizing w with
  | atom a =>
      simp [translate, expandedForces, forces]
  | bottom =>
      simp [translate, expandedForces, forces]
  | disj p q ihp ihq =>
      change (expandedForces M w (translate p) ∨
        expandedForces M w (translate q)) ↔
        (forces M w p ∨ forces M w q)
      exact or_congr (ihp w) (ihq w)
  | impl p q ihp ihq =>
      change (∀ z : World, w ≤ z →
        expandedForces M z (translate p) →
        expandedForces M z (translate q)) ↔
        (∀ z : World, w ≤ z → forces M z p → forces M z q)
      constructor
      · intro h z hwz hp
        exact (ihq z).mp (h z hwz ((ihp z).mpr hp))
      · intro h z hwz hp
        exact (ihq z).mpr (h z hwz ((ihp z).mp hp))

/-- Even under assumptions, the semantic interpretation agrees pointwise. -/
theorem context_semantics_equiv {Atom : Type u} {World : Type v}
    [Preorder World] (M : Model Atom World) (w : World)
    (Γ : Set (Formula Atom)) :
    (∀ ψ, ψ ∈ translate '' Γ → expandedForces M w ψ) ↔
      holds M Γ w := by
  constructor
  · intro h φ hφ
    exact (semantics_equiv M w φ).mp (h _ ⟨φ, hφ, rfl⟩)
  · intro h ψ hψ
    rcases hψ with ⟨φ, hφ, rfl⟩
    exact (semantics_equiv M w φ).mpr (h φ hφ)

/-- The target has syntax that cannot be translated from the source. -/
theorem top_not_in_image {Atom : Type u} :
    ¬ ∃ φ : Formula Atom, translate φ = ExpandedFormula.top := by
  rintro ⟨φ, h⟩
  cases φ <;> cases h

/-- Our concrete interpretation composes with the target identity. -/
theorem embedding_compose_identity {Atom : Type u}
    {Γ : Set (Formula Atom)} {φ : Formula Atom}
    (d : Derives Γ φ) :
    (expandedCalculus Atom).derives
      ((Interpretation.compose (embedding Atom)
        (Interpretation.identity (expandedCalculus Atom))).onFormula '' Γ)
      ((Interpretation.compose (embedding Atom)
        (Interpretation.identity (expandedCalculus Atom))).onFormula φ) :=
  (Interpretation.compose (embedding Atom)
    (Interpretation.identity (expandedCalculus Atom))).onProof d

end Axiomscope.Experiment009

#print axioms Axiomscope.Experiment009.translate_derivation
#print axioms Axiomscope.Experiment009.semantics_equiv
#print axioms Axiomscope.Experiment009.context_semantics_equiv
#print axioms Axiomscope.Experiment009.top_not_in_image
#print axioms Axiomscope.Experiment009.embedding_compose_identity
