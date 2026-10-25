# Experiment 002 — a Kripke countermodel to excluded middle

## Question

Can we establish a genuine **nonderivability result** rather than merely observe that a particular Lean proof uses classical axioms?

Yes, for a precisely defined small intuitionistic propositional calculus. This is a well-known metatheoretic technique, formalized here in Lean—not a newly discovered independence result.

## The two-world model

We take two worlds, ordered by accessibility:

```text
root (0)  ─────▶  future (1)
atom false       atom true
```

The atomic proposition is **not forced** at the root and **is forced** at the future world. Forcing is persistent: what is forced earlier remains forced later.

The semantic clauses for the propositional fragment are:

- `w ⊩ atom` precisely when `1 ≤ w.val`
- `w ⊩ ⊥` never
- `w ⊩ A ∨ B` when `w ⊩ A` or `w ⊩ B`
- `w ⊩ A → B` when **every accessible future world** forcing `A` also forces `B`

At the root, neither `atom` nor `atom → ⊥` is forced. The first fails because the atom is not yet true. The second fails because at the future world, the atom is forced but falsity is not. Thus

[
	ext{root} 
otVdash mathrm{atom} lor (mathrm{atom}	oot).
]

## Formalized deduction system

`Provable Γ φ` contains precisely these rule constructors:

- Assumption from the context
- Disjunction introduction, left and right
- Disjunction elimination by cases
- Implication introduction (discharging an assumption)
- Implication elimination (modus ponens)
- Elimination of falsity

**No excluded-middle axiom** or unrestricted double-negation-elimination rule is included.

The Lean proof `sound` establishes by induction over all derivations:

[
mathrm{Provable}(Gamma,arphi)
;Longrightarrow;
orall w, (mathrm{holds}(Gamma,w)	o wVdasharphi).
]

The empty context is satisfied at the root. A derivation of excluded middle from no assumptions would therefore force it at the root, contradicting the countermodel.

Consequently `excludedMiddle_notDerivable` establishes:

[

eg,mathrm{Provable}(arnothing, mathrm{atom}lor(mathrm{atom}	oot)).
]

## Why this is stronger than Experiment 001

Experiment 001 audits the axioms in **specific** Lean proofs, which cannot establish that another proof is impossible.

Experiment 002 combines an explicitly defined calculus, a semantic interpretation, a theorem stating all calculus derivations are sound, and a counterexample to the target formula. It therefore rules out **every possible derivation in that calculus**.

## Limits and next steps

This proves a familiar nonderivability theorem for the `⊥`, `∨`, `→` fragment with one atom. It does not assert that the ambient Lean logic is intuitionistic, nor settle any question independent of ZFC.

Further work would generalize the forcing relation to arbitrary atoms and arbitrary finite Kripke frames, formalize more connectives, and compare provability across multiple systems. Claims about a broader calculus require corresponding soundness or conservativity arguments.

## Verification

- [Lean implementation](../../Axiomscope/Experiments/KripkeCountermodel.lean)
- [Machine-readable theorem record](../../proofs/experiments/002-kripke-countermodel.json)
- [Proof ledger](../PROOF-LEDGER.md)

Every dependency is audited by CI and checked against the committed generated files. The soundness proof and persistence lemma report no additional axioms; the countermodel and nonderivability proofs report `propext` and no `Classical.choice`.
