# Foundations v0.1 — research specification

**Status:** experimental proposal. This describes a *program of work*, not a new axiomatic system.

## 1. Goal

Build a system for expressing and checking mathematical statements together with explicit foundational assumptions, constructive content when available, and comparisons across frameworks.

The measurable initial question is:

> Can we report what a theorem proves, which principles its proof requires, and what changes when we work in a different foundational environment?

Lean already offers axiom auditing. Thus merely displaying an axiom list is **not** new. Any novelty claim must identify functionality beyond the current tools and literature.

## 2. Chosen host foundation

The v0.1 implementation is hosted in Lean 4 / Mathlib. The primitive notion of a **type** and the universe hierarchy `Type u` belong to Lean's existing logic; sets in Mathlib can be predicates `α → Prop`. They are **not** unqualified ZFC sets.

We do not equate Lean's type universes with actual ZFC universes, nor claim that Lean's kernel has exactly ZFC's axioms.

**Proof correctness** is relative to the trusted kernel, the imported definitions, and each theorem's actual axiom dependencies.

## 3. Scope of the first experiment

### Objects

- Naturals: `ℕ`
- Integers: `ℤ`
- Even naturals: the subtype `{n : ℕ // Even n}`
- Subsets of naturals: `Set ℕ`, predicates on naturals

### Relations

- **Same cardinality:** witnessed by an equivalence `α ≃ β`, which explicitly contains forward and inverse functions and the inverse laws.
- **Different cardinality:** a lack of bijection; the diagonal argument establishes a stronger no-surjection fact for `ℕ → Set ℕ`.
- **Density:** a different invariant; it is *not* a substitute for cardinality. Formalizing density is out of scope for v0.1.

### Existence / construction

Record whether the proof exhibits an explicit function and inverse or relies on a general existence principle. “Constructive” is a property to substantiate by a proof and its axiom dependencies, not a decorative label.

### Axioms

Do not introduce new axioms in v0.1. Use Lean's `#print axioms` mechanism to inspect trusted assumptions. Importing Mathlib by itself does not prove that every declaration uses classical choice.

### Universe boundaries

Set-theoretic paradoxes are avoided by working inside Lean's existing typed universe structure. We are *using* this design, not claiming to have invented it.

## 4. Required verification

For each theorem:

1. Lean compiles without `sorry`, `admit`, or added axioms.
2. The statement specifies precisely which type/set is involved.
3. The documentation distinguishes a bijection from asymptotic density.
4. The `#print axioms` report is inspected, recorded, and not misrepresented.
5. Reproducibility uses pinned Lean and Mathlib versions.

## 5. Research questions for a genuinely new system

- Can a proof artifact record assumptions in a structured, machine-verifiable form that transports across foundational frameworks?
- Can we show which results survive changes of constructive/classical principles or universe assumptions?
- Can translations among set-theoretic, type-theoretic, and categorical presentations preserve both propositions and auditable proofs?
- What advantage does the framework deliver beyond existing tools such as Lean's axiom audit?

## 6. Nonclaims

AXIOMSCOPE v0.1 **does not**:
- replace ZFC;
- resolve CH or another independent proposition;
- introduce a new infinity or cardinal;
- prove its own consistency;
- claim cardinality, measure, density, or model pluralism are new ideas.

A future distinct theory would require explicit syntax, formation rules, inference rules, axioms, semantics, and metatheoretic results.
