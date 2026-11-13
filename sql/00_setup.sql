-- Structured Finance Interviews from Zero: Chapter 0 and Chapter 17
-- Creates the practice database and loads the companion CSV files.
-- Change the four file paths below to where your companion folder is.
-- The CSV files use Unix (LF) line endings, hence ROWTERMINATOR = '0x0a'.
-- FORMAT = 'CSV' needs SQL Server 2017 or later.
-- Docker users: copy the files into the container first, e.g.
--   docker cp data/. sql1:/tmp/
-- and use the paths /tmp/ashcombe_loan_tape.csv and so on.

IF DB_ID('ashcombe') IS NULL CREATE DATABASE ashcombe;
GO
USE ashcombe;
GO

DROP TABLE IF EXISTS dbo.loan_tape;
DROP TABLE IF EXISTS dbo.servicer_balances;
DROP TABLE IF EXISTS dbo.periods;
DROP TABLE IF EXISTS dbo.loan_history;
GO

-- No primary key on purpose: the tape contains a duplicate loan_id (Chapter 17 explains).
CREATE TABLE dbo.loan_tape (
    loan_id               VARCHAR(12)    NOT NULL,
    origination_date      DATE           NOT NULL,
    maturity_date         DATE           NOT NULL,
    original_term_months  INT            NOT NULL,
    seasoning_months      INT            NOT NULL,
    remaining_term_months INT            NOT NULL,
    original_balance      DECIMAL(18,2)  NOT NULL,
    current_balance       DECIMAL(18,2)  NOT NULL,
    original_valuation    DECIMAL(18,2)  NOT NULL,
    indexed_valuation     DECIMAL(18,2)  NULL,
    original_ltv          DECIMAL(9,4)   NOT NULL,
    indexed_ltv           DECIMAL(9,4)   NULL,
    interest_rate         DECIMAL(9,5)   NOT NULL,
    rate_type             VARCHAR(20)    NOT NULL,
    repayment_type        VARCHAR(20)    NOT NULL,
    occupancy             VARCHAR(20)    NOT NULL,
    region                VARCHAR(40)    NOT NULL,
    monthly_payment       DECIMAL(18,2)  NOT NULL,
    arrears_months        INT            NOT NULL,
    arrears_balance       DECIMAL(18,2)  NOT NULL,
    possession_flag       CHAR(1)        NOT NULL,
    borrower_income       DECIMAL(18,2)  NULL,
    income_verified       VARCHAR(3)     NULL
);

CREATE TABLE dbo.servicer_balances (
    loan_id          VARCHAR(12)   NOT NULL PRIMARY KEY,
    current_balance  DECIMAL(18,2) NOT NULL,
    arrears_months   INT           NOT NULL
);

CREATE TABLE dbo.periods (
    period               INT           NOT NULL PRIMARY KEY,
    payment_date         DATE          NOT NULL,
    collection_month     VARCHAR(7)    NOT NULL,
    opening_pool         DECIMAL(18,2) NOT NULL,
    revenue_receipts     DECIMAL(18,2) NOT NULL,
    scheduled_principal  DECIMAL(18,2) NOT NULL,
    prepayments          DECIMAL(18,2) NOT NULL,
    losses               DECIMAL(18,2) NOT NULL
);

-- Six months of servicing history, one row per loan per month (Chapters 16 to 18)
CREATE TABLE dbo.loan_history (
    loan_id          VARCHAR(12)   NOT NULL,
    month_end        DATE          NOT NULL,
    current_balance  DECIMAL(18,2) NOT NULL,
    arrears_months   INT           NOT NULL,
    monthly_payment  DECIMAL(18,2) NOT NULL,
    status           VARCHAR(10)   NOT NULL,
    CONSTRAINT pk_loan_history PRIMARY KEY (loan_id, month_end)
);
GO

BULK INSERT dbo.loan_tape
FROM 'C:\temp\ashcombe_loan_tape.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a');

BULK INSERT dbo.servicer_balances
FROM 'C:\temp\servicer_balances.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a');

BULK INSERT dbo.periods
FROM 'C:\temp\ashcombe_periods.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a');

BULK INSERT dbo.loan_history
FROM 'C:\temp\ashcombe_loan_history.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a');
GO

-- Check: should return 1200 and 240000000.00
SELECT COUNT(*) AS loans, SUM(current_balance) AS balance
FROM dbo.loan_tape;
