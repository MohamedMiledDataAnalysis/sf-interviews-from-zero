"""Chapter 18, section 18.7: write a small monthly pack to Excel, with a chart image."""
import sys
sys.stdout.reconfigure(errors="replace")  # print £ safely on any console
from pathlib import Path
import pandas as pd
import matplotlib
matplotlib.use("Agg")  # scripts only: leave this line out in a notebook
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent
tape = pd.read_csv(ROOT / "data" / "ashcombe_loan_tape.csv")
out = ROOT / "python" / "output"
out.mkdir(exist_ok=True)

tape["arrears_bucket"] = pd.cut(tape["arrears_months"], bins=[-1, 0, 1, 2, 999],
                                labels=["Up to date", "1 month", "2 months", "3+ months"])
arrears = (tape.groupby("arrears_bucket", observed=False)
               .agg(loans=("loan_id", "size"), balance=("current_balance", "sum")))
arrears["pct_of_pool"] = arrears["balance"] / arrears["balance"].sum()

# Clean the region names: strip spaces, match ignoring case, map known variants
ALLOWED = ["East Midlands", "East of England", "London", "North East", "North West", "Scotland",
           "South East", "South West", "Wales", "West Midlands", "Yorkshire and the Humber"]
mapping = {name.lower(): name for name in ALLOWED}
mapping["greater london"] = "London"
clean = tape["region"].str.strip().str.lower().map(mapping)
assert clean.notna().all(), "A region could not be mapped: add it to the mapping"

region = (tape.assign(region=clean)
              .groupby("region")["current_balance"].sum()
              .sort_values(ascending=False).to_frame("balance"))
region["pct_of_pool"] = region["balance"] / region["balance"].sum()

with pd.ExcelWriter(out / "ashcombe_pack.xlsx", engine="openpyxl") as xl:
    arrears.to_excel(xl, sheet_name="Arrears")
    region.to_excel(xl, sheet_name="Region")

ax = (arrears["pct_of_pool"].iloc[1:] * 100).plot(kind="bar", color="#1F3A5F", figsize=(6, 3.5))
ax.set_ylabel("% of pool balance")
ax.set_xlabel("")
ax.set_title("Ashcombe: loans in arrears, 30 June 2026")
plt.xticks(rotation=0)
plt.tight_layout()
plt.savefig(out / "arrears.png", dpi=150)
print("Written:", out / "ashcombe_pack.xlsx", "and", out / "arrears.png")
print(region.round(4))
