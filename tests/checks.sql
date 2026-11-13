-- Checks that the numbers quoted in the book come out of SQL Server.
-- Each failed check raises an error (Msg 50000) naming the check.
USE ashcombe;
SET NOCOUNT ON;
DECLARE @n INT, @d DECIMAL(38,6), @s VARCHAR(200);

SELECT @n = COUNT(*), @d = SUM(current_balance) FROM dbo.loan_tape;
IF @n <> 1200 OR @d <> 240000000 THROW 50000, 'Ch0: tape count/balance', 1;

SELECT @n = COUNT(DISTINCT loan_id) FROM dbo.loan_tape;
IF @n <> 1199 THROW 50000, 'Ch17 5.2: distinct IDs', 1;

SELECT @d = ROUND(SUM(interest_rate * current_balance) / SUM(current_balance), 5) FROM dbo.loan_tape;
IF @d <> 0.05444 THROW 50000, 'Ch17 2.2: WA rate', 1;

SELECT @n = COUNT(*), @d = SUM(current_balance) FROM dbo.loan_tape WHERE arrears_months >= 3;
IF @n <> 24 OR @d <> 4648983 THROW 50000, 'Ch17 1.2: 3+ arrears', 1;

SELECT @n = COUNT(*) FROM dbo.loan_tape WHERE indexed_ltv <= 0.50;
IF @n <> 325 THROW 50000, 'Ch17 3.1: first LTV bucket', 1;

-- SQL Server's default collation merges the London spellings (Ch17 section 2)
SELECT @n = COUNT(*) FROM dbo.loan_tape WHERE region = 'London';
IF @n <> 190 THROW 50000, 'Ch17: London 190 loans under the default collation', 1;
SELECT @n = COUNT(*) FROM (SELECT region FROM dbo.loan_tape GROUP BY region) AS g;
IF @n <> 12 THROW 50000, 'Ch17: 12 region groups in SQL Server', 1;

-- Practice set answer 9 (SQL Server)
SELECT @n = COUNT(*) FROM (SELECT region FROM dbo.loan_tape GROUP BY region HAVING AVG(current_balance) > 205000) AS g;
IF @n <> 5 THROW 50000, 'Ch17 practice 9: five regions in SQL Server', 1;

-- Joins and reconciliation
SELECT @n = COUNT(*) FROM dbo.servicer_balances AS s LEFT JOIN dbo.loan_tape AS t ON t.loan_id = s.loan_id WHERE t.loan_id IS NULL;
IF @n <> 1 THROW 50000, 'Ch17 4.2: one servicer loan missing', 1;
SELECT @n = COUNT(*) FROM (SELECT loan_id, current_balance FROM dbo.servicer_balances EXCEPT SELECT loan_id, current_balance FROM dbo.loan_tape) AS e;
IF @n <> 3 THROW 50000, 'Ch17 13: EXCEPT returns three rows', 1;

-- Data-quality query 7.1 must list nine exceptions (with the case-sensitive region rule)
SELECT @n = COUNT(*) FROM (
  SELECT loan_id FROM dbo.loan_tape GROUP BY loan_id HAVING COUNT(*) > 1
  UNION ALL SELECT loan_id FROM dbo.loan_tape WHERE indexed_valuation IS NULL
  UNION ALL SELECT loan_id FROM dbo.loan_tape WHERE indexed_valuation IS NOT NULL AND ABS(current_balance / indexed_valuation - indexed_ltv) > 0.005
  UNION ALL SELECT loan_id FROM dbo.loan_tape WHERE interest_rate < 0.005 OR interest_rate > 0.15
  UNION ALL SELECT loan_id FROM dbo.loan_tape WHERE DATEDIFF(month, origination_date, maturity_date) <> original_term_months
  UNION ALL SELECT loan_id FROM dbo.loan_tape WHERE DATALENGTH(region) <> DATALENGTH(TRIM(region))
       OR region COLLATE Latin1_General_CS_AS NOT IN ('East Midlands','East of England','London','North East','North West','Scotland','South East','South West','Wales','West Midlands','Yorkshire and the Humber')
  UNION ALL SELECT loan_id FROM dbo.loan_tape WHERE repayment_type = 'Repayment' AND current_balance > original_balance
  UNION ALL SELECT loan_id FROM dbo.loan_tape WHERE original_term_months <> seasoning_months + remaining_term_months) AS x;
IF @n <> 9 THROW 50000, 'Ch17 7.1: nine exceptions', 1;

-- History and pool cut
SELECT @d = SUM(current_balance) FROM dbo.loan_history WHERE month_end = '2026-06-30' AND status = 'Active';
IF @d <> 240000000 THROW 50000, 'Ch17 9.1: June history balance', 1;
SELECT @n = COUNT(*), @d = SUM(current_balance) FROM dbo.loan_tape
WHERE arrears_months = 0 AND possession_flag = 'N' AND seasoning_months >= 3 AND indexed_ltv <= 0.90
  AND current_balance <= 750000 AND remaining_term_months <= 420 AND occupancy = 'Owner-occupied';
IF @n <> 892 OR @d <> 175064566 THROW 50000, 'Ch17 10.2: pool cut', 1;

-- Roll rates May to June (query 9.4): 18 loans from 1 to 2 months
SELECT @n = COUNT(*) FROM dbo.loan_history AS m
JOIN dbo.loan_history AS j ON j.loan_id = m.loan_id AND j.month_end = '2026-06-30' AND j.status = 'Active'
WHERE m.month_end = '2026-05-31' AND m.arrears_months = 1 AND j.arrears_months = 2;
IF @n <> 18 THROW 50000, 'Ch17 9.4: roll 1 to 2', 1;

-- CPR in query 5.3
SELECT @d = ROUND(100 * (1 - POWER(1 - CAST(prepayments AS FLOAT) / (opening_pool - scheduled_principal), 12)), 1) FROM dbo.periods WHERE period = 2;
IF @d <> 11.9 THROW 50000, 'Ch17 5.3: CPR period 2', 1;

-- Second audit: statements and numbers added to Chapter 17
SELECT @n = COUNT(*) FROM (SELECT region COLLATE Latin1_General_CS_AS AS r, DATALENGTH(region) AS b FROM dbo.loan_tape GROUP BY region COLLATE Latin1_General_CS_AS, DATALENGTH(region)) AS g;
IF @n <> 14 THROW 50000, 'Ch15: GROUP BY with CS_AS and DATALENGTH lists 14 spellings', 1;
SELECT @n = COUNT(*) FROM (SELECT DISTINCT region FROM dbo.loan_tape) AS g;
IF @n <> 12 THROW 50000, 'Ch17: SELECT DISTINCT region gives 12', 1;
SELECT @n = COUNT(*), @d = SUM(CASE WHEN j.current_balance IS NULL THEN 1 ELSE 0 END) FROM dbo.loan_history AS a
LEFT JOIN dbo.loan_history AS j ON j.loan_id = a.loan_id AND j.month_end = '2026-06-30' WHERE a.month_end = '2026-01-31';
IF @n <> 1257 OR @d <> 46 THROW 50000, 'Ch17: ON version 1,257 rows, 46 NULL', 1;
SELECT @n = COUNT(*) FROM dbo.loan_history AS a LEFT JOIN dbo.loan_history AS j ON j.loan_id = a.loan_id
WHERE a.month_end = '2026-01-31' AND j.month_end = '2026-06-30';
IF @n <> 1211 THROW 50000, 'Ch17: WHERE version 1,211 rows', 1;
IF DATEADD(month, 3, CAST('2026-04-30' AS DATE)) <> '2026-07-30' THROW 50000, 'Ch17: DATEADD keeps the day', 1;
IF EOMONTH(CAST('2026-04-30' AS DATE), 3) <> '2026-07-31' THROW 50000, 'Ch17: EOMONTH(d, 3)', 1;
IF DATEDIFF(month, '2026-01-31', '2026-02-28') <> 1 THROW 50000, 'Ch17: DATEDIFF month-ends', 1;
WITH a AS (
    SELECT loan_id, month_end, arrears_months,
           ROW_NUMBER() OVER (PARTITION BY loan_id ORDER BY month_end)
         - ROW_NUMBER() OVER (PARTITION BY loan_id, CASE WHEN arrears_months > 0 THEN 1 ELSE 0 END ORDER BY month_end) AS grp
    FROM dbo.loan_history WHERE status = 'Active')
SELECT @n = COUNT(*) FROM (SELECT loan_id FROM a WHERE arrears_months > 0 GROUP BY loan_id, grp HAVING COUNT(*) >= 3) AS r;
IF @n <> 59 THROW 50000, 'Ch17 9.6: 59 runs', 1;
SELECT @d = ROUND(100.0 * SUM(CASE WHEN arrears_months >= 3 THEN current_balance ELSE 0 END) / SUM(current_balance), 2) FROM dbo.loan_tape WHERE YEAR(origination_date) = 2016;
IF @d <> 6.80 THROW 50000, 'Ch17 9.7: 2016 vintage 6.80%', 1;
SELECT @d = ROUND(100.0 * SUM(current_balance) / 240000000, 2) FROM dbo.loan_tape WHERE region = 'London';
IF @d <> 16.30 THROW 50000, 'Ch17/Ch20: London 16.30% in SQL Server', 1;
SELECT DISTINCT @d = PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY current_balance) OVER () FROM dbo.loan_tape;
SELECT @s = rate_type FROM (SELECT TOP 1 CASE WHEN GROUPING(rate_type) = 1 THEN 'Total' ELSE rate_type END AS rate_type, GROUPING(rate_type) AS g, SUM(current_balance) AS balance
  FROM dbo.loan_tape GROUP BY ROLLUP(rate_type) ORDER BY GROUPING(rate_type) DESC) AS x;
IF @s <> 'Total' THROW 50000, 'Ch17: ROLLUP with GROUPING', 1;
SELECT * INTO #staging FROM dbo.loan_history WHERE month_end = '2026-06-30';
INSERT INTO #staging SELECT TOP 5 * FROM dbo.loan_history WHERE month_end = '2026-06-30' ORDER BY loan_id;
WITH d AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY loan_id, month_end ORDER BY current_balance DESC) AS rn FROM #staging) DELETE FROM d WHERE rn > 1;
IF @@ROWCOUNT <> 5 THROW 50000, 'Ch17: delete duplicates on staging', 1;
EXEC sp_executesql N'SELECT @c = COUNT(*) FROM dbo.loan_history WHERE month_end = @d', N'@d DATE, @c INT OUTPUT', @d = '2026-06-30', @c = @n OUTPUT;
IF @n <> 1211 THROW 50000, 'Ch17: sp_executesql', 1;
SET XACT_ABORT ON;
BEGIN TRY BEGIN TRANSACTION; UPDATE dbo.periods SET losses = losses WHERE period = 1; COMMIT; END TRY
BEGIN CATCH IF @@TRANCOUNT > 0 ROLLBACK; THROW; END CATCH;
SET XACT_ABORT OFF;

-- Third audit: numbers printed in Chapter 17 that checks.sql did not yet verify.
-- Insert before PRINT 'ALL CHECKS PASSED' (same batch: no GO).
-- One-way EXCEPT checks are exact here: either the expected rows partition a total already pinned
-- (1,200 loans), or a separate row count is checked.
DECLARE @d2 DECIMAL(38,6), @d3 DECIMAL(38,6), @n2 INT;

-- 1.1, 1.2, 1.3, 1.4, 1.5
SELECT TOP 1 @s = loan_id, @d = current_balance FROM dbo.loan_tape ORDER BY loan_id;
IF @s <> 'ASH100001' OR @d <> 152661 THROW 50000, 'Ch17 1.1: first loan', 1;
SELECT TOP 1 @s = loan_id, @d = current_balance FROM dbo.loan_tape WHERE arrears_months >= 3 ORDER BY current_balance DESC;
IF @s <> 'ASH100019' OR @d <> 367870 THROW 50000, 'Ch17 1.2: largest 3+ loan', 1;
SELECT @n = COUNT(*), @d = MAX(current_balance) FROM dbo.loan_tape
WHERE occupancy = 'Buy-to-let' AND repayment_type = 'Interest-only' AND region = 'London' AND current_balance > 300000;
IF @n <> 5 OR @d <> 840940 THROW 50000, 'Ch17 1.3: five loans, largest 840,940', 1;
SELECT @n = COUNT(*) FROM dbo.loan_tape WHERE region IN ('Scotland', 'Wales');
IF @n <> 125 THROW 50000, 'Ch17 1.4: 125 loans', 1;
SELECT @n = COUNT(*), @s = MAX(loan_id) FROM dbo.loan_tape WHERE indexed_valuation IS NULL;
IF @n <> 1 OR @s <> 'ASH101045' THROW 50000, 'Ch17 1.5: ASH101045', 1;

-- 2.1, 2.3, 2.4
SELECT @d = AVG(current_balance), @d2 = MAX(current_balance), @d3 = MIN(current_balance) FROM dbo.loan_tape;
IF @d <> 200000 OR @d2 <> 840940 OR @d3 <> 43126 THROW 50000, 'Ch17 2.1: average, largest, smallest', 1;
IF EXISTS (SELECT rate_type, COUNT(*), SUM(current_balance) FROM dbo.loan_tape GROUP BY rate_type
           EXCEPT SELECT * FROM (VALUES ('Fixed', 853, 169638911.00), ('Tracker', 203, 40563887.00), ('SVR', 144, 29797202.00)) AS v (r, n, b))
   THROW 50000, 'Ch17 2.3: rate-type table', 1;
SELECT @n = COUNT(*) FROM (SELECT region FROM dbo.loan_tape GROUP BY region HAVING COUNT(*) > 100) AS g;
IF @n <> 6 THROW 50000, 'Ch17 2.4: six regions over 100 loans', 1;

-- 3.1 first and last buckets
SELECT @d = SUM(current_balance) FROM dbo.loan_tape WHERE indexed_ltv <= 0.50;
SELECT @n = COUNT(*), @d2 = SUM(current_balance) FROM dbo.loan_tape WHERE indexed_ltv > 0.90;
IF @d <> 63960160 OR @n <> 16 OR @d2 <> 2819087 THROW 50000, 'Ch17 3.1: LTV buckets', 1;

-- 4.1 and 4.2 rows
IF EXISTS (SELECT t.loan_id, t.current_balance, s.current_balance FROM dbo.loan_tape AS t JOIN dbo.servicer_balances AS s ON s.loan_id = t.loan_id
           WHERE t.current_balance <> s.current_balance
           EXCEPT SELECT * FROM (VALUES ('ASH100213', 73590.00, 280980.00), ('ASH100500', 159150.00, 157900.00), ('ASH100501', 78640.00, 79890.00)) AS v (i, t, s))
   OR (SELECT COUNT(*) FROM dbo.loan_tape AS t JOIN dbo.servicer_balances AS s ON s.loan_id = t.loan_id WHERE t.current_balance <> s.current_balance) <> 3
   THROW 50000, 'Ch17 4.1: three differences', 1;
SELECT @s = s.loan_id, @d = s.current_balance FROM dbo.servicer_balances AS s LEFT JOIN dbo.loan_tape AS t ON t.loan_id = s.loan_id WHERE t.loan_id IS NULL;
IF @s <> 'ASH100888' OR @d <> 73590 THROW 50000, 'Ch17 4.2: ASH100888', 1;

-- 5.1, 5.2, 5.3 period 1
SELECT @d = ROUND(100.0 * SUM(current_balance) / 240000000, 2) FROM dbo.loan_tape WHERE region = 'South East';
IF @d <> 19.31 THROW 50000, 'Ch17 5.1: South East 19.31%', 1;
SELECT @n = COUNT(*), @n2 = COUNT(DISTINCT loan_id), @d = SUM(current_balance) FROM dbo.servicer_balances;
IF @n <> 1200 OR @n2 <> 1200 OR @d <> 240000000 THROW 50000, 'Ch17 5.2: servicer totals', 1;
SELECT @d = ROUND(100 * (1 - POWER(1 - CAST(prepayments AS FLOAT) / (opening_pool - scheduled_principal), 12)), 1) FROM dbo.periods WHERE period = 1;
IF @d <> 10.5 THROW 50000, 'Ch17 5.3: CPR period 1', 1;

-- 6.1, 6.2, 6.3 / practice 18, 6.5
SELECT @n = COUNT(*) FROM (SELECT loan_id FROM dbo.loan_tape GROUP BY loan_id HAVING COUNT(*) > 1) AS x;
SELECT @s = MAX(loan_id) FROM (SELECT loan_id FROM dbo.loan_tape GROUP BY loan_id HAVING COUNT(*) > 1) AS x;
IF @n <> 1 OR @s <> 'ASH100213' THROW 50000, 'Ch17 6.1: one duplicate ID', 1;
SELECT TOP 1 @d = ROUND(100.0 * current_balance / SUM(current_balance) OVER (), 3) FROM dbo.loan_tape ORDER BY current_balance DESC;
IF @d <> 0.350 THROW 50000, 'Ch17 6.2: largest loan 0.35%', 1;
SELECT @d = ROUND(100.0 * SUM(current_balance) / 240000000, 2) FROM (SELECT TOP 10 current_balance FROM dbo.loan_tape ORDER BY current_balance DESC) AS x;
IF @d <> 2.67 THROW 50000, 'Ch17 6.3 and practice 18: ten largest 2.67%', 1;
SELECT @d = MAX(prepayments) - MIN(prepayments) FROM dbo.periods;
IF @d <> 280000 THROW 50000, 'Ch17 6.5: +280,000', 1;

-- 9.1 January, 9.2 first row and the tie, 9.3 identity, 9.4 full matrix, 9.5 four loans, 9.7 2025
SELECT @n = COUNT(*), @d = SUM(current_balance) FROM dbo.loan_history WHERE month_end = '2026-01-31' AND status = 'Active';
IF @n <> 1257 OR @d <> 255405739 THROW 50000, 'Ch17 9.1: January 1,257 and 255,405,739', 1;
WITH h AS (SELECT loan_id, month_end,
                  LAG(current_balance) OVER (PARTITION BY loan_id ORDER BY month_end) - current_balance AS repaid
           FROM dbo.loan_history WHERE status = 'Active')
SELECT @d = MAX(repaid), @n = SUM(CASE WHEN repaid = 2000 THEN 1 ELSE 0 END) FROM h WHERE month_end = '2026-06-30';
IF @d <> 5462 OR @n <> 3 THROW 50000, 'Ch17 9.2: 5,462 and three loans at 2,000', 1;
WITH h AS (SELECT loan_id, month_end, status, current_balance,
                  LAG(current_balance) OVER (PARTITION BY loan_id ORDER BY month_end) AS prev_balance
           FROM dbo.loan_history)
SELECT @n = COUNT(*) FROM (
  SELECT month_end,
         SUM(prev_balance) - SUM(CASE WHEN status = 'Redeemed' THEN prev_balance ELSE 0 END)
       - SUM(CASE WHEN status = 'Active' THEN prev_balance - current_balance ELSE 0 END) - SUM(current_balance) AS gap
  FROM h WHERE prev_balance IS NOT NULL GROUP BY month_end) AS r
WHERE gap = 0;
IF @n <> 5 THROW 50000, 'Ch17 9.3: roll-forward ties in all five months', 1;
WITH pairs AS (
  SELECT CASE WHEN m.arrears_months >= 3 THEN 3 ELSE m.arrears_months END AS f,
         CASE WHEN j.arrears_months >= 3 THEN 3 ELSE j.arrears_months END AS t
  FROM dbo.loan_history AS m
  JOIN dbo.loan_history AS j ON j.loan_id = m.loan_id AND j.month_end = '2026-06-30' AND j.status = 'Active'
  WHERE m.month_end = '2026-05-31')
SELECT @n = COUNT(*) FROM (SELECT f, t, COUNT(*) AS c FROM pairs GROUP BY f, t
                           EXCEPT SELECT * FROM (VALUES (0,0,1083),(0,1,37),(1,0,14),(1,1,12),(1,2,18),(2,0,5),(2,1,2),(2,2,4),(2,3,4),(3,2,1),(3,3,20)) AS v (f, t, c)) AS x;
IF @n <> 0 THROW 50000, 'Ch17 9.4: roll-rate matrix', 1;
SELECT @n = COUNT(*) FROM dbo.loan_history AS j JOIN dbo.loan_history AS m ON m.loan_id = j.loan_id AND m.month_end = '2026-05-31'
WHERE j.month_end = '2026-06-30' AND j.arrears_months >= 3 AND m.arrears_months = 2;
IF @n <> 4 THROW 50000, 'Ch17 9.5: four new 3+ loans, all from 2', 1;
SELECT @d = ROUND(100.0 * SUM(CASE WHEN arrears_months >= 3 THEN current_balance ELSE 0 END) / SUM(current_balance), 2) FROM dbo.loan_tape WHERE YEAR(origination_date) = 2025;
IF @d <> 1.24 THROW 50000, 'Ch17 9.7: 2025 vintage 1.24%', 1;

-- 10.3 failure counts and the 308 excluded loans
IF (SELECT COUNT(*) FROM dbo.loan_tape WHERE arrears_months > 0) <> 98
OR (SELECT COUNT(*) FROM dbo.loan_tape WHERE indexed_ltv > 0.90) <> 16
OR (SELECT COUNT(*) FROM dbo.loan_tape WHERE current_balance > 750000) <> 2
OR (SELECT COUNT(*) FROM dbo.loan_tape WHERE occupancy <> 'Owner-occupied') <> 216
OR (SELECT COUNT(*) FROM dbo.loan_tape WHERE possession_flag <> 'N') <> 5
   THROW 50000, 'Ch17 10.3: 98 / 16 / 2 / 216 / 5', 1;
SELECT @n = COUNT(*) FROM dbo.loan_tape
WHERE NOT (arrears_months = 0 AND possession_flag = 'N' AND seasoning_months >= 3 AND indexed_ltv <= 0.90
           AND current_balance <= 750000 AND remaining_term_months <= 420 AND occupancy = 'Owner-occupied');
IF @n <> 308 THROW 50000, 'Ch17 10.2: 308 loans excluded', 1;

-- 10.5 control totals for June and May (the query inside the procedure)
SELECT @n = COUNT(*), @n2 = COUNT(DISTINCT loan_id), @d = SUM(current_balance),
       @d2 = SUM(CASE WHEN arrears_months >= 3 THEN current_balance ELSE 0 END)
FROM dbo.loan_history WHERE month_end = '2026-06-30' AND status = 'Active';
IF @n <> 1200 OR @n2 <> 1200 OR @d <> 240000000 OR @d2 <> 4648983 THROW 50000, 'Ch17 10.5: June control totals', 1;
SELECT @n = COUNT(*), @d = SUM(current_balance) FROM dbo.loan_history WHERE month_end = '2026-05-31' AND status = 'Active';
IF @n <> 1211 OR @d <> 242582325 THROW 50000, 'Ch17 10.5: May control totals', 1;

-- 17.14: moving average, ROLLUP total, EXCEPT rows, median
WITH m AS (SELECT month_end, SUM(current_balance) AS balance FROM dbo.loan_history WHERE status = 'Active' GROUP BY month_end)
SELECT @d = ROUND(a, 0) FROM (SELECT month_end, AVG(balance) OVER (ORDER BY month_end ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS a FROM m) AS x
WHERE month_end = '2026-06-30';
IF @d <> 242681670 THROW 50000, 'Ch17 17.14: three-month average 242,681,670', 1;
SELECT @n = loans, @d = balance FROM (SELECT GROUPING(rate_type) AS g, COUNT(*) AS loans, SUM(current_balance) AS balance
                                      FROM dbo.loan_tape GROUP BY ROLLUP(rate_type)) AS x WHERE g = 1;
IF @n <> 1200 OR @d <> 240000000 THROW 50000, 'Ch17 17.14: ROLLUP total row', 1;
IF EXISTS (SELECT loan_id, current_balance FROM dbo.servicer_balances EXCEPT SELECT loan_id, current_balance FROM dbo.loan_tape
           EXCEPT SELECT * FROM (VALUES ('ASH100500', 157900.00), ('ASH100501', 79890.00), ('ASH100888', 73590.00)) AS v (i, b))
   THROW 50000, 'Ch17 17.14: EXCEPT rows', 1;
SELECT DISTINCT @d = PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY current_balance) OVER () FROM dbo.loan_tape;
IF @d <> 179211.5 THROW 50000, 'Ch17 interview table: median balance 179,211.50', 1;

-- Practice set answers (SQL Server values)
IF (SELECT COUNT(*) FROM dbo.loan_tape WHERE rate_type = 'Tracker') <> 203 THROW 50000, 'Practice 1', 1;
IF (SELECT SUM(current_balance) FROM dbo.loan_tape WHERE repayment_type = 'Interest-only') <> 53039031 THROW 50000, 'Practice 2', 1;
IF (SELECT ROUND(AVG(original_ltv), 4) FROM dbo.loan_tape WHERE occupancy = 'Buy-to-let') <> 0.6204 THROW 50000, 'Practice 3', 1;
SELECT TOP 1 @s = loan_id, @d = current_balance FROM dbo.loan_tape WHERE region = 'Scotland' ORDER BY current_balance DESC;
IF @s <> 'ASH100594' OR @d <> 542210 THROW 50000, 'Practice 4', 1;
IF (SELECT COUNT(*) FROM dbo.loan_tape WHERE original_term_months = 420) <> 171 THROW 50000, 'Practice 5', 1;
IF (SELECT ROUND(SUM(indexed_ltv * current_balance) / SUM(current_balance), 4) FROM dbo.loan_tape WHERE arrears_months >= 1) <> 0.6155 THROW 50000, 'Practice 6', 1;
IF (SELECT COUNT(*) FROM dbo.loan_tape WHERE origination_date >= '2025-01-01' AND origination_date < '2026-01-01') <> 221 THROW 50000, 'Practice 7', 1;
IF EXISTS (SELECT original_term_months, COUNT(*) FROM dbo.loan_tape GROUP BY original_term_months
           EXCEPT SELECT * FROM (VALUES (240, 102), (300, 493), (360, 434), (420, 171)) AS v (t, n)) THROW 50000, 'Practice 8', 1;
IF (SELECT ROUND(AVG(current_balance), 0) FROM dbo.loan_tape WHERE region = 'London') <> 205872 THROW 50000, 'Practice 9: London average 205,872', 1;
IF (SELECT ROUND(100.0 * SUM(CASE WHEN rate_type = 'Fixed' THEN current_balance ELSE 0 END) / SUM(current_balance), 2) FROM dbo.loan_tape) <> 70.68 THROW 50000, 'Practice 10', 1;
IF (SELECT SUM(arrears_balance) FROM dbo.loan_tape) <> 252649.48 THROW 50000, 'Practice 11', 1;
SELECT @n = COUNT(*), @d = SUM(current_balance) FROM dbo.loan_tape WHERE possession_flag = 'Y';
IF @n <> 5 OR @d <> 973577 THROW 50000, 'Practice 12', 1;
IF (SELECT COUNT(*) FROM dbo.loan_tape WHERE borrower_income > 150000) <> 34 THROW 50000, 'Practice 13', 1;
SELECT @s = loan_id FROM (SELECT loan_id, DENSE_RANK() OVER (ORDER BY current_balance DESC) AS r FROM dbo.loan_tape) AS x WHERE r = 2;
IF @s <> 'ASH100772' THROW 50000, 'Practice 14', 1;
IF EXISTS (SELECT month_end, COUNT(*) FROM dbo.loan_history WHERE status = 'Redeemed' GROUP BY month_end
           EXCEPT SELECT * FROM (VALUES (CAST('2026-02-28' AS DATE), 11), ('2026-03-31', 12), ('2026-04-30', 13), ('2026-05-31', 10), ('2026-06-30', 11)) AS v (m, n))
   OR (SELECT COUNT(*) FROM dbo.loan_history WHERE status = 'Redeemed') <> 57
   THROW 50000, 'Practice 15', 1;
IF (SELECT COUNT(*) FROM (SELECT loan_id FROM dbo.loan_history GROUP BY loan_id
     HAVING MAX(arrears_months) = 0 AND SUM(CASE WHEN month_end = '2026-06-30' AND status = 'Active' THEN 1 ELSE 0 END) = 1) AS x) <> 984
   THROW 50000, 'Practice 16', 1;
IF (SELECT COUNT(*) FROM (SELECT h.loan_id FROM dbo.loan_history AS h JOIN dbo.loan_tape AS t ON t.loan_id = h.loan_id
     WHERE t.arrears_months >= 3 GROUP BY h.loan_id HAVING MAX(h.arrears_months) >= 7) AS x) <> 7
   THROW 50000, 'Practice 17: four at 8 months, three at 7', 1;
SELECT @n = COUNT(*), @d = SUM(current_balance) FROM dbo.loan_tape WHERE repayment_type = 'Interest-only' AND maturity_date < '2045-01-01';
IF @n <> 50 OR @d <> 11753499 THROW 50000, 'Practice 19', 1;
IF EXISTS (SELECT rate_type, ROUND(AVG(1.0 * seasoning_months), 1) FROM dbo.loan_tape GROUP BY rate_type
           EXCEPT SELECT * FROM (VALUES ('Fixed', 50.1), ('SVR', 49.0), ('Tracker', 50.8)) AS v (r, a))
   THROW 50000, 'Practice 20', 1;

-- Corrections 1, 6, 8, 9
SELECT @n = COUNT(*), @d = SUM(current_balance) FROM dbo.loan_tape WHERE occupancy = 'Buy-to-let';
IF @n <> 216 OR @d <> 46245021 THROW 50000, 'Correction 1', 1;
IF EXISTS (SELECT 1 FROM dbo.loan_tape AS t JOIN dbo.servicer_balances AS s ON s.loan_id = t.loan_id WHERE t.arrears_months <> s.arrears_months)
   THROW 50000, 'Correction 6: no rows', 1;
IF (SELECT COUNT(*) FROM dbo.loan_history AS a JOIN dbo.loan_history AS j ON j.loan_id = a.loan_id AND j.month_end = '2026-06-30' AND j.status = 'Active'
    WHERE a.month_end = '2026-04-30' AND a.arrears_months = 0 AND j.arrears_months >= 2) <> 12 THROW 50000, 'Correction 8', 1;
SELECT @n = COUNT(*), @d = SUM(current_balance) FROM dbo.loan_tape
WHERE arrears_months = 0 AND possession_flag = 'N' AND seasoning_months >= 3 AND indexed_ltv <= 0.90
  AND current_balance <= 750000 AND remaining_term_months <= 420 AND (occupancy = 'Owner-occupied' OR indexed_ltv <= 0.75);
IF @n <> 1082 OR @d <> 215298938 THROW 50000, 'Correction 9', 1;

-- Practice test 2, question 4 (SQL route)
SELECT @d = ROUND(100 * SUM(CASE WHEN loan_id = 'ASH100602' THEN 0.0537 ELSE interest_rate END * current_balance) / SUM(current_balance), 3),
       @d2 = ROUND(100 * SUM(indexed_ltv * current_balance) / SUM(current_balance), 3),
       @d3 = ROUND(100 * SUM(CASE WHEN loan_id = 'ASH100357' THEN 0.4638 ELSE indexed_ltv END * current_balance) / SUM(current_balance), 3)
FROM dbo.loan_tape;
IF @d <> 5.400 OR @d2 <> 60.333 OR @d3 <> 60.317 THROW 50000, 'Practice test 2 Q4: 5.400 / 60.333 / 60.317', 1;
IF (SELECT ROUND(100.0 * SUM(current_balance) / 240000000, 2) FROM dbo.loan_tape WHERE region IN ('London', 'Greater London')) <> 16.42
   THROW 50000, 'Practice test 2 Q4: London corrected 16.42%', 1;

-- Mock 4 query (SUM of SUM OVER) runs and gives 12 rows summing to 100%
SELECT @n = COUNT(*), @d = ROUND(SUM(pct), 6) FROM (
  SELECT region, 100.0 * SUM(current_balance) / SUM(SUM(current_balance)) OVER () AS pct FROM dbo.loan_tape GROUP BY region) AS x;
IF @n <> 12 OR ABS(@d - 100) > 0.0001 THROW 50000, 'Mock 4: share of pool by region', 1;

PRINT 'ALL CHECKS PASSED';
