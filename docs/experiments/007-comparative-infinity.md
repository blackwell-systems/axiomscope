# Experiment 007 — comparative infinity

## Research question

When can a set known to be infinite be shown to contain a countably
infinite subset? When is a Dedekind witness available?

These are established questions in set theory. This pilot compares
two **assumption profiles in Lean**, not separate formalizations of
ZF and ZF without choice.

## Objects under comparison

- Ordinary infinity: `Infinite α`, meaning `α` is not finite.
- Countable subset: an injective sequence `Nat → α`.
- Finite avoidance: a supplied *uniform function*
  `pick : List α → α` satisfying `pick xs ∉ xs`.
- Dedekind witness: an injective, nonsurjective endomap `α → α`.

A uniform selector is stronger data than the propositions
`∀ xs, ∃ a, a ∉ xs`. This is precisely why it is an interesting
explicit assumption.

## Formal comparison

**Explicit uniform finite avoidance** gives an injective sequence:
build finite prefixes recursively, choose the next point outside the
prefix, and use freshness to prove that no two outputs are equal.

**Ambient infinity** gives an injective sequence through Mathlib's
`Infinite.natEmbedding`. The proof dependency ledger records which
Lean axioms this construction relies upon. This is not a theorem
inside an independently defined choice-free ZF theory.

**Dedekind infinitude** is witnessed by successor on `Nat`,
and that witness can be transported along an explicit equivalence
`α ≃ Nat`. We are not claiming this restricted proof establishes
the result for arbitrary infinite sets.

## Acceptance criterion

Compare independently verified theorem statements, *explicit
hypotheses*, axiom dependency reports, and witness provenance
without conflating the absence of a kernel axiom with the absence
of mathematical assumptions. CI must agree with the generated
proof dependency ledger.

## Not established

This experiment does **not** prove any independence statement.
Showing that ordinary infinity does not imply Dedekind infinity
over ZF requires an independently justified set-theoretic model
or a published relative-consistency argument. A tactic failing,
or the use of `Classical.choice` in a particular Lean proof,
does not establish necessity.

Formal source: [ComparativeInfinity.lean](../../Axiomscope/Experiments/ComparativeInfinity.lean).
Generated report: [007-comparative-infinity.json](../../proofs/experiments/007-comparative-infinity.json).
