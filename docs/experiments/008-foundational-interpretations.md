# Experiment 008 — proof-preserving logical interpretations

## Research target

Our first mathematical milestone beyond assumption auditing is a **verified
relationship between two explicitly defined deductive systems**. We choose
a small common propositional language because Experiment 003 already gives
a model-based nonderivability theorem for its intuitionistic calculus.

This is a **pilot for interpretation theory**, not the claimed invention
of a new foundation. We are testing whether AxiomScope's abstractions
remain precise under composition and when a reverse translation fails.

## Source and target

Both calculi work with the same formula syntax:

- atomic propositions;
- falsity;
- disjunction;
- implication.

**IPC** is the inductively defined intuitionistic natural-deduction system
from [Experiment 003](../../Axiomscope/Experiments/GeneralKripke.lean).

**CPC** is an independently defined inductive derivation relation that
contains the corresponding introduction/elimination rules and adds a
schema for excluded middle:

```text
       -----------------------------
       Γ ⊢ᴄ p ∨ (p → ⊥)
```

Thus the systems have the same object language but **different proof
relations**. The target is an explicit extension of the source, not Lean's
ambient proposition prover used in disguise.

## The interpretation interface

[FoundationalInterpretations.lean](../../Axiomscope/FoundationalInterpretations.lean)
defines `Calculus` with a derivability relation and `Interpretation`
with two fields:

- `onFormula : F → G`, translating formulas;
- `onProof`, establishing that any derivation of `φ` from context `Γ`
  yields a derivation of `onFormula φ` from the pointwise image
  `onFormula '' Γ`.

An interpretation *includes* its preservation theorem; a naked mapping
of symbols is not an interpretation. The interface has mechanically proved
identity and composition constructions.

For interpretations `I : A → B` and `J : B → C` this yields:

```text
Γ ⊢ₐ φ   =>   I[Γ] ⊢ᵦ I(φ)   =>   J[I[Γ]] ⊢꜀ J(I(φ))
```

The second step uses the verified preservation witness for `J`.

## Positive result: intuitionistic proofs embed into classical proofs

[Experiment008.lean](../../Axiomscope/Experiments/Experiment008.lean)
proves, by induction on *every introduction and elimination rule* of
the source calculus, that:

```text
Γ ⊢IPC φ   ⇒   Γ ⊢CPC φ.
```

This gives an `Interpretation` whose formula translation is the identity
and whose proof translation is supplied by a Lean-checked induction. The
experiment also instantiates composition by composing this interpretation
with the classical system's identity interpretation.

## Negative result: the reverse identity translation is impossible

There is no `Interpretation CPC IPC` whose formula map fixes **every**
formula. Otherwise the CPC excluded-middle derivation with empty premises
would translate into an IPC derivation of excluded middle.

Experiment 003 has already proved such an IPC derivation cannot exist,
using a persistent two-world Kripke countermodel and soundness of the
explicit intuitionistic deduction rules. This makes the obstruction a
mathematical theorem, **not merely a failed automated search**.

The restriction to **identity on formulas** is essential. This theorem
does **not** rule out all interpretations of classical logic into
intuitionistic logic. Negative translations of classical logic, for
example, are established mathematics.

## What is established, and what is not

The formal proof checks establish a small, compositional interpretation
interface and one strictness result for a common-language pair of
logical systems. They do not establish:

- an interpretation between ZF and dependent type theory;
- any semantic or constructive preservation theorem across different
  object languages;
- an impossibility theorem for arbitrary nonidentity translations;
- a new logical theorem or a new axiomatic foundation;
- a demonstrated performance or expressivity advantage over existing
  Isabelle/Lean theory-interpretation facilities.

The interface currently treats any proof-preserving formula map as a
possible interpretation; its translation need not automatically preserve
connectives or other syntax. A later experiment should add compositional
syntax translation and semantic compatibility obligations.

## Acceptance and falsification

This milestone passes only when the Lean kernel checks:

1. Interpretation identity and composition;
2. All source proof rules transported into the classical calculus;
3. The positive interpretation and its composition;
4. The reverse identity obstruction derived from the previously
   verified two-world countermodel.

**Next mathematical gate:** compare this abstraction with established
translations of first-order theories, locales, institution-like
satisfaction-preserving morphisms, and existing logical framework
libraries. Then construct a *nonidentity* formula translation between
different languages and prove explicit preservation of semantics.

The project should pivot if it only reimplements existing interfaces
without enabling a distinct theorem, analysis, or verified capability.
