from wolframclient.evaluation import WolframLanguageSession
from wolframclient.language import wl, wlexpr

########################################
# legacy

def integrate_massless_legacy(wolfram_loc, path_to_file, results_dir, antenna_family, multiplicity, loop_order, output_dest):
    with WolframLanguageSession(wolfram_loc) as session:
        session.evaluate(wl.Get(str(path_to_file / "build_pipeline.wl")))
        session.evaluate(wl.Get(str(path_to_file / "integrate_pipeline.wl")))
        session.evaluate(wl.Put(
            wlexpr(f"BuildAndIntegrateAntenna[{antenna_family}, {multiplicity}, {loop_order}]"),
            str(results_dir / f"{output_dest}.m"),
    ))
