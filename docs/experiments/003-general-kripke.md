# Experiment 003 — generalized Kripke semantics

## Question

Can the one-atom, two-world soundness and nonderivability construction from
Experiment 002 be expressed as a reusable theorem for arbitrary atomic
propositions and arbitrary preordered worlds?

## Model

For atom type `Atom` and preordered world type `World`, a `Model` contains:

- `atomForces : World → Atom → Prop`, an atomic forcing relation.
- `persistent`, which requires atomic forcing to be monotone along the world preorder.

Formulas contain atoms, bottom, disjunction and implication. The implication
clause quantifies over every accessible future world.

## General results

- `forces_mono`: all formulas are persistent.
- `sound`: every derivation in the natural-deduction calculus is valid in **every** model of this form.
- `generic_em_not_derivable`: if an atom is not forced at one world but
  is forced at a later accessible world, its excluded-middle instance has
  no derivation from the empty context in this calculus.
- `two_world_em_not_derivable`: instantiates the general result with the
  two-world preorder.

The key logical distinction is that failure of an atom at the current world
does not establish its negation: the atom may become true at a future world.

## Scope

This is a standard Kripke soundness argument in a reusable formalization.
It does not claim semantic completeness, independence in ZFC, or a new
mathematical theorem. It extends only the indicated propositional fragment;
conjunction, universal and existential quantification, equality, and
general set-theoretic axioms are outside the current calculus.

## Verification and dependency accounting

The module is checked explicitly by CI using
`lake env lean Axiomscope/Experiments/GeneralKripke.lean`.
Its exported results include `#print axioms` queries. They should be
registered in the generated proof ledger after the Lean check confirms the
module elaborates; do not hand-author axiom observations.

Source: [GeneralKripke.lean](../../Axiomscope/Experiments/GeneralKripke.lean).
