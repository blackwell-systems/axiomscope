import Axiomscope.Experiments.PeanoAxioms

/-!
# Experiment 006 — first-order arithmetic and induction schemas

Terms and formulas are *data*, with named natural-number variable indices and
first-order quantifiers. Quantifiers range over elements of the carrier, not
over arbitrary predicates. First-order induction is expressed as a family of
semantic instances indexed by this formula syntax and by parameters.

We prove that full predicate induction (Experiment 005) validates *every*
first-order formula instance. We also exhibit a first-order induction instance
that fails in a two-track signature, despite well-defined zero/successor.
This is not a proof of the converse, a completeness theorem, or a construction
of a nonstandard model of all first-order Peano axioms.
-/

namespace Axiomscope.Experiment006

universe u

/-- The first-order arithmetic signature, without imposing any axioms. -/
structure Signature (α : Type u) where
  zero : α
  succ : α → α
  add : α → α → α
  mul : α → α → α

/-- Terms are finite syntax trees; variable indices are names, not numbers
living in the interpreted structure. -/
inductive Term where
  | var : Nat → Term
  | zero : Term
  | succ : Term → Term
  | add : Term → Term → Term
  | mul : Term → Term → Term
  deriving Repr, DecidableEq

/-- First-order formulas over equality, connectives, and bound individual
variables. No constructor quantifies over arbitrary predicates. -/
inductive Formula where
  | eq : Term → Term → Formula
  | bottom : Formula
  | conj : Formula → Formula → Formula
  | disj : Formula → Formula → Formula
  | impl : Formula → Formula → Formula
  | all : Nat → Formula → Formula
  | ex : Nat → Formula → Formula
  deriving Repr, DecidableEq

/-- Reassign one *individual* variable in an environment. -/
def bind (ρ : Nat → α) (i : Nat) (a : α) : Nat → α :=
  fun j => if j = i then a else ρ j

@[simp] theorem bind_same (ρ : Nat → α) (i : Nat) (a : α) :
    bind ρ i a i = a := by simp [bind]

@[simp] theorem bind_other (ρ : Nat → α) (i j : Nat) (a : α)
    (h : j ≠ i) : bind ρ i a j = ρ j := by simp [bind, h]

/-- Evaluation of terms in an arbitrary arithmetic signature. -/
def eval {α : Type u} (M : Signature α) (ρ : Nat → α) : Term → α
  | .var i => ρ i
  | .zero => M.zero
  | .succ t => M.succ (eval M ρ t)
  | .add t s => M.add (eval M ρ t) (eval M ρ s)
  | .mul t s => M.mul (eval M ρ t) (eval M ρ s)

/-- Tarski satisfaction for first-order formulas. -/
def satisfies {α : Type u} (M : Signature α) (ρ : Nat → α) :
    Formula → Prop
  | .eq t s => eval M ρ t = eval M ρ s
  | .bottom => False
  | .conj p q => satisfies M ρ p ∧ satisfies M ρ q
  | .disj p q => satisfies M ρ p ∨ satisfies M ρ q
  | .impl p q => satisfies M ρ p → satisfies M ρ q
  | .all i p => ∀ a : α, satisfies M (bind ρ i a) p
  | .ex i p => ∃ a : α, satisfies M (bind ρ i a) p

/-- A single formula instance, possibly with free parameter variables.
This quantifies over formulas as *syntax* rather than over all predicates
of the carrier. Hence it describes the first-order induction schema. -/
def instanceValid {α : Type u} (M : Signature α)
    (p : Formula) (x : Nat) (ρ : Nat → α) : Prop :=
  satisfies M (bind ρ x M.zero) p ∧
    (∀ a, satisfies M (bind ρ x a) p →
      satisfies M (bind ρ x (M.succ a)) p) →
    ∀ a, satisfies M (bind ρ x a) p

/-- Every instance in the first-order formula induction schema is valid,
including under arbitrary assignments to its remaining free variables. -/
def FirstOrderInduction {α : Type u} (M : Signature α) : Prop :=
  ∀ (p : Formula) (x : Nat) (ρ : Nat → α),
    instanceValid M p x ρ

/-- Forget the axioms of an arithmetic system, retaining only its signature. -/
def signatureOf {α : Type u} (M : Experiment005.ArithmeticSystem α) :
    Signature α where
  zero := M.zero
  succ := M.succ
  add := M.add
  mul := M.mul

/-- Full induction entails every first-order formula instance. -/
theorem full_induction_implies_first_order {α : Type u}
    (M : Experiment005.ArithmeticSystem α) :
    FirstOrderInduction (signatureOf M) := by
  intro p x ρ ⟨hzero, hstep⟩ a
  exact M.induction
    (fun b => satisfies (signatureOf M) (bind ρ x b) p)
    hzero hstep a

/-- Formula saying that an element is zero or has a predecessor.
Variable 0 is free; variable 1 is bound by the existential quantifier. -/
def zeroOrSuccessor : Formula :=
  .disj (.eq (.var 0) .zero)
    (.ex 1 (.eq (.var 0) (.succ (.var 1))))

/-- Interpret the formula as an ordinary statement in any signature. -/
theorem zeroOrSuccessor_iff {α : Type u} (M : Signature α) (ρ : Nat → α) :
    satisfies M ρ zeroOrSuccessor ↔
      ρ 0 = M.zero ∨ ∃ a : α, ρ 0 = M.succ a := by
  simp [zeroOrSuccessor, satisfies, eval, bind]

/-- Two successor tracks, with an additional zero-like starting element.
The arithmetic operations are included just to interpret the whole language;
this theorem does not assert that this structure satisfies first-order PA. -/
def twoTracks : Signature (Experiment004.Number × Bool) where
  zero := (.zero, false)
  succ := fun a => (.succ a.1, a.2)
  add := fun a b => (Experiment004.add a.1 b.1, a.2)
  mul := fun a b => (Experiment004.mul a.1 b.1, false)

/-- The first-order formula 'x = 0 or x has a predecessor' gives an explicit
induction instance that fails in this weak two-track structure. -/
theorem twoTracks_not_first_order_inductive :
    ¬ FirstOrderInduction twoTracks := by
  intro h
  let ρ : Nat → Experiment004.Number × Bool := fun _ => twoTracks.zero
  have hz : satisfies twoTracks (bind ρ 0 twoTracks.zero) zeroOrSuccessor := by
    apply (zeroOrSuccessor_iff twoTracks _).2
    left
    simp
  have hs : ∀ a, satisfies twoTracks (bind ρ 0 a) zeroOrSuccessor →
      satisfies twoTracks (bind ρ 0 (twoTracks.succ a)) zeroOrSuccessor := by
    intro a _
    apply (zeroOrSuccessor_iff twoTracks _).2
    right
    exact ⟨a, by simp⟩
  have hall := (h zeroOrSuccessor 0 ρ) ⟨hz, hs⟩
  have hbad := (zeroOrSuccessor_iff twoTracks
    (bind ρ 0 (Experiment004.Number.zero, true))).1
    (hall (Experiment004.Number.zero, true))
  rcases hbad with hzero | ⟨a, hsucc⟩
  · change (Experiment004.Number.zero, true) =
        (Experiment004.Number.zero, false) at hzero
    have hb : true = false := congrArg Prod.snd hzero
    cases hb
  · change (Experiment004.Number.zero, true) =
        (Experiment004.Number.succ a.1, a.2) at hsucc
    have hn : Experiment004.Number.zero = Experiment004.Number.succ a.1 :=
      congrArg Prod.fst hsucc
    exact Experiment004.zero_ne_succ a.1 hn

end Axiomscope.Experiment006

#print axioms Axiomscope.Experiment006.bind_same
#print axioms Axiomscope.Experiment006.bind_other
#print axioms Axiomscope.Experiment006.zeroOrSuccessor_iff
#print axioms Axiomscope.Experiment006.full_induction_implies_first_order
#print axioms Axiomscope.Experiment006.twoTracks_not_first_order_inductive
