theory GateB_CountableConverse
  imports GateB_Enumeration
begin

text \<open>
  An infinite set equipped with an injection into the naturals
  is well-orderable in ZF: pull back the natural-number order.
  The prior GateB_ZF proof then extracts a copy of nat.
\<close>

lemma infinite_subcountable_has_nat_injection:
  assumes inf: "\<not> Finite(U)" and count: "U \<lesssim> nat"
  shows "nat \<lesssim> U"
proof -
  have "well_ord(nat,Memrel(nat))"
    by (rule well_ord_Memrel [OF Ord_nat])
  then obtain r where wr: "well_ord(U,r)"
    using count by (blast dest: lepoll_well_ord)
  have equiv: "U \<approx> |U|"
    by (rule eqpoll_sym [OF well_ord_cardinal_eqpoll [OF wr]])
  have ord: "Ord(|U|)"
    by (rule Card_is_Ord [OF Card_cardinal])
  have witness: "\<exists>a. Ord(a) \<and> U \<approx> a"
    using equiv ord by blast
  have "has_nat_injection(U)"
    by (rule wellorderable_infinite_has_nat_injection [OF inf witness])
  thus ?thesis unfolding has_nat_injection_def .
qed

lemma selected_union_has_nat_injection:
  assumes f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
  shows "nat \<lesssim> selected_union(f)"
proof -
  have infinite: "\<not> Finite(selected_union(f))"
    by (rule selected_union_infinite [OF f])
  have countable: "selected_union(f) \<lesssim> nat"
    by (rule selected_union_lepoll_nat [OF f])
  show ?thesis
    by (rule infinite_subcountable_has_nat_injection [OF infinite countable])
qed

text \<open>
  The positive Gate B target, stated entirely inside Isabelle's ZF
  object logic, with AC_omega as a single explicit proposition.
  No global well-ordering or ambient Isabelle/HOL choice axiom
  is used to obtain the injection.
\<close>

theorem countable_choice_infinite_has_nat_injection:
  assumes inf: "\<not> Finite(A)" and cc: "countable_choice"
  shows "has_nat_injection(A)"
proof -
  obtain f where f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
    using countable_choice_yields_infinite_enumerated_union [OF inf cc]
    by blast
  have seq: "nat \<lesssim> selected_union(f)"
    by (rule selected_union_has_nat_injection [OF f])
  have incl: "selected_union(f) \<subseteq> A"
    by (rule selected_union_subset [OF f])
  have "nat \<lesssim> A"
    using seq incl by (blast intro: subset_imp_lepoll lepoll_trans)
  thus ?thesis unfolding has_nat_injection_def .
qed


text \<open>
  The first half of the Dedekind-infinity bridge uses no choice principle.
  The existing ZF CardinalArith theorem embeds succ(A) into A whenever
  nat embeds into A. Restricting this injection to A omits the image
  of the additional point A (which is not an element of itself).
\<close>

definition has_proper_self_embedding :: "i \<Rightarrow> o" where
  "has_proper_self_embedding(A) \<equiv>
    (\<exists>f. f \<in> inj(A,A) \<and> f \<notin> surj(A,A))"

lemma nat_injection_gives_proper_self_embedding:
  assumes countable: "has_nat_injection(A)"
  shows "has_proper_self_embedding(A)"
proof -
  have n: "nat \<lesssim> A"
    using countable unfolding has_nat_injection_def .
  have extra: "succ(A) \<lesssim> A"
    unfolding succ_def by (rule nat_cons_lepoll [OF n])
  obtain g where g: "g \<in> inj(succ(A),A)"
    using extra unfolding lepoll_def by blast
  let ?h = "restrict(g,A)"
  have narrower: "?h \<in> inj(A, A - {g`A})"
    by (rule inj_succ_restrict [OF g])
  have embedding: "?h \<in> inj(A,A)"
    using narrower by (blast intro: inj_weaken_type)
  have new: "A \<in> succ(A)" by simp
  have missed: "g`A \<in> A"
    using g new by (blast dest: inj_is_fun apply_type)
  have not_onto: "?h \<notin> surj(A,A)"
  proof
    assume onto: "?h \<in> surj(A,A)"
    then obtain x where xa: "x \<in> A" and hit: "?h`x = g`A"
      using missed unfolding surj_def by blast
    have "?h`x \<in> A - {g`A}"
      using narrower xa by (blast dest: inj_is_fun apply_type)
    with hit show False by blast
  qed
  show ?thesis
    using embedding not_onto unfolding has_proper_self_embedding_def by blast
qed


text \<open>
  Conversely, any injective, nonsurjective endomap has an element
  outside its image. Iterating the map from that element gives an
  infinite sequence. The orbit cannot repeat: a first collision can
  be pulled backward using injectivity until it contradicts the
  missing-image starting point. This is all internal to Isabelle/ZF.
\<close>

lemma proper_self_embedding_gives_nat_injection:
  assumes proper: "has_proper_self_embedding(A)"
  shows "has_nat_injection(A)"
proof -
  obtain f where fi: "f \<in> inj(A,A)" and notsurj: "f \<notin> surj(A,A)"
    using proper unfolding has_proper_self_embedding_def by blast
  have ff: "f \<in> A -> A" using fi by (rule inj_is_fun)
  obtain a where aa: "a \<in> A" and missing: "\<forall>x\<in>A. f`x \<noteq> a"
    using ff notsurj unfolding surj_def by blast
  let ?orbit = "\<lambda>n. rec(n,a,\<lambda>k x. f`x)"
  have orb_in: "\<And>n. n \<in> nat \<Longrightarrow> ?orbit(n) \<in> A"
  proof -
    fix n assume n: "n \<in> nat"
    show "?orbit(n) \<in> A"
      using n by (induct n rule: nat_induct)
        (use aa ff in \<open>auto intro: apply_type\<close>)
  qed
  have no_repeat_base: "\<And>n. n \<in> nat \<Longrightarrow> ?orbit(succ(n)) \<noteq> a"
    using orb_in missing by auto
  have positive_base: "\<And>n. \<lbrakk>n \<in> nat; ?orbit(n) = a\<rbrakk> \<Longrightarrow> n = 0"
  proof -
    fix n assume nn: "n \<in> nat" and hit: "?orbit(n) = a"
    from nn show "n = 0"
    proof (cases rule: natE)
      case 0
      thus ?thesis by simp
    next
      case (succ m)
      hence "?orbit(n) \<noteq> a" using no_repeat_base by simp
      with hit show ?thesis by blast
    qed
  qed
  have orbit_distinct:
    "\<And>m n. \<lbrakk>m \<in> nat; n \<in> nat\<rbrakk> \<Longrightarrow> (?orbit(m) = ?orbit(n) \<longrightarrow> m = n)"
  proof -
    fix m n assume m: "m \<in> nat" and n: "n \<in> nat"
    from m n show "?orbit(m) = ?orbit(n) \<longrightarrow> m = n"
    proof (induct m n rule: diff_induct)
      case (0 x)
      show ?case using "0" positive_base by auto
    next
      case (0_succ y)
      show ?case using "0_succ" no_repeat_base by auto
    next
      case (succ_succ x y)
      show ?case
      proof
        assume eq: "?orbit(succ(x)) = ?orbit(succ(y))"
        have fx: "f`(?orbit(x)) = f`(?orbit(y))" using eq by simp
        have xy: "?orbit(x) = ?orbit(y)"
          by (rule inj_apply_equality
            [OF fi fx orb_in[OF succ_succ.hyps(1)] orb_in[OF succ_succ.hyps(2)]])
        have "x = y" using succ_succ.hyps xy by blast
        then show "succ(x) = succ(y)" by simp
      qed
    qed
  qed
  let ?g = "\<lambda>n\<in>nat. ?orbit(n)"
  have gf: "?g \<in> nat -> A"
    by (rule lam_type, rule orb_in)
  have gi: "\<forall>m\<in>nat. \<forall>n\<in>nat. ?g`m = ?g`n \<longrightarrow> m=n"
    using orbit_distinct by auto
  have "?g \<in> inj(nat,A)"
    using gf gi unfolding inj_def by blast
  hence "nat \<lesssim> A" unfolding lepoll_def by blast
  thus ?thesis unfolding has_nat_injection_def .
qed

theorem dedekind_infinity_equivalence:
  "has_nat_injection(A) \<longleftrightarrow> has_proper_self_embedding(A)"
  by (blast intro: nat_injection_gives_proper_self_embedding
                   proper_self_embedding_gives_nat_injection)

end
