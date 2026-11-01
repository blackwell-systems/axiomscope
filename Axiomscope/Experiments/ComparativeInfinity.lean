import Mathlib

/-!
# Experiment 007 — comparative infinity

This experiment separates three claims that are often conflated:

* a *uniform finite-avoidance selector* (choose a point outside any finite list);
* a *countably infinite subset* (an injective sequence of points);
* a *Dedekind witness* (an injective, non-surjective self-map).

The uniform selector yields an injective sequence by primitive recursion, with
no global choice argument. Mathlib's Infinite.natEmbedding supplies an
alternative proof from the ambient "not finite" typeclass; that construction
has its own axiomatic dependencies, audited below.

This first comparison is between explicit assumptions and the ambient Lean
foundation. It is **not** a model of ZF without choice, and does not establish
independence of Dedekind infinitude from ordinary infinitude.
-/

namespace Axiomscope.Experiment007

universe u

/-- An explicit selector, uniform over all finite lists of elements. -/
structure FiniteAvoidance (α : Type u) where
  pick : List α → α
  fresh : ∀ xs : List α, pick xs ∉ xs

/-- Build the first `n` selected points in reverse chronological order. -/
def selectedPrefix {α : Type u} (s : FiniteAvoidance α) : Nat → List α
  | 0 => []
  | n + 1 => s.pick (selectedPrefix s n) :: selectedPrefix s n

/-- Each new point avoids every previously chosen point. -/
def chosen {α : Type u} (s : FiniteAvoidance α) (n : Nat) : α :=
  s.pick (selectedPrefix s n)

/-- Previously selected points occur in every later selectedPrefix. -/
theorem earlier_mem_prefix {α : Type u} (s : FiniteAvoidance α)
    (m n : Nat) (h : m < n) : chosen s m ∈ selectedPrefix s n := by
  induction n with
  | zero =>
      omega
  | succ n ih =>
      by_cases heq : m = n
      · subst m
        change chosen s n = chosen s n ∨ chosen s n ∈ selectedPrefix s n
        exact Or.inl rfl
      · have hlt : m < n := by omega
        change chosen s m = chosen s n ∨ chosen s m ∈ selectedPrefix s n
        exact Or.inr (ih hlt)

/-- A uniform finite-avoidance selector generates an injection of Nat. -/
theorem chosen_injective {α : Type u} (s : FiniteAvoidance α) :
    Function.Injective (chosen s) := by
  intro m n h
  rcases lt_trichotomy m n with hlt | heq | hgt
  · have hmem : chosen s m ∈ selectedPrefix s n :=
      earlier_mem_prefix s m n hlt
    rw [h] at hmem
    exact False.elim ((s.fresh (selectedPrefix s n)) hmem)
  · exact heq
  · have hmem : chosen s n ∈ selectedPrefix s m :=
      earlier_mem_prefix s n m hgt
    rw [← h] at hmem
    exact False.elim ((s.fresh (selectedPrefix s m)) hmem)

/-- Existence of a countably infinite subset, as a concrete injection. -/
def HasCountableSubset (α : Type u) : Prop :=
  ∃ f : Nat → α, Function.Injective f

/-- Explicit uniform finite avoidance suffices to construct a countable subset. -/
theorem finite_avoidance_suffices {α : Type u} (s : FiniteAvoidance α) :
    HasCountableSubset α :=
  ⟨chosen s, chosen_injective s⟩

/-- A countably infinite subset proves that the ambient type is infinite. -/
theorem countable_subset_implies_infinite {α : Type u}
    (h : HasCountableSubset α) : Infinite α := by
  rcases h with ⟨f, hf⟩
  exact Infinite.of_injective f hf

/-- Under Lean/Mathlib's ambient choice-capable foundation, ordinary
infinitude gives a countably infinite subset via a library embedding. -/
theorem ambient_infinite_has_countable_subset (α : Type u) [Infinite α] :
    HasCountableSubset α :=
  ⟨Infinite.natEmbedding α, (Infinite.natEmbedding α).injective⟩

/-- An injective but not surjective self-map witnesses Dedekind infinitude. -/
def HasProperSelfEmbedding (α : Type u) : Prop :=
  ∃ f : α → α, Function.Injective f ∧ ¬ Function.Surjective f

/-- The successor map shows that the naturals are Dedekind-infinite. -/
theorem nat_has_proper_self_embedding : HasProperSelfEmbedding Nat := by
  refine ⟨Nat.succ, Nat.succ_injective, ?_⟩
  intro h
  rcases h 0 with ⟨n, hn⟩
  exact Nat.succ_ne_zero n hn

/-- Transport a Dedekind witness along a supplied equivalence to Nat.
The equivalence is an explicit hypothesis rather than a chosen inverse. -/
theorem proper_self_embedding_of_equiv_nat {α : Type u}
    (e : α ≃ Nat) : HasProperSelfEmbedding α := by
  refine ⟨fun x => e.symm (Nat.succ (e x)), ?_, ?_⟩
  · intro a b hab
    apply e.injective
    have hs : Nat.succ (e a) = Nat.succ (e b) := by
      have he := congrArg e hab
      simpa using he
    exact Nat.succ.inj hs
  · intro h
    rcases h (e.symm 0) with ⟨a, ha⟩
    have hz : Nat.succ (e a) = 0 := by
      have he := congrArg e ha
      simpa using he
    exact (Nat.succ_ne_zero _) hz

end Axiomscope.Experiment007

#print axioms Axiomscope.Experiment007.earlier_mem_prefix
#print axioms Axiomscope.Experiment007.chosen_injective
#print axioms Axiomscope.Experiment007.finite_avoidance_suffices
#print axioms Axiomscope.Experiment007.countable_subset_implies_infinite
#print axioms Axiomscope.Experiment007.ambient_infinite_has_countable_subset
#print axioms Axiomscope.Experiment007.nat_has_proper_self_embedding
#print axioms Axiomscope.Experiment007.proper_self_embedding_of_equiv_nat
