-- "Five more patterns interviewers test" and "Changing data" (SQLite).
-- Every change in this file is rolled back or made to a temporary table,
-- so the database is unchanged when the script ends.
-- SQLite has no ROLLUP, MERGE, TRY ... CATCH or sp_executesql: the
-- SQLite equivalents the book gives are used instead.

-- 14.1 A filter in ON: keeps every January loan
-- Expected: 1,257 rows, 46 with a NULL June balance
SELECT COUNT(*) AS rows_kept,
       SUM(CASE WHEN jun_balance IS NULL THEN 1 ELSE 0 END) AS null_june
FROM (
  SELECT a.loan_id, j.current_balance AS jun_balance
  FROM loan_history AS a
  LEFT JOIN loan_history AS j
    ON j.loan_id = a.loan_id AND j.month_end = '2026-06-30'
  WHERE a.month_end = '2026-01-31'
);

-- 14.2 Wrong: the June filter in WHERE drops the 46 loans
-- Expected: 1,211 rows
SELECT COUNT(*) AS rows_kept
FROM (
  SELECT a.loan_id, j.current_balance AS jun_balance
  FROM loan_history AS a
  LEFT JOIN loan_history AS j ON j.loan_id = a.loan_id
  WHERE a.month_end = '2026-01-31'
    AND j.month_end = '2026-06-30'
);

-- 14.3 EXCEPT: the servicer's rows that the tape does not match
-- Expected: ASH100500 157,900; ASH100501 79,890; ASH100888 73,590
SELECT loan_id, current_balance FROM servicer_balances
EXCEPT
SELECT loan_id, current_balance FROM loan_tape
ORDER BY loan_id;

-- 14.4 INTERSECT: the rows in both (count only)
SELECT COUNT(*) AS rows_in_both
FROM (SELECT loan_id, current_balance FROM servicer_balances
      INTERSECT
      SELECT loan_id, current_balance FROM loan_tape);

-- 14.5 A total row: SQLite has no ROLLUP, so add it with UNION ALL
-- Expected last row: Total, 1,200 loans, 240,000,000
SELECT rate_type, loans, balance
FROM (
  SELECT 0 AS is_total, rate_type, COUNT(*) AS loans,
         SUM(current_balance) AS balance
  FROM loan_tape GROUP BY rate_type
  UNION ALL
  SELECT 1, 'Total', COUNT(*), SUM(current_balance) FROM loan_tape
)
ORDER BY is_total, balance DESC;

-- 14.6 A three-month moving average with a window frame
-- Expected: June 242,681,670 (rounded)
WITH m AS (
    SELECT month_end, SUM(current_balance) AS balance
    FROM loan_history WHERE status = 'Active'
    GROUP BY month_end
)
SELECT month_end, balance,
       AVG(balance) OVER (
           ORDER BY month_end
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS avg_3_months
FROM m;

-- 14.7 UPDATE ... FROM (SQLite 3.33 or later), inside a transaction
-- that is rolled back. A SAVEPOINT is SQLite's named transaction: it
-- works whether or not a transaction is already open.
SAVEPOINT change;
UPDATE loan_tape SET current_balance = s.current_balance
FROM servicer_balances AS s
WHERE s.loan_id = loan_tape.loan_id
  AND loan_tape.loan_id IN ('ASH100500', 'ASH100501');
-- Expected: 157,900 and 79,890 (the servicer's balances)
SELECT loan_id, current_balance FROM loan_tape
WHERE loan_id IN ('ASH100500', 'ASH100501');
ROLLBACK TO change;
RELEASE change;

-- 14.8 Delete duplicates on a staging table with no key
DROP TABLE IF EXISTS temp.staging;
CREATE TEMP TABLE staging AS
SELECT loan_id, month_end, current_balance
FROM loan_history WHERE month_end = '2026-06-30';
-- load the same file twice by mistake
INSERT INTO staging
SELECT loan_id, month_end, current_balance
FROM loan_history WHERE month_end = '2026-06-30';
DELETE FROM staging
WHERE rowid NOT IN (SELECT MIN(rowid) FROM staging
                    GROUP BY loan_id, month_end);
-- Expected: 1,211 rows, 1,211 distinct loans
SELECT COUNT(*) AS rows_left, COUNT(DISTINCT loan_id) AS loans
FROM staging;

-- 14.9 Insert or update in one statement: SQLite's upsert (no MERGE)
DROP TABLE IF EXISTS temp.loans;
CREATE TEMP TABLE loans (loan_id TEXT PRIMARY KEY, current_balance REAL);
INSERT INTO loans
SELECT loan_id, current_balance FROM loan_tape
WHERE loan_id IN ('ASH100500', 'ASH100501');
INSERT INTO loans (loan_id, current_balance)
SELECT loan_id, current_balance FROM servicer_balances
WHERE loan_id IN ('ASH100500', 'ASH100501', 'ASH100888')
ON CONFLICT (loan_id) DO UPDATE
SET current_balance = excluded.current_balance;
-- Expected: ASH100500 157,900; ASH100501 79,890; ASH100888 73,590
SELECT loan_id, current_balance FROM loans ORDER BY loan_id;

-- 14.10 SQLite has no TRY ... CATCH: the calling program (Python, for
-- example) rolls back when a statement fails.

-- 14.11 Parameters: SQLite has no sp_executesql; in Python, pass the
-- value separately: con.execute("... WHERE month_end = ?", ("2026-06-30",))
-- Expected: 1,211
SELECT COUNT(*) AS rows_in_june FROM loan_history
WHERE month_end = '2026-06-30';

-- 15.1 A transaction: check, then roll back (or RELEASE to keep it)
SAVEPOINT change;
UPDATE loan_tape
SET region = 'London'
WHERE loan_id = 'ASH100096';
SELECT loan_id, region FROM loan_tape
WHERE loan_id = 'ASH100096';
ROLLBACK TO change;
RELEASE change;
-- Expected: the region is back to its original value
SELECT loan_id, region FROM loan_tape WHERE loan_id = 'ASH100096';
