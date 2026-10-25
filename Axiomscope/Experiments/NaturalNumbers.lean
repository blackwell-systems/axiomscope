import Mathlib

/-!
# Experiment 004 — reconstructing natural numbers

This module introduces a fresh inductive type with zero and successor,
without referencing Lean's built-in Nat in its *definition*. We derive
induction and recursion, define addition and multiplication recursively,
prove their basic arithmetic laws, and construct an explicit equivalence
with Lean's Nat.

**Foundational boundary:** an inductive declaration is licensed by Lean's
existing inductive-type rules. This is a reconstruction *inside* Lean,
not an existence proof from the propositional calculus of Experiments
002–003 and not a newly discovered construction of arithmetic.
-/

namespace Axiomscope.Experiment004

universe u

/-- A separate recursive number type, not an alias for Lean's Nat. -/
inductive Number where
  | zero : Number
  | succ : Number → Number

/-- Structural induction follows from the fresh inductive definition. -/
theorem induction_rule {P : Number → Prop}
    (hz : P .zero) (hs : ∀ n, P n → P (.succ n)) :
    ∀ n : Number, P n := by
  intro n
  induction n with
  | zero => exact hz
  | succ n ih => exact hs n ih

/-- Primitive recursion into any type. -/
def recurse {α : Type u} (z : α) (s : α → α) : Number → α
  | .zero => z
  | .succ n => s (recurse z s n)

/-- The recursion equations determine the resulting map uniquely. -/
theorem recurse_unique {α : Type u} (z : α) (s : α → α)
    (f : Number → α)
    (hzero : f .zero = z)
    (hsucc : ∀ n, f (.succ n) = s (f n)) :
    ∀ n, f n = recurse z s n := by
  intro n
  induction n with
  | zero => exact hzero
  | succ n ih =>
      rw [hsucc n, ih]
      rfl

/-- The zero and successor constructors are disjoint. -/
theorem zero_ne_succ (n : Number) :
    Number.zero ≠ Number.succ n := by
  intro h
  cases h

/-- Successor is injective. -/
theorem succ_injective : Function.Injective Number.succ := by
  intro a b h
  cases h
  rfl

/-- Convert our number type to Lean's built-in naturals. -/
def toNat : Number → Nat
  | .zero => 0
  | .succ n => Nat.succ (toNat n)

/-- Convert Lean naturals to our independently declared number type. -/
def ofNat : Nat → Number
  | 0 => .zero
  | Nat.succ n => .succ (ofNat n)

/-- The conversions are inverse in the Nat-to-Nat direction. -/
theorem toNat_ofNat : ∀ n : Nat, toNat (ofNat n) = n := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      simp [ofNat, toNat, ih]

/-- The conversions are inverse in the Number-to-Number direction. -/
theorem ofNat_toNat : ∀ n : Number, ofNat (toNat n) = n := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      simp [toNat, ofNat, ih]

/-- An explicit equivalence, rather than just a cardinality equality. -/
def equivNat : Number ≃ Nat where
  toFun := toNat
  invFun := ofNat
  left_inv := ofNat_toNat
  right_inv := toNat_ofNat

/-- Addition defined by recursion on the right argument. -/
def add (a : Number) : Number → Number
  | .zero => a
  | .succ b => .succ (add a b)

/-- Multiplication defined using previously defined addition. -/
def mul (a : Number) : Number → Number
  | .zero => .zero
  | .succ b => add (mul a b) a

theorem add_zero (a : Number) : add a .zero = a := rfl

theorem add_succ (a b : Number) :
    add a (.succ b) = .succ (add a b) := rfl

theorem mul_zero (a : Number) : mul a .zero = .zero := rfl

theorem mul_succ (a b : Number) :
    mul a (.succ b) = add (mul a b) a := rfl

/-- Our recursive addition agrees with Nat addition. -/
theorem toNat_add (a b : Number) :
    toNat (add a b) = toNat a + toNat b := by
  induction b with
  | zero => rfl
  | succ b ih =>
      change Nat.succ (toNat (add a b)) = toNat a + Nat.succ (toNat b)
      rw [ih, Nat.add_succ]

/-- Our recursive multiplication agrees with Nat multiplication. -/
theorem toNat_mul (a b : Number) :
    toNat (mul a b) = toNat a * toNat b := by
  induction b with
  | zero => rfl
  | succ b ih =>
      change toNat (add (mul a b) a) = toNat a * Nat.succ (toNat b)
      rw [toNat_add, ih, Nat.mul_succ]

/-- The forward conversion is injective because the two maps are inverses. -/
theorem toNat_injective : Function.Injective toNat := by
  intro a b h
  have h' := congrArg ofNat h
  simpa only [ofNat_toNat] using h'

/-- Addition is associative. -/
theorem add_assoc (a b c : Number) :
    add (add a b) c = add a (add b c) := by
  apply toNat_injective
  simp [toNat_add, Nat.add_assoc]

/-- Addition is commutative. -/
theorem add_comm (a b : Number) : add a b = add b a := by
  apply toNat_injective
  simp [toNat_add, Nat.add_comm]

/-- Multiplication is associative. -/
theorem mul_assoc (a b c : Number) :
    mul (mul a b) c = mul a (mul b c) := by
  apply toNat_injective
  simp [toNat_mul, Nat.mul_assoc]

/-- Multiplication distributes over addition. -/
theorem mul_add (a b c : Number) :
    mul a (add b c) = add (mul a b) (mul a c) := by
  apply toNat_injective
  simp [toNat_mul, toNat_add, Nat.mul_add]

end Axiomscope.Experiment004

#print axioms Axiomscope.Experiment004.induction_rule
#print axioms Axiomscope.Experiment004.recurse_unique
#print axioms Axiomscope.Experiment004.zero_ne_succ
#print axioms Axiomscope.Experiment004.succ_injective
#print axioms Axiomscope.Experiment004.toNat_ofNat
#print axioms Axiomscope.Experiment004.ofNat_toNat
#print axioms Axiomscope.Experiment004.equivNat
#print axioms Axiomscope.Experiment004.toNat_injective
#print axioms Axiomscope.Experiment004.toNat_add
#print axioms Axiomscope.Experiment004.toNat_mul
#print axioms Axiomscope.Experiment004.add_assoc
#print axioms Axiomscope.Experiment004.add_comm
#print axioms Axiomscope.Experiment004.mul_assoc
#print axioms Axiomscope.Experiment004.mul_add
