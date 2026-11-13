-- Structured Finance Interviews from Zero, Chapter 17 (SQL Server / T-SQL).
-- "Five more patterns interviewers test" and "Changing data".
-- Run 00_setup.sql first. SQLite versions are in sqlite_version/.
-- Every change in this file is rolled back or made to a temporary table,
-- so the database is unchanged when the script ends.
USE ashcombe;
GO

-- 14.1 A filter in ON: keeps every January loan
-- Expected: 1,257 rows, 46 with a NULL June balance
SELECT a.loan_id, j.current_balance AS jun_balance
FROM dbo.loan_history AS a
LEFT JOIN dbo.loan_history AS j
  ON j.loan_id = a.loan_id AND j.month_end = '2026-06-30'
WHERE a.month_end = '2026-01-31';

-- 14.2 Wrong: the June filter in WHERE drops the 46 loans
-- Expected: 1,211 rows
SELECT a.loan_id, j.current_balance AS jun_balance
FROM dbo.loan_history AS a
LEFT JOIN dbo.loan_history AS j ON j.loan_id = a.loan_id
WHERE a.month_end = '2026-01-31'
  AND j.month_end = '2026-06-30';

-- 14.3 EXCEPT: the servicer's rows that the tape does not match
-- Expected: ASH100500 157,900; ASH100501 79,890; ASH100888 73,590
SELECT loan_id, current_balance FROM dbo.servicer_balances
EXCEPT
SELECT loan_id, current_balance FROM dbo.loan_tape
ORDER BY loan_id;

-- 14.4 INTERSECT: the rows in both (count only)
SELECT COUNT(*) AS rows_in_both
FROM (SELECT loan_id, current_balance FROM dbo.servicer_balances
      INTERSECT
      SELECT loan_id, current_balance FROM dbo.loan_tape) AS x;

-- 14.5 A total row with ROLLUP
-- Expected last row: Total, 1,200 loans, 240,000,000
SELECT CASE WHEN GROUPING(rate_type) = 1 THEN 'Total'
            ELSE rate_type END AS rate_type,
       COUNT(*) AS loans, SUM(current_balance) AS balance
FROM dbo.loan_tape
GROUP BY ROLLUP(rate_type)
ORDER BY GROUPING(rate_type), balance DESC;

-- 14.6 A three-month moving average with a window frame
-- Expected: June 242,681,670 (rounded)
WITH m AS (
    SELECT month_end, SUM(current_balance) AS balance
    FROM dbo.loan_history WHERE status = 'Active'
    GROUP BY month_end
)
SELECT month_end, balance,
       AVG(balance) OVER (
           ORDER BY month_end
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS avg_3_months
FROM m;

-- 14.7 UPDATE ... FROM ... JOIN, inside a transaction that is rolled back
BEGIN TRANSACTION;
UPDATE t SET t.current_balance = s.current_balance
FROM dbo.loan_tape t
JOIN dbo.servicer_balances s ON s.loan_id = t.loan_id
WHERE t.loan_id IN ('ASH100500', 'ASH100501');
-- Expected: 157,900 and 79,890 (the servicer's balances)
SELECT loan_id, current_balance FROM dbo.loan_tape
WHERE loan_id IN ('ASH100500', 'ASH100501');
ROLLBACK;

-- 14.8 Delete duplicates with a CTE, on a staging table with no key
DROP TABLE IF EXISTS #staging;
SELECT loan_id, month_end, current_balance
INTO #staging
FROM dbo.loan_history
WHERE month_end = '2026-06-30';
-- load the same file twice by mistake
INSERT INTO #staging
SELECT loan_id, month_end, current_balance
FROM dbo.loan_history
WHERE month_end = '2026-06-30';
WITH d AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY loan_id, month_end
                                 ORDER BY current_balance DESC) AS rn
    FROM #staging
)
DELETE FROM d WHERE rn > 1;
-- Expected: 1,211 rows, 1,211 distinct loans
SELECT COUNT(*) AS rows_left, COUNT(DISTINCT loan_id) AS loans
FROM #staging;

-- 14.9 MERGE: update existing loans and insert new ones in one statement
DROP TABLE IF EXISTS #loans;
SELECT loan_id, current_balance
INTO #loans
FROM dbo.loan_tape
WHERE loan_id IN ('ASH100500', 'ASH100501');
MERGE #loans AS t
USING (SELECT loan_id, current_balance
       FROM dbo.servicer_balances
       WHERE loan_id IN ('ASH100500', 'ASH100501', 'ASH100888')) AS s
ON t.loan_id = s.loan_id
WHEN MATCHED THEN
    UPDATE SET t.current_balance = s.current_balance
WHEN NOT MATCHED BY TARGET THEN
    INSERT (loan_id, current_balance)
    VALUES (s.loan_id, s.current_balance);
-- Expected: ASH100500 157,900; ASH100501 79,890; ASH100888 73,590
SELECT loan_id, current_balance FROM #loans ORDER BY loan_id;

-- 14.10 TRY ... CATCH: roll back a load if any statement fails
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE dbo.loan_tape SET region = 'London'
    WHERE loan_id = 'ASH100096';
    -- a later statement fails (here, a division by zero)
    SELECT 1 / 0 AS will_fail;
    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    SELECT 'Rolled back: ' + ERROR_MESSAGE() AS result;
END CATCH;
SET XACT_ABORT OFF;
-- Expected: the region of ASH100096 is unchanged
SELECT loan_id, region FROM dbo.loan_tape WHERE loan_id = 'ASH100096';

-- 14.11 Dynamic SQL with a parameter, never by joining text
-- Expected: 1,211
EXEC sp_executesql
    N'SELECT COUNT(*) AS rows_in_june FROM dbo.loan_history WHERE month_end = @d',
    N'@d DATE',
    @d = '2026-06-30';

-- 15.1 A transaction: check, then roll back (or COMMIT when sure)
BEGIN TRANSACTION;
UPDATE dbo.loan_tape
SET region = 'London'
WHERE loan_id = 'ASH100096';
SELECT loan_id, region FROM dbo.loan_tape
WHERE loan_id = 'ASH100096';
ROLLBACK;
