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

## Phase 3 — mathematical research

- [ ] Identify a precise conjecture or technical limitation of existing frameworks.
- [ ] State what falsifies the proposed advantage.
- [ ] Produce a new theorem, usable tool, or rigorous impossibility result.
- [ ] Only then consider a new axiomatic system.

### Immediate acceptance criterion

CI passes all proof files; the proof ledger accurately reports actual axiomatic dependencies; README distinguishes verified results from unverified aspirations.
