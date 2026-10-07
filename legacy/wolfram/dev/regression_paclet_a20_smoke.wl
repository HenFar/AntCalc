(* Fresh-kernel public execution smoke test. The load is deliberately its own
   input line, matching ordinary notebook use of <<AntCalc` before API calls. *)

<<AntCalc`

result = BuildAntenna[A, 2, 0,
  UseStoredResults -> False,
  StoreResults -> False];

Print[<|
  "Regression" -> "PacletA20Smoke",
  "BuildAntennaContext" -> Context[BuildAntenna],
  "ResultComputed" -> (result =!= $Failed),
  "ResultHead" -> Head[result]
|>];

Quit[];
