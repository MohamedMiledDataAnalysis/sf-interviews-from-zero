-- Structured Finance Interviews from Zero, Chapter 17 (SQL Server / T-SQL).
-- Run 00_setup.sql first. SQLite versions are in sqlite_version/.
USE ashcombe;
GO

-- 3.1 Indexed LTV stratification with CASE (bucket in a subquery, then GROUP BY)
SELECT ltv_bucket, COUNT(*) AS loans, SUM(current_balance) AS balance
FROM (
  SELECT current_balance,
       CASE
         WHEN indexed_ltv IS NULL THEN '9 Missing'
         WHEN indexed_ltv <= 0.50 THEN '1 50% or less'
         WHEN indexed_ltv <= 0.60 THEN '2 >50% to 60%'
         WHEN indexed_ltv <= 0.70 THEN '3 >60% to 70%'
         WHEN indexed_ltv <= 0.80 THEN '4 >70% to 80%'
         WHEN indexed_ltv <= 0.90 THEN '5 >80% to 90%'
         ELSE '6 Over 90%'
       END AS ltv_bucket
  FROM dbo.loan_tape
) AS b
GROUP BY ltv_bucket
ORDER BY ltv_bucket;

-- 3.2 Arrears stratification
SELECT arrears_bucket, COUNT(*) AS loans, SUM(current_balance) AS balance
FROM (
  SELECT current_balance,
       CASE
         WHEN arrears_months = 0 THEN '0 Up to date'
         WHEN arrears_months = 1 THEN '1 month'
         WHEN arrears_months = 2 THEN '2 months'
         ELSE '3+ months'
       END AS arrears_bucket
  FROM dbo.loan_tape
) AS b
GROUP BY arrears_bucket
ORDER BY arrears_bucket;

-- 3.3 Conditional sums in one row (a cross-tab)
SELECT rate_type,
       SUM(CASE WHEN repayment_type = 'Repayment'     THEN current_balance ELSE 0 END) AS repayment,
       SUM(CASE WHEN repayment_type = 'Interest-only' THEN current_balance ELSE 0 END) AS interest_only,
       SUM(CASE WHEN repayment_type = 'Part and part' THEN current_balance ELSE 0 END) AS part_and_part
FROM dbo.loan_tape
GROUP BY rate_type
ORDER BY rate_type;
