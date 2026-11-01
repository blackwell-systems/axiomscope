# Experiment 010 — composable semantic interpretation certificates

## Mathematical target

Experiments 008–009 verified **proof preservation** and **semantic
preservation**, but used separate theorems. Experiment 010 puts both
obligations in a reusable type whose values cannot be built without
providing proof terms for both claims.

The [general interface](../../Axiomscope/SemanticInterpretations.lean) is
parameterized by two deductive systems, two satisfaction predicates, and
one **shared world/index type**.

An interpretation certificate consists of:

- A verified proof translation `logic : Interpretation A B`.
- A meaning-preservation theorem, for every index `w` and source formula
  `φ`:
  
  ```text
  targetSatisfies w (logic.onFormula φ)
      ↔ sourceSatisfies w φ
  ```

Because the equivalence is *two-way*, the interface captures preservation
and reflection of truth for these particular satisfaction predicates.

## General compositional result

For certificates `A → B` and `B → C` sharing an intermediate
satisfaction predicate and a world/index type, the existing
`Interpretation.compose` carries proofs across both steps. The
equivalences also compose:

```text
C[w, J(I(φ))]  ↔  B[w, I(φ)]  ↔  A[w, φ]
```

The composite therefore preserves the original derivation and its meaning.

Identity has a canonical certificate. A generic context theorem
establishes:

```text
(∀ ψ ∈ I[Γ], targetSatisfies w ψ)
  ↔ (∀ φ ∈ Γ, sourceSatisfies w φ)
```

for **arbitrary sets of assumptions**, without assuming the formula
translation is injective.

## A justified obstruction

The generic `no_certificate_of_mismatch` theorem says that if a source
formula is true at some index but its proposed translation is demonstrably
false at the same index, no certificate with that formula map exists.

This is evidence of *actual disagreement in a specified semantics*.
**Failure to construct a certificate is not a proof of impossibility.**

## Concrete proof: Experiment 009 revisited

[Experiment010.lean](../../Axiomscope/Experiments/Experiment010.lean)
constructs `certifiedEmbedding`, packaging:

- Experiment 009's nonidentity translation `atom a ↦ atom a ∧ ⊤`;
- Its previously verified transport of intuitionistic derivations into
  the expanded target calculus;
- Its Kripke forcing equivalence at every world of any fixed persistent
  source model.

We then verify:

1. Derivation transport through the packaged certificate.
2. Context satisfaction equivalence via the **generic** theorem.
3. Semantic preservation through a **composed** certificate.
4. Derivation transport through the same composition.

Unlike Experiment 009, these operations consume the *certificate* rather
than independently invoking manually paired proof and semantic theorems.

## Scope and scientific limits

This is a useful formal API experiment, **not a mathematical novelty claim**.

- Both satisfaction predicates share the same index type. In the example
  this is a world from one fixed Kripke model.
- There is **no map of models** between arbitrary model categories; thus
  this is not yet a general institution morphism or cross-foundation
  interpretation.
- The notion of semantic equivalence is relative to the supplied
  satisfaction predicates. It does not imply full abstraction, adequacy
  for all models, or proof reflection.
- The original source/target syntax, logical systems, and existing
  proof checker still come from one Lean kernel.
- No new independence theorem, axiomatic foundation, or theorem transport
  across Isabelle and Lean has been established.

## Acceptance criteria

- Lean kernel checks the general certificate, identity, composition,
  context theorem, and mismatch obstruction.
- Lean checks all concrete Kripke instantiations.
- Experiment 010 theorems are included in the generated proof ledger,
  with observed Lean axioms, explicit profiles, and regression tests.
- Existing Gate A and Lean CI succeed.

## Next falsifiable gate

Add an explicit mapping between **different classes of models/worlds**,
not merely two syntax types interpreted in one model. Prove a satisfaction
condition under that map, distinguish preservation from reflection, and
test against an established logical-framework or institution-morphism
baseline. If the work simply reimplements existing libraries, the next
step is to identify a genuinely useful comparison or pivot.
