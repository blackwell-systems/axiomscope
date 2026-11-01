# Gate B — choice-sensitive infinity (partial benchmark)

## Research objective

We want to compare the *same* set-theoretic distinction:

**Infinite(A) ⇒ DedekindInfinite(A)**

across independently specified foundations. The relevant definition of ordinary
finite is `Finite(A) ≡ ∃n∈ω. A≈n`. A Dedekind-infinite witness may be stated
as an injection `ω ↪ A`, or equivalently an injective nonsurjective self-map.
**Both directions are now verified by Isabelle/ZF without Choice.**

## Machine-checked Isabelle/ZF results

[GateB_ZF.thy](GateB_ZF.thy) is a new Isabelle/ZF theory, not
Isabelle/HOL and not Mathlib's `Infinite α`. It contains:

1. `countable_injection_implies_infinite`: `nat ≲ A ⟹ ¬Finite(A)`,
   without a choice assumption.
2. `wellorderable_infinite_has_nat_injection`:
   `¬Finite(A) ∧ (∃a. Ord(a) ∧ A≈a) ⟹ nat ≲ A`.

The second theorem is a restricted, well-orderability-based benchmark.
Its assumption is **stronger than** countable choice; the complete
`ACω` theorem is proved separately below.

The new [Isabelle CI workflow](../../../.github/workflows/gate-b-isabelle.yml)
checks these theorems in the first-order ZF object logic. It also checks the
[typed claim manifest](manifest.json) and its deterministic
[comparison report](comparison.json).

## Explicit countable choice and the finite-witness theorem

[GateB_CountableChoice.thy](GateB_CountableChoice.thy) introduces
`countable_choice` **as a proposition in the ZF object logic**: every
natural-number-indexed family of nonempty sets has a choice function.
This is a conditional assumption, **not** a new global Isabelle axiom.

The formal development proves that any infinite set has injections
`n → A` for each individual finite ordinal `n` without Choice.
Assuming `countable_choice`, it then selects a single family of such
finite injections indexed by every natural number.

The subsequent enumeration and converse theories combine these finite
injections into the full countable-choice theorem. This intermediate
lemma remains useful because its assumptions are strictly explicit.

## Verified infinite union of selected finite injections

[GateB_Assemble.thy](GateB_Assemble.thy) proves that if one injection
`f_n : n ↪ A` is supplied for each finite ordinal `n`, the union
`⋃ₙ range(f_n)` is infinite. Otherwise, if the union were equipotent
to a finite ordinal `m`, the selected `f_(m+1)` would imply an
injection `m+1 ↪ m`, contradicting the ZF finite-cardinal theorem.

It then combines the earlier **explicit countable-choice proposition**
with the finite-witness results to verify the existence of such an
infinite enumerated union under `¬Finite(A) ∧ ACω`.

These statements are the finite-union part of the complete proof.
The countability bridge and final injection are now checked in the
linked enumeration and converse theories.

## Complete positive theorem — ZF plus countable choice

The following result is now **Isabelle2026 kernel-verified**:

```isabelle
theorem countable_choice_infinite_has_nat_injection:
  assumes inf: "\<not> Finite(A)" and cc: "countable_choice"
  shows "has_nat_injection(A)"
```

See [GateB_CountableConverse.thy](GateB_CountableConverse.thy) and the
[successful Isabelle2026 build](https://github.com/blackwell-systems/axiomscope/actions/runs/41278192193).

The proof runs in **Isabelle/ZF**, whose `ZF` base theory explicitly excludes
Choice. `countable_choice` is defined as a separate object-level proposition,
and passed as an explicit theorem assumption.

The construction takes the countably selected finite injections,
proves their ranges have an infinite union, then assigns each element
the **least natural-number code** of one of its occurrences. That gives
an injection from the union into `nat` without additional Choice.
Since the union is both nonfinite and well-orderable, it contains a
copy of `nat`, and the inclusion into `A` completes the proof.

The positive countable-choice result is standard mathematics, now
reproduced and checked in this project. It is **not** a novel theorem.

## Verified Dedekind-infinity equivalence

The Isabelle/ZF theory `GateB_CountableConverse.thy` proves without Choice:

    (nat ≲ A)  iff  (∃f∈inj(A,A). f∉surj(A,A)).

The forward proof embeds an extra point and restricts the resulting
injection, leaving one point uncovered. The reverse proof starts outside
the range of a supplied injective endomap, iterates it, then uses
two-variable induction to prove the sequence cannot repeat.

Machine-checked lemmas: `nat_injection_gives_proper_self_embedding`,
`proper_self_embedding_gives_nat_injection`, and
`dedekind_infinity_equivalence`.

[Successful Isabelle2026 verification](https://github.com/blackwell-systems/axiomscope/actions/runs/41291106509).

This is established mathematics, not a new independence result.

## External mathematical context and the unverified negative model

The countable choice principle `ACω` suffices to show every infinite set
contains an injection of `ω`. The Open Logic Project, *Set Theory*,
Theorem 9.9 provides background to this now machine-checked positive theorem:
https://builds.openlogicproject.org/content/set-theory/set-theory.pdf

Cohen's first symmetric model contains an infinite Dedekind-finite set of
reals, showing why the converse is not a theorem of ZF alone (relative to
the consistency assumptions of the symmetric-model construction).
A modern peer-reviewed account is in the *Journal of Symbolic Logic*,
Section 3.1 of *Does DC imply ACω uniformly?*:
https://www.cambridge.org/core/journals/journal-of-symbolic-logic/article/does-mathsf-dc-imply-mathsf-acomega-uniformly/05069A84199B3477B3BEA2E58EF21AF6

**The positive theorem above is machine-verified. The Cohen countermodel remains literature-only.** A cited paper is not proof-assistant verification.

## Exact outstanding gaps

- No kernel-checked first Cohen symmetric model within this project.
- No machine-checked *negative* independence result in this repository.
- No demonstrated novel mathematical discovery.

The evidence compiler must reject any attempt to change the paper-backed
claims to `formal_isabelle_kernel` or to substitute a well-order witness
for countable choice.

**Status: positive countable-choice theorem and Dedekind equivalence verified; the negative independence benchmark remains open.** The negative symmetric-model result is still external literature evidence, not a kernel-checked model in this project.
