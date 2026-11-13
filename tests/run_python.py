"""Runs every Python script and every SQLite script of the companion and writes a report.

Python: each script in python/ must finish without an error.
SQLite: the database is rebuilt before each script (as a reader starting fresh);
only ch17_08 may report errors, and exactly two (queries 8.1 and 8.4).
Usage, from the repository root:  python tests/run_python.py
"""
import os, platform, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "tests" / "output"
(OUT / "logs").mkdir(parents=True, exist_ok=True)
env = dict(os.environ, MPLBACKEND="Agg", PYTHONIOENCODING="utf-8")
py = sys.executable

def run(args, log):
    r = subprocess.run([py, *args], cwd=ROOT, env=env, capture_output=True, text=True, encoding="utf-8")
    (OUT / "logs" / log).write_text(r.stdout + r.stderr, encoding="utf-8")
    return r

rows, bad = [], 0
for f in sorted((ROOT / "python").glob("*.py")):
    if f.name.startswith("test_"):
        continue
    if f.name.startswith("ch18_09"):
        run(["sql/sqlite_version/build_db.py"], "build_db.log")   # ch18_09 reads the SQLite database
    r = run([str(f.relative_to(ROOT))], f"python_{f.stem}.log")
    ok = r.returncode == 0 and "Traceback" not in r.stderr
    if f.name == "00_check_setup.py":
        ok = ok and "Setup OK" in r.stdout
    bad += not ok
    last = (r.stderr.strip().splitlines() or [""])[-1][:100] if not ok else ""
    rows.append(f"| python/{f.name} | {'pass' if ok else 'FAIL'} | {last.replace('|', '/')} |")

r = run(["-m", "pytest", "-q", "python"], "pytest.log")
ok = r.returncode == 0
bad += not ok
rows.append(f"| python -m pytest python | {'pass' if ok else 'FAIL'} | {(r.stdout.strip().splitlines() or [''])[-1]} |")

for f in sorted((ROOT / "sql" / "sqlite_version").glob("ch17_*.sql")):
    b = run(["sql/sqlite_version/build_db.py"], "build_db.log")
    if b.returncode != 0:
        rows.append("| build_db.py | FAIL | see logs/build_db.log |"); bad += 1; break
    r = run(["sql/sqlite_version/run_query.py", str(f.relative_to(ROOT))], f"sqlite_{f.stem}.log")
    errors = [l for l in r.stdout.splitlines() if l.startswith("ERROR:")]
    expected = 2 if f.name.startswith("ch17_08") else 0
    ok = r.returncode == 0 and len(errors) == expected
    bad += not ok
    note = f"{len(errors)} errors, {expected} expected" + ("" if ok else f": {errors[:1]}")
    rows.append(f"| sql/sqlite_version/{f.name} | {'pass' if ok else 'FAIL'} | {note.replace('|', '/')} |")

import pandas
head = [f"# Python and SQLite run on {platform.system()} with Python {platform.python_version()}, pandas {pandas.__version__}", "",
        "| Script | Result | Notes |", "|---|---|---|"]
text = "\n".join(head + rows + ["", f"**Failures: {bad}**", ""])
(OUT / f"PYTHON_REPORT_{platform.system()}.md").write_text(text, encoding="utf-8")
print(text)
sys.exit(1 if bad else 0)
