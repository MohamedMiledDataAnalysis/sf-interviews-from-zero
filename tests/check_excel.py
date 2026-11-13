"""Recalculates every companion workbook in LibreOffice and checks it.

For each workbook: (1) save a copy with every stored result removed, so nothing
is taken on trust; (2) let LibreOffice recalculate every formula; (3) fail if any
cell shows an error (#N/A, #VALUE!, #REF!, #DIV/0!, #NAME?, #NUM!); (4) fail if a
recalculated result differs from the result stored in the file, which is the
number the book prints.  Usage, from the repository root:
    python tests/check_excel.py
"""
import shutil, subprocess, sys, tempfile
from pathlib import Path
from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parent.parent
ERRORS = ("#N/A", "#VALUE!", "#REF!", "#DIV/0!", "#NAME?", "#NUM!", "#NULL!", "Err:")
SOFFICE = shutil.which("soffice") or shutil.which("libreoffice")
if not SOFFICE:
    sys.exit("LibreOffice (soffice) is required")

def close(a, b):
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return abs(a - b) <= 1e-6 * max(1.0, abs(a), abs(b))
    return a == b

failures, report = 0, ["| Workbook | Formulas | Errors | Differences from the book |", "|---|---:|---:|---:|"]
for book in sorted((ROOT / "excel").glob("*.xlsx")):
    stored = load_workbook(book, data_only=True)
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        stripped = tmp / book.name
        load_workbook(book).save(stripped)          # openpyxl writes formulas without results
        out = tmp / "out"
        subprocess.run([SOFFICE, "--headless", f"-env:UserInstallation=file://{tmp}/profile",
                        "--convert-to", "xlsx", "--outdir", str(out), str(stripped)],
                       check=True, capture_output=True, timeout=300)
        formulas = load_workbook(stripped)
        calc = load_workbook(out / book.name, data_only=True)
        n = errs = diffs = 0
        for ws in formulas:
            for row in ws.iter_rows():
                for c in row:
                    if not (isinstance(c.value, str) and c.value.startswith("=")):
                        continue
                    n += 1
                    got = calc[ws.title][c.coordinate].value
                    want = stored[ws.title][c.coordinate].value
                    if isinstance(got, str) and got.startswith(ERRORS):
                        errs += 1
                        print(f"ERROR  {book.name} {ws.title}!{c.coordinate} {c.value} -> {got}")
                    elif want is not None and not close(got, want):
                        diffs += 1
                        print(f"DIFF   {book.name} {ws.title}!{c.coordinate} book {want!r} recalculated {got!r}")
    failures += errs + diffs
    report.append(f"| {book.name} | {n} | {errs} | {diffs} |")
print("\n".join(report))
out_dir = ROOT / "tests" / "output"; out_dir.mkdir(parents=True, exist_ok=True)
(out_dir / "EXCEL_REPORT.md").write_text("# Excel workbooks recalculated in LibreOffice\n\n" + "\n".join(report) + "\n")
sys.exit(1 if failures else 0)
