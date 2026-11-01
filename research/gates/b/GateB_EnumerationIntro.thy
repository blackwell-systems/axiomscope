theory GateB_EnumerationIntro
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

end
