# Experiment 005 — Peano axioms, characterization, and the role of induction

## Research question

If we specify the natural numbers by properties rather than constructing
another inductive datatype, can we recover the same mathematical structure?
Which assumption prevents unintended extra elements?

## Three levels of structure

1. `WeakSuccessor α` assumes a zero, a successor, zero not in the
   successor's image, and an injective successor.
2. `PeanoSystem α` adds **full induction for every predicate**
   `P : α → Prop`.
3. `ArithmeticSystem α` adds arbitrary operations `add` and `mul`,
   constrained by the usual equations for recursion on the second argument.

**Do not confuse this with first-order PA.** Quantifying over all Lean
predicates is a stronger, higher-order induction principle than first-order
PA's schema ranging only over formulas in a first-order signature. The
categoricity result proved here therefore does **not** imply first-order
Peano arithmetic is categorical.

## Formal results

Using Experiment 004's inductively built `Number`, define a canonical
map `encode M : Number → α` for any `PeanoSystem α`:

- `encode zero = M.zero`.
- `encode (succ n) = M.succ (encode n)`.
- `encode_unique`: any map satisfying these equations is identical.
- `encode_injective`: injection follows from constructor disjointness
  and successor injectivity.
- `encode_surjective`: full induction proves *every* element of the
  carrier lies in the image.
- `encode_bijective`: the forward map is bijective without `Classical.choice`.
- `equivalence`: packaging that bijection as a noncomputable `Equiv` object
  uses Lean's `Classical.choice` for an inverse.
- `encode_add` and `encode_mul`: with arithmetic equations, the
  canonical map also preserves addition and multiplication.

The `standard` arithmetic structure is an explicit model using Experiment
004's `Number`, providing relative satisfiability inside Lean.

## Why induction matters

Consider the carrier `Number × Bool`, with:

- zero = `(zero, false)`
- successor = `(succ n, b)`: it increments the number but preserves the
  Boolean label.

Successor is injective and zero is not a successor. But the `true`
track is unreachable from zero, even after arbitrarily many successors.
The predicate `b = false` holds at zero and persists under successor,
yet fails on the `true` track. Thus full induction fails.

This is a concrete model showing the **weak** axioms are insufficient.
It does not show that every first-order PA model looks like two tracks,
or establish independence of an arbitrary formal axiom schema.

## Foundation accounting

The generated report confirms that all eight structural and countermodel
results use no additional Lean axioms, while the explicit `equivalence`
declaration uses `Classical.choice`. This is a **choice dependency of the
inverse-producing proof**, not a requirement for the bijectivity theorem.

The structural assumptions are *fields* of an explicit Lean structure;
they do not appear as global Lean kernel axioms. Consequently a theorem
may report no additional Lean axioms while still requiring the substantial
`M.induction` field or other hypotheses. The generated ledger tracks
kernel axioms, while this document records assumption provenance.
The construction of `Number` still uses Lean's inductive-type rules.

Future work: define the *syntax* and *semantics* of a first-order
arithmetic theory, show soundness, and distinguish a formula induction
schema from unrestricted predicate induction; eventually compare with
set-theoretic natural numbers.

[Formal Lean source](../../Axiomscope/Experiments/PeanoAxioms.lean)
· [Generated proof record](../../proofs/experiments/005-peano-axioms.json)
