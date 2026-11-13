-- SQLite version of 00_setup.sql (tables only; build_db.py loads the CSVs)
CREATE TABLE loan_tape (
    loan_id TEXT NOT NULL, origination_date TEXT NOT NULL, maturity_date TEXT NOT NULL,
    original_term_months INTEGER NOT NULL, seasoning_months INTEGER NOT NULL,
    remaining_term_months INTEGER NOT NULL, original_balance REAL NOT NULL,
    current_balance REAL NOT NULL, original_valuation REAL NOT NULL, indexed_valuation REAL,
    original_ltv REAL NOT NULL, indexed_ltv REAL, interest_rate REAL NOT NULL,
    rate_type TEXT NOT NULL, repayment_type TEXT NOT NULL, occupancy TEXT NOT NULL,
    region TEXT NOT NULL, monthly_payment REAL NOT NULL, arrears_months INTEGER NOT NULL,
    arrears_balance REAL NOT NULL, possession_flag TEXT NOT NULL, borrower_income REAL,
    income_verified TEXT
);
CREATE TABLE servicer_balances (
    loan_id TEXT NOT NULL PRIMARY KEY, current_balance REAL NOT NULL, arrears_months INTEGER NOT NULL
);
CREATE TABLE periods (
    period INTEGER NOT NULL PRIMARY KEY, payment_date TEXT NOT NULL, collection_month TEXT NOT NULL,
    opening_pool REAL NOT NULL, revenue_receipts REAL NOT NULL, scheduled_principal REAL NOT NULL,
    prepayments REAL NOT NULL, losses REAL NOT NULL
);
CREATE TABLE loan_history (
    loan_id TEXT NOT NULL, month_end TEXT NOT NULL, current_balance REAL NOT NULL,
    arrears_months INTEGER NOT NULL, monthly_payment REAL NOT NULL, status TEXT NOT NULL,
    PRIMARY KEY (loan_id, month_end)
);
