-- Structured Finance Interviews from Zero, Chapter 17 (SQL Server / T-SQL).
-- Run 00_setup.sql first. SQLite versions are in sqlite_version/.
USE ashcombe;
GO

-- 7.1 All data-quality exceptions in one list
SELECT loan_id, 'Duplicate loan_id' AS rule_failed
FROM dbo.loan_tape GROUP BY loan_id HAVING COUNT(*) > 1
UNION ALL
SELECT loan_id, 'Missing indexed valuation'
FROM dbo.loan_tape WHERE indexed_valuation IS NULL
UNION ALL
SELECT loan_id, 'Stored indexed LTV differs by more than 0.5%'
FROM dbo.loan_tape
WHERE indexed_valuation IS NOT NULL
  AND ABS(current_balance / indexed_valuation - indexed_ltv) > 0.005
UNION ALL
SELECT loan_id, 'Interest rate outside 0.5% to 15%'
FROM dbo.loan_tape WHERE interest_rate < 0.005 OR interest_rate > 0.15
UNION ALL
SELECT loan_id, 'Maturity not origination + term'
FROM dbo.loan_tape
WHERE DATEDIFF(month, origination_date, maturity_date) <> original_term_months
UNION ALL
SELECT loan_id, 'Region not in allowed list'
FROM dbo.loan_tape
WHERE DATALENGTH(region) <> DATALENGTH(TRIM(region))          -- extra spaces
   OR region COLLATE Latin1_General_CS_AS NOT IN ('East Midlands','East of England','London','North East','North West',
                     'Scotland','South East','South West','Wales','West Midlands',
                     'Yorkshire and the Humber')
UNION ALL
SELECT loan_id, 'Repayment loan above original balance'
FROM dbo.loan_tape WHERE repayment_type = 'Repayment' AND current_balance > original_balance
UNION ALL
SELECT loan_id, 'Term does not add up'
FROM dbo.loan_tape WHERE original_term_months <> seasoning_months + remaining_term_months
ORDER BY 2, 1;
