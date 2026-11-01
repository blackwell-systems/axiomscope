(* Isabelle's own theorem dependency APIs supply the baseline.
   This is NOT an AxiomScope proof-analysis algorithm. *)
val baseline_thy = @{theory};
val baseline_ctxt = @{context};
fun flatten_line s =
  String.translate (fn #"\n" => " " | #"\t" => " " | c => str c) s;
fun benchmark (id, theorem) =
  let
    val direct = Thm_Deps.thm_deps baseline_thy [theorem];
    val pretty_direct =
      flatten_line (Pretty.string_of (Thm_Deps.pretty_thm_deps baseline_ctxt [theorem]));
    val body = Proofterm.strip_thm_body (Thm.proof_body_of theorem);
    val transitive = Proofterm.fold_body_thms
      (fn {name, ...} => insert (op =) name) [body] [];
    val local = filter (String.isPrefix "GateB_") transitive;
    val all_oracles = Thm_Deps.all_oracles [theorem];
  in
    id ^ "\t" ^ Int.toString (length direct) ^ "\t" ^
    Int.toString (length transitive) ^ "\t" ^
    String.concatWith "," (sort string_ord local) ^ "\t" ^
    Int.toString (length all_oracles) ^ "\t" ^ pretty_direct
  end;
val baseline_rows = [
  benchmark ("finite_witnesses",
    @{thm GateB_CountableChoice.infinite_has_finite_injections}),
  benchmark ("countable_family",
    @{thm GateB_CountableChoice.countable_choice_finite_injection_family}),
  benchmark ("selected_family",
    @{thm GateB_CountableChoice.countable_choice_selects_all_finite_injections}),
  benchmark ("selected_union",
    @{thm GateB_Assemble.selected_union_infinite}),
  benchmark ("selected_to_injection",
    @{thm GateB_CountableConverse.selected_union_has_nat_injection}),
  benchmark ("choice_to_injection",
    @{thm GateB_CountableConverse.countable_choice_infinite_has_nat_injection}),
  benchmark ("wellorder_to_injection",
    @{thm GateB_ZF.wellorderable_infinite_has_nat_injection})
];
val _ = Export.export baseline_thy
  (Path.binding (Path.basic "axiomscope_native_dependencies.tsv", Position.none))
  (Bytes.contents_blob (Bytes.string (String.concatWith "\n" baseline_rows ^ "\n")));
val _ = writeln "AXIOMSCOPE_NATIVE_BASELINE_EXPORTED";
