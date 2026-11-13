"""Checks that the SQLite numbers and statements printed in the book come out of SQLite.
Run from the repository root after:  python sql/sqlite_version/build_db.py
Usage:  python tests/check_sqlite.py"""
import sqlite3, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
con = sqlite3.connect(ROOT / "sql" / "sqlite_version" / "ashcombe.db")
q = lambda s: con.execute(s).fetchall()
CHECKS = [
    ("Ch0: 1,200 loans, 240,000,000", "SELECT COUNT(*), SUM(current_balance) FROM loan_tape", [(1200, 240000000.0)]),
    ("Ch17 2.2: WA rate 0.05444", "SELECT ROUND(SUM(interest_rate*current_balance)/SUM(current_balance), 5) FROM loan_tape", [(0.05444,)]),
    ("Ch17 17.3: London 188 / 1 / 1",
     "SELECT region, COUNT(*) FROM loan_tape WHERE lower(trim(region)) = 'london' GROUP BY region ORDER BY region",
     [("London", 188), ("London ", 1), ("london", 1)]),
    ("Ch17 5.1/6.4: 14 groups", "SELECT COUNT(*) FROM (SELECT region FROM loan_tape GROUP BY region)", [(14,)]),
    ("Ch17 17.12: 14 distinct regions", "SELECT COUNT(*) FROM (SELECT DISTINCT region FROM loan_tape)", [(14,)]),
    ("Ch20 Q4: London exact 16.15%", "SELECT ROUND(100.0*SUM(current_balance)/240000000, 2) FROM loan_tape WHERE region = 'London'", [(16.15,)]),
    ("Ch17 practice 9 (SQLite): six rows",
     "SELECT COUNT(*) FROM (SELECT region FROM loan_tape GROUP BY region HAVING AVG(current_balance) > 205000)", [(6,)]),
    ("Ch17 9.7: vintage via substr", "SELECT substr(origination_date, 1, 4), ROUND(100.0*SUM(CASE WHEN arrears_months >= 3 THEN current_balance ELSE 0 END)/SUM(current_balance), 2) FROM loan_tape WHERE substr(origination_date, 1, 4) IN ('2016', '2025') GROUP BY 1 ORDER BY 1",
     [("2016", 6.8), ("2025", 1.24)]),
    ("Ch17 17.12: month-end + 3 months", "SELECT date('2026-01-31', 'start of month', '+4 months', '-1 day')", [("2026-04-30",)]),
    ("Ch17 17.12: '+1 month' rolls into March", "SELECT date('2026-01-31', '+1 month')", [("2026-03-03",)]),
    ("Ch17 17.12: strftime needs CAST", "SELECT strftime('%m', '2026-06-30') = 6, CAST(strftime('%m', '2026-06-30') AS INTEGER) = 6", [(0, 1)]),
    ("Ch17 17.6: 7 / 2 = 3", "SELECT 7 / 2", [(3,)]),
    ("Ch17 17.12: x / 0 is NULL in SQLite", "SELECT 1 / 0", [(None,)]),
    ("Ch17 17.12: safe conversion", "SELECT CASE WHEN trim(s) <> '' AND trim(s) NOT GLOB '*[^0-9.]*' THEN CAST(trim(s) AS REAL) END FROM (SELECT 'abc' AS s UNION ALL SELECT '152661.50')",
     [(None,), (152661.5,)]),
    ("Ch17 correction 7: SQLite accepts the ungrouped column", "SELECT COUNT(*) FROM (SELECT region, SUM(current_balance) FROM loan_tape)", [(1,)]),
    ("Ch17 17.14: EXCEPT rows", "SELECT loan_id FROM (SELECT loan_id, current_balance FROM servicer_balances EXCEPT SELECT loan_id, current_balance FROM loan_tape) ORDER BY 1",
     [("ASH100500",), ("ASH100501",), ("ASH100888",)]),
    ("Ch17 17.14: three-month average", "WITH m AS (SELECT month_end, SUM(current_balance) AS b FROM loan_history WHERE status = 'Active' GROUP BY month_end) SELECT ROUND(AVG(b) OVER (ORDER BY month_end ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)) FROM m ORDER BY month_end DESC LIMIT 1",
     [(242681670.0,)]),
    ("Ch17 interview: median of an even count", "SELECT AVG(current_balance) FROM (SELECT current_balance FROM loan_tape ORDER BY current_balance LIMIT 2 OFFSET 599)", [(179211.5,)]),
]
bad = 0
for name, sql, want in CHECKS:
    got = q(sql)
    ok = got == want
    bad += not ok
    print(f"{'pass' if ok else 'FAIL'}  {name}" + ("" if ok else f": got {got}, expected {want}"))
print("ALL SQLITE CHECKS PASSED" if not bad else f"{bad} SQLITE CHECKS FAILED")
sys.exit(1 if bad else 0)
