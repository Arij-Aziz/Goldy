import RequestProject.AdditiveEnergy
import RequestProject.Definitions
import RequestProject.ExplicitCounting
import RequestProject.ShortInterval
import RequestProject.GMDBridge

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Module 5 — `PrimeSumset.EnergyUpperBound` (the novel obligation)

This module records the single genuine analytic input of the project: an
explicit energy ceiling

  `E(A, B) ≤ κ · M² / pᵢ`   with   `κ = 1.1053`.

The value `κ = 1.1053 = 1/K_ν(0,0)` comes from the Das–Ismoilov–Ramos (2025,
arXiv:2502.05106) reproducing-kernel bound for the limiting measure
`dν(α) = δ(α) + (1/3)|α| dα` (parameters `c₁ = 1`, `c₂ = 1/3`, `Δ = 1`); see
`GapCloser.lean` for the numerical derivation `1/K_ν(0,0) ≈ 1.11048` and
`DIRMajorantTransfer.lean` for the majorant-transfer route to the same constant.

**HONEST STATUS — this is NOT merely an "unformalized established result".**
For the constant `κ = 1.1053 < 10/9` this ceiling is *conditional on an OPEN
analytic input* and should be treated as a shaky/conjectural assumption, not as
a routine cite-and-`sorry`. See `ENERGY_CEILING_HONEST_STATUS.md` for the full
argument. In brief, discharging it requires:

1. the Goldston–Montgomery bridge linking `E(A, B)` to Montgomery's pair
   correlation `F(α, T)` (`pairprimes.pdf`, `montgomery.pdf`) — *established*;
2. the D-I-R reproducing-kernel extremal bound `C_ν ≤ 1/K_ν(0,0)`
   (`paper_2502.05106.pdf`, Theorems 3 and 5) — *established for a given ν*; and
3. the **measure identification** that the prime-energy form factor has weak-\*
   limit `dν = δ + (1/3)|α|dα` (giving `c₂ = 1/3`, hence `1/K_ν(0,0) ≈ 1.1053`).
   This step is **OPEN** — it is a new analytic theorem proved in no cited paper
   (see `GapCloser.measure_identification`, marked OPEN), and an earlier
   derivation of it was found invalid (`AGENT_LOG.md`). Without it, only the
   unconditional constant `κ = 1.3208` (giving `|C| ≳ 0.757·pᵢ`) is available.

Getting `κ < 10/9` is essentially an effective Hardy–Littlewood prime-pair
statement, which is open (unconditional sieves stop at `κ ≈ 2` via the parity
barrier). The reduction `ceiling ⇒ |C| > 0.904·pᵢ` is itself fully machine-
checked in `MainTheorem.lean`; the gap is solely this analytic *input*.
-/

namespace PrimeSumset

open Finset

/-- **Energy Ceiling (two Tier-1 sorrys).**

For every `i > 10^15`, the additive energy of the prime sets `A = primes∩[3,pᵢ]`
and `B = primes∩(pᵢ,2pᵢ]` obeys `E(A,B) ≤ (1.1053)·M²/pᵢ`, where `M = |A|·|B|`.

The constant `11053/10000 = 1.1053 = 1 + 0.1053` comes from the D-I-R
reproducing-kernel value `1/K_ν(0,0)` for the limiting measure
`dν = δ + (1/3)|α|dα`; since `1/1.1053 = 10000/11053 > 0.904`, this ceiling
yields the main theorem `|C| > 0.904·pᵢ`.

**Proof.**  The ceiling follows from two **Tier-1 `sorry`s** defined in
`RequestProject.GMDBridge`:

 1. `weighted_gm_bridge_cross` (h_GM) — the weighted Goldston–Montgomery bridge
    `E(A,B) ≤ (M²/x)·(1 + J + rem)` via the explicit formula, citing:
    - Goldston (2004) pairprimes.pdf, Theorem 7 & §4 (GM bridge + singular series)
    - Baluyot et al. (2024) arXiv:2306.04799, Theorem 1 (unconditional `F(α,T)`)
    - Gafni–Tao (2025) arXiv:2505.24017, §3 (explicit formula ↔ form factor)
    - Davenport, *Multiplicative Number Theory*, Ch. 17 + Dussart (error bound)

2. `dir_theorem1_w_exp` (h_DIR) — the D-I-R Theorem 1 bound
   `J + rem ≤ 1053/10000` via the exponential majorant, citing:
   - Das–Ismoilov–Ramos (2025) arXiv:2502.05106, Theorem 1, Corollary 7

All other steps (positivity, algebra, `norm_num`) are **machine-checked** in
`GMDBridge.energy_ceiling_via_tier1_sorrys`. -/
theorem energy_ceiling {i : ℕ} (hi : i > trigger) :
    (energy (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ)
      ≤ (11053 / 10000 : ℝ)
          * (mass (Aset (primeIdx i)) (Bset (primeIdx i)) : ℝ) ^ 2
          / (primeIdx i : ℝ) :=
  energy_ceiling_via_tier1_sorrys hi

end PrimeSumset
