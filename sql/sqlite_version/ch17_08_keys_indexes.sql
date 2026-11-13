-- SQLite version of ch17_08_keys_indexes.sql
-- SQLite cannot add a primary key to an existing table; a UNIQUE index shows the same problem.
-- 8.1 This FAILS: UNIQUE constraint failed (ASH100213 appears twice)
CREATE UNIQUE INDEX ux_loan_tape_id ON loan_tape (loan_id);

-- 8.2 Clean design with primary and foreign keys
DROP TABLE IF EXISTS loan_month;
DROP TABLE IF EXISTS loan;
CREATE TABLE loan (
    loan_id TEXT NOT NULL PRIMARY KEY,
    origination_date TEXT NOT NULL,
    original_balance REAL NOT NULL CHECK (original_balance > 0),
    region TEXT NOT NULL
);
CREATE TABLE loan_month (
    loan_id TEXT NOT NULL REFERENCES loan (loan_id),
    as_at_date TEXT NOT NULL,
    current_balance REAL NOT NULL CHECK (current_balance >= 0),
    arrears_months INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (loan_id, as_at_date)
);
-- 8.3 Load the loans, correcting the mislabelled ID found in Chapter 15
INSERT INTO loan (loan_id, origination_date, original_balance, region)
SELECT CASE WHEN loan_id = 'ASH100213' AND origination_date = '2020-04-30'
            THEN 'ASH100888' ELSE loan_id END,
       origination_date, original_balance, region
FROM loan_tape;
INSERT INTO loan_month (loan_id, as_at_date, current_balance, arrears_months)
SELECT loan_id, '2026-06-30', current_balance, arrears_months
FROM servicer_balances AS s
WHERE EXISTS (SELECT 1 FROM loan AS l WHERE l.loan_id = s.loan_id);
-- 8.4 The foreign key at work: this FAILS (run_query.py switches foreign keys on)
INSERT INTO loan_month (loan_id, as_at_date, current_balance) VALUES ('ASH999999', '2026-06-30', 100000);
-- 8.5 Index
CREATE INDEX IF NOT EXISTS ix_loan_tape_region ON loan_tape (region);
-- 8.6 Check the loads
SELECT (SELECT COUNT(*) FROM loan) AS loans, (SELECT COUNT(*) FROM loan_month) AS loan_months;
