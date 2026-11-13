-- Structured Finance Interviews from Zero, Chapter 17 (SQLite).
-- The SQL practice set (answers 1 to 20) and the chapter's exercises
-- (corrections 1 to 9). Try each question yourself before you run the answer.
-- Build the database first: python sql/sqlite_version/build_db.py

-- Answer 1. How many loans are tracker loans? Expected: 203
SELECT COUNT(*) AS loans FROM loan_tape
WHERE rate_type = 'Tracker';

-- Answer 2. Total balance of interest-only loans? Expected: 53,039,031
SELECT SUM(current_balance) AS balance FROM loan_tape
WHERE repayment_type = 'Interest-only';

-- Answer 3. Simple average original LTV of buy-to-let loans? Expected: 0.6204
SELECT AVG(original_ltv) AS avg_original_ltv FROM loan_tape
WHERE occupancy = 'Buy-to-let';

-- Answer 4. Largest loan in Scotland? Expected: ASH100594, 542,210
SELECT loan_id, current_balance
FROM loan_tape
WHERE region = 'Scotland'
ORDER BY current_balance DESC
LIMIT 1;

-- Answer 5. How many loans have a 420-month term? Expected: 171
SELECT COUNT(*) AS loans FROM loan_tape
WHERE original_term_months = 420;

-- Answer 6. Balance-weighted indexed LTV of loans in arrears? Expected: 0.6155
SELECT SUM(indexed_ltv * current_balance)
       / SUM(current_balance) AS wa_indexed_ltv
FROM loan_tape
WHERE arrears_months >= 1;

-- Answer 7. How many loans were originated in 2025? Expected: 221
SELECT COUNT(*) AS loans FROM loan_tape
WHERE origination_date >= '2025-01-01'
  AND origination_date < '2026-01-01';

-- Answer 8. Loans and balance by original term
-- Expected: 240: 102 loans; 300: 493; 360: 434; 420: 171
SELECT original_term_months, COUNT(*) AS loans,
       SUM(current_balance) AS balance
FROM loan_tape
GROUP BY original_term_months
ORDER BY original_term_months;

-- Answer 9. Region spellings with an average balance above 205,000
-- Expected (SQLite keeps every spelling apart): Greater London, london,
-- West Midlands, Yorkshire and the Humber, South East, London
SELECT region, AVG(current_balance) AS avg_balance
FROM loan_tape
GROUP BY region
HAVING AVG(current_balance) > 205000
ORDER BY AVG(current_balance) DESC;

-- Answer 10. Percentage of the pool in fixed-rate loans? Expected: 70.68
SELECT 100.0 * SUM(CASE WHEN rate_type = 'Fixed'
                        THEN current_balance ELSE 0 END)
       / SUM(current_balance) AS pct_fixed
FROM loan_tape;

-- Answer 11. Total amount overdue? Expected: 252,649.48
SELECT SUM(arrears_balance) AS arrears_balance FROM loan_tape;

-- Answer 12. Loans in possession and their balance? Expected: 5, 973,577
SELECT COUNT(*) AS loans, SUM(current_balance) AS balance
FROM loan_tape
WHERE possession_flag = 'Y';

-- Answer 13. Loans with a borrower income above 150,000? Expected: 34
SELECT COUNT(*) AS loans FROM loan_tape
WHERE borrower_income > 150000;

-- Answer 14. The second-largest loan? Expected: ASH100772, 758,161
SELECT loan_id, current_balance
FROM (SELECT loan_id, current_balance,
        DENSE_RANK() OVER (ORDER BY current_balance DESC) AS r
      FROM loan_tape) AS x
WHERE r = 2;

-- Answer 15. Loans redeemed in full each month
-- Expected: Feb 11, Mar 12, Apr 13, May 10, Jun 11
SELECT month_end, COUNT(*) AS redeemed
FROM loan_history
WHERE status = 'Redeemed'
GROUP BY month_end
ORDER BY month_end;

-- Answer 16. Loans in the pool in June, up to date every month? Expected: 984
SELECT COUNT(*) AS loans
FROM (SELECT loan_id
      FROM loan_history
      GROUP BY loan_id
      HAVING MAX(arrears_months) = 0
         AND SUM(CASE WHEN month_end = '2026-06-30'
                       AND status = 'Active'
                      THEN 1 ELSE 0 END) = 1) AS x;

-- Answer 17. Highest arrears reached by the loans now 3+ months behind
-- Expected: ASH100543, ASH100600, ASH100726, ASH100922 (8); ASH100236 (7)
SELECT h.loan_id, MAX(h.arrears_months) AS max_arrears
FROM loan_history h
JOIN loan_tape t ON t.loan_id = h.loan_id
WHERE t.arrears_months >= 3
GROUP BY h.loan_id
ORDER BY 2 DESC, 1
LIMIT 5;

-- Answer 18. Share of the pool in the ten largest loans? Expected: 2.67
SELECT 100.0 * SUM(current_balance)
       / (SELECT SUM(current_balance) FROM loan_tape) AS pct_top_10
FROM (SELECT current_balance
      FROM loan_tape
      ORDER BY current_balance DESC
      LIMIT 10) AS x;

-- Answer 19. Interest-only loans maturing before 2045
-- Expected: 50 loans, 11,753,499
SELECT COUNT(*) AS loans, SUM(current_balance) AS balance
FROM loan_tape
WHERE repayment_type = 'Interest-only'
  AND maturity_date < '2045-01-01';

-- Answer 20. Simple average seasoning by rate type
-- Expected: Fixed 50.1, SVR 49.0, Tracker 50.8 months
SELECT rate_type, AVG(1.0 * seasoning_months) AS avg_seasoning
FROM loan_tape
GROUP BY rate_type
ORDER BY rate_type;

-- Correction 1. Loans and balance by occupancy
-- Expected: Buy-to-let 216 loans, 46,245,021
SELECT occupancy, COUNT(*) AS loans, SUM(current_balance) AS balance
FROM loan_tape
GROUP BY occupancy;

-- Correction 2. Loans with an original LTV above 90%, largest first
SELECT loan_id, original_ltv, current_balance
FROM loan_tape
WHERE original_ltv > 0.90
ORDER BY current_balance DESC;

-- Correction 3. Balance-size strat (Chapter 16, exercise 2)
-- Expected: the buckets add up to 1,200 loans and 240,000,000
SELECT size_bucket, COUNT(*) AS loans, SUM(current_balance) AS balance
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

-- Correction 4. Balance-weighted average interest rate by rate type
-- (the Fixed figure includes the 53.7% error)
SELECT rate_type,
       SUM(interest_rate * current_balance) / SUM(current_balance) AS wa_rate
FROM loan_tape
GROUP BY rate_type;

-- Correction 5. The three largest loans in each region
SELECT region, loan_id, current_balance, rn
FROM (
    SELECT region, loan_id, current_balance,
           ROW_NUMBER() OVER (PARTITION BY region
                              ORDER BY current_balance DESC) AS rn
    FROM loan_tape
) AS x
WHERE rn <= 3
ORDER BY region, rn;

-- Correction 6. Loans whose arrears differ between tape and servicer
-- Expected: no rows
SELECT t.loan_id, t.arrears_months, s.arrears_months AS servicer_arrears
FROM loan_tape t
JOIN servicer_balances s ON s.loan_id = t.loan_id
WHERE t.arrears_months <> s.arrears_months;

-- Correction 7. SELECT region, SUM(current_balance) FROM loan_tape
-- fails in SQL Server (Msg 8120); SQLite accepts it and shows one arbitrary
-- region next to the grand total, which is worse. The fix:
SELECT region, SUM(current_balance) AS balance
FROM loan_tape
GROUP BY region;

-- Correction 8. Up to date in April, 2+ months behind in June? Expected: 12
SELECT COUNT(*) AS loans
FROM loan_history a
JOIN loan_history j
  ON j.loan_id = a.loan_id
 AND j.month_end = '2026-06-30'
 AND j.status = 'Active'
WHERE a.month_end = '2026-04-30'
  AND a.arrears_months = 0
  AND j.arrears_months >= 2;

-- Correction 9. The pool cut with buy-to-let allowed up to 75% indexed LTV
-- Expected: 1,082 loans, 215,298,938
SELECT COUNT(*) AS eligible_loans, SUM(current_balance) AS eligible_balance
FROM loan_tape
WHERE arrears_months = 0
  AND possession_flag = 'N'
  AND seasoning_months >= 3
  AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
  AND (occupancy = 'Owner-occupied' OR indexed_ltv <= 0.75);
