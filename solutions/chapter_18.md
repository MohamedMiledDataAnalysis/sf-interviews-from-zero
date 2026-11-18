# Chapter 18: Python for structured finance: pandas at work

## Corrections

### Exercise 1: validate="one_to_one"

#### What the question asks

> Add `validate="one_to_one"` to the merge in `ch18_04_reconciliation.py`. What happens, and why?

In plain words: the reconciliation script joins the loan tape to the servicer's balances on `loan_id`. You must add one argument that tells pandas what shape the join should have, run the script, and explain the outcome.

The exercise uses `merge` with `how="outer"` and `indicator=True` (Section 18.5), the uniqueness dimension of data quality and the duplicated loan ID found in Chapter 15 (Sections 15.1 and 15.3), and Python's error messages (Section 18.1).

#### The plan

1. **Read what the argument promises.** `validate` states the expected relationship between the two tables; pandas checks it before joining.
2. **Run the merge with the argument** and read the message, word by word.
3. **Find the rows the message points to** and explain why they break the promise.
4. **Show what the merge does without the argument,** to see what the check protects you from.

#### Step by step

**Step 1: the argument.** `validate="one_to_one"` tells pandas: every `loan_id` appears at most once in the left table (the tape) and at most once in the right table (the servicer). If either is false, pandas stops with an error instead of joining.

**Step 2: run it.** Open `python/ch18_04_reconciliation.py` and change the merge to:

```python
rec = tape[["loan_id", "current_balance"]].merge(
    serv[["loan_id", "current_balance"]], on="loan_id",
    how="outer", suffixes=("_tape", "_servicer"),
    indicator=True, validate="one_to_one")
```

- `tape[["loan_id", "current_balance"]]` keeps the two columns needed from the tape; the double brackets select a list of columns.
- `on="loan_id"` is the key; `how="outer"` keeps loans found on either side.
- `suffixes` renames the two balance columns so they can be told apart; `indicator=True` adds a `_merge` column saying where each row was found.
- `validate="one_to_one"` is the new argument.

Running the script stops with:

```
pandas.errors.MergeError: Merge keys are not unique in
left dataset; not a one-to-one merge
```

followed by "Duplicates in left: … ASH100213".

**Step 3: find the duplicate.**

```python
dups = tape[tape["loan_id"].duplicated(keep=False)]
print(dups[["loan_id", "origination_date",
            "current_balance"]])
```

- `duplicated(keep=False)` marks every row whose ID appears more than once, not only the second occurrence.
- The output shows two rows for **ASH100213**: one originated 30 April 2024 with £280,980, one originated 30 April 2020 with £73,590.

Two different loans share one ID. Chapter 15 found the cause: the 2020 loan is really **ASH100888**, mislabelled in the extract.

**Step 4: what happens without the check.** Without `validate`, the merge runs and returns **1,201** rows: the servicer's single ASH100213 row (£280,980) is matched to *both* tape rows, and ASH100888 appears as `right_only`. One match is correct; the other shows a "difference" of −£207,390 that is not a balance error at all.

#### Reading the result

- **The merge stops because the key is not unique on the tape side.** That is exactly what `validate` is for: it refuses to produce a result that rests on a broken assumption.
- **The error is a finding, not a nuisance.** It is the duplicate ID of the exceptions log (DQ-01 in Practice test 2), found at the moment the join is attempted.
- **The fix belongs in the data**, not in the code: correct the second ASH100213 to ASH100888 at source, then rerun. The merge will then pass validation and report only the two real £1,250 differences.

- **What `validate` cannot do.** It checks the shape of the join, not the values: two loans with the right IDs but swapped balances would pass. That is why the reconciliation also compares balances row by row, which is the next step of the script.

#### Checking your answer

- **Check the right-hand table separately.** `serv["loan_id"].duplicated().sum()` returns **0**: the servicer's IDs are unique, so the problem is on the left only, as the message says.
- **Check the row counts.** Tape 1,200 rows, 1,199 distinct IDs: one duplicate. The unvalidated merge's 1,201 rows = 1,200 matched rows (two of them for ASH100213) + 1 `right_only` row.
- **Check that validation passes when the data are right.** On a copy with the duplicate removed (`tape.drop_duplicates("loan_id")`), the validated merge runs and returns 1,200 rows: 1,199 `both` and 1 `right_only` (ASH100888).

- **Check the message is reproducible.** Run the cell twice: the same error, naming the same loan. A check that fails the same way every time is a reliable control; one that fails at random points to a different problem.

#### Mistakes people make on this exercise

- **Dropping the duplicate to make the error go away.** `drop_duplicates` keeps the first ASH100213 and deletes the other loan from the reconciliation: a real loan of £73,590 disappears from the check.
- **Reading only the first line of the error.** "Duplicates in left" names the table and the key; the next line names the loan. Read the whole message before changing anything.
- **Validating on the wrong side.** `validate="many_to_one"` would pass on the tape side (duplicates allowed in the left table) and hide the problem. Choose the validation that matches what the data *should* be: one row per loan on each side.
- **Leaving `validate` out of production code.** The check costs almost nothing in time; without it, a duplicated key doubles amounts silently every month.

- **Catching the error and carrying on.** Wrapping the merge in `try`/`except` and printing "merge failed" hides the message that names the loan; if you catch it, print the error itself and stop.

#### Trade-offs and going further

- **Fail fast or report.** `validate` stops the whole script, which is right for a monthly control: nothing should be published on a broken key. A reporting script might instead list the duplicates and continue; then the check must write them to the exceptions log, or they are forgotten.
- **Validate in pandas or in the database.** In SQL Server, a primary key on `loan_id` (Section 17.9) refuses the duplicate when the data are loaded. A database constraint catches the problem earlier, before anyone runs a merge.
- **Going further.** Add `assert tape["loan_id"].is_unique, "Duplicate loan IDs in the tape"` before the merge. The script then stops with your own message, which a colleague will understand without knowing `merge`.

- **`validate` in every merge.** The four values (`one_to_one`, `one_to_many`, `many_to_one`, `many_to_many`) cover every case; writing the one you expect documents the join for the next reader as well as checking it.

### Exercise 2: the smallest month 2 loss that empties the reserve

#### What the question asks

> Use `run_waterfall` to find the smallest month 2 loss, in whole thousands of pounds, at which the reserve fund ends at zero.

In plain words: in Ashcombe's month 2 the loss was £260,000 and the reserve ended above zero. You must find how large the loss would have to be, rounded to the next £1,000, for the reserve to be completely used up, using the waterfall function of the companion repository.

The exercise uses the waterfall function `run_waterfall` (Section 18.6), loops and functions (Section 18.1), the revenue waterfall and the PDL of Chapter 9 (Sections 9.2 and 9.4), and the month 1 and month 2 inputs of Chapter 9's worked example (Section 9.5).

#### The plan

1. **Run month 1** to get the opening balances of month 2, because month 2 must start where month 1 ended.
2. **Wrap month 2 in a small function of the loss,** so that only the loss changes from one run to the next.
3. **Raise the loss in steps of £1,000** until the closing reserve reaches zero.
4. **Explain the answer with arithmetic,** so that it does not depend on the loop.

#### Step by step

**Step 1: import the function and run month 1.**

```python
import sys
sys.path.append("python")   # notebook only
from ch18_05_waterfall import run_waterfall
```

```python
m1 = run_waterfall(236_900_000, 203_300_000, 33_600_000,
                   2_400_000, 1_045_000, 2_880_000, 52_000)
```

- `sys.path.append("python")` tells a notebook started in the companion folder where to find the script.
- The arguments are month 1's opening pool, Class A, Class B, reserve, revenue receipts, principal receipts and loss, in the order the function expects.
- `m1` is a dictionary; `m1["Closing reserve"]` is £2,383,271.

**Step 2: month 2 as a function of the loss.**

```python
def month2(losses):
    return run_waterfall(m1["Closing pool"], m1["Closing Class A"],
                         m1["Closing Class B"], m1["Closing reserve"],
                         1_038_000, 3_150_000, losses)
```

- `def month2(losses):` defines a function with one input.
- The four opening balances come from `m1`; revenue £1,038,000 and principal £3,150,000 are month 2's receipts.
- `month2(260_000)["Closing reserve"]` reproduces the chapter: £2,163,148.

**Step 3: the search.**

```python
loss = 260_000
while month2(loss)["Closing reserve"] > 0:
    loss += 1_000
print(loss, month2(loss - 1_000)["Closing reserve"])
```

- Start at the real loss, £260,000.
- `while … > 0:` repeats the indented line as long as the reserve is still positive.
- `loss += 1_000` raises the loss by £1,000 each time.
- The output is `2424000 148`: at **£2,424,000** the reserve is zero; at £2,423,000 it was still **£148**.

#### Reading the result

- **Month 2 can absorb a loss of up to £2,423,148 before the reserve is exhausted.** The smallest whole-thousand loss that empties it is **£2,424,000**.
- **The arithmetic behind it:** in month 2, after items 1 to 5 there is excess spread of £39,877 plus the opening reserve of £2,383,271, a total of £2,423,148 available for item 6 (the Class B PDL) and item 7 (the reserve). A loss of exactly that size is cleared in full and leaves nothing for the reserve.
- **Above that, the PDL is not cleared.** At £2,424,000, £852 of PDL stays outstanding, and Class B is exposed for the first time.

- **A stress question in one line.** "How big a loss can the deal take this month before the junior notes are exposed?" is one of the first questions a surveillance analyst asks after a large repossession. The function answers it in seconds for any month, as long as the opening balances are right.

- **The month's revenue matters too.** If month 2's revenue had been lower, the excess spread would have been smaller and the threshold lower by the same amount: the reserve and the excess spread are one pot for item 6.

#### Checking your answer

- **Run the exact figure.** `month2(2_423_148)["Closing reserve"]` returns **0** and `month2(2_423_148)["PDL outstanding"]` returns **0**: the loss is cleared and the reserve is empty.
- **Run one pound more.** `month2(2_423_149)["PDL outstanding"]` returns **1**: one pound of loss is left on the PDL.
- **Compare with Excel.** Chapter 16's Waterfall sheet with B9 = 2,423,148 shows B28 (closing reserve) = 0, and Goal Seek on B28 gives the same loss.

- **Check the loop's last two values.** Print `month2(loss)["Closing reserve"]` for `loss` = 2,423,000 and 2,424,000: £148 and £0. The answer is the first value at which the reserve is zero, and the value just before it must still be positive.

#### Mistakes people make on this exercise

- **Starting month 2 from the original balances.** Calling `run_waterfall(236_900_000, …)` for month 2 uses month 1's opening position and a full reserve of £2,400,000; the loop then stops at £2,429,000, £5,000 too high.
- **Answering £2,383,271.** That is the opening reserve alone; it forgets that month 2's excess spread also clears PDL before the reserve is touched.
- **An infinite loop.** Writing `while month2(loss)["Closing reserve"] > 0:` without `loss += 1_000` never ends. In a notebook, stop it with the square Stop button.
- **Stopping at the first loss that makes the reserve fall.** Any loss above the excess spread reduces the reserve; the question asks when it reaches zero.

- **Comparing with `== 0` on a calculated reserve.** Here the waterfall works in whole pounds, so `> 0` is safe. In a model with fractions of a pound, a reserve of 0.0000001 counts as positive; round to pence before comparing.

#### Trade-offs and going further

- **A loop or a formula.** The loop is simple and works for any waterfall, however complicated. The formula (excess spread + reserve) is exact and instant, but only because Ashcombe's waterfall is simple; with triggers or several PDLs the loop is safer.
- **Steps of £1,000 or bisection.** The loop runs about 2,164 times; a bisection (halve the range each time) finds the exact pound in about 22 runs. For one question either is fine; inside a model run thousands of times, bisection matters.
- **Going further.** Find the loss at which Class A, not only the reserve, is affected in month 2: the Class A PDL starts when the loss exceeds Class B's balance plus what revenue can clear.

- **Copy the month or recompute.** The function recomputes everything from the inputs, so each run is independent and the loop can try any loss. A spreadsheet that copies a month's block can do the same with Goal Seek, but only one cell at a time.

### Exercise 3: 3+ months arrears by month

#### What the question asks

> Using the history file, calculate the 3+ months arrears percentage of the pool for each month from January to June.

In plain words: the history file has one row per loan per month. For each month you must add the balances of the loans 3 or more months behind and divide by that month's pool, giving the ratio that investor reports show and that triggers test.

The exercise uses reading a CSV and filtering rows (Sections 18.2 and 18.4), `where` and `groupby` (Section 18.3), the history file of Section 18.8, and the arrears ratio of Chapter 10 (Section 10.6).

#### The plan

1. **Keep only the active loans** in each month, because redeemed loans are no longer in the pool.
2. **Make a column that equals the balance when a loan is 3+ months behind, and 0 otherwise.** Summing it gives the arrears balance.
3. **Group by month** and sum both the arrears balance and the pool.
4. **Divide and format**, then check June against the tape.

#### Step by step

**Step 1: load and filter.**

```python
import pandas as pd
hist = pd.read_csv("data/ashcombe_loan_history.csv")
a = hist[hist["status"] == "Active"]
```

- `pd.read_csv` loads the file: 7,426 rows, one per loan per month.
- `hist["status"] == "Active"` is True for loans still in the pool; the brackets keep those rows only.

**Step 2: the arrears balance column.**

```python
late = a["arrears_months"] >= 3
a = a.assign(b3=a["current_balance"].where(late, 0))
```

- `late` is True for each row 3 or more months in arrears.
- `.where(late, 0)` keeps the balance where `late` is True and puts 0 elsewhere.
- `assign(b3=…)` adds it as a new column named `b3`, without changing the original table.

**Step 3: group and divide.**

```python
g = a.groupby("month_end")[["b3", "current_balance"]].sum()
pct = g["b3"] / g["current_balance"]
print(pct.map("{:.2%}".format))
```

- `groupby("month_end")` makes one group per month; `.sum()` adds the two columns within each.
- `pct` divides the arrears balance by the pool, month by month.
- `map("{:.2%}".format)` prints each ratio as a percentage with two decimals.

The output:

| Month | 3+ arrears balance (£) | Pool (£) | Ratio |
|---|---:|---:|---:|
| January | 1,878,639 | 255,405,739 | 0.74% |
| February | 3,173,892 | 251,652,360 | 1.26% |
| March | 3,170,994 | 248,689,232 | 1.28% |
| April | 3,692,131 | 245,462,684 | 1.50% |
| May | 3,562,828 | 242,582,325 | 1.47% |
| June | 4,648,983 | 240,000,000 | **1.94%** |

#### Reading the result

- **Serious arrears more than doubled in six months**, from 0.74% to 1.94% of the pool, while the pool itself shrank by 6%.
- **The rise is not smooth.** The largest monthly jumps were February (+0.52 percentage points) and June (+0.47); May fell slightly in balance even though the count rose from 19 to 21 loans.
- **The count tells the same story**: 10 loans in January, 24 in June. A surveillance analyst would explain the June jump loan by loan in the commentary (Chapter 14) and compare the ratio with the deal's trigger.

- **Against a trigger.** Many UK deals set a 3+ months arrears trigger at a level such as 5% of the pool. At 1.94% Ashcombe is well inside it; at the rate of the last six months (about +0.2 percentage points a month) it would take more than a year to reach 5%. An analyst says both: the level and the distance to the trigger.

#### Checking your answer

- **June against the tape.** The tape is the June position: 24 loans 3+ months in arrears, £4,648,983, on a pool of £240,000,000: 1.94%. Same as the history.
- **The pool totals.** January's £255,405,739 and June's £240,000,000 are the history's active balances; June matches the tape total exactly.
- **Another tool.** The Excel History sheet with SUMIFS by month and arrears gives the same six ratios (Chapter 16), and so does a SQL `GROUP BY month_end` with a `CASE` sum (Chapter 17).

- **One month by hand.** For January, filter the history to 31 January and active loans, sum the balances where `arrears_months >= 3` (£1,878,639) and divide by the month's total (£255,405,739): 0.74%, as the table shows.

#### Mistakes people make on this exercise

- **Counting loans instead of balance.** 24 ÷ 1,200 = 2.00% in June: close, but the report's ratio is by balance, and in another month the two can differ widely.
- **`> 3` instead of `>= 3`.** That excludes loans exactly 3 months behind; June then shows a lower ratio and the trigger test is wrong.
- **Leaving out the status filter.** Here it makes no difference to the sums, because redeemed rows have a balance of zero, but any calculation that counts rows (a loan count, an average balance) would include loans no longer in the pool.
- **Dividing by the original pool.** £4,648,983 ÷ £255,405,739 = 1.82%: that is cumulative-style arithmetic; an arrears ratio uses the current month's pool.

- **Forgetting to sort before reading the result.** `groupby` sorts the months as text, which works here because the dates are written year-month-day. With dates written day/month/year, January 2027 would print before February 2026; parse the column with `pd.to_datetime` first.

#### Trade-offs and going further

- **`where` or a filter.** Filtering to late loans and grouping gives the arrears balance but loses the pool total, so a second group-by is needed for the denominator. `where` keeps every row and gives both sums in one pass.
- **Ratio or trend.** A single month's ratio answers "are we below the trigger?"; the six-month series answers "where are we heading?". Reports show both, and a chart of the series (Chapter 16, *Charts that explain*) makes the trend obvious.
- **Going further.** Add the number of loans with `n3=late.astype(int)` in the same `assign`, and sum it in the group-by. The six counts are 10, 16, 18, 19, 21 and 24.

- **History file or monthly tapes.** The history file has six months in one table, which makes this a single group-by. With six separate monthly tapes, read them in a loop, add a `month_end` column to each and `concat` them first (Section 18.12, *Many monthly files*).
