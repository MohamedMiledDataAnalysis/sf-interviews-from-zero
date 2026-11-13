"""A second, independent check of the companion workbooks.

LibreOffice (tests/check_excel.py) is one calculation engine. This script uses a
different one, the Python package `formulas`, which reimplements Excel's functions.
Every formula is calculated again and compared with the result stored in the file
(the number the book prints). Functions the package does not implement (such as
HYPERLINK) are listed, not counted as failures.
Usage, from the repository root:  python tests/check_excel_formulas.py
"""
import re, sys, warnings, datetime as dt
from pathlib import Path
warnings.filterwarnings("ignore")
import formulas
from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parent.parent
# Excel features this engine does not implement; these cells are listed, not failed.
SKIP = ("HYPERLINK",     # links: nothing to calculate
        "{",             # array constants inside EXACT, e.g. EXACT(Q2,{"London",...})
        )
# Cells that only add up skipped cells, or pass a whole range as a COUNTIF criterion
SKIP_CELLS = {("test2_solution.xlsx", "Answers", "B19"),   # =SUM of the EXACT flags above
              ("test2_solution.xlsx", "Answers", "B11")}   # COUNTIF(range, range) inside SUMPRODUCT
rows, failures = [], 0
BOOKS = sys.argv[1:] or [str(p) for p in sorted((ROOT / "excel").glob("*_solution.xlsx")) + [ROOT / "excel" / "ch16_excel_workbook.xlsx"]]
for book in map(Path, BOOKS):
    fwb = load_workbook(book)
    stored = load_workbook(book, data_only=True)
    cells = {}
    for ws in fwb:
        for row in ws.iter_rows():
            for c in row:
                if isinstance(c.value, str) and c.value.startswith("="):
                    cells[(ws.title.upper(), c.coordinate)] = (ws.title, c.value)
    model = formulas.ExcelModel().loads(str(book)).finish()
    result = model.calculate()
    got = {}
    for k, v in result.items():
        m = re.match(r"'?\[[^\]]+\](.+?)'?!([A-Z]+[0-9]+)$", str(k))
        if m:
            try:
                got[(m.group(1).upper(), m.group(2))] = v.value[0, 0]
            except Exception:
                pass
    diff = skipped = 0
    for key, (title, f) in cells.items():
        if any(s in f.upper() for s in SKIP) or (book.name, title, key[1]) in SKIP_CELLS:
            skipped += 1
            continue
        want = stored[title][key[1]].value
        if isinstance(want, dt.datetime):
            want = (want - dt.datetime(1899, 12, 30)).days
        val = got.get(key)
        if isinstance(want, bool) or not isinstance(want, (int, float)):
            ok = str(val) == str(want) or (want is None and str(val) in ("", "None"))
        else:
            try:
                ok = abs(float(val) - want) <= 1e-6 * max(1.0, abs(want))
            except Exception:
                ok = False
        if not ok:
            diff += 1
            if diff <= 25:
                print(f"DIFF {book.name} {title}!{key[1]} {f[:60]} -> {val!r}, stored {want!r}")
    failures += diff
    rows.append(f"| {book.name} | {len(cells)} | {skipped} | {diff} |")
report = ["| Workbook | Formulas | Not supported by the engine | Differences |", "|---|---:|---:|---:|"] + rows
print("\n".join(report))
out = ROOT / "tests" / "output"; out.mkdir(parents=True, exist_ok=True)
(out / "EXCEL_ENGINE2_REPORT.md").write_text("# Excel workbooks recalculated by a second engine (formulas)\n\n" + "\n".join(report) + "\n")
sys.exit(1 if failures else 0)
