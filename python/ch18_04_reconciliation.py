"""Chapter 18, section 18.5: reconcile the tape with the servicer's balances."""
import sys
sys.stdout.reconfigure(errors="replace")  # print £ safely on any console
from pathlib import Path
import pandas as pd

DATA = Path(__file__).resolve().parent.parent / "data"
tape = pd.read_csv(DATA / "ashcombe_loan_tape.csv")
serv = pd.read_csv(DATA / "servicer_balances.csv")

# Step 1: totals
totals = pd.DataFrame({
    "rows": [len(tape), len(serv)],
    "distinct_ids": [tape["loan_id"].nunique(), serv["loan_id"].nunique()],
    "balance": [tape["current_balance"].sum(), serv["current_balance"].sum()],
}, index=["tape", "servicer"])
print(totals, "\n")

# Step 2 and 3: keys and values, in one outer merge
rec = tape[["loan_id", "current_balance"]].merge(
    serv[["loan_id", "current_balance"]], on="loan_id", how="outer",
    suffixes=("_tape", "_servicer"), indicator=True)
rec["difference"] = rec["current_balance_tape"] - rec["current_balance_servicer"]

exceptions = rec[(rec["_merge"] != "both") | (rec["difference"] != 0)]
print(exceptions.to_string(index=False))
