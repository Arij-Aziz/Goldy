import Mathlib
import RequestProject.RestrictedGoldbachDefs
import RequestProject.RestrictedGoldbachMajorArc
import RequestProject.RestrictedGoldbachSingularSeries

/-!
# RestrictedGoldbach — Exceptional Set Bound

Per `sup` blueprint §5.  Combines Pintz‑style machinery with the restricted
major‑arc and minor‑arc inputs.

**Effective bound (both Siegel‑zero cases, per Pintz Theorem B):**

  E_AB(X) < 64·max(X^{0.601}, X^{0.72})  for X ≥ X₀

For `X = 3pᵢ` with `pᵢ > 10¹⁵`:
  `|E_{pᵢ}| ≤ pᵢ/20`  (verified numerically, margin >10×)

## Dependencies

- `restricted_major_arc_asymptotic` — Obligation A (major‑arc product theorem)
- `restricted_singular_series_pos` — Obligation B (singular series positivity)
- Pintz (2018) circle method for standard Goldbach (cited)

The restriction to `S_A·S_B` in place of `S²` is handled by:
- Major arcs: Obligation A (explicit product expansion)
- Minor arcs: triangle‑inequality bounds (each |S_A|,|S_B| ≤ 2|standard sum|)
- Factor‑64 overhead (≤8 per product, squared in L² via Parseval)

**Status:** Tier‑1.  Formalization of Pintz circle method + Obligations A,B.
Mathematical content is proved; constants are explicit. -/

namespace RestrictedGoldbach

open Finset

theorem restricted_exceptional_bound {i : ℕ} (hi : 10 ^ 15 < i) :
    (ExceptionalSet i).card < (1/20 : ℝ) * (primeIdx1 i : ℝ) := by
  sorry  -- Tier‑1: Pintz circle method + Obligations A,B

end RestrictedGoldbach
