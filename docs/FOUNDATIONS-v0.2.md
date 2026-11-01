# Foundations v0.2 — an experiment in proof-context semantics

**Status:** candidate architecture with an executable, deliberately limited experiment.
**Target:** move beyond collecting theorems by testing how formal proof witnesses behave
when the assumptions available to a mathematician change.

This is **not** an alternative set theory, a new logic, an independence proof, or
a demonstrated improvement over existing theorem-prover capabilities.

## 1. The research question

Can a proof-assistant-verified result be exposed as an **applicable witness**
whose assumptions, provenance, and logical environment are explicit enough
to answer counterfactual questions?

Example: given a nonfinite set A in ZF, which *registered derivations*
can produce an injection from the natural numbers into A? What changes if
we additionally supply countable choice, or a local well-order of A?

Axiom lists alone do not answer that conditional query: the premises of the
theorem, the assumptions available in the current context, and alternative
proof routes also matter. Existing assistants may already provide analogous
capabilities; v0.2 is a reproducible test candidate, not a novelty claim.

## 2. A small vocabulary

1. **Foundation:** a specific object logic and proof checker. Our first
   foundation is Isabelle/ZF. An Isabelle/HOL or Lean proof is not silently
   treated as a proof inside Isabelle/ZF.
2. **Context:** named premises currently available, e.g. nonfiniteness of A,
   countable choice AComega, a well-order witness for A, or a nat injection.
3. **Claim:** a precisely scoped theorem statement, linked to its proof
   assistant declaration and actual source.
4. **Witness:** a *registered* formal proof of a claim together with a
   contract identifying the premises required to apply it to the current
   goal. A witness does not become an axiom.
5. **Goal:** an assertion we want to obtain by applying one of those
   existing witnesses, e.g. a nat injection from a nonfinite A.
6. **Interpretation:** a possible future bridge between different
   foundational languages. Any such bridge must specify translations of
   statements, preservation of meaning, and verified proof transport.
   **No interpretations are implemented in v0.2.**

The candidate representation is a graph:
foundation -> context -> goal -> applicable proof witnesses -> verified source.
The important distinction is between a theorem being *proved conditionally*
inside ZF and a user having discharged the condition in a particular context.

## 3. Operational meaning (first experiment)

Let C be a finite set of explicitly supplied premises and let R(p) be
the registered premises required to use a verified proof witness p.

    applicable(p, C) := checked(p) AND same_logic(p, C) AND R(p) subset C
    supported(g, C) := EXISTS p for g such that applicable(p, C)

The implementation produces **supported_by_registered_proof** or
**no_registered_witness**. The latter MUST NOT mean false, unprovable, or
independent. A different proof may exist outside our registry.

The conditions are **local context premises**, not universal axioms.
For example, wellorder_A means the particular set A is equipotent to an
ordinal; it is strictly different from assuming the global axiom of choice.
The system never identifies Lean's Classical.choice with set-theoretic AComega.

The v0.2 prototype has three explicit proof contracts from the existing
[Gate B manifest](../research/gates/b/manifest.json):

| Goal | Formal proof | Context requirements |
| --- | --- | --- |
| Nonfinite A -> nat injects into A | countable_choice_infinite_has_nat_injection | nonfinite_A, AComega |
| Nonfinite A -> nat injects into A | wellorderable_infinite_has_nat_injection | nonfinite_A, wellorder_A |
| Nat injects into A -> A nonfinite | countable_injection_implies_infinite | nat_injection_A |

These theorems and their concrete signatures are checked against the
Gate B manifest and source file. Any attempt to use a published-only
countermodel as a kernel-verified proof is rejected. The GitHub CI also
replays the existing Isabelle Gate B session, separately from this query
tool.

## 4. Counterfactual experiment

The [scenario inputs](../research/foundations-v0.2/scenarios.json)
define five contexts, including bare nonfiniteness in ZF, extra AComega,
extra local well-orderability, and an explicit injection witness.

The [generated results](../research/foundations-v0.2/report.json)
show that:

- Under nonfinite_A alone, **neither registered positive proof** is
  directly applicable. This is **not** proof of ZF nonderivability.
- Under nonfinite_A + AComega, the explicit countable-choice proof applies.
- Under nonfinite_A + wellorder_A, the local well-order proof applies
  instead, without needing AComega.
- Given a nat injection, the ZF nonfiniteness proof applies.
- Supplying both positive-premise alternatives preserves both available
  witnesses rather than arbitrarily declaring one the unique proof.

Removing a premise can remove registered support. It cannot logically
refute a theorem. The proof applicability relation is monotone under
**adding** context premises as long as the foundation and proof registry
do not change.

## 5. Trust and failure conditions

- Gate B's existing evidence validator must pass. The v0.2 query engine
  cannot confer formal status on unverified mathematical claims.
- Exact proof IDs, statements, scope and assumptions must match checked
  Gate B records. No arbitrary JSON-defined proof is trusted.
- Each source theorem must exist in its named Isabelle/ZF file.
- The generated report must be deterministic and checked into Git.
- The query engine must reject an unknown logical system or premise tag.
- An absent proof, a failed proof attempt, or a literature citation must
  never be reported as a formally checked countermodel.
- Source checks by themselves do not replace Isabelle kernel replay.

These checks establish that our **metadata computation** is accountable;
they do not independently type-check an arbitrary user-supplied theorem.

## 6. Measurable milestone and failure criterion

v0.2 is successful as an *engineering prototype* if its tests, report,
existing Gate B evidence checks and Isabelle proof replay all pass,
and it answers the scenario queries reproducibly.

That is NOT success for the larger foundational research objective.
To justify a distinct research contribution, we still need to:

1. **Replace manually curated applicability contracts** with a checked
   extraction of proof dependencies and explicit premise discharge.
2. **Benchmark against Isabelle locales/interpretations, AFP, Lean
   declarations/axiom inspection and existing proof-analysis tools.**
   If they already do this just as well, do not label it novel.
3. **Add verified foundation-to-foundation translations** or another
   genuinely useful capability with a correctness theorem.
4. **Demonstrate a concrete advantage**, such as fewer unsupported
   transports, a precise counterexample to naïve assumption remapping,
   or reliable semantic preservation that existing reports do not expose.

A failed comparison should lead to revising or stopping this architecture,
not inventing new axioms to force a result.

## 7. Running the experiment

From the repository root, with Python 3:

    python3 -m unittest scripts.tests.test_foundation_probe_v02 -v
    python3 scripts/check_foundation_gate_b.py --check
    python3 scripts/foundation_probe_v02.py --check

Use --write only for an intentional input or contract change, and commit
the resulting report. GitHub Actions also runs these commands.

## 8. Current limits

Only Isabelle/ZF and three *existing* theorems are covered. The registry
is small and contracts are manually curated, so we cannot claim automated
dependency discovery. Different representations of the same proposition
are not automatically equated. Proofs in different kernels are not
transported. We have not proved a new mathematical theorem, found a
countermodel, or established independence of ZF principles.

**Research decision:** use this as the smallest test of the architecture.
Do not resume unbounded theorem formalizations until the capability
is compared to existing work and the next milestone is falsifiable.
