-- 5.1 A CTE for the pool total, then each region's share
WITH pool AS (
    SELECT SUM(current_balance) AS total FROM loan_tape
)
SELECT t.region,
       SUM(t.current_balance)                         AS balance,
       ROUND(100.0 * SUM(t.current_balance) / p.total, 2) AS pct_of_pool
FROM loan_tape AS t
CROSS JOIN pool AS p
GROUP BY t.region, p.total
ORDER BY balance DESC;

-- 5.2 Two CTEs: reconcile totals between tape and servicer
WITH tape AS (
    SELECT COUNT(*) AS rows_, COUNT(DISTINCT loan_id) AS ids, SUM(current_balance) AS balance
    FROM loan_tape
),
servicer AS (
    SELECT COUNT(*) AS rows_, COUNT(DISTINCT loan_id) AS ids, SUM(current_balance) AS balance
    FROM servicer_balances
)
SELECT 'Tape' AS source, rows_, ids, balance FROM tape
UNION ALL
SELECT 'Servicer', rows_, ids, balance FROM servicer;

-- 5.3 CPR for each period, step by step
WITH smm AS (
    SELECT period, payment_date,
           prepayments / (opening_pool - scheduled_principal) AS smm
    FROM periods
)
SELECT period, payment_date,
       ROUND(100 * smm, 3)                    AS smm_pct,
       ROUND(100 * (1 - POWER(1 - smm, 12)), 1) AS cpr_pct
FROM smm;
