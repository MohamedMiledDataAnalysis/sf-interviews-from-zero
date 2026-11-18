# Chapter 18: Python for structured finance: pandas at work

## Corrections

### Exercise 1: WA interest rate by rate type

#### What the question asks

> Calculate the balance-weighted average interest rate for each `rate_type`, using `groupby` and `sum`.

In plain words: the same figure as SQL Exercise 4 of Chapter 17, in pandas: one weighted average rate for Fixed, SVR and Tracker loans, where each loan counts in proportion to its balance.

The exercise uses the weighted average in pandas (Section 18.3), `groupby` with `sum` (Section 18.3), `assign` to add a column without changing the original DataFrame (Section 18.12), and the weighted average of Chapter 10 (Section 10.1).

#### The plan

1. **Compute each loan's weight** as rate × balance, a new column.
2. **Group by `rate_type` and add up** both the weighted column and the balances.
3. **Divide the two sums** in each group: the weighted average.
4. **Check it** against the SQL result and against the pool's WA rate.

#### Step by step

**Step 1: load the tape.**

```python
import pandas as pd
tape = pd.read_csv("data/ashcombe_loan_tape.csv")
```

- `read_csv` reads the 1,200 loans into a DataFrame; the path is relative to the repository root, where the scripts run.

**Step 2: the weighted column and the group sums.**

```python
g = (tape.assign(w=tape["interest_rate"] * tape["current_balance"])
         .groupby("rate_type")[["w", "current_balance"]]
         .sum())
```

- `tape["interest_rate"] * tape["current_balance"]` multiplies the two columns row by row, like SUMPRODUCT's inner step.
- `.assign(w=…)` returns a copy of `tape` with the new column `w`; `tape` itself is unchanged.
- `.groupby("rate_type")` splits the rows by rate type; `[["w", "current_balance"]]` keeps the two columns to add; `.sum()` adds them in each group.
- `g` has one row per rate type and two columns.

**Step 3: divide.**

```python
wa = g["w"] / g["current_balance"]
print(wa.map("{:.3%}".format))
```

- Dividing two Series divides row by row, matched on the index (the rate type).
- `.map("{:.3%}".format)` formats each value as a percentage with three decimals, for display only.

The output:

```
rate_type
Fixed      5.175%
SVR        7.247%
Tracker    5.245%
```

#### Reading the result

- **SVR loans pay the most, 7.25%**, as in SQL: the lender's standard variable rate, paid by borrowers whose deal has ended.
- **Fixed is overstated by the 53.7% keying error** on ASH100602 (Chapter 15). Exercise 6 corrects it.
- **Three tools, one figure.** Excel (SUMPRODUCT), SQL (two SUMs) and pandas (`groupby` and `sum`) give the same 5.175%, 7.247% and 5.245%. In an interview, saying that you checked one tool against another is worth as much as the number.
- **The figures are for a report, the precision is for checking.** Three decimals of a percent (5.175%) are enough to compare tools; a report shows two (5.17%). Keep the full value in the data and format only for display.

#### Checking your answer

- **The groups average to the pool.**

```python
print(g["w"].sum() / g["current_balance"].sum())
```

prints 0.05444…, the pool's 5.444% (Section 18.3).

- **The SQL result.** Chapter 17, Exercise 4 returns the same three figures.
- **Sizes.** `g["current_balance"]` shows £169,638,911, £29,797,202 and £40,563,887, which add to £240,000,000.
- **One group by hand.** `t = tape[tape["rate_type"] == "SVR"]`, then `(t["interest_rate"] * t["current_balance"]).sum() / t["current_balance"].sum()` returns 0.07247, the SVR row.

#### Mistakes people make on this exercise

- **`tape.groupby("rate_type")["interest_rate"].mean()`.** It gives the simple average (Fixed 5.171%), not the weighted one.
- **Summing the rates and the balances separately, then multiplying.** `g_rate.sum() * g_bal.sum()` is meaningless; the product must be taken row by row, before the sum.
- **Adding `w` with `tape["w"] = …`.** It works, but changes `tape` for every later cell; in a notebook, a column that appears from an earlier cell is a common source of confusion. `assign` keeps the original clean.
- **Forgetting the brackets around the column list.** `groupby("rate_type")["w", "current_balance"]` with single brackets raises an error in recent pandas; a list of columns needs double brackets.
- **Ignoring missing rates.** If some rates were blank, `sum()` would skip their products but keep their balances in the denominator, and the average would be pulled down. Weight only the loans with a value, as Section 18.3 shows, and report how much balance was left out.

#### Trade-offs and going further

- **Sum and divide, or `np.average`.** `tape.groupby("rate_type").apply(lambda d: np.average(d["interest_rate"], weights=d["current_balance"]))` reads closer to the definition, but loops over the groups in Python; the sum-and-divide method is vectorised and stays fast on a tape of a million loans.
- **One function for every weighted average.** Section 18.3 wraps the pool version in a function, `wa(column)`; adding a `by` argument that runs the `groupby` makes the same function serve rate, LTV and term by any group.
- **Going further.** Group by two columns, `groupby(["rate_type", "repayment_type"])`: SVR interest-only loans pay the most, 7.26%.
- **`pivot_table` for the same result.** `tape.assign(w=…).pivot_table(index="rate_type", values=["w", "current_balance"], aggfunc="sum")` gives the same two sums; it is handier when a second grouping goes across the columns.
- **Tiny differences between tools.** Excel, SQL Server and pandas can disagree in the sixth or seventh decimal, because each adds floating-point numbers in a different order. Compare results rounded to the precision you report (three decimals of a percent here), not to the last digit.

### Exercise 2: a balance-size strat with pd.cut

#### What the question asks

> Build a balance-size strat with `pd.cut` and the buckets of Chapter 16, exercise 2. Assert that it ties to the tape.

In plain words: the five balance bands of the Excel strat (£100,000 or less, then up to £200,000, £300,000, £500,000, and above), built in pandas, with code that stops if the strat does not add up to the pool.

The exercise uses `pd.cut` and `groupby().agg()` for strats (Section 18.3), `assert` for checks in code (Section 18.3), and the band convention of Chapter 10: "over the lower edge, up to and including the upper edge".

#### The plan

1. **Write the edges and labels** as lists, so the bands are visible at the top of the code.
2. **Assign each loan to a band** with `pd.cut`.
3. **Count and add up** each band with `groupby` and `agg`, and add the share of the pool.
4. **Assert** that the counts and balances tie to the tape.

#### Step by step

**Step 1: edges and labels.**

```python
import pandas as pd
tape = pd.read_csv("data/ashcombe_loan_tape.csv")
edges = [0, 100_000, 200_000, 300_000, 500_000, 10_000_000]
labels = ["£100k or less", ">£100k to £200k", ">£200k to £300k",
          ">£300k to £500k", "Over £500k"]
```

- Six edges make five bands. The last edge, £10,000,000, is above any loan, so the top band is open in practice.
- The underscores in `100_000` are only for reading; Python ignores them.

**Step 2: the bands.**

```python
tape["size_bucket"] = pd.cut(tape["current_balance"],
                             bins=edges, labels=labels)
```

- `pd.cut` puts each balance in the band `(lower, upper]`: a loan of exactly £100,000 goes in "£100k or less", as in Excel's `">"&B` and `"<="&C`.
- A balance outside every band (above £10m, or £0) would get `NaN`; the asserts below would catch it.

**Step 3: the strat.**

```python
size = (tape.groupby("size_bucket", observed=False)
            .agg(loans=("loan_id", "size"),
                 balance=("current_balance", "sum")))
size["pct_of_pool"] = size["balance"] / size["balance"].sum()
```

- `observed=False` keeps every band, even an empty one, so the table always has five rows.
- `.agg(loans=("loan_id", "size"), balance=("current_balance", "sum"))` names each output column and says how to compute it.
- The share divides each band by the strat's total.

**Step 4: the checks.**

```python
assert size["loans"].sum() == len(tape)
assert size["balance"].sum() == tape["current_balance"].sum()
print(size)
```

- Each `assert` is silent when true and stops the script with `AssertionError` when false.
- Comparing with `len(tape)` and the tape's own sum, not with typed numbers, keeps the check valid next month.

The output:

| size_bucket | loans | balance | pct_of_pool |
|---|---:|---:|---:|
| £100k or less | 125 | 10,205,405 | 4.25% |
| >£100k to £200k | 581 | 87,927,905 | 36.64% |
| >£200k to £300k | 340 | 82,154,579 | 34.23% |
| >£300k to £500k | 137 | 49,632,662 | 20.68% |
| Over £500k | 17 | 10,079,449 | 4.20% |

#### Reading the result

- **Excel, SQL and pandas agree band by band** (Chapter 16, Exercise 2; Chapter 17, Exercise 3). A strat built in one tool and checked in another is a strong control.
- **71% of the balance sits between £100,000 and £300,000**; the 17 loans over £500,000 hold 4.2% of the pool, and are the first place to look for single-loan concentration.
- **The table is ready for a report.** The labels match the Excel strat's wording, the bands are in order (a `pd.cut` result is an ordered category), and the shares add to 100%, so the DataFrame can be written to Excel with `to_excel` as it is.

#### Checking your answer

- **The asserts pass**, so the strat holds every loan and every pound.
- **Break it on purpose.** Change the last edge to 500,000: the 17 largest loans fall outside every band, `size["loans"].sum()` becomes 1,183, and the first assert stops the script. A check you have seen fail is a check you can trust.
- **One band by hand.** `((tape["current_balance"] > 100_000) & (tape["current_balance"] <= 200_000)).sum()` returns 581.

#### Mistakes people make on this exercise

- **A last edge below the largest loan** (£840,940): those loans get `NaN` and vanish from the strat without a message, unless an assert catches them.
- **`right=False`.** It switches the bands to `[lower, upper)`, so a loan of exactly £200,000 moves up a band, and the strat no longer matches Excel and SQL.
- **`observed=True` (the newer default).** An empty band disappears from the table, and next month's report has a different number of rows.
- **Labels in the wrong number.** Five bands need five labels and six edges; one label too many or too few stops `pd.cut` with a `ValueError`, which at least fails loudly.

#### Trade-offs and going further

- **Typed edges or derived edges.** Typed edges match the investor report and the prospectus; `pd.qcut(tape["current_balance"], 5)` makes five bands with equal numbers of loans, which is useful for analysis but not for a report, because the edges change every month.
- **Asserts or a check table.** `assert` stops a script, which is right for an automated monthly run; in a notebook for a manager, a printed "check = 0" row is friendlier.
- **Going further.** Add `wa_rate` to the strat with the two-sum method of Exercise 1. It varies little across bands, from 5.29% to 5.56%, and the highest figure, in the £200k to £300k band, contains the 53.7% keying error (Exercise 6): balance size does not drive rates in this pool.
- **A reusable function.** Wrapping Steps 2 to 4 in `def strat(df, column, edges, labels)` gives one tested function for every strat (LTV, balance, seasoning); the monthly report then calls it once per table, and a change to the method is made in one place.

### Exercise 3: validate="one_to_one"

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

### Exercise 4: the smallest month 2 loss that empties the reserve

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

### Exercise 5: the ten largest loans with cumulative share

#### What the question asks

> List the ten largest loans with their cumulative percentage of the pool (like SQL query 6.3). Hint: `sort_values`, then `cumsum()`.

In plain words: a top-ten list of loans by balance, with a running total expressed as a share of the whole pool, so that the last line says how much of the pool the ten largest loans hold.

The exercise uses `sort_values`, `head` and `cumsum` (Section 18.12), and the concentration measure of Chapter 10 (Section 10.10) that SQL query 6.3 computes with a running window (Section 17.7).

#### The plan

1. **Sort the tape by balance, largest first**, and keep ten rows.
2. **Compute the running total** of the ten balances.
3. **Divide by the whole pool**, not by the ten loans.
4. **Check the last line** against SQL query 6.3.

#### Step by step

**Step 1: the ten largest.**

```python
import pandas as pd
tape = pd.read_csv("data/ashcombe_loan_tape.csv")
cols = ["loan_id", "region", "current_balance"]
top = (tape.sort_values("current_balance", ascending=False)
           .head(10)[cols])
```

- `sort_values(…, ascending=False)` orders the 1,200 loans from largest to smallest.
- `.head(10)` keeps the first ten; `[cols]` keeps three columns.

**Step 2: the running share.**

```python
total = tape["current_balance"].sum()
top["cum_pct"] = top["current_balance"].cumsum() / total
print(top)
```

- `total` is the pool, £240,000,000, computed from the data.
- `cumsum()` adds the balances down the list: the first value is the largest loan, the tenth is the sum of all ten.
- Dividing by `total` turns each running sum into a share of the pool.

The output (shares rounded):

| loan_id | region | current_balance | cum_pct |
|---|---|---:|---:|
| ASH100881 | London | 840,940 | 0.35% |
| ASH100772 | East of England | 758,161 | 0.67% |
| ASH100484 | Yorkshire and the Humber | 620,912 | 0.92% |
| … | | | |
| ASH100185 | Yorkshire and the Humber | 558,805 | **2.67%** |

#### Reading the result

- **The ten largest loans are 2.67% of the pool**, the same figure as SQL query 6.3. Each loan is at most 0.35% of the pool: the pool is granular, with no single loan that could hurt the notes on its own.
- **Four of the ten are in London**: high balances follow high house prices. A region strat by balance and a top-ten list together show whether concentration is about borrowers or about places.
- **Investors and rating agencies ask for this table.** Prospectuses and investor reports show the share of the largest loans or borrowers, because a pool with a few very large loans can lose a large share of its value through one default.
- **The list falls slowly.** The tenth loan (£558,805) is two-thirds the size of the first (£840,940); there is no single outsized loan. A list where the first loan was several times the second would point to a special case worth reading in the loan file.

#### Checking your answer

- **The last line by another route.** `top["current_balance"].sum() / total` returns 0.02666, the 2.67% of the tenth row.
- **`nlargest`.** `tape.nlargest(10, "current_balance")` returns the same ten loans in the same order.
- **SQL.** Query 6.3 of Chapter 17 shows 2.67% for the tenth row.
- **The first row.** `tape["current_balance"].max() / total` returns 0.0035, the 0.35% on the first line: the running share always starts with the largest loan's own share.
- **The whole pool.** Without `.head(10)`, the last value of `cum_pct` is exactly 1.0: the running share of every loan adds to the pool. A last value other than 100% means a balance is missing or counted twice.

#### Mistakes people make on this exercise

- **Dividing by the ten loans' total.** `top["current_balance"].cumsum() / top["current_balance"].sum()` always ends at 100%, which says nothing about concentration.
- **Computing the share before sorting.** `cumsum` on the unsorted tape adds loans in file order; the top ten are then not the first ten.
- **`ascending=True`.** It lists the ten smallest loans, whose cumulative share (0.21%) looks reassuring and answers a different question.
- **Forgetting to divide by the whole pool when the tape is filtered.** If `tape` has been cut to one region earlier in the notebook, `total` is that region's balance, and the shares are of the region, not of the pool. Name the denominator in the column label.
- **Ties at the cut-off.** If the tenth and eleventh loans had the same balance, `head(10)` would keep one of them without saying so. Check `tape["current_balance"].nlargest(11)` and mention a tie if there is one; here there is none.

#### Trade-offs and going further

- **`sort_values` and `head`, or `nlargest`.** `nlargest` is shorter and faster on very large data, because it does not sort everything; `sort_values` makes the method explicit, which helps in an interview.
- **Loans or borrowers.** One borrower can hold several loans; concentration limits in deal documents are usually per borrower. With a borrower ID, group first: `tape.groupby("borrower_id")["current_balance"].sum().nlargest(10)`.
- **Going further.** Plot the cumulative share for all 1,200 loans (a concentration curve): the closer to a straight line, the more granular the pool.
- **Formatting.** `top.style.format({"cum_pct": "{:.2%}", "current_balance": "{:,.0f}"})` displays the table with percentages and thousands separators in a notebook, without changing the numbers underneath.

### Exercise 6: correct the 53.7% rate

#### What the question asks

> Correct the 53.7% rate in a copy of the DataFrame and recalculate the WA interest rate.

In plain words: one loan, ASH100602, has its rate keyed as 53.7% instead of 5.37% (Chapter 15). Fix it, without touching the data as received, and show how the pool's weighted average rate changes.

The exercise uses `copy()`, boolean masks and `.loc` for changing values (Section 18.4), the weighted average (Section 18.3), and the data quality finding of Chapter 15 (Section 15.3).

#### The plan

1. **Copy the DataFrame**, so the as-received tape is still available for the exceptions log and the "before" figure.
2. **Find the row** with a mask on `loan_id`.
3. **Change the one cell** with `.loc[row, column]`.
4. **Recompute the WA rate** before and after, and explain the difference.

#### Step by step

**Step 1: the copy.**

```python
import pandas as pd
tape = pd.read_csv("data/ashcombe_loan_tape.csv")
fixed = tape.copy()
```

- `copy()` makes an independent DataFrame. Without it, `fixed = tape` is a second name for the same data, and a change to one changes both.

**Step 2: the mask and the change.**

```python
row = fixed["loan_id"] == "ASH100602"
print(fixed.loc[row, "interest_rate"])
fixed.loc[row, "interest_rate"] = 0.0537
```

- `row` is a Series of True and False, True only for ASH100602.
- The `print` shows the value before the change: 0.537. Looking before changing proves the mask finds the loan.
- `.loc[row, "interest_rate"] = 0.0537` sets that one cell. `.loc` takes rows first, then the column.

**Step 3: before and after.**

```python
def wa_rate(df):
    bal = df["current_balance"]
    return (df["interest_rate"] * bal).sum() / bal.sum()

print(f"before {wa_rate(tape):.3%}  after {wa_rate(fixed):.3%}")
```

- A small function avoids writing the same formula twice.
- `:.3%` formats with three decimals.

The output:

```
before 5.444%  after 5.400%
```

#### Reading the result

- **One keying error moved the pool's WA rate by 0.044 percentage points** (4.4 basis points), on a loan that is 0.09% of the pool. A rate ten times too high carries a lot of weight.
- **The corrected figure is the one to report.** The WA rate feeds the pool yield, and through it excess spread (Chapter 8): a 4.4 bp error overstates the pool's interest by about £8,800 a month.
- **The as-received tape is kept.** `tape` still shows 53.7%, which is what the exceptions log must record as "found".
- **The fix changes one group much more than the pool.** The pool's rate moves 4.4 bp; the Fixed group's moves 6.2 bp (Chapter 17, Exercise 4), because the same error is spread over a smaller balance. The smaller the group you report, the more one bad value can move it.
- **Other figures move too.** Every output that uses the rate changes: the WA rate of the Fixed group, the rate strat (ASH100602 moves from an impossible top band to the 5% to 6% band) and the pool yield used for excess spread. Correcting the data once, before the report is built, fixes them all at the same time.

#### Checking your answer

- **The difference by arithmetic.** (0.537 − 0.0537) × £218,596 ÷ £240,000,000 = 0.00044, the 0.044% between the two outputs.
- **Only one cell changed.** `(tape["interest_rate"] != fixed["interest_rate"]).sum()` returns 1.
- **The same correction in SQL.** The `CASE` query of Chapter 17, Exercise 4 gives the corrected Fixed rate, 5.112%; Exercise 1 of this chapter run on `fixed` returns it too.
- **The original is untouched.** After the change, `tape.loc[tape["loan_id"] == "ASH100602", "interest_rate"]` still shows 0.537: the copy worked.

#### Mistakes people make on this exercise

- **Chained assignment.** `fixed[row]["interest_rate"] = 0.0537` changes a temporary copy: pandas 2 warns, and pandas 3 changes nothing at all, silently. Always `.loc[row, column]`.
- **No copy.** `fixed = tape` then `fixed.loc[…] = …` corrects `tape` too, and the "before" figure is lost.
- **Dividing the rate by 10 everywhere.** `fixed["interest_rate"] / 10` breaks the 1,199 correct loans; fix the one loan that is wrong.
- **Matching on the row number.** `fixed.loc[601, "interest_rate"] = 0.0537` works today because ASH100602 is row 601, but a re-sorted or refreshed tape puts another loan there. Always find the row by its ID.

#### Trade-offs and going further

- **Correct in code or at source.** A correction in code makes this month's report right; the servicer must fix the system, or next month's tape repeats the error. The exceptions log (Chapter 15) is how the two are linked.
- **One fix, or a corrections table.** With several fixes, keep a small DataFrame of `loan_id`, `field`, `old`, `new` and apply it in a loop: the corrections become data, reviewed and reused, rather than lines scattered in a script.
- **Going further.** Write a rule that would have caught the error automatically: `tape[(tape["interest_rate"] < 0) | (tape["interest_rate"] > 0.15)]` returns ASH100602 only.
- **Logging the change.** In a monthly script, print or log the loan, the field, the old value and the new one at the moment of the change; the log becomes the evidence for the exceptions register.

### Exercise 7: 3+ months arrears by month

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

### Exercise 8: the CPR for a 4-year WAL

#### What the question asks

> Using `project`, find the CPR at which Class A's WAL is closest to 4 years.

In plain words: run the cash flow projection of `ch18_08_cashflow_projection.py` at several prepayment speeds, read Class A's weighted average life each time, and find the speed that gives four years.

The exercise uses the functions `project` and `wal` (Section 18.9), CPR (Chapter 10, Section 10.7) and the WAL (Section 10.9). At 10% CPR, Class A's WAL is 4.91 years.

#### The plan

1. **Know the direction**: a higher CPR repays principal sooner, so the WAL falls. Four years needs a CPR above 10%.
2. **Run a grid of CPRs** in small steps, and print the WAL for each.
3. **Read the closest value**, then refine with a bisection for the exact rate.
4. **Check** that the WAL falls at every step.

#### Step by step

**Step 1: import the functions.**

```python
import sys
sys.path.append("python")   # notebook only
from ch18_08_cashflow_projection import project, wal
```

- `sys.path.append("python")` lets a notebook in the repository root find the script; a script in the `python` folder finds it without this line.
- `project(cpr=…)` returns a DataFrame of monthly cash flows; `wal(cf, "class_a_principal")` computes the WAL of a principal column in years.

**Step 2: the grid.**

```python
for cpr in [0.10 + 0.005 * i for i in range(11)]:
    cf = project(cpr=cpr)
    print(f"{cpr:.1%}", round(wal(cf, "class_a_principal"), 3))
```

- The list comprehension makes eleven CPRs: 10.0%, 10.5%, … 15.0%.
- For each, the pool is projected and Class A's WAL printed with three decimals.

The output:

| CPR | WAL (years) |
|---:|---:|
| 10.0% | 4.912 |
| 11.0% | 4.574 |
| 12.0% | 4.274 |
| 12.5% | 4.136 |
| **13.0%** | **4.006** |
| 13.5% | 3.882 |
| 14.0% | 3.765 |
| 15.0% | 3.549 |

**13% CPR** gives the WAL closest to 4 years.

**Step 3: the exact rate.**

```python
lo, hi = 0.10, 0.20
for _ in range(40):
    mid = (lo + hi) / 2
    if wal(project(cpr=mid), "class_a_principal") > 4:
        lo = mid
    else:
        hi = mid
print(f"{mid:.2%}")
```

- `lo` gives a WAL above 4 years, `hi` one below; each pass halves the range and keeps the half that contains 4.
- Forty halvings narrow 10 percentage points to far below a basis point.

The output: **13.02%**.

#### Reading the result

- **About 13% CPR gives a four-year WAL.** Around that point each extra 0.5% of CPR shortens the WAL by 0.12 to 0.13 years, about a month and a half.
- **The curve flattens as CPR rises**: from 10% to 11% the WAL falls by 0.34 years, from 14% to 15% by 0.22. Each extra point of CPR prepays a smaller remaining balance.
- **This is the question a pricing desk asks.** Notes are priced at an assumed CPR; investors want to know how far the WAL moves if prepayments differ. A table like Step 2 is the answer.
- **Class A's WAL is a pricing input.** A note's price and its spread are quoted at a stated CPR; if prepayments run at 13% instead of 10%, Class A's life is nearly a year shorter (4.91 to 4.01 years), and an investor who bought above par receives the premium back over a shorter period.

#### Checking your answer

- **The WAL falls at every step** of the grid, as it must when only CPR changes.
- **Section 18.9's table.** At 15% CPR it shows a Class A WAL of 3.55 years, the grid's last row.
- **The bisection lands inside the grid's bracket**: 13.02% is between 13.0% (4.006) and 13.5% (3.882), close to 13.0%, as 4.006 is close to 4.
- **Plug the answer back in.** `wal(project(cpr=0.13022), "class_a_principal")` returns 4.000 years to three decimals.

#### Mistakes people make on this exercise

- **Steps that are too coarse.** A grid of 10%, 12%, 14% jumps from 4.27 to 3.77 years and misses the closest value.
- **Typing `cpr=13`.** The function expects 0.13. With 13, `(1 - cpr) ** (1 / 12)` takes a root of a negative number, Python returns a complex number, and the projection stops with a `TypeError`.
- **Reading the pool's WAL instead of Class A's.** `wal(cf, "class_b_principal")` or a pool WAL gives a different, longer figure.
- **Reusing a stale `cf`.** In a notebook, printing `wal(cf, …)` after the loop reads the last projection only (15%); every CPR needs its own projection, inside the loop.
- **A bracket that does not contain the answer.** Starting the bisection with `lo, hi = 0.15, 0.20` (both WALs below 4 years) makes it converge to 15% without finding 4 years. Check that the WAL at `lo` is above 4 and at `hi` below before the loop.

#### Trade-offs and going further

- **Grid or bisection.** A grid shows the whole curve, which is what a reader needs to understand sensitivity; bisection finds one exact value fast. Give both: the table for the reader, the exact rate for the record.
- **Speed.** Each projection runs a few hundred months, so forty runs take well under a second; for thousands of scenarios, vectorise the projection or cache results.
- **Going further.** Repeat the grid with `cdr=0.02`: defaults also repay Class A in this model (Chapter 16, Exercise 8), so the CPR needed for four years falls to 11.69%.
- **A library root-finder.** `scipy.optimize.brentq(lambda c: wal(project(cpr=c), "class_a_principal") - 4, 0.10, 0.20)` finds the same 13.02% in a few lines; writing the bisection yourself shows you understand it, which is what an interview tests.
