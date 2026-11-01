theory GateB_EnumerationLeast
  imports GateB_EnumerationIntro
begin

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

end
