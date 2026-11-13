"""Chapter 18, section 18.10: read from a database with SQL, log each step, stop on a failed check."""
import sys
sys.stdout.reconfigure(errors="replace")  # print £ safely on any console
import logging
import sqlite3
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s",
                    datefmt="%Y-%m-%d %H:%M:%S")
log = logging.getLogger("monthly_checks")

db = ROOT / "sql" / "sqlite_version" / "ashcombe.db"
if not db.exists():
    raise SystemExit("Run python sql/sqlite_version/build_db.py first")
query = """
    SELECT loan_id, current_balance, arrears_months
    FROM loan_history
    WHERE month_end = ? AND status = 'Active'
"""
with sqlite3.connect(db) as con:
    june = pd.read_sql(query, con, params=["2026-06-30"])
con.close()
log.info("Loaded %s loans, balance £%s", f"{len(june):,}", f"{june['current_balance'].sum():,.0f}")

control_balance = 240_000_000
difference = june["current_balance"].sum() - control_balance
if abs(difference) > 0.5:
    log.error("Balance differs from control total by £%s", f"{difference:,.2f}")
    raise SystemExit(1)
log.info("Control total agreed")

if june["loan_id"].duplicated().any():
    log.error("Duplicate loan IDs found")
    raise SystemExit(1)
log.info("Loan IDs unique")

share_3plus = june.loc[june["arrears_months"] >= 3, "current_balance"].sum() / june["current_balance"].sum()
log.info("3+ months arrears: %.2f%% of the pool", 100 * share_3plus)
