"""Exercise actual A30 runcards and optionally compare with a previous run.

Uses the installed symbolic tools. Original A30 outputs and any existing test
card are restored even on failure. Run sequentially with other integrations.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[2]
CASES = [
    ("build_python", 1, 0, "pythonToWl", "kira", 1, 1),
    ("build_legacy", 1, 0, "legacy", "legacy", 1, 1),
    ("integrate_kira", 0, 1, "pythonToWl", "kira", 1, 1),
    ("integrate_legacy", 0, 1, "legacy", "legacy", 1, 1),
    *[(f"both_{b}_{i}", 1, 1, b, i, 1, 1)
      for b in ("pythonToWl", "legacy") for i in ("kira", "legacy")],
    ("manual_kira", 0, 1, "pythonToWl", "kira", 0, 1),
    ("masters_only", 0, 1, "pythonToWl", "kira", 1, 0),
]
OUTPUT_FILES = [
    "results/unintegrated/unintegratedA30.m",
    "results/unintegrated_legacy/unintegratedA30.m",
    "results/integrated_legacy/integratedA30.m",
    "results/integrated/A30_0_masters.inc",
    "results/integrated/A30_0_scale.json",
    "results/integrated/A30_0_integrated.inc",
]


def run(output_dir, baseline_path=None):
    output_dir.mkdir(parents=True, exist_ok=True)
    baseline = {row["case"]: row for row in json.loads(baseline_path.read_text())} if baseline_path else None
    card_path = ROOT / "runcards" / "_restructure_check.json"
    preserved = {p: p.read_bytes() if p.exists() else None
                 for p in [card_path, *(ROOT / name for name in OUTPUT_FILES)]}
    rows = []
    try:
        with tempfile.TemporaryDirectory(prefix="antcalc-operations-") as scratch:
            for name, build, integrate, build_method, integrate_method, auto, masters in CASES:
                card = {
                    "build": build, "integrate": integrate,
                    "build_method": build_method, "integrate_method": integrate_method,
                    "build_print_to_terminal": 1, "integrate_print_to_terminal": 1,
                    "family": "A", "multiplicity": 3, "loop_order": 0,
                    "auto_input_path": auto,
                    "manual_input_path": "results/unintegrated/unintegratedA30.m",
                    "substitute_masters": masters,
                }
                card_path.write_text(json.dumps(card, indent=2))
                expected = []
                if build:
                    folder = "unintegrated" if build_method == "pythonToWl" else "unintegrated_legacy"
                    expected.append(f"results/{folder}/unintegratedA30.m")
                if integrate:
                    if integrate_method == "legacy":
                        expected.append("results/integrated_legacy/integratedA30.m")
                    else:
                        expected += OUTPUT_FILES[3:5]
                        if masters:
                            expected.append(OUTPUT_FILES[5])
                # Existing input is preserved, but expected outputs must be written afresh.
                for filename in expected:
                    (ROOT / filename).unlink(missing_ok=True)
                start = time.monotonic()
                command = [sys.executable, str(ROOT / "src/antcalc/orchestrator.py"), "_restructure_check"]
                env = {**os.environ, "ANTCALC_KIRA_DIR": str(Path(scratch) / "kira")}
                if name == "manual_kira":
                    command = [sys.executable, "-m", "antcalc", "_restructure_check"]
                    env["PYTHONPATH"] = str(ROOT / "src")
                proc = subprocess.run(
                    command, cwd=scratch, env=env,
                    capture_output=True, text=True, timeout=600,
                )
                (output_dir / f"{name}.log").write_text(proc.stdout + "\nSTDERR\n" + proc.stderr)
                fingerprints, problems = {}, []
                for filename in expected:
                    path = ROOT / filename
                    if not path.exists():
                        problems.append(f"Missing output: {filename}")
                        continue
                    content = path.read_text()
                    if any(token in content for token in ("$Failed", "BuildAntenna[", "BuildAndIntegrateAntenna[")):
                        problems.append(f"Unevaluated output: {filename}")
                    fingerprints[filename] = hashlib.sha256("".join(content.split()).encode()).hexdigest()
                row = {"case": name, "exit": proc.returncode,
                       "seconds": round(time.monotonic() - start, 1),
                       "files": fingerprints, "problems": problems}
                if baseline is not None:
                    previous = baseline.get(name)
                    row["same_as_before"] = bool(previous and previous["files"] == fingerprints
                                                 and previous["exit"] == proc.returncode)
                rows.append(row)
                (output_dir / "summary.json").write_text(json.dumps(rows, indent=2) + "\n")
                ok = proc.returncode == 0 and not problems and row.get("same_as_before", True)
                print(f"{name}: {'PASS' if ok else 'FAIL'} ({row['seconds']} s)", flush=True)
                if not ok:
                    return 1
    finally:
        for path, content in preserved.items():
            if content is None:
                path.unlink(missing_ok=True)
            else:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(content)
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=Path(__file__).parent / "output")
    parser.add_argument("--compare", type=Path, help="Previous summary.json to compare against")
    args = parser.parse_args()
    raise SystemExit(run(args.output_dir.resolve(), args.compare.resolve() if args.compare else None))
