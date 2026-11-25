# Chapter 20: Practice test 2: loan tape, data quality and reporting

## Solution

### Question 1: control totals

#### What the question asks

> **Control totals (8 marks).** Give the number of rows, the number of distinct loan IDs and the total balance in each file. What do they tell you?

In plain words: three totals for each of the two files (rows, distinct loan IDs, balance), compared side by side, and what the comparison does and does not prove.

#### The plan

1. **Count the rows** in each file: a missing or truncated extract shows here first.
2. **Count the distinct loan IDs**: if it is lower than the row count, an ID appears more than once.
3. **Sum the balances**: the figure the investor report will show.
4. **Compare pair by pair and say what agrees and what does not**: a control total is only useful with a conclusion.

#### Step by step

| | Tape | Servicer |
|---|---:|---:|
| Rows | 1,200 | 1,200 |
| Distinct loan IDs | **1,199** | 1,200 |
| Balance (£) | 240,000,000 | 240,000,000 |

Rows and balances agree, but the tape has 1,199 distinct IDs for 1,200 rows: at least one ID appears twice. **Matching totals do not prove the data is right**; loan-level reconciliation is needed.

How: Excel `COUNTA` and `SUM`, and `=SUMPRODUCT(1/COUNTIF(range, range))` for distinct values (or `=COUNTA(UNIQUE(range))` in Excel 365; the SUMPRODUCT form fails if the range contains a blank); SQL `COUNT(*)`, `COUNT(DISTINCT loan_id)`, `SUM(current_balance)`; pandas `len`, `nunique`, `sum`.

#### Reading the result

Totals agree, but one ID is duplicated in the tape: the files are not yet proven to match.

#### Checking your answer

Rows − distinct IDs = 1 in the tape and 0 in the servicer file; `tape[tape.duplicated('loan_id', keep=False)]` shows the two ASH100213 rows.

#### Mistakes people make on this question

- Stopping when the totals agree.
- **Counting distinct IDs with COUNTIF on a column with blanks.** `SUMPRODUCT(1/COUNTIF(range,range))` divides by zero on a blank cell; check for blanks first or use `COUNTA(UNIQUE(range))`.
- **Reporting the totals without a conclusion.** The marks are for "totals agree but one ID is duplicated, so a loan-level reconciliation is needed".

#### Trade-offs and going further

Control totals take a minute and catch gross errors (a missing file, a truncated extract); only a loan-level reconciliation catches errors that cancel.

- **Going further.** Add a fourth control total: the number of loans per region in each file. It would show the London spellings at once.

### Question 2: reconciliation

#### What the question asks

> **Reconciliation (14 marks).** Reconcile the tape to the servicer extract at loan level. List every difference and explain its likely cause.

In plain words: match every loan of the tape to the servicer's extract by loan ID, list every loan that is missing on one side or has a different balance, and explain each difference.

#### The plan

1. **Join the two files on `loan_id` with a full outer join**, so that loans missing on either side appear.
2. **List the unmatched keys**, then the matched keys with a non-zero difference.
3. **Look at each exception's other fields** (origination date, balance on the other side) to find its cause.
4. **Show how the differences net to the matching totals**, which proves the list is complete.

#### Step by step

| Loan | Tape (£) | Servicer (£) | Difference (£) | Cause |
|---|---:|---:|---:|---|
| ASH100888 | not in tape | 73,590 | | Mislabelled in the tape as ASH100213 |
| ASH100213 (2nd row) | 73,590 | 280,980 | −207,390 | Not a balance error: two loans share this ID, and one is really ASH100888 |
| ASH100500 | 159,150 | 157,900 | +1,250 | £1,250 overpayment applied to ASH100501 instead of ASH100500 |
| ASH100501 | 78,640 | 79,890 | −1,250 | Same, opposite side |

The two £1,250 differences cancel, and the mislabelled loan is still counted, which is why the totals agree.

#### Reading the result

Two problems explain all four rows: a mislabelled ID and an overpayment posted to the wrong loan.

#### Checking your answer

The differences net to zero (+1,250 − 1,250) and the mislabelled balance is counted once on each side, which is why the totals agreed.

- **pandas gives the same four rows** with `merge(..., how="outer", indicator=True)` and a filter on `_merge != "both"` or a non-zero difference (Extension E3).

#### Mistakes people make on this question

- **An inner join**, which hides ASH100888 entirely.
- **Explaining the −£207,390 as a balance error.** The two ASH100213 rows are two different loans; the difference disappears once the second is relabelled ASH100888.
- **Netting the two £1,250 differences and reporting nothing.** Each loan's balance is wrong; the report and the regulatory file use loan-level balances.

#### Trade-offs and going further

Matching on ID alone can mislead when an ID is reused; for a suspicious pair, compare a second field such as the origination date.

- **Going further.** Rerun the reconciliation after correcting the ID: only ASH100500 and ASH100501 remain, with +£1,250 and −£1,250.

### Question 3: the seven data errors

#### What the question asks

> **Data quality rules (24 marks).** Run checks for uniqueness, completeness, valid values and consistency. Identify **seven** separate data errors in the tape, with the loan ID, the field, what is wrong and how you found it.

In plain words: apply the four kinds of data quality rule to the tape and find seven separate errors, each with the loan, the field, what is wrong and the rule that found it.

#### The plan

1. **Uniqueness**: count IDs; a duplicate is error 1.
2. **Completeness**: count blanks per required field.
3. **Valid values**: ranges for rates, allowed lists for regions, an exact comparison so that case and spaces count.
4. **Consistency**: recalculate stored fields (LTV, maturity date, balance against original) and compare with a tolerance.

Each dimension is one family of rules (Chapter 15, Section 15.1); running all four guarantees that no kind of error is skipped.

#### Step by step

| # | Loan | Field | What is wrong | Found by |
|---|---|---|---|---|
| 1 | ASH100213 (second row) | `loan_id` | Two different loans (originated 2020 and 2024) share one ID; the 2020 loan is ASH100888 | Uniqueness check; reconciliation |
| 2 | ASH100357 | `indexed_ltv` | Stored 64.00%; balance ÷ indexed valuation = 217,068 ÷ 468,000 = 46.38% | Recalculate LTV, tolerance 0.005 (0.5 percentage points) |
| 3 | ASH100602 | `interest_rate` | 0.537 (53.7%); almost certainly 0.0537 (5.37%), a keying slip | Range check 0.5% to 15% |
| 4 | ASH100734 | `maturity_date` | 31 August 2039, but origination 31 August 2024 + 300 months = **31 August 2049** | Maturity check with EOMONTH |
| 5 | ASH101045 | `indexed_valuation` | Blank | Completeness check |
| 6 | ASH100096, ASH100411, ASH101151 | `region` | "london", `"London "` (trailing space) and "Greater London" | Allowed-values check, case-sensitive and exact |
| 7 | ASH100104 | `current_balance` | Repayment loan with a balance of £79,516, above its original £75,730 | Consistency check by repayment type |

Notes on method:

- Rule 6 needs an **exact** comparison. Excel's `COUNTIF` ignores case, so it misses `"london"`; SQL Server's default collation ignores case, and its comparisons ignore trailing spaces, so a rule that tests `region = 'London'` misses both `"london"` and `"London "` (with a trailing space); for the same reason `WHERE region = 'London'` gives London 16.30% of the pool in SQL Server, not 16.15%. Only `"Greater London"` is caught by both. Use `EXACT` in Excel, `COLLATE ... CS_AS` and a length check in SQL Server, or plain `isin` in pandas.
- Rule 4 must use month-ends: `EDATE` can return the 30th instead of the month-end (for example 30 August instead of 31 August), so `EOMONTH` (or comparing months) is the safe test.
- Loan ASH101045 has a stored indexed LTV (53.8%) but no indexed valuation, so the stored figure cannot be checked. Flag it rather than trust it.

#### Reading the result

Each rule finds one error; region needs an exact comparison, because three of the usual tools ignore case or trailing spaces.

#### Checking your answer

Every error is reproducible: each rule, rerun, returns the same loans. The pandas script `ch18_03_data_quality.py` lists them all.

#### Mistakes people make on this question

- **Counting the reconciliation difference as a tape error.** It is a difference between two files: in the log it is DQ-02, apart from the seven tape errors.
- **Counting the three region variants as three errors.** They are one error type (non-standard region values) affecting three loans.
- **Using `EDATE` for the maturity rule.** It can land on the 30th instead of the month-end; `EOMONTH` is the safe test.

#### Trade-offs and going further

Exact rules find every variant but flag harmless ones too (a trailing space); a mapping table handles the known ones and leaves the rule to catch new ones.

- **Going further.** Write each rule as a one-line specification (field, condition, tolerance, dimension) as in Chapter 15, Section 15.6: the list becomes the test plan for the next tape.

### Question 4: impact on reported metrics

#### What the question asks

> **Impact (14 marks).** Calculate the WA interest rate and the WA indexed LTV as reported and after correcting the errors that affect them. Calculate London's share of the pool before and after cleaning the region field.

In plain words: show how much the errors of Question 3 change three figures an investor reads: the WA interest rate, the WA indexed LTV, and London's share of the pool.

#### The plan

1. **Compute each metric as reported**, on the tape as received.
2. **Correct only the errors that affect that metric**, in a copy of the data.
3. **Recompute and show the change**, in basis points or percentage points.
4. **Explain why each change is large or small**, from the size of the loan and the size of the error.

#### Step by step

| Metric | As reported | Corrected | Change |
|---|---:|---:|---:|
| WA interest rate | 5.444% | 5.400% | −4.4 bp |
| WA indexed LTV | 60.333% | 60.317% | −0.02 percentage points |
| London share of pool | 16.15% | 16.42% | +0.27 percentage points |

The "as reported" London figure counts exact "London" only. A report built with SUMIFS, as in Chapter 16's Strats sheet, already includes "london" and shows 16.24%; either way, cleaning raises it to 16.42%.

- Rate: replace 0.537 with 0.0537. One loan out of 1,200 moves the pool's WA rate by 4.4 basis points.
- Indexed LTV: replace ASH100357's stored 64.00% with 46.38%. The effect is small because the loan is small relative to the pool, but the loan's own LTV bucket changes from ">60% to 70%" to "50% or less", so the strat changes.
- London: adding the three variant loans (£222,329 + £144,275 + £293,586 = £660,190) raises London's share.

#### Reading the result

One wrong rate moves the pool's WA rate by 4.4 bp; one wrong LTV hardly moves the WA LTV but changes the strat.

#### Checking your answer

Rate: (0.537 − 0.0537) × £218,596 ÷ £240,000,000 = 0.044%, the 4.4 bp change. London: £660,190 ÷ £240m = 0.275 points, the change from 16.15% to 16.42%.

#### Mistakes people make on this question

- Correcting the original file without keeping the as-reported figure: the comparison is the answer.
- **Mixing the corrections.** Correcting the rate when computing the LTV (or the reverse) does no harm here, but in general each metric's "corrected" figure must name the corrections it includes.
- **Reporting 16.24% as "as reported" without saying which tool produced it.** SUMIFS ignores case and already includes "london"; an exact match does not.

#### Trade-offs and going further

Small pool-level changes can still matter: a change of a few basis points in WA rate alters excess spread forecasts, and a loan in the wrong LTV band changes a table investors read.

- **Going further.** Recompute the excess spread of Chapter 8 with the corrected WA rate: 5.400% instead of 5.444% lowers the pool yield by 4.4 basis points, about £8,800 a month.

### Question 5: exceptions log

#### What the question asks

> **Exceptions log (10 marks).** Write an exceptions log for your findings, with impact, owner and proposed action.

In plain words: turn the findings of Questions 2 and 3 into a log a team can act on: what was found, what it affects, who fixes it, and what they will do.

#### The plan

1. **One row per problem**, not per loan, so that the owner sees one task per cause.
2. **Impact in the reader's terms**: which report, file or number is wrong.
3. **An owner who can fix it at source**: the servicer, the data team, valuations.
4. **An action that prevents a repeat**, not only a correction.

#### Step by step

| ID | Loan and field | Impact | Owner | Action |
|---|---|---|---|---|
| DQ-01 | ASH100213 / ASH100888, `loan_id` | Two loans misidentified in the regulatory file; lookups and joins wrong | Data team and servicer | Correct the ID; find why the extract mislabelled it |
| DQ-02 | ASH100500 / ASH100501, `current_balance` | Two balances and LTVs wrong by £1,250 | Servicing | Servicer to confirm and re-run the extract |
| DQ-03 | ASH100357, `indexed_ltv` | Wrong LTV bucket in the strat | Data team | Recalculate LTV from source fields |
| DQ-04 | ASH100602, `interest_rate` | WA rate overstated by 4.4 bp | Servicer | Confirm 5.37% from the mortgage system |
| DQ-05 | ASH100734, `maturity_date` | Maturity date wrong in the loan-level file and in any maturity strat; the stored remaining term (278 months) agrees with 2049, so models that use it are unaffected | Servicer | Confirm the maturity date (expected 31 August 2049) |
| DQ-06 | ASH101045, `indexed_valuation` | LTV cannot be verified | Valuations | Obtain the valuation; flag until then |
| DQ-07 | Three loans, `region` | London understated by £660,190 | Data team | Map the variants; add a mapping table |
| DQ-08 | ASH100104, `current_balance` | Implausible balance for a repayment loan | Servicer | Ask whether arrears or fees were capitalised, or the original balance is wrong |

(The reconciliation finding, DQ-02, is not one of the seven tape errors: it is a difference against the servicing system.)

#### Reading the result

Eight rows: the seven tape errors and the reconciliation difference.

#### Checking your answer

Every finding of Questions 2 and 3 appears once, with a named owner.

- **Every finding appears once.** The duplicate ID, the reconciliation difference and six other tape errors: eight rows, DQ-01 to DQ-08.

#### Mistakes people make on this question

- **No owner.** An exception without an owner is never closed.
- **"Fixed" as the action.** The log must say what was changed and where, so that next month's tape can be checked for the same problem.

#### Trade-offs and going further

A shared log (spreadsheet or ticket system) is easy to follow; tracking items to closure takes discipline, so review it at each month-end.

- **Going further.** Add a "date raised" and "date closed" column; the time to close each item becomes a measure the team can report.

### Question 6: linking questions

#### What the question asks

> **Linking questions (15 marks).**
>
> a. The WA interest rate in the investor report is used to calculate the pool's weighted average yield and the deal's excess spread. If the 53.7% rate were not corrected, would the cash paid to noteholders change? Explain.
> b. What would the duplicate loan ID do to the loan-level regulatory file?
> c. Why might a repayment loan's balance be higher than its original balance? What would you ask the servicer?

In plain words: three short explanations that link data errors to their consequences: for the cash, for the regulatory file, and for a borrower's balance.

#### The plan

1. **For each part, separate what the error changes from what it does not**: reports and files against cash.
2. **Give the consequence in one or two sentences**, then the action.
3. **For (c), list the possible causes before the question to the servicer**, so the question is specific.

#### Step by step

a. **No.** The cash paid to noteholders depends on what borrowers actually pay, which is collected by the servicer and run through the waterfall. The 53.7% is a **reporting** error in the tape, not a cash error. But it would overstate the pool's yield and excess spread in the investor report and in any cash flow model that uses the tape, so investors and rating agencies would see the deal as stronger than it is.

b. The regulatory file requires a unique identifier for each loan. A duplicate would be rejected by validation or, worse, accepted with two different loans under one ID, so the file would misreport one loan's characteristics and omit ASH100888 entirely. It must be fixed before submission.

c. Possible reasons: arrears, fees or interest **capitalised** (added to the balance) under a forbearance arrangement; a **further advance** not reflected in the original balance; or a wrong original balance. Ask the servicer for the loan's transaction history since origination, and whether any capitalisation or further advance has been made.

#### Reading the result

Reporting errors do not move cash, but they mislead the people who price and supervise the deal.

#### Checking your answer

Each answer names a consequence and an action.

- **Test (a) against the waterfall.** The waterfall uses cash collected, not the tape's rates: Chapter 9's revenue receipts come from the servicer's collections report.

#### Mistakes people make on this question

- Saying the 53.7% rate changes the cash waterfall.
- **For (b), saying the file is "slightly wrong".** A duplicate key is rejected by validation or misreports two loans; it must be fixed before submission.
- **For (c), asking the servicer "is this right?"** Ask for the transaction history since origination, and whether arrears, fees or a further advance were capitalised.

#### Trade-offs and going further

Correcting reports quickly protects credibility; investigating causes (capitalisation, further advances) protects the next report.

- **Going further.** For (a), say which investors would be misled most: those holding Class B, whose protection depends most on excess spread.

### Question 7: code

#### What the question asks

> **Code (5 marks).** Write the SQL query or pandas code you would use to find loans in the servicer extract that are missing from the tape.

In plain words: code that lists the loans in the servicer's file that the tape does not contain.

#### The plan

1. **Choose an anti-join**: keep the servicer rows with no match in the tape.
2. **Write it in the tool you know best**, SQL or pandas.
3. **Run it and name the result.**

#### Step by step

```sql
SELECT s.loan_id, s.current_balance
FROM dbo.servicer_balances AS s
LEFT JOIN dbo.loan_tape AS t ON t.loan_id = s.loan_id
WHERE t.loan_id IS NULL;
```

```python
missing = serv[~serv["loan_id"].isin(tape["loan_id"])]
```

Both return ASH100888, £73,590.

#### Reading the result

One loan, ASH100888, £73,590: the loan hidden under the duplicate ID.

#### Checking your answer

Reverse the direction (tape loans missing from the servicer): none, because every tape ID exists in the servicer file.

#### Mistakes people make on this question

- **An inner join with `WHERE t.loan_id IS NULL`**, which can never be true.
- **`isin` the wrong way round**, which lists tape loans missing from the servicer (none).

#### Trade-offs and going further

`NOT EXISTS` is equivalent and often faster in SQL Server; `EXCEPT` is shortest but returns only the key columns.

- **Going further.** `SELECT loan_id FROM dbo.servicer_balances EXCEPT SELECT loan_id FROM dbo.loan_tape;` returns the same loan in one line (Chapter 17, Section 17.14).

### Question 8: summary

#### What the question asks

> **Summary (10 marks).** In no more than 150 words, summarise for your manager what you found and whether the tape can be used.

In plain words: a summary of at most 150 words for a manager who must decide whether the tape can be published.

#### The plan

1. **Lead with the result**: totals agree, but loan-level checks found problems.
2. **List the problems with numbers**, grouped so the manager can count them.
3. **Give the consequence and a recommendation**: publish or not, and what is needed first.

#### Step by step

> I've checked the 30 June tape. Totals agree with the servicer (1,200 loans, £240m), but loan-level checks found problems. A £1,250 overpayment sits on the wrong loan, and the tape has seven data errors: a duplicated loan ID (ASH100888 is labelled ASH100213), a 53.7% interest rate that overstates the WA rate by 4.4 bp, a wrong maturity date, a wrong stored LTV, a missing valuation, three non-standard London region values and a repayment loan above its original balance. None changes the cash waterfall, but several would misstate the investor report and the regulatory file. I recommend we don't publish until the servicer confirms the corrections; the exceptions log, with owners, is attached.

#### Reading the result

The manager can decide in one read: do not publish until the corrections are confirmed.

#### Checking your answer

Count the words (about 125); check every number against the workbook.

- **Every number matches the workbook**: 1,200 loans, £240m, £1,250, 53.7%, 4.4 bp.

#### Mistakes people make on this question

- Listing every check performed instead of the findings.
- **No recommendation.** The manager asked whether the tape can be used; the summary must answer.
- **Over 150 words.** The limit is part of the question.

#### Trade-offs and going further

A firm recommendation helps the manager; stating the uncertainty (servicer confirmation needed) keeps it honest.

- **Going further.** Write the two-sentence version for a senior manager: the recommendation and the one number that matters most.

## Extension questions

**E1.** After correcting ASH100357's indexed LTV, what changes in the indexed LTV stratification table?

**E2.** For each of the seven errors, propose one control that would stop it recurring.

**E3.** Write the pandas code for the reconciliation in question 2, using `merge` with `indicator=True`.

### Solutions

#### E1: the LTV strat after the correction

**What the question asks.** How the indexed LTV stratification changes when ASH100357's LTV is corrected.

**The plan.** Move the loan from its old band to its new one; recompute the two bands.

**Step by step.** The loan (£217,068) moves from "over 60% to 70%" to "50% or less". The first band becomes **326 loans, £64,177,228**; the ">60% to 70%" band becomes **244 loans, £47,838,481**.

**Reading the result.** One loan, two bands changed; every other band is untouched.

**Checking the answer.** The totals stay at 1,200 loans and £240,000,000.

**Mistakes to avoid.** Recomputing the whole strat by hand: change the input, let the formulas move the loan.

**Trade-offs.** Strats built on recalculated LTVs would never have shown the wrong band; stored values are only as good as the system that copied them.

#### E2: a control for each error

**What the question asks.** One preventive control for each of the seven errors.

**The plan.** For each error, ask where it entered and what would stop it there.

**Step by step.**

| Error | Control |
|---|---|
| Duplicate ID | Uniqueness check before release; primary key in the database |
| Wrong stored LTV | Calculate LTV in the tape build instead of storing a copied value |
| Rate slip | Range check at entry in the mortgage system and in the tape build |
| Maturity date | Derive maturity from origination and term, or check it automatically |
| Missing valuation | Completeness check; documented fallback (for example, original valuation indexed from origination) |
| Region variants | Mapping table, with unmapped values rejected |
| Balance above original | Consistency check by product; servicer confirmation for capitalisations |

**Reading the result.** Most controls move the check earlier, to where the data is created.

**Checking the answer.** Each control would have stopped its error in this month's tape.

**Mistakes to avoid.** "Be more careful" is not a control.

**Trade-offs.** Controls at source are cheapest per error but need the servicer's systems to change; checks in the tape build are under your control and catch everything that slips through.

#### E3: the reconciliation in pandas

**What the question asks.** The loan-level reconciliation of Question 2 with `merge`.

**The plan.** Outer merge on `loan_id` with an indicator; compute the difference; keep exceptions.

**Step by step.**

```python
rec = tape[["loan_id", "current_balance"]].merge(
    serv[["loan_id", "current_balance"]],
    on="loan_id", how="outer",
    suffixes=("_tape", "_servicer"), indicator=True)
rec["difference"] = (rec["current_balance_tape"]
                     - rec["current_balance_servicer"])
print(rec[(rec["_merge"] != "both")
          | (rec["difference"] != 0)])
```

1. `how="outer"` keeps keys from both sides.
2. `indicator=True` adds `_merge`: "both", "left_only" or "right_only".
3. The filter keeps unmatched keys and matched keys with a difference.

**Reading the result.** Four rows: ASH100888 (right only), the second ASH100213 row (−£207,390), ASH100500 and ASH100501. The first ASH100213 row matches the servicer exactly, so the filter drops it.

**Checking the answer.** Without the filter, both ASH100213 rows appear, each matched to the servicer's single £280,980 row: the duplicate's effect.

**Mistakes to avoid.** Leaving out `validate`: here, `validate="one_to_one"` would stop the merge and point straight at the duplicate.

**Trade-offs.** Running with `validate` first, then without it once the duplicate is understood, gives both the alarm and the full picture.

## Marking guide

| Question | Full marks need |
|---|---|
| 1 | All six figures; says totals are not enough |
| 2 | All four lines and the two causes |
| 3 | Seven errors, each with loan, field, problem and method; exact matching for regions |
| 4 | Before and after for all three metrics |
| 5 | Impact, owner and action for every line |
| 6 | Reporting versus cash distinction; regulatory consequence; capitalisation |
| 7 | A working anti-join |
| 8 | Clear, short, numbers right, a recommendation |

**Score guide:** 85+ ready; 70 to 84, reread Chapter 15; below 70, work through the checks in Chapters 16 to 18 with the tape open, then retake.

> **Tips**
>
> - In a real test, you will not be told how many errors there are. Run every rule category, then stop when the rules are exhausted, not when you reach a number.
> - Always separate **what you found** from **what you assume**. "The rate is almost certainly 5.37%; to be confirmed with the servicer" is the professional phrasing.
