-- Structured Finance Interviews from Zero, Chapter 17 (SQL Server / T-SQL).
-- Run 00_setup.sql first. SQLite versions are in sqlite_version/.
USE ashcombe;
GO

-- 4.1 INNER JOIN: loans in both sources whose balances differ
SELECT t.loan_id,
       t.current_balance                     AS tape_balance,
       s.current_balance                     AS servicer_balance,
       t.current_balance - s.current_balance AS difference
FROM dbo.loan_tape AS t
JOIN dbo.servicer_balances AS s ON s.loan_id = t.loan_id
WHERE t.current_balance <> s.current_balance
ORDER BY t.loan_id;

-- 4.2 LEFT JOIN: servicer loans missing from the tape
SELECT s.loan_id, s.current_balance
FROM dbo.servicer_balances AS s
LEFT JOIN dbo.loan_tape AS t ON t.loan_id = s.loan_id
WHERE t.loan_id IS NULL;

-- 4.3 FULL OUTER JOIN: every loan in either source, with its status
SELECT COALESCE(t.loan_id, s.loan_id) AS loan_id,
       t.current_balance AS tape_balance,
       s.current_balance AS servicer_balance,
       CASE
         WHEN t.loan_id IS NULL THEN 'Servicer only'
         WHEN s.loan_id IS NULL THEN 'Tape only'
         WHEN t.current_balance <> s.current_balance THEN 'Balance differs'
         ELSE 'Match'
       END AS status
FROM dbo.loan_tape AS t
FULL OUTER JOIN dbo.servicer_balances AS s ON s.loan_id = t.loan_id
WHERE t.loan_id IS NULL OR s.loan_id IS NULL OR t.current_balance <> s.current_balance
ORDER BY loan_id;
