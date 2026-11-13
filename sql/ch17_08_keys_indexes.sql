-- Structured Finance Interviews from Zero, Chapter 17 (SQL Server / T-SQL).
-- Keys, constraints and indexes. Run 00_setup.sql first.
USE ashcombe;
GO

-- 8.1 Try to make loan_id the primary key of the tape. This FAILS,
--     because ASH100213 appears twice. The error message names the duplicate key.
ALTER TABLE dbo.loan_tape
  ADD CONSTRAINT pk_loan_tape PRIMARY KEY (loan_id);
GO

-- 8.2 A clean design: one table of loans, one table of monthly performance
DROP TABLE IF EXISTS dbo.loan_month;
DROP TABLE IF EXISTS dbo.loan;
GO
CREATE TABLE dbo.loan (
    loan_id           VARCHAR(12)   NOT NULL,
    origination_date  DATE          NOT NULL,
    original_balance  DECIMAL(18,2) NOT NULL CHECK (original_balance > 0),
    region            VARCHAR(40)   NOT NULL,
    CONSTRAINT pk_loan PRIMARY KEY (loan_id)
);

CREATE TABLE dbo.loan_month (
    loan_id          VARCHAR(12)   NOT NULL,
    as_at_date       DATE          NOT NULL,
    current_balance  DECIMAL(18,2) NOT NULL CHECK (current_balance >= 0),
    arrears_months   INT           NOT NULL DEFAULT 0,
    CONSTRAINT pk_loan_month PRIMARY KEY (loan_id, as_at_date),
    CONSTRAINT fk_loan_month_loan FOREIGN KEY (loan_id) REFERENCES dbo.loan (loan_id)
);
GO

-- 8.3 Load the loans, correcting the mislabelled ID found in Chapter 15
--     (the 2020 loan labelled ASH100213 is really ASH100888)
INSERT INTO dbo.loan (loan_id, origination_date, original_balance, region)
SELECT CASE WHEN loan_id = 'ASH100213' AND origination_date = '2020-04-30'
            THEN 'ASH100888' ELSE loan_id END,
       origination_date, original_balance, region
FROM dbo.loan_tape;

INSERT INTO dbo.loan_month (loan_id, as_at_date, current_balance, arrears_months)
SELECT s.loan_id, '2026-06-30', s.current_balance, s.arrears_months
FROM dbo.servicer_balances AS s
WHERE EXISTS (SELECT 1 FROM dbo.loan AS l WHERE l.loan_id = s.loan_id);
GO

-- 8.4 The foreign key at work: this FAILS, because loan ASH999999 does not exist
INSERT INTO dbo.loan_month (loan_id, as_at_date, current_balance)
VALUES ('ASH999999', '2026-06-30', 100000);
GO

-- 8.5 An index to speed up searches and groupings by region
DROP INDEX IF EXISTS ix_loan_tape_region ON dbo.loan_tape;
CREATE INDEX ix_loan_tape_region ON dbo.loan_tape (region) INCLUDE (current_balance);
GO

-- 8.6 Which indexes exist on the tape?
SELECT i.name AS index_name, i.type_desc
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('dbo.loan_tape') AND i.name IS NOT NULL;
