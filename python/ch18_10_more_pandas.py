"""Chapter 18, sections 18.9 (price and yield), 18.11 (a pool cut in pandas)
and 18.12 (more pandas you will need). Run from the companion folder:
    python python/ch18_10_more_pandas.py"""
import sys
if hasattr(sys.stdout, "reconfigure"):  # consoles only; notebooks print £ already
    sys.stdout.reconfigure(errors="replace")
from pathlib import Path
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"
out = ROOT / "python" / "output"
out.mkdir(exist_ok=True)
sys.path.append(str(ROOT / "python"))
from ch18_08_cashflow_projection import project  # noqa: E402

tape = pd.read_csv(DATA / "ashcombe_loan_tape.csv")
hist = pd.read_csv(DATA / "ashcombe_loan_history.csv")

# ---------------------------------------------------------------------------
print("18.9 Price and yield of Class A at 10% CPR")
cf = project(cpr=0.10)
paid_before = cf["class_a_principal"].cumsum().shift(fill_value=0)
bal_a = 206_400_000 - paid_before
cash = cf["class_a_principal"] + bal_a * 0.045 / 12


def price(y):
    # present value of the cash flows at yield y
    return (cash / (1 + y / 12) ** cf["month"]).sum()


lo, hi = 0.0, 0.20
for _ in range(60):          # bisection: halve the range
    mid = (lo + hi) / 2
    if price(mid) > 206_400_000:
        lo = mid
    else:
        hi = mid
print(f"Yield at par: {mid:.3%}")                              # 4.500%
print(f"Price at a 5% yield: {price(0.05) / 206_400_000:.2%} of par")  # 97.95%
assert f"{mid:.3%}" == "4.500%"

# ---------------------------------------------------------------------------
print("\n18.11 A pool cut in pandas")
criteria = {
    "Up to date": tape["arrears_months"] == 0,
    "Remaining term <= 35 years": tape["remaining_term_months"] <= 420,
    "No possession": tape["possession_flag"] == "N",
    "Seasoned 3+ months": tape["seasoning_months"] >= 3,
    "Indexed LTV <= 90%": tape["indexed_ltv"] <= 0.90,
    "Balance <= £750k": tape["current_balance"] <= 750_000,
    "Owner-occupied": tape["occupancy"] == "Owner-occupied",
}
eligible = pd.concat(criteria, axis=1).all(axis=1)
print(f"Eligible: {eligible.sum()} loans, "
      f"£{tape.loc[eligible, 'current_balance'].sum():,.0f}")   # 892, £175,064,566
print("Loans failing each criterion:")
print((~pd.concat(criteria, axis=1)).sum().to_string())
assert eligible.sum() == 892

# ---------------------------------------------------------------------------
print("\n18.12 Reading Excel files")
serv = pd.read_excel(ROOT / "excel" / "test2_blank.xlsx",
                     sheet_name="Servicer", dtype={"loan_id": str})
sheets = pd.read_excel(ROOT / "excel" / "test2_blank.xlsx", sheet_name=None)
print(f"Servicer sheet: {len(serv):,} rows, £{serv['current_balance'].sum():,.0f}")
print("Sheets:", ", ".join(sheets.keys()))                    # Answers, Tape, Servicer

print("\n18.12 Reading CSV files safely")
tape = pd.read_csv(DATA / "ashcombe_loan_tape.csv",
                   dtype={"loan_id": str}, thousands=",",
                   na_values=["", "N/A", "-"])
tape["origination_date"] = pd.to_datetime(tape["origination_date"],
                                          format="%Y-%m-%d")
print(tape.dtypes[["loan_id", "origination_date", "current_balance"]].to_string())

print("\n18.12 A group total on every row with transform")
ALLOWED = ["East Midlands", "East of England", "London",
           "North East", "North West", "Scotland",
           "South East", "South West", "Wales",
           "West Midlands", "Yorkshire and the Humber"]
mapping = {name.lower(): name for name in ALLOWED}
mapping["greater london"] = "London"
clean = tape["region"].str.strip().str.lower().map(mapping)
tape["region_clean"] = clean
by_region = tape.groupby("region_clean")["current_balance"]
tape["pct_of_region"] = tape["current_balance"] / by_region.transform("sum")
print(tape[["loan_id", "region_clean", "current_balance", "pct_of_region"]].head(3).to_string())

print("\n18.12 Several conditions with np.select")
tape["stage"] = np.select(
    [tape["arrears_months"] >= 3, tape["arrears_months"] >= 1],
    ["Stage 3", "Stage 2"], default="Stage 1")
print(tape["stage"].value_counts().sort_index().to_string())    # 1,102 / 74 / 24

print("\n18.12 Nine calls worth knowing")
print(tape["rate_type"].value_counts(normalize=True).round(3).to_string())  # Fixed 71.1%
print("drop_duplicates keeps", len(tape.drop_duplicates("loan_id")), "rows")  # 1,199
monthly = (hist[hist["status"] == "Active"]
           .groupby("month_end")["current_balance"].sum())
print("Three-month average:\n" + monthly.rolling(3).mean().dropna().map("{:,.0f}".format).to_string())
print(f"June change: {monthly.pct_change().iloc[-1]:.2%}")       # -1.06%
factor = (1 + monthly.pct_change().fillna(0)).cumprod()
print(f"Pool factor in June: {factor.iloc[-1]:.3f}")             # 0.940

print("\n18.12 Arrears by vintage (share of balance 3+ months in arrears)")
h = hist.merge(tape[["loan_id", "origination_date"]].drop_duplicates("loan_id"),
               on="loan_id")
h["vintage"] = h["origination_date"].astype(str).str[:4]
act = h[h["status"] == "Active"]
keys = ["vintage", "month_end"]
late = act[act["arrears_months"] >= 3]
curve = (late.groupby(keys)["current_balance"].sum()
         / act.groupby(keys)["current_balance"].sum())
table = curve.fillna(0).unstack("month_end")
print(table.map(lambda x: f"{x:.2%}").to_string())   # June: 2016 6.80%, 2025 1.24%

# A true vintage curve: months since origination on the columns
h["month_end"] = pd.to_datetime(h["month_end"])
h["mob"] = ((h["month_end"].dt.year - h["origination_date"].dt.year) * 12
            + (h["month_end"].dt.month - h["origination_date"].dt.month))
print("Months on book of the 2025 vintage in June:",
      sorted(int(m) for m in h.loc[(h["vintage"] == "2025")
                                    & (h["month_end"] == "2026-06-30"), "mob"].unique()))

print("\n18.12 Dates in a schedule")
dates = pd.date_range("2026-07-31", periods=12, freq="ME")
print(dates[:3].strftime("%Y-%m-%d").tolist(), "...")
print("Days between month-ends:", dates.to_series().diff().dt.days.dropna().astype(int).tolist())

print("\n18.12 Many monthly files")
files = sorted(Path("incoming").glob("tape_*.csv"))
if files:
    tapes = pd.concat([pd.read_csv(f).assign(source=f.name) for f in files],
                      ignore_index=True)
    print(f"{len(files)} files, {len(tapes):,} rows")
else:
    print("No tape files in incoming/ (the companion has none: use your own folder)")

print("\n18.12 Wide and long tables")
wide = hist.pivot(index="loan_id", columns="month_end", values="arrears_months")
long = wide.reset_index().melt(id_vars="loan_id", var_name="month_end",
                               value_name="arrears_months")
print(f"wide {wide.shape}, long {long.shape}")

print("\n18.12 Handling errors")
import logging  # noqa: E402
logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
log = logging.getLogger("monthly_checks")
path = DATA / "ashcombe_loan_tape.csv"
try:
    checked = pd.read_csv(path)
    log.info("Tape loaded: %s rows", f"{len(checked):,}")
except FileNotFoundError:
    log.error("Tape not delivered: %s", path)
    raise SystemExit(1)

print("\n18.12 A tidy Excel output")
region = (tape.groupby("region_clean")["current_balance"].sum()
              .sort_values(ascending=False).to_frame("balance"))
region["pct_of_pool"] = region["balance"] / region["balance"].sum()
with pd.ExcelWriter(out / "ashcombe_region_tidy.xlsx", engine="openpyxl") as xl:
    region.to_excel(xl, sheet_name="Region")
    ws = xl.sheets["Region"]
    ws.column_dimensions["A"].width = 28
    for cell in ws["C"][1:]:
        cell.number_format = "0.0%"
    ws.freeze_panes = "A2"
print("Saved python/output/ashcombe_region_tidy.xlsx")
