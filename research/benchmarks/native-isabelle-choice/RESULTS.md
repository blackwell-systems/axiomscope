# Benchmark outcome: no distinctive capability established

**Decision:** do not expand the current assumption/witness registry as an original mathematics research program without a new, independently demonstrated capability.

**Source:** [Isabelle2026 CI run](https://github.com/blackwell-systems/axiomscope/actions/runs/41348268656). See [machine-readable observations](observed-isabelle2026.json).

| Gate B theorem | Immediate dependencies | Transitive dependencies | Immediate local references | Transitive local references |
| --- | ---: | ---: | ---: | ---: |
| Individual finite witnesses | 70 | 490 | 0 | 0 |
| Countable choice family | 34 | 233 | 1 | 2 |
| Selected finite family | 5 | 503 | 2 | 4 |
| Selected union infinite | 36 | 402 | 1 | 1 |
| Selected family to injection | 5 | 915 | 3 | 11 |
| Countable choice to injection | 19 | 992 | 4 | 19 |
| Wellorderability route | 18 | 399 | 1 | 1 |

The seven graphs contain **12 immediate and 38 transitive local named references**, with no oracle dependencies reported.

Native Isabelle directly links the finite-injection existence proof to the countable-choice family selection proof, and links the final positive theorem to the selected-union and injection-extraction constructions. AxiomScope's existing registered-context report does not demonstrate an advantage over these machine-recorded dependencies.

**Scope:** the native graph is not a proof of minimal axioms or independence, and the missing Cohen symmetric countermodel remains unverified in our repository. This benchmark does not establish complete feature equivalence between Isabelle and AxiomScope. It establishes only that no distinctive analysis capability was demonstrated in this test.

**Next gate:** select an independent mathematical construction and define an objectively testable improvement over the prover's native outputs. If no such gap exists, redirect the mathematical research to an actual theorem or model construction.
