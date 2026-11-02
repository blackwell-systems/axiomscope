# AXIOMSCOPE

> **Project status: Concluded — archival snapshot (November 2026).**
>
> AxiomScope was an experimental investigation of mathematical foundations,
> formal verification, logical interpretations, and assumption-sensitive
> constructions. Active development has ended. This public repository is
> retained as a reproducible record of the investigation.
>
> **What was achieved:** machine-checked formalizations of established
> mathematics in Lean 4 and Isabelle/ZF, plus experimental proof-context and
> interpretation tools. **What was not achieved:** a new mathematical
> foundation, an original mathematical theorem, a verified negative
> set-theoretic independence model, or a demonstrated research advantage
> over established tools.
>
> The final [native Isabelle benchmark](research/benchmarks/native-isabelle-choice/RESULTS.md)
> found no distinguishing advantage for AxiomScope's registered
> assumption/witness analysis. See the
> [underlying observations](research/benchmarks/native-isabelle-choice/observed-isabelle2026.json)
> and [proof ledger](docs/PROOF-LEDGER.md) for the evidence and limits.

**Proofs carry their assumptions. Foundations have relationships.**

AXIOMSCOPE was an experimental research project investigating how mathematical
foundations, their assumptions, and theorems could be represented and related in
a precise, machine-checkable way.

The work used Lean 4 and Isabelle to test that idea. **The aim was not to build another
theorem prover or merely catalogue known proofs.** The motivating question was
whether we can develop a rigorous and useful account of transformations between
foundational systems: what can be interpreted, what is preserved, and what
cannot be transferred without additional assumptions.

> **Research question:** Given a mathematical statement or construction proved
> in foundation F₁, under what verified conditions can it be interpreted or
> reconstructed in foundation F₂? If it cannot, can we establish a genuine
> mathematical obstruction rather than merely fail to find a proof?

This objective builds on substantial prior work in mathematical logic, theory
interpretations, proof assistants, and categorical and structural foundations.
We claim **no new foundation or mathematical discovery** at present.

## Original research goal (historical)

The intended contribution was to do more than display axioms used by a proof.
The research program asked whether a coherent framework could connect:

| Component | What must be represented or verified |
| --- | --- |
| **Foundations** | Primitive objects, formation and inference rules, axioms, and semantics |
| **Proof contexts** | Which assumptions are available for a particular claim |
| **Mathematical constructions** | How objects and witnesses are defined, not just whether they exist |
| **Interpretations** | Explicit translations between mathematical languages and structures |
| **Preservation results** | Proofs that a translation preserves designated statements or constructions |
| **Obstructions** | Actual countermodels, noninterpretability results, or other verified failures of preservation |

For a suitably verified interpretation `I : F₁ → F₂`, the kind of
preservation result we want to investigate has the form:

```text
F₁ ⊢ T      ⟹      F₂ ⊢ I(T)
```

The implication **requires hypotheses and a proof about I**; it is not true
for an arbitrary translation or any pair of foundations. Finding the exact
conditions, their compositional behavior, and useful cases of failure is
part of the mathematical work.

There are also general limits: no tool can automatically decide arbitrary
mathematical statements, always find the weakest assumptions, or universally
transport proofs between unrelated logics. AXIOMSCOPE must report those limits
rather than hide them.

## What exists today

The current repository is a **verified research scaffold**, not a new
axiomatic system. Our experiments fall into three categories:

| Area | Verified work | Important limit |
| --- | --- | --- |
| **Lean foundations experiments** | Cardinality, excluded middle, Kripke nonderivability, independent natural-number constructions, Peano-style structures and first-order induction | These experiments use Lean's existing logical rules and do not establish a new foundation |
| **Isabelle foundational comparisons** | Reproduced ZF versus hereditarily finite foundations (Gate A); proved the positive ZF + countable-choice infinity implication (Gate B) | The symmetric-model independence side of Gate B is *published literature*, not machine-checked here |
| **Foundations v0.2–v0.3 prototypes** | Context-sensitive applicability of three registered Isabelle/ZF proofs; explicit premises extracted from source and checked against elaborated Isabelle theorem statements with exported evidence | This is neither automatic transitive proof-dependency extraction nor cross-foundation proof transport |

The detailed results, caveats, and proof evidence live in the research
documents and machine-generated reports. **A missing registered proof never
counts as evidence that a theorem is false or independent.**

## Final research decision

The final research benchmark compared the choice-sensitive witness analysis
against native Isabelle2026 proof-dependency and oracle reporting. In seven
machine-checked theorem graphs, native Isabelle exposed the relevant
construction chain, including the finite-witness, countable-choice selection,
and injection-extraction steps.

The benchmark **did not demonstrate a distinctive mathematical analysis
capability** for the AxiomScope registry. This is a bounded negative
assessment of the proposed research direction, not a theorem proving that
future contributions are impossible. The project was concluded rather than
expanded into additional experiments.

See [the benchmark methodology](research/benchmarks/native-isabelle-choice/README.md)
and [recorded results](research/benchmarks/native-isabelle-choice/RESULTS.md).
The earlier [research roadmap](docs/ROADMAP.md) is preserved as a historical
record, not a current plan.

## Prototype: assumption-context analysis

The [Foundations v0.2 specification](docs/FOUNDATIONS-v0.2.md) models a
foundation, context, theorem, and registered proof witness. Given a context
such as `¬Finite(A)`, it asks which **already checked proofs** can establish
a desired conclusion if additional premises (for example countable choice
or local well-orderability) are supplied.

The [scenario engine](scripts/foundation_probe_v02.py) uses
[explicit scenarios](research/foundations-v0.2/scenarios.json) and a
[deterministic report](research/foundations-v0.2/report.json).

The [Foundations v0.3 experiment](docs/FOUNDATIONS-v0.3.md) adds
[Isabelle-generated statement checks](research/gates/b/GateB_ProverBridge.thy).
These compare the parsed assumptions with **elaborated theorem objects** and
export prover-rendered signatures for CI to consume. That improves the
provenance of the analysis, but does **not** inspect all transitive
proof dependencies or prove translation between logical systems.

A native Isabelle exporter or dependency tool may already supply much of
this functionality. The prototype is a research test bed, **not a claim of
uniqueness**.

## Experiment 008 — first verified interpretation between logical systems

[Experiment 008](docs/experiments/008-foundational-interpretations.md) is
our first direct test of the mathematical architecture. We formalize
**intuitionistic and classical natural-deduction calculi** in one common
propositional language, and a reusable interpretation carrying formulas,
contexts, and proofs. An induction translates every intuitionistic
derivation into a classical derivation; a Kripke countermodel rules out
the reverse **identity-on-formulas** interpretation. Interpretations
compose under verified proof preservation.

These are established logical facts. This is not yet a translation
between ZF and type theory, and it does not exclude other nonidentity
translations of classical into intuitionistic logic.

## Experiment 009 — a nonidentity translation with semantic evidence

[Experiment 009](docs/experiments/009-nonidentity-translation.md) moves
beyond Experiment 008's shared-language inclusion. A **distinct target
formula language** adds conjunction and truth. We translate each source
atom into its conjunction with truth, preserving all source derivations
and the truth of every translated formula and context in arbitrary
Kripke models.

This is a verified **conservative encoding**, not yet a theorem between
different mathematical foundations or a claim of novelty.

## Experiment 010 — composable semantic certificates

[Experiment 010](docs/experiments/010-semantic-certificates.md)
packages both derivation preservation and Kripke meaning-preservation in a
**single verified interpretation certificate**. Identity and composition
are certified generically; context satisfaction follows automatically
from the certificate. A concrete semantic mismatch rules out a proposed
certificate when its meaning-preservation condition cannot hold.

The implementation still uses one shared semantic index and one Lean
kernel. It does not transfer arbitrary models or prove that different
mathematical foundations are equivalent.

## Experiment 011 — models and worlds now translate too

[Experiment 011](docs/experiments/011-model-translation.md) generalizes
semantic certificates to **different source/target model and world types**.
A Kripke bounded map transports atomic valuations, with a formally
verified truth correspondence for all formulas. This combines with the
nonidentity formula translation from Experiment 009 in one reusable
model-indexed certificate.

A two-world counterexample demonstrates that monotonicity **without
back-lifting accessible futures** is not sufficient to preserve implication.
These are established results about Kripke models, not a new foundational
system or proof of mathematical novelty.

## Experiment 012 — institution-theory baseline

[Experiment 012](docs/experiments/012-signature-satisfaction.md)
formalizes the classical institution **satisfaction condition** for
signature-indexed propositional languages. Renaming atomic symbols
translates formulas covariantly and reduces valuations contravariantly;
Lean verifies identity, composition and invariance of satisfaction.
A mismatched model reduct is rejected by an explicit counterexample.

**This is established institution theory, not new mathematics.**
Its purpose is to provide an honest baseline and sharpen the next
research decision: demonstrate a useful assumption/witness analysis
beyond existing frameworks, or pivot.

## Mathematical experiments

The early experiments establish checked examples and probe specific
foundational distinctions. They are supporting evidence, **not** the
long-term research objective.

| Experiment | Question | Formalization and explanation |
| --- | --- | --- |
| Baseline | How do bijections and Cantor diagonalization compare cardinalities? | [Lean proofs](Axiomscope/CardinalExamples.lean) |
| 001 | What changes when excluded middle requires a decision procedure or classical reasoning? | [Explanation](docs/experiments/001-excluded-middle.md) |
| 002 | Can a Kripke countermodel prove nonderivability in a specified intuitionistic calculus? | [Explanation](docs/experiments/002-kripke-countermodel.md) |
| 003 | Does the Kripke soundness argument generalize to arbitrary atoms and worlds? | [Explanation](docs/experiments/003-general-kripke.md) |
| 004 | Can we reconstruct natural numbers and verify equivalence to built-in `Nat`? | [Explanation](docs/experiments/004-natural-numbers.md) |
| 005 | What exactly does full predicate induction provide in a Peano-style structure? | [Explanation](docs/experiments/005-peano-axioms.md) |
| 006 | How does first-order induction over formulas differ from full predicate induction? | [Explanation](docs/experiments/006-first-order-induction.md) |
| 007 | Which infinity arguments use explicit selection versus ambient assumptions? | [Explanation](docs/experiments/007-comparative-infinity.md) |
| 008 | Which proofs survive a translation between intuitionistic and classical calculi, and where does the reverse identity map fail? | [Formal experiment](docs/experiments/008-foundational-interpretations.md) |
| 009 | Can a nonidentity encoding between different formula languages preserve derivations and Kripke forcing? | [Formal experiment](docs/experiments/009-nonidentity-translation.md) |
| 010 | Can proof-preserving interpretations carry semantic certificates that compose and reject genuine mismatches? | [Formal experiment](docs/experiments/010-semantic-certificates.md) |
| 011 | Can a bounded world map and nonidentity formula translation preserve proofs and truth across different model classes? | [Formal experiment](docs/experiments/011-model-translation.md) |
| 012 | Do signature-indexed sentence renaming and model reducts satisfy the established institution laws? | [Formal experiment](docs/experiments/012-signature-satisfaction.md) |
| Gate A | What changes between Isabelle/ZF and a hereditarily finite model? | [Evidence and limitations](research/gates/a/README.md) |
| Gate B | How does countable choice establish `ω ↪ A` for nonfinite `A`? | [Formal result and open negative case](research/gates/b/README.md) |

For Gate B, the checked positive result is:

```text
ZF + ACω ⊢ ∀A. ¬Finite(A) → (ω ↪ A)
```

This is established mathematics, reproduced in Isabelle/ZF with an explicit
object-level assumption of countable choice.

Independently of Choice, Isabelle/ZF also verifies the **Dedekind-infinity
equivalence**: a set admits an injection from the natural numbers if and
only if it admits an injective, nonsurjective self-map. See the
[verified Gate B bridge](research/gates/b/README.md) and
[successful Isabelle2026 proof replay](https://github.com/blackwell-systems/axiomscope/actions/runs/41291106509). A machine-checked model of ZF
with an infinite Dedekind-finite set has **not** been constructed in this
repository.

## Reproduce the results

Install [Lean 4 with elan](https://lean-lang.org/install/manual/).
The `lean-toolchain`, Mathlib dependency and `lake-manifest.json` pin the
Lean environment.

```sh
lake exe cache get
lake build
python3 -m unittest discover -s scripts/tests -v
python3 scripts/generate_proof_ledger.py --check
python3 scripts/build_comparison.py --check
python3 scripts/check_foundation_gate_b.py --check
python3 scripts/foundation_probe_v02.py --check
python3 scripts/generate_prover_bridge_v03.py --check
```

The Isabelle/ZF tests and prover-export integration are replayed in
[GitHub Actions](.github/workflows/gate-b-isabelle.yml) using the pinned
Isabelle2026 container. They do not follow from running Lean alone.
See the [generated proof ledger](docs/PROOF-LEDGER.md) and
[Gate B evidence](research/gates/b/comparison.json) for precise scope.

## Research documents

- [Foundations v0.1: initial research specification](docs/FOUNDATIONS-v0.1.md)
- [Foundations v0.2: proof-context semantics](docs/FOUNDATIONS-v0.2.md)
- [Foundations v0.3: prover-checked theorem statements](docs/FOUNDATIONS-v0.3.md)
- [Research roadmap](docs/ROADMAP.md)
- [Machine-readable axiom dependency ledger](proofs/dependencies.json)
- [Declaration metadata catalogue](proofs/catalog.json)

## Scientific status at conclusion

**Research concluded; no original mathematical discovery claimed.** The
project verified examples and known mathematical results, including
conditional choice-sensitive constructions, using existing trusted proof
assistants. It also developed and tested experimental interpretation and
proof-context interfaces.

It did **not** establish a distinct foundational theory, a formally checked
negative independence model, a general cross-foundation theorem transport,
or a demonstrated advantage over existing mathematical interpretation
frameworks. The native Isabelle benchmark found the proposed registry's
distinctive research value unproven.

The proofs, source code, workflows, and research records are preserved for
inspection and reproduction. This archival description is not an endorsement
of the original research conjectures or a claim of mathematical novelty.
