theory GateB_ProverBridge
  imports GateB_CountableConverse
begin

text \<open>
  The ML code inspects actual Isabelle theorem objects after kernel proof
  replay. It verifies that the source-extracted premise/conclusion signatures
  match the elaborated propositions, and exports human-readable theorem
  signatures for a separate CI consumer. This is NOT an export of full
  proof-term dependencies or a cross-foundation proof translation.
\<close>

ML_file "GateB_ProverBridge.ML"

(* Independent baseline: native Isabelle proof-body and oracle APIs. *)
ML_file "GateB_NativeBaseline.ML"

end
