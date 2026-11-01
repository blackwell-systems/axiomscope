# Gate B — choice-sensitive infinity (partial benchmark)

## Research objective

We want to compare the *same* set-theoretic distinction:

**Infinite(A) ⇒ DedekindInfinite(A)**

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

## Explicit countable choice and the finite-witness theorem

[GateB_CountableChoice.thy](GateB_CountableChoice.thy) introduces
`countable_choice` **as a proposition in the ZF object logic**: every
natural-number-indexed family of nonempty sets has a choice function.
This is a conditional assumption, **not** a new global Isabelle axiom.

The formal development proves that any infinite set has injections
`n → A` for each individual finite ordinal `n` without Choice.
Assuming `countable_choice`, it then selects a single family of such
finite injections indexed by every natural number.

**The crucial assembly step is still missing:** the selected finite
injections have not yet been combined into an injection `nat → A`.
Thus we have formalized a meaningful partial countable-choice proof,
not the full claim `ZF + ACω ⊢ Infinite(A) → DedekindInfinite(A)`.

## Verified infinite union of selected finite injections

[GateB_Assemble.thy](GateB_Assemble.thy) proves that if one injection
`f_n : n ↪ A` is supplied for each finite ordinal `n`, the union
`⋃ₙ range(f_n)` is infinite. Otherwise, if the union were equipotent
to a finite ordinal `m`, the selected `f_(m+1)` would imply an
injection `m+1 ↪ m`, contradicting the ZF finite-cardinal theorem.

It then combines the earlier **explicit countable-choice proposition**
with the finite-witness results to verify the existence of such an
infinite enumerated union under `¬Finite(A) ∧ ACω`.

These statements are part of the proof of the countable-choice
converse, **not yet the converse itself**. The bridge proving that
this union embeds in `nat` remains to be checked before claiming
`nat ≲ A`.

## Complete positive theorem — ZF plus countable choice

The following result is now **Isabelle2026 kernel-verified**:

```isabelle
theorem countable_choice_infinite_has_nat_injection:
  assumes inf: "\\<not> Finite(A)" and cc: "countable_choice"
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

## Published, but not kernel-checked here

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
- No kernel-checked bridge from `nat ≲ A` to a proper self-embedding here.
- No machine-checked *negative* independence result in this repository.
- No demonstrated novel mathematical discovery.

The evidence compiler must reject any attempt to change the paper-backed
claims to `formal_isabelle_kernel` or to substitute a well-order witness
for countable choice.

**Status: positive countable-choice theorem complete; Gate B independence benchmark remains open.** The negative symmetric-model result is still external literature evidence, not a kernel-checked model in this project.
