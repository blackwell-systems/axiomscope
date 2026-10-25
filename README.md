# AXIOMSCOPE

**Proofs carry their assumptions.**

AXIOMSCOPE is an experimental project in foundations of mathematics. Its first goal is not to replace ZFC or introduce unsupported new axioms: it is to make the objects, proof principles, constructions, and limitations behind familiar theorems explicit and mechanically checkable.

The initial work uses **Lean 4 and Mathlib**, which provide an established logical foundation and a small trusted kernel. AxiomScope v0.1 is a research *scaffold*, not yet a distinct axiomatic system.

## First experiment: three facts about infinity

| Result | Formal artifact | Interpretation |
| --- | --- | --- |
| The natural numbers correspond bijectively to the even natural numbers | `Axiomscope.natEquivEven` | Cardinality need not measure natural density |
| The natural numbers correspond bijectively to the integers | `Axiomscope.natEquivInt` | Adding infinitely many negative integers need not increase cardinality |
| No function from the naturals onto their power set is surjective | `Axiomscope.cantorDiagonal` | The power set is strictly larger in the relevant cardinal sense |

The even-number bijection is written out explicitly. The integer bijection initially reuses Mathlib's constructive equivalence `Equiv.intEquivNat`; rewriting it from scratch is a later educational exercise. Cantor's diagonal argument is written out directly.

## Experiment 001 — changing logical assumptions

Four Lean proofs examine the difference between constructively provable double-negated excluded middle, excluded middle with an explicit decision procedure, and unrestricted classical excluded middle and double-negation elimination. The experiment generates a [comparison record](proofs/experiments/001-excluded-middle.json) from proof-checked axiom output. See [the experiment explanation](docs/experiments/001-excluded-middle.md).

**Scope:** This compares specific Lean proofs and their assumptions, not different ZFC models; it does not establish an independence theorem. Lean's `Classical.choice` is not synonymous with the set-theoretic Axiom of Choice.

## Experiment 002 — a genuine nonderivability proof

A two-world Kripke model shows that `atom ∨ ¬atom` is not forced at the root, even though the atom becomes true at a later accessible world. We define a small intuitionistic natural-deduction calculus for implication, disjunction, and falsity, prove **every derivation is sound in this semantics**, and conclude that this excluded-middle instance is **not derivable in that calculus**.

This is stronger than Experiment 001's proof-dependency inspection. It is a mathematically checked nonderivability theorem **for the explicitly defined calculus**, not a claim of novelty or a result about ZFC independence.

Read the [formal explanation](docs/experiments/002-kripke-countermodel.md), [Lean code](Axiomscope/Experiments/KripkeCountermodel.lean), and [machine-readable comparison](proofs/experiments/002-kripke-countermodel.json).

## Experiment 003 — generalized Kripke models

We now formalize arbitrary atomic propositions and preordered worlds with persistent forcing. The [general soundness and nonderivability criterion](Axiomscope/Experiments/GeneralKripke.lean) uses **no additional Lean axioms**. The present concrete two-world specialization uses `propext`, `Quot.sound`, and `Classical.choice` in its proof and is labeled accordingly. This is a proof-level dependency, not a requirement of the general countermodel theorem.

See the [experiment write-up](docs/experiments/003-general-kripke.md) and [audited comparison](proofs/experiments/003-general-kripke.json).

## Experiment 004 — rebuilding the natural numbers

We declare a **fresh inductive number type** with zero and successor, independent of the *definition* of Lean's `Nat`. From its constructors we recover an induction rule and a recursion principle with uniqueness, and recursively define addition and multiplication. Explicit functions in both directions establish `Experiment004.Number ≃ Nat`. We prove the operations agree with ordinary arithmetic and recover familiar laws.

**Foundational boundary:** this uses Lean's existing inductive-type rules. It does **not** derive infinity from our propositional Kripke calculus, and transporting arithmetic laws from built-in `Nat` is not an independent proof of arithmetic's foundations. The experiment's contribution is auditable construction provenance and compatibility.

See [the Lean module](Axiomscope/Experiments/NaturalNumbers.lean), [experiment explanation](docs/experiments/004-natural-numbers.md), and [axiom report](proofs/experiments/004-natural-numbers.json).

## Experiment 005 — axiomatic Peano systems

Rather than introducing another inductive datatype, we specify **zero, successor, addition, multiplication, and explicit laws** over an arbitrary carrier. Our `PeanoSystem` includes induction over **every** Lean predicate—not merely the first-order induction schema. The [Lean formalization](Axiomscope/Experiments/PeanoAxioms.lean) proves a canonical map from our Experiment 004 numbers is injective and surjective, and preserves the arithmetic operations. It also exhibits a two-track zero/successor structure satisfying disjointness and injectivity but **failing induction**, showing why the induction assumption matters.

**Scope:** The categorical conclusion here depends on full higher-order induction. It is not a proof of categoricity for first-order Peano arithmetic, which admits nonstandard models. This also does not derive the existence of a model from pure logic: we construct a model inside Lean's inductive type theory.

See the [research explanation](docs/experiments/005-peano-axioms.md) and [generated report](proofs/experiments/005-peano-axioms.json).

## Experiment 006 — first-order syntax and induction schema

We now define a **first-order arithmetic language** as explicit term and formula syntax, including equality, addition, multiplication, connectives, and quantified individual variables. The [formal semantics](Axiomscope/Experiments/FirstOrderArithmetic.lean) interpret formulas in an arbitrary arithmetic signature. Crucially, the induction schema ranges over **syntax-definable formulas**, not over arbitrary predicates of the carrier.

We prove that Experiment 005's *full predicate induction* validates every semantic first-order induction instance. A two-track model fails one explicit formula instance, showing the schema imposes genuine constraints beyond an arbitrary zero/successor signature. This is **not** a nonstandard model of PA or proof that first-order PA lacks categoricity.

See [Experiment 006's scope and formalization](docs/experiments/006-first-order-induction.md).

## Build

Install [Lean 4 through elan](https://lean-lang.org/install/manual/), then run:

```sh
lake exe cache get
lake build
lake env lean Axiomscope/CardinalExamples.lean
lake env lean Axiomscope/Experiments/ExcludedMiddle.lean
lake env lean Axiomscope/Experiments/KripkeCountermodel.lean
lake env lean Axiomscope/Experiments/GeneralKripke.lean
lake env lean Axiomscope/Experiments/NaturalNumbers.lean
lake env lean Axiomscope/Experiments/PeanoAxioms.lean
lake env lean Axiomscope/Experiments/FirstOrderArithmetic.lean
python3 -m unittest discover -s scripts/tests -v
python3 scripts/generate_proof_ledger.py --check
```

The `lean-toolchain`, Mathlib dependency, and committed `lake-manifest.json` are pinned to **v4.35.0** and its exact dependency revisions. Run `lake update` only when intentionally updating and recommitting the lockfile. **All three initial formal results have passed Lean compilation and axiom inspection** in the [successful CI run](https://github.com/blackwell-systems/axiomscope/actions/runs/40219540458). See the [proof ledger](docs/PROOF-LEDGER.md) for the observed axiom dependencies.

The proof ledger is **generated**, not manually maintained. After editing proofs, run `python3 scripts/generate_proof_ledger.py --write` and commit both `proofs/dependencies.json` and `docs/PROOF-LEDGER.md`. CI recomputes their axiom lists from Lean and rejects drift or unapproved axioms. Only the mathematical descriptions and construction provenance in `proofs/catalog.json` are manually curated. This is an *axiom-dependency* report, not yet a complete transitive lemma-dependency graph.

## Working principles

1. **Precision first.** State the underlying universe, type, equivalence relation, and proof obligations.
2. **Construction provenance.** Distinguish a witness-producing proof from existence inferred by other principles.
3. **Explicit dependency accounting.** Audit which axioms a theorem actually uses; do not confuse library imports with proof dependencies.
4. **No conflation of sizes.** Cardinality, density, measure, and order type answer different questions.
5. **Independent results stay independent.** Changing foundations does not automatically resolve ZFC-independent propositions.
6. **Compatibility before novelty.** Document what Mathlib, ZFC, ETCS, constructive set theory, and type theory already provide before claiming any new result.

## Documents

- [Foundations v0.1 specification](docs/FOUNDATIONS-v0.1.md)
- [Generated proof ledger](docs/PROOF-LEDGER.md)
- [Machine-readable axiom dependencies](proofs/dependencies.json)
- [Experiment 001 comparison](proofs/experiments/001-excluded-middle.json)
- [Experiment 002: Kripke countermodel and soundness](docs/experiments/002-kripke-countermodel.md)
- [Experiment 003: generalized Kripke models](docs/experiments/003-general-kripke.md)
- [Experiment 004: natural numbers reconstruction](docs/experiments/004-natural-numbers.md)
- [Experiment 005: axiomatic Peano systems](docs/experiments/005-peano-axioms.md)
- [Experiment 006: first-order arithmetic induction schema](docs/experiments/006-first-order-induction.md)
- [Declaration metadata catalogue](proofs/catalog.json)
- [Research roadmap](docs/ROADMAP.md)

## Status

**Experimental / v0.1.** The three baseline infinity results are machine-verified, with observed axiom dependencies documented. The proposed foundational framework itself is not established as a new mathematical theory; no new independence theorem is claimed.
