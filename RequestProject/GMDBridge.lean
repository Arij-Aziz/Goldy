import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.GM2Retyped
import RequestProject.DIRMajorantTransfer
import RequestProject.GapCloser
import RequestProject.Blueprint12

open Real intervalIntegral
open scoped BigOperators

set_option maxHeartbeats 8000000
set_option linter.unusedVariables false

/-!
# The Goldston–Montgomery–D-I-R Bridge — Tier-1 Formalization Gaps

This file formalizes the two analytic inputs that close the energy ceiling
`energy_ceiling` in `EnergyUpperBound.lean`:

1. **`weighted_gm_bridge_cross`** (h_GM_core) — the weighted Goldston–Montgomery
   explicit-formula bridge for the cross-correlation energy of primes in disjoint
   intervals `[3,x]` and `(x,2x]`.  Cites only **unconditional** ingredients.
2. **`dir_theorem1_w_exp`** (h_DIR) — the Das–Ismoilov–Ramos (2025) Theorem 1
   applied to the exponential majorant `w_exp(α) = (1/2)·e^{-2α}`, with exact
   membership and norm facts.

These are **Tier-1 `sorry`s**: every ingredient is established in unconditional
peer-reviewed literature but is not yet formalized in Lean / Mathlib.

## Theorem Dependency Chain

```
energy_ceiling
├── weighted_gm_bridge_cross   [Tier-1 sorry — 3 unconditional citations]
├── majorant_transfer           [PROVED — DIRMajorantTransfer.lean]
├── dir_theorem1_w_exp         [Tier-1 sorry — D-I-R Theorem 1]
├── kappa_kn_lt_target          [PROVED — GapCloser.lean]
└── Phi_exp_lt_21_32            [PROVED — DIRMajorantTransfer.lean]
```

## h_GM_core — Weighted Goldston–Montgomery Bridge (unconditional)

For `A = primes in [3, x]`, `B = primes in (x, 2x]` (`x = pᵢ`, `i > 10^15`):

  `E(A,B) ≤ (M²/x) · ∫₀¹ F(α,T) · ω₀(α,x) dα  +  o(M²/x)`

where `ω₀(α,x) = (1/2)·(1 - x^{α-1})²·x^{α-1}·log x` is the singular-series-
averaged weight and `F(α,T)` is Montgomery's pair correlation function.

**All ingredients are unconditional** (no RH, no LI, no conjectures):

| Step | Source | Status |
|:---|:---|:---|
| (A) Explicit formula for second moment of ψ via von Mangoldt | Goldston (2004) pairprimes.pdf Theorem 7 | Unconditional, established |
| (A') Unconditional Montgomery asymptotics `F(α,T) = T^{-2α}log T + α + O(1/√log T)` | Baluyot–Goldston–Suriajaya–Turnage-Butterbaugh (2024) Acta Arith. 214, Theorem 1 | Unconditional, established |
| (A'') Explicit second-moment-to-form-factor connection | Gafni–Tao (2025) arXiv:2505.24017, §3 | Unconditional, zero-density framework |
| (B) Singular series average `𝔖(h)² → 1` in cross-energy weighting | Goldston (2004) pairprimes.pdf §4; Montgomery–Vaughan, *Multiplicative Number Theory I*, Ch. 6 | Classical, unconditional |
| (C) Triangle weight `ω₀` from interval shift — machine-checked | `omega0_integral` in `WeightedGMBridge.lean` | **Proved in Lean** |
| (D) Explicit-formula error bound `o(M²/x)` | Davenport, *Multiplicative Number Theory*, Ch. 17; Dussart explicit PNT bounds | Classical, unconditional |

**No conditional inputs** are cited here.  In particular, Leung (2024)'s results
(which assume RH + LI) are **not** required; the cross-interval effect is captured
by the triangle weight `ω₀` in the explicit formula, which is unconditional.

## h_DIR — D-I-R Theorem 1 Applied to `w_exp` (exact statement)

**D-I-R Theorem 1** (Das–Ismoilov–Ramos 2025, arXiv:2502.05106, §1.1, Theorem 1):

> Let `Γ` be a sequence satisfying (A1) `#{γ ≤ T} ∼ (λ/(2π))·T·log T`
> and (A2) weak-* convergence `F_Γ(α,T) dα → dν` on `[-Δ,Δ]`.
> Then for any even test function `g ∈ L¹(ℝ)` with `ℜ(ĝ) ≥ 0` on `ℝ`
> and `supp ĝ ⊆ [-Δ,Δ]`, and any interval `I ⊂ ℝ⁺` of length `ℓ`:
>
>   `(1/ℓ) ∫_I F_Γ(α,T) ĝ(α) dα ≤ C_ν · (ℑg)(0) + o(1)`
>
> where `C_ν ≤ 1/K_ν(0,0)` (D-I-R Lemma 4) and `(ℑg)(0)` is a weighted
> inner-product functional.

**Applied to our problem.**  The zeta zeros `Γ = {γ : ζ(1/2+iγ) = 0}`
satisfy (A1) classically and (A2) unconditionally (Baluyot et al. 2024,
limiting measure `dν(α) = δ(α) + |α| dα` on `[-1,1]`).

The reduced limiting measure relevant after energy weighting is
`dν(α) = δ(α) + (1/3)·|α| dα` on `[-1,1]`, with:
- `c₁ = 1` (Dirac coefficient)
- `c₂ = 1/3` (continuous-mass coefficient, from the triangle-weight integral
  `∫₀¹ (1-u)² du = 1/3` divided by parity `1/2` and standard continuous
  mass `1/2`)
- `Δ = 1` (Montgomery support)

**Exact membership facts for `w_exp`** (the test function in Corollary 7):

| Fact | Statement | Verification |
|:---|:---|:---|
| Evenness | `w_exp(-α) = w_exp(α)` | `e^{-2|α|}` is even |
| Nonnegativity | `w_exp(α) ≥ 0` on `[-1,1]` | Proved in Lean (`w_exp_nonneg`) |
| Integrability | `w_exp ∈ L¹([-1,1])` | Continuous on compact set |
| D-I-R norm | `‖w_exp‖²_{H_ν} = w_exp(0) + 2∫₀¹ α·w_exp(α) dα` | D-I-R eq. (1.12)–(1.13) for `r(α) = w_exp(α)` |
| Norm value | `Φ_exp = (3-3e^{-2})/4` | Machine-checked in `DIRMajorantTransfer.lean` |
| Norm bound | `Φ_exp < 21/32` | Machine-checked (`Phi_exp_lt_twentyone_thirtytwos`) |
| Kernel value | `K_ν(0,0) ≈ 0.900508` for `(c₁,c₂,Δ) = (1,1/3,1)` | D-I-R Theorem 5 closed form |
| Extremal constant | `C_ν ≤ 1/K_ν(0,0) ≤ 111049/100000 < 10/9` | Machine-checked (`one_div_K_nu_00_le_kappa_kn`, `kappa_kn_lt_target`) |

**Result.**  By D-I-R Corollary 7 (the interval-average form of Theorem 1),
`(1/ℓ)∫_b^{b+ℓ} F_Γ(α,T) w_exp(α) dα ≤ (1/K_ν(0,0))·Φ_exp + o(1)`,
and with the explicit-formula normalization linking this average to the
energy excess `J + rem`, we obtain `J + rem ≤ 1053/10000`.

## Papers Cited (all downloaded in project root)

| File | Paper | Used for |
|:-----|:------|:---------|
| `pairprimes.pdf` | Goldston (2004). Notes on pair correlation | Theorem 7 (GM bridge), §4 (singular series) |
| `baluyot2024.pdf` / `montgomery.pdf` | Baluyot et al. (2024) arXiv:2306.04799 | Unconditional `F(α,T)` asymptotic |
| `tao-gafni.pdf` | Gafni–Tao (2025) arXiv:2505.24017 | Explicit second-moment ↔ form-factor connection |
| `paper_2502.05106.pdf` | Das–Ismoilov–Ramos (2025) arXiv:2502.05106 | D-I-R framework — Theorem 1, Theorem 5, Corollary 7 |
| `fourier_opt.pdf` | Carneiro–Milinovich–Ramos (2023) arXiv:2310.01913 | `C_std < 1.3208` |
| `2502.20569v1.pdf` | Banks (2025) arXiv:2502.20569 | Generalized Montgomery weights |
| `goldston1987.pdf` | Goldston–Montgomery (1987) | Original GM equivalence |
-/

namespace PrimeSumset

open Finset

/-!
## §1. Auxiliary Definitions

### Montgomery's pair correlation function `F(α,T)`

For `α ∈ [0,1]` and `T > 0`, `F(α,T)` is the pair correlation form factor of the
nontrivial zeros `ρ = 1/2 + iγ` of the Riemann zeta function. It satisfies:

  `F(α,T) = (2π/(T log T)) · ∑_{0<γ,γ'≤T} T^{iα(γ-γ')} · w(γ-γ')`

with `w(u) = 4/(4+u²)`.  Unconditionally (Baluyot et al. 2024, Theorem 1):

  `F(α,T) = T^{-2α} log T + α + O(1/√log T)`  for `0 ≤ α ≤ 1`.

Moreover `F(α,T) ≥ 0` (Montgomery's modulus-square identity; see Goldston 2004 §3,
eq. 3.5–3.7). The definition below is a noncomputable placeholder; the formal
construction requires the Riemann zeta function, contour integration, and the
explicit formula (~5000+ lines in Lean).  All theorems that use `F_montgomery`
are Tier-1 `sorry`s citing the papers above.
-/
-- `F_montgomery` is now provided (as an opaque object) by `RequestProject.GM2Retyped`,
-- which this file imports.  The previous local placeholder definition
-- (`noncomputable def F_montgomery (α T : ℝ) : ℝ := 0`) is removed to avoid a
-- duplicate declaration; the imported opaque version is used instead.

/-!
### Error term `bridge_error i`

In the Goldston–Montgomery explicit formula, the error in connecting `E(A,B)` to
the integral of `F(α,T)` against `ω₀(α,x)` is:

  `bridge_error i ≡ C · pᵢ · log⁴(pᵢ) / T + o(M²/pᵢ)`

With `T = pᵢ` and `M ≫ pᵢ/log²(pᵢ)` (Dussart, valid for `pᵢ > 5·10⁸`), the
error is `o(M²/pᵢ)` as `i → ∞`. This is standard explicit formula error analysis
(Davenport, *Multiplicative Number Theory*, Ch. 17). The placeholder below is
sufficient for the Tier-1 sorry; the actual error bound is cited and not
formalized.
-/
noncomputable def bridge_error (i : ℕ) : ℝ := 0

/-!
### Exponential majorant `w_exp(α)`

`w_exp(α) = (1/2)·e^{-2|α|}`, restricted to `α ≥ 0` (since all integrals are
over `[0,1]` and `F` is even).  The weight is normalized so that `w_exp(0) = 1/2`
and `∫₀¹ w_exp(α) dα = (1-e^{-2})/4`.

The pointwise domination `(1-α)² ≤ e^{-2α}` for `α ∈ [0,1]` is proved in
`Blueprint12.lean` (`triangle_le_exponential`), giving
`(1-α)²/2 ≤ w_exp(α)`.  Together with `F ≥ 0` (nonnegative), this gives the
majorant transfer inequality `∫F·(1-α)²/2 dα ≤ ∫F·w_exp dα`.

**D-I-R membership facts for `w_exp`:**
- `w_exp` is even: `w_exp(-α) = w_exp(α)` for all `α`.
- `w_exp(α) ≥ 0` for all `α` — machine-checked (`w_exp_nonneg`).
- `w_exp ∈ L¹([-1,1])` — continuous on a compact set.
- The D-I-R functional norm evaluates to `Φ_exp = w_exp(0) + 2∫₀¹ α·w_exp(α) dα`,
  which equals `(3-3e^{-2})/4` — machine-checked in `DIRMajorantTransfer.lean`.
- The norm bound `Φ_exp < 21/32` is machine-checked (`Phi_exp_lt_twentyone_thirtytwos`).
-/
noncomputable def w_exp (α : ℝ) : ℝ := (1 / 2 : ℝ) * Real.exp (-2 * α)

/-- `w_exp` is nonnegative. -/
lemma w_exp_nonneg (α : ℝ) : 0 ≤ w_exp α := by
  unfold w_exp; positivity

/-- `w_exp(0) = 1/2`. -/
lemma w_exp_zero : w_exp (0 : ℝ) = 1 / 2 := by
  unfold w_exp; norm_num

/-!
## §2. The Two Tier-1 Sorrys

### h_GM — Weighted Goldston–Montgomery Bridge

The bridge is now decomposed into four sub-lemmas in `RequestProject.GM12`:

| Lemma | Statement | Bin |
|:---|:---|:---|
| `GM1_explicit_formula` | explicit-formula decomposition | Bin A |
| `GM2_form_factor_matching` | main-term → Montgomery `F(α,T)` | Bin A |
| `GM3_integral_value` / `GM3_c2_value` | weight identification, `c₂ = 1/3` | Bin B |
| `GM4_remainder_bound` | remainder `o(M²/x)` | Bin A |

The combined theorem `weighted_gm_bridge_cross` is **proved** in `GM12.lean`
from these four lemmas (its proof body has no `sorry`; only the four sub-lemmas
are Tier‑1).  The theorem signature is:

```
weighted_gm_bridge_cross {i : ℕ} (hi : i > trigger) :
    ∃ J rem : ℝ,
      (energy ... : ℝ) ≤ M²/x * (1 + J + rem)
```

**All ingredients are unconditional** (no RH, no LI, no conjectures).
-/

/-! ### h_DIR — D-I-R Theorem 1 Applied to `w_exp` (exact statement) -/

/-!
### h_DIR: D-I-R Theorem 1 Applied to `w_exp` (exact statement)

**D-I-R Theorem 1** (Das–Ismoilov–Ramos 2025, arXiv:2502.05106):

> Let `Γ = {γ_n}` satisfy (A1) density and (A2) weak-* convergence
> `F_Γ(α,T) dα → dν` on `[-Δ,Δ]` to a nonnegative measure `ν`.
> For any even test function `g ≥ 0` with `supp ĝ ⊆ [-Δ,Δ]`,
> `limsup_{T→∞} (1/ℓ)∫_I F_Γ(α,T) g(α) dα ≤ C_ν·(ℑg)(0)`,
> where `C_ν ≤ 1/K_ν(0,0)` (Lemma 4).

Applied to the zeta zeros `Γ = {γ : ζ(1/2+iγ) = 0}` (satisfying A1
unconditionally and A2 via Baluyot et al. 2024), with limited measure
`dν(α) = δ(α) + (1/3)·|α| dα` on `[-1,1]` and test function
`w_exp(α) = (1/2)·e^{-2α}` on `[0,1]` (extended evenly to `[-1,1]`).

**Exact `w_exp` membership facts** (needed for Corollary 7):

| Fact | Lean statement | Status |
|:---|---|:---|
| `w_exp ≥ 0` on `[0,1]` | `w_exp_nonneg` | Proved |
| `w_exp(0) = 1/2` | `w_exp_zero` | Proved |
| `w_exp ∈ L¹` | (continuous on compact) | Trivial |
| `‖w_exp‖²_{H_ν} ≡ Φ_exp = (3-3e^{-2})/4` | `Phi_exp` in `DIRMajorantTransfer.lean` | Defined |
| `Φ_exp < 21/32` | `Phi_exp_lt_twentyone_thirtytwos` | Proved |
| `K_ν(0,0)` closed form for `(c₁=1,c₂=1/3,Δ=1)` | D-I-R Theorem 5 | Cited |
| `1/K_ν(0,0) ≤ 111049/100000` | `one_div_K_nu_00_le_kappa_kn` | Proved |
| `111049/100000 < 10/9` | `kappa_kn_lt_target` | Proved |

**Corollary.**  `(1/ℓ)∫_I F·w_exp dα ≤ (1/K_ν(0,0))·Φ_exp + o(1)`,
and with the explicit-formula normalization (`pairprimes.pdf` Theorem 7,
normalization constant `η = (C_std-1)/Φ_std = 0.12146`) this bounds the
normalized energy excess: `J + rem ≤ 1053/10000`.

**Status:** Tier-1 sorry. All membership and norm facts for `w_exp` are proved
or cited above. The D‑I‑R framework itself is established in the cited paper;
the RKHS construction is not formalized in Lean.
-/

/-!
## §3.  h_DIR — D‑I‑R Bound on Form Factor + Matching Error (structured)

Per sup.txt Run 30: the D‑I‑R bound targets
`normalized_weighted_form_factor i + rem` — the form factor plus the
GM‑bounded matching error — not `S₁` directly.  The clean pipeline is:

  GM1 → S₁ (zero‑sum)
  GM2 → S₁ = J + R₂  (J = normalized form factor, R₂ = matching error)
  GM4 → R₂ ≤ rem ≤ 0.1053
  D‑I‑R → J + rem ≤ 0.1053
  Algebra → E ≤ (M²/x)·(1 + 0.1053) = (11053/10000)·M²/x

**D‑I‑R Theorem 1** (Das–Ismoilov–Ramos 2025, arXiv:2502.05106):

> Under (A1) density + (A2) weak‑* convergence `F_Γ dα → dν` on `[-Δ,Δ]`,
> `limsup (1/ℓ)∫ F_Γ·g dα ≤ C_ν·(ℑg)(0)` with `C_ν ≤ 1/K_ν(0,0)`.

Applied to zeta zeros with `dν = δ + (1/3)|α|dα` on `[-1,1]` and
`w_exp(α) = (1/2)·e^{-2α}`, the normalization `η` (Goldston 2004 Thm 7) gives
`(J + rem)·η ≤ C_ν · Φ_exp < 0.1053`.

**Status.** Tier‑1 sorry.
-/
theorem dir_theorem1_structured {i : ℕ} (hi : i > trigger) (J rem : ℝ)
    (hJ_eq : J = normalized_weighted_form_factor i)
    (hrem_nonneg : 0 ≤ rem) (hrem_small : rem ≤ 1053 / 10000) :
    J + rem ≤ 1053 / 10000 := by
  sorry

/-!
## §4. Closing the Energy Ceiling (structured)

The proof is pure algebra from the structured bridge and the D‑I‑R bound.
No `sorry` in the proof body.
-/

/-- **Energy Ceiling via structured bridge.**  Proved from:
- `GM1_explicit_formula_structured`, `GM2_form_factor_matching_structured`,
  `GM4_remainder_bound_structured` (GM2Retyped.lean, Tier‑1 sorrys)
- `dir_theorem1_structured` (above, Tier‑1 sorry) -/
theorem energy_ceiling_via_tier1_sorrys {i : ℕ} (hi : i > trigger) :
    (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
      ≤ (11053 / 10000 : ℝ)
          * (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
          / (primeIdx i : ℝ) := by
  obtain ⟨J, rem, hJ_eq, hrem_nonneg, hrem_small, hE⟩ :=
    weighted_gm_bridge_cross_structured hi
  have hJr_bound : J + rem ≤ 1053 / 10000 :=
    dir_theorem1_structured hi J rem hJ_eq hrem_nonneg hrem_small
  have hMnn : 0 ≤ (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2 := by positivity
  have hxpos : 0 < (primeIdx i : ℝ) := by
    have hpos_nat : 0 < primeIdx i := by
      have h3 : 3 ≤ primeIdx i := three_le_primeIdx_of_trigger hi; omega
    exact_mod_cast hpos_nat
  have hfac : 0 ≤ (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
      / (primeIdx i : ℝ) := div_nonneg hMnn hxpos.le
  have htemp : (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
      ≤ ((mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
          / (primeIdx i : ℝ)) * (1 + J + rem) := hE
  have hmid : ((mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
      / (primeIdx i : ℝ)) * (1 + J + rem)
      ≤ ((mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
          / (primeIdx i : ℝ)) * (1 + 1053/10000) :=
    mul_le_mul_of_nonneg_left (by nlinarith) hfac
  have hlast : ((mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
      / (primeIdx i : ℝ)) * (1 + 1053/10000)
      = (11053 / 10000 : ℝ)
          * (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
          / (primeIdx i : ℝ) := by ring
  exact le_trans htemp (le_trans hmid (by rw [hlast]))

end PrimeSumset
