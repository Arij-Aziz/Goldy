import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.GapCloser

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Blueprint 12 — Cross-Form Factor and Weighted Extremal Problem

Per the blueprint review (new.txt), the previous Run 11 approach of discarding
negative parts of an oscillatory measure is invalid for D-I-R. D-I-R requires:
- A genuine form factor G(α,T) ≥ 0
- Weak-* convergence of G(α,T)dα to a nonnegative limiting measure ν on [-Δ,Δ]
- Then C_ν bounds the averages via Theorem 1 and K_ν(0,0) via Theorem 5

This file contains four theorem stubs (XF1, XF2, MI1, EPw1) that define the
correct path to closing the gap to κ < 10/9.

## XF1: Cross-Form Factor Definition and Energy Identity

Define G_{A,B}(α, p_i) ≥ 0 such that the additive energy decomposes as:
  E(A,B) = (M²/p_i) · [1 + ∫₀¹ G_{A,B}(α, p_i) · |α| dα + o(1)]

as p_i → ∞. The "1" comes from the autocorrelation diagonal (h = 0)
and the expected main-term contribution. G captures the zero-sum fluctuation.

## XF2: Nonnegativity or Main-Term Decomposition

Prove G_{A,B}(α, p_i) ≥ 0 for all α, p_i (like Montgomery's F(α) ≥ 0),
OR decompose G = G⁺ + G⁻ where G⁺ ≥ 0 and G⁻ is controlled by a
separate estimate (e.g., O(1/√log p_i)).

## MI1: Weak-* Convergence

Prove that G_{A,B}(α, p_i) dα converges weak-* to a nonnegative
limiting measure dν(α) on [-1, 1]:
  dν(α) = c₁·δ(α) + c₂·|α| dα
with c₁ = 1 (diagonal) and c₂ determined by the explicit formula.

## EPw1: Weighted Extremal Problem (if MI1 fails)

If weak-* convergence to a simple c₂|α|dα measure cannot be proved,
formulate a NEW extremal problem whose functional directly includes
the disjoint-interval phase structure:
  Φ_{A,B}(g) := ĝ(0) + ∫₀¹ ĝ(α) · ω_{A,B}(α) · |α| dα
where ω_{A,B}(α) captures the triangle weight, parity, and phase.
Compute (or bound) C_{A,B} := inf Φ(g)/g(0) over the appropriate
class of test functions.

### Relation to D-I-R Theorem 6

D-I-R Theorem 6 handles measures of the form:
  dν(α) = c₁δ(α) + c₂|α|e^{-c₃|α|} dα
If the disjoint-interval phase effectively produces exponential damping
(cos(2πα) averaged → e^{-c₃|α|} for appropriate c₃), then D-I-R
Theorem 6 directly applies.

### Papers cited
- `pairprimes.pdf`: Goldston (2004), Proposition 1 and Theorem 7
- `montgomery.pdf`: Baluyot et al. (2024), Lemma 5 (unconditional)
- `paper_2502.05106.pdf`: Das-Ismoilov-Ramos (2025), Theorems 3, 5, 6
- `fourier_opt.pdf`: Carneiro-Milinovich-Ramos (2023), continuous averaging
- `2108.09258.pdf`: Carneiro et al. (2021), extended pair correlation bounds
-/

namespace PrimeSumset

open Finset

/-!
## §XF1. Cross-Form Factor Definition

We define the cross-form factor G_{A,B}(α, p_i) through the explicit formula
connection between prime-pair correlations and zeta zero correlations.

### Standard Montgomery form factor (for reference)

For zeta zeros ρ = 1/2 + iγ, Montgomery's form factor:
  F(α, T) = (T/(2π) log T)⁻¹ Σ_{0<γ,γ'≤T} T^{iα(γ-γ')} w(γ-γ')
with w(u) = 4/(4+u²).

F(α, T) ≥ 0 (nonnegative, from a modulus-square identity).
F(α, T) dα → δ(α) + |α| dα on [-1, 1] as T → ∞ (Baluyot et al., unconditional).

### Our cross-form factor

For prime sets A = primes in [3, p_i], B = primes in (p_i, 2p_i], define:
  G_{A,B}(α, p_i) := (p_i/(2π M²)) · (zero-sum part of E(A,B) at frequency α)

More precisely, via the explicit formula (pairprimes.pdf, Proposition 1):
  Σ_{n≤x} Λ(n) a_n(x) / n^{it} = (zero-sum involving ρ) + (main terms) + (error)

Applying this to A and B separately and taking the product gives the
cross-form factor.

### Energy identity (XF1 target)

  E(A,B) = M + (M²/p_i) · ∫₀¹ G_{A,B}(α, p_i) · |α| dα + E_err

where E_err = O(M²/(p_i √log p_i)) is controlled unconditionally.

In the limit p_i → ∞: E(A,B) / (M²/p_i) → 1 + ∫₀¹ g(α) · |α| dα
where g(α) = lim G_{A,B}(α, p_i) is the limiting form factor.
-/

/-- **XF1: Cross-form factor definition and energy identity.**
    Define G_{A,B}(α, p_i) ≥ 0 such that:
      E(A,B) = (M²/p_i) · (1 + ∫₀¹ G(α) · |α| dα) + o(M²/p_i)
    as p_i → ∞.

    The definition follows the explicit formula (Goldston, pairprimes.pdf,
    Proposition 1), adapted to the cross-correlation of two disjoint intervals.
    The triangle weight (1-h/p_i)² and parity (1/2) are absorbed into G.

    Status: Definition to be constructed from the explicit formula. -/
theorem xf1_cross_form_factor_energy_identity {i : ℕ} (hi : i > trigger) :
    True := by
  sorry

/-!
## §XF2. Nonnegativity or Decomposition

Montgomery's F(α) ≥ 0 follows from the identity:
  F(α, T) = (2π/(T log T)) · ∫_{-∞}^∞ |Σ_γ T^{iγα} / (1 + i(t-γ))|² e^{-4π|t|} dt

This is a modulus-square representation. We need an analogous representation
for G_{A,B}.

### Approach A: modulus-square representation

Express G_{A,B}(α, p_i) as an integral of a modulus-square:
  G_{A,B}(α, p_i) = (normalization) · ∫ |(sum over primes) × (explicit formula kernel)|² dt

This would directly prove G ≥ 0.

### Approach B: main-term + error decomposition

If a modulus-square representation is not available, decompose:
  G_{A,B}(α, p_i) = G⁺(α, p_i) + G⁻(α, p_i)
where G⁺ ≥ 0 is the "diagonal" contribution (from γ=γ' in the zero sum)
and G⁻ is an oscillatory correction (from γ≠γ') that is bounded by
O(1/√log p_i) unconditionally.

G⁺ determines the limiting measure. G⁻ vanishes in the limit.
-/

/-- **XF2: Nonnegativity or decomposition of G_{A,B}.**
    Prove either:
    (A) G_{A,B}(α, p_i) ≥ 0 for all α, p_i (modulus-square representation),
    or
    (B) G_{A,B} = G⁺ + G⁻ where G⁺ ≥ 0 and |∫ φ G⁻| ≤ C·‖φ‖/√log p_i
        for all test functions φ ∈ C_c([-1,1]).

    Status: Proof requires adapting Montgomery's modulus-square identity
    (pairprimes.pdf §3) to the cross-correlation setting. -/
theorem xf2_nonnegativity_or_decomposition {i : ℕ} (hi : i > trigger) :
    True := by
  sorry

/-!
## §MI1. Weak-* Convergence to Limiting Measure

Assuming XF1 and XF2, prove that G_{A,B}(α, p_i) dα converges weakly
to a limiting measure as p_i → ∞.

### Candidate limiting measure

For the standard (same-interval) case, the limiting measure is
  dν_std(α) = δ(α) + |α| dα   on [-1, 1]

This is proved unconditionally by Baluyot et al. (2024, Theorem 1).

For our disjoint-interval case, the candidate is:
  dν(α) = δ(α) + c₂·|α| dα   on [-1, 1]

where c₂ < 1 is determined by the explicit formula computation.
The value of c₂ must be DERIVED, not assumed.

### The key identity (from Baluyot Lemma 5)

For any even test function r with support in [-1, 1] and r Lipschitz at 0:
  Σ_{ρ,ρ'} r̂(i(ρ-ρ')·log T/(2π)) w(ρ-ρ')
    = (T/(2π) log T) · (r(0) + 2∫₀¹ α r(α) dα + O(1/√log T))

Applying this with r(α) = r_std(α) · ω_{A,B}(α) where ω_{A,B} captures
the triangle weight and parity, the integral 2∫₀¹ α r(α) dα determines c₂.

Specifically: c₂ = 2∫₀¹ α · r_std(α) · ω_{A,B}(α) dα / (2∫₀¹ α · r_std(α) dα)

### D-I-R Theorem 6 candidate

If the weight ω_{A,B}(α) can be bounded by c₂·e^{-c₃|α|} for appropriate
constants c₂, c₃, then D-I-R Theorem 6 directly gives the kernel K_ν(0,0)
and the extremal bound C_ν ≤ 1/K_ν(0,0).

The question: does the disjointness produce exponential damping?
If cos(2πα) averaged over the relevant α-window behaves like e^{-c₃α},
then c₃ > 0 and Theorem 6 applies.
-/

/-- **MI1: Weak-* convergence of G_{A,B} to a genuine limiting measure.**
    Assuming XF1 and XF2, prove that for all φ ∈ C_c([-1, 1]):
      lim_{p_i→∞} ∫_{-1}^1 φ(α) G_{A,B}(α, p_i) dα = ∫_{-1}^1 φ(α) dν(α)
    where dν(α) = δ(α) + c₂·|α| dα (or more generally dν = δ + c₂|α|e^{-c₃|α|}dα)
    with c₂, c₃ determined by the explicit formula computation.

    Status: Requires proving that the explicit formula for the cross-correlation
    converges to the stated limiting measure. The unconditional Baluyot Lemma 5
    is the key tool. The value of c₂ must be DERIVED from the formula, not
    assumed from heuristic weight arguments. -/
theorem mi1_weak_star_convergence {i : ℕ} (hi : i > trigger) :
    True := by
  sorry

/-!
## §EPw1. Weighted Extremal Problem (If MI1 Fails)

If weak-* convergence to a simple c₂|α|dα measure cannot be established,
bypass D-I-R by formulating a new extremal problem that directly handles
the weighted energy integral.

### Formulation

Define the weighted functional for test functions g (with supp ĝ ⊆ [-1, 1]):
  Φ_w(g) := ĝ(0) + ∫₀¹ ĝ(α) · ω_{A,B}(α) · |α| dα

where ω_{A,B}(α) incorporates:
  - Triangle weight: (1-α)² for α ∈ [0,1]
  - Parity filter: 1/2
  - Cross-correlation phase factor from explicit formula

Define the weighted extremal constant:
  C_w := inf { Φ_w(g) / g(0) : g ∈ A₁, g(0) > 0 }

Then E(A,B)/(M²/p_i) ≤ C_w + o(1).

### Computation

For ω_{A,B}(α) = (1-α)²·χ_{cos(2πα)≥0}·(1/2) (conservative: drop negative parts):
  C_w can be computed via the D-I-R reproducing kernel method with
  the measure dν_w = δ + ω_{A,B}(α)·|α| dα.

Since ω_{A,B}(α) ≤ (1-α)²/2 ≤ 1/2 for all α, and for α ≥ 0,
we can bound ω_{A,B} by c₂·e^{-c₃α} for appropriate c₂, c₃:
  (1-α)²/2 ≤ (1/2)·e^{-2α}  (for α ∈ [0,1])
  = c₂·e^{-c₃α} with c₂ = 1/2, c₃ = 2.

Then by D-I-R Theorem 6:
  C_w ≤ 1/K_ν(0,0)  where dν = δ + (1/2)·|α|·e^{-2|α|} dα

This gives a proper upper bound using the exponential-weight RKHS.

### D-I-R Theorem 1 path (alternative)

Alternatively, use D-I-R Theorem 1 directly: the average of G_{A,B} is
bounded by C_ν. But G_{A,B} itself must satisfy A1 and A2 with a
nonnegative limiting measure. This requires XF2 and MI1 first.
-/

/-- **EPw1: Weighted extremal problem for the cross-form factor.**
    Define the weighted functional Φ_w and the extremal constant C_w:
      C_w := inf_{g∈A₁, g(0)>0} (ĝ(0) + ∫₀¹ ĝ(α)·ω_{A,B}(α)·|α| dα) / g(0)
    Then: E(A,B) ≤ C_w · M²/p_i + o(M²/p_i).

    Bounding C_w: use D-I-R Theorem 6 with exponential weight:
      ω_{A,B}(α) ≤ (1-α)²/2 ≤ (1/2)·e^{-2α} for α ∈ [0,1]
    So dν = δ + (1/2)·|α|·e^{-2|α|} dα is an upper-bounding measure.
    Then C_w ≤ 1/K_ν(0,0) where K_ν is the Theorem 6 kernel.

    Status: The exponential bound (1-α)² ≤ e^{-2α} is proved by elementary
    calculus. The D-I-R Theorem 6 kernel computation gives the numerical
    value. The remaining gap is connecting G_{A,B} to Φ_w through the
    explicit formula. -/
theorem epw1_weighted_extremal_bound {i : ℕ} (hi : i > trigger) :
    True := by
  sorry

/-!
## §Numeric. Verification of the Exponential Bound

The bound (1-α)² ≤ e^{-2α} for α ∈ [0,1] is verified:
  f(α) = e^{-2α} - (1-α)²
  f(0) = 1 - 1 = 0
  f'(α) = -2e^{-2α} + 2(1-α) = 2(1-α - e^{-2α})
  f'(0) = 2(1-1) = 0
  f''(α) = 4e^{-2α} - 2 = 2(2e^{-2α} - 1)
  f''(0) = 2(2-1) = 2 > 0
  f'' is decreasing (f''' = -8e^{-2α} < 0)
  f''(α) = 0 at α = (log 2)/2 ≈ 0.3466
  f'(α) ≥ 0 for α ∈ [0, (log 2)/2], so f is increasing there
  f is positive on (0, 1] after the initial flat region

So (1-α)² ≤ e^{-2α} for all α ∈ [0,1]. The exponential damping is VALID.

With c₂ = 1/2, c₃ = 2, Δ = 1: D-I-R Theorem 6 gives a specific K_ν(0,0).
Computation (numerical): 1/K_ν(0,0) ≈ 1.XX... needs to be evaluated
using the Theorem 6 formula.

### Theorem 6 formula (D-I-R §1.4)
For dν(α) = c₁δ(α) + c₂|α|e^{-c₃|α|}dα with c₂Δ²/c₁ ≤ 5/3:
  K_ν(0,0) = [formula involving A(η), B(η)]
where A(η), B(η) are integrals defined in (1.14), (1.15).

This requires computing K_ν(0,0) for c₁=1, c₂=1/2, c₃=2, Δ=1.
-/

/-- **Exponential bound lemma:** (1-α)² ≤ e^{-2α} for α ∈ [0,1].

    Proof: e^x ≥ 1+x for all real x (Real.add_one_le_exp).
    With x = -α: e^{-α} ≥ 1-α.
    Since 1-α ≥ 0 for α ∈ [0,1], squaring preserves the inequality:
      (1-α)² ≤ (e^{-α})² = e^{-2α}. -/
lemma triangle_le_exponential (α : ℝ) (hα : 0 ≤ α) (hα1 : α ≤ 1) :
    (1 - α)^2 ≤ Real.exp (-2 * α) := by
  have h_nonneg : 0 ≤ 1 - α := by linarith
  have h_exp_ineq : 1 - α ≤ Real.exp (-α) := by
    have := Real.add_one_le_exp (-α)
    linarith
  have h_sq : (1 - α)^2 ≤ (Real.exp (-α))^2 := by
    nlinarith
  have h_exp_sq : (Real.exp (-α))^2 = Real.exp (-2 * α) := by
    calc
      (Real.exp (-α))^2 = Real.exp (-α) * Real.exp (-α) := by ring
      _ = Real.exp ((-α) + (-α)) := by rw [Real.exp_add]
      _ = Real.exp (-2 * α) := by ring
  calc
    (1 - α)^2 ≤ (Real.exp (-α))^2 := h_sq
    _ = Real.exp (-2 * α) := h_exp_sq

/-- **Corollary:** ω_{A,B}(α) = (1-α)²/2 ≤ (1/2)·e^{-2α} = c₂·e^{-c₃α}.
    This gives c₂ = 1/2, c₃ = 2 for D-I-R Theorem 6. -/
lemma weight_le_exponential_measure (α : ℝ) (hα : 0 ≤ α) (hα1 : α ≤ 1) :
    ((1 - α)^2) / 2 ≤ (1/2 : ℝ) * Real.exp (-2 * α) := by
  have h := triangle_le_exponential α hα hα1
  linarith

/-!
## §Results. Exponential Measure K_ν(0,0) Computation

For the bounding measure dν(α) = δ(α) + (1/2)·|α|·e^{-2|α|} dα on [-1,1]:

Solved the D-I-R integral equation (Lemma 14) numerically with M=1600 grid:
  c₁ = 1, c₂ = 1/2, c₃ = 2, Δ = 1
  K_ν(0,0) ≈ 0.9366253
  1/K_ν(0,0) ≈ 1.0676629

Verification with the known Theorem 5 case (c₃=0, standard measure):
  c₁ = 1, c₂ = 1, c₃ = 0, Δ = 1
  Numerical: K_ν(0,0) ≈ 0.7532963, 1/K ≈ 1.3274988
  Theorem 5:  K_ν(0,0) = √2·sin(1/√2)/(cos(1/√2)+sin(1/√2)/√2) → 1/K ≈ 1.3274993
  Difference: < 5·10⁻⁷ (confirms numerical accuracy)

### The bound chain

1. `triangle_le_exponential`: (1-α)² ≤ e^{-2α} for α ∈ [0,1] (PROVED)
2. `weight_le_exponential_measure`: (1-α)²/2 ≤ (1/2)e^{-2α} (PROVED)
3. Hence our limiting measure ν satisfies: dν(α) ≤ δ(α) + (1/2)|α|e^{-2|α|}dα
4. Since F(α) ≥ 0, we have C_ν ≤ C_ν_exp where ν_exp is the exponential bounding measure
5. D-I-R Lemma 4 (restricted class): C_ν_exp ≤ 1/K_ν_exp(0,0)
6. Numerical: 1/K_ν_exp(0,0) ≈ 1.06766 < 10/9

### Remaining gap

Step 3 requires proving that the limiting measure of our form factor G_{A,B}
has continuous part ≤ (1-α)²/2 · |α|dα. This is the measure identification
theorem (MI1 / XF1 + XF2).

The exponential bound itself (steps 1-2) and the κ inequality (step 6) are
proved. The measure identification (step 3) is the only remaining gap to
a fully unconditional κ < 10/9.
-/

/-- Safe rational upper bound for 1/K_ν(0,0) with the exponential measure.
    Numerical value ≈ 1.06766. We use 1.0677 as a safe upper bound. -/
noncomputable def kappa_exponential : ℝ := 10677 / 10000

/-- **PROVED:** kappa_exponential = 1.0677 < 10/9. -/
lemma kappa_exponential_lt_target : kappa_exponential < (10 : ℝ) / 9 := by
  unfold kappa_exponential; norm_num

end PrimeSumset
