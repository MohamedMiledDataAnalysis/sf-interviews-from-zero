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

PRINT 'ALL CHECKS PASSED';
