"""Chapter 18, section 18.4: data-quality checks; writes exceptions to a CSV."""
import sys
if hasattr(sys.stdout, "reconfigure"):  # consoles only; notebooks print £ already
    sys.stdout.reconfigure(errors="replace")
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
tape = pd.read_csv(ROOT / "data" / "ashcombe_loan_tape.csv",
                   parse_dates=["origination_date", "maturity_date"])

ALLOWED_REGIONS = {"East Midlands", "East of England", "London", "North East", "North West",
                   "Scotland", "South East", "South West", "Wales", "West Midlands",
                   "Yorkshire and the Humber"}

months = ((tape["maturity_date"].dt.year - tape["origination_date"].dt.year) * 12
          + (tape["maturity_date"].dt.month - tape["origination_date"].dt.month))
recalc_iltv = tape["current_balance"] / tape["indexed_valuation"]

rules = {
    "Duplicate loan_id": tape["loan_id"].duplicated(keep=False),
    "Missing indexed valuation": tape["indexed_valuation"].isna(),
    "Stored indexed LTV differs by more than 0.5%": (recalc_iltv - tape["indexed_ltv"]).abs() > 0.005,
    "Interest rate outside 0.5% to 15%": ~tape["interest_rate"].between(0.005, 0.15),
    "Maturity not origination + term": months != tape["original_term_months"],
    "Region not in allowed list": ~tape["region"].isin(ALLOWED_REGIONS),
    "Repayment loan above original balance": (tape["repayment_type"] == "Repayment")
                                             & (tape["current_balance"] > tape["original_balance"]),
    "Term does not add up": tape["original_term_months"]
                            != tape["seasoning_months"] + tape["remaining_term_months"],
}

frames = []
for rule, failed in rules.items():
    hits = tape.loc[failed, ["loan_id", "current_balance"]].copy()
    hits["rule_failed"] = rule
    frames.append(hits)
    print(f"{rule:<48} {failed.sum():>3}")

exceptions = pd.concat(frames, ignore_index=True)
out = ROOT / "python" / "output"
out.mkdir(exist_ok=True)
exceptions.to_csv(out / "dq_exceptions.csv", index=False)
print(f"\n{len(exceptions)} exceptions written to {out / 'dq_exceptions.csv'}")
