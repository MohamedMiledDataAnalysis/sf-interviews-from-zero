-- Structured Finance Interviews from Zero, Chapter 17 (SQL Server / T-SQL).
-- Run 00_setup.sql first. SQLite versions are in sqlite_version/.
USE ashcombe;
GO

-- 6.1 ROW_NUMBER: find repeated loan IDs and number each copy
SELECT loan_id, origination_date, current_balance, copy_no
FROM (
    SELECT loan_id, origination_date, current_balance,
           ROW_NUMBER() OVER (PARTITION BY loan_id ORDER BY origination_date) AS copy_no,
           COUNT(*)     OVER (PARTITION BY loan_id)                           AS copies
    FROM dbo.loan_tape
) AS x
WHERE copies > 1;

-- 6.2 Share of pool on every row, without GROUP BY
SELECT TOP 5 loan_id, current_balance,
       ROUND(100.0 * current_balance / SUM(current_balance) OVER (), 3) AS pct_of_pool
FROM dbo.loan_tape
ORDER BY current_balance DESC;

-- 6.3 The ten largest loans and their cumulative share (concentration)
SELECT TOP 10 loan_id, current_balance,
       RANK() OVER (ORDER BY current_balance DESC) AS size_rank,
       ROUND(100.0 * SUM(current_balance) OVER (ORDER BY current_balance DESC
                                               ROWS UNBOUNDED PRECEDING)
             / SUM(current_balance) OVER (), 2) AS cumulative_pct
FROM dbo.loan_tape
ORDER BY current_balance DESC;

-- 6.4 The largest loan in each region
SELECT region, loan_id, current_balance
FROM (
    SELECT region, loan_id, current_balance,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY current_balance DESC) AS rn
    FROM dbo.loan_tape
) AS x
WHERE rn = 1
ORDER BY current_balance DESC;

-- 6.5 LAG: compare each period with the one before
SELECT period, payment_date, prepayments,
       LAG(prepayments) OVER (ORDER BY period)               AS previous_prepayments,
       prepayments - LAG(prepayments) OVER (ORDER BY period) AS change
FROM dbo.periods;
