# AXIOMSCOPE research roadmap

## Phase 0 — a reproducible proof project

- [x] Document the project scope and nonclaims.
- [x] Add pinned Lean and Mathlib configuration.
- [x] Draft the three elementary infinity proofs.
- [x] Add a GitHub Actions build check.
- [x] **Obtain a green Lean build**, including all three theorems.
- [x] Record actual `#print axioms` output in the proof ledger.
- [ ] Require zero `sorry` and zero user-defined axioms.

## Phase 1 — proof metadata and traceability

- [x] Model baseline theorem records (statement, representation, axiom dependencies, and construction provenance); proof-checking is a CI gate.
- [x] Generate JSON and Markdown axiom-dependency reports from successful Lean output; fail CI on drift.
- [ ] Extend the report to a transitive theorem/definition dependency graph (currently axioms only).
- [ ] Compare “reuses a library equivalence” against “provides a direct implementation”.
- [ ] Test whether the result meaningfully improves existing Lean functionality.

## Phase 2 — explicit changes of foundation

- [x] Choose a controlled comparison: excluded middle under decidability and unrestricted classical reasoning.
- [x] Specify the different logical statements, context assumptions, and the scope of proof-level comparison.
- [x] Implement Experiment 001 and check proof-profile comparisons against audited machine-readable records in CI.
- [x] Experiment 002: prove soundness and nonderivability of excluded middle for an explicit intuitionistic propositional calculus using a two-world Kripke model.
- [x] Experiment 003: generalize Kripke soundness and nonderivability to arbitrary atoms and preordered worlds.
- [ ] Explore semantic completeness for the explicit calculus or a rigorously characterized fragment.
- [ ] Document related systems (CZF, ETCS, type theory, proof assistants) and avoid duplicate novelty claims.

## Phase 2b — reconstructing standard mathematics

- [x] Experiment 004: declare an independent natural-number inductive type and derive recursion, induction, arithmetic, and equivalence to Lean `Nat`.
- [ ] Distinguish proof dependencies from the underlying Lean inductive-type rules in a cross-foundation comparison.
- [x] Experiment 005: characterize natural numbers using an arbitrary carrier with full predicate induction, and prove equivalence and arithmetic preservation.
- [x] Give a weak-axiom structure that satisfies successor disjointness/injectivity but fails induction.
- [x] Experiment 006: define first-order arithmetic formula syntax and semantic induction schema, and prove full induction validates all its instances.
- [x] Give an explicit first-order induction instance refuted by a weak two-track signature.
- [ ] Construct syntactic induction axiom formulas with capture-avoiding substitution and prove their semantics agrees with the schema.
- [ ] Compare **first-order** PA with full predicate induction through independently modeled nonstandard models or interpretation results, without claiming first-order categoricity.
- [ ] Interpret natural-number arithmetic in a separate set-theoretic theory and compare assumptions.

## Phase 2c — comparative foundations

- [x] Experiment 007 pilot: contrast explicit finite-avoidance selection with ambient infinity, with machine-audited proofs.
- [x] Exhibit Dedekind self-embedding witnesses for Nat and types equipped with explicit equivalences to Nat.
- [ ] Model independent weak set theories, including a precise choice principle.
- [ ] Establish a genuine nonimplication with an independently justified model, not simply a failed proof or reliance on `Classical.choice`.
- [ ] Extend proof reports with semantic assumption profiles and witness provenance.

## Gate A / Gate B research decisions

- [x] Compare actual Isabelle/ZF and AFP ZFfin/HF foundations, with pinned source hashes, model interpretation evidence, and independent Isabelle2026 builds.
- [x] State countable Choice as a ZF object-level proposition, not as ambient Lean/HOL choice.
- [x] Verify that a nonfinite set admits injections from every finite ordinal with no Choice.
- [x] Under `ACω`, select the finite injections, prove their union infinite, encode it in `nat`, and verify `nat ≲ A` in Isabelle/ZF.
- [x] Prove the equivalence between `nat ≲ A` and an injective nonsurjective endomap in the Isabelle/ZF object language, without Choice.
- [ ] Build or import a genuine machine-checked symmetric model with an infinite Dedekind-finite set, or leave the negative result clearly labeled as published-only.
- [ ] Demonstrate a distinctive research/tooling capability beyond Isabelle/AFP's existing libraries, or decide to pivot the project.

## Foundations v0.2 — test the architecture, not another known theorem

- [x] Define a restricted context / proof-witness / goal semantics without new axioms.
- [x] Build a conservative scenario engine over already verified Isabelle/ZF proof contracts.
- [x] Demonstrate alternative routes via countable Choice and local well-orderability.
- [x] Fail closed on unknown assumptions, cross-logic claims, or published-only evidence.
- [x] Keep machine-generated counterfactual results and explicit regression tests under CI.
- [x] Extract the explicit quoted premise list and conclusion from registered Isabelle/ZF theorem source declarations (restricted grammar).
- [x] Cross-check source-extracted theorem signatures against Isabelle's elaborated theorem objects; consume a prover-produced session export in the scenario experiment.
- [ ] Extract immediate or transitive theorem and axiom dependencies from prover proof-body/theory exports (beyond statement-premise correspondence).
- [ ] Compare what the prototype adds beyond Isabelle locales, theory interpretations, Lean's axiom audit, AFP, and existing dependency tooling.
- [ ] Prove a useful interpretation / transport correctness theorem across *explicitly linked* foundations.
- [ ] Demonstrate measurable benefit or pivot; do not claim novelty from proof collection.

## Experiment 008 — interpretations between two deductive systems

- [ ] Verify a general proof-preserving interpretation interface and its composition law in Lean.
- [ ] Define an explicit classical extension of the existing intuitionistic propositional calculus and transport every deduction rule.
- [ ] Establish a model-backed obstruction to the reverse **identity-on-formulas** interpretation using Experiment 003's Kripke countermodel.
- [ ] Audit the resulting theorems' axiomatic dependencies; record evidence and nonclaims.
- [ ] Benchmark this pilot against existing theory-interpretation machinery before broadening to different object languages.
- [ ] Extend to a nonidentity formula translation with explicit connective and semantic preservation obligations.

## Experiment 009 — nonidentity syntax translation and semantic preservation

- [x] Introduce an independently defined richer target object-language and natural deduction calculus.
- [x] Verify derivation transport through a nonidentity formula translation, including open contexts.
- [x] Prove preservation and reflection of Kripke forcing for all models/worlds, plus context satisfaction.
- [x] Exhibit a target syntax constructor outside the literal translation image without overstating semantic expressivity.
- [x] Audit all new theorems through Lean's generated proof ledger and regression tests.
- [ ] Compare semantic interpretation certificates with native Lean/Isabelle and established theory-morphism frameworks before claiming novelty.

## Experiment 010 — composable semantic interpretation certificates

- [ ] Define a reusable certificate requiring proof transport and satisfaction equivalence over a shared index.
- [ ] Verify identity, composition, and context satisfaction preservation from the general certificate.
- [ ] Prove that a concrete semantic mismatch rules out a certificate for that formula map.
- [ ] Instantiate the certificate with Experiment 009's nonidentity Kripke translation, including composed proof and semantic preservation.
- [ ] Register and audit the new theorems and preserve all existing Lean/Gate A checks.
- [ ] Extend to explicit mappings between distinct classes of models; benchmark against existing institution/logical framework translations.

## Phase 3 — mathematical research

- [ ] Identify a precise conjecture or technical limitation of existing frameworks.
- [ ] State what falsifies the proposed advantage.
- [ ] Produce a new theorem, usable tool, or rigorous impossibility result.
- [ ] Only then consider a new axiomatic system.

### Immediate acceptance criterion

CI passes all proof files; the proof ledger accurately reports actual axiomatic dependencies; README distinguishes verified results from unverified aspirations.
