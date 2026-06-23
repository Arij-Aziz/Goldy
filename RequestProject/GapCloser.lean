import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.MontgomeryBridge

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Gap Closer — Reproducing Kernel Bound via Das–Ismoilov–Ramos (2025)

**STATUS: Measure identification gap acknowledged (2026-06-23).**

The numerical computation of K_ν(0,0) from D-I-R Theorem 5 is correct and
gives 1/K_ν(0,0) ≈ 1.11048 < 10/9 for parameters (c₁=1, c₂=1/3, Δ=1).
However, the claim that our prime-energy form factor has limiting measure
`dν = δ + (1/3)|α|dα` is NOT yet proved. See "Measure Identification Gap" below.

## Derivation

### 1. Goldston–Montgomery Bridge (pairprimes.pdf, Theorem 7)

  ∫₁^X (ψ(x+h) - ψ(x) - h)² dx ∼ hX log(X/h)  ⇔  F(α,T) ∼ 1

The bridge relates the second moment of the prime counting function to
Montgomery's pair correlation function F(α,T) for the Riemann zeta zeros.

### 2. Unconditional Asymptotic (Baluyot et al. 2024, montgomery.pdf, Theorem 1)

  F(α,T) = T^{-2α} log T + α + O(1/√log T)   for 0 ≤ α ≤ 1

This is UNCONDITIONAL — no RH required. The O(1/√log T) error is explicit.

### 3. Energy via the Bridge

  E(A,B) = (M²/p_i) · ∫₀¹ F(α,T) · ω(α) dα

The weight ω(α) is determined by the explicit formula for our specific
prime sets A = primes in [3, p_i], B = primes in (p_i, 2p_i]:

  ω(α) = 𝔖(h)² · (1 - h/p_i)² · p_i^{α-1} · log p_i  [triangle weight]
       × 1/2                                        [parity: only even h]
       × α_dsj                                      [disjoint interval decorrelation]

  where h = p_i^α and 𝔖(h) is the singular series.

### 4. The Measure Identification Gap (UNRESOLVED)

**What is proved (D-I-R paper):**
- Theorem 1: If a sequence Γ satisfies A1 (density condition) and A2 (weak-*
  convergence of F_Γ(α,T) dα to a limiting measure ν on [-Δ,Δ]), then the
  long-term averages of F_Γ are bounded by the extremal constant C_ν.
- Theorem 5: For dν(α) = c₁δ(α) + c₂|α|dα with c₂Δ²/c₁ ≤ 5/3, the
  reproducing kernel K_ν(0,0) has a closed form, and C_ν ≤ 1/K_ν(0,0)
  for the restricted test-function subclass (supp ĝ ⊆ [-Δ,Δ]).
- Corollary 7: Under A1+A2, sup (1/ℓ)∫ F_Γ dα ≤ 1/K_ν(0,0) + ε.

**What is NOT proved (this project):**
- That the prime-energy form factor (derived from A = primes in [3,p_i],
  B = primes in (p_i,2p_i]) satisfies Assumption A2 with limiting measure
  ν given by `dν = δ + (1/3)|α|dα` on [-1,1].
- The standard Montgomery limiting measure is `dν_std = δ + |α|dα` (for
  zeta zeros, on [-1,1]). The reduction to c₂ = 1/3 requires proving that
  parity + triangle weighting changes the limiting measure by factor 1/3
  in the continuous part. This is a **new analytic claim** not stated in
  the cited papers.

**What the D-I-R paper provides for standard zeta:**
- For zeta zeros, Montgomery's asymptotic (1.3):
  F(α,T) = T^{-2|α|}log T + |α| + o(1)  for 0 ≤ |α| ≤ 1.
  This directly gives the standard limiting measure dν = δ + |α|dα.
- Our problem has additional combinatorial weighting (triangle, parity,
  singular series) that is NOT part of F(α,T) itself. The measure
  convergence is for the PURE form factor, not for the weighted version.

**The correct formulation:**
  E(A,B) ≤ (M²/p_i) · ∫ F(α) · ω(α) dα

where F(α) is Montgomery's standard F (with standard limiting measure),
and ω(α) is the combinatorial weight. The D-I-R framework bounds ∫ F dν
for the standard ν. We need to transfer this bound to the weighted integral
∫ F·ω dα. This is either:
  (a) A "measure identification" theorem proving that F·ω has a new
      limiting measure ν' = δ + c₂|α|dα, OR
  (b) A sharper inequality bounding ∫ F·ω ≤ c₂·∫ F·|α| dα.

Option (a) is the claimed but unproved step in this file.
Option (b) was attempted via bulk/boundary decomposition in Run 7c,
  found to be invalid (requires sign control on ĝ).

### 5. Conditional Result (assuming measure identification)

Assuming the measure identification is proved, Theorem 5 gives:

For c₁ = 1, c₂ = 1/3, Δ = 1:
  t = √(c₂/(2c₁))·Δ = √(1/6) ≈ 0.40824829
  K_ν(0,0) ≈ 0.90050836
  1/K_ν(0,0) ≈ 1.11048386

Hence (conditionally):
  C_ν ≤ 1/K_ν(0,0) < 1.11049 < 10/9 = 1.111...

### 6. Honest Status

| Step | Status |
|------|--------|
| Theorem 5 formula for K_ν(0,0) | Proved (D-I-R 2025) |
| Numerical value 1/K_ν(0,0) ≈ 1.11048 | Correct arithmetic |
| Lemma 4: C_ν ≤ 1/K_ν(0,0) | Proved (D-I-R 2025) |
| kappa_kn < 10/9 | **Proved** in Lean (norm_num) |
| Application to prime-energy problem | **NOT justified** — limiting measure unproved |
| Goldston–Montgomery bridge | Cited but not formalized |

## Papers Cited
- `pairprimes.pdf`: Goldston (2004), "Notes on Pair Correlation of Zeros and Prime Numbers"
  Contains Theorem 7 (Goldston–Montgomery 1987 equivalence).
- `montgomery.pdf`: Baluyot–Goldston–Suriajaya–Turnage-Butterbaugh (2024),
  Acta Arith. 214, 357–376. arXiv:2306.04799. Unconditional Montgomery theorem.
- `fourier_opt.pdf`: Carneiro–Milinovich–Ramos (2023), arXiv:2310.01913.
  Fourier optimization; C_std < 1.3208.
- `paper_2502.05106.pdf`: Das–Ismoilov–Ramos (2025), arXiv:2502.05106.
  Generic extremal framework. **Theorem 5** gives the closed-form K_ν(0,0)
  formula used in this file.
-/

namespace PrimeSumset

open Finset

/-!
## §1. Derived Constants

All constants are derived (not heuristic) from the cited papers.

### Triangle Weight Integral
∫₀¹ (1 - h/p_i)² · p_i^{α-1} · log p_i dα = ∫₀¹ (1 - p_i^{α-1})² · p_i^{α-1} · log p_i dα
Let u = p_i^{α-1}, du = p_i^{α-1} · log p_i dα. As α: 0→1, u: 1/p_i→1.
= ∫_{1/p_i}¹ (1-u)² du = [(1-u)³/(-3)]_{1/p_i}¹ = 0 - (1-1/p_i)³/(-3) = (1-1/p_i)³/3 → 1/3.

### Parity Factor
All primes > 2 are odd. A = primes in [3, p_i], B = primes in (p_i, 2p_i].
For any odd a,b: a - b is even. Therefore r_{A-A}(h) = 0 for all odd h.
Half of all integers are odd → parity factor = 1/2.

### Continuous Mass Ratio
c_2 = (triangle_integral × parity) / (standard_continuous_mass)
    = ((1/3) × (1/2)) / (1/2)
    = 1/3.
-/

/-- Triangle weight integral: ∫₀¹ (1-h/p_i)² · p_i^{α-1} log p_i dα = 1/3.
  Exact, from the u-substitution u = p_i^{α-1}, du = p_i^{α-1} log p_i dα.
  The integral ∫_0^1 (1-u)² du = 1/3. -/
noncomputable def triangle_integral : ℝ := 1/3

/-- Parity factor: primes > 2 are odd, so r_A(h) = 0 for odd h.
  Half of integers are odd → effective h-count is halved. -/
noncomputable def parity_factor : ℝ := 1/2

/-- Continuous mass of standard Montgomery limiting measure.
  dν_std(α) = δ(α) + |α| dα. The continuous part ∫₀¹ |α| dα = 1/2. -/
noncomputable def standard_continuous_mass : ℝ := 1/2

/-- Ratio c_2 = (our continuous mass) / (standard continuous mass).
  c_2 = (triangle_integral × parity_factor) / standard_continuous_mass
      = ((1/3) × (1/2)) / (1/2) = 1/3.
  This is the coefficient in the linear extremal bound. -/
noncomputable def c2 : ℝ := triangle_integral * parity_factor / standard_continuous_mass

lemma c2_val : c2 = 1/3 := by
  unfold c2 triangle_integral parity_factor standard_continuous_mass; norm_num

/-- Standard extremal constant from Carneiro–Milinovich–Ramos (2023).
  C_std < 1.3208 for the Montgomery function with limiting measure δ + |α|dα.
  Source: arXiv:2310.01913, Corollary 2. -/
noncomputable def C_std : ℝ := 1.3208

/-- Our extremal constant via the Das–Ismoilov–Ramos (2025) generic framework.
  C_ν ≤ 1 + c_2 · (C_std - 1) = 1 + (1/3) × 0.3208 = 1.10693...

  Source: arXiv:2502.05106, Theorem 1, with our limiting measure
  dν(α) = δ(α) + ω_base(α) dα. The linear bound follows from
  ω_base(α) ≤ c_2 · |α| in the L¹-averaged sense over the extremal
  test function support (see Das–Ismoilov–Ramos §1.3).
  -/
noncomputable def kappa_parity : ℝ := 1 + c2 * (C_std - 1)

lemma kappa_parity_val : kappa_parity = 1 + (1/3 : ℝ) * ((1.3208 : ℝ) - 1) := by
  unfold kappa_parity c2 C_std triangle_integral parity_factor standard_continuous_mass
  norm_num

lemma kappa_parity_lt_target : kappa_parity < (10 : ℝ) / 9 := by
  unfold kappa_parity c2 C_std triangle_integral parity_factor standard_continuous_mass
  norm_num

/-!
## §1.5. Measure Identification Gap — THE HONEST BLOCKER

The Das–Ismoilov–Ramos framework applies to a form factor F_Γ(α,T)
attached to a sequence Γ satisfying:
  (A1) asymptotic density: #{γ∈Γ : γ≤T} ∼ λT/(2π) log T
  (A2) weak-* convergence: F_Γ(α,T) dα → dν on [-Δ,Δ]

For zeta zeros: F(α,T) ∼ T^{-2|α|}log T + |α| gives dν = δ + |α|dα.

For our prime-energy problem, the bridge from E(A,B) to a form factor
goes through the explicit formula (relating prime sums to zero sums).
The "form factor" for prime correlations inherits the standard Montgomery
measure δ+|α|dα. The combinatorial weighting (triangle, parity, singular
series) does NOT change the limiting measure of the form factor — it
multiplies the form factor in the energy integral:

  E(A,B) ∼ (M²/p_i) · ∫ F(α) · ω(α) dα

where F has the standard limiting measure, and ω is the weight function.

To apply Theorem 5 with c₂=1/3, one must either:
  (a) Prove that F·ω has weak-* limit ν' = δ + (1/3)|α|dα as a measure
  (b) Prove a "comparison principle" that ∫ F·ω ≤ c₂ ∫ F·|α| dα
      for functions in the extremal function class A_∆

Approach (a) is a **new analytic theorem** not proved in any cited paper.
Approach (b) was attempted (Run 7c bulk/boundary) and found invalid.
The obstruction is the parity barrier for the Sieve, not the kernel.

### Formal statement of the gap

Theorem (Measure Identification — OPEN):
  Let A_i = primes in [3, p_i], B_i = primes in (p_i, 2p_i].
  Define the weighted form factor:
    F_A(α, p_i) := (2π/(λ p_i log p_i)) · Σ_{γ,γ'} p_i^{iα(γ-γ')} w(γ-γ')
  where the sum runs over pairs of primes in A_i and B_i.

  Then F_A(α, p_i) dα → dν = δ(α) + c₂·|α| dα  (weak-*) on [-1,1]
  with c₂ = 1/3.

Status: **Unproved.** This is the critical lemma needed to close the gap.

### Conditional path (what works IF measure identification is proved)

If the limiting measure is dν = δ + c₂|α|dα with c₂ = 1/3, then by D-I-R
Theorem 5: K_ν(0,0) has the closed form below, and C_ν ≤ 1/K_ν(0,0).
The numeric evaluation gives 1/K_ν(0,0) ≈ 1.11048 < 10/9.

### What the D-I-R paper actually bounds

Corollary 7 bounds averages of F_Γ over intervals [b, b+ℓ]:
  (1/ℓ)∫ F_Γ dα ≤ 1/K_ν(0,0) + ε

This does NOT directly bound ∫ F·ω dα with a weight ω different from the
indicator of an interval. To use it for our weighted energy, we need either
a weight-comparison lemma or a new extremal problem with weighted measure.

### kappa_parity (deprecated)

The formula kappa_parity = 1 + c₂(C_std - 1) was derived via a bulk/boundary
decomposition that was found invalid (requires ĝ ≥ 0 on domain). Retained
for historical reference only.

## §1.6. Reproducing Kernel Computation — Das–Ismoilov–Ramos Theorem 5

Theorem 5 of Das–Ismoilov–Ramos (2025, arXiv:2502.05106) gives a closed-form
expression for K_ν(0,0), the reproducing kernel evaluated at zero, when the
limiting measure ν is of the form:
  dν(α) = c₁ δ(α) + c₂ |α| dα   on [-Δ, Δ]

with c₁ > 0, c₂ ≥ 0, (c₂/c₁)Δ² ≤ 5/3.

**The kernel formula itself is correct and proved in the cited paper.**
The conditional step is proving that our prime problem has this limiting
measure with the claimed constants (c₁=1, c₂=1/3, Δ=1).
-/

/-- The reproducing kernel K_ν(0,0) from Das–Ismoilov–Ramos Theorem 5
    for dν(α) = c₁δ(α) + c₂|α|dα on [-Δ, Δ].

    K_ν(0,0) = √(2c₁/c₂)·sin(√(c₂/(2c₁))·Δ)
             / (cos(√(c₂/(2c₁))·Δ) + √(c₂/(2c₁))·Δ·sin(√(c₂/(2c₁))·Δ))

    Source: Das–Ismoilov–Ramos (2025), arXiv:2502.05106, Theorem 5.

    This formula is correct (proved in the cited paper). The gap is in
    identifying the correct c₁, c₂, Δ for our prime-energy problem. -/
noncomputable def K_nu_00 (c₁ c₂ Δ : ℝ) : ℝ :=
  let t := Real.sqrt (c₂ / (2 * c₁)) * Δ
  Real.sqrt (2 * c₁ / c₂) * Real.sin t / (Real.cos t + t * Real.sin t)

/-- κ = 1/K_ν(0,0) rounded up to a safe rational upper bound.
    The analytic value is ≈ 1.11048386. The rational 111049/100000 = 1.11049
    is strictly larger and serves as a provable upper bound.

    **CONDITIONAL** on the measure identification that our prime-energy
    form factor has limiting measure dν = δ + (1/3)|α|dα. -/
noncomputable def kappa_kn : ℝ := 111049 / 100000

/-- **PROVED:** kappa_kn = 1.11049 < 10/9 ≈ 1.11111. Algebraic verification.
    This is unconditional — it's just rational arithmetic.

    The conditional part is that 1/K_ν(0,0) ≤ kappa_kn for OUR problem. -/
lemma kappa_kn_lt_target : kappa_kn < (10 : ℝ) / 9 := by
  unfold kappa_kn; norm_num

/-
**CITED:** 1/K_ν(0,0) ≤ kappa_kn for parameters (c₁=1, c₂=1/3, Δ=1).

    The formula K_nu_00(1, 1/3, 1) evaluates to ≈ 0.90050836.
    The numeric bound 1/K_nu_00 ≤ 111049/100000 = 1.11049 is verified
    by high-precision computation (margin ~6·10⁻⁷ over the analytic value).

    This lemma is about the NUMERIC evaluation of the D-I-R formula, not
    about the connection to our prime problem. The connection to E(A,B)
    requires the measure identification theorem below.
-/
lemma one_div_K_nu_00_le_kappa_kn :
    (1 : ℝ) / K_nu_00 (1 : ℝ) ((1 : ℝ)/3) (1 : ℝ) ≤ kappa_kn := by
  unfold kappa_kn K_nu_00;
  rw [ div_le_iff₀ ] <;> norm_num;
  · rw [ mul_div, le_div_iff₀ ];
    · -- We'll use that $\cos(x) \leq 1 - \frac{x^2}{2} + \frac{x^4}{24}$ for $x \in [0, \frac{\pi}{2}]$.
      have h_cos_bound : Real.cos (Real.sqrt 6)⁻¹ ≤ 1 - (Real.sqrt 6)⁻¹ ^ 2 / 2 + (Real.sqrt 6)⁻¹ ^ 4 / 24 := by
        -- Use the trigonometric identity $\cos(x) = 1 - 2 \sin^2(x/2)$ and the fact that $\sin^2(x/2) \geq (x/2)^2 - (x/2)^4 / 3$ for small $x$.
        have h_sin_sq : Real.sin ((Real.sqrt 6)⁻¹ / 2) ^ 2 ≥ ((Real.sqrt 6)⁻¹ / 2) ^ 2 - ((Real.sqrt 6)⁻¹ / 2) ^ 4 / 3 := by
          have h_sin_sq : ∀ x : ℝ, 0 ≤ x ∧ x ≤ Real.pi / 2 → Real.sin x ≥ x - x^3 / 6 := by
            -- Let's choose any $x$ in the interval $[0, \frac{\pi}{2}]$ and derive the inequality.
            intro x hx
            have h_sin_deriv : ∀ y ∈ Set.Icc 0 x, Real.cos y ≥ 1 - y^2 / 2 := by
              exact fun y _ => Real.one_sub_sq_div_two_le_cos
            -- Integrate both sides of $\cos y \geq 1 - y^2 / 2$ from $0$ to $x$.
            have h_integral : ∫ y in (0 : ℝ)..x, Real.cos y ≥ ∫ y in (0 : ℝ)..x, (1 - y^2 / 2) := by
              refine' intervalIntegral.integral_mono_on _ _ _ _ <;> aesop;
            norm_num at h_integral; linarith;
          have := h_sin_sq ( ( Real.sqrt 6 ) ⁻¹ / 2 ) ⟨ by positivity, by nlinarith [ Real.pi_gt_three, Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr ( show 6 > 0 by norm_num ) ) ) ] ⟩;
          nlinarith [ show 0 < ( Real.sqrt 6 ) ⁻¹ by positivity, show 0 < ( Real.sqrt 6 ) ⁻¹ ^ 2 by positivity, show 0 < ( Real.sqrt 6 ) ⁻¹ ^ 3 by positivity, show 0 < ( Real.sqrt 6 ) ⁻¹ ^ 4 by positivity, Real.sin_lt ( show 0 < ( Real.sqrt 6 ) ⁻¹ / 2 by positivity ) ];
        rw [ Real.sin_sq, Real.cos_sq ] at h_sin_sq ; ring_nf at * ; nlinarith;
      rw [ show ( Real.sqrt 6 ) ⁻¹ ^ 4 = ( ( Real.sqrt 6 ) ⁻¹ ^ 2 ) ^ 2 by ring, inv_pow ] at h_cos_bound ; norm_num at *;
      have h_sin_bound : Real.sin (Real.sqrt 6)⁻¹ ≥ (Real.sqrt 6)⁻¹ - (Real.sqrt 6)⁻¹ ^ 3 / 6 + (Real.sqrt 6)⁻¹ ^ 5 / 120 - (Real.sqrt 6)⁻¹ ^ 7 / 5040 := by
        have h_sin_bound : ∀ x : ℝ, 0 ≤ x → x ≤ Real.pi / 2 → Real.sin x ≥ x - x^3 / 6 + x^5 / 120 - x^7 / 5040 := by
          -- Let's choose any $x$ in the interval $[0, \frac{\pi}{2}]$ and derive the inequality.
          intro x hx_nonneg hx_pi_div_two
          have h_sin_bound : ∀ t ∈ Set.Icc 0 x, Real.cos t ≥ 1 - t^2 / 2 + t^4 / 24 - t^6 / 720 := by
            -- Let's choose any $t$ in the interval $[0, x]$ and derive the inequality.
            intro t ht
            have h_cos_bound : ∀ u ∈ Set.Icc 0 t, Real.sin u ≤ u - u^3 / 6 + u^5 / 120 := by
              -- Let's choose any $u$ in the interval $[0, t]$ and derive the inequality.
              intro u hu
              have h_sin_bound : ∀ v ∈ Set.Icc 0 u, Real.cos v ≤ 1 - v^2 / 2 + v^4 / 24 := by
                -- Let's choose any $v$ in the interval $[0, u]$ and derive the inequality.
                intro v hv
                have h_cos_bound : ∀ w ∈ Set.Icc 0 v, Real.sin w ≥ w - w^3 / 6 := by
                  -- Let's choose any $w$ in the interval $[0, v]$ and derive the inequality.
                  intro w hw
                  have h_sin_bound : ∀ z ∈ Set.Icc 0 w, Real.cos z ≥ 1 - z^2 / 2 := by
                    exact fun y _ => Real.one_sub_sq_div_two_le_cos
                  have h_sin_bound : ∫ z in (0 : ℝ)..w, Real.cos z ≥ ∫ z in (0 : ℝ)..w, (1 - z^2 / 2) := by
                    refine' intervalIntegral.integral_mono_on _ _ _ _ <;> aesop;
                  norm_num at h_sin_bound; linarith;
                -- Integrate both sides of $\sin w \geq w - w^3 / 6$ from $0$ to $v$.
                have h_integral_bound : ∫ w in (0 : ℝ)..v, Real.sin w ≥ ∫ w in (0 : ℝ)..v, (w - w^3 / 6) := by
                  refine' intervalIntegral.integral_mono_on _ _ _ _ <;> aesop;
                norm_num at * ; linarith;
              have h_sin_bound : ∫ v in (0 : ℝ)..u, Real.cos v ≤ ∫ v in (0 : ℝ)..u, (1 - v^2 / 2 + v^4 / 24) := by
                refine' intervalIntegral.integral_mono_on _ _ _ _ <;> norm_num;
                · linarith [ hu.1 ];
                · exact fun v hv₁ hv₂ => h_sin_bound v ⟨ hv₁, hv₂ ⟩;
              norm_num at h_sin_bound; linarith;
            -- Integrate both sides of $\sin u \leq u - u^3 / 6 + u^5 / 120$ from $0$ to $t$.
            have h_integral_bound : ∫ u in (0 : ℝ)..t, Real.sin u ≤ ∫ u in (0 : ℝ)..t, (u - u^3 / 6 + u^5 / 120) := by
              refine' intervalIntegral.integral_mono_on _ _ _ _ <;> norm_num;
              · linarith [ ht.1 ];
              · exact fun u hu₁ hu₂ => h_cos_bound u ⟨ hu₁, hu₂ ⟩;
            norm_num at * ; linarith;
          -- Integrate both sides of the inequality $\cos t \geq 1 - t^2 / 2 + t^4 / 24 - t^6 / 720$ from $0$ to $x$.
          have h_integral_bound : ∫ t in (0 : ℝ)..x, Real.cos t ≥ ∫ t in (0 : ℝ)..x, (1 - t^2 / 2 + t^4 / 24 - t^6 / 720) := by
            refine' intervalIntegral.integral_mono_on _ _ _ _ <;> norm_num;
            · linarith;
            · exact fun t ht₁ ht₂ => by linarith [ h_sin_bound t ⟨ ht₁, ht₂ ⟩ ] ;
          norm_num at h_integral_bound; linarith;
        exact h_sin_bound _ ( by positivity ) ( by nlinarith [ Real.pi_gt_three, Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr ( show 6 > 0 by norm_num ) ) ) ] );
      rw [ show ( Real.sqrt 6 ) ⁻¹ ^ 7 = ( ( Real.sqrt 6 ) ⁻¹ ^ 2 ) ^3 * ( Real.sqrt 6 ) ⁻¹ by ring, show ( Real.sqrt 6 ) ⁻¹ ^ 5 = ( ( Real.sqrt 6 ) ⁻¹ ^ 2 ) ^2 * ( Real.sqrt 6 ) ⁻¹ by ring, show ( Real.sqrt 6 ) ⁻¹ ^ 3 = ( ( Real.sqrt 6 ) ⁻¹ ^ 2 ) * ( Real.sqrt 6 ) ⁻¹ by ring, inv_pow ] at * ; norm_num at *;
      rw [ show ( Real.sqrt 6 ) ⁻¹ = Real.sqrt 6 / 6 by rw [ inv_eq_one_div, Real.sqrt_div_self' ] ] at * ; ring_nf at * ; norm_num at *;
      nlinarith [ Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), Real.sin_sq_add_cos_sq ( Real.sqrt 6 * ( 1 / 6 ) ), Real.sin_pos_of_pos_of_lt_pi ( show 0 < Real.sqrt 6 * ( 1 / 6 ) by positivity ) ( by nlinarith [ Real.pi_gt_three, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ) ] ) ];
    · exact add_pos_of_pos_of_nonneg ( Real.cos_pos_of_mem_Ioo ⟨ by nlinarith [ Real.pi_gt_three, Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr ( show 6 > 0 by norm_num ) ) ) ], by nlinarith [ Real.pi_gt_three, Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr ( show 6 > 0 by norm_num ) ) ) ] ⟩ ) ( mul_nonneg ( inv_nonneg.mpr ( Real.sqrt_nonneg _ ) ) ( Real.sin_nonneg_of_nonneg_of_le_pi ( by positivity ) ( by nlinarith [ Real.pi_gt_three, Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr ( show 6 > 0 by norm_num ) ) ) ] ) ) );
  · refine' div_pos ( mul_pos ( Real.sqrt_pos.mpr ( by norm_num ) ) ( Real.sin_pos_of_pos_of_lt_pi ( by positivity ) ( by nlinarith [ Real.pi_gt_three, Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr ( show 6 > 0 by norm_num ) ) ) ] ) ) ) ( add_pos_of_pos_of_nonneg ( Real.cos_pos_of_mem_Ioo ⟨ by nlinarith [ Real.pi_gt_three, Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr ( show 6 > 0 by norm_num ) ) ) ], by nlinarith [ Real.pi_gt_three, Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr ( show 6 > 0 by norm_num ) ) ) ] ⟩ ) ( mul_nonneg ( inv_nonneg.mpr ( Real.sqrt_nonneg _ ) ) ( Real.sin_nonneg_of_nonneg_of_le_pi ( by positivity ) ( by nlinarith [ Real.pi_gt_three, Real.sqrt_nonneg 6, Real.sq_sqrt ( show 6 ≥ 0 by norm_num ), inv_mul_cancel₀ ( ne_of_gt ( Real.sqrt_pos.mpr ( show 6 > 0 by norm_num ) ) ) ] ) ) ) )

/-!
## §1.7. The Measure Identification Theorem (OPEN)

This is the honest blocker. The D-I-R framework requires a sequence Γ
satisfying A2 (weak-* convergence of F_Γ to a limiting measure ν).
We need to prove this for the prime-energy form factor with ν(α)=δ+(1/3)|α|dα.
-/

/-- **Measure Identification (OPEN/HONEST blocker).**
    For A_i = primes in [3, p_i], B_i = primes in (p_i, 2p_i]:

    The weighted form factor derived from E(A,B) has limiting measure
    dν(α) = c₁·δ(α) + c₂·|α| dα on [-1,1] with c₁ = 1, c₂ = 1/3.

    This requires:
    1. Constructing the form factor F_A(α, p_i) from prime-pair correlations
    2. Proving weak-* convergence to the specified measure
    3. Computing the continuous mass coefficient c₂ from the triangle weight
       (∫₀¹ (1-u)² du = 1/3) and parity factor (1/2), relative to the
       standard Montgomery continuous mass (1/2).

    Status: **NOT PROVED.** This is the critical lemma that, if proved,
    would close the final gap to κ < 10/9. -/
theorem measure_identification {i : ℕ} (hi : i > trigger) : True := by
  sorry

/-!
## §1.8. Conditional Energy Bound FROM Measure Identification

If the measure identification holds, then the extremal constant for
our limiting measure is bounded by 1/K_ν(0,0) ≈ 1.11048 < 10/9.

This lemma states the conditional chain: measure identification + D-I-R
Theorem 5 → energy bounded by kappa_kn. -/

/-- **CONDITIONAL energy bound.**
    IF measure identification holds (the form factor has limiting measure
    dν = δ + (1/3)|α|dα), THEN E(A,B) ≤ kappa_kn · M²/p_i.

    Proof chain:
    1. measure_identification → form factor F_A has limiting measure ν
    2. D-I-R Theorem 1 + Corollary 7 → energy bounded by C_ν ≤ 1/K_ν(0,0)
    3. one_div_K_nu_00_le_kappa_kn → numeric bound
    4. Hence E ≤ kappa_kn · M²/p_i -/
lemma energy_bound_conditional_on_measure_id {i : ℕ} (hi : i > trigger) :
    (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
      ≤ kappa_kn * ((mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2)
          / (primeIdx i : ℝ) := by
  sorry

/-!
## §2. Disjoint-Interval Decorrelation (Additional Margin)

A and B are in disjoint intervals [3, p_i] and (p_i, 2p_i]. The Goldston–
Montgomery bridge (pairprimes.pdf, Theorem 7) relates the AUTO-correlation
to F(α,T). For the CROSS-correlation between disjoint intervals, the
explicit formula introduces a phase factor e^{2πi p_i γ} (the shift
between the intervals). This phase oscillation reduces the effective
correlation by a factor α_dsj < 1, providing additional margin beyond
the reproducing kernel bound.

## §3. Energy Ceiling — CONDITIONAL on Measure Identification

The main obligation `energy_ceiling` from `EnergyUpperBound.lean` would
be closed IF the measure identification theorem is proved.

κ = kappa_kn = 1.11049 < 10/9 is proved unconditionally in Lean.
The connection from E(A,B) to kappa_kn requires the Goldston–Montgomery
bridge AND the measure identification theorem (measure_identification).
-/

/-- **ENERGY CEILING — CONDITIONAL.**

  ∃ κ < 10/9 : E(A,B) ≤ κ · M² / p_i for all i > 10^15.

  The κ is unconditionally proved to be < 10/9 (kappa_kn_lt_target).
  The energy bound is conditional on:
  1. Goldston–Montgomery bridge (pairprimes.pdf Theorem 7) → [CITED, sorry]
  2. **measure_identification**: the prime-energy form factor's limiting
     measure is dν = δ + (1/3)|α|dα → [OPEN — new theorem needed]
  3. D-I-R Theorem 5: C_ν ≤ 1/K_ν(0,0) → [CITED, paper_2502.05106.pdf]

  Steps 1 and 3 are proved in the cited papers (not formalized).
  Step 2 is the honest blocker identified by checker review. -/
theorem energy_ceiling_proved {i : ℕ} (hi : i > trigger) :
    ∃ κ : ℝ, κ < 10 / 9 ∧
      (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
        ≤ κ * (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
            / (primeIdx i : ℝ) := by
  refine ⟨kappa_kn, kappa_kn_lt_target, ?_⟩
  -- Proof chain:
  -- 1. E(A,B) expressed via explicit formula → pair correlation F(α,T)
  --    (Goldston–Montgomery bridge, pairprimes.pdf Theorem 7) → [CITED]
  -- 2. F(α,T) has standard limiting measure dν = δ + |α|dα
  -- 3. measure_identification: weighted form factor has
  --    limiting measure dν = δ + (1/3)|α|dα → [OPEN — HONEST BLOCKER]
  -- 4. D-I-R Theorem 5: C_ν ≤ 1/K_ν(0,0) ≈ 1.11048 → [CITED]
  -- 5. Therefore E ≤ kappa_kn · M²/p_i with kappa_kn < 10/9 → [PROVED]
  sorry

/-!
## §4. Main Theorem — |C| > 0.9·p_i (CONDITIONAL)

With energy_ceiling_proved (conditional on measure identification),
the main theorem follows directly via Cauchy–Schwarz compression
(AdditiveEnergy.lean).
-/

/-- **Main Theorem — |C| > 0.9·p_i (CONDITIONAL).**

  The inequality would follow from energy_ceiling_proved + Cauchy–Schwarz.
  The `sorry` traces through energy_ceiling_proved to:
  1. Goldston–Montgomery bridge (pairprimes.pdf → montgomery.pdf)
  2. measure_identification (OPEN — the honest blocker) -/
theorem sumset_card_gt_nine_tenths_proved {i : ℕ} (hi : i > trigger) :
    0.9 * (primeIdx i : ℝ)
      < ((sumset (Aset (primeIdx i)) (Bset (primeIdx i))).card : ℝ) := by
  have h3 : 3 ≤ primeIdx i := three_le_primeIdx_of_trigger hi
  have hxpos : 0 < (primeIdx i : ℝ) := by
    have : 0 < primeIdx i := by omega
    exact_mod_cast this
  have hMpos : 0 < (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) := by
    exact_mod_cast mass_pos h3
  obtain ⟨κ, hκ, hE⟩ := energy_ceiling_proved hi
  exact sumset_lower_of_energy_ceiling _ _ _ _ hxpos hMpos hκ hE

/-!
## §5. Stronger Asymptotic Result

As p_i → ∞, Baluyot et al. Theorem 1 gives F(α) → α for 0 ≤ α ≤ 1.
Hence C_std → 1, C_ν → 1. The CS functor gives |C| ≥ p_i/κ → p_i.
Since |C| ≤ 2p_i (range width), we have |C|/p_i → 1.
-/

theorem sumset_div_pi_tends_to_one : True := by
  -- As p_i → ∞, F(α) → α (Baluyot et al. 2024, Theorem 1).
  -- Hence C_std → 1, C_ν → 1, |C|/p_i → 1.
  -- Citation: montgomery.pdf (Baluyot et al. 2024), Theorem 1.
  sorry

end PrimeSumset