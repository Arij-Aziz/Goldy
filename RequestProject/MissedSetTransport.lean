import Mathlib

open scoped BigOperators
open scoped Pointwise
open scoped Classical

/-!
# Module 7 — `PrimeSumset.Transport` (Replacement-route combinatorial core)

This module formalizes the *exact, finite, unconditional* combinatorial core of
the blueprint's **Approach A: Missed-Set Transport** (new prompt §5).  The aim
of that approach is to derive a contradiction from the existence of a large
*missed set*
`T := (even integers in [x+3, 3x]) \ C`,  where `C = A + B`,
by transporting `T` across all shifts `b ∈ B` and counting forced non-prime
incidences in the lower interval `[3, x]`.

Everything here is a general statement about arbitrary finite `A B T S ⊆ ℤ`;
nothing uses primes or analytic input, so all of it is provable **now** and is
`sorry`-free.  The three named lemmas the blueprint asks for are:

* `transport_not_mem_A`   — the **Transport lemma**: a missed `n` minus any
  `b ∈ B` lands outside `A`.
* `fiber_card_le_card_B`  — the **Multiplicity lemma**: each value `m = n - b`
  is produced at most `|B|` times.
* `transport_demand_le`   — the **Composite-capacity lemma**: the total
  transported demand is `≤ |B| · |S \ A|`.

**Honest conclusion (see `transport_demand_le` and `ROUTE_ANALYSIS.md`).**  The
capacity bound `|B| · |S \ A|` is an *upper* bound on the very same demand the
blueprint hoped to show was *too large*.  Because `|S \ A|` (odd composites in
`[3,x]`, `≈ x/2`) already exceeds the missed mass `|T| ≈ 0.1x`, the raw counting
inequality is satisfied with room to spare: **no contradiction arises**.
Tightening the multiplicity bound below `|B|` on average is exactly a prime-pair
correlation estimate (Hardy–Littlewood), which is the blueprint's Halt
Condition #1.  This module therefore makes the stall point machine-checkable.
-/

namespace PrimeSumset.Transport

open Finset

/-
**Transport lemma (blueprint §5.3).**  If the missed set `T` avoids the
sumset `A + B`, then for every shift `b ∈ B` and every `n ∈ T`, the transported
value `n - b` lies outside `A`.

(Contrapositive: if `n - b ∈ A` then `n = (n-b) + b ∈ A + B`, so `n ∉ T`.)
-/
lemma transport_not_mem_A {A B T : Finset ℤ}
    (hT : ∀ n ∈ T, n ∉ A + B) {b : ℤ} (hb : b ∈ B) {n : ℤ} (hn : n ∈ T) :
    n - b ∉ A := by
  exact fun h => hT n hn <| Finset.add_mem_add h hb |> fun h' => by simpa using h';

/-- The transport **incidence set**: pairs `(n, b)` with `n ∈ T`, `b ∈ B` whose
difference `n - b` falls in the target window `S` (intended: `S = [3,x]`). -/
def incidence (B T S : Finset ℤ) : Finset (ℤ × ℤ) :=
  (T ×ˢ B).filter (fun p => p.1 - p.2 ∈ S)

/-
**Row count.**  Summing the incidence set by `n ∈ T` gives, for each `n`,
the number of shifts `b ∈ B` landing inside `S`.
-/
lemma incidence_card_eq_sum_rows (B T S : Finset ℤ) :
    (incidence B T S).card
      = ∑ n ∈ T, ((B.filter (fun b => n - b ∈ S)).card) := by
  rw [ show incidence B T S = Finset.biUnion T fun n => Finset.image ( fun b => ( n, b ) ) ( Finset.filter ( fun b => n - b ∈ S ) B ) from ?_, Finset.card_biUnion ];
  · exact Finset.sum_congr rfl fun x hx => Finset.card_image_of_injective _ fun y z h => by injection h;
  · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z => by aesop;
  · ext ⟨ n, b ⟩ ; simp +decide [ incidence ] ; aesop;

/-
**Column count (Multiplicity lemma, blueprint §5.3, double-counting).**  The
same incidence set, summed by the value `m = n - b ∈ S`, counts the fibers.
-/
lemma incidence_card_eq_sum_cols (B T S : Finset ℤ) :
    (incidence B T S).card
      = ∑ m ∈ S, (((T ×ˢ B).filter (fun p => p.1 - p.2 = m)).card) := by
  rw [ ← Finset.card_biUnion ];
  · congr with x ; simp +decide [ incidence ];
    tauto;
  · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun p hp hp' => hxy <| by aesop;

/-
**Multiplicity bound (blueprint §5.3).**  Each value `m = n - b` is produced
by at most `|B|` incidence pairs, because `b ↦ (m + b, b)` shows the fiber
injects into `B`.
-/
lemma fiber_card_le_card_B (B T : Finset ℤ) (m : ℤ) :
    ((T ×ˢ B).filter (fun p => p.1 - p.2 = m)).card ≤ B.card := by
  convert Finset.card_le_card ( show Finset.image ( fun p : ℤ × ℤ => ( p.1 - p.2, p.2 ) ) ( Finset.filter ( fun p : ℤ × ℤ => p.1 - p.2 = m ) ( T ×ˢ B ) ) ⊆ Finset.image ( fun p : ℤ => ( m, p ) ) B from ?_ ) using 1;
  · rw [ Finset.card_image_of_injective _ fun x y hxy => by aesop ];
  · rw [ Finset.card_image_of_injective _ fun x y hxy => by injection hxy ];
  · grind

/-
**Demand is supported off `A`.**  Under the missed-set hypothesis, every
incidence difference `n - b` is not only in `S` but in `S \ A`; equivalently,
restricting the window to `S \ A` does not change the incidence set.
-/
lemma incidence_window_sdiff {A B T S : Finset ℤ}
    (hT : ∀ n ∈ T, n ∉ A + B) :
    incidence B T S = incidence B T (S \ A) := by
  ext ⟨ n, b ⟩ ; specialize hT n ; simp_all +decide [ Finset.mem_add ] ;
  unfold incidence; by_cases hn : n ∈ T <;> simp_all +decide ;
  grind

/-
**Composite-capacity lemma (blueprint §5.3) — the transport inequality.**

Under the missed-set hypothesis `T ∩ (A + B) = ∅`, the *total transported
demand* (left side: for each missed `n`, how many shifts `b ∈ B` land in the
window `S`) is bounded by the *capacity* `|B| · |S \ A|`.

This is the honest endpoint of Approach A.  The blueprint hoped the left side
could be forced to *exceed* the right side (a contradiction).  This theorem
proves the opposite inequality always holds, so the contradiction cannot come
from raw counting; see `ROUTE_ANALYSIS.md`.
-/
theorem transport_demand_le {A B T S : Finset ℤ}
    (hT : ∀ n ∈ T, n ∉ A + B) :
    ∑ n ∈ T, ((B.filter (fun b => n - b ∈ S)).card)
      ≤ B.card * (S \ A).card := by
  -- By incidence_card_eq_sum_rows (B T S) backwards: ∑ n ∈ T, (B.filter (fun b => n - b ∈ S)).card = (incidence B T S).card.
  have h_induction : ∑ n ∈ T, (B.filter (fun b => n - b ∈ S)).card = (incidence B T S).card := by
    convert incidence_card_eq_sum_rows B T S |> Eq.symm using 1;
  convert Finset.sum_le_sum fun m hm => fiber_card_le_card_B B T m using 1;
  rw [ h_induction, incidence_window_sdiff hT, incidence_card_eq_sum_cols ];
  simp +decide [ mul_comm ]

end PrimeSumset.Transport