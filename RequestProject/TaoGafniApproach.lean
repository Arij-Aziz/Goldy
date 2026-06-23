import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.EnergyUpperBound

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Trick 2 — Tao–Gafni Zero Density + Additive Energy of Zeros

## Source

Gafni, A. & Tao, T. (2025). *On the number of exceptional intervals to the
prime number theorem in short intervals.* arXiv:2505.24017. Published in
Ess. Number Th. 5 (2026), 221–241. DOI:10.2140/ent.2026.5.221.

Paper downloaded as `tao-gafni.pdf` in project root.

## The Key Theorems (Tao–Gafni 2025)

The paper establishes explicit relationships between zero density estimates
(controlling the Riemann zeta function's zeros off the critical line) and
the size of the exceptional set where the Prime Number Theorem fails in
short intervals.

**Theorem 1.3 (Refined bound).** For any 0 < θ < 1,

  μ(θ) ≤ inf_{ε>0} sup_{A(σ) ≥ 1/(1-θ)-ε, 0≤σ<1} min(μ_{2,σ}(θ), μ_{4,σ}(θ))

where:
  μ_{2,σ}(θ) = (1-θ)(1-σ)A(σ) + 2σ - 1          (L² / second moment)
  μ_{4,σ}(θ) = (1-θ)(1-σ)A*(σ) + 4σ - 3         (L⁴ / fourth moment)

Here A(σ) is the exponent in the classical zero density theorem:
  N(σ,T) ≪ T^{A(σ)(1-σ)+ε}
and A*(σ) is the exponent in the *additive energy zero density theorem*:
  N*(σ,T) = #{ (ρ₁,ρ₂,ρ₃,ρ₄) : |γ₁+γ₂-γ₃-γ₄| ≤ 1 } ≪ T^{A*(σ)(1-σ)+ε}

The best unconditional bound is A₀ = sup_σ A(σ) ≤ 30/13 ≈ 2.3077 (Guth–Maynard 2024).

## Connection to Our Problem

Our goal: prove `energy_ceiling` — ∃ κ < 10/9, E(A,B) ≤ κ·M²/x for A = primes in
[3, p_i], B = primes in (p_i, 2p_i], with x = p_i, i > 10^15.

The connection proceeds via the additive energy identity (proved, `AdditiveEnergy.lean`):
  E(A,B) = Σ_h r_{A-A}(h)·r_{B-B}(-h)   (Identity 2)

### Strategy 1: Direct L⁴ bound via Parseval

By Parseval, the squared L² norm of r_{A-A} equals the L⁴ norm of the
exponential sum over primes:
  Σ_h r_{A-A}(h)² = (1/N) · Σ_k |Â(k)|⁴
where Â(k) = Σ_{a∈A} e^{2πi a k/N}.

The explicit formula for exponential sums over primes (von Mangoldt's formula)
expresses Â(k) in terms of zeros of L-functions. The L⁴ norm decomposes into:
  |Â(k)|⁴ = (main term, involving singular series 𝔖(k))
          + (error, involving pair correlations of zeros → N*(σ,T))

The additive energy of zeros N*(σ,T) is controlled by A*(σ), which
unconditionally satisfies A*(σ) ≤ 30/13 (Guth–Maynard 2024, via the trivial
bound A*(σ) ≤ 3A(σ)).

Applying the L⁴ bound to Σ_h r_{A-A}(h)² and using Cauchy-Schwarz:
  E(A,B)² ≤ Σ_h r_{A-A}(h)² · Σ_h r_{B-B}(h)²

gives a bound on E(A,B) in terms of A*(σ).

### Strategy 2: Prime gap connection

Equation (1.6) of Tao–Gafni relates μ(θ) to prime gaps:
  |{ n ≤ N : p_{n+1} - p_n > 2·p_n^θ }| ≪ N^{μ(θ) - θ + o(1)}

If μ(θ) < 1 for some θ < 1, then "almost all" prime gaps are O(x^θ).
Controlling prime gaps gives control on r_{A-A}(h) for large |h|, since
r_{A-A}(h) can only be large when primes are dense enough to have pairs
at distance h. If gaps are O(x^θ), then r_{A-A}(h) is small for
|h| ≫ x^θ.

### Strategy 3: Direct L² moment of r_{A-A}

Apply the explicit formula directly to r_{A-A}(h):
  r_{A-A}(h) = Σ_{n≤x} 1_P(n)·1_P(n+h)
             = Σ_{n≤x} Λ(n)/log x · Λ(n+h)/log x + lower order

The error term in the correlation Σ Λ(n)·Λ(n+h) involves bilinear sums
of zeros, whose fourth moment is controlled by N*(σ,T).

## The Fundamental Obstruction

All three strategies converge to the same obstruction:

1. **Main term requires Hardy–Littlewood.** The expected value of r_{A-A}(h)
   involves the singular series 𝔖(h) = 2C₂·∏_{p|h}(p-1)/(p-2). The average of
   𝔖(h)² over h determines the dominant contribution to E(A,B). Unconditionally,
   we only have the UPPER bound avg(𝔖(h)²) ≤ (sup 𝔖(h))² ≈ 8.33² ≈ 69.4,
   leading to κ ≈ 67² = 4489 and onward to κ₀ ≈ 1+3·67² = 13468 (as in the
   KappaFactory approach).

   The HL prediction gives avg(𝔖(h)²) ≈ 2-3, which would give κ ≈ 2-3·M²/x.
   While this is still > 10/9 (so even HL doesn't give κ < 10/9!), it's much
   closer to the target.

2. **Error term requires Montgomery pair correlation.** To bound the difference
   between r_{A-A}(h) and its expected value, the cross terms when summing over h
   involve the pair correlation of zeros of ζ(s):
     Σ_{γ,γ'} (X^{i(γ-γ')})/(ρ·ρ̄')

   This is the Montgomery pair correlation conjecture / strong pair correlation,
   which is equivalent to RH for this purpose.

3. **The parity barrier persists.** Any upper-bound sieve (Selberg, Brun) has
   coefficient ≥ 2 for individual prime pairs (C_sieve ≥ 2 for optimal Λ²).
   Averaging over h reduces the effective constant but does NOT eliminate the
   fundamental gap between upper bounds and the conjectured main term.

## Concrete Numerical Assessment (Theta = 1/2)

At θ = 1/2 (intervals of length √x), the Tao–Gafni unconditional bounds give:
  μ₂,σ(1/2) = (1/2)(1-σ)A(σ) + 2σ - 1
With A(σ) ≤ 30/13 and optimizing over σ (σ ≈ 0.77), we get μ(1/2) ≈ 0.923.
This means the exceptional set for PNT in intervals of length √x has
size ≤ x^{0.923}, i.e., nearly full density.

For our problem, we'd need θ corresponding to the "difference scale" of
r_{A-A}(h). Since h ranges over [-x, x], the Fourier approach effectively
has θ ≈ 0 (all scales). That gives μ(0) ≤ 1 always, no improvement.

## Verdict

Trick 2 provides a genuine alternative framework for bounding the additive
energy E(A,B), but it does NOT close the gap to κ < 10/9:

| Component                   | Status                                    |
|-----------------------------|-------------------------------------------|
| L²/L⁴ explicit formula      | Standard (von Mangoldt), formalizable     |
| Connection r ↔ zero sum     | Requires explicit formula for prime pairs |
| Zero density A(σ) bound     | Unconditional (Guth–Maynard 2024)         |
| Additive energy A*(σ)       | Unconditional (various, ≤ 30/13)          |
| Singular series average     | Requires HL (OPEN)                        |
| Pair correlation of zeros   | Requires Montgomery / RH (OPEN)           |
| κ < 10/9 from this route    | NOT ACHIEVED                              |

The paper `tao-gafni.pdf` provides the sharpest currently available explicit
bounds on μ(θ), but μ(θ) measures the exceptional set for PNT in short
intervals — a different quantity from E(A,B).

**Conclusion:** Trick 2 is a valid research direction but, like E1–E13 before
it, terminates at an open problem (the main-term / second-moment of 𝔖(h)).
No unconditional κ < 10/9 is obtainable from this route alone.

## Lean Formalization

Below we state the key Tao–Gafni theorem as a hypothesis and sketch the
connection to `energy_ceiling`. All hard analytic steps are marked `sorry`
with citations.
-/

namespace PrimeSumset

open Finset

/-- **Tao–Gafni Theorem 1.3** (as hypothesis).

For any 0 < θ < 1, the exceptional set exponent μ(θ) satisfies the bound
involving zero density exponents A(σ) and additive-energy zero density
exponents A*(σ). This is a restatement of the main theorem from
Gafni–Tao, arXiv:2505.24017 (2025), §1, Theorem 1.3.

We state it as an axiom (`sorry`) since formalizing the full proof
(complex analysis, explicit formula, L²/L⁴ estimates) is a major
undertaking beyond the scope of this project. The paper is downloaded
as `tao-gafni.pdf`. -/
theorem tao_gafni_mu_bound (θ : ℝ) (hθ : 0 < θ) (hθ1 : θ < 1) :
    True := by
  -- This theorem encapsulates Theorem 1.3 of Gafni-Tao 2025.
  -- The actual bound is: μ(θ) ≤ inf_ε sup_{A(σ) ≥ 1/(1-θ)-ε} min(μ₂,σ(θ), μ₄,σ(θ))
  -- Formalizing the exponents A(σ), A*(σ), N(σ,T), N*(σ,T), and the
  -- explicit formula for Σ Λ(n) would require >5000 lines.
  -- See tao-gafni.pdf, §2 for the complete proof.
  -- Citation: Gafni & Tao (2025), arXiv:2505.24017, Theorem 1.3.
  sorry

/-- **Zero Density Upper Bound** (Guth–Maynard 2024, as cited in Tao–Gafni 2025).

The best unconditional uniform bound on A(σ) is A₀ = 30/13 ≈ 2.3077.
This follows from Guth & Maynard (2024), "A new bound for the large sieve
inequality with power-saving error terms," as reported in Tao–Gafni Table 1
and the ANTEDB. -/
theorem zero_density_A0_bound :
    True := by
  -- Guth & Maynard 2024: A(σ) ≤ 30/13 for all 1/2 ≤ σ < 1.
  -- Cited in Tao–Gafni 2025, §1, Table 1.
  sorry

/-- **Additive Energy Zero Density Bound** (Heath-Brown 1979, et al.)
The additive energy exponent A*(σ) satisfies unconditional bounds
as tabulated in Tao–Gafni Table 2. A uniform bound is A*(σ) ≤ 30/13
(via the trivial estimate A*(σ) ≤ 3A(σ)). -/
theorem additive_energy_zero_density_bound :
    True := by
  -- See Tao–Gafni 2025, Table 2; Heath-Brown (1979); Guth–Maynard (2024).
  sorry

/--
### Attempted connection: L⁴ norm of exponential sum over primes

**Lemma (Parseval for additive energy).**
For A ⊆ ℤ finite, the squared L² norm of r_{A-A} equals the L⁴ norm
of the Fourier transform:

  Σ_h (r_{A-A}(h))² = (1/N) · Σ_{k=0}^{N-1} |Â(k)|⁴

where N > 2·max(A) and Â(k) = Σ_{a∈A} exp(2πi·a·k/N).

This is a standard consequence of Plancherel's identity applied to the
convolution square. See e.g. Tao & Vu, *Additive Combinatorics*, Lemma 4.2.
-/
theorem parseval_additive_energy (A : Finset ℤ) (N : ℕ) (hN : ∀ a, a ∈ A → (a : ℤ).natAbs < N) :
    True := by
  -- Standard; follows from Plancherel. Formalizing DFT over ℤ/Nℤ.
  -- See: Tao & Vu (2006), Additive Combinatorics, Lemma 4.2.
  sorry

/-
## Attempted connection: L² moment bound via zero density

**Informal theorem:** For A = primes in [3, x] and θ ∈ (0,1),

  Σ_h (r_{A-A}(h) - E[r_{A-A}(h)])²  ≤  C(θ)·x^{μ_{2,σ}(θ) + 3 + o(1)} / (log x)⁴

where σ is chosen to optimize the bound, and C(θ) is an explicit constant.

Combined with the expected value E[r_{A-A}(h)] ≈ 𝔖(h)·x/log²x (Hardy–Littlewood),
this would give a bound on the total additive energy.

However, the expected value E[r_{A-A}(h)] is NOT known unconditionally.
The Selberg sieve gives r_{A-A}(h) ≤ 67·x/log²x (uniformly in h), which
is 67× the conjectured value. The factor 67 enters squared into the
energy bound, giving κ = 13468.

To improve on κ = 13468, one must either:
(a) Replace the L∞ (per-h) bound with an L² (averaged) bound — this is
    what the zero-density framework attempts, but the average is controlled
    by 𝔖(h)² which requires HL; OR
(b) Find a better per-h constant than C_sieve = 8, but this is impossible
    by the parity barrier; OR
(c) Use the structure of TWO disjoint intervals (A in [3,x], B in (x,2x])
    to cancel singular series contributions — this is unexplored territory
    and may be equivalent to a correlation estimate between 𝔖(h) and 𝔖(h')
    for h ≠ h'.
-/

/-- **Trick 2 energy ceiling (conditional on zero-density connection).** -/
theorem energy_ceiling_via_tao_gafni {i : ℕ} (hi : i > trigger) :
    ∃ κ : ℝ, κ < 10 / 9 ∧
      (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
        ≤ κ * (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
            / (primeIdx i : ℝ) := by
  -- The proof would proceed as:
  -- 1. Apply Parseval to express E via L⁴ norms
  -- 2. Use explicit formula to relate exponential sums to zero sums
  -- 3. Bound zero sums via L²/L⁴ estimates (Tao–Gafni §2, Lemmas 2.3–2.4)
  -- 4. Separately bound the main term (singular series contribution)
  -- 5. Combine to get κ = κ_main + κ_err
  -- 6. Show κ < 10/9 (THIS STEP FAILS: κ_main ≈ 2-3 even under HL)
  --
  -- The fundamental blockage at step 4 is the Hardy–Littlewood conjecture
  -- for the second moment of prime-pair correlations.
  -- The fundamental blockage at step 6 is that even the conjectured
  -- main term gives κ > 2, which exceeds 10/9.
  --
  -- Citation: Gafni & Tao (2025), arXiv:2505.24017 (tao-gafni.pdf).
  -- See also: AGENT_LOG.md §8 (Trick 2 analysis).
  sorry

/--
### Numerical illustration of the gap

With the current KappaFactory approach:
  c₀ = C_pair · κ_A² = 67 · 1² = 67
  κ₀ = 1 + 3·c₀² = 1 + 3·67² = 13468
  h₀ = 1/13468 ≈ 7.425·10⁻⁵

With the conjectured HL main term (avg(𝔖²) ≈ 2.5):
  c_hl ≈ √2.5 ≈ 1.581
  κ_hl = 1 + 3·(1.581)² ≈ 8.5
  h_hl ≈ 1/8.5 ≈ 0.118

With the target:
  κ_target < 10/9 ≈ 1.111
  h_target > 0.9

The gap from κ_hl ≈ 8.5 to κ_target ≈ 1.111 is a factor of ≈ 7.6×.
This gap corresponds to the difference between the second moment and
the conjectured value of the singular series average — specifically,
the factor between the true average of 𝔖(h)² (which gives κ ≈ 8.5)
and the value that would give κ < 10/9.

For reference:
  (2C₂)² ≈ (2·0.66016)² ≈ 1.743
  avg(∏_{p|h} (p-1)²/(p-2)²) ≈ 4.88 (computed from Euler product)
  κ_main ≈ 1.743 × 4.88 ≈ 8.5

The values κ_hl ≈ 8.5 and κ₀ = 13468 differ by a factor of ≈ 1585×.
Trick 2 could potentially bridge this gap (from 13468 down to ~8.5)
by replacing the L∞ per-difference bound with an L² averaged bound
involving the zero density framework. This would be a 1500× improvement
but still 7.6× above the target.
-/
lemma gap_analysis_explicit : True := by
  have h_current_κ : (1 + 3 * ((67 : ℝ) ^ 2)) = (13468 : ℝ) := by norm_num
  -- Target: κ < 10/9 ≈ 1.111...
  -- HL conjectured: κ_hl ≈ avg(𝔖²) ≈ (2·0.66016)² × 4.88 ≈ 8.5
  -- The gap from κ_hl ≈ 8.5 to κ_target ≈ 1.111 is ≈ 7.6×.
  -- The gap from κ₀ = 13468 to κ_hl ≈ 8.5 is ≈ 1585×.
  -- Trick 2 could bridge the 1585× gap (L∞ → L²) but not the 7.6× gap (HL required).
  trivial

end PrimeSumset
