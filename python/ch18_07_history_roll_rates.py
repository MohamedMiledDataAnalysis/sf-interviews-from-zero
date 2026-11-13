"""Chapter 18, section 18.8: six months of history: pool trend, movements and roll rates."""
import sys
if hasattr(sys.stdout, "reconfigure"):  # consoles only; notebooks print £ already
    sys.stdout.reconfigure(errors="replace")
from pathlib import Path
import pandas as pd

DATA = Path(__file__).resolve().parent.parent / "data"
hist = pd.read_csv(DATA / "ashcombe_loan_history.csv", parse_dates=["month_end"])

# 1. Pool trend: active loans and balance by month
active = hist[hist["status"] == "Active"]
trend = active.groupby("month_end").agg(loans=("loan_id", "size"),
                                        balance=("current_balance", "sum"))
print(trend, "\n")

# 2. Movements: previous balance for each loan with shift() inside each loan
hist = hist.sort_values(["loan_id", "month_end"])
hist["prev_balance"] = hist.groupby("loan_id")["current_balance"].shift(1)
moves = hist.dropna(subset=["prev_balance"])
moves = moves.assign(
    redemptions=moves["prev_balance"].where(moves["status"] == "Redeemed", 0),
    other_principal=(moves["prev_balance"] - moves["current_balance"]).where(moves["status"] == "Active", 0))
summary = (moves.groupby("month_end")[["prev_balance", "redemptions", "other_principal", "current_balance"]]
                .sum().rename(columns={"prev_balance": "opening", "current_balance": "closing"}))
summary["check"] = summary["opening"] - summary["redemptions"] - summary["other_principal"] - summary["closing"]
print(summary, "\n")

# 3. Roll-rate matrix, May to June, for loans active in June
def bucket(m):
    return "3+" if m >= 3 else str(int(m))

wide = hist.pivot(index="loan_id", columns="month_end", values="arrears_months")
status_jun = hist[hist["month_end"] == "2026-06-30"].set_index("loan_id")["status"]
pairs = wide[[pd.Timestamp("2026-05-31"), pd.Timestamp("2026-06-30")]].dropna()
pairs = pairs[status_jun.reindex(pairs.index) == "Active"]
counts = pd.crosstab(pairs.iloc[:, 0].map(bucket), pairs.iloc[:, 1].map(bucket),
                     rownames=["May"], colnames=["June"], margins=True, margins_name="Total")
print(counts, "\n")
rates = pd.crosstab(pairs.iloc[:, 0].map(bucket), pairs.iloc[:, 1].map(bucket),
                    rownames=["May"], colnames=["June"], normalize="index")
print((rates * 100).round(1))
