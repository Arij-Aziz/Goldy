import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.RestrictedGoldbachDefs
import RequestProject.RestrictedGoldbachCombinatorics
import RequestProject.RestrictedGoldbachMajorArc
import RequestProject.RestrictedGoldbachSingularSeries
import RequestProject.RestrictedGoldbachExceptionalSet
import RequestProject.RestrictedGoldbachMain
import RequestProject.MainTheorem
import RequestProject.Goldbach

/-!
# Axiom audit

This module imports every file directly needed by the twenty most important
theorems of the development and runs `#print axioms` on each.
Running this file prints, for each theorem, the exact set of axioms it
transitively depends on.

Reading the output:

* Theorems depending only on `propext`, `Classical.choice`, `Quot.sound`
  are fully machine-checked.
* Theorems whose dependency list contains `sorryAx` rest on the project's
  remaining Tier-1 analytic citation burden (`restricted_exceptional_bound`).
-/

-- ## Main result — strongest density constant (0.95)
#check RestrictedGoldbach.sumset_card_gt_95
#print axioms RestrictedGoldbach.sumset_card_gt_95

-- ## Main result — 0‑indexed framing
#check PrimeSumset.sumset_card_gt_95
#print axioms PrimeSumset.sumset_card_gt_95

-- ## Goldbach density bound (0.95)
#check PrimeSumset.goldbach_density
#print axioms PrimeSumset.goldbach_density

-- ## Goldbach exceptional‑set bound (0.05)
#check PrimeSumset.goldbach_exception_bound
#print axioms PrimeSumset.goldbach_exception_bound

-- ## Tier‑1 analytic gap (Pintz circle method, cited)
#check RestrictedGoldbach.restricted_exceptional_bound
#print axioms RestrictedGoldbach.restricted_exceptional_bound

-- ## Main combinatorial identity: |C| = pᵢ − |Eₓ|
#check RestrictedGoldbach.card_sumset_eq_pi_sub_eset
#print axioms RestrictedGoldbach.card_sumset_eq_pi_sub_eset

-- ## Inequality form in ℝ
#check RestrictedGoldbach.sumset_card_ge_pi_sub_eset
#print axioms RestrictedGoldbach.sumset_card_ge_pi_sub_eset

-- ## Cauchy–Schwarz compression: M² ≤ |C|·E
#check PrimeSumset.cauchy_schwarz_compression
#print axioms PrimeSumset.cauchy_schwarz_compression

-- ## Research‑ladder reduction: |C| ≥ x/κ
#check PrimeSumset.sumset_card_ge_of_energy_ceiling
#print axioms PrimeSumset.sumset_card_ge_of_energy_ceiling

-- ## Identity 1: E = Σ r²
#check PrimeSumset.energy_eq_sum_sq
#print axioms PrimeSumset.energy_eq_sum_sq

-- ## Identity 2: E = Σ r_A·r_B
#check PrimeSumset.energy_eq_diff_corr
#print axioms PrimeSumset.energy_eq_diff_corr

-- ## Fundamental sum identity: Σ r = M
#check PrimeSumset.sum_rAdd
#print axioms PrimeSumset.sum_rAdd

-- ## Parity: every sum a+b is even
#check RestrictedGoldbach.add_Aset_Bset_even
#print axioms RestrictedGoldbach.add_Aset_Bset_even

-- ## Range: a+b ∈ (pᵢ, 3pᵢ]
#check RestrictedGoldbach.add_Aset_Bset_range
#print axioms RestrictedGoldbach.add_Aset_Bset_range

-- ## Even count in the target interval
#check RestrictedGoldbach.card_evens_Ico
#print axioms RestrictedGoldbach.card_evens_Ico

-- ## Major‑arc asymptotic (Obligation A, Tier‑1 stub)
#check RestrictedGoldbach.restricted_major_arc_asymptotic
#print axioms RestrictedGoldbach.restricted_major_arc_asymptotic

-- ## Membership: 0 < r_{A+B}(N) ↔ N ∈ A+B
#check RestrictedGoldbach.rAdd_pos_iff
#print axioms RestrictedGoldbach.rAdd_pos_iff

-- ## Positivity of 1‑indexed prime
#check RestrictedGoldbach.primeIdx1_pos
#print axioms RestrictedGoldbach.primeIdx1_pos

-- ## Trigger threshold: pᵢ ≥ 3 above 10^15
#check PrimeSumset.three_le_primeIdx_of_trigger
#print axioms PrimeSumset.three_le_primeIdx_of_trigger

-- ## Mass positivity: |A|·|B| > 0
#check PrimeSumset.mass_pos
#print axioms PrimeSumset.mass_pos
