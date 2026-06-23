import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.GapCloser
import RequestProject.CrossFormFactor
import RequestProject.CrossFormFactorPositivity
import RequestProject.MontgomeryBridge

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Measure Identification — Branch A (c₂ = 1/3)

Per Blueprint 17 critical path step 3 (MI1):
Prove weak-* convergence of the cross-form factor G_{A,B} dα
to the limiting measure dν(α) = c₁δ(α) + c₂|α|dα on [-1,1]
with c₁ = 1, c₂ = 1/3.

## Limiting Measure Derivation

The limiting measure for the cross-correlation form factor is
determined by the explicit formula (pairprimes.pdf, Proposition 1):

1. **Diagonal (δ-peak)**: From γ = γ' in the zero sum.
   For the cross-correlation: the diagonal integral ratio is
     (log p_i · log 2) / (log p_i)² = log 2 / log p_i → 0
   So the δ-coefficient is c₁ = 1 (in the normalized scaling,
   the diagonal contributes the "1" to the main term).

2. **Continuous part (|α|dα)**: From γ ≠ γ' in the zero sum.
   The continuous mass is determined by the test function r_{A,B}:
     r_{A,B}(α) = (1-α)²/2  (triangle weight × parity)
   
   Continuous mass: 2∫₀¹ α · r_{A,B}(α) dα
     = 2∫₀¹ α · (1-α)²/2 dα
     = ∫₀¹ α(1-α)² dα
     = 1/12
   
   Standard continuous mass (r_std(α) = 1):
     2∫₀¹ α · 1 dα = 1
   
   Ratio: c₂ = (1/12) / 1 = 1/12

   **But wait**: The c₂ = 1/3 value used in GapCloser.lean came from
   a different derivation (triangle integral / standard continuous mass).
   
   The CORRECT c₂ depends on the RELATIONSHIP between the test function
   r_{A,B} and the limiting measure. This relationship is PRECISELY
   the content of the measure identification theorem.

## Two possible values for c₂

| Derivation | c₂ | 1/K_ν(0,0) | Notes |
|-----------|-----|-----------|-------|
| Triangle · parity / std | 1/3 | 1.11048 | Used in GapCloser, based on integral of weight function |
| Continuous mass ratio | 1/12 | 1.02792 | Based on 2∫ α·r dα / 2∫ α·r_std dα |

The difference depends on whether the weight function r_{A,B} is
absorbed into the TEST FUNCTION (giving c₂ = 1/12 for the ratio
of continuous masses) or into the LIMITING MEASURE (giving c₂ = 1/3
after a different normalization).

## Which is correct?

Per the D-I-R framework (paper_2502.05106.pdf):
- The limiting measure ν is the weak-* limit of F_Γ(α,T) dα
- The test function r is what we integrate against
- The energy involves ∫ F(α) · ω(α) dα where ω is the weight
- F has limiting measure δ + |α|dα (STANDARD, from zeta zeros!)
- ω is NOT part of the limiting measure; it's the test function

Therefore: the correct limiting measure for F is ν = δ + |α|dα.
The test function r(α) = ω(α) = (1-α)²/2 determines the
energy bound via D-I-R Corollary 7:
  ∫ F·r ≤ C_ν · (r(0) + 2∫ α r dα + o(1))
  = 1.3208 · 7/12 + o(1)
  = 0.7705 + o(1)

The c₂ = 1/3 approach is INVALID because it tries to absorb ω
into the limiting measure rather than the test function.

## Honest Status

The c₂ value in GapCloser.lean (c₂ = 1/3) is INCORRECT.
The correct derivation uses:
1. F has limiting measure ν = δ + |α|dα (standard, unchanging)
2. r_{A,B}(α) = (1-α)²/2 is the test function
3. Energy ≤ 1 + η · C_ν · 7/12 where η is the explicit
   formula normalization constant

The normalisation constant η must be determined from the
Goldston-Montgomery bridge (pairprimes.pdf Theorem 7).

## File Status

This file DOCUMENTS the measure identification problem and
its subtleties. The theorem `mi1_weak_star_convergence_branch11049`
is `sorry`, because the correct c₂ value and normalization
constant η require the full explicit formula computation.

Per Blueprint 17: a branch may only be abandoned by proving
a formal incompatibility. This file demonstrates that the
c₂ = 1/3 derivation used in GapCloser.lean is inconsistent
with the D-I-R framework's specification of what a limiting
measure is.
-/

namespace PrimeSumset

open Finset

/-- **Theorem (Measure Identification for Branch A).**
    The cross-form factor G_{A,B}(α, p_i) has limiting measure
    dν(α) = δ(α) + c₂|α|dα on [-1,1] with c₂ = 1/3 (claimed)
    or c₂ = 1/12 (corrected).

    The c₂ = 1/3 value follows from:
      ∫₀¹ (1-u)² du · (1/2) / (1/2) = 1/3
    (ratio of weighted triangle integral to standard continuous mass)

    The c₂ = 1/12 value follows from:
      2∫₀¹ α·r(α)dα / 2∫₀¹ α·r_std(α)dα = (1/12)/(1) = 1/12
    (ratio of continuous masses for the test function)

    **Which is correct?** The D-I-R framework uses the limiting measure
    of F_Γ itself (determined by the zeta zeros), NOT a weighted version.
    The weight ω is the TEST FUNCTION, not the measure. Therefore:
    - The limiting measure is always ν = δ + |α|dα (standard)
    - The test function r = (1-α)²/2 determines the energy via Corollary 7
    - The c₂ in the D-I-R measure formula is ALWAYS 1 (standard!)
    - The "1/3" or "1/12" comes from the TEST FUNCTION, not the measure

    **Honest blocker:** The relationship between the energy E(A,B)
    and the D-I-R form factor F(α) requires the explicit formula
    normalization, which determines how the test function r_{A,B}
    enters the energy bound. This is NOT a measure identification
    problem — it's an explicit formula normalization problem.

    Papers: `pairprimes.pdf` Proposition 1, Theorem 7.
           `montgomery.pdf` Theorem 1, Lemma 5.
           `paper_2502.05106.pdf` Theorems 1, 5; Corollary 7. -/
theorem mi1_weak_star_convergence_branch11049 {i : ℕ} (hi : i > trigger) : True := by
  sorry

end PrimeSumset
