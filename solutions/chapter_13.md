# Chapter 13: Regulation: the rules every deal follows

## Corrections

### Exercise 1: STS criteria a loan tape can test

#### What the question asks

> Name three STS criteria you could test directly on a loan tape.

In plain words: the STS label (simple, transparent and standardised) has a long list of criteria. Some can only be checked by reading the deal documents; others can be checked with a query on the loan data. You must name three of the second kind, and a strong answer also says how you would test each one and what the Ashcombe tape shows.

The exercise uses the STS criteria and the table *Testing STS criteria on a loan tape* in Section 13.6, the loan tape fields of Appendix D, and the SQL of Chapter 17 (`COUNT`, `SUM`, `CASE`, `WHERE`).

#### The plan

1. **Separate document criteria from data criteria.** A criterion is testable on the tape only if a field on the tape answers it.
2. **Choose three data criteria** and write each as a precise condition on named fields.
3. **Run the tests on the Ashcombe tape** and record the result, because a test without a result is only half an answer.
4. **Check that the fields are populated,** since a blank field passes a test it should fail.

#### Step by step

**Step 1: document or data?** From Section 13.6:

| Criterion | Tested on | Why |
|---|---|---|
| True sale | Documents | A legal question about the transfer |
| Sequential after enforcement | Documents | Set in the priority of payments |
| At least one payment made | **Tape** | `seasoning_months` |
| No loans in default at closing | **Tape** | `arrears_months`, `possession_flag` |
| Homogeneity | **Tape** | asset type, region, occupancy |
| Credit-granting standards | **Tape** (in part) | `income_verified` |

**Step 2 and 3: three tests, written and run.** In SQLite (for SQL Server, add `dbo.` before the table name):

*Test 1: at least one payment made.*

```sql
SELECT COUNT(*) AS loans,
       MIN(seasoning_months) AS min_seasoning,
       SUM(CASE WHEN seasoning_months < 1
                THEN 1 ELSE 0 END) AS failing
FROM loan_tape;
```

- `MIN(seasoning_months)` shows the youngest loan.
- The `CASE` inside `SUM` counts the loans with less than one month of seasoning: 1 when the condition is true, 0 otherwise.
- Result: 1,200 loans, minimum seasoning **6 months**, **0** failing.

*Test 2: no loans in default at closing.*

```sql
SELECT COUNT(*) AS loans, SUM(current_balance) AS balance,
       SUM(CASE WHEN possession_flag = 'Y'
                THEN 1 ELSE 0 END) AS in_possession
FROM loan_tape
WHERE arrears_months >= 3 OR possession_flag = 'Y';
```

- The `WHERE` keeps the loans that count as in default: 3 or more months in arrears, or repossessed.
- The `CASE` sum counts how many of them are in possession.
- Result: **24 loans, £4,648,983, fail**; 5 of them are also in possession.

*Test 3: credit-granting standards (income verified).*

```sql
SELECT income_verified, COUNT(*) AS loans
FROM loan_tape
GROUP BY income_verified;
```

- `GROUP BY` lists every value the field takes, with its count, so an unexpected value (blank, "N", "Unknown") would appear as its own row.
- Result: **Yes, 1,200**: every loan passes.

The homogeneity criterion is a fourth valid answer: `SELECT DISTINCT occupancy` and the region list show that every loan is a UK residential mortgage.

#### Reading the result

- **Two of the three tests pass and one fails.** Every loan has made payments and every borrower's income was verified, but 24 loans (£4.6 million, 1.94% of the pool) are in serious arrears or in possession.
- **As built, the Ashcombe pool could not be labelled STS.** The 24 loans would have to be removed before closing, which is what the eligibility criteria and the pool cut of Chapter 17 do.
- **This is data work.** A data analyst can run these tests in minutes every time a pool is proposed, and the results go straight into the STS notification file.

- **The results feed the eligibility criteria.** Eligibility criteria (Chapter 4) are written so that the pool meets STS at closing: "no loan more than one month in arrears", "no loan in possession". The pool cut of Chapter 17 applies them; the tests above prove, afterwards, that the selected pool really meets them.

#### Checking your answer

- **Each test must be a condition you could hand to a colleague.** "No loans in default" is not testable; "`arrears_months >= 3 OR possession_flag = 'Y'` returns no rows" is.
- **The fields must be complete.** A blank `arrears_months` would make `arrears_months >= 3` false and the loan would pass. Check:

```sql
SELECT COUNT(*) AS loans FROM loan_tape
WHERE arrears_months IS NULL OR possession_flag IS NULL;
```

It returns **0**, so the test 2 result is trustworthy.

- **The failing count matches the arrears strat.** The Strats sheet of Chapter 16 shows 24 loans 3+ months in arrears: the same loans, by another tool.

#### Mistakes people make on this exercise

- **Naming document criteria.** "True sale" and "clear waterfall" are real STS criteria, but no loan field tests them; an answer that names them scores nothing for the data part of the question.
- **Testing `arrears_months > 3`.** That misses loans exactly 3 months behind: 3 months is the usual definition of default in UK deals. Use `>= 3`.
- **Forgetting possession.** A repossessed loan can show fewer months in arrears than it owes once the servicer stops counting; the possession flag must be tested too.
- **Trusting a pass without checking blanks.** A field that is blank for every loan makes every condition false and every loan "pass".

#### Trade-offs and going further

- **Data tests against legal judgement.** The data tests are fast and repeatable but only answer part of each criterion. "Credit-granting standards" also means the lender's policies were applied consistently, which an income flag cannot prove. The STS notification relies on both, and responsibility stays with the originator.
- **Testing at the cut-off date only, or again at closing.** The tape is measured at the cut-off date; a loan can fall into arrears before closing. Many teams rerun the tests on the latest data just before closing.
- **Going further.** Write a fourth test for the "at least one payment" criterion that does not rely on seasoning: compare `original_balance` with `current_balance` for repayment loans. A repayment loan that has made payments must have a lower balance. On the Ashcombe tape one repayment loan, ASH100104, has a balance above its original: Chapter 15 explains why that needs a question to the servicer.
