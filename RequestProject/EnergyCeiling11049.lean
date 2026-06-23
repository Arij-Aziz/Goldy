import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.EnergyUpperBound
import RequestProject.GapCloser
import RequestProject.BridgeToDIR11049
import RequestProject.MontgomeryBridge

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Energy Ceiling — Branch A (κ ≤ 1.11049)

Per Blueprint 17 critical path step 5:
Deduce the explicit bound below 10/9, then pass through the
already formalized Cauchy-Schwarz contradiction layer.

This file provides the FINAL theorem that fills the
`energy_ceiling` obligation in `EnergyUpperBound.lean`.

## The bridge

The proof assembles:
1. `kappa_kn_lt_target` (GapCloser.lean) — PROVED: 1.11049 < 10/9
2. `bridge_to_dir_branch11049` — CITED/stub: E ≤ kappa_kn · M²/p_i

The bridge itself traces to:
- Goldston-Montgomery bridge (pairprimes.pdf)
- D-I-R Theorem 5 (paper_2502.05106.pdf)
- Numerical evaluation of D-I-R kernel

All papers downloaded. Pending human verification.

## Required declaration

Per Blueprint 17: `energy_ceiling` from `EnergyUpperBound.lean`
must be filled. This file provides `energy_ceiling_11049` which
satisfies the same signature, enabling `MainTheorem.lean` to
compile with `|C| > 0.9·p_i`.

## Status

The numeric inequality `kappa_kn < 10/9` is PROVED.
The energy bound `E ≤ kappa_kn · M²/p_i` is CONDITIONAL on:
1. Goldston-Montgomery bridge (pairprimes.pdf Theorem 7)
2. D-I-R Corollary 7 (paper_2502.05106.pdf)
3. Measure identification: test function r(α) = (1-α)²/2
   (MeasureIdentification11049.lean)

All cited from downloaded papers. The honest `sorry` traces
to the explicit formula normalization.
-/

namespace PrimeSumset

open Finset

/-- **Energy Ceiling — Branch A (κ = 1.11049).**
    For i > 10^15: E(A,B) ≤ 1.11049 · M² / p_i.

    Consequence: since 1.11049 < 10/9, by Cauchy-Schwarz
    (AdditiveEnergy.sumset_lower_of_energy_ceiling):
    |C| = |A+B| > 0.9 · p_i. -/
theorem energy_ceiling_11049 {i : ℕ} (hi : i > trigger) :
    ∃ κ : ℝ, κ < 10 / 9 ∧
      (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
        ≤ κ * (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
            / (primeIdx i : ℝ) := by
  have hκ : kappa_kn < (10 : ℝ) / 9 := kappa_kn_lt_target
  refine ⟨kappa_kn, hκ, ?_⟩
  -- The energy bound delegates to the bridge theorem.
  -- The bridge itself delegates to:
  --   1. Goldston-Montgomery bridge (pairprimes.pdf Thm 7) — CITED
  --   2. Measure identification (MeasureIdentification11049.lean) — OPEN
  --   3. D-I-R Theorem 5 (paper_2502.05106.pdf) — CITED
  sorry

/-- **Main Theorem via Branch A.**
    |C| > 0.9·p_i for i > 10^15.

    Proof: energy_ceiling_11049 gives κ < 10/9,
    then Cauchy-Schwarz compression yields the bound. -/
theorem sumset_card_gt_nine_tenths_branch11049 {i : ℕ} (hi : i > trigger) :
    0.9 * (primeIdx i : ℝ)
      < ((sumset (Aset (primeIdx i)) (Bset (primeIdx i))).card : ℝ) := by
  have h3 : 3 ≤ primeIdx i := three_le_primeIdx_of_trigger hi
  have hxpos : 0 < (primeIdx i : ℝ) := by
    have : 0 < primeIdx i := by omega
    exact_mod_cast this
  have hMpos : 0 < (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) := by
    exact_mod_cast mass_pos h3
  obtain ⟨κ, hκ, hE⟩ := energy_ceiling_11049 hi
  exact sumset_lower_of_energy_ceiling _ _ _ _ hxpos hMpos hκ hE

end PrimeSumset
