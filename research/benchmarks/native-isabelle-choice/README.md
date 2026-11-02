# Research gate — native Isabelle versus AxiomScope witness reporting

## The decision being tested

**Null hypothesis:** AxiomScope's existing assumption/witness lookup does
not yet provide a mathematical analysis capability beyond what native
Isabelle/ZF proofs and their recorded dependencies already support.

This gate is explicitly **adversarial**. Its purpose is to decide whether
to extend AxiomScope's assumption-analysis architecture, not to increase
the experiment count or restate existing proofs as discoveries.

## Existing mathematical proof chain

The test is anchored in actual kernel-replayed Isabelle/ZF theorems:

| Stage | Named theorem | Meaning |
| --- | --- | --- |
| Individual finite witnesses | `infinite_has_finite_injections` | An infinite set admits each finite injection separately, in ZF |
| Selection family | `countable_choice_finite_injection_family` | The explicit `ACω` assumption enables a simultaneously selected family |
| Combined choice route | `countable_choice_selects_all_finite_injections` | Applies the choice proposition to finite witness candidates |
| Union of selected ranges | `selected_union_infinite` | Given the *selected family*, the union is infinite, without applying `ACω` again |
| Injection extraction | `selected_union_has_nat_injection` | A supplied family gives a countable injection |
| Final positive result | `countable_choice_infinite_has_nat_injection` | Infinite `A` + explicit `ACω` implies `ω ↪ A` |
| Alternative route | `wellorderable_infinite_has_nat_injection` | Local well-orderability supplies a separate sufficient route |

The critical distinction is:

```text
∀ n∈ω, ∃ f_n ∈ inj(n,A)     does not itself yield
∃ F, ∀ n∈ω, F(n) ∈ inj(n,A)
```

The second step needs a justified selection principle or explicit
selected family. The source files already encode this distinction.
The experiment measures *what can be recovered from prover evidence*;
it does **not** prove that `ACω` is the weakest possible assumption.

## Baseline run

[`GateB_NativeBaseline.ML`](../../research/gates/b/GateB_NativeBaseline.ML)
uses native Isabelle2026 APIs:

- `Thm_Deps.thm_deps` — immediate named dependencies.
- `Proofterm.fold_body_thms` on `Thm.proof_body_of` — transitive
  named theorem dependencies (subject to available proof recording).
- `Thm_Deps.all_oracles` — proof-oracle dependencies.

No dependency edge is invented by the Python consumer; it only validates
and summarizes the native Isabelle-exported TSV.
The CI run must build the same `GateB_ZF` Isabelle/ZF session, preserve
the v0.3 elaborated theorem signature checks, and export the native
baseline plus a JSON comparison report as artifacts.

Relevant Isabelle documentation:
[Isar Reference](https://isabelle.in.tum.de/dist/library/Doc/Isar_Ref/Outer_Syntax.html)
and [Implementation Manual](https://isabelle.in.tum.de/dist/Isabelle2025/doc/implementation.pdf).

## AxiomScope side

The existing
[Foundations v0.2 applicability engine](../../docs/FOUNDATIONS-v0.2.md)
already answers five manually registered scenarios:

- Infinite `A` alone: no *registered* sufficient witness.
- Infinite `A` + `ACω`: countable-choice witness applicable.
- Infinite `A` + local well-orderability: alternative witness applicable.
- An injection from `ω` supplied: ZF nonfiniteness consequence applicable.
- Both extra contexts supplied: multiple known witnesses preserved.

The v0.3 bridge checks elaborated Isabelle propositions against source
contracts. It does **not** automatically extract a complete proof-witness
graph, prove assumptions minimal, or produce countermodels.

## Verdict criteria

| Question | Pass condition |
| --- | --- |
| Proof/evidence integrity | Native export comes from kernel-replayed Isabelle theorem objects |
| Correct assumptions | Distinguish `ACω` from a supplied finite witness family |
| Negative reliability | Never claim ZF independence from a missing registered witness |
| Native comparison | Measure immediate and transitive named theorem coverage and oracles |
| AxiomScope differentiation | Find a useful, independently verified result unavailable from native reports at comparable scope |

**Current decision rule:** If native proof dependencies already identify
the mathematical construction chain and AxiomScope adds only a
manually registered context lookup, the project has **not** justified
expanding this architecture.

No claim is made that a transitive dependency graph automatically
characterizes the minimal set of *logical assumptions*, nor that the
presence of an `ACω` premise proves necessity.

## Next action after the benchmark

The strongest option is to choose a second **independent** mathematical
construction and a narrowly stated task that existing proof assistants
cannot already perform. If such a gap cannot be demonstrated, preserve
AxiomScope as a verified research corpus and pivot the mathematical
program instead of adding another layer of interpretation tooling.

The benchmark artifact is generated by
[`benchmark_native_gate_b.py`](../../scripts/benchmark_native_gate_b.py).
The report's `distinguishing_capability_demonstrated` is deliberately
false until independent evidence establishes otherwise.
