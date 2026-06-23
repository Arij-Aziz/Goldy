import Mathlib

/-!
# The reproducing-kernel extremal principle (Das–Ismoilov–Ramos, Lemma 4 core)

This module gives a **fully formalized, self-contained** proof of the abstract
mathematical engine underlying the Das–Ismoilov–Ramos (2025, arXiv:2502.05106)
reproducing-kernel framework — specifically the reduction in their **Lemma 4**,

  `Cν ≤ 1 / Kν(0,0)`.

## Dictionary to the paper

In D-I-R, one works in the weighted Paley–Wiener space `Hν = PW(π∆)` equipped
with the inner product `⟪f, g⟫ν = ∫_ℝ f(x) g(x) ν̂(x) dx` (their (1.11)–(1.13)),
which is a reproducing kernel Hilbert space whenever `(c₂/c₁)∆² ≤ 5/3`
(their Theorem 3). Writing `K = Kν` for the reproducing kernel, the section
`k := Kν(0, ·) ∈ Hν` satisfies the *reproducing property*

  `f(0) = ⟪f, k⟫ν`  for all `f ∈ Hν`,   and   `Kν(0,0) = ⟪k, k⟫ν`.

Under this dictionary the present file proves, **in an arbitrary real inner
product space**, the two purely Hilbert-space facts that the framework rests on:

* `eval_sq_le` — the Cauchy–Schwarz bound `f(0)² = ⟪f,k⟫² ≤ Kν(0,0) · ‖f‖²ν`.
* `rkhs_extremal` — the sharp constant: `Kν(0,0) = sup_{f≠0} f(0)² / ‖f‖²ν`,
  attained at `f = k`. This is the primal extremal identity.
* `rkhs_dual_extremal` — the **dual** identity that is D-I-R's Lemma 4 verbatim:
  the minimum of `‖f‖²ν` over all `f` with `f(0) = 1` equals `1 / Kν(0,0)`.
  Since `Cν` is exactly this minimal energy of the normalized extremal problem
  (EP1), this is the equality `Cν = 1 / Kν(0,0)` of which Lemma 4 keeps the `≤`.

The only ingredient is Cauchy–Schwarz (`real_inner_mul_inner_self_le`); the
analytic content of the framework (that `Hν` is an RKHS, and the *value* of
`Kν(0,0)` from their Theorems 5/6) is orthogonal to this extremal principle and
is what the rest of the project records as cited input.

These statements are general theorems about real inner product spaces and carry
no `sorry`.
-/

namespace PrimeSumset.DIR

open RealInnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- For `k ≠ 0` the self-inner-product is strictly positive (this is `Kν(0,0) > 0`). -/
lemma inner_self_pos_of_ne_zero {k : E} (hk : k ≠ 0) : 0 < ⟪k, k⟫ := by
  rcases (real_inner_self_nonneg (x := k)).lt_or_eq with h | h
  · exact h
  · exact absurd (inner_self_eq_zero.mp h.symm) hk

/-- **Cauchy–Schwarz / reproducing bound.**
For any `f` and the kernel section `k`, `⟪f, k⟫² ≤ ⟪f, f⟫ · ⟪k, k⟫`.
Under the dictionary `f(0) = ⟪f, k⟫`, `Kν(0,0) = ⟪k,k⟫`, `‖f‖²ν = ⟪f,f⟫`,
this is `f(0)² ≤ Kν(0,0) · ‖f‖²ν`. -/
theorem eval_sq_le (f k : E) : ⟪f, k⟫ ^ 2 ≤ ⟪f, f⟫ * ⟪k, k⟫ := by
  have h := real_inner_mul_inner_self_le f k
  nlinarith [h]

/-- **Primal extremal identity (sharp constant).**
For `k ≠ 0`, the value `⟪k, k⟫ = Kν(0,0)` is the greatest value of the Rayleigh
quotient `f ↦ ⟪f, k⟫² / ⟪f, f⟫` over nonzero `f`, attained at `f = k`. -/
theorem rkhs_extremal (k : E) (hk : k ≠ 0) :
    IsGreatest {t : ℝ | ∃ f : E, f ≠ 0 ∧ t = ⟪f, k⟫ ^ 2 / ⟪f, f⟫} ⟪k, k⟫ := by
  have hkpos : 0 < ⟪k, k⟫ := inner_self_pos_of_ne_zero hk
  constructor
  · refine ⟨k, hk, ?_⟩
    field_simp
  · rintro t ⟨f, hf, rfl⟩
    have hfpos : 0 < ⟪f, f⟫ := inner_self_pos_of_ne_zero hf
    rw [div_le_iff₀ hfpos]
    have := eval_sq_le f k
    nlinarith [this]

/-- **Dual extremal identity — Das–Ismoilov–Ramos Lemma 4 (as an equality).**
For `k ≠ 0`, the least value of the energy `⟪f, f⟫` over all `f` normalized by
`⟪f, k⟫ = 1` equals `1 / ⟪k, k⟫`.

Under the dictionary this is: the minimum of `‖f‖²ν` over `f ∈ Hν` with `f(0)=1`
equals `1 / Kν(0,0)`. Since the D-I-R extremal constant `Cν` is precisely this
minimal energy of (EP1), this gives `Cν = 1 / Kν(0,0)`, sharpening the `≤` of
their Lemma 4. The minimizer is `f = k / Kν(0,0)`. -/
theorem rkhs_dual_extremal (k : E) (hk : k ≠ 0) :
    IsLeast {t : ℝ | ∃ f : E, ⟪f, k⟫ = 1 ∧ t = ⟪f, f⟫} (1 / ⟪k, k⟫) := by
  have hkpos : 0 < ⟪k, k⟫ := inner_self_pos_of_ne_zero hk
  constructor
  · refine ⟨(⟪k, k⟫)⁻¹ • k, ?_, ?_⟩
    · rw [real_inner_smul_left]
      field_simp
    · rw [real_inner_smul_left, real_inner_smul_right]
      field_simp
  · rintro t ⟨f, hf1, rfl⟩
    rw [div_le_iff₀ hkpos]
    have hcs := eval_sq_le f k
    rw [hf1] at hcs
    nlinarith [hcs]

end PrimeSumset.DIR
