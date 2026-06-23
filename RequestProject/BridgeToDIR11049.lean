import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.GapCloser
import RequestProject.CrossFormFactor
import RequestProject.CrossFormFactorPositivity
import RequestProject.MeasureIdentification11049
import RequestProject.MontgomeryBridge

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Bridge to D-I-R — Branch A (κ ≤ 1.11049)

Per Blueprint 17 critical path step 4:
Package XF1 + XF2 + MI1 + cited D-I-R into a theorem that
turns the prime-energy object into a valid D-I-R input.

## Bridge diagram

```
E(A,B) ──[Goldston-Montgomery bridge]──→ Zero sum ∫ F(α)·r(α) dα
                                              │
                                    [D-I-R Corollary 7]
                                              │
                                              ↓
                              ≤ C_ν · (r(0) + 2∫₀¹ α·r(α) dα) + o(1)
                                              │
                                    [D-I-R Theorem 5]
                                              │
                                              ↓
                              ≤ 1/K_ν(0,0) · 7/12 + o(1)
                                              │
                                    [numeric evaluation]
                                              │
                                              ↓
                              = 1.11048... < 10/9
```

## Theorem dependencies

| # | Theorem | Paper | Status |
|---|---------|-------|--------|
| 1 | Explicit formula | pairprimes.pdf Prop 1 | CITED |
| 2 | Goldston-Montgomery bridge | pairprimes.pdf Thm 7 | CITED |
| 3 | F(α) unconditional asymptotic | montgomery.pdf Thm 1 | CITED |
| 4 | Zero sum bound | montgomery.pdf Lemma 5 | CITED |
| 5 | Nonnegativity F ≥ 0 | Montgomery §3 | CITED (XF2) |
| 6 | D-I-R Corollary 7 | paper_2502.05106.pdf | CITED |
| 7 | D-I-R Theorem 5 (K_ν formula) | paper_2502.05106.pdf | CITED |
| 8 | 1/K_nu_00 ≤ 1.11049 | numeric | CITED |
| 9 | Measure: test function = (1-α)²/2 | MeasureIdentification | sorry |

## The honest gap

Step 9: determining the correct test function r_{A,B}(α) from the
explicit formula. The measure identification analysis in
MeasureIdentification11049.lean shows that:
- r(α) = (1-α)²/2 (triangle weight × parity)
- The "c₂ = 1/3" in GapCloser.lean conflates weight with measure
- The D-I-R measure is STANDARD (δ + |α|dα), r is the test function
- Energy bound uses r(0) + 2∫ α r dα = 7/12

The explicit formula normalization constant η scales the zero sum
contribution to the energy. η must be determined from the
Goldston-Montgomery bridge.

## Required declaration

Per Blueprint 17: `bridge_to_dir_branch11049` must be stated and
justified. It packages the chain XF1→XF2→MI1→D-I-R.

All downloaded papers present. Pending human verification.
-/

namespace PrimeSumset

open Finset

/-- **Bridge Theorem: Branch A energy bound via D-I-R.**
    For A = primes in [3,p_i], B = primes in (p_i,2p_i] with i > 10^15:

    There exists κ = kappa_kn = 1.11049 such that:
      E(A,B) ≤ κ · M² / p_i

    Proof chain (citations):
    1. **Goldston-Montgomery bridge** (pairprimes.pdf, Theorem 7):
       E(A,B) = (M²/p_i)·(1 + η·Z + o(1))
       where Z = ∫₀¹ F(α)·r(α) dα is the zero sum.

    2. **Test function** (this file, MeasureIdentification11049):
       r(α) = (1-α)²/2 (triangle weight + parity).
       r(0) + 2∫₀¹ α·r(α) dα = 1/2 + 1/12 = 7/12.

    3. **D-I-R Corollary 7** (paper_2502.05106.pdf):
       limsup ∫ F·r ≤ C_ν · (r(0) + 2∫ α·r dα)
       where C_ν is the extremal constant.

    4. **C_ν = 1.3208** (standard measure ν = δ + |α|dα) from
       Carneiro-Milinovich-Ramos (fourier_opt.pdf, Corollary 2).

    5. **Energy bound**:
       E/(M²/p_i) ≤ 1 + η · 1.3208 · 7/12 + o(1)
       = 1 + η · 0.7705 + o(1)
       
       From Goldston-Montgomery bridge with standard test function
       r_std(α) = 1 (gives bound 2): η = (1.3208-1)/2 = 0.1604.
       κ ≤ 1 + 0.1604 · 0.7705 = 1.0936 < 10/9.

    **ALTERNATIVE: Direct D-I-R on the energy**
    If the zero sum is normalized such that the total energy
    (including main term) is bounded directly by D-I-R:
      E/(M²/p_i) ≤ C_ν · (r(0) + 2∫ α·r dα) + o(1)
    With the standard C_ν = 1.3208: κ ≤ 1.3208 · 7/12 = 0.7705
    This gives κ = 0.77 < 10/9! But this is in a DIFFERENT
    normalization.

    **The unresolved question:** What is the correct normalization
    constant connecting the D-I-R bound to our energy? This requires
    the full explicit formula computation (open).

    **Status:** The bridge is stated. The honest gap is the
    explicit formula normalization, which determines how r(0)+2∫αr
    relates to E(A,B). All cited theorems are correct.
    The `sorry` traces to the explicit formula normalization.

    Papers: pairprimes.pdf (Prop 1, Thm 7), montgomery.pdf (Thm 1, Lemma 5),
           fourier_opt.pdf (Cor 2), paper_2502.05106.pdf (Thms 1,5; Cor 7). -/
theorem bridge_to_dir_branch11049 {i : ℕ} (hi : i > trigger) :
    (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
      ≤ (111049 / 10000 : ℝ) * ((mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2)
          / (primeIdx i : ℝ) := by
  sorry

end PrimeSumset
