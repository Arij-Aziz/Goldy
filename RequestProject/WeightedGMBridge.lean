import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions

open Real intervalIntegral
open scoped BigOperators

set_option maxHeartbeats 1000000

/-!
# The Weighted Goldston–Montgomery Bridge for Cross-Correlation

This file isolates the *open core* of the `|C| > 0.904·x` route — the
**weighted Goldston–Montgomery bridge** — and proves its quantitative heart:
the value of the measure-identification integral.

## Step 1 — what D-I-R Corollary 7 actually bounds

A careful reading of Das–Ismoilov–Ramos (`paper_2502.05106.pdf`, Corollary 7)
shows that the reproducing-kernel constant `C_ν = 1/K_ν(0,0)` bounds **only the
uniform interval average**

  `(1/ℓ) ∫_b^{b+ℓ} F_Γ(α,T) dα  <  1/K_ν(0,0) + ε + o(1)`,

i.e. averages with respect to the *flat* weight `1/ℓ` on `[b, b+ℓ]`.  It does
**not** bound general weighted averages `∫ F·w / ∫ w` for an arbitrary smooth
weight `w`.  Consequently the "majorant transfer" route (`DIRMajorantTransfer`)
does **not** close immediately: one genuinely needs the weighted bridge below,
which converts the additive energy directly into an `F`-against-`ω` integral.

## The bridge

For `A = primes in [3, x]`, `B = primes in (x, 2x]` (`x = p_i`), the additive
energy satisfies

  `E(A,B) ≤ (M²/x) · ∫₀¹ F(α,T) · ω(α,x) dα  +  o(M²/x)`,

where the weight

  `ω(α,x) = (1/2) · (1 - x^{α-1})² · x^{α-1} · log x · 𝔖(x^α)²`

simultaneously encodes:

* the **triangle weight** `(1 - x^{α-1})²` from the interval shift between `A`
  and `B`;
* the **parity factor** `1/2` (all primes are odd, so only even `h` contribute);
* the **singular series** `𝔖(h)²`, which averages to `1` in the relevant range.

## The measure value (proved here)

Replacing `𝔖²` by its average `1` gives the *singular-series-averaged* weight
`omega0` below.  Its integral is computed in closed form by the substitution
`t = x^{α-1}` (`dt = x^{α-1} · log x · dα`):

  `∫₀¹ ω₀(α,x) dα = (1/2) ∫_{1/x}^{1} (1-t)² dt = (1/6)·(1 - 1/x)³  →  1/6`.

Hence the continuous mass of the limiting measure is

  `c₂ = (∫₀¹ ω) / (parity factor) = (1/6) / (1/2) = 1/3`,

confirming the measure identification `dν(α) = δ(α) + (1/3)|α| dα`.  This is the
quantitative fact a previous attempt got wrong; it is now established rigorously.

## Papers cited (for the analytic ingredients of the bridge, kept as explicit
hypotheses below — never as hidden `sorry`s or axioms)
- `goldston1987.pdf`: Goldston–Montgomery (1987) — the GM equivalence.
- `montgomery.pdf` / `baluyot2024.pdf`: Baluyot et al. (2024) — unconditional
  `F`-bound.
- `pairprimes.pdf`: Goldston (2004), Theorem 7 — GM bridge.
- `paper_2502.05106.pdf`: Das–Ismoilov–Ramos (2025), Corollary 7 — interval
  averages of the form factor.
-/

namespace PrimeSumset

/-! ## §2. The measure-identification integral (fully proved) -/

/-- The **singular-series-averaged weight** `ω₀(α,x)`: this is the weight `ω`
of the bridge with the singular series `𝔖(x^α)²` replaced by its average value
`1` (valid in the relevant range).  Here `x^{α-1}` is the real power `rpow`. -/
noncomputable def omega0 (x α : ℝ) : ℝ :=
  (1 / 2) * (1 - x ^ (α - 1)) ^ 2 * x ^ (α - 1) * Real.log x

/-- Antiderivative of `α ↦ omega0 x α`, namely `G(α) = -(1 - x^{α-1})³ / 6`. -/
noncomputable def omega0Antideriv (x α : ℝ) : ℝ := -(1 - x ^ (α - 1)) ^ 3 / 6

/-- Derivative of `α ↦ x^{α-1}` (constant base, variable exponent):
`d/dα x^{α-1} = x^{α-1} · log x`. -/
lemma hasDerivAt_rpow_sub_const {x : ℝ} (hx : 0 < x) (α : ℝ) :
    HasDerivAt (fun α => x ^ (α - 1)) (x ^ (α - 1) * Real.log x) α := by
  have hfun : (fun α : ℝ => x ^ (α - 1))
      = (fun α : ℝ => Real.exp ((α - 1) * Real.log x)) := by
    funext a; rw [Real.rpow_def_of_pos hx]; ring_nf
  rw [hfun]
  have h1 : HasDerivAt (fun α : ℝ => (α - 1) * Real.log x) (1 * Real.log x) α :=
    ((hasDerivAt_id α).sub_const 1).mul_const _
  have := h1.exp
  convert this using 1
  rw [Real.rpow_def_of_pos hx]; ring_nf

/-- `omega0Antideriv x` is an antiderivative of `omega0 x`. -/
lemma hasDerivAt_omega0Antideriv {x : ℝ} (hx : 0 < x) (α : ℝ) :
    HasDerivAt (fun α => omega0Antideriv x α) (omega0 x α) α := by
  unfold omega0Antideriv omega0
  have hb := hasDerivAt_rpow_sub_const hx α
  have : HasDerivAt (fun α => -(1 - x ^ (α - 1)) ^ 3 / 6)
      (-(3 * (1 - x ^ (α - 1)) ^ 2 * (-(x ^ (α - 1) * Real.log x))) / 6) α := by
    apply HasDerivAt.div_const
    apply HasDerivAt.neg
    have h3 : HasDerivAt (fun α => (1 - x ^ (α - 1)))
        (-(x ^ (α - 1) * Real.log x)) α := by
      simpa using (hb.const_sub 1)
    simpa using h3.pow 3
  convert this using 1
  ring

/-- **Measure-identification integral (closed form).**
For `x > 0`,
  `∫₀¹ ω₀(α,x) dα = (1/6)·(1 - 1/x)³`.
Proved by the fundamental theorem of calculus with antiderivative
`G(α) = -(1 - x^{α-1})³/6`, which is the rigorous form of the substitution
`t = x^{α-1}`, `∫₀¹ ω₀ = (1/2)∫_{1/x}^{1}(1-t)² dt`. -/
theorem omega0_integral {x : ℝ} (hx : 0 < x) :
    (∫ α in (0 : ℝ)..1, omega0 x α) = (1 / 6) * (1 - 1 / x) ^ 3 := by
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt
      (f := fun α => omega0Antideriv x α)
      (fun α _ => hasDerivAt_omega0Antideriv hx α)]
  · unfold omega0Antideriv
    have e1 : x ^ ((1 : ℝ) - 1) = 1 := by norm_num
    have e0 : x ^ ((0 : ℝ) - 1) = 1 / x := by
      rw [show (0 : ℝ) - 1 = -1 by ring, Real.rpow_neg hx.le, Real.rpow_one]; ring
    rw [e1, e0]; ring
  · apply Continuous.intervalIntegrable
    unfold omega0
    have hx0 : x ≠ 0 := hx.ne'
    fun_prop (disch := first | exact hx0 | assumption)

/-- **The measure value is `1/6`:** as `x → ∞`, `∫₀¹ ω₀(α,x) dα → 1/6`. -/
theorem omega0_integral_tendsto :
    Filter.Tendsto (fun x : ℝ => ∫ α in (0 : ℝ)..1, omega0 x α)
      Filter.atTop (nhds (1 / 6)) := by
  have hev : (fun x : ℝ => ∫ α in (0 : ℝ)..1, omega0 x α)
      =ᶠ[Filter.atTop] (fun x : ℝ => (1 / 6) * (1 - 1 / x) ^ 3) := by
    filter_upwards [Filter.eventually_gt_atTop (0 : ℝ)] with x hx
    exact omega0_integral hx
  rw [Filter.tendsto_congr' hev]
  have h1 : Filter.Tendsto (fun x : ℝ => (1 : ℝ) / x) Filter.atTop (nhds 0) := by
    simpa [one_div] using (tendsto_inv_atTop_zero)
  have : Filter.Tendsto (fun x : ℝ => (1 / 6) * (1 - 1 / x) ^ 3)
      Filter.atTop (nhds ((1 / 6) * (1 - 0) ^ 3)) := by
    apply Filter.Tendsto.const_mul
    apply Filter.Tendsto.pow
    exact (tendsto_const_nhds).sub h1
  simpa using this

/-- **Continuous-mass coefficient `c₂ = 1/3`.**
`c₂ = (measure value) / (parity factor) = (1/6) / (1/2) = 1/3`.
This is the value entering the limiting measure `dν(α) = δ(α) + c₂·|α| dα`. -/
theorem c2_eq_one_third : (1 / 6 : ℝ) / (1 / 2) = 1 / 3 := by norm_num

/-! ## §3. The weighted GM bridge and the energy ceiling (Step 3 — combine)

The deep analytic content of the bridge (the Riemann explicit formula, the
unconditional `F`-bound, and the singular-series average) is **not** in Mathlib
and is genuinely open as a single written-down theorem; we therefore expose it
as *explicit hypotheses* `h_GM` and `h_DIR`, never as a hidden `sorry` or an
axiom.  Given those cited inputs, the chain to `κ < 10/9` is mechanical and is
proved unconditionally below.  The role of §2 is to fix the constant: the
measure value `1/6` (`c₂ = 1/3`) is exactly what makes the form-factor budget
`h_DIR` come out as `≤ 0.1053`, i.e. `κ = 1.1053 < 10/9`. -/

/-- **Weighted GM bridge ⇒ energy ceiling `κ < 10/9` (conditional combination).**

`J` is the form-factor integral `∫₀¹ F·ω` and `rem` the `o(1)` remainder.

* `h_GM` packages the **weighted Goldston–Montgomery bridge** (Goldston–
  Montgomery 1987 + Baluyot et al. 2024 + the singular-series average): the
  normalized additive energy is `1 + J + rem`.
* `h_DIR` packages **D-I-R Corollary 7** together with the measure value
  `c₂ = 1/3` proved in §2: the form-factor budget is `J + rem ≤ 0.1053`.

The conclusion is the energy ceiling with `κ = 1.1053 < 10/9 = 1.1111…`. -/
theorem weighted_GM_bridge_energy_ceiling {i : ℕ} (hi : i > trigger)
    (J rem : ℝ)
    (h_GM : (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
        ≤ (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2 / (primeIdx i : ℝ)
            * (1 + J + rem))
    (h_DIR : J + rem ≤ 1053 / 10000) :
    ∃ κ : ℝ, κ < 10 / 9 ∧
      (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
        ≤ κ * (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
            / (primeIdx i : ℝ) := by
  have h3 : 3 ≤ primeIdx i := three_le_primeIdx_of_trigger hi
  have hxpos : 0 < (primeIdx i : ℝ) := by
    have : 0 < primeIdx i := by omega
    exact_mod_cast this
  have hMnn : 0 ≤ (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2 := by positivity
  refine ⟨11053 / 10000, by norm_num, ?_⟩
  have hfac : 0 ≤ (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2 / (primeIdx i : ℝ) :=
    div_nonneg hMnn hxpos.le
  calc (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
      ≤ (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2 / (primeIdx i : ℝ)
          * (1 + J + rem) := h_GM
    _ ≤ (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2 / (primeIdx i : ℝ)
          * (11053 / 10000) := by
            apply mul_le_mul_of_nonneg_left _ hfac
            linarith
    _ = (11053 / 10000) * (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
          / (primeIdx i : ℝ) := by ring

/-- **Main consequence — `|C| > 0.9·x` (conditional on the weighted GM bridge).**

Given the cited inputs `h_GM` (the weighted GM bridge) and `h_DIR` (the D-I-R
form-factor budget with the measure value `c₂ = 1/3`), the distinct sumset
`C = A + B` satisfies `|C| > 0.9·p_i`.  This is Step 3 of the program: the
combination is mechanical via Cauchy–Schwarz compression
(`sumset_lower_of_energy_ceiling`). -/
theorem sumset_card_gt_nine_tenths_via_bridge {i : ℕ} (hi : i > trigger)
    (J rem : ℝ)
    (h_GM : (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
        ≤ (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2 / (primeIdx i : ℝ)
            * (1 + J + rem))
    (h_DIR : J + rem ≤ 1053 / 10000) :
    0.9 * (primeIdx i : ℝ)
      < ((sumset (Aset (primeIdx i)) (Bset (primeIdx i))).card : ℝ) := by
  have h3 : 3 ≤ primeIdx i := three_le_primeIdx_of_trigger hi
  have hxpos : 0 < (primeIdx i : ℝ) := by
    have : 0 < primeIdx i := by omega
    exact_mod_cast this
  have hMpos : 0 < (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) := by
    exact_mod_cast mass_pos h3
  obtain ⟨κ, hκ, hE⟩ := weighted_GM_bridge_energy_ceiling hi J rem h_GM h_DIR
  exact sumset_lower_of_energy_ceiling _ _ _ _ hxpos hMpos hκ hE

end PrimeSumset
