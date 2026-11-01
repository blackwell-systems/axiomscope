import Axiomscope.Experiments.GeneralKripke
import Axiomscope.FoundationalInterpretations

/-!
# Experiment 008 — a first verified interpretation between two logics

IPC and CPC share formula syntax in the {atoms, bottom, disjunction,
implication} fragment. CPC extends IPC with an explicit excluded-middle
inference rule. We verify that IPC proofs embed into CPC proofs and that
the identity translation in the opposite direction is obstructed by
the Kripke countermodel from Experiment 003.

The identity *reverse translation* fails; this does not rule out all
other translations (e.g. negative translations), nor does it establish
a relationship between ZF, ZFC, and type theory.
-/

namespace Axiomscope.Experiment008

open Axiomscope.Experiment003
open Axiomscope.FoundationalInterpretations

universe u

/-- Classical natural deduction extends the intuitionistic rules by an
    explicit excluded-middle axiom schema in the object language. -/
inductive ClassicalDerives {Atom : Type u} :
    Set (Formula Atom) → Formula Atom → Prop where
  | assumption {Γ p} : p ∈ Γ → ClassicalDerives Γ p
  | orLeft {Γ p q} : ClassicalDerives Γ p → ClassicalDerives Γ (.disj p q)
  | orRight {Γ p q} : ClassicalDerives Γ q → ClassicalDerives Γ (.disj p q)
  | orElim {Γ p q r} : ClassicalDerives Γ (.disj p q) →
      ClassicalDerives (Set.insert p Γ) r →
      ClassicalDerives (Set.insert q Γ) r → ClassicalDerives Γ r
  | implIntro {Γ p q} : ClassicalDerives (Set.insert p Γ) q →
      ClassicalDerives Γ (.impl p q)
  | implElim {Γ p q} : ClassicalDerives Γ (.impl p q) →
      ClassicalDerives Γ p → ClassicalDerives Γ q
  | exFalso {Γ p} : ClassicalDerives Γ .bottom → ClassicalDerives Γ p
  | excludedMiddle {Γ p} :
      ClassicalDerives Γ (.disj p (.impl p .bottom))

/-- Every intuitionistic derivation can be reconstructed using the
    corresponding inference rules in the classical calculus. -/
theorem intuitionistic_to_classical {Atom : Type u}
    {Γ : Set (Formula Atom)} {φ : Formula Atom}
    (derivation : Derives Γ φ) : ClassicalDerives Γ φ := by
  induction derivation with
  | assumption hp => exact ClassicalDerives.assumption hp
  | orLeft _ ih => exact ClassicalDerives.orLeft ih
  | orRight _ ih => exact ClassicalDerives.orRight ih
  | orElim _ _ _ ihp ihleft ihright =>
      exact ClassicalDerives.orElim ihp ihleft ihright
  | implIntro _ ih => exact ClassicalDerives.implIntro ih
  | implElim _ _ ihp ihq => exact ClassicalDerives.implElim ihp ihq
  | exFalso _ ih => exact ClassicalDerives.exFalso ih

/-- The explicitly defined intuitionistic calculus. -/
def intuitionisticCalculus (Atom : Type u) : Calculus (Formula Atom) where
  derives := Derives

/-- Its classical extension, with object-level excluded middle. -/
def classicalCalculus (Atom : Type u) : Calculus (Formula Atom) where
  derives := ClassicalDerives

/-- A proof-preserving interpretation of the intuitionistic calculus
    into the classical extension (identity map on formulas). -/
def inclusion (Atom : Type u) :
    Interpretation (intuitionisticCalculus Atom) (classicalCalculus Atom) where
  onFormula := id
  onProof := by
    intro Γ φ derivation
    change ClassicalDerives Γ φ
    exact intuitionistic_to_classical derivation

/-- The intended theorem transport is independent of the specific
    source context: every IPC derivation survives the interpretation. -/
theorem inclusion_preserves {Atom : Type u}
    {Γ : Set (Formula Atom)} {φ : Formula Atom}
    (h : (intuitionisticCalculus Atom).derives Γ φ) :
    (classicalCalculus Atom).derives
      ((inclusion Atom).onFormula '' Γ) ((inclusion Atom).onFormula φ) :=
  (inclusion Atom).onProof h

/-- Interpretation composition works on this concrete embedding as well. -/
theorem inclusion_composed_with_identity {Atom : Type u}
    {Γ : Set (Formula Atom)} {φ : Formula Atom}
    (h : Derives Γ φ) :
    (classicalCalculus Atom).derives
      ((Interpretation.compose (inclusion Atom)
        (Interpretation.identity (classicalCalculus Atom))).onFormula '' Γ)
      ((Interpretation.compose (inclusion Atom)
        (Interpretation.identity (classicalCalculus Atom))).onFormula φ) :=
  (Interpretation.compose (inclusion Atom)
    (Interpretation.identity (classicalCalculus Atom))).onProof h

/-- The reverse *identity-on-formulas* proof interpretation is impossible.
    CPC proves the excluded-middle instance, and Experiment 003 has a
    certified Kripke countermodel to its intuitionistic derivability. -/
theorem no_reverse_identity_interpretation :
    ¬ ∃ I : Interpretation (classicalCalculus Unit)
                            (intuitionisticCalculus Unit),
        ∀ φ : Formula Unit, I.onFormula φ = φ := by
  rintro ⟨I, hid⟩
  let em : Formula Unit := .disj (.atom ()) (.impl (.atom ()) .bottom)
  have classical_em : (classicalCalculus Unit).derives
      (∅ : Set (Formula Unit)) em := by
    exact ClassicalDerives.excludedMiddle
  have transported := I.onProof classical_em
  have intuitionistic_em : Derives (∅ : Set (Formula Unit)) em := by
    simpa [intuitionisticCalculus, em, hid] using transported
  exact two_world_em_not_derivable intuitionistic_em

end Axiomscope.Experiment008

#print axioms Axiomscope.Experiment008.intuitionistic_to_classical
#print axioms Axiomscope.Experiment008.inclusion_preserves
#print axioms Axiomscope.Experiment008.inclusion_composed_with_identity
#print axioms Axiomscope.Experiment008.no_reverse_identity_interpretation
