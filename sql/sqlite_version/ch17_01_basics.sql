-- 1.1 The first ten loans, a few columns
SELECT loan_id, current_balance, interest_rate, region
FROM loan_tape
ORDER BY loan_id
LIMIT 10;

-- 1.2 Loans 3 or more months in arrears, largest first
SELECT loan_id, current_balance, arrears_months, arrears_balance
FROM loan_tape
WHERE arrears_months >= 3
ORDER BY current_balance DESC;

-- 1.3 Buy-to-let interest-only loans in London over 300,000
SELECT loan_id, current_balance, indexed_ltv
FROM loan_tape
WHERE occupancy = 'Buy-to-let'
  AND repayment_type = 'Interest-only'
  AND region = 'London'
  AND current_balance > 300000
ORDER BY current_balance DESC;

-- 1.4 Loans in two regions, using IN
SELECT COUNT(*) AS loans
FROM loan_tape
WHERE region IN ('Scotland', 'Wales');

-- 1.5 The loan with no indexed valuation: IS NULL, never = NULL
SELECT loan_id, current_balance, indexed_valuation
FROM loan_tape
WHERE indexed_valuation IS NULL;
