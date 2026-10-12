"""Full Kira integration with generated families (A30, B40, C40, A40), compared with the golden fixtures."""
import json
import os
import subprocess
import sys
from pathlib import Path

import sympy as sp
from sympy.core.function import AppliedUndef

TESTS_DIR = Path(__file__).resolve().parent
ROOT_DIR = TESTS_DIR.parents[1]
REFERENCE_DIR = TESTS_DIR / "reference"
INTEGRATED_DIR = ROOT_DIR / "results" / "integrated"
RUNCARD_PATH = ROOT_DIR / "runcards" / "_generated_check.json"
FERMAT_DEFAULT = "/Users/henriquefarinha/opt/fermat/Ferm7a/fer64"
EXTRA_PATH = ["/Users/henriquefarinha/opt/kira/bin", "/opt/homebrew/bin"]

# antenna: (family, multiplicity, component names of the results)
CASES = {
    "A30": ("A", 3, ["A30_0"]),
    "B40": ("B", 4, ["B40_0"]),
    "C40": ("C", 4, ["C40_0"]),
    "A40": ("A", 4, ["A40_0", "A40_1"]),
}


def runcard_text(family, multiplicity):
    return json.dumps({
        "build": 0, "build_method": "pythonToWl", "build_print_to_terminal": 1,
        "integrate": 1, "integrate_method": "kira", "integrate_print_to_terminal": 1,
        "substitute_masters": 0, "generate_families": 1,
        "auto_input_path": 1, "manual_input_path": "",
        "family": family, "multiplicity": multiplicity, "loop_order": 0,
    }, indent=4)


def same_text(first, second):
    return "".join(first.split()) == "".join(second.split())


def read_expression(text):
    body = text.split("=", 1)[1].strip().rstrip(";")
    return sp.sympify(body, locals={"rat": lambda num, den: num / den})


def same_masters(actual_text, reference_text):
    if same_text(actual_text, reference_text):
        return True, "text"
    actual = sp.expand(read_expression(actual_text))
    reference = sp.expand(read_expression(reference_text))
    masters = actual.atoms(AppliedUndef) | reference.atoms(AppliedUndef)
    for master in masters:
        if sp.simplify(actual.coeff(master) - reference.coeff(master)) != 0:
            return False, f"coefficient of {master} differs"
    remainder = actual.subs({m: 0 for m in masters}) - reference.subs({m: 0 for m in masters})
    return sp.simplify(remainder) == 0, "sympy"


def same_scale(actual_text, reference_text):
    return json.loads(actual_text) == json.loads(reference_text)


def compare_component(name):
    verdicts = []
    masters_actual = INTEGRATED_DIR / f"{name}_masters.inc"
    scale_actual = INTEGRATED_DIR / f"{name}_scale.json"
    if not masters_actual.exists() or not scale_actual.exists():
        return [(f"{name} output", False, "missing output files")]
    ok, how = same_masters(masters_actual.read_text(), (REFERENCE_DIR / f"{name}_masters.inc").read_text())
    verdicts.append((f"{name}_masters.inc", ok, how))
    ok = same_scale(scale_actual.read_text(), (REFERENCE_DIR / f"{name}_scale.json").read_text())
    verdicts.append((f"{name}_scale.json", ok, "json"))
    return verdicts


def main(selected):
    env = {**os.environ}
    env["FERMATPATH"] = os.environ.get("FERMATPATH", FERMAT_DEFAULT)
    env["PATH"] = os.pathsep.join(EXTRA_PATH + [os.environ.get("PATH", "")])
    failures = 0

    for antenna in selected:
        family, multiplicity, names = CASES[antenna]
        RUNCARD_PATH.write_text(runcard_text(family, multiplicity))
        for name in names:
            for kind in ("masters.inc", "scale.json"):
                (INTEGRATED_DIR / f"{name}_{kind}").unlink(missing_ok=True)

        proc = subprocess.run(
            [sys.executable, "src/antcalc/orchestrator.py", "_generated_check"],
            cwd=ROOT_DIR, capture_output=True, text=True, env=env,
        )
        if proc.returncode != 0:
            last = (proc.stderr.strip().splitlines() or [f"exit code {proc.returncode}"])[-1]
            print(f"{antenna}: FAIL (run error: {last})")
            failures += 1
            continue

        for name in names:
            for label, ok, how in compare_component(name):
                print(f"{label}: {'PASS' if ok else 'FAIL'} ({how})")
                failures += 0 if ok else 1

    print("ALL PASS" if failures == 0 else f"{failures} FAILED")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    targets = sys.argv[1:] or list(CASES)
    sys.exit(main(targets))
