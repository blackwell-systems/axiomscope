import Axiomscope.Experiments.NaturalNumbers

/-!
# Experiment 005 — axiomatic natural-number structures

An arbitrary carrier is equipped with zero, successor, injectivity, zero/successor
disjointness, and a *full* induction principle over every Lean predicate.
We recover the unique zero/successor-preserving map from Experiment 004's
inductive numbers and prove it is bijective. Adding recursive equations for
addition and multiplication makes that map preserve arithmetic.

The full predicate-quantifying induction field is a second-order-style
assumption in Lean's ambient higher-order logic: this is NOT first-order PA,
which has an induction schema only for formulas in its first-order language.
Categoricity here must not be misreported as categoricity of first-order PA.

Finally, a two-track successor structure satisfies injectivity and zero
disjointness but fails induction, showing those weaker requirements alone
do not characterize the naturals.
-/

namespace Axiomscope.Experiment005

open Axiomscope.Experiment004 (Number)

universe u

/-- Weak zero/successor data, *without* induction. -/
structure WeakSuccessor (α : Type u) where
  zero : α
  succ : α → α
  zero_ne_succ : ∀ x, zero ≠ succ x
  succ_injective : Function.Injective succ

/-- Full-induction Peano structure on an arbitrary carrier. -/
structure PeanoSystem (α : Type u) extends WeakSuccessor α where
  induction : ∀ P : α → Prop, P zero →
    (∀ x, P x → P (succ x)) → ∀ x, P x

/-- Arithmetic also supplies recursive equations for + and *. -/
structure ArithmeticSystem (α : Type u) extends PeanoSystem α where
  add : α → α → α
  mul : α → α → α
  add_zero : ∀ a, add a zero = a
  add_succ : ∀ a b, add a (succ b) = succ (add a b)
  mul_zero : ∀ a, mul a zero = zero
  mul_succ : ∀ a b, mul a (succ b) = add (mul a b) a

/-- Interpret a freshly constructed number in any Peano system. -/
def encode {α : Type u} (M : PeanoSystem α) : Number → α
  | .zero => M.zero
  | .succ n => M.succ (encode M n)

/-- The interpreter respects the constructors by definition. -/
theorem encode_succ {α : Type u} (M : PeanoSystem α) (n : Number) :
    encode M (.succ n) = M.succ (encode M n) := rfl

/-- Any function preserving zero and successor equals the interpreter. -/
theorem encode_unique {α : Type u} (M : PeanoSystem α)
    (f : Number → α)
    (hz : f .zero = M.zero)
    (hs : ∀ n, f (.succ n) = M.succ (f n)) :
    ∀ n, f n = encode M n := by
  intro n
  induction n with
  | zero => exact hz
  | succ n ih =>
      change f (.succ n) = M.succ (encode M n)
      rw [hs n, ih]

/-- Distinct numbers map to distinct elements using successor injectivity. -/
theorem encode_injective {α : Type u} (M : PeanoSystem α) :
    Function.Injective (encode M) := by
  intro a
  induction a with
  | zero =>
      intro b h
      cases b with
      | zero => rfl
      | succ b =>
          change M.zero = M.succ (encode M b) at h
          exact (M.zero_ne_succ _ h).elim
  | succ a ih =>
      intro b h
      cases b with
      | zero =>
          change M.succ (encode M a) = M.zero at h
          exact (M.zero_ne_succ _ h.symm).elim
      | succ b =>
          change M.succ (encode M a) = M.succ (encode M b) at h
          exact congrArg Number.succ (ih b (M.succ_injective h))

/-- Full induction says every element is reached by the interpreter. -/
theorem encode_surjective {α : Type u} (M : PeanoSystem α) :
    Function.Surjective (encode M) := by
  intro x
  apply M.induction (P := fun y => ∃ n : Number, encode M n = y)
  · exact ⟨.zero, rfl⟩
  · intro y ⟨n, hn⟩
    refine ⟨.succ n, ?_⟩
    change M.succ (encode M n) = M.succ y
    rw [hn]

/-- Full induction and constructor axioms uniquely determine the carrier
up to equivalence, with a canonical zero/successor-preserving forward map. -/
def equivalence {α : Type u} (M : PeanoSystem α) : Number ≃ α :=
  Equiv.ofBijective (encode M) ⟨encode_injective M, encode_surjective M⟩

/-- The interpreter also respects the recursively axiomatized addition. -/
theorem encode_add {α : Type u} (M : ArithmeticSystem α) (a b : Number) :
    encode M.toPeanoSystem (Experiment004.add a b) =
      M.add (encode M.toPeanoSystem a) (encode M.toPeanoSystem b) := by
  induction b with
  | zero =>
      change encode M.toPeanoSystem a =
        M.add (encode M.toPeanoSystem a) M.zero
      exact (M.add_zero _).symm
  | succ b ih =>
      change M.succ (encode M.toPeanoSystem (Experiment004.add a b)) =
        M.add (encode M.toPeanoSystem a)
          (M.succ (encode M.toPeanoSystem b))
      rw [M.add_succ, ih]

/-- The interpreter also respects recursively axiomatized multiplication. -/
theorem encode_mul {α : Type u} (M : ArithmeticSystem α) (a b : Number) :
    encode M.toPeanoSystem (Experiment004.mul a b) =
      M.mul (encode M.toPeanoSystem a) (encode M.toPeanoSystem b) := by
  induction b with
  | zero =>
      change M.zero = M.mul (encode M.toPeanoSystem a) M.zero
      exact (M.mul_zero _).symm
  | succ b ih =>
      change encode M.toPeanoSystem
          (Experiment004.add (Experiment004.mul a b) a) =
        M.mul (encode M.toPeanoSystem a)
          (M.succ (encode M.toPeanoSystem b))
      rw [M.mul_succ, encode_add, ih]

/-- Experiment 004's inductively constructed numbers satisfy the axioms. -/
def standard : ArithmeticSystem Number where
  zero := .zero
  succ := .succ
  zero_ne_succ := Experiment004.zero_ne_succ
  succ_injective := Experiment004.succ_injective
  induction := by
    intro P hz hs n
    exact Experiment004.induction_rule hz hs n
  add := Experiment004.add
  mul := Experiment004.mul
  add_zero := Experiment004.add_zero
  add_succ := Experiment004.add_succ
  mul_zero := Experiment004.mul_zero
  mul_succ := Experiment004.mul_succ

/-- Two disjoint successor tracks: the second track is unreachable from zero. -/
def twoTracks : WeakSuccessor (Number × Bool) where
  zero := (.zero, false)
  succ := fun x => (.succ x.1, x.2)
  zero_ne_succ := by
    intro x h
    have hfst : Number.zero = Number.succ x.1 := congrArg Prod.fst h
    exact Experiment004.zero_ne_succ x.1 hfst
  succ_injective := by
    intro x y h
    apply Prod.ext
    · exact Experiment004.succ_injective (congrArg Prod.fst h)
    · exact congrArg Prod.snd h

/-- Weak successor axioms alone do not entail full induction. -/
theorem twoTracks_not_inductive :
    ¬ (∀ P : Number × Bool → Prop, P twoTracks.zero →
      (∀ x, P x → P (twoTracks.succ x)) → ∀ x, P x) := by
  intro h
  have hfalse : ∀ x : Number × Bool, x.2 = false :=
    h (fun x => x.2 = false) (by rfl) (by
      intro x hx
      exact hx)
  have impossible : true = false := hfalse (.zero, true)
  cases impossible

end Axiomscope.Experiment005

#print axioms Axiomscope.Experiment005.encode_succ
#print axioms Axiomscope.Experiment005.encode_unique
#print axioms Axiomscope.Experiment005.encode_injective
#print axioms Axiomscope.Experiment005.encode_surjective
#print axioms Axiomscope.Experiment005.equivalence
#print axioms Axiomscope.Experiment005.encode_add
#print axioms Axiomscope.Experiment005.encode_mul
#print axioms Axiomscope.Experiment005.twoTracks_not_inductive
