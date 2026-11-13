-- Structured Finance Interviews from Zero, Chapter 17 (SQL Server / T-SQL).
-- Run 00_setup.sql first. SQLite versions are in sqlite_version/.
USE ashcombe;
GO

-- 10.1 A view: a saved query that behaves like a table
DROP VIEW IF EXISTS dbo.v_pool_summary;
GO
CREATE VIEW dbo.v_pool_summary AS
SELECT COUNT(*) AS loans,
       SUM(current_balance) AS balance,
       SUM(interest_rate * current_balance) / SUM(current_balance) AS wa_rate,
       SUM(indexed_ltv * current_balance) / SUM(current_balance) AS wa_iltv
FROM dbo.loan_tape;
GO

SELECT * FROM dbo.v_pool_summary;

-- 10.2 A pool cut: which loans meet the eligibility criteria for a new deal?
SELECT COUNT(*) AS eligible_loans, SUM(current_balance) AS eligible_balance
FROM dbo.loan_tape
WHERE arrears_months = 0
  AND possession_flag = 'N'
  AND seasoning_months >= 3
  AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
  AND occupancy = 'Owner-occupied';

-- 10.3 Why loans fail: one row per criterion
SELECT 'In arrears' AS reason, COUNT(*) AS loans FROM dbo.loan_tape WHERE arrears_months > 0
UNION ALL SELECT 'Indexed LTV over 90%', COUNT(*) FROM dbo.loan_tape WHERE indexed_ltv > 0.90
UNION ALL SELECT 'Balance over 750,000', COUNT(*) FROM dbo.loan_tape WHERE current_balance > 750000
UNION ALL SELECT 'Buy-to-let', COUNT(*) FROM dbo.loan_tape WHERE occupancy <> 'Owner-occupied'
UNION ALL SELECT 'In possession', COUNT(*) FROM dbo.loan_tape WHERE possession_flag <> 'N';

-- 10.4 A temporary table: keep an intermediate result for several queries
DROP TABLE IF EXISTS #eligible;
SELECT loan_id, current_balance, region
INTO #eligible
FROM dbo.loan_tape
WHERE arrears_months = 0 AND indexed_ltv <= 0.90 AND occupancy = 'Owner-occupied';

SELECT region, COUNT(*) AS loans, SUM(current_balance) AS balance
FROM #eligible GROUP BY region ORDER BY balance DESC;
GO

-- 10.5 A stored procedure: the monthly control totals for any month-end
DROP PROCEDURE IF EXISTS dbo.usp_control_totals;
GO
CREATE PROCEDURE dbo.usp_control_totals
    @month_end DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @month_end            AS month_end,
           COUNT(*)              AS loans,
           COUNT(DISTINCT loan_id) AS distinct_ids,
           SUM(current_balance)  AS balance,
           SUM(CASE WHEN arrears_months >= 3 THEN current_balance ELSE 0 END) AS arrears_3plus
    FROM dbo.loan_history
    WHERE month_end = @month_end AND status = 'Active';
END;
GO

EXEC dbo.usp_control_totals @month_end = '2026-06-30';
EXEC dbo.usp_control_totals @month_end = '2026-05-31';
