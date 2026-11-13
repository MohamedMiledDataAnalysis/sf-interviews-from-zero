"""Checks the Excel features that a recalculation cannot see, in the saved files themselves.

Practice test 3 (solution): the drop-down lists, the red/amber/green conditional
formatting, the chart and its second axis, the in-workbook links, and the
_xlfn. prefix that Excel needs for IFNA and RANK.EQ. The blank versions must
contain none of the answers. Usage, from the repository root:
    python tests/check_excel_features.py
"""
import re, sys, zipfile
from pathlib import Path
from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parent.parent
X = ROOT / "excel"
rows, bad = [], 0

def check(name, ok, detail=""):
    global bad
    bad += not ok
    rows.append(f"| {name} | {'pass' if ok else 'FAIL'} | {detail} |")

sol = load_workbook(X / "test3_solution.xlsx")
blank = load_workbook(X / "test3_blank.xlsx")

# Drop-down lists
dvs = {str(dv.sqref): dv for dv in sol["2 Lists"].data_validations.dataValidation}
check("Test 3: Y/N list on H5:H14", dvs.get("H5:H14") is not None and dvs["H5:H14"].type == "list"
      and dvs["H5:H14"].formula1 == '"Y,N"', str(dvs.get("H5:H14") and dvs["H5:H14"].formula1))
check("Test 3: status list on I5:I14 points to K5:K8", dvs.get("I5:I14") is not None
      and dvs["I5:I14"].formula1 == "$K$5:$K$8", str(dvs.get("I5:I14") and dvs["I5:I14"].formula1))

# Conditional formatting
cf = sol["12 Dashboard"].conditional_formatting
rules = [(str(r.sqref), rule.formula[0]) for r in cf for rule in r.rules]
want = {('D7:D9', 'D7="Green"'), ('D7:D9', 'D7="Amber"'), ('D7:D9', 'D7="Red"')}
check("Test 3: three colour rules on D7:D9", want <= set(rules), "; ".join(f for _, f in rules))

# Chart with a secondary axis
with zipfile.ZipFile(X / "test3_solution.xlsx") as z:
    charts = [n for n in z.namelist() if n.startswith("xl/charts/chart")]
    xml = z.read(charts[0]).decode() if charts else ""
val_axes = re.findall(r"<valAx>.*?</valAx>", xml, re.S)
check("Test 3: one chart, on the 4 Chart sheet", len(charts) == 1 and len(sol["4 Chart"]._charts) == 1, f"{len(charts)} chart(s)")
check("Test 3: two value axes, the second crossing at max", len(val_axes) == 2 and 'crosses val="max"' in xml,
      f"{len(val_axes)} value axes")
check("Test 3: chart and axis titles present", xml.count("<title>") >= 3, f"{xml.count('<title>')} titles")
check("Test 3: axes not deleted", 'delete val="1"' not in xml)

# Links
bad_links = [ws.title for ws in sol.worksheets[1:] if not (ws["A3"].hyperlink and ws["A3"].hyperlink.location == "'1 Start'!A1")]
check("Test 3: 'Back to the task list' links point inside the workbook", not bad_links, ", ".join(bad_links))
starts = [sol["1 Start"][f"B{r}"].value for r in range(6, 18)]
check("Test 3: task list uses HYPERLINK to each sheet", all(isinstance(v, str) and v.startswith('=HYPERLINK("#') for v in starts))

# Functions Excel needs prefixed
for f in sorted(X.glob("*.xlsx")):
    with zipfile.ZipFile(f) as z:
        text = " ".join(re.findall(r"<f[^>]*>(.*?)</f>", " ".join(
            z.read(n).decode("utf-8", "ignore") for n in z.namelist() if n.startswith("xl/worksheets/sheet")), re.S))
    missing = [fn for fn in ("IFNA", "RANK.EQ", "XLOOKUP", "MAXIFS", "TEXTJOIN", "IFS")
               if re.search(rf"(?<![._A-Z]){re.escape(fn)}\(", text)]
    check(f"{f.name}: newer functions carry the _xlfn. prefix", not missing, ", ".join(missing))

# Blank version holds no answers
leaks = [f"{ws.title}!{c.coordinate}" for ws in blank for row in ws.iter_rows() for c in row
         if c.fill.fgColor.rgb in ("00E2EFDA", "FFE2EFDA") and c.value not in (None, "")
         and not (ws.title == "1 Start" and c.column == 2)]
check("Test 3 blank: answer cells empty", not leaks, ", ".join(leaks[:5]))
check("Test 3 blank: no lists, colour rules or chart",
      sum(len(ws.data_validations.dataValidation) + len(ws.conditional_formatting) + len(ws._charts) for ws in blank) == 0)

out = ROOT / "tests" / "output"; out.mkdir(parents=True, exist_ok=True)
text = "\n".join(["# Excel features saved in the files", "", "| Check | Result | Detail |", "|---|---|---|"] + rows + ["", f"**Failures: {bad}**", ""])
(out / "EXCEL_FEATURES_REPORT.md").write_text(text, encoding="utf-8")
print(text)
sys.exit(1 if bad else 0)
