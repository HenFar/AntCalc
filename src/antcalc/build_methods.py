from pathlib import Path
from wolframclient.evaluation import WolframLanguageSession
from wolframclient.language import wl, wlexpr

########################################
# legacy

def build_massless_legacy(wolfram_loc, path_to_file, results_dir, antenna_family, multiplicity, loop_order, output_dest):
    with WolframLanguageSession(wolfram_loc) as session:
        session.evaluate(wl.Get(str(path_to_file / "build_pipeline.wl")))
        session.evaluate(wl.Put(
            wlexpr(f"BuildAntenna[{antenna_family}, {multiplicity}, {loop_order}]"),
            str(results_dir / f"{output_dest}.m"),
        ))

########################################
# pythonToWl

def build_massless_pythonToWl(wolfram_loc, path_to_file, results_dir, antenna_family, multiplicity, loop_order, output_dest):
    with WolframLanguageSession(wolfram_loc) as session:
        session.evaluate(wl.Get(str(path_to_file / "build_pipeline.wl")))
        session.evaluate(wlexpr('''cleanUnintegratedAntenna[expr_] :=    expr //. {Epsilon -> (4 - d)/2,      FeynAmpDenominator[props__] :>       Times @@ ({props} /.          PropagatorDenominator[p_, m_ : 0] :> 1/(p^2 - m^2)),      Pair[Momentum[a_, ___], Momentum[b_, ___]] :>       If[a === b, a^2,        Symbol[StringJoin @@ Sort[{ToString[a], ToString[b]}]]],      Momentum[p_, ___] :> p};'''))
        session.evaluate(wl.Put(
            wlexpr(f"(BuildAntenna[{antenna_family}, {multiplicity}, {loop_order}, ReductionBackend -> None] // cleanUnintegratedAntenna[#]& // Together)"),
            str(results_dir / f"{output_dest}.m"),
        ))
