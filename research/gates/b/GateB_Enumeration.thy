theory GateB_Enumeration
  imports GateB_Assemble
begin

text \<open>
  Each x in the union of the selected finite ranges has an
  occurrence at some pair (n,k) with n natural and k<n.
  A fixed injection of natural pairs into the naturals
  assigns a canonical *least* occurrence index.
  This is a definable inverse: no further Choice is invoked.
\<close>

definition selected_index :: "[i,i,i] \<Rightarrow> i" where
  "selected_index(f,q,x) \<equiv>
    (\<mu> j. \<exists>n\<in>nat. \<exists>k\<in>n.
          j = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k)"

lemma selected_union_subset:
  assumes f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
  shows "selected_union(f) \<subseteq> A"
proof
  fix x
  assume "x \<in> selected_union(f)"
  then obtain n where n: "n \<in> nat" and xr: "x \<in> range(f`n)"
    unfolding selected_union_def by blast
  have fn: "f`n \<in> inj(n,A)" using f n by (rule apply_type)
  obtain k where kn: "k \<in> n" and xeq: "x = (f`n)`k"
    using xr inj_is_fun [OF fn] by (blast dest: Pi_memberD intro: apply_equality)
  show "x \<in> A"
    using xeq kn inj_is_fun [OF fn] by (blast dest: apply_type)
qed

lemma selected_code_candidate:
  assumes f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
      and q: "q \<in> inj(nat\<times>nat,nat)"
      and x: "x \<in> selected_union(f)"
  shows "\<exists>j\<in>nat. \<exists>n\<in>nat. \<exists>k\<in>n.
             j = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k"
proof -
  obtain n where n: "n \<in> nat" and xr: "x \<in> range(f`n)"
    using x unfolding selected_union_def by blast
  have fn: "f`n \<in> inj(n,A)" using f n by (rule apply_type)
  have fun: "f`n \<in> n -> A" by (rule inj_is_fun [OF fn])
  obtain k where k: "k \<in> n" and eq: "x = (f`n)`k"
    using xr fun by (blast dest: Pi_memberD intro: apply_equality)
  have kn: "k \<in> nat" using n k by (blast intro: Ord_trans Ord_nat)
  have pr: "\<langle>n,k\<rangle> \<in> nat\<times>nat"
    using n kn by blast
  have qi: "q`\<langle>n,k\<rangle> \<in> nat"
    using q pr by (blast dest: inj_is_fun [THEN apply_type])
  show ?thesis using qi n k eq by blast
qed

lemma selected_index_represents:
  assumes f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
      and q: "q \<in> inj(nat\<times>nat,nat)"
      and x: "x \<in> selected_union(f)"
  shows "\<exists>n\<in>nat. \<exists>k\<in>n.
         selected_index(f,q,x) = q`\<langle>n,k\<rangle>
           \<and> x = (f`n)`k"
proof -
  obtain j where j: "j \<in> nat"
    and property: "\<exists>n\<in>nat. \<exists>k\<in>n.
       j = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k"
    using selected_code_candidate [OF f q x] by blast
  have "(\<exists>n\<in>nat. \<exists>k\<in>n.
        (\<mu> v. \<exists>n\<in>nat. \<exists>k\<in>n.
           v = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k)
         = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k)"
  proof (rule_tac i=j in LeastI)
    show "\<exists>n\<in>nat. \<exists>k\<in>n.
       j = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k" using property .
    show "Ord(j)" by (rule nat_into_Ord [OF j])
  qed
  thus ?thesis unfolding selected_index_def .
qed

lemma selected_index_natural:
  assumes f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
      and q: "q \<in> inj(nat\<times>nat,nat)"
      and x: "x \<in> selected_union(f)"
  shows "selected_index(f,q,x) \<in> nat"
proof -
  obtain j where j: "j \<in> nat"
    and property: "\<exists>n\<in>nat. \<exists>k\<in>n.
       j = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k"
    using selected_code_candidate [OF f q x] by blast
  have le: "(\<mu> v. \<exists>n\<in>nat. \<exists>k\<in>n.
           v = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k) \<le> j"
  proof (rule_tac i=j in Least_le)
    show "\<exists>n\<in>nat. \<exists>k\<in>n.
       j = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k" using property .
    show "Ord(j)" by (rule nat_into_Ord [OF j])
  qed
  have "(\<mu> v. \<exists>n\<in>nat. \<exists>k\<in>n.
           v = q`\<langle>n,k\<rangle> \<and> x = (f`n)`k) \<in> nat"
    using j le by (blast intro: lt_trans1)
  thus ?thesis unfolding selected_index_def .
qed

lemma selected_index_injective:
  assumes f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
      and q: "q \<in> inj(nat\<times>nat,nat)"
      and x: "x \<in> selected_union(f)"
      and y: "y \<in> selected_union(f)"
      and eq: "selected_index(f,q,x) = selected_index(f,q,y)"
  shows "x = y"
proof -
  obtain n k where n: "n \<in> nat" and k: "k \<in> n"
    and cx: "selected_index(f,q,x) = q`\<langle>n,k\<rangle>"
    and vx: "x = (f`n)`k"
    using selected_index_represents [OF f q x] by blast
  obtain m l where m: "m \<in> nat" and l: "l \<in> m"
    and cy: "selected_index(f,q,y) = q`\<langle>m,l\<rangle>"
    and vy: "y = (f`m)`l"
    using selected_index_represents [OF f q y] by blast
  have kn: "k \<in> nat" using n k by (blast intro: Ord_trans Ord_nat)
  have ln: "l \<in> nat" using m l by (blast intro: Ord_trans Ord_nat)
  have pair: "\<langle>n,k\<rangle> = \<langle>m,l\<rangle>"
    using q n kn m ln cx cy eq
    by (blast intro: inj_apply_equality)
  thus ?thesis using vx vy by simp
qed

lemma selected_union_lepoll_nat:
  assumes f: "f \<in> (\<Prod>n\<in>nat. inj(n,A))"
  shows "selected_union(f) \<lesssim> nat"
proof -
  have square: "nat\<times>nat \<approx> nat"
    by (rule InfCard_square_eqpoll [OF InfCard_nat])
  then obtain q where q: "q \<in> inj(nat\<times>nat,nat)"
    unfolding eqpoll_def by (blast intro: bij_is_inj)
  let ?U = "selected_union(f)"
  let ?h = "\<lambda>x\<in>?U. selected_index(f,q,x)"
  have hf: "?h \<in> ?U -> nat"
    by (rule lam_type) (blast intro: selected_index_natural [OF f q])
  have hi: "\<forall>x\<in>?U. \<forall>y\<in>?U. ?h`x = ?h`y \<longrightarrow> x=y"
    using f q
    by (auto intro: selected_index_injective [OF f q])
  have "?h \<in> inj(?U,nat)"
    using hf hi unfolding inj_def by blast
  thus ?thesis unfolding lepoll_def by blast
qed

end
