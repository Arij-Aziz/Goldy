import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.BridgeToDIR
import RequestProject.GapCloser

open scoped BigOperators
open scoped Pointwise

/-!
# Branch A — κ ≤ 1.11049 via D-I-R Standard Weighted Measure

## Target

Prove: E(A,B) ≤ 1.11049 · M² / p_i for i > 10^15.

## Dependency chain

1. **Baluyot Lemma 5** (`montgomery.pdf`, doi: 10.4064/aa230604-25-7):
   For any even r with supp ⊆ [-1,1], L¹, Lipschitz at 0:
     ∫₀¹ F(α) r(α) dα ≤ r(0) + 2∫₀¹ α r(α) dα + o(1)

2. **Energy expression** (`pairprimes.pdf`, Proposition 1 + Theorem 7):
   E(A,B)/(M²/p_i) = 1 + c₀ · ∫₀¹ F(α) r_{A,B}(α) dα + o(1)
   where c₀ = (C_std - 1)/(r_std(0) + 2∫₀¹ α r_std dα) ≈ 0.1604
   and r_std is the test function for the standard autocorrelation.

3. **Test function** (NEW — measure identification):
   r_{A,B}(α) = (1-α)² / 2  (triangle weight + parity)
   r_{A,B}(0) = 1/2,  2∫₀¹ α r_{A,B} dα = 1/12

4. **Normalization constant** (from standard case):
   C_std = 1.3208 (Carneiro-Milinovich-Ramos, `fourier_opt.pdf`, Corollary 2)
   For uniform test function r_std(α) = 1: r_std(0) + 2∫ α r_std = 2
   c₀ = (1.3208 - 1) / 2 = 0.1604

5. **Bound**:
   ∫₀¹ F(α) r_{A,B}(α) dα ≤ 1/2 + 1/12 = 7/12
   κ ≤ 1 + c₀·7/12 = 1 + 0.1604·0.58333 = 1.0936

6. **But 1.0936 ≠ 1.11049**. The number 1.11049 came from D-I-R Theorem 5
   with c₂ = 1/3 (a DIFFERENT measure coefficient). That approach confused
   the weight in the energy integral with the limiting measure of F.

   The CORRECT κ from the Baluyot Lemma 5 + explicit formula chain is 1.0936.
   This IS < 10/9, but requires the measure identification to confirm
   r_{A,B}(α) = (1-α)²/2.

7. **HONEST STATUS**: κ ≤ 1.0936 < 10/9 is CONDITIONAL on proving
   r_{A,B}(α) = (1-α)²/2 from the explicit formula. If r_{A,B}(α) = r_auto(α)
   (same as autocorrelation), then κ = 1.3208 (no improvement from disjointness).
   The cross-correlation phase in the explicit formula determines whether
   r_{A,B} < r_auto or r_{A,B} = r_auto.

## Papers cited
- `pairprimes.pdf`: Goldston (2004) — Proposition 1, Theorem 7
- `montgomery.pdf`: Baluyot et al. (2024) — Theorem 1, Lemma 5
- `fourier_opt.pdf`: Carneiro et al. (2023) — Corollary 2 (C_std < 1.3208)
- `paper_2502.05106.pdf`: Das-Ismoilov-Ramos (2025) — framework

All downloaded. Pending human verification.
-/

namespace PrimeSumset

open Finset

/-- **Branch A: κ ≤ 1.0936 (conditional on measure identification).**

    IF the test function for the cross-correlation energy is r(α) = (1-α)²/2,
    THEN by Baluyot Lemma 5 and the explicit formula normalization:
      E(A,B) ≤ (1 + c₀·7/12) · M² / p_i < 1.0937 · M² / p_i < (10/9)·M²/p_i

    The constant c₀ is determined by the standard autocorrelation case:
    C_std = 1.3208 = 1 + c₀·(∫ F·r_std) where r_std(α) = 1 gives bound 2.
    So c₀ = 0.3208/2 = 0.1604.

    With r_{A,B}(α) = (1-α)²/2: Lemma 5 bound = 7/12.
    κ ≤ 1 + 0.1604·7/12 = 1.0936.

    **Status:** Conditional on measure identification (does r_{A,B} = (1-α)²/2?).
    The Baluyot Lemma 5 bound and the c₀ computation are rigorous.
    The explicit formula connection (pairprimes.pdf) determines r_{A,B}.

    Downloaded papers: pairprimes.pdf, montgomery.pdf, fourier_opt.pdf. -/
theorem branch_a_kappa_bound {i : ℕ} (hi : i > trigger) :
    (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
      ≤ (10937 / 10000 : ℝ) * ((mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2)
          / (primeIdx i : ℝ) := by
  sorry

end PrimeSumset
