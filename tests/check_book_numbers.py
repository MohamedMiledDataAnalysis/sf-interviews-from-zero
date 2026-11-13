"""Compares the numbers printed in the book with the workbooks.

tests/book_numbers_excel.csv lists, for each number the book prints, the workbook
cell that holds it, the printed value and the decimals to compare. Values are
read twice: as saved in the file, and after LibreOffice recalculates the file
(tests/output/recalculated/, written by check_excel.py), so both must agree with
the book. Usage, from the repository root:  python tests/check_book_numbers.py
"""
import csv, sys
from pathlib import Path
from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parent.parent
rows = list(csv.DictReader(open(ROOT / "tests" / "book_numbers_excel.csv", encoding="utf-8")))
sources = {"saved": ROOT / "excel", "recalculated": ROOT / "tests" / "output" / "recalculated"}
cache, fails, checked = {}, [], 0
for label, folder in sources.items():
    if not folder.exists():
        print(f"(no {label} copies found in {folder}; skipped)")
        continue
    for r in rows:
        key = (label, r["workbook"])
        if key not in cache:
            cache[key] = load_workbook(folder / r["workbook"], data_only=True)
        got = cache[key][r["sheet"]][r["cell"]].value
        exp = r["expected"]
        if r["decimals"] == "":
            ok = str(got) == exp
        else:
            d = int(r["decimals"])
            ok = isinstance(got, (int, float)) and round(got, d) == round(float(exp), d)
        checked += 1
        if not ok:
            fails.append(f"| {label} | {r['workbook']} | {r['sheet']}!{r['cell']} | book {exp} | file {got} | {r['where in the book']} |")
lines = ["# Numbers printed in the book, checked against the workbooks", "",
         f"Checked: {checked} values ({len(rows)} printed numbers, saved and recalculated). Failures: {len(fails)}", ""]
if fails:
    lines += ["| Copy | Workbook | Cell | Book | File | Where |", "|---|---|---|---|---|---|"] + fails
out = ROOT / "tests" / "output"; out.mkdir(parents=True, exist_ok=True)
(out / "BOOK_NUMBERS_REPORT.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
print("\n".join(lines))
sys.exit(1 if fails else 0)
