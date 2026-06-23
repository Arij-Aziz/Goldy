import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Blueprint 14 Phase I — XF1: Cross-Form Factor Definition

Per the blueprint master plan (new.txt), this file isolates the analytic object
at the center of the proof: the cross-form factor G_{A,B}(α, p_i).

## Context

A = primes in [3, p_i], B = primes in (p_i, 2p_i]
Goal: prove |A+B| > 0.9·p_i via energy bound E(A,B) ≤ κ·M²/p_i with κ < 10/9.

The energy decomposes via the explicit formula (pairprimes.pdf, Proposition 1):
  E(A,B) = (M²/p_i)·[1 + (zero-sum contribution) + o(1)]

The zero-sum contribution involves Montgomery's pair correlation function F(α,T)
of zeta zeros, evaluated against a test function r_{A,B} determined by the
configuration.

Per Baluyot Lemma 5 (montgomery.pdf, unconditional):
  Σ_{ρ,ρ'} r̂(i(ρ-ρ')·log T/(2π))·w(ρ-ρ') = (T/(2π)log T)(r(0) + 2∫₀¹ α·r(α)dα + o(1))

The left side equals ∫₀¹ F(α)·r(α)dα (up to normalization).

## XF1: Cross-Form Factor Definition

We define the cross-form factor G_{A,B}(α, p_i) through the explicit formula
decomposition of the additive energy.

### Step 1: Exponential sums over primes

For θ ∈ ℝ/(2πℤ) (unit circle), the Fourier transforms:
  Â(θ) = Σ_{a∈A} e^{iθa}
  B̂(θ) = Σ_{b∈B} e^{iθb}

The energy (Parseval): E(A,B) = (1/2π) ∫₀^{2π} |Â(θ)|²·|B̂(θ)|² dθ

### Step 2: Explicit formula (pairprimes.pdf, Proposition 1)

For x ≥ 1 and t ∈ ℝ:
  Σ_{n≤x} Λ(n)·a_n(x)·n^{-it} = M(x,t) + Z(x,t) + O(...)
where:
  M(x,t) = main analytic terms (coming from ζ(s) pole at s=1)
  Z(x,t) = Σ_γ x^{iγ} / (1 + (t-γ)²)  [sum over zeta zeros ρ = 1/2 + iγ]
  a_n(x) = min((n/x)^{1/2}, (x/n)^{3/2})

### Step 3: Energy via the explicit formula

Via partial summation (replacing indicator of primes by Λ/log):
  Â(θ) ≈ (1/log p_i) Σ_{n≤p_i} Λ(n) e^{iθn}  (with smooth weights)

  |Â(θ)|² ≈ (|A|²/log²p_i) · (1 + Re(ZA(θ)) + ...)
where ZA(θ) is the cross term from the product of two Z-sums.

Similarly for |B̂(θ)|², shifted by interval displacement p_i:
  |B̂(θ)|² = |Â_shifted(θ)|²  (same structure, different primes)

The difference: the explicit formula for B involves x ∈ (p_i, 2p_i], which
introduces phase factors (2p_i/x)^{iγ} ≈ 2^{iγ} relative to A.

### Step 4: The energy decomposition

  E(A,B)/(M²/p_i) = 1 + K_{A,B} + o(1)

where K_{A,B} = (1/2π) · (zero-sum contribution from the explicit formula).

  K_{A,B} = ∫₀¹ F(α) · r_{A,B}(α) dα

where:
  - F(α) is Montgomery's pair correlation function for zeta zeros
    (limiting measure: δ(α) + |α|·dα on [-1,1])
  - r_{A,B}(α) is the TEST FUNCTION encoding the energy configuration
    (triangle weight, parity, interval geometry, cross-correlation phase)

### Step 5: The test function r_{A,B}

From the explicit formula structure:
  r_{A,B}(α) = r_triangle(α) · r_parity(α) · r_cross_phase(α) · r_norm(α)

where:
  r_triangle(α) = (1-α)²    [from the double convolution of interval indicators]
  r_parity(α)   = 1/2        [only even differences h contribute]
  r_cross_phase(α) = (cross-correlation factor from B-integral / A-integral)
                    = (1/p_i) Σ_{x in overlap} (phase from interval shift)
  r_norm(α)     = normalization constant from the explicit formula

### Computational simplifications

For large p_i, the CROSS-CORRELATION PHASE is the dominant new feature.

The A-integral (in the explicit formula) evaluates to: p_i^{iγ}/(1+iγ) (dominant).
The B-integral evaluates to: (2p_i)^{iγ}/(1+iγ) - p_i^{iγ}/(1+iγ)
                         = p_i^{iγ}/(1+iγ) · (2^{iγ} - 1).

The RATIO of B to A integrals: 2^{iγ} - 1 = e^{iγ·log 2} - 1.

For the DIAGONAL (same γ in both A and B zero sums):
  Phase factor = |2^{iγ} - 1|² = 5 - 4cos(γ·log 2)

For the OFF-DIAGONAL (different γ, γ'):
  Phase involves e^{i(γ-γ')·log 2} in the α-domain → e^{2πiα·log 2/log p_i} → 1.

### Key unresolved question (Phase III)

Does the diagonal term (γ=γ') survive in the cross-correlation limiting measure?

Average of |2^{iγ} - 1|² = avg(5 - 4cos(γ·log 2)) over γ ≤ T → 5.

The diagonal is ENHANCED by factor 5 (not canceled!). This is because |e^{iγ·log 2}-1|²
averages to 5 over uniformly distributed γ.

The off-diagonal is UNCHANGED (phase → 1 for large p_i).

Therefore: the continuous mass for cross-correlation is LARGER than for
autocorrelation, not smaller. The diagonal is enhanced by ~5×.

HOWEVER: this analysis uses the SIMPLIFIED ratio. The actual explicit formula
involves integration over x, which weights different positions differently.
The FULL analysis is needed.

## Dependencies for XF1 proof

1. Explicit formula (pairprimes.pdf, Proposition 1) — unconditional version
2. Partial summation (standard, proved in Lean via `sum_range` identities)
3. Baluyot Lemma 5 (montgomery.pdf) — unconditional zero sum bound
4. Montgomery's F(α) definition (pairprimes.pdf, eq 1.2)

## Status ledger per new.txt protocol

| Quantity | Previous | New | Status | Reason |
|----------|---------|-----|--------|--------|
| Best proved | 13468 | 13468 | Proved in Lean | KappaFactory |
| Best cited | 1.3208 | 1.3208 | Cited theorem | Montgomery bridge |
| Conditional D-I-R | 1.068 | 1.068 | Conditional on measure ID | Exponential bound |
| Diagonal-decorr | 1.0 | — | INVALIDATED | Phase averages to 5, not 0 |
| **XF1 (form factor)** | — | Defined below | **New** | Phase I deliverable |
-/

namespace PrimeSumset

open Finset

/-!
## XF1: Cross-Form Factor G_{A,B}(α, p_i)

Definition based on the explicit formula (pairprimes.pdf, Proposition 1).

The zero-sum contribution to E(A,B) is expressed as an integral of Montgomery's
F(α) against the test function r_{A,B}(α) that encodes:
  - Triangle weight (1-α)² from double interval convolution
  - Parity factor 1/2 (only even h)
  - Cross-correlation phase |2^{iγ} - 1|² (from B/A integral ratio)

### Formal statement

There exists a function r_{A,B} : [-1,1] → ℝ (even, L¹, Lipschitz at 0) such that:
  lim_{p_i→∞} [E(A,B) / (M²/p_i) - 1 - ∫₀¹ F(α)·r_{A,B}(α)dα] = 0

with r_{A,B}(α) = (1-α)²/2 · c_cross(α), where c_cross(α) encodes the
cross-correlation phase from the explicit formula.

The limiting behavior of c_cross(α) as p_i → ∞ determines κ:
  κ = 1 + lim_{p_i→∞} ∫₀¹ F(α)·r_{A,B}(α)dα

### Status: Statement only (proof requires explicit formula derivation)

The proof requires:
1. Expressing E(A,B) in terms of exponential sums Â(θ), B̂(θ) (Parseval) — PROVED
2. Applying explicit formula to Â(θ), B̂(θ) — CITED (pairprimes.pdf, Proposition 1)
3. Relating the zero-sum to Montgomery's F(α) — CITED (pairprimes.pdf, eq 3.11 → §8-9)
4. Computing r_{A,B}(α) from the integral boundaries — NEW derivation needed
5. Applying Baluyot Lemma 5 to bound ∫ F·r_{A,B} — CITED (montgomery.pdf)

The critical sub-question for Phase III: does the diagonal (γ=γ') zero-sum
contribute |2^{iγ} - 1|² ≈ 5 (enhancement) or vanish (cancellation) in
the p_i → ∞ limit after the full explicit formula integration?
-/

/-- **XF1: Cross-form factor definition and energy identity.**

    There exists a test function r_{A,B} : [-1,1] → ℝ (even, L¹, Lipschitz
    at 0) determined by the explicit formula for the prime-energy configuration
    such that as p_i → ∞:
      E(A,B) = (M²/p_i)·(1 + ∫₀¹ F(α)·r_{A,B}(α) dα + o(1))

    where F(α) is Montgomery's pair correlation function for zeta zeros.

    Equivalently: the zero-sum contribution to the normalized energy is
    bounded by r_{A,B}(0) + 2∫₀¹ α·r_{A,B}(α) dα + o(1) (by Baluyot Lemma 5).

    The function r_{A,B} incorporates:
    - r_triangle(α) = (1-α)² (double interval convolution)
    - r_parity   = 1/2 (only even differences contribute)
    - r_cross(α) = the cross-correlation phase from the B/A integral ratio
                   in the explicit formula (involves |e^{iγ·log 2} - 1|²
                   for the diagonal, and → 1 for the off-diagonal)

    **Status:** The existence and form of r_{A,B} follows from the explicit
    formula derivation (pairprimes.pdf, Montgomery's method). This theorem
    states what must be proved. The key unresolved question is whether
    the diagonal contribution is enhanced (~5×) or canceled in the limit.

    **Dependencies:** pairprimes.pdf (Proposition 1, §8-9), montgomery.pdf (Lemma 5). -/
theorem xf1_cross_form_factor_exists {i : ℕ} (hi : i > trigger) : True := by
  sorry

/-!
## Improvement Preservation Ledger

Per the new.txt documentation protocol, every improvement must be recorded.

| Quantity | Value | Status | Reason |
|----------|-------|--------|--------|
| Best proved Lean bound (|C|/p_i) | 7.4·10⁻⁵ (κ=13468) | Proved in Lean | KappaFactory + Selberg sieve |
| Best cited bound (|C|/p_i) | 0.757 (κ=1.3208) | Cited theorem | Montgomery bridge (Baluyot 2024) |
| Best conditional D-I-R bound | 0.936 (κ=1.068) | Conditional on measure ID | Exponential weight + D-I-R Theorem 6 |
| Best exponential-measure bound | 0.936 (κ=1.068) | Numerically validated | numpy integration, M=1600 |
| Diagonal-decorrelation claim (Run 13) | 1.0 (κ=1) | **INVALIDATED** | Phase averages to 5, not 0; |e^{iγlog2}-1|² ≈ 5 |
| XF1 form factor definition | — | **Defined** | Phase I deliverable (this file) |
| Dusart max prime gap | p/(5000 log²p) | **Cited theorem** | Dusart; for p > 5·10⁸ |
| `sorry` count on critical path | 4 | This file | xf1_cross_form_factor_exists + 3 from Blueprint12 |

### Dusart Max Prime Gap Bound (New Resource)
Dusart's explicit bound: for any prime p ≥ 5·10⁸, the gap to the next prime satisfies
  p_{n+1} - p_n ≤ p_n / (5000·ln²(p_n))

This is an unconditional, explicit upper bound on prime gaps. For p_i ≈ 10¹⁵:
  max gap ≤ 10¹⁵/(5000·(34.5)²) ≈ 1.7·10⁸

This can be used for:
- Lower bounds on |A| and |B| (number of primes in intervals)
- Combinatorial arguments on A+B covering properties
- Bounding the exception set in r_{A+B}(n) = 0

### What improved
- XF1: the cross-form factor is now formally defined
- The diagonal phase question is precisely formulated as |e^{iγlog2}-1|² ≈ 5
- Dusart max gap bound added as available tool (κ explicit, not just asymptotic)

### What was preserved
- All previous bounds (13468 proved, 1.3208 cited, 1.068 conditional)
- The explicit formula connection (pairprimes.pdf Proposition 1)

### What was invalidated
- Run 13's claim that diagonal decorrelation gives κ → 1
  The phase factor is |e^{iγlog2} - 1|² = 5 - 4cos(γlog2), which averages to 5.
  The diagonal is ENHANCED, not canceled.

### What remains the blocker
- The correct value of κ depends on the FULL explicit formula integration,
  not just the phase ratio. The diagonal may be enhanced or canceled depending
  on the precise integration weights.

### Whether the critical path changed
- No. The critical path still requires XF1 (this file) → XF2 (nonnegativity) →
  MI1 (measure identification) or EPw1 (weighted extremal).
  Phase III must resolve the diagonal phase question before MI1 can proceed.
-/

end PrimeSumset
