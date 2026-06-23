import Mathlib
import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.Goldbach

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Goldbach density with one prime in the Baker–Harman–Pintz short interval

This module addresses the additional requested result:

> For all sufficiently large `x`, at least `90.4%` of even integers in `(x, 3x]`
> are the sum of a prime `p₁ ≤ x` and a prime `p₂` in the BHP short interval
> `(x, x + x^0.525]`.

Here `x^0.525 = x^(21/40)`, and the relevant prime sets are

* `A = Aset x = {p prime : 3 ≤ p ≤ x}`  (the project's `Aset`, primes `≤ x`;
  `2` is harmlessly excluded — it never contributes to an *even* representation
  paired with another odd prime), and
* `B = Bbhp x = {p prime : x < p ≤ x + ⌊x^0.525⌋}`  (primes in the BHP short
  interval).

## The literal statement, over `(x, 3x]`, is false

If `p₁ ≤ x` and `p₂ ≤ x + x^0.525`, then `p₁ + p₂ ≤ 2x + x^0.525 < 3x` for all
large `x` (since `x^0.525 < x`).  Hence **no** even integer in
`(2x + x^0.525, 3x]` is representable, and that sub-interval already contains
`≈ x/2` of the `≈ x` even integers of `(x, 3x]`.  So at most `≈ 50%` of the even
integers in `(x, 3x]` can ever be represented in this form — the `90.4%` claim
over `(x, 3x]` is structurally impossible.

(Concrete analog `x = 100`, `⌊x^0.525⌋ = 11`: the primes in `(100, 111]` are
`101, 103, 107, 109`, so every representable `N = p₁ + p₂` lies in `(103, 209]`;
the even integers of `(100, 300]` number `100`, of which at most `≈ 54` can lie
in `(103, 209]` — far below `90.4`.)

The user's literal statement is therefore preserved verbatim, but only as a
commented-out block below, with this explanation.

## The corrected, faithful statement

The genuine achievable output interval is the support `(x, 2x + ⌊x^0.525⌋]` of
`A + B`.  The corrected result, `bhp_goldbach_density`, states that at least
`90.4%` of the even integers in this support interval are representable as
`p₁ + p₂` with `p₁ ≤ x` prime and `p₂` a prime in the BHP short interval.

This mirrors exactly the project's main density result `goldbach_density`
(where, for `B = primes∩(x,2x]`, the support is `(x, 3x]` whose even integers
number `x`, the project's normalization).  The number of even integers in the
support is the natural normalization for the additive-energy method.

## Honest analytic obligations

As with the project's main theorem (which rests on the single honest obligation
`energy_ceiling`), the corrected result is reduced to two clearly separated
honest inputs, each left as one documented `sorry`:

* `bhp_prime_exists` — the Baker–Harman–Pintz short-interval prime theorem:
  for large `x`, `(x, x + x^0.525]` contains a prime.  (This is a genuine deep
  analytic theorem, not in Mathlib.)  It supplies `B ≠ ∅`, hence `M > 0`.
* `energy_ceiling_bhp` — the additive-energy ceiling
  `E(A,B) ≤ (1.1053)·M²/D`, where `D` is the number of even integers in the
  support and `1.1053 = 1/K_ν(0,0)` is the reproducing-kernel value (exactly
  the constant used by `energy_ceiling`; for the project's configuration the
  number of even integers in the support equals `x`, so this is the faithful
  generalization of `energy_ceiling`).

Everything else — the parity and support-range structure, and the
Cauchy–Schwarz/energy reduction `ceiling ⇒ density` — is fully machine-checked
on top of these two obligations (the reduction reuses
`AdditiveEnergy.sumset_card_ge_of_energy_ceiling`).
-/

namespace PrimeSumset

open Finset

/-- The BHP threshold above which the short-interval prime theorem is invoked.
(The genuine BHP theorem holds for all sufficiently large `x`; we record a
concrete large trigger, matching the scale of the project's `trigger`.) -/
def bhpTrigger : ℕ := 10 ^ 15

/-- The BHP short-interval length `⌊x^0.525⌋ = ⌊x^(21/40)⌋`. -/
noncomputable def bhpLen (x : ℕ) : ℕ := ⌊(x : ℝ) ^ (21 / 40 : ℝ)⌋₊

/-- `B = {p prime : x < p ≤ x + ⌊x^0.525⌋}`, the primes in the BHP short
interval, as a finite set of integers. -/
noncomputable def Bbhp (x : ℕ) : Finset ℤ :=
  (((Finset.Ioc x (x + bhpLen x)).filter (fun n => Nat.Prime n)).image
    (fun n => (n : ℤ)))

/-- The support interval of `A + B`: `(x, 2x + ⌊x^0.525⌋]`. -/
noncomputable def bhpSupport (x : ℕ) : Finset ℤ :=
  Finset.Ioc (x : ℤ) (2 * x + bhpLen x)

/-- The number of even integers in the support interval `(x, 2x + ⌊x^0.525⌋]`.
This is the normalization (denominator) for the density statement. -/
noncomputable def bhpEvenCount (x : ℕ) : ℕ :=
  ((bhpSupport x).filter (fun n => Even n)).card

/-! ### Parity and support-range structure (fully proved) -/

/-- Every element of `Bbhp x` is odd (for `x ≥ 2`, primes `> x` are `≠ 2`). -/
lemma Bbhp_odd {x : ℕ} (hx2 : 2 ≤ x) {b : ℤ} (hb : b ∈ Bbhp x) : Odd b := by
  simp [Bbhp] at hb
  obtain ⟨n, ⟨⟨hlt, _⟩, hp⟩, rfl⟩ := hb
  exact (Int.odd_coe_nat n).mpr (hp.odd_of_ne_two (by omega))

/-- Any representable `N` (for `x ≥ 2`) is even: it is a sum of two odd primes. -/
lemma rAdd_bhp_pos_even {x : ℕ} (hx2 : 2 ≤ x) {N : ℤ}
    (hN : 0 < rAdd (Aset x) (Bbhp x) N) : Even N := by
  rw [rAdd_pos_iff, Finset.mem_add] at hN
  obtain ⟨a, ha, b, hb, rfl⟩ := hN
  exact (Aset_odd ha).add_odd (Bbhp_odd hx2 hb)

/-- Any representable `N` lies in the support interval `(x, 2x + ⌊x^0.525⌋]`. -/
lemma rAdd_bhp_pos_mem_support {x : ℕ} {N : ℤ}
    (hN : 0 < rAdd (Aset x) (Bbhp x) N) : N ∈ bhpSupport x := by
  rw [rAdd_pos_iff, Finset.mem_add] at hN
  obtain ⟨a, ha, b, hb, rfl⟩ := hN
  simp [Aset] at ha
  simp [Bbhp] at hb
  obtain ⟨na, ⟨⟨h3, hax⟩, _⟩, rfl⟩ := ha
  obtain ⟨nb, ⟨⟨hxb, hb2⟩, _⟩, rfl⟩ := hb
  simp only [bhpSupport, Finset.mem_Ioc]
  constructor <;> omega

/-- The distinct sumset `A + B` is exactly the set of representable even
integers of the support; i.e. filtering the support by "even and representable"
recovers the whole sumset. -/
lemma bhp_filter_eq_sumset {x : ℕ} (hx2 : 2 ≤ x) :
    {N ∈ bhpSupport x | Even N ∧ 0 < rAdd (Aset x) (Bbhp x) N}
      = sumset (Aset x) (Bbhp x) := by
  ext N
  rw [Finset.mem_filter]
  constructor
  · rintro ⟨_, _, h⟩; rwa [rAdd_pos_iff] at h
  · intro h
    have hpos : 0 < rAdd (Aset x) (Bbhp x) N := by rw [rAdd_pos_iff]; exact h
    exact ⟨rAdd_bhp_pos_mem_support hpos, rAdd_bhp_pos_even hx2 hpos, hpos⟩

/-- The support contains the even integer `2x`, so it has at least one even
integer (`bhpEvenCount x > 0`). -/
lemma bhpEvenCount_pos {x : ℕ} (hx : 1 ≤ x) : 0 < bhpEvenCount x := by
  apply Finset.card_pos.mpr
  refine ⟨(2 * (x : ℤ)), ?_⟩
  rw [Finset.mem_filter]
  refine ⟨?_, ⟨(x : ℤ), by ring⟩⟩
  simp only [bhpSupport, Finset.mem_Ioc]
  have hx1 : (1 : ℤ) ≤ (x : ℤ) := by exact_mod_cast hx
  have hL : (0 : ℤ) ≤ (bhpLen x : ℤ) := Int.natCast_nonneg _
  constructor
  · nlinarith
  · nlinarith

/-! ### Honest analytic obligations (one documented `sorry` each) -/

/-- **Baker–Harman–Pintz short-interval prime theorem (honest obligation).**

For all sufficiently large `x`, the short interval `(x, x + x^0.525]` contains a
prime, so `Bbhp x` is nonempty.  This is a genuine deep analytic theorem (Baker,
Harman & Pintz, 2001) that is not available in Mathlib; it is recorded as one
documented `sorry`. -/
theorem bhp_prime_exists {x : ℕ} (hx : bhpTrigger ≤ x) : (Bbhp x).Nonempty := by
  sorry

/-- **Energy ceiling for the BHP short-interval configuration (honest
obligation).**

For all sufficiently large `x`, the additive energy of `A = Aset x` (primes
`≤ x`) and `B = Bbhp x` (primes in the BHP short interval) obeys
`E(A,B) ≤ (1.1053)·M²/D`, where `M = |A|·|B|` and `D = bhpEvenCount x` is the
number of even integers in the support interval `(x, 2x + ⌊x^0.525⌋]`.

The constant `1.1053 = 1/K_ν(0,0)` is the reproducing-kernel value of the
project's `energy_ceiling`.  For the project's main configuration the number of
even integers in the support equals `x`, so this `D`-normalized ceiling is the
faithful generalization of `energy_ceiling`.  Discharging it requires the same
analytic-number-theory machinery (a Goldston–Montgomery-type bridge to prime
pair correlations plus the Das–Ismoilov–Ramos reproducing-kernel bound), which
is not in Mathlib; it is recorded as one documented `sorry`. -/
theorem energy_ceiling_bhp {x : ℕ} (hx : bhpTrigger ≤ x) :
    (energy (Aset x) (Bbhp x) : ℝ)
      ≤ (11053 / 10000 : ℝ)
          * (mass (Aset x) (Bbhp x) : ℝ) ^ 2
          / (bhpEvenCount x : ℝ) := by
  sorry

/-! ### Positivity of the mass (from BHP) -/

/-- The mass `M = |A|·|B|` is positive for large `x` (`A` nonempty since
`3 ≤ x`; `B` nonempty by Baker–Harman–Pintz). -/
lemma mass_bhp_pos {x : ℕ} (hx : bhpTrigger ≤ x) :
    0 < mass (Aset x) (Bbhp x) := by
  have h3 : 3 ≤ x := le_trans (by norm_num [bhpTrigger]) hx
  exact mul_pos (Finset.card_pos.mpr (Aset_nonempty h3))
    (Finset.card_pos.mpr (bhp_prime_exists hx))

/-! ### The corrected density result (machine-checked modulo the two
obligations) -/

/-- **Sumset lower bound (corrected core).**  For all sufficiently large `x`,
the distinct sumset `C = A + B` (with `A` the primes `≤ x` and `B` the primes in
the BHP short interval `(x, x + x^0.525]`) satisfies `|C| > 0.904·D`, where
`D = bhpEvenCount x` is the number of even integers in the support
`(x, 2x + ⌊x^0.525⌋]`. -/
theorem bhp_sumset_card_gt {x : ℕ} (hx : bhpTrigger ≤ x) :
    0.904 * (bhpEvenCount x : ℝ)
      < ((sumset (Aset x) (Bbhp x)).card : ℝ) := by
  have hDpos : 0 < (bhpEvenCount x : ℝ) := by
    have : 0 < bhpEvenCount x :=
      bhpEvenCount_pos (le_trans (by norm_num [bhpTrigger]) hx)
    exact_mod_cast this
  have hMpos : 0 < (mass (Aset x) (Bbhp x) : ℝ) := by
    exact_mod_cast mass_bhp_pos hx
  -- `|C| ≥ D/κ` with `κ = 1.1053`.
  have hge : (bhpEvenCount x : ℝ) / (11053 / 10000)
      ≤ ((sumset (Aset x) (Bbhp x)).card : ℝ) :=
    sumset_card_ge_of_energy_ceiling _ _ _ _ hDpos (by norm_num) hMpos
      (energy_ceiling_bhp hx)
  -- `0.904·D < D/κ` since `0.904 < 1/κ = 10000/11053`.
  have hlt : 0.904 * (bhpEvenCount x : ℝ) < (bhpEvenCount x : ℝ) / (11053 / 10000) := by
    rw [lt_div_iff₀ (by norm_num)]
    nlinarith [hDpos]
  linarith

/-- **BHP Goldbach density (corrected).**  For all sufficiently large `x`, at
least `90.4%` of the even integers in the support interval
`(x, 2x + ⌊x^0.525⌋]` are the sum of a prime `p₁ ≤ x` and a prime `p₂` in the
BHP short interval `(x, x + x^0.525]`.

Formally, the number of representable even integers `N` in the support exceeds
`0.904·D`, where `D = bhpEvenCount x` is the number of even integers in the
support.  Since every representable `N` is even and lies in the support, the
filtered count equals `|A + B|`, so this is `bhp_sumset_card_gt` repackaged.

(Constant `9040/10000 = 0.904`.) -/
theorem bhp_goldbach_density {x : ℕ} (hx : bhpTrigger ≤ x) :
    (9040 / 10000 : ℝ) * (bhpEvenCount x : ℝ)
      < (#{N ∈ bhpSupport x |
            Even N ∧ 0 < rAdd (Aset x) (Bbhp x) N} : ℝ) := by
  have hx2 : 2 ≤ x := by
    have : bhpTrigger ≤ x := hx
    have : (2 : ℕ) ≤ bhpTrigger := by norm_num [bhpTrigger]
    omega
  rw [bhp_filter_eq_sumset hx2]
  have hconst : (9040 / 10000 : ℝ) = 0.904 := by norm_num
  rw [hconst]
  exact bhp_sumset_card_gt hx

/-- **BHP Goldbach density (corrected) — "for all sufficiently large `x`"
form.**  Exactly the requested phrasing: there is a threshold `X₀` beyond which
at least `90.4%` of the even integers in the support interval
`(x, 2x + ⌊x^0.525⌋]` are sums `p₁ + p₂` with `p₁ ≤ x` prime and `p₂` a prime in
the BHP short interval `(x, x + x^0.525]`. -/
theorem bhp_goldbach_density_eventually :
    ∃ X₀ : ℕ, ∀ x : ℕ, X₀ ≤ x →
      (9040 / 10000 : ℝ) * (bhpEvenCount x : ℝ)
        < (#{N ∈ bhpSupport x |
              Even N ∧ 0 < rAdd (Aset x) (Bbhp x) N} : ℝ) :=
  ⟨bhpTrigger, fun _ hx => bhp_goldbach_density hx⟩

/-!
## The user's literal statement (preserved, but false — see header)

```
-- For all sufficiently large x, at least 90.4% of even integers in (x, 3x]
-- are the sum of a prime p₁ ≤ x and a prime p₂ in (x, x + x^0.525].
theorem bhp_goldbach_density_literal :
    ∃ X₀ : ℕ, ∀ x : ℕ, X₀ ≤ x →
      (9040 / 10000 : ℝ)
          * (((Finset.Ioc (x : ℤ) (3 * x)).filter (fun n => Even n)).card : ℝ)
        < (#{N ∈ Finset.Ioc (x : ℤ) (3 * x) |
              Even N ∧ 0 < rAdd (Aset x) (Bbhp x) N} : ℝ) := by
  sorry  -- FALSE: A + B ⊆ (x, 2x + x^0.525], which misses ≈ half of (x, 3x];
         -- see the module header for the structural reason and a numeric witness.
```
-/

end PrimeSumset
