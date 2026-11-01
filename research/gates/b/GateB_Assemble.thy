theory GateB_Assemble
  imports GateB_CountableChoice
begin

text \<open>
  Finite injections of every size have ranges that cannot all be
  contained in a single finite set. This uses only ZF; countable
  choice has already been used to supply the family of injections.
\<close>

definition selected_union :: "i \<Rightarrow> i" where
  "selected_union(f) \<equiv> (\<Union>n\<in>nat. range(f`n))"

lemma selected_union_infinite:
  assumes f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
  shows "\<not> Finite(selected_union(f))"
proof
  assume fin: "Finite(selected_union(f))"
  obtain m where m: "m \<in> nat" and eq: "selected_union(f) \<approx> m"
    using fin unfolding Finite_def by blast
  have sm: "succ(m) \<in> nat" using m by simp
  have fm: "f`succ(m) \<in> inj(succ(m),A)"
    using f sm by (rule apply_type)
  have range_sub: "range(f`succ(m)) \<subseteq> selected_union(f)"
    using sm unfolding selected_union_def by blast
  have emb: "f`succ(m) \<in> inj(succ(m),selected_union(f))"
    using fm range_sub
    by (blast intro: inj_inj_range inj_weaken_type)
  have le: "succ(m) \<lesssim> selected_union(f)"
    using emb unfolding lepoll_def by blast
  have contradiction: "succ(m) \<lesssim> m"
    using le eq by (blast intro: eqpoll_imp_lepoll lepoll_trans)
  show False by (rule succ_lepoll_natE [OF contradiction m])
qed

lemma countable_choice_yields_infinite_enumerated_union:
  assumes inf: "\<not> Finite(A)" and cc: "countable_choice"
  shows "\<exists>f\<in>(\<Prod>n\<in>nat. inj(n,A)). \<not> Finite(selected_union(f))"
proof -
  have nonempty: "(\<Prod>n\<in>nat. inj(n,A)) \<noteq> 0"
    by (rule countable_choice_selects_all_finite_injections [OF inf cc])
  then obtain f where f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
    by blast
  show ?thesis
    using f selected_union_infinite[OF f] by blast
qed

end
