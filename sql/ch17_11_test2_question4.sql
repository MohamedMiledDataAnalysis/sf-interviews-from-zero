-- Practice test 2, question 4: the pool figures before and after the corrections
-- (Chapter 20). Run 00_setup.sql first. SQL Server / T-SQL.
USE ashcombe;
GO

-- 4a. Weighted average interest rate, with ASH100602 corrected to 5.37%
-- Expected: 5.444 and 5.400
SELECT ROUND(100 * SUM(interest_rate * current_balance)
             / SUM(current_balance), 3) AS wa_rate_before,
       ROUND(100 * SUM(CASE WHEN loan_id = 'ASH100602'
                            THEN 0.0537 ELSE interest_rate END
                       * current_balance)
             / SUM(current_balance), 3) AS wa_rate_after
FROM dbo.loan_tape;

-- 4b. Weighted average indexed LTV, with ASH100357 corrected to 46.38%
-- Expected: 60.333 and 60.317
SELECT ROUND(100 * SUM(indexed_ltv * current_balance)
             / SUM(current_balance), 3) AS wa_ltv_before,
       ROUND(100 * SUM(CASE WHEN loan_id = 'ASH100357'
                            THEN 0.4638 ELSE indexed_ltv END
                       * current_balance)
             / SUM(current_balance), 3) AS wa_ltv_after
FROM dbo.loan_tape;

-- 4c. London's share of the pool once every spelling is mapped
-- Expected: 16.42
SELECT ROUND(100.0 * SUM(current_balance) / 240000000, 2)
         AS london_pct
FROM dbo.loan_tape
WHERE LOWER(TRIM(region)) IN ('london', 'greater london');
