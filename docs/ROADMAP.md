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

- [ ] Model a theorem record (statement, representation, assumptions, construction status, proof-checking result, dependencies).
- [ ] Derive machine-readable dependency reports rather than copying them by hand.
- [ ] Compare “reuses a library equivalence” against “provides a direct implementation”.
- [ ] Test whether the result meaningfully improves existing Lean functionality.

## Phase 2 — explicit changes of foundation

- [ ] Choose *one* controlled comparison: constructive vs classical existence, or two presentations of sets.
- [ ] Formulate exactly what is transported and which definitions change.
- [ ] Implement and verify a nontrivial example where assumption provenance matters.
- [ ] Document related systems (CZF, ETCS, type theory, proof assistants) and avoid duplicate novelty claims.

## Phase 3 — mathematical research

- [ ] Identify a precise conjecture or technical limitation of existing frameworks.
- [ ] State what falsifies the proposed advantage.
- [ ] Produce a new theorem, usable tool, or rigorous impossibility result.
- [ ] Only then consider a new axiomatic system.

### Immediate acceptance criterion

CI passes all proof files; the proof ledger accurately reports actual axiomatic dependencies; README distinguishes verified results from unverified aspirations.
