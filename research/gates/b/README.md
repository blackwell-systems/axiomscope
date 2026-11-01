# Gate B — choice-sensitive infinity (partial benchmark)

## Research objective

We want to compare the *same* set-theoretic distinction:

[
\text{infinite}(A) \Longrightarrow \text{Dedekind-infinite}(A)
]

across independently specified foundations. The relevant definition of ordinary
finite is `Finite(A) ≡ ∃n∈ω. A≈n`. A Dedekind-infinite witness may be stated
as an injection `ω ↪ A`, or equivalently an injective nonsurjective self-map;
the equivalence has **not** yet been proved in this Gate B theory.

## Machine-checked Isabelle/ZF results

[GateB_ZF.thy](GateB_ZF.thy) is a new Isabelle/ZF theory, not
Isabelle/HOL and not Mathlib's `Infinite α`. It contains:

1. `countable_injection_implies_infinite`: `nat ≲ A ⟹ ¬Finite(A)`,
   without a choice assumption.
2. `wellorderable_infinite_has_nat_injection`:
   `¬Finite(A) ∧ (∃a. Ord(a) ∧ A≈a) ⟹ nat ≲ A`.

The second theorem assumes an explicit witness that A is equipotent to an
ordinal. This is **stronger than** the countable-choice assumption we'd
ultimately like to isolate. We do not label it a proof from `ACω`.

The new [Isabelle CI workflow](../../../.github/workflows/gate-b-isabelle.yml)
checks these theorems in the first-order ZF object logic. It also checks the
[typed claim manifest](manifest.json) and its deterministic
[comparison report](comparison.json).

## Published, but not kernel-checked here

The countable choice principle `ACω` suffices to show every infinite set
contains an injection of `ω`. The Open Logic Project, *Set Theory*,
Theorem 9.9 provides a textbook proof:
https://builds.openlogicproject.org/content/set-theory/set-theory.pdf

Cohen's first symmetric model contains an infinite Dedekind-finite set of
reals, showing why the converse is not a theorem of ZF alone (relative to
the consistency assumptions of the symmetric-model construction).
A modern peer-reviewed account is in the *Journal of Symbolic Logic*,
Section 3.1 of *Does DC imply ACω uniformly?*:
https://www.cambridge.org/core/journals/journal-of-symbolic-logic/article/does-mathsf-dc-imply-mathsf-acomega-uniformly/05069A84199B3477B3BEA2E58EF21AF6

**These are external literature claims, not declarations in
`GateB_ZF.thy`.** A cited paper is not proof-assistant verification.

## Exact outstanding gaps

- No Isabelle/ZF proof of the countable-choice (`ACω`) converse.
- No kernel-checked first Cohen symmetric model within this project.
- No kernel-checked bridge from `nat ≲ A` to a proper self-embedding here.
- No machine-checked *negative* independence result in this repository.
- No demonstrated novel mathematical discovery.

The evidence compiler must reject any attempt to change the paper-backed
claims to `formal_isabelle_kernel` or to substitute a well-order witness
for countable choice.

**Status: Gate B remains open.** Passing its initial Isabelle proof checks is
substantive progress toward faithful comparative foundations, but not
completion of the original independence benchmark.
