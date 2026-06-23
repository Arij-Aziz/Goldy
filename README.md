[![Build](https://github.com/Arij-Aziz/Gold_dense/actions/workflows/build.yml/badge.svg)](https://github.com/Arij-Aziz/Gold_dense/actions/workflows/build.yml)
# PrimeSumset: A New Explicit Positive Density for the Prime Sumset

Machine-verified proofs reducing a Goldbach-type density theorem to explicit additive energy bounds, formalized in Lean 4 using Mathlib. The project strictly separates an unformalized analytic bound (the "formalization gap") from a fully machine-verified algebraic superstructure (the "research ladder").

`Challenge.lean` (root) is a statement-only mirror for the comparator check; its `sorry` proofs are intentional placeholders and are not part of the verified proof chain. To see the true axiom footprint of the active dependency tree, compile `RequestProject/Audit.lean`.

## What This Project Is

This project formalizes the structural and combinatorial reductions required to prove that the sumset $C = A + B$ (where $A$ and $B$ are disjoint sets of primes) has strictly positive density.

The project is split into two rigorously separated halves:

1. **The Conditional Main Result:** A proof that $|C| > 0.904x$ and that the number of even Goldbach exceptions in $(x, 3x]$ is $< 0.096x$, **conditional** on a single analytic `sorry` (`energy_ceiling`).
2. **The Unconditional Research Ladder:** A 100% machine-verified reduction showing that *any* explicit sieve upper bound implies a positive density for the sumset. By plugging in literature-derived constants (Dusart 2010, Selberg sieve), the project extracts an **unconditional, fully proven positive density** of $h_0 = 1/13468$.

## What This Project Is Not

- **Not an unconditional proof of the $0.904$ density.** The target $\kappa \le 1.1053$ energy ceiling relies on unformalized literature (Das–Ismoilov–Ramos 2025 reproducing-kernel bounds and the Goldston–Montgomery bridge). The codebase isolates this as a single explicit `sorry`.
- **Not a proof of the Goldbach Conjecture.** We are counting representations and bounding the exceptional set of even numbers in a specific interval $(x, 3x]$, not proving that every even number is representable.
- **Not a bypass of the Parity Barrier.** The unconditional branch of the project hits the classical parity barrier (yielding the constant $1/13468$). The theoretical jump to $0.904$ depends entirely on the isolated formalization gap.
- **Not an asymptotic result.** The bounds are formulated explicitly for a fixed astronomical threshold ($x = p_i$ for $i > 10^{15}$).
- **Inactive files are scaffolding only.** Files not imported in `RequestProject/Main.lean` (such as `TaoGafniApproach.lean` or `Blueprint12.lean`) are exploratory scaffolding and are not part of the proof chain.

## Main Results

**Phase I & II — The Target Density & The Analytic Gap**
(`RequestProject/MainTheorem.lean`, `RequestProject/Goldbach.lean`, `RequestProject/EnergyUpperBound.lean`)

Conditional on the isolated formalization gap `energy_ceiling` (which posits $E(A,B) \le 1.1053 M^2/x$), we prove:
* `sumset_card_gt_904`: The distinct sumset satisfies $|A + B| > 0.904x$.
* `goldbach_exception_bound`: The number of even integers $N \in (x, 3x]$ with $r_{A+B}(N) = 0$ is strictly less than $0.096x$.

**Phase III & IV — The Unconditional Research Ladder & Difference Sieve**
(`RequestProject/ResearchLadder.lean`, `RequestProject/DifferenceSieve.lean`)

Fully machine-checked algebraic reductions converting raw prime-pair upper bounds into additive energy bounds:
* `per_diff_of_pair_bound`: Converts $r \le C_{pair} x / \log^2x$ and $|A| \ge x / (\kappa_A \log x)$ into the required per-difference energy bound $r \le (C_{pair} \kappa_A^2) L^2 / x$.
* `sumset_card_gt_const_of_sieve_ceiling`: Proves that any explicit sieve constant $\kappa$ yields $|A+B| > hx$ for all $h < 1/\kappa$.

**Phase V — First Fully-Cited Unconditional Density**
(`RequestProject/ConcreteConstants.lean`)

By instantiating the difference sieve with literature constants ($C_{pair} = 67$, $\kappa_A = 1$), we unconditionally prove:
* `sumset_ge_cited_density`: $|A+B| \ge (1/13468)x$.

**Phase VI — Minor-Arc Integration**
(`RequestProject/MinorArc.lean`)

* `minor_arc_energy_bound`: An unconditional proof of Parseval's identity tying the combinatorial additive energy exactly to the minor-arc $L^2$-integral of the power spectra.

## Scope of Novelty

We are not aware of the following appearing in the literature in this form:
1. The explicit packaging of the difference sieve into an additive energy bound within an interactive theorem prover.
2. The rigorous, machine-checked repackaging of the distinct sumset cardinality directly into a localized Goldbach exceptional-set bound (`goldbach_exception_bound`).

## Axiom Audit

The project dependency tree has been strictly audited via `RequestProject/Audit.lean`. The separation between the conditional main results and the unconditional reductions is absolute. 14 theorems are `sorry`-free; 1 is an explicit `sorry` (the analytic formalization gap); 4 conditionally inherit `sorryAx`.

```text
── Phase I: Target Main Results (Conditional) ─────────────────────────────
sumset_card_gt_904                          → [propext, Classical.choice, Quot.sound, sorryAx]
overlap_bound                               → [propext, Classical.choice, Quot.sound, sorryAx]
goldbach_density                            → [propext, Classical.choice, Quot.sound, sorryAx]
goldbach_exception_bound                    → [propext, Classical.choice, Quot.sound, sorryAx]

── Phase II: The Formalization Gap ────────────────────────────────────────
energy_ceiling                              → [propext, Classical.choice, Quot.sound, sorryAx]

── Phase III & IV: The Research Ladder (Unconditional) ────────────────────
sumset_card_ge_of_sieve_ceiling             → [propext, Classical.choice, Quot.sound]
sumset_card_gt_const_of_sieve_ceiling       → [propext, Classical.choice, Quot.sound]
per_diff_of_pair_bound                      → [propext, Classical.choice, Quot.sound]
energy_ceiling_of_prime_pair_sieve          → [propext, Classical.choice, Quot.sound]
sumset_card_ge_of_prime_pair_sieve          → [propext, Classical.choice, Quot.sound]
sumset_card_gt_of_prime_pair_sieve          → [propext, Classical.choice, Quot.sound]
sumset_card_gt_of_prime_pair_sieve_concrete → [propext, Classical.choice, Quot.sound]

── Phase V: Unconditional Explicit Densities ──────────────────────────────
sumset_ge_cited_density                     → [propext, Classical.choice, Quot.sound]

── Phase VI: Minor-Arc Integration ────────────────────────────────────────
energy_eq_minor_arc_integral                → [propext, Classical.choice, Quot.sound]
minor_arc_energy_bound                      → [propext, Classical.choice, Quot.sound]

```

## AI Assistance

This project is a human–AI collaboration. Mathematical direction, structural architecture, the decision to isolate the analytic gap, and theorem statements were guided by the human author. AI assistance was utilized for tactic synthesis, algebraic massaging, and infrastructure boilerplate. All mathematical claims were reviewed and verified by the human author.

## Build

```bash
lake exe cache get
lake build

```

Requires Lean toolchain `leanprover/lean4:v4.28.0` (see `lean-toolchain`).

## File Map

```text
RequestProject/
├── Audit.lean                        ← Central #print axioms registry
├── Main.lean                         ← Top-level import for the active build tree
├── MainTheorem.lean                  ← Conditional sumset density theorem
├── Goldbach.lean                     ← Repackaging into Goldbach exceptional set
├── EnergyUpperBound.lean             ← The isolated D-I-R 2025 formalization gap (sorry)
├── ResearchLadder.lean               ← Abstract reduction from energy to density
├── DifferenceSieve.lean              ← Transfer from prime-pair bounds to energy bounds
├── ConcreteConstants.lean            ← Literature instantiation (c_pair = 67)
├── MinorArc.lean                     ← Circle method / Parseval identity
├── AdditiveEnergy.lean               ← Core sumset and energy definitions
├── Definitions.lean                  ← Set A, Set B, and threshold thresholds
├── KappaFactory.lean                 ← Constant extraction utilities
├── ShortInterval.lean                ← Inactive sorry placeholder for Axler short intervals
└── ExplicitCounting.lean             ← Foundational counting lemmas

Challenge.lean                        ← Pure-Mathlib auditable statement file (sorry proofs)
Solution.lean                         ← Minimal entry point importing Main.lean

```

```

```
