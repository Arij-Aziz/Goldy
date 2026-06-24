import RequestProject.Main

/-!
# Axiom audit

This module imports `RequestProject.Main` (the full project) and runs
`#print axioms` on the twenty most important theorems of the development.
Running this file prints, for each theorem, the exact set of axioms it
transitively depends on.

Reading the output:

* Theorems depending only on `propext`, `Classical.choice`, `Quot.sound`
  (and, where relevant, `Lean.ofReduceBool` / `Lean.trustCompiler`) are fully
  machine-checked.
* Theorems whose dependency list contains `sorryAx` rest on the project's
  remaining Tier-1 analytic citation burdens (chiefly `energy_ceiling` and the
  GM-bridge sorrys).
-/

open PrimeSumset

-- ## Additive-energy combinatorics (unconditional, machine-checked)
#print axioms sum_rAdd
#print axioms energy_eq_sum_sq
#print axioms energy_eq_diff_corr
#print axioms overlap_card_mul_sq_le_energy
#print axioms cauchy_schwarz_compression
#print axioms sumset_lower_of_energy_ceiling
#print axioms sumset_card_ge_of_energy_ceiling
#print axioms sumset_card_gt_of_energy_ceiling

-- ## Prime-set basic facts (unconditional, machine-checked)
#print axioms mass_pos
#print axioms Aset_nonempty
#print axioms Bset_nonempty
#print axioms three_le_primeIdx_of_trigger
#print axioms rAdd_pos_iff
#print axioms rAdd_pos_even

-- ## Main density / exceptional-set results (conditional on `energy_ceiling`)
#print axioms energy_ceiling
#print axioms sumset_card_gt_904
#print axioms overlap_bound
#print axioms goldbach_density
#print axioms goldbach_exception_bound

-- ## GM bridge layer
#print axioms GM2_form_factor_matching_structured
