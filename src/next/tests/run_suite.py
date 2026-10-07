# Integrate-only regression suite: each antenna goes through src/orchestrator.py with the Kira
# integrator (fresh Kira state per expression) and is compared, order by order in ep, with the
# integrated antennae of the thesis (Appendix A). Usage: python src/next/tests/run_suite.py [A30 A40 ...]
import json, os, subprocess, sys, time
from pathlib import Path
import sympy as sp

TESTS_DIR = Path(__file__).resolve().parent
SRC_DIR = TESTS_DIR.parent
ROOT_DIR = SRC_DIR.parent.parent
OUTPUT_DIR = TESTS_DIR / "output"
sys.path.insert(0, str(TESTS_DIR))
from references import references, ep, pi, z3

cases = {   # antenna: (family, multiplicity, loop_order, reference of each component)
    "A30": ("A", 3, 0, ["A30"]),
    "A40": ("A", 4, 0, ["A40 leading", "A40 subleading"]),
    "B40": ("B", 4, 0, ["B40"]),
    "C40": ("C", 4, 0, ["C40"]),
}

def read_result(path):
    text = path.read_text().split("=", 1)[1].strip().rstrip(";")
    return sp.sympify(text.replace("rat(", "(").replace("^", "**"), locals={"ep": ep, "pi": pi, "z3": z3})

def compare(result, reference):
    difference = sp.expand(result - reference)
    return all(sp.simplify(difference.coeff(ep, power)) == 0 for power in range(-4, 3))

env = {**os.environ}
env.setdefault("FERMATPATH", str(Path.home() / "opt/fermat/Ferm7a/fer64"))
OUTPUT_DIR.mkdir(exist_ok=True)
runcard_path = ROOT_DIR / "runcards" / "_suite.json"
integrated_dir = ROOT_DIR / "results" / "integrated"
selected = sys.argv[1:] or list(cases)
rows = []

for name in selected:
    family, multiplicity, loop_order, component_references = cases[name]
    runcard_path.write_text(json.dumps({
        "build": 0, "build_method": "pythonToWl", "build_print_to_terminal": 1,
        "integrate": 1, "integrate_method": "kira", "integrate_print_to_terminal": 1,
        "substitute_masters": 1, "auto_input_path": 1, "manual_input_path": "",
        "family": family, "multiplicity": multiplicity, "loop_order": loop_order,
    }, indent=4))
    for stale in integrated_dir.glob(f"{name}_*"):
        stale.unlink()

    start = time.perf_counter()
    proc = subprocess.run([sys.executable, "orchestrator.py", "_suite"], cwd=SRC_DIR,
                          capture_output=True, text=True, env=env)
    seconds = round(time.perf_counter() - start, 1)
    (OUTPUT_DIR / f"{name}.log").write_text(proc.stdout + "\n--- stderr ---\n" + proc.stderr)

    if proc.returncode != 0:
        error = (proc.stderr.strip().splitlines() or ["exit code " + str(proc.returncode)])[-1]
        rows.append((name, "error", seconds, error))
    else:
        verdicts = []
        for index, reference_name in enumerate(component_references):
            scale = json.loads((integrated_dir / f"{name}_{index}_scale.json").read_text())["factor"]
            ok = compare(read_result(integrated_dir / f"{name}_{index}_integrated.inc"), references[reference_name])
            verdicts.append(f"{reference_name}: {'match' if ok else 'MISMATCH'}, scale {scale}")
        rows.append((name, "match" if all("match," in v for v in verdicts) else "mismatch", seconds, "; ".join(verdicts)))
    print(*rows[-1], sep=" | ", flush=True)

runcard_path.unlink(missing_ok=True)
summary = ["| Antenna | Verdict | Time | Details |", "|---|---|---|---|"]
summary += [f"| {name} | {verdict} | {seconds} s | {details} |" for name, verdict, seconds, details in rows]
(OUTPUT_DIR / "summary.md").write_text("\n".join(summary) + "\n")
sys.exit(0 if all(verdict == "match" for _, verdict, _, _ in rows) else 1)
