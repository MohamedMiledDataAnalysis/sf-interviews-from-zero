-- 2.1 Pool summary
SELECT COUNT(*)                AS loans,
       SUM(current_balance)    AS pool_balance,
       AVG(current_balance)    AS average_balance,
       MAX(current_balance)    AS largest_loan,
       MIN(current_balance)    AS smallest_loan
FROM loan_tape;

-- 2.2 Weighted averages
SELECT ROUND(SUM(interest_rate * current_balance) / SUM(current_balance), 5) AS wa_rate,
       ROUND(SUM(original_ltv  * current_balance) / SUM(current_balance), 4) AS wa_oltv,
       ROUND(SUM(seasoning_months * current_balance) / SUM(current_balance), 1) AS wa_seasoning
FROM loan_tape;

-- 2.3 Balance by rate type
SELECT rate_type,
       COUNT(*)             AS loans,
       SUM(current_balance) AS balance
FROM loan_tape
GROUP BY rate_type
ORDER BY balance DESC;

-- 2.4 Regions with more than 100 loans (HAVING filters groups)
SELECT region, COUNT(*) AS loans
FROM loan_tape
GROUP BY region
HAVING COUNT(*) > 100
ORDER BY loans DESC;
