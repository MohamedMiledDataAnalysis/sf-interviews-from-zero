"""Chapter 18: answers to the Python practice set (1 to 8) and corrections to the
exercises (1 to 8). Try each task yourself before you run this file.
Run from the companion folder:  python python/ch18_11_practice_answers.py"""
import sys
if hasattr(sys.stdout, "reconfigure"):  # consoles only; notebooks print £ already
    sys.stdout.reconfigure(errors="replace")
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"
out = ROOT / "python" / "output"
out.mkdir(exist_ok=True)
sys.path.append(str(ROOT / "python"))
from ch18_05_waterfall import run_waterfall  # noqa: E402
from ch18_08_cashflow_projection import project, wal  # noqa: E402

# The practice preamble
tape = pd.read_csv(DATA / "ashcombe_loan_tape.csv")
hist = pd.read_csv(DATA / "ashcombe_loan_history.csv")
ALLOWED = ["East Midlands", "East of England", "London",
           "North East", "North West", "Scotland",
           "South East", "South West", "Wales",
           "West Midlands", "Yorkshire and the Humber"]
mapping = {name.lower(): name for name in ALLOWED}
mapping["greater london"] = "London"
tape["region_clean"] = tape["region"].str.strip().str.lower().map(mapping)


def show(title, result):
    print(f"\n{title}")
    print(result.to_string() if hasattr(result, "to_string") else result)


# Answer 1. Loans by occupancy and repayment type
show("Answer 1", pd.crosstab(tape["occupancy"], tape["repayment_type"]))

# Answer 2. Balance-weighted indexed LTV by region
w = tape["indexed_ltv"] * tape["current_balance"]
g = (tape.assign(w=w)
         .groupby("region_clean")[["w", "current_balance"]].sum())
region_ltv = (g["w"] / g["current_balance"]).sort_values(ascending=False)
show("Answer 2 (highest East of England 62.4%, lowest North East 56.2%)",
     region_ltv.map("{:.1%}".format))

# Answer 3. The five regions with the largest balance 3+ months in arrears
late = tape[tape["arrears_months"] >= 3]
by_region = late.groupby("region_clean")["current_balance"]
show("Answer 3", by_region.sum().nlargest(5))

# Answer 4. Affordability: annual payments / borrower income
ratio = tape["monthly_payment"] * 12 / tape["borrower_income"]
show("Answer 4: loans above 30%, and the median",
     f"{(ratio > 0.30).sum()} loans; median {ratio.median():.1%}")   # 190; 24.7%

# Answer 5. Loans active in May and June that paid no principal
active = hist[hist["status"] == "Active"]
wide = active.pivot(index="loan_id", columns="month_end", values="current_balance")
both = wide[["2026-05-31", "2026-06-30"]].dropna()
no_principal = (both["2026-05-31"] == both["2026-06-30"]).sum()
show("Answer 5", f"{no_principal} loans")                          # 293

# Answer 6. Annualised rate of full redemptions
h6 = hist.sort_values(["loan_id", "month_end"]).copy()
h6["prev"] = h6.groupby("loan_id")["current_balance"].shift(1)
h6 = h6.dropna(subset=["prev"])
h6 = h6.assign(red=h6["prev"].where(h6["status"] == "Redeemed", 0))
g6 = h6.groupby("month_end")[["red", "prev"]].sum()
rates = 1 - (1 - g6["red"] / g6["prev"]) ** 12
show("Answer 6 (Feb 14.7%, Mar 11.7%, Apr 12.8%, May 11.5%, Jun 10.5%)",
     rates.map("{:.1%}".format))


# Answer 7. A reusable strat function
def strat(df, column, edges, balance="current_balance"):
    buckets = pd.cut(df[column], bins=edges)
    result = df.groupby(buckets, observed=False).agg(
        loans=("loan_id", "size"), balance=(balance, "sum"))
    result["pct_of_pool"] = result["balance"] / result["balance"].sum()
    assert result["loans"].sum() == len(df), "Some loans fall outside the edges"
    return result


show("Answer 7", strat(tape, "seasoning_months", [0, 12, 36, 60, 120, 200]))

# Answer 8. The DQ exceptions, one sheet per rule
dq_file = out / "dq_exceptions.csv"
if dq_file.exists():
    exceptions = pd.read_csv(dq_file)
    with pd.ExcelWriter(out / "dq_by_rule.xlsx") as xl:
        rules = exceptions.groupby("rule_failed")
        for i, (rule, group) in enumerate(rules, start=1):
            group.to_excel(xl, sheet_name=f"Rule {i}", index=False)
    show("Answer 8", f"python/output/dq_by_rule.xlsx: {rules.ngroups} sheets")
else:
    show("Answer 8", "Run python/ch18_03_data_quality.py first")

# Correction 1. Balance-weighted interest rate by rate type
w = tape["interest_rate"] * tape["current_balance"]
g = (tape.assign(w=w)
         .groupby("rate_type")[["w", "current_balance"]].sum())
show("Correction 1 (the Fixed figure includes the keying error)",
     (g["w"] / g["current_balance"]).map("{:.3%}".format))

# Correction 2. Balance-size strat, tied to the tape
size = strat(tape, "current_balance",
             [0, 100_000, 200_000, 300_000, 500_000, 10_000_000])
assert size["loans"].sum() == 1200 and size["balance"].sum() == 240_000_000
show("Correction 2", size)

# Correction 3. validate="one_to_one" on the reconciliation merge
serv = pd.read_csv(DATA / "servicer_balances.csv")
try:
    tape[["loan_id", "current_balance"]].merge(
        serv[["loan_id", "current_balance"]], on="loan_id", how="outer",
        suffixes=("_tape", "_servicer"), indicator=True,
        validate="one_to_one")
    show("Correction 3", "No error")
except pd.errors.MergeError as e:
    show("Correction 3: MergeError, because ASH100213 appears twice", e)

# Correction 4. The smallest month 2 loss that empties the reserve
m1 = run_waterfall(236_900_000, 203_300_000, 33_600_000,
                   2_400_000, 1_045_000, 2_880_000, 52_000)


def month2(losses):
    return run_waterfall(m1["Closing pool"], m1["Closing Class A"],
                         m1["Closing Class B"], m1["Closing reserve"],
                         1_038_000, 3_150_000, losses)


loss = 260_000
while month2(loss)["Closing reserve"] > 0:
    loss += 1_000
show("Correction 4 (£2,424,000; at £2,423,000 the reserve is £148)",
     f"£{loss:,}; reserve at £{loss - 1_000:,}: "
     f"£{month2(loss - 1_000)['Closing reserve']:,.0f}")

# Correction 5. The ten largest loans with their cumulative % of the pool
cols = ["loan_id", "current_balance"]
top = tape.sort_values("current_balance", ascending=False).head(10)[cols]
total = tape["current_balance"].sum()
top["cum_pct"] = top["current_balance"].cumsum() / total
show("Correction 5 (the tenth row shows 2.67%)", top)

# Correction 6. The WA rate with the 53.7% rate corrected
fixed = tape.copy()
row = fixed["loan_id"] == "ASH100602"
fixed.loc[row, "interest_rate"] = 0.0537
bal = fixed["current_balance"]
show("Correction 6", f"{(fixed['interest_rate'] * bal).sum() / bal.sum():.3%}")  # 5.400%

# Correction 7. 3+ months arrears as % of the pool, each month
a = hist[hist["status"] == "Active"]
late = a["arrears_months"] >= 3
a = a.assign(b3=a["current_balance"].where(late, 0))
g7 = a.groupby("month_end")[["b3", "current_balance"]].sum()
show("Correction 7 (May 1.47%, June 1.94%)",
     (g7["b3"] / g7["current_balance"]).map("{:.2%}".format))

# Correction 8. The CPR at which Class A's WAL is closest to 4 years
print("\nCorrection 8 (13.0% gives 4.006 years)")
for cpr in [0.10 + 0.005 * i for i in range(11)]:
    cf = project(cpr=cpr)
    print(f"{cpr:.1%}", round(wal(cf, "class_a_principal"), 3))
