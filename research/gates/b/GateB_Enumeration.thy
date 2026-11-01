theory GateB_Enumeration
  imports GateB_EnumerationLeast
begin

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
  have np: "\<langle>n,k\<rangle> \<in> nat\<times>nat" using n kn by blast
  have mp: "\<langle>m,l\<rangle> \<in> nat\<times>nat" using m ln by blast
  have qc: "q`\<langle>n,k\<rangle> = q`\<langle>m,l\<rangle>"
    using cx cy eq by simp
  have pair: "\<langle>n,k\<rangle> = \<langle>m,l\<rangle>"
    by (rule inj_apply_equality [OF q qc np mp])
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
  proof (rule lam_type)
    fix x
    assume hx: "x \<in> ?U"
    show "selected_index(f,q,x) \<in> nat"
      by (rule selected_index_natural [OF f q hx])
  qed
  have hi: "\<forall>x\<in>?U. \<forall>y\<in>?U. ?h`x = ?h`y \<longrightarrow> x=y"
  proof (intro ballI impI)
    fix x y
    assume x: "x \<in> ?U" and y: "y \<in> ?U"
      and h: "?h`x = ?h`y"
    have code: "selected_index(f,q,x) = selected_index(f,q,y)"
      using x y h by simp
    show "x=y" by (rule selected_index_injective [OF f q x y code])
  qed
  have "?h \<in> inj(?U,nat)"
    using hf hi unfolding inj_def by blast
  thus ?thesis unfolding lepoll_def by blast
qed

end
