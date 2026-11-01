# Experiment 012 — a signature-indexed satisfaction condition

## The research checkpoint

The research question here is **not** whether we can invent a better
description of logical translations. **Institution theory already provides
the abstract structure we have been approaching.** Its principal ingredients
are a category of signatures, a covariant sentence functor, a contravariant
model functor, and a satisfaction condition connecting them.

The original literature and the
[Internet Encyclopedia of Philosophy overview](https://iep.utm.edu/insti-th/)
state the condition for a signature morphism `f : Σ → Σ′`:

```text
M′ ⊨Σ′ Sen(f)(φ)   ↔   Mod(f)(M′) ⊨Σ φ
```

Our immediate goal is to reproduce the essentials *honestly and
machine-checkably* as a baseline, not claim that it is original.

## Exact fragment formalized

[Experiment012.lean](../../Axiomscope/Experiments/Experiment012.lean)
uses the pre-existing intuitionistic propositional formula syntax from
Experiment 003, but gives it ordinary single-valuation propositional
semantics. This choice intentionally separates **syntax translation and
valuation reduct** from the Kripke-world model transport of Experiment 011.

| Institution ingredient | Experiment 012 representation |
| --- | --- |
| Signature `Σ` | Type `Atom` of atomic names |
| Signature morphism `f` | Function `A → B` |
| Sentences `Sen(A)` | `Formula A` |
| Sentence translation `Sen(f)` | `sentenceMap f`, recursively renaming atoms |
| Models `Mod(A)` | `Valuation A := A → Prop` |
| Model reduct `Mod(f)` | `reduct f M := M ∘ f` (opposite direction) |
| Satisfaction `M ⊨ φ` | Recursive `satisfied M φ : Prop` |
| Satisfaction condition | `satisfaction_condition`, proved by induction on formulas |

The formula syntax includes atoms, bottom, disjunction and implication.
The satisfaction interpretation uses the ordinary propositional
connectives of Lean `Prop`, rather than Kripke implication over future
worlds. The propositional valuation class therefore is **not the same
semantic class** as Experiment 003's Kripke models.

## Formally checked obligations

1. Sentence translations preserve signature identity and composition:
   `Sen(id) = id` and `Sen(g ∘ f) = Sen(g) ∘ Sen(f)`.
2. Model reducts preserve identity and reverse composition:
   `Mod(g ∘ f) = Mod(f) ∘ Mod(g)` on valuations.
3. For all `f`, `M`, `φ`: the *satisfaction condition*.
4. The condition remains true for two successively composed signature
   translations.
5. The condition extends pointwise to any set of assumptions `Γ`.
6. A deliberately wrong reduct for `Unit → Bool` disagrees on the
   atomic sentence, proving that the satisfaction obligation can fail
   under a bad model translation.

These results are small but mathematically explicit. The positive
condition does **not** hold for arbitrary formula and model functions:
they must satisfy the proven relation.

## Comparison against existing theory

The existing concept is institution theory, developed by Goguen and
Burstall, including the familiar account in
[Institutions: Abstract Model Theory for Specification and Programming](https://courses.grainger.illinois.edu/cs522/sp2016/InstitutionsAbstractModelTheory.pdf).
A modern overview is
[Institution Theory (IEP)](https://iep.utm.edu/insti-th/).

A separate substantial Lean implementation of classical, intuitionistic,
and first-order logic already exists in
[FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation).
We should compare against its semantic and interpretation interfaces
rather than implying AxiomScope has invented those proof techniques.

**What is missing from our formalization:** the full category `Sign`,
functors into `Set` and `Catᵒᵖ`, a category of model morphisms,
and signature-indexed naturality of model transformations. We verify
the relevant identity and composition laws **without** claiming a
complete category-theoretic institution instance.

**What remains unproved:** a distinct theorem or analysis capability
that institution theory or existing formal logic libraries cannot
already represent. The fact that a Lean proof compiles does not
establish mathematical novelty.

## Falsifiable next research objective

Before implementing more abstractions, choose one concrete cross-foundation
task (for example, translation of a genuinely non-propositional
construction with specific assumption requirements) and compare
AxiomScope against institution theory, Isabelle theory interpretations,
and existing Lean infrastructure.

A useful result would be **a verified relative assumption or witness
preservation analysis** that those baselines do not already supply at
comparable specificity. If the baseline handles the example completely,
that is evidence to narrow or pivot the research.

The next experiment should measure an identified mathematical gap,
**not** merely add another known layer to this interface.
