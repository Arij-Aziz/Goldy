import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.Blueprint12
import RequestProject.GapCloser
import RequestProject.CrossFormFactor
import RequestProject.CrossFormFactorPositivity
import RequestProject.MeasureIdentification10677
import RequestProject.MontgomeryBridge

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Bridge to D-I-R — Branch B (κ ≤ 1.0677)

Per Blueprint 17 critical path step 4:
Package XF1 + XF2 + MI1 + cited D-I-R into a theorem that
turns the prime-energy object into a valid D-I-R input.

## Bridge diagram (Exponential Branch)

```
E(A,B) ──[G-M bridge]──→ ∫ F(α)·r(α) dα (zero sum)
                              │
                    r(α) ≤ (1/2)e^{-2|α|}  [PROVED, Blueprint12]
                              │
                    F(α) ≥ 0  [XF2, cited]
                              │
                              ↓
                         ∫ F·r ≤ ∫ F·(1/2)e^{-2|α|} dα
                              │
                    [D-I-R Theorem 6]
                              │
                              ↓
                         ≤ 1/K_ν(0,0) · Φ_ν + o(1)
                              │
                    [Numerical: K ≈ 0.9366253]
                              │
                              ↓
                         = 1.06766... < 10/9
```

## Advantages over Branch A

1. **Exponential bound is PROVED in Lean** (Blueprint12.lean):
   (1-α)² ≤ e^{-2α} → (1-α)²/2 ≤ (1/2)e^{-2α}

2. **The measure inequality is VALID**: Since F ≥ 0 (XF2),
   r ≤ (1/2)e^{-2|α|} pointwise implies
   ∫ F·r ≤ ∫ F·(1/2)e^{-2|α|} dα.
   This is elementary measure theory — no sign issues!

3. **D-I-R Theorem 6 directly applies** to the exponential measure.

4. **Bigger margin**: κ = 1.0677 vs 1.1105 (Branch A).
   Margin to 10/9 is 0.043 vs 0.0006.

## Key inequality

The exponential domination: (1-α)² ≤ e^{-2α} for α ∈ [0,1].
Proof: f(α) = e^{-2α} - (1-α)², f(0) = 0, f'(α) = -2e^{-2α}+2(1-α),
f'(0) = 0, f''(α) = 4e^{-2α}-2 ≥ 0 for α ∈ [0, (log 2)/2] ≈ [0, 0.347].
For α > (log 2)/2: (1-α)² ≤ 1 ≤ e^{-2α} (since e^{-2α} ≥ e^{-2} ≈ 0.135)
for α ∈ [0.347, 0.816], and (1-α)² < (1-0.816)² ≈ 0.034 < e^{-2·0.816}
= 0.196. The full proof uses `Real.add_one_le_exp` in Lean.

## What remains the gap

The explicit formula normalization. The G-M bridge determines how
the integral ∫ F·r relates to E(A,B). The exponential bound
controls the MEASURE but not the NORMALIZATION.

## Required declaration

Per Blueprint 17: `bridge_to_dir_branch10677`.

Papers: pairprimes.pdf (Prop 1, Thm 7), montgomery.pdf (Thm 1),
       paper_2502.05106.pdf (Thm 6, Lemma 14).
-/

namespace PrimeSumset

open Finset

/-- **Bridge Theorem: Branch B energy bound via exponential D-I-R.**
    For A = primes in [3,p_i], B = primes in (p_i,2p_i] with i > 10^15:

    There exists κ ≤ 1.0677 such that:
      E(A,B) ≤ κ · M² / p_i

    Proof chain:
    1. **XF1** (CrossFormFactor.lean): E/(M²/p_i) = 1 + η·∫ F·r + o(1)
       where r(α) = (1-α)²/2. [cited from pairprimes.pdf]
    
    2. **Exponential bound** (Blueprint12.lean, PROVED):
       r(α) = (1-α)²/2 ≤ (1/2)e^{-2α} = (1/2)e^{-2|α|} for α ∈ [0,1].
    
    3. **XF2** (CrossFormFactorPositivity.lean, CITED):
       F(α) ≥ 0. Therefore: ∫ F·r ≤ ∫ F·(1/2)e^{-2|α|} dα.
    
    4. **D-I-R Theorem 6** (paper_2502.05106.pdf, CITED):
       For dν = δ + (1/2)|α|e^{-2|α|}dα: C_ν ≤ 1/K_ν(0,0) ≈ 1.0677.
    
    5. **Energy bound**:
       E/(M²/p_i) ≤ η · C_ν + o(1) ≤ η · 1.0677 + o(1)
       
       The normalization η depends on the explicit formula.
       If η = 1 (direct D-I-R on normalized energy):
       κ ≤ 1.0677 < 10/9.
       
       If η = 0.1604 (indirect, via test function):
       κ ≤ 1 + 0.1604 · 0.0677 = 1.0109 < 10/9.

    **Status:** The exponential inequality is PROVED. The D-I-R
    Theorem 6 kernel is CITED (numerical verification available).
    The normalization η requires the explicit formula (open `sorry`).

    Papers: pairprimes.pdf, montgomery.pdf, paper_2502.05106.pdf. -/
theorem bridge_to_dir_branch10677 {i : ℕ} (hi : i > trigger) :
    (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
      ≤ (10677 / 10000 : ℝ) * ((mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2)
          / (primeIdx i : ℝ) := by
  sorry

end PrimeSumset
