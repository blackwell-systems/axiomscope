# Experiment 009 — nonidentity translation into a richer logical language

## Research question

Can AxiomScope translate between **different formula types**, preserve
derivations under translated assumptions, and verify that the interpretation
preserves and reflects semantic truth in every Kripke world?

Experiment 008 used one common formula language and an identity map.
Experiment 009 tests the next feature: a nonidentity translation into a
distinct, richer syntax.

## Two calculi

The source is Experiment 003's intuitionistic propositional calculus
containing atoms, falsity, disjunction, and implication.

The target is a separately defined inductive language containing atoms,
**truth, falsity, conjunction, disjunction, and implication**. Its
deduction rules add conjunction introduction/elimination and truth
introduction to the familiar intuitionistic rules.

For the interpretation `t`:

```text
t(atom a)    = and(atom a, top)
t(bottom)    = bottom
t(or p q)    = or(t(p), t(q))
t(imp p q)   = imp(t(p), t(q))
```

Mapping `atom a` to `atom a ∧ ⊤` is intentional: this is *not* the
identity on terms, even if the languages share names for connectives.

It is, however, a **conservative encoding**. It does not amount to an
independently chosen set-theoretic or type-theoretic foundation.

## Proof translation

The Lean theorem `translate_derivation` is proved by induction over the
*actual source derivation tree*. Every source inference rule has a
corresponding target derivation, with assumptions carried through their
set-image translation:

```text
Γ ⊢source φ  ==>  t[Γ] ⊢target t(φ)
```

The theorem is installed as an instance of the reusable `Interpretation`
interface from Experiment 008. It can compose with other formally verified
interpretations, illustrated here by composing with the target identity.

## Semantic preservation (both directions)

Both source and target formulas are interpreted over the **same arbitrary
persistent Kripke model**. Source forcing is from Experiment 003; the
target is equipped with a new forcing function for conjunction and truth.

We prove by structural induction on every source formula that:

```text
targetForces(M, w, t(φ))  <->  sourceForces(M, w, φ)
```

for *every* Kripke world `w` and every persistent model `M`. In the
atomic case the added conjunction with truth is semantically neutral.

We separately establish equivalence for contexts:

```text
(∀ ψ ∈ t[Γ], targetForces(M,w,ψ))
    <-> (∀ φ ∈ Γ, sourceForces(M,w,φ))
```

Thus the test is stronger than a proof-preserving formula map alone.
It checks the meaning of translated statements and hypotheses.

## A verified boundary

The target contains `top` as a primitive formula, while no translated
source formula is exactly the primitive `top` term. Consequently, our
translation is not surjective on target **syntax**.

This is a syntactic distinction, **not** a proof that the target logic
expresses more semantic content. The target `top` is logically
equivalent to translated source tautologies such as `bottom → bottom`.

## Acceptance criteria

- Lean checks the proof translation, its interpretation instance, and
  the composition use.
- Lean checks the semantic equivalence at **all worlds**, not only the
  two-world example.
- Lean checks context semantic preservation and the syntax counterexample.
- The five new declarations are included in the generated axiom ledger,
  with no unapproved axioms or `sorryAx`.
- Existing Lean and Gate A workflows pass.

## Research status and next gate

All mathematical results here are established metatheory. AxiomScope is
using them to **test the architecture**, not claiming originality.

The next meaningful advance is to make semantic preservation a required
or separately composable interpretation certificate, then test a translation
that meaningfully changes logical connectives or representation (e.g. a
negative translation). Before presenting such functionality as new, we
must compare against existing logics, institution morphisms,
interpretations, and mechanized logical-relations libraries.

**Not established:** a new logic, a cross-kernel proof translation, a
semantic interpretation between ZF and type theory, general equivalence
of distinct foundational theories, or any independence theorem.
