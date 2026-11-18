-- Structured Finance Interviews from Zero: every SQL query printed in the solutions
-- (SQL Server / T-SQL), in the book's order. Generated from the book: do not edit.
-- Run 00_setup.sql first. The SQLite version is sqlite_version/ch17_13_solutions.sql.
USE ashcombe;
GO


-- ===== Chapter 13, Exercise 1: STS criteria a loan tape can test

SELECT COUNT(*) AS loans,
       MIN(seasoning_months) AS min_seasoning,
       SUM(CASE WHEN seasoning_months < 1
                THEN 1 ELSE 0 END) AS failing
FROM loan_tape;

SELECT COUNT(*) AS loans, SUM(current_balance) AS balance,
       SUM(CASE WHEN possession_flag = 'Y'
                THEN 1 ELSE 0 END) AS in_possession
FROM loan_tape
WHERE arrears_months >= 3 OR possession_flag = 'Y';

SELECT income_verified, COUNT(*) AS loans
FROM loan_tape
GROUP BY income_verified;

SELECT COUNT(*) AS loans FROM loan_tape
WHERE arrears_months IS NULL OR possession_flag IS NULL;


-- ===== Chapter 17, Exercise 1: loans and balance by occupancy

SELECT occupancy,
       COUNT(*) AS loans,
       SUM(current_balance) AS balance
FROM dbo.loan_tape
GROUP BY occupancy
ORDER BY occupancy;


-- ===== Chapter 17, Exercise 2: original LTV above 90%, largest first

SELECT loan_id, original_ltv, current_balance
FROM dbo.loan_tape
WHERE original_ltv > 0.90
ORDER BY current_balance DESC;

SELECT COUNT(*) AS loans,
       SUM(current_balance) AS balance,
       MAX(original_ltv) AS highest_ltv
FROM dbo.loan_tape
WHERE original_ltv > 0.90;


-- ===== Chapter 17, Exercise 3: a balance-size strat with CASE

SELECT loan_id, current_balance,
       CASE
         WHEN current_balance <= 100000 THEN '1 £100k or less'
         WHEN current_balance <= 200000 THEN '2 >£100k to £200k'
         WHEN current_balance <= 300000 THEN '3 >£200k to £300k'
         WHEN current_balance <= 500000 THEN '4 >£300k to £500k'
         ELSE '5 Over £500k'
       END AS size_bucket
FROM dbo.loan_tape
WHERE loan_id IN ('ASH100001', 'ASH100002', 'ASH100003');

SELECT size_bucket,
       COUNT(*) AS loans,
       SUM(current_balance) AS balance
FROM (
  SELECT current_balance,
         CASE
           WHEN current_balance <= 100000 THEN '1 £100k or less'
           WHEN current_balance <= 200000 THEN '2 >£100k to £200k'
           WHEN current_balance <= 300000 THEN '3 >£200k to £300k'
           WHEN current_balance <= 500000 THEN '4 >£300k to £500k'
           ELSE '5 Over £500k'
         END AS size_bucket
  FROM dbo.loan_tape
) AS b
GROUP BY size_bucket
ORDER BY size_bucket;

SELECT COUNT(*) AS loans, SUM(current_balance) AS balance
FROM dbo.loan_tape;

SELECT COUNT(*) FROM dbo.loan_tape
WHERE current_balance IN (100000, 200000, 300000, 500000);


-- ===== Chapter 17, Exercise 4: WA interest rate by rate type

SELECT rate_type,
       COUNT(*) AS loans,
       SUM(interest_rate * current_balance)
         / SUM(current_balance) AS wa_rate
FROM dbo.loan_tape
GROUP BY rate_type
ORDER BY rate_type;

SELECT SUM(CASE WHEN loan_id = 'ASH100602' THEN 0.0537
                ELSE interest_rate END * current_balance)
       / SUM(current_balance) AS wa_rate_fixed_corrected
FROM dbo.loan_tape
WHERE rate_type = 'Fixed';


-- ===== Chapter 17, Exercise 5: the three largest loans in each region

SELECT region, loan_id, current_balance, rn
FROM (
    SELECT region, loan_id, current_balance,
           ROW_NUMBER() OVER (PARTITION BY region
                              ORDER BY current_balance DESC) AS rn
    FROM dbo.loan_tape
) AS x
WHERE rn <= 3
ORDER BY region, rn;


-- ===== Chapter 17, Exercise 6: arrears differences between tape and servicer

SELECT t.loan_id,
       t.arrears_months AS tape_arrears,
       s.arrears_months AS servicer_arrears
FROM dbo.loan_tape AS t
JOIN dbo.servicer_balances AS s
  ON s.loan_id = t.loan_id
WHERE t.arrears_months <> s.arrears_months;

SELECT COUNT(*) AS rows_compared
FROM dbo.loan_tape AS t
JOIN dbo.servicer_balances AS s
  ON s.loan_id = t.loan_id;


-- ===== Chapter 17, Exercise 7: why the query fails

SELECT region, SUM(current_balance) AS balance
FROM dbo.loan_tape
GROUP BY region
ORDER BY balance DESC;


-- ===== Chapter 17, Exercise 8: up to date in April, 2+ behind in June

SELECT COUNT(*) FROM dbo.loan_history
WHERE month_end = '2026-04-30' AND arrears_months = 0
  AND month_end = '2026-06-30' AND arrears_months >= 2;

SELECT a.loan_id, a.arrears_months AS apr_arrears,
       j.arrears_months AS jun_arrears, j.current_balance
FROM dbo.loan_history a
JOIN dbo.loan_history j
  ON j.loan_id = a.loan_id
 AND j.month_end = '2026-06-30'
 AND j.status = 'Active'
WHERE a.month_end = '2026-04-30'
  AND a.arrears_months = 0
  AND j.arrears_months >= 2
ORDER BY a.loan_id;


-- ===== Chapter 17, Exercise 9: buy-to-let up to 75% indexed LTV in the pool cut

SELECT COUNT(*) AS eligible_loans,
       SUM(current_balance) AS eligible_balance
FROM dbo.loan_tape
WHERE arrears_months = 0
  AND possession_flag = 'N'
  AND seasoning_months >= 3
  AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
  AND occupancy = 'Owner-occupied';

SELECT COUNT(*) AS loans, SUM(current_balance) AS balance
FROM dbo.loan_tape
WHERE arrears_months = 0
  AND possession_flag = 'N'
  AND seasoning_months >= 3
  AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
  AND occupancy = 'Buy-to-let'
  AND indexed_ltv <= 0.75;

SELECT occupancy, COUNT(*) AS loans,
       SUM(current_balance) AS balance
FROM dbo.loan_tape
WHERE arrears_months = 0 AND possession_flag = 'N'
  AND seasoning_months >= 3 AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
GROUP BY occupancy;


-- ===== Chapter 20, Question 7: code

SELECT s.loan_id, s.current_balance
FROM dbo.servicer_balances AS s
LEFT JOIN dbo.loan_tape AS t ON t.loan_id = s.loan_id
WHERE t.loan_id IS NULL;
