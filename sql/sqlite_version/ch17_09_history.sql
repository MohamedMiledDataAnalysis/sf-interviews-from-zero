-- 9.1 Pool balance and loan count by month (active loans only)
SELECT month_end,
       COUNT(*)             AS loans,
       SUM(current_balance) AS balance
FROM loan_history
WHERE status = 'Active'
GROUP BY month_end
ORDER BY month_end;

-- 9.2 Each active loan's balance change from the previous month (LAG within each loan)
SELECT loan_id, month_end, current_balance, previous_balance,
       previous_balance - current_balance AS principal_repaid
FROM (
    SELECT loan_id, month_end, current_balance,
           LAG(current_balance) OVER (PARTITION BY loan_id ORDER BY month_end) AS previous_balance
    FROM loan_history
    WHERE status = 'Active'
) AS h
WHERE month_end = '2026-06-30'
ORDER BY principal_repaid DESC, loan_id
LIMIT 10;

-- 9.3 Monthly pool movements: redemptions in full and other principal
WITH h AS (
    SELECT loan_id, month_end, status, current_balance,
           LAG(current_balance) OVER (PARTITION BY loan_id ORDER BY month_end) AS prev_balance
    FROM loan_history
)
SELECT month_end,
       SUM(prev_balance)                                                      AS opening,
       SUM(CASE WHEN status = 'Redeemed' THEN prev_balance ELSE 0 END)        AS redemptions,
       SUM(CASE WHEN status = 'Active' THEN prev_balance - current_balance ELSE 0 END) AS other_principal,
       SUM(current_balance)                                                   AS closing
FROM h
WHERE prev_balance IS NOT NULL
GROUP BY month_end
ORDER BY month_end;

-- 9.4 Roll-rate matrix, May to June (counts of loans)
WITH pairs AS (
    SELECT m.loan_id,
           CASE WHEN m.arrears_months >= 3 THEN '3+' ELSE CAST(m.arrears_months AS TEXT) END AS may_bucket,
           CASE WHEN j.arrears_months >= 3 THEN '3+' ELSE CAST(j.arrears_months AS TEXT) END AS jun_bucket
    FROM loan_history AS m
    JOIN loan_history AS j
      ON j.loan_id = m.loan_id AND j.month_end = '2026-06-30' AND j.status = 'Active'
    WHERE m.month_end = '2026-05-31'
)
SELECT may_bucket,
       SUM(CASE WHEN jun_bucket = '0'  THEN 1 ELSE 0 END) AS to_0,
       SUM(CASE WHEN jun_bucket = '1'  THEN 1 ELSE 0 END) AS to_1,
       SUM(CASE WHEN jun_bucket = '2'  THEN 1 ELSE 0 END) AS to_2,
       SUM(CASE WHEN jun_bucket = '3+' THEN 1 ELSE 0 END) AS to_3plus,
       COUNT(*) AS total
FROM pairs
GROUP BY may_bucket
ORDER BY may_bucket;

-- 9.5 Loans that reached 3+ months in arrears for the first time in June
SELECT j.loan_id, j.current_balance, m.arrears_months AS may_arrears, j.arrears_months AS jun_arrears
FROM loan_history AS j
JOIN loan_history AS m ON m.loan_id = j.loan_id AND m.month_end = '2026-05-31'
WHERE j.month_end = '2026-06-30' AND j.arrears_months >= 3 AND m.arrears_months < 3;
