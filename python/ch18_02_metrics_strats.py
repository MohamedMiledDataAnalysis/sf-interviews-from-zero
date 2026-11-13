"""Chapter 18, section 18.3: pool metrics and stratification tables."""
import sys
sys.stdout.reconfigure(errors="replace")  # print £ safely on any console
from pathlib import Path
import pandas as pd

DATA = Path(__file__).resolve().parent.parent / "data"
tape = pd.read_csv(DATA / "ashcombe_loan_tape.csv")
bal = tape["current_balance"]


def wa(column):
    """Balance-weighted average of a column."""
    return (tape[column] * bal).sum() / bal.sum()


summary = pd.Series({
    "Loans": len(tape),
    "Pool balance": bal.sum(),
    "Average balance": bal.mean(),
    "WA interest rate": wa("interest_rate"),
    "WA original LTV": wa("original_ltv"),
    "WA indexed LTV": wa("indexed_ltv"),
    "WA seasoning (months)": wa("seasoning_months"),
})
fmt = {"Loans": "{:,.0f}", "Pool balance": "£{:,.0f}", "Average balance": "£{:,.0f}",
       "WA interest rate": "{:.3%}", "WA original LTV": "{:.2%}", "WA indexed LTV": "{:.2%}",
       "WA seasoning (months)": "{:.1f}"}
for name, value in summary.items():
    print(f"{name:<24} {fmt[name].format(value):>16}")

# Indexed LTV strat with pd.cut: (0, 0.5], (0.5, 0.6] ...
edges = [0, 0.5, 0.6, 0.7, 0.8, 0.9, 10]
labels = ["50% or less", ">50% to 60%", ">60% to 70%", ">70% to 80%", ">80% to 90%", "Over 90%"]
tape["ltv_bucket"] = pd.cut(tape["indexed_ltv"], bins=edges, labels=labels)

strat = (tape.groupby("ltv_bucket", observed=False)
             .agg(loans=("loan_id", "size"), balance=("current_balance", "sum")))
strat["pct_of_pool"] = strat["balance"] / strat["balance"].sum()
strat.loc["Total"] = strat.sum()
strat["loans"] = strat["loans"].astype(int)
print(strat)

assert strat.loc["Total", "loans"] == len(tape), "Strat count does not tie to the tape"
assert abs(strat.loc["Total", "balance"] - bal.sum()) < 0.5, "Strat balance does not tie to the tape"
print("Strat ties to the tape.")

# Two-way table: balance by rate type and repayment type
pivot = pd.pivot_table(tape, values="current_balance", index="rate_type",
                       columns="repayment_type", aggfunc="sum", margins=True, margins_name="Total")
print(pivot)
