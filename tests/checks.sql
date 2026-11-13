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

PRINT 'ALL CHECKS PASSED';
