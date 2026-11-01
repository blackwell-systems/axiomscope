theory GateB_ZF
  imports ZF
begin

text \<open>
  These are propositions *inside Isabelle's first-order ZF object logic*.
  No ambient Isabelle/HOL lemma about infinite sets is used.

  A Dedekind-style witness is here an injection from the natural-number set.
  The equivalence to a proper self-embedding is proved separately in
  GateB_CountableConverse, without additional Choice.
\<close>

definition has_nat_injection :: "i \<Rightarrow> o" where
  "has_nat_injection(A) \<equiv> nat \<lesssim> A"

lemma countable_injection_implies_infinite:
  assumes "has_nat_injection(A)"
  shows "\<not> Finite(A)"
  using assms nat_not_Finite lepoll_Finite
  unfolding has_nat_injection_def by blast

text \<open>
  A LOCAL well-orderability witness is a sufficient assumption, stronger
  than countable choice. The theorem intentionally does not assert
  that this witness can be obtained in ZF alone.
\<close>

lemma wellorderable_infinite_has_nat_injection:
  assumes inf: "\<not> Finite(A)"
      and witness: "\<exists>a. Ord(a) \<and> A \<approx> a"
  shows "has_nat_injection(A)"
proof -
  obtain a where oa: "Ord(a)" and eq: "A \<approx> a"
    using witness by blast
  have nfa: "\<not> Finite(a)"
  proof
    assume fa: "Finite(a)"
    have "A \<lesssim> a" using eq by (rule eqpoll_imp_lepoll)
    then have "Finite(A)" using fa lepoll_Finite by blast
    with inf show False by blast
  qed
  have "nat \<le> a"
    using nat_le_infinite_Ord[OF oa nfa] .
  then have "nat \<lesssim> a"
    by (rule le_imp_lepoll)
  also have "a \<approx> A" using eq by (rule eqpoll_sym)
  finally have "nat \<lesssim> A" .
  thus ?thesis unfolding has_nat_injection_def .
qed

text \<open>
  This isolates the exact sufficiency used in the checked positive proof.
  No theorem about countable choice itself has been established here.
\<close>

end
