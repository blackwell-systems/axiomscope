# Foundations v0.3 — prover-checked theorem signatures

**Status:** experimental integration, not a new mathematical foundation.

## Motivation

The v0.2 scenario engine interprets quoted \`assumes\` and \`shows\` clauses
from Isabelle source. That is a useful prototype but **a source parser
does not prove that its strings equal the elaborated theorem**. This
milestone introduces a separate Isabelle-side correspondence check.

## Verification chain

1. The v0.2 source parser extracts the three registered Gate B theorem
   signatures. Each theorem is already classified as Isabelle kernel-verified
   by the existing manifest, which does not promote the published-only
   symmetric-model counterexample.
2. \`scripts/generate_prover_bridge_v03.py --check\` checks that
   \`GateB_ProverBridge.ML\` is exactly generated from those current
   signatures. No manually edited per-theorem expected propositions.
3. The Isabelle/ZF session builds \`GateB_ProverBridge.thy\`. For each
   registered theorem, Isabelle/ML retrieves its actual \`thm\` object,
   constructs a candidate proposition from the source premises and
   conclusion, compares it with \`Thm.prop_of\`, and checks the observed
   number of \`Thm.prems_of\` premises. Any mismatch aborts the build.
4. The theory exports a TSV of **prover-rendered premises/conclusion** via
   Isabelle session exports. The exported content is produced from the
   actual theorem objects, not copied from the Python source parser.
5. \`scripts/check_prover_bridge_v03.py\` consumes the export, rejects
   incomplete/duplicate/unsupported entries, and emits a scenario report
   augmented with the prover-rendered statements. CI archives these files.
   The report distinguishes *applicable registered proof* from mere absence
   of a proof.

The resulting assurance is conditional on Isabelle's own theorem objects,
the source-to-goal semantics, and the trustworthiness of the prover build.

## What changes versus v0.2?

Before: the Python report derived premise counts and printable statements
entirely from source text.

After: Isabelle checks that the reconstructed source proposition matches
the elaborated theorem. The consumer also includes separately
prover-rendered terms and the observed premise count. A mismatched
source declaration is caught **by Isabelle**, and CI cannot continue
using an unverified report.

This is a narrow but material advance in *evidence provenance*.

## What this does NOT achieve

- The ML export provides **declaration premises**, NOT transitive
  dependencies on lemmas, definitions, or axioms used inside the proof.
- \`Pattern.matches\` checks theorem shape up to schematic instantiation;
  it is not a proof of representation independence or a general semantic
  equivalence procedure.
- The scenario engine still uses manually assigned semantics for
  \`nonfinite_A\`, \`AComega\`, \`wellorder_A\`, and \`nat_injection_A\`.
- The three theorem IDs and goals remain registered by hand; arbitrary
  theorems are not discovered.
- Isabelle/ZF proof statements are not transported to Lean, HOL, or ZFfin.
- The negative Cohen symmetric-model benchmark remains **published-only**
  within AxiomScope.
- No new mathematical theorem or novel tool capability is claimed.

## Comparison and next research gate

This approach should be evaluated against standard Isabelle theorem
exports and dependency tools before extending it. Isabelle can export
elaborated theory content, and \`Thm.proof_body_of\` provides a route
toward proof-dependency information. Lean also supports its own axiom
inspection and declaration introspection.

**Acceptance for this milestone:** the new Isabelle theory builds,
a nonempty session export is created, the exported rows are consumed
into a deterministic scenario result, and the existing Lean and Gate A
workflows remain green.

**Next falsifiable experiment:** use Isabelle's native proof-body
information to derive immediate named theorem dependencies (if retained
for these proofs) and compare the result to the existing manually
registered provenance. Measure coverage, mismatches, and limitations.
If native tooling already answers the research question adequately,
pivot instead of claiming an invention.

## Reproduction

The Gate B GitHub Actions workflow runs the full chain under the pinned
\`makarius/isabelle:Isabelle2026\` container:

    python3 scripts/generate_prover_bridge_v03.py --check
    python3 -m unittest scripts.tests.test_prover_bridge_v03 -v
    # Isabelle2026: build -d /theories GateB_ZF
    # Isabelle2026: export -n -d /theories -O /exports \
    #   -x "GateB_ZF.GateB_ProverBridge:axiomscope_theorems.tsv" GateB_ZF
    python3 scripts/check_prover_bridge_v03.py \
      --export isabelle-exports/GateB_ZF.GateB_ProverBridge/axiomscope_theorems.tsv \
      --output isabelle-exports/prover-certified-scenarios.json

This is an integration test tied to Isabelle2026, not a standalone
Python verification of mathematical correctness.
