-- Structured Finance Interviews from Zero: every SQL query printed in the solutions
-- (SQLite), in the book's order. Generated from the book: do not edit.
-- Build the database first: python sql/sqlite_version/build_db.py


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


-- ===== Chapter 17, Exercise 1: a balance-size strat with CASE

SELECT loan_id, current_balance,
       CASE
         WHEN current_balance <= 100000 THEN '1 £100k or less'
         WHEN current_balance <= 200000 THEN '2 >£100k to £200k'
         WHEN current_balance <= 300000 THEN '3 >£200k to £300k'
         WHEN current_balance <= 500000 THEN '4 >£300k to £500k'
         ELSE '5 Over £500k'
       END AS size_bucket
FROM loan_tape
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
  FROM loan_tape
) AS b
GROUP BY size_bucket
ORDER BY size_bucket;

SELECT COUNT(*) AS loans, SUM(current_balance) AS balance
FROM loan_tape;

SELECT COUNT(*) FROM loan_tape
WHERE current_balance IN (100000, 200000, 300000, 500000);


-- ===== Chapter 17, Exercise 2: up to date in April, 2+ behind in June

SELECT COUNT(*) FROM loan_history
WHERE month_end = '2026-04-30' AND arrears_months = 0
  AND month_end = '2026-06-30' AND arrears_months >= 2;

SELECT a.loan_id, a.arrears_months AS apr_arrears,
       j.arrears_months AS jun_arrears, j.current_balance
FROM loan_history a
JOIN loan_history j
  ON j.loan_id = a.loan_id
 AND j.month_end = '2026-06-30'
 AND j.status = 'Active'
WHERE a.month_end = '2026-04-30'
  AND a.arrears_months = 0
  AND j.arrears_months >= 2
ORDER BY a.loan_id;


-- ===== Chapter 17, Exercise 3: buy-to-let up to 75% indexed LTV in the pool cut

SELECT COUNT(*) AS eligible_loans,
       SUM(current_balance) AS eligible_balance
FROM loan_tape
WHERE arrears_months = 0
  AND possession_flag = 'N'
  AND seasoning_months >= 3
  AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
  AND occupancy = 'Owner-occupied';

SELECT COUNT(*) AS loans, SUM(current_balance) AS balance
FROM loan_tape
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
FROM loan_tape
WHERE arrears_months = 0 AND possession_flag = 'N'
  AND seasoning_months >= 3 AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
GROUP BY occupancy;


-- ===== Chapter 20, Question 7: code

SELECT s.loan_id, s.current_balance
FROM servicer_balances AS s
LEFT JOIN loan_tape AS t ON t.loan_id = s.loan_id
WHERE t.loan_id IS NULL;
