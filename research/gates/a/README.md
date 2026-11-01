# Gate A — a real difference in foundational assumptions

## Claim, at the right level

**The proposition:** the existence of an *inductive set*, containing the
empty set and closed under the von Neumann successor operation.

| Checked presentation | Source | Exact formal status | What is *not* established |
| --- | --- | --- | --- |
| Isabelle/ZF (Isabelle/FOL) | `ZF_Base.infinity` | Explicit **axiom** `0 ∈ Inf ∧ (∀y∈Inf. succ(y) ∈ Inf)` | This is not an independent model or consistency proof of ZF |
| AFP `ZFfin` (Isabelle/HOL) | `L_fin.fin`, inherited by `ZFfin` | Explicit **locale assumption** negating the existence of an inductive set | Not an Isabelle/FOL theorem disproving its axiom |
| AFP model `ZFfin_HF` | `interpretation zfhf: ZFfin "(\<^bold>\<in>)"` | Completed **locale interpretation proof** on hereditarily finite sets | Not a formal translation between Isabelle/FOL and Isabelle/HOL |

The AFP model is a meaningful strengthening of a mere assumption list:
it shows that the finiteness theory's requirements have a formal
realization in HF *inside Isabelle/HOL*. It does **not** show that the
two formalizations have been related by a proved interpretation of
their different host logics.

## Source of truth and evidence levels

The [machine-readable manifest](manifest.json) pins the full Git
commit and Git blob ID of **five actual Isabelle source files**.
The [comparison](comparison.json) is generated from that manifest
only after checking exact declaration shapes, locale inheritance,
session dependencies, and the HF model proof's source anchors.

`python3 scripts/check_foundation_gate_a.py --check` re-fetches all
five files from these immutable Git revisions and checks their content
hashes and declarations. This is a **source/provenance check**, not a
theorem prover or kernel verification. The output deliberately says
`isabelle_replay: NOT_RUN_BY_SOURCE_CHECKER`.

The [upstream AFP entry](https://devel.isa-afp.org/entries/ZF_finite.html)
reports a successful build for its own Mercurial revisions. Those
short revisions are documented separately and **must not be treated as
cryptographically identical to the Git mirror pins**.

A separate GitHub Actions workflow,
[Gate A — Isabelle kernel replay](../../../.github/workflows/gate-a-isabelle.yml),
checks out AFP 2026 at the pinned Git revision, runs the actual
Isabelle2026 `ZF` session, then runs AFP's `ZF_finite` session
(including `HereditarilyFinite`). Its successful run, if available,
is **the proof replay**, and its logs are uploaded as evidence.
The Isabelle2026 release image is pinned by version tag, not by
container manifest digest; this is a remaining supply-chain limitation.

## Reproduce source evidence

```sh
python3 -m unittest scripts.tests.test_foundation_gate_a -v
python3 scripts/check_foundation_gate_a.py --check
# Intentional update after changing verified sources:
python3 scripts/check_foundation_gate_a.py --write
```

## Pass/fail assessment

Gate A requires (1) pinned source integrity and structural checks,
(2) successful independent Isabelle session builds, and
(3) provenance distinguishing explicit axioms, locale assumptions,
and proved interpretations. Source inspection alone does **not**
meet this bar.

If all pass, AxiomScope has shown a *reproducible reporting workflow*:
a cross-source evidence comparison with provenance. This is an
engineering smoke test only; the fundamental distinction is already
well established in the published Isabelle/AFP literature.

**Gate B remains unresolved:** comparing Dedekind infinity across a
choice-free model and a choice-bearing foundation requires genuine
set-theoretic interpretation and consistency evidence. Gate A alone
does not advance that mathematical result.

## Next decision

Do not start another exploratory proof until the specific Gate A
build result has been recorded and assessed against the capabilities
AFP already supplies. If AxiomScope is merely duplicating AFP's
theory browser and build provenance, report *no distinctive tooling
value* and pivot.
