"""Chapter 18, section 18.2: load the tape and look at it."""
import sys
if hasattr(sys.stdout, "reconfigure"):  # consoles only; notebooks print £ already
    sys.stdout.reconfigure(errors="replace")
from pathlib import Path
import pandas as pd

DATA = Path(__file__).resolve().parent.parent / "data"
tape = pd.read_csv(DATA / "ashcombe_loan_tape.csv",
                   parse_dates=["origination_date", "maturity_date"])

print(tape.shape)                      # (rows, columns)
print(tape.head(3).T)                  # first 3 loans, turned on their side
print(tape.dtypes.value_counts())      # how many columns of each type
print(tape["current_balance"].describe().round(0))
print(tape["rate_type"].value_counts())
print(tape.isna().sum()[lambda s: s > 0])   # columns with blanks

# Filtering: loans 3+ months in arrears, largest first
arrears3 = tape[tape["arrears_months"] >= 3].sort_values("current_balance", ascending=False)
print(len(arrears3), "loans 3+ months in arrears; balance", f"£{arrears3['current_balance'].sum():,.0f}")
print(arrears3[["loan_id", "current_balance", "arrears_months"]].head())
