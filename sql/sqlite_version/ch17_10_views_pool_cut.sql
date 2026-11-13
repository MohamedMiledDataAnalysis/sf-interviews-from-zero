-- 10.1 A view: a saved query that behaves like a table
DROP VIEW IF EXISTS v_pool_summary;
CREATE VIEW v_pool_summary AS
SELECT COUNT(*) AS loans,
       SUM(current_balance) AS balance,
       SUM(interest_rate * current_balance) / SUM(current_balance) AS wa_rate,
       SUM(indexed_ltv * current_balance) / SUM(current_balance) AS wa_iltv
FROM loan_tape;

SELECT * FROM v_pool_summary;

-- 10.2 A pool cut: which loans meet the eligibility criteria for a new deal?
SELECT COUNT(*) AS eligible_loans, SUM(current_balance) AS eligible_balance
FROM loan_tape
WHERE arrears_months = 0
  AND possession_flag = 'N'
  AND seasoning_months >= 3
  AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
  AND occupancy = 'Owner-occupied';

-- 10.3 Why loans fail: one row per criterion
SELECT 'In arrears' AS reason, COUNT(*) AS loans FROM loan_tape WHERE arrears_months > 0
UNION ALL SELECT 'Indexed LTV over 90%', COUNT(*) FROM loan_tape WHERE indexed_ltv > 0.90
UNION ALL SELECT 'Balance over 750,000', COUNT(*) FROM loan_tape WHERE current_balance > 750000
UNION ALL SELECT 'Buy-to-let', COUNT(*) FROM loan_tape WHERE occupancy <> 'Owner-occupied'
UNION ALL SELECT 'In possession', COUNT(*) FROM loan_tape WHERE possession_flag <> 'N';

-- 10.4 A temporary table
DROP TABLE IF EXISTS temp.eligible;
CREATE TEMP TABLE eligible AS
SELECT loan_id, current_balance, region FROM loan_tape
WHERE arrears_months = 0 AND indexed_ltv <= 0.90 AND occupancy = 'Owner-occupied';
SELECT region, COUNT(*) AS loans, SUM(current_balance) AS balance FROM eligible GROUP BY region ORDER BY balance DESC;

-- 10.5 SQLite has no stored procedures; python/ch18_09_sql_and_logging.py is the Python equivalent
