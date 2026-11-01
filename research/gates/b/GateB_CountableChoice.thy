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


text \<open>
  Without any choice principle, a nonfinite set has an injection from
  each individual finite ordinal. This does not choose those injections
  simultaneously, which is exactly why the countable choice axiom is
  needed in the next step.
\<close>

lemma infinite_has_finite_injections:
  assumes inf: "\<not> Finite(A)"
      and n: "n \<in> nat"
  shows "inj(n,A) \<noteq> 0"
  using n
proof (induct n)
  case 0
  show ?case by (auto simp add: inj_def)
next
  case (succ n)
  obtain f where f: "f \<in> inj(n,A)" using succ.hyps(2) by blast
  have fn: "f \<in> n -> A" using f by (rule inj_is_fun)
  have finite_range: "Finite(range(f))"
  proof -
    have r: "range(f) = {f`x. x \<in> n}"
      using fn by (blast dest: Pi_memberD intro: apply_Pair)
    have "Finite(n)" using succ.hyps(1) by (rule nat_into_Finite)
    then have "Finite({f`x. x \<in> n})"
      by (rule Finite_RepFun)
    then show ?thesis using r by simp
  qed
  have fresh: "\<exists>y\<in>A. y \<notin> range(f)"
    using inf finite_range by (blast intro: subset_Finite)
  obtain y where yA: "y \<in> A" and yr: "y \<notin> range(f)"
    using fresh by blast
  have fr: "f \<in> inj(n,range(f))"
    using f unfolding inj_def by (blast intro: range_of_fun)
  have ext: "cons(\<langle>n,y\<rangle>,f) \<in>
       inj(succ(n),cons(y,range(f)))"
    using fr yr succ.hyps(1)
    by (blast intro: inj_extend simp add: succ_def)
  have sub: "cons(y,range(f)) \<subseteq> A"
    using fn yA by (auto dest: range_type)
  have "cons(\<langle>n,y\<rangle>,f) \<in> inj(succ(n),A)"
    using ext sub by (rule inj_weaken_type)
  then show ?case by blast
qed

end
