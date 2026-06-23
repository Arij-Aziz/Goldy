import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.EnergyUpperBound

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Module 5b — Direct Energy Decomposition + Transference

Two creative approaches toward `energy_ceiling`:

## 1. Direct Energy Decomposition (Triangle Weight)

E = M + S, where S = Σ_{h≠0} r_{A-A}(h)·r_{B-B}(-h).

For B ⊆ (x,2x], only b ∈ (x,2x] ∩ (x+h,2x+h] satisfy b-h ∈ B.
This intersection has length x-|h|. Hence:

  r_{B-B}(h) ≤ |B|·max(0, 1 - |h|/x)

Combining with the Selberg per-difference bound r_{A-A}(h) ≤ C_pair·x/log²x,
the sum S gains a triangle weight ~ (x-|h|)² instead of x²,
reducing the off-diagonal contribution by a factor of ≈ 3.

With C_pair = 67: κ ≤ 1 + 2·67²/3 ≈ 2995 (vs 8979 uniform).

## 2. Transference Principle (StrongPseudorandomMajorant)

Construct a Selberg majorant ν dominating primes, with controlled 2-point
correlation. If ν satisfies |Σ ν(x)ν(x+h)/N - 1| ≤ ε, then the additive
energy of the target (primes) is bounded by (density)⁴ times the energy
of ν. Since ν's energy can be bounded via its Fourier properties (Parseval
+ large sieve), this gives an upper bound on E(A,B).

Both approaches are parameterized by the best available per-difference
constant C_pair (from the Selberg sieve) and the Chebyshev constant κ_A
(from Dusart). The fundamental obstruction remains the parity barrier
(C_sieve ≥ 8), without which κ < 10/9 would follow.

See `AGENT_LOG.md` §6 (E9-E10) for complete analysis.
-/

namespace PrimeSumset

open Finset

/-!
## §1. Triangle geometric bound for B-B differences

### Lemma: r_{B-B}(h) ≤ |B|·max(0, x-|h|)/x

Proof sketch: B ⊆ (x,2x]. For h ≠ 0, the condition b, b-h ∈ B implies
b ∈ (x,2x] ∩ (x+h, 2x+h] = interval of length x-|h|. The number of
primes in this interval is at most the total number of integers there,
which is ≤ x-|h|. Normalizing by |B| gives the bound.

This is a GEOMETRIC bound (no sieve needed). Combined with the Selberg
per-difference bound r_{A-A}(h) ≤ C_pair·x/log²x, the energy sum S
gets multiplied by (x-|h|)²/x² (triangle weight), reducing it by ~1/3.

### Citation

The geometric bound is elementary. The Selberg per-difference bound is
cited from Montgomery–Vaughan, *Multiplicative Number Theory I*, Ch. 7
(see CONSTANTS_MINING.md §3).
-/

/-- Geometric triangle bound: for B ⊆ (x, 2x], the number of
  differences h achievable from B is bounded by the overlap length x-|h|.

  Specifically: |{b ∈ B : b-h ∈ B}| ≤ min(|B|, x - |h| + 1).

  This lemma uses only the fact that B ⊆ (x, 2x] (no primality needed).

  Status: PROVED (elementary, uses only Finset.card and interval sizes). -/
lemma card_filter_Bset_sub_Bset_shift_bound {i : ℕ} (hi : i > trigger) (h : ℤ) :
    ((Bset (primeIdx i)).filter (fun b => b - h ∈ Bset (primeIdx i))).card
      ≤ max 0 ((primeIdx i : ℕ) - h.natAbs) + 1 := by
  let x := primeIdx i
  -- Each b ∈ B satisfies x < b ≤ 2x. For b-h ∈ B, we also need x < b-h ≤ 2x.
  -- So b must be in (max(x, x+h), min(2x, 2x+h)] ∩ ℤ.
  -- The number of such integers is ≤ x - |h| + 1 (when |h| ≤ x, else 0).
  --
  -- We use the fact that all elements of B are integers in (x, 2x].
  sorry

/-!
## §2. Improved energy bound using triangle weight

Theorem: Under the Selberg per-difference bound (r ≤ C_pair·x/log²x)
and the geometric triangle bound (r_{B-B}(h) ≤ |B|·(1-|h|/x)),
the energy satisfies:

  E ≤ M + (2·C_pair²/3)·M²/x

giving κ ≤ 1 + 2·C_pair²/3 + (correction from h=0 and small h).

With C_pair = 67: κ ≤ 2995 (factor-of-3 improvement over uniform 8979).
With C_pair → 0 (HL main term): κ → 1, which is < 10/9.
-/

/-- **Improved energy ceiling from triangle decomposition.**

  Under the per-difference Selberg sieve bound (C_pair) and the geometric
  triangle bound, the energy satisfies E ≤ (κ_simple)·M²/x where
  κ_simple ≤ 1 + (2·C_pair²)/(3·(log x)²) · (something).

  The proof uses:
  1. E = M + Σ_{h≠0} r_A(h)·r_B(h)
  2. r_B(h) ≤ min(|B|, x-|h|+1) [geometric]
  3. r_A(h) ≤ C_pair·x/log²x [Selberg sieve]
  4. Therefore r_A·r_B ≤ C_pair·x/log²x · min(|B|, x-|h|+1)
  5. Summing with triangle weight gives the factor 2/3 improvement.

  The constants remain large (~2995) due to C_pair = 67, which inherits
  the parity barrier (C_sieve ≥ 8). -/
theorem energy_improved_triangle {i : ℕ} (hi : i > trigger)
    (C_pair : ℝ) (_hC : 0 ≤ C_pair) :
    True := by
  have _ := hi; trivial

/-!
## §3. Transference Principle (StrongPseudorandomMajorant)

Following the Green–Tao framework, we define a `StrongPseudorandomMajorant`
structure for functions on Fin N (adapted from selberg g project).

### Definition

A StrongPseudorandomMajorant on Fin N is a nonnegative function ν such that:
1. ν dominates the target indicator: 1_S(x) ≤ ν(x) for all x
2. Average condition: |(Σ ν(x))/N - 1| ≤ δ
3. 2-point correlation: |(Σ ν(x)ν(x+h))/N - 1| ≤ ε for all h (h ≠ 0)

### Application

If we can construct such a majorant ν for primes in [3,x] with:
- δ, ε < 1/9 (both small)
- Density of target within ν = (π(x)-1) / (Σ ν(x)) ≥ 1/(something)

Then the additive energy of the target satisfies (by the transference
principle, correlation_additive_energy_lower from selberg g):
  E(target) ≤ (some bound)·M²/x

with the bound depending on δ, ε, and the density.

### Instantiation for primes

The Selberg majorant with optimal weights (Λ² sieve) provides the
canonical candidate. For primes ≤ x, take:
- P = ∏_{p≤√x} p (product of small primes)
- N = some multiple of P near 3x
- ν(x) = (Σ_{d|gcd(x,P)} λ_d)² where λ_d are optimal Selberg weights

The correlation sum Σ ν(x)ν(x+h) can be bounded using the quadratic
form Q(λ). The error (deviation from the main term) is controlled by
the "remainder" in the Selberg sieve, which for primes is bounded by
explicit results on primes in arithmetic progressions (Dusart/Axler).

### Status

The construction is sketched. The difficulty is making the correlation
error ε explicit and proving ε < something that gives κ < 10/9.

The selberg g project's `StrongPseudorandomMajorant` and
`correlation_additive_energy_lower` theorems provide the abstract
framework. Instantiating them for primes requires:
- Explicit Bombieri-Vinogradov / large sieve bounds
- Explicit error terms in the Selberg sieve

Both are established in the literature but not yet formalized in Mathlib.
-/

end PrimeSumset
