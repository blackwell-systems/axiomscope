# Experiment 006 — first-order arithmetic and formula induction

## Research question

How does induction ranging over first-order *formulas* differ from the
stronger induction assumption for **all** predicates in Experiment 005?

## The language

`Term` is an inductive syntax of variables (named by natural-number indices),
zero, successor, addition, and multiplication. `Formula` is an inductive
syntax of equality, bottom, conjunction, disjunction, implication, universal
quantification, and existential quantification. Quantifiers bind only
individual variable indices, **not predicates**. Names can be shadowed.

`eval` and `satisfies` interpret this syntax in any `Signature α`
supplied with zero, successor, addition, and multiplication, together
with an environment assigning a carrier element to each variable.
This is a Tarski-style first-order semantics.

## Semantic induction schema

For each syntax formula `p`, distinguished variable `x`, and environment
`ρ` supplying parameter values, the semantic induction instance says:

1. `p` holds when `x` is assigned zero.
2. If `p` holds at an arbitrary value, it holds at that value's successor.
3. Then `p` holds at every value assigned to `x`.

`FirstOrderInduction M` is the family of these instances for **all
syntax formulas and parameter environments**. It is not an axiom
quantifying over every arbitrary predicate on the carrier. In Lean the
schema is represented directly through satisfaction, rather than as
a family of object-level formulas with substitution; syntactic axiom
generation and its capture-avoidance correctness remain a future task.

## Formal implications and limits

- `full_induction_implies_first_order` uses Experiment 005's full
  predicate induction to validate every first-order formula instance.
  This is an implication, not an equivalence.
- `zeroOrSuccessor_iff` gives the exact interpretation of the formula
  `x = 0 ∨ ∃y, x = S(y)`.
- `twoTracks_not_first_order_inductive` finds an explicit failure of
  that formula's induction instance for a carrier with two successor
  tracks; it does **not** purport to be a model of first-order PA.

The first-order language is genuinely restricted to finite formulas.
The ambient metatheory remains Lean dependent type theory. We have
**not** established noncategoricity of first-order PA in Lean or constructed
a nonstandard PA model. Doing so would require additional metatheory.
We have also not shown that the semantic schema, without further
axioms, implies full predicate induction.

The visible `#print axioms` ledger concerns Lean kernel assumptions;
the explicit full-induction field of the Experiment 005 model is an
independent semantic hypothesis. Both must be distinguished in the
foundational comparison.

Source: [FirstOrderArithmetic.lean](../../Axiomscope/Experiments/FirstOrderArithmetic.lean)
· [Audited results](../../proofs/experiments/006-first-order-induction.json)
