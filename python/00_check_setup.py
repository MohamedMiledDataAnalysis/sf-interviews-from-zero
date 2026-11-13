"""Chapter 0: checks that Python, pandas and the companion files work.
Run from the companion folder:  python python/00_check_setup.py"""
import sys
if hasattr(sys.stdout, "reconfigure"):  # consoles only; notebooks print £ already
    sys.stdout.reconfigure(errors="replace")
from pathlib import Path
import pandas as pd

DATA = Path(__file__).resolve().parent.parent / "data"
tape = pd.read_csv(DATA / "ashcombe_loan_tape.csv")

print(f"Loans: {len(tape):,}")
print(f"Pool balance: £{tape['current_balance'].sum():,.0f}")
print(f"pandas {pd.__version__}")
ok = len(tape) == 1200 and round(tape["current_balance"].sum()) == 240_000_000
old = tuple(int(x) for x in pd.__version__.split(".")[:2]) < (2, 2)
if old:
    print("Please upgrade pandas: python -m pip install -r requirements.txt")
print("Setup OK" if ok and not old
      else "Something is wrong: see the message above, or expected 1,200 loans and £240,000,000")
