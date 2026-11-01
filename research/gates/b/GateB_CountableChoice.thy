theory GateB_CountableChoice
  imports GateB_ZF
begin

text \<open>
  This is the countable axiom of choice as a *single object-level
  proposition inside Isabelle/ZF*, not an Isabelle/HOL choice rule.

  A family is represented by a set-theoretic function whose domain is nat.
  Its values must all be nonempty; the dependent product is the collection
  of choice functions for the family.
\<close>

definition countable_choice :: o where
  "countable_choice \<equiv>
     (\<forall>F. (function(F) \<and> domain(F) = nat \<and>
                    (\<forall>n\<in>nat. F`n \<noteq> 0))
          \<longrightarrow> (\<Prod>n\<in>nat. F`n) \<noteq> 0)"

lemma countable_choice_family:
  assumes cc: "countable_choice"
      and function: "function(F)"
      and domain: "domain(F) = nat"
      and nonempty: "\<forall>n\<in>nat. F`n \<noteq> 0"
  shows "(\<Prod>n\<in>nat. F`n) \<noteq> 0"
  using assms unfolding countable_choice_def by blast

text \<open>
  The family of sets of finite injective witnesses is itself
  nat-indexed. This is the specific countable-choice application needed
  for the infinity comparison; the remaining hard step is to assemble
  the chosen finite witnesses into one infinite injection.
\<close>

lemma countable_choice_finite_injection_family:
  assumes cc: "countable_choice"
      and candidates: "\<forall>n\<in>nat. inj(n,A) \<noteq> 0"
  shows "(\<Prod>n\<in>nat. inj(n,A)) \<noteq> 0"
proof -
  let ?F = "\<lambda>n\<in>nat. inj(n,A)"
  have "function(?F)" by (rule function_lam)
  moreover have "domain(?F) = nat" by simp
  moreover have "\<forall>n\<in>nat. ?F`n \<noteq> 0"
    using candidates by simp
  ultimately have "(\<Prod>n\<in>nat. ?F`n) \<noteq> 0"
    using cc countable_choice_family by blast
  then show ?thesis by (simp cong: Pi_cong)
qed

end
