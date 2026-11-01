# Experiment 011 — model-changing Kripke interpretations

## Mathematical question

Experiments 009 and 010 changed the formula language and packaged
proof and semantic preservation, but both semantics were evaluated at
worlds of the **same Kripke model**. Experiment 011 introduces separately
typed model classes and world types, plus a satisfaction correspondence
between them.

The example uses intuitionistic Kripke semantics. The source models
have worlds `Nat`, whereas target models have worlds `Nat × Bool`;
the atom valuation is pulled back along the projection to natural
number worlds.

**This is a bounded-morphism / p-morphism experiment in established
modal and intuitionistic Kripke semantics, not an original theorem.**

## General certificate

[ModelInterpretations.lean](../../Axiomscope/ModelInterpretations.lean)
defines `ModelInterpretation`, packaging:

- A proof-preserving object-language interpretation.
- A function mapping *source models* into *target models*.
- A function mapping target worlds into source worlds, indexed by the
  original source model.
- A verified satisfaction condition for every source model, target world,
  and source formula:

```text
targetSat (onModel M) w (onFormula φ)
  ↔ sourceSat M (onWorld M w) φ
```

Identity and composition are defined generically for these certificates;
the latter composes proof transport, model translation, world maps, and
semantic equivalences simultaneously. A separate theorem transports
the satisfaction of arbitrary hypothesis contexts.

## The essential back condition

[Experiment011.lean](../../Axiomscope/Experiments/Experiment011.lean)
defines a `BoundedMap` from target worlds to source worlds:

```text
p : TargetWorld → SourceWorld

forth:   b ≤ b'  ⇒  p(b) ≤ p(b')
back:    p(b) ≤ a  ⇒  ∃ b' ≥ b, p(b') = a
```

We then pull a persistent source atomic valuation back along `p`.
The theorem `pullback_forcing_equiv` shows by structural induction that
**every source formula** is forced in the pulled-back model at `b`
if and only if it is forced in the original model at `p(b)`.

The back condition is used in the implication case. Monotonicity alone
would not allow an implication over all source futures to be recovered
from an implication over target futures.

## Concrete model and syntax translation

Our target world type is `Nat × Bool` with its product preorder. The
projection to `Nat` is monotone. Any source successor world can be
lifted while preserving the target world's Boolean coordinate.

The concrete `certifiedCover` combines:

- The nonidentity **formula** translation from Experiment 009,
  `atom a ↦ atom a ∧ ⊤`.
- The corresponding verified natural-deduction proof translation.
- The new **model** translation, pulling source valuations from
  `Model Atom Nat` to `Model Atom (Nat × Bool)`.
- The new **world** translation given by projection.
- The proven semantic equivalence for arbitrary source models,
  target worlds, and source formulas.

It also instantiates the general context-satisfaction theorem and
certificate composition.

## Falsifying a naive world translation

We provide a counterexample based on Experiment 003's two-world
Kripke model. A singleton world mapped to the root is monotone but
cannot lift the accessible future where the atom becomes true.

Consequently:

- In a singleton model where the atom is always false,
  the implication `p → ⊥` holds.
- At the root of the original two-world model,
  `p → ⊥` does not hold, because the atom becomes true later.

The formal mismatch **does not claim** that no other translation
could work. It shows that mere monotonicity cannot justify the general
forcing equivalence established for bounded maps.

## Acceptance and research limits

The experiment passes only when Lean checks the generic
interpretation certificate, bounded morphism theorem, concrete
distinct-world certificate, context and composition theorems, and
the counterexample; when the proof ledger records Lean-observed
axioms; and when existing verification remains green.

Remaining limitations:

- Both model classes are Kripke models in the **same Lean kernel**.
- We do not model full theories of ZF, type theory, or categorical
  foundations or compare their expressive power.
- Our model map is a particular bounded-morphism pullback.
- The construction is a known preservation method in Kripke semantics.
- We have not benchmarked against existing modal logic, institution,
  category-theoretic or logical-framework libraries.

**Next mathematical gate:** represent satisfaction conditions for
translations between *different classes of structures*, compare against
established institution-morphism definitions, and identify a testable
capability beyond their existing implementations.
