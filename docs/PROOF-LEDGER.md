# Proof ledger

> **Generated file.** Do not edit directly. Regenerate with `python3 scripts/generate_proof_ledger.py --write`.

Axiom dependencies are extracted from Lean after successfully elaborating the declarations. Statements and construction descriptions come from [proofs/catalog.json](../proofs/catalog.json); machine-readable output: [proofs/dependencies.json](../proofs/dependencies.json).

| Declaration | Statement | Implementation | Profile | Axioms used |
| --- | --- | --- | --- | --- |
| `Axiomscope.natEquivEven` | ℕ ≃ {n : ℕ // Even n} | Explicit doubling map and halving inverse (local construction) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.natEquivInt` | ℕ ≃ ℤ | Reuses Mathlib's Equiv.intEquivNat.symm (Mathlib equivalence) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.cantorDiagonal` | ∀ f : ℕ → Set ℕ, ¬ Function.Surjective f | Direct diagonal contradiction (local proof) | `choice_free` | None reported |
| `Axiomscope.Experiment001.doubleNegatedExcludedMiddle` | ∀ P : Prop, ¬¬ (P ∨ ¬P) | Direct intuitionistic contradiction proof (Experiment 001 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment001.decidableExcludedMiddle` | ∀ P : Prop, [Decidable P] → (P ∨ ¬P) | Constructive disjunction from a Decidable instance (Experiment 001 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment001.classicalExcludedMiddle` | ∀ P : Prop, P ∨ ¬P | Unrestricted excluded middle under Lean classical reasoning (Experiment 001 local proof) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |
| `Axiomscope.Experiment001.classicalDoubleNegationElim` | ∀ P : Prop, ¬¬P → P | Unrestricted double-negation elimination under classical reasoning (Experiment 001 local proof) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |
| `Axiomscope.Experiment002.forces_mono` | ∀ φ w v, w.val ≤ v.val → forces w φ → forces v φ | Induction on formulas: truth persists to accessible worlds (Experiment 002 local semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment002.sound` | Provable Γ φ → ∀ w, holds Γ w → forces w φ | Induction over every rule of the explicit natural-deduction calculus (Experiment 002 local semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment002.root_not_forces_em` | ¬ forces root (atom ∨ (atom → ⊥)) | Two-world Kripke countermodel with atom forced only in the future (Experiment 002 local semantic proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment002.excludedMiddle_notDerivable` | ¬ Provable ∅ (atom ∨ (atom → ⊥)) | Soundness plus root countermodel yields a contradiction (Experiment 002 local semantic proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment003.forces_mono` | ∀ φ w z, w ≤ z → forces M w φ → forces M z φ | Induction proving formula persistence (General semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment003.sound` | Derives Γ φ → ∀ w, holds M Γ w → forces M w φ | Soundness by induction over the deduction rules (General semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment003.generic_em_not_derivable` | atom unforced at w, forced at z ≥ w → ¬ Derives ∅ (atom ∨ ¬atom) | Countermodel criterion using general soundness (General semantic proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment003.two_world_em_not_derivable` | ¬ Derives ∅ (atom ∨ ¬atom) in a specific two-world model | Two-world instance with accessibility and atomic witness proofs (Concrete specialization) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |
| `Axiomscope.Experiment004.induction_rule` | ∀ P : Number → Prop, P zero → (∀ n, P n → P (succ n)) → ∀ n, P n | Structural induction over the fresh inductive type (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.recurse_unique` | A recursive function with specified zero and successor equations is unique | Induction on Number with recursion equations (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.zero_ne_succ` | ∀ n : Number, zero ≠ succ n | Constructor disjointness by case analysis (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.succ_injective` | Injective Number.succ | Constructor injectivity via equality elimination (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.toNat_ofNat` | ∀ n : Nat, toNat (ofNat n) = n | Induction on built-in Nat (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.ofNat_toNat` | ∀ n : Number, ofNat (toNat n) = n | Induction on custom Number (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.equivNat` | Number ≃ Nat | Explicit forward/inverse functions with inverse laws (Local recursive definitions and inverse proofs) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.toNat_injective` | Injective toNat | Apply inverse function to an equality (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.toNat_add` | ∀ a b, toNat (add a b) = toNat a + toNat b | Induction on second argument and Nat addition recursion (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.toNat_mul` | ∀ a b, toNat (mul a b) = toNat a * toNat b | Induction on second argument and Nat multiplication recursion (Experiment 004 local proof) | `kernel_only` | None reported |
| `Axiomscope.Experiment004.add_assoc` | ∀ a b c, add (add a b) c = add a (add b c) | Transport Nat associativity across injective conversion (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.add_comm` | ∀ a b, add a b = add b a | Transport Nat commutativity across injective conversion (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.mul_assoc` | ∀ a b c, mul (mul a b) c = mul a (mul b c) | Transport Nat associativity across injective conversion (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment004.mul_add` | ∀ a b c, mul a (add b c) = add (mul a b) (mul a c) | Transport Nat distributivity across injective conversion (Experiment 004 local proof) | `choice_free` | `propext` |
| `Axiomscope.Experiment005.encode_succ` | ∀ M n, encode M (succ n) = M.succ (encode M n) | Definitional preservation of successor (Experiment 005 axiomatic characterization) | `kernel_only` | None reported |
| `Axiomscope.Experiment005.encode_unique` | Any zero/successor-preserving map Number → α equals encode M | Structural induction on Number (Experiment 005 axiomatic characterization) | `kernel_only` | None reported |
| `Axiomscope.Experiment005.encode_injective` | ∀ M, Function.Injective (encode M) | Constructor disjointness and successor injectivity (Experiment 005 axiomatic characterization) | `kernel_only` | None reported |
| `Axiomscope.Experiment005.encode_surjective` | ∀ M, Function.Surjective (encode M) | Full predicate induction on reachability (Experiment 005 axiomatic characterization) | `kernel_only` | None reported |
| `Axiomscope.Experiment005.encode_bijective` | ∀ M, Function.Bijective (encode M) | Assemble injectivity and surjectivity without choice (Experiment 005 axiomatic characterization) | `kernel_only` | None reported |
| `Axiomscope.Experiment005.equivalence` | ∀ M, Number ≃ α | Equiv.ofBijective packages a noncomputable inverse (Experiment 005 axiomatic characterization) | `classical_choice` | `Classical.choice` |
| `Axiomscope.Experiment005.encode_add` | ∀ M a b, encode M (Number.add a b) = M.add (encode M a) (encode M b) | Induction and explicit recursive addition equations (Experiment 005 axiomatic characterization) | `kernel_only` | None reported |
| `Axiomscope.Experiment005.encode_mul` | ∀ M a b, encode M (Number.mul a b) = M.mul (encode M a) (encode M b) | Induction and explicit recursive multiplication equations (Experiment 005 axiomatic characterization) | `kernel_only` | None reported |
| `Axiomscope.Experiment005.twoTracks_not_inductive` | WeakSuccessor (Number × Bool) fails full induction | An extra successor track satisfies weak axioms but violates induction (Experiment 005 axiomatic characterization) | `kernel_only` | None reported |
| `Axiomscope.Experiment006.bind_same` | ∀ ρ i a, bind ρ i a i = a | Update an individual variable at its named index (Experiment 006 first-order syntax and semantic schema) | `choice_free` | `propext` |
| `Axiomscope.Experiment006.bind_other` | ∀ ρ i j a, j ≠ i → bind ρ i a j = ρ j | Update leaves other variable indices untouched (Experiment 006 first-order syntax and semantic schema) | `choice_free` | `propext` |
| `Axiomscope.Experiment006.zeroOrSuccessor_iff` | satisfies M ρ (x=0 ∨ ∃y, x=S(y)) ↔ ρ 0=M.zero ∨ ∃a,ρ 0=M.succ a | Unfold first-order satisfaction and bound-variable reassignment (Experiment 006 first-order syntax and semantic schema) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment006.full_induction_implies_first_order` | ArithmeticSystem full predicate induction → FirstOrderInduction (signatureOf M) | Instantiate the full induction field with the predicate interpreted by each first-order formula (Experiment 006 first-order syntax and semantic schema) | `kernel_only` | None reported |
| `Axiomscope.Experiment006.twoTracks_not_first_order_inductive` | ¬ FirstOrderInduction twoTracks | Concrete refutation by the formula x=0 ∨ ∃y, x=S(y) on an extra successor chain (Experiment 006 first-order syntax and semantic schema) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment007.earlier_mem_prefix` | Earlier selected elements belong to every later finite prefix | Induction on prefix length, using elementary natural-number order lemmas (Experiment 007 explicit-assumption comparison) | `choice_free` | `propext` |
| `Axiomscope.Experiment007.chosen_injective` | A uniform fresh-point selector generates a sequence with no repeated elements | Construct selected points by finite prefixes and use freshness (Experiment 007 explicit-assumption comparison) | `choice_free` | `propext` |
| `Axiomscope.Experiment007.finite_avoidance_suffices` | FiniteAvoidance α → HasCountableSubset α | Explicit uniform finite-avoidance selector, no ambient choice hypothesis (Experiment 007 explicit-assumption comparison) | `choice_free` | `propext` |
| `Axiomscope.Experiment007.countable_subset_implies_infinite` | HasCountableSubset α → Infinite α | Use Mathlib Infinite.of_injective from a supplied injection (Experiment 007 explicit-assumption comparison) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |
| `Axiomscope.Experiment007.ambient_infinite_has_countable_subset` | Infinite α → HasCountableSubset α in the ambient Mathlib foundation | Use Mathlib Infinite.natEmbedding, whose current proof uses Classical.choice (Experiment 007 explicit-assumption comparison) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |
| `Axiomscope.Experiment007.nat_has_proper_self_embedding` | HasProperSelfEmbedding Nat | The successor map is injective and omits zero (Experiment 007 explicit-assumption comparison) | `choice_free` | `propext` |
| `Axiomscope.Experiment007.proper_self_embedding_of_equiv_nat` | (α ≃ Nat) → HasProperSelfEmbedding α | Transport the successor shift along an explicitly supplied equivalence (Experiment 007 explicit-assumption comparison) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment008.intuitionistic_to_classical` | IPC Γ φ → CPC Γ φ | Direct induction transporting every intuitionistic derivation constructor (Experiment 008 proof-interpretation pilot) | `kernel_only` | None reported |
| `Axiomscope.Experiment008.inclusion_preserves` | Interpretation IPC CPC transports derivations and contexts | Apply the typed proof-preserving inclusion (Experiment 008 proof-interpretation pilot) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment008.inclusion_composed_with_identity` | IPC → CPC → CPC preserves any IPC derivation | Compose the inclusion with a verified identity interpretation (Experiment 008 proof-interpretation pilot) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment008.no_reverse_identity_interpretation` | No identity-on-formulas proof-preserving interpretation CPC → IPC | CPC excluded-middle proof contradicts Experiment 003 two-world Kripke countermodel (Experiment 008 proof-interpretation pilot) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |
| `Axiomscope.Experiment009.translate_derivation` | Source IPC derivations transport to the expanded formula calculus with translated assumptions | Induction on all source inference rules; explicit set-image transport (Experiment 009 Kripke-preserving nonidentity encoding) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment009.semantics_equiv` | Target forcing of translate φ iff source forcing of φ at every world | Structural recursion; arbitrary persistent Kripke models (Experiment 009 Kripke-preserving nonidentity encoding) | `choice_free` | `propext` |
| `Axiomscope.Experiment009.context_semantics_equiv` | Satisfaction of translated premise images iff satisfaction of source context | Equivalence of every source assumption with its translation (Experiment 009 Kripke-preserving nonidentity encoding) | `choice_free` | `propext` |
| `Axiomscope.Experiment009.top_not_in_image` | No source formula maps to primitive target top syntax | Constructor distinction proves a concrete non-surjectivity claim about syntax (Experiment 009 Kripke-preserving nonidentity encoding) | `kernel_only` | None reported |
| `Axiomscope.Experiment009.embedding_compose_identity` | Translated derivation remains valid after composing with target identity interpretation | Use composition of proof-preserving interpretations (Experiment 009 Kripke-preserving nonidentity encoding) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment010.certified_derivation` | Certified Kripke interpretation carries every intuitionistic derivation | Use the certificate's underlying proof transport (Experiment 010 checked semantic interpretation certificates) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment010.certified_contexts` | Certified translation preserves and reflects Kripke satisfaction of arbitrary contexts | Instantiate the general context equivalence theorem (Experiment 010 checked semantic interpretation certificates) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment010.composed_semantics` | Composition with semantic identity preserves and reflects Kripke forcing | Compose two semantic certificates and use their equivalence (Experiment 010 checked semantic interpretation certificates) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment010.composed_derivation` | Composition with semantic identity transports intuitionistic proofs | Use the composed certificate's underlying proof interpretation (Experiment 010 checked semantic interpretation certificates) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment011.pullback_forcing_equiv` | Bounded world maps preserve and reflect Kripke forcing for every formula | Structural induction; implication uses bounded-map future back-lifting (Experiment 011 bounded Kripke model/world translation) | `kernel_only` | None reported |
| `Axiomscope.Experiment011.cover_context_equiv` | Model-indexed certificate preserves truth of arbitrary contexts | Instantiate generic translated-context satisfaction theorem for Nat × Bool cover (Experiment 011 bounded Kripke model/world translation) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment011.cover_transports_derivation` | Model-indexed certificate transports intuitionistic derivations | Apply proof-preservation field of combined formula/model interpretation (Experiment 011 bounded Kripke model/world translation) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment011.composed_cover_satisfaction` | Composed model certificate preserves forcing across world and syntax maps | Use model-level certificate composition with identity (Experiment 011 bounded Kripke model/world translation) | `choice_free` | `Quot.sound`, `propext` |
| `Axiomscope.Experiment011.bad_projection_not_back` | Root-only projection from one world into a two-world frame fails back lifting | Explicit future world cannot be reached from singleton (Experiment 011 bounded Kripke model/world translation) | `choice_free` | `propext` |
| `Axiomscope.Experiment011.bad_projection_changes_implication` | Root-only monotone projection changes truth of p implies false | Explicit two-world Kripke implication counterexample (Experiment 011 bounded Kripke model/world translation) | `classical_choice` | `Classical.choice`, `Quot.sound`, `propext` |

## Scope of the audit

- The recorded dependencies are **axioms**, not the complete transitive graph of definitions and lemmas.
- An empty axiom list does **not** mean a theorem was proved without a logical system, trusted kernel, or definitions.
- Absence of `Classical.choice` in the report does not by itself guarantee executable content.
- The global allowlist and per-proof profiles reject unexpected axioms or missing required classical assumptions.
- Lean's `Classical.choice` is not the ZFC Axiom of Choice.
- This audits particular proofs; it does not prove alternative proofs or models are impossible.

## Regenerate or verify

```sh
lake exe cache get
lake build
python3 scripts/generate_proof_ledger.py --write  # intentional updates
python3 scripts/generate_proof_ledger.py --check  # CI
```

CI fails if either generated file is missing or differs from a fresh successful Lean run.
