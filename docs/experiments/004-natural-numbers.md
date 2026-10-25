# Experiment 004 — reconstructing natural numbers inside Lean

## Research question

What do we obtain from a zero constructor, an unrestricted successor
constructor, and Lean's existing inductive-type elimination rules?

We deliberately define `Experiment004.Number` as a **fresh inductive
type**, without mentioning `Nat` in its definition. Lean provides the
resulting induction and recursion machinery. We then implement a
non-dependent recursion operator, show it is unique, and prove the
distinctness of zero from successors and injectivity of successor.

## From structure to arithmetic

Addition is defined by recursion on the second argument, and
multiplication is defined by recursion using addition.

We define `toNat : Number → Nat` and `ofNat : Nat → Number` and
prove they are mutual inverses. This supplies an explicit
`equivNat : Number ≃ Nat`. It also lets us check that the recursive
operations agree with Lean's operations, and transport proofs of
associativity, commutativity, and distributivity.

**Dependency distinction:** the basic recurrence equations and the
new inductive type do not depend on a set-theoretic axiom of infinity
as an explicit premise. Instead, the ability to declare a recursive
inductive type is a capability already present in Lean's ambient
dependent type theory. Reconstructing `Number` does not derive the
existence of an infinite object from our earlier propositional calculus
or from pure first-order logic.

## What this does and does not show

- It builds a genuinely separate datatype with the Peano-style
  constructors.
- It proves recursion, induction, concrete arithmetic laws, and
  compatibility with Lean's built-in naturals.
- The arithmetic-law proofs currently transport results about
  Lean `Nat` through a proved equivalence. They are not independent
  foundational proofs of arithmetic without Mathlib.
- It is not a new natural-number system, a proof of set-theoretic infinity,
  or a demonstration that arithmetic requires no foundational commitments.

## Next comparison

A proper foundation-level experiment should state a *separate*
first-order theory (for example Peano axioms), an interpretation of
arithmetic in a theory of sets, or a natural numbers object in a
category. We can then compare which rules or assumptions must be
supplied to recover induction and recursion, distinguishing
representation-level equivalence from interpretation of formal theories.

Source: [NaturalNumbers.lean](../../Axiomscope/Experiments/NaturalNumbers.lean).
Proof assumptions are inspected using `#print axioms` and recorded in
AxiomScope's generated ledger after verification.
