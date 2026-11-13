"""Changes inputs in the workbooks, recalculates them in LibreOffice and checks the
results the book prints for those cases: the WAL table, WAL to call, the CDR grid,
Correction 8, the stressed and breakeven waterfalls, and Practice test 3's answers
after a data change (the marker's check). Usage:  python tests/check_excel_scenarios.py
"""
import shutil, subprocess, sys, tempfile
from pathlib import Path
from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parent.parent
SOFFICE = shutil.which("soffice") or shutil.which("libreoffice")
if not SOFFICE:
    sys.exit("LibreOffice (soffice) is required")
rows, bad = [], 0

def run(book, changes, tmp):
    """Apply {(sheet, cell): value} to a copy of book, recalculate, return the result workbook."""
    wb = load_workbook(ROOT / "excel" / book)
    for (sh, ref), v in changes.items():
        wb[sh][ref] = v
    src = tmp / f"case_{len(rows)}_{book}"
    wb.save(src)
    out = tmp / "out"
    subprocess.run([SOFFICE, "--headless", f"-env:UserInstallation=file://{tmp}/profile",
                    "--convert-to", "xlsx", "--outdir", str(out), str(src)], check=True,
                   capture_output=True, timeout=300)
    return load_workbook(out / src.name, data_only=True)

def check(case, got, want, places=None):
    global bad
    if places is None:
        ok = got == want
    else:
        ok = isinstance(got, (int, float)) and round(got, places) == want
    bad += not ok
    rows.append(f"| {case} | {want} | {got if places is None or not isinstance(got, float) else round(got, places + 2)} | {'pass' if ok else 'FAIL'} |")

with tempfile.TemporaryDirectory() as t:
    tmp = Path(t)
    CH16 = "ch16_excel_workbook.xlsx"
    # WAL table and WAL to call (Chapter 16)
    to_call = {("Projection", f"J{r}"): f"=IF(A{r}=61,I{r},MIN(D{r}+E{r}+F{r},I{r}))" for r in range(12, 401)}
    for cpr, wal, call in [(0, 12.28, 4.68), (0.05, 7.43, 4.04), (0.10, 4.91, 3.48), (0.15, 3.55, 2.98), (0.20, 2.73, 2.54)]:
        wb = run(CH16, {("Projection", "C5"): cpr}, tmp)
        check(f"Ch16 WAL to maturity, CPR {cpr:.0%}", wb["Projection"]["F5"].value, wal, 2)
        wb = run(CH16, {("Projection", "C5"): cpr, **to_call}, tmp)
        check(f"Ch16 WAL to call, CPR {cpr:.0%}", wb["Projection"]["F5"].value, call, 2)
    # CDR grid at 10% CPR (Chapter 16 data table)
    for cdr, wal in [(0, 5.08), (0.005, 4.91), (0.01, 4.75), (0.02, 4.46), (0.04, 3.96)]:
        wb = run(CH16, {("Projection", "C6"): cdr}, tmp)
        check(f"Ch16 CDR grid, CDR {cdr:.1%}", wb["Projection"]["F5"].value, wal, 2)
    # Correction 8: CDR 2%, severity 30%
    wb = run(CH16, {("Projection", "C6"): 0.02, ("Projection", "C7"): 0.30}, tmp)
    check("Ch16 Correction 8: WAL", wb["Projection"]["F5"].value, 4.46, 2)
    check("Ch16 Correction 8: losses (£m)", wb["Projection"]["F6"].value / 1e6, 8.85, 2)
    # Stressed and breakeven waterfalls (Chapter 16)
    wb = run(CH16, {("Waterfall", "B9"): 2_800_000}, tmp)
    check("Ch16 stress: closing reserve", wb["Waterfall"]["B28"].value, 0, 0)
    check("Ch16 stress: PDL outstanding", wb["Waterfall"]["C41"].value, 376852, 0)
    check("Ch16 stress: reconciliation check", wb["Waterfall"]["C46"].value, 0, 0)
    wb = run(CH16, {("Waterfall", "B9"): 2_423_147}, tmp)
    check("Ch16 breakeven: loss 2,423,147 leaves £1", wb["Waterfall"]["B28"].value, 1, 0)
    wb = run(CH16, {("Waterfall", "B9"): 2_423_148}, tmp)
    check("Ch16 breakeven: loss 2,423,148 leaves 0", wb["Waterfall"]["B28"].value, 0, 0)
    # Practice test 3: answers follow a data change
    T3 = "test3_solution.xlsx"
    wb = run(T3, {("5 VLOOKUP", "B5"): "Greater London", ("11 RANK", "B5"): 999999}, tmp)
    check("Ch21 data change: loans not mapped", wb["5 VLOOKUP"]["E46"].value, 2, 0)
    check("Ch21 data change: largest loan", wb["11 RANK"]["G5"].value, "ASH100001")
    wb = run(T3, {("9 IF and bands", "K2"): 0.70}, tmp)
    check("Ch21 LTV limit 70%: loans flagged High", wb["9 IF and bands"]["K13"].value, 12, 0)

lines = ["# Excel scenarios recalculated in LibreOffice", "", "| Case | Book | Recalculated | Result |", "|---|---|---|---|"] + rows + ["", f"**Failures: {bad}**", ""]
out = ROOT / "tests" / "output"; out.mkdir(parents=True, exist_ok=True)
(out / "EXCEL_SCENARIOS_REPORT.md").write_text("\n".join(lines), encoding="utf-8")
print("\n".join(lines))
sys.exit(1 if bad else 0)
