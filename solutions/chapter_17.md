# Chapter 17: SQL for structured finance: the queries that matter

> © 2026 Mohamed Miled. All rights reserved. This text is part of the book *Structured Finance Interviews from Zero* and may not be copied, republished or sold. The code blocks are under the MIT licence (see `LICENSE`); the explanations are not (see `LICENSE-TEXT.md`).

## Corrections

### Exercise 1: loans and balance by occupancy

#### What the question asks

> Write a query for the number and balance of loans by `occupancy`.

In plain words: one row for each occupancy type in the tape (owner-occupied, buy-to-let), with how many loans it has and their total current balance.

The exercise uses `GROUP BY` with `COUNT(*)` and `SUM` (Section 17.3), and the table `dbo.loan_tape` described in Section 17.1.

#### The plan

1. **Group by the column that defines a row of the answer**, `occupancy`: one group per value.
2. **Aggregate inside each group**: count the rows and add the balances.
3. **Name the output columns**, so the result reads like a report.
4. **Check the groups add back to the pool**: 1,200 loans and £240,000,000.

#### Step by step

```sql
SELECT occupancy,
       COUNT(*) AS loans,
       SUM(current_balance) AS balance
FROM dbo.loan_tape
GROUP BY occupancy
ORDER BY occupancy;
```

- `FROM dbo.loan_tape` reads the 1,200 rows of the tape.
- `GROUP BY occupancy` sorts them into groups, one per distinct value of `occupancy`. Every column in the `SELECT` must now be either the grouping column or an aggregate.
- `COUNT(*)` counts the rows in each group; `SUM(current_balance)` adds their balances.
- `AS loans` and `AS balance` name the columns; without them SQL Server shows "(No column name)".
- `ORDER BY occupancy` fixes the row order. Without it, SQL returns groups in whatever order is fastest, which can change between runs.

The result:

| occupancy | loans | balance |
|---|---:|---:|
| Buy-to-let | **216** | **46,245,021** |
| Owner-occupied | **984** | **193,754,979** |

#### Reading the result

- **Buy-to-let is 18% of the loans and 19.3% of the balance.** Its loans are slightly larger on average: £214,097 against £196,905 for owner-occupied.
- **The split matters to investors.** Buy-to-let loans are repaid from rent, not salary, and 85.7% of them (by balance) are interest-only, against 6.9% of owner-occupied loans. Prospectuses show this line first in the occupancy strat.
- **Only two values appear**, so the field is clean: no misspellings, no blanks. A third row, such as "BTL" or NULL, would be a data quality finding.
- **The two groups are not alike.** Buy-to-let loans have a lower WA indexed LTV (56.1% against 61.4%) and a slightly lower WA rate (5.42% against 5.45%). A one-line occupancy strat is the start; adding those columns turns it into a comparison an investor can use.

#### Checking your answer

- **The groups add up.** 216 + 984 = 1,200 loans; £46,245,021 + £193,754,979 = £240,000,000, the totals of `SELECT COUNT(*), SUM(current_balance) FROM dbo.loan_tape`.
- **The same figure elsewhere.** The Metrics sheet of the Chapter 16 workbook shows the buy-to-let balance in B12: £46,245,021.
- **No NULL group.** `SELECT COUNT(*) FROM dbo.loan_tape WHERE occupancy IS NULL` returns 0; if it did not, `GROUP BY` would show a NULL row.
- **Same answer in SQLite.** The query has no SQL Server-specific syntax, so `run_query.py` returns the same two rows; a query that runs unchanged in both engines is easier to share.

#### Mistakes people make on this exercise

- **Leaving out `GROUP BY`.** `SELECT occupancy, COUNT(*) FROM dbo.loan_tape` fails in SQL Server with Msg 8120 (Exercise 7 explains why).
- **`COUNT(occupancy)` instead of `COUNT(*)`.** It skips rows where occupancy is NULL; here the result is the same, but on a dirty tape the loans with a blank occupancy vanish from the count without warning.
- **Grouping by a second column by accident.** `GROUP BY occupancy, region` returns 24 rows instead of 2; check that the row count matches the number of values you expect.
- **Filtering groups in `WHERE`.** To keep only groups above a size, the condition on `COUNT(*)` goes in `HAVING`; `WHERE COUNT(*) > 100` fails, because `WHERE` runs before the groups exist.
- **Trusting the engine to merge spellings.** SQL Server's default collation would group "buy-to-let" with "Buy-to-let", while SQLite and pandas would not. Here the field is clean, but on another tape the same query can return two rows in one tool and three in another; check the distinct values first.

#### Trade-offs and going further

- **Add the share in the same query.** `100.0 * SUM(current_balance) / SUM(SUM(current_balance)) OVER () AS pct_of_pool` gives 19.27% and 80.73%. It is compact, but a window over an aggregate surprises readers who have not met it; a CTE with the total in a separate step is easier to read.
- **Count or balance.** Investors read balances; operations teams read counts. Showing both costs one line.
- **Going further.** Add `AVG(current_balance) AS avg_balance` and `SUM(interest_rate * current_balance) / SUM(current_balance) AS wa_rate` to the same query: a one-query occupancy strat.
- **A total row in the same result.** SQL Server's `GROUP BY ROLLUP(occupancy)` adds a third row with NULL in `occupancy` and the pool totals (1,200; £240,000,000). It saves a second query, but SQLite does not support it, and the NULL label must be replaced (`COALESCE(occupancy, 'Total')`) before the result goes into a report.

### Exercise 2: original LTV above 90%, largest first

#### What the question asks

> Write a query listing loans with an **original** LTV above 90%, largest balance first.

In plain words: a list of the loans that were made with less than a 10% deposit, sorted so that the largest balances, where the risk is concentrated, come first.

The exercise uses `WHERE`, `ORDER BY` and column selection (Section 17.2), and the original LTV of Chapter 10 (Section 10.3). LTVs are stored as decimals: 0.90 means 90%.

#### The plan

1. **Choose the columns** the reader needs to act on: ID, the LTV that triggered the filter, the balance.
2. **Filter** with `original_ltv > 0.90`, strictly above, as the question says.
3. **Sort** by `current_balance` from largest to smallest.
4. **Count and total the list** with a second query, so the list can be summarised in one line.

#### Step by step

```sql
SELECT loan_id, original_ltv, current_balance
FROM dbo.loan_tape
WHERE original_ltv > 0.90
ORDER BY current_balance DESC;
```

- `SELECT loan_id, original_ltv, current_balance` returns three columns only: a list for a reviewer, not a full extract.
- `WHERE original_ltv > 0.90` keeps loans strictly above 90%. The tape has no loan at exactly 0.90, so `>=` gives the same 111 rows here, but the question says "above".
- `ORDER BY current_balance DESC` puts the largest first; `DESC` means descending.

The first rows:

| loan_id | original_ltv | current_balance |
|---|---:|---:|
| ASH100499 | 0.9480 | 607,409 |
| ASH100653 | 0.9307 | 538,556 |
| ASH100826 | 0.9170 | 345,947 |

The list has **111 rows**; the last is ASH100258 (£43,126).

Then the summary:

```sql
SELECT COUNT(*) AS loans,
       SUM(current_balance) AS balance,
       MAX(original_ltv) AS highest_ltv
FROM dbo.loan_tape
WHERE original_ltv > 0.90;
```

Result: **111 loans, £20,410,799**, highest original LTV **95.12%**.

#### Reading the result

- **8.5% of the pool by balance was lent above 90% LTV.** These borrowers had little equity at the start, so a fall in house prices could put them in negative equity.
- **Only one loan is above 95%, at 95.12%.** A 95% maximum LTV is the usual ceiling for UK prime lending; the single loan above it is worth a question to the originator.
- **The largest, ASH100499 (£607,409 at 94.80%), is also the sixth-largest loan in the pool.** A large, high-LTV loan is the first one a credit reviewer looks at.
- **Original LTV describes the start.** Many of these loans have since repaid and prices have risen; their indexed LTV is lower. A risk review would add `indexed_ltv` to the list.
- **Most of them have since improved.** The 111 loans have a WA original LTV of 92.6% and a WA indexed LTV of 79.9%: repayments and house price rises have rebuilt their equity. 69 of them (£12.5m) are still above 80% indexed LTV.
- **Where they are.** The South East (28 loans) and London (18) have the most: high prices make large deposits harder to find.

#### Checking your answer

- **The summary query agrees with the list**: 111 rows in the list, 111 in the count.
- **The edge.** `SELECT COUNT(*) FROM dbo.loan_tape WHERE original_ltv = 0.90` returns 0, so `>` and `>=` agree on this tape; on another tape they may not.
- **The LTV strat.** The original LTV strat (if built with an "Over 90%" band) shows the same count and balance in its top band.
- **The first row by hand.** `SELECT MAX(current_balance) FROM dbo.loan_tape WHERE original_ltv > 0.90` returns £607,409, the balance of the first row.

#### Mistakes people make on this exercise

- **`WHERE original_ltv > 90`.** LTVs are decimals, so no loan passes and the query returns an empty list, with no error to warn you.
- **Using `indexed_ltv`.** The question asks for the LTV at origination; indexed LTV above 90% gives a much shorter list.
- **Forgetting `DESC`.** The default order is ascending, so the smallest loan, £43,126, comes first.
- **Sorting by `original_ltv`** instead of balance: the list then starts with the highest LTV, ASH101169 at 95.12%, which answers a different question.
- **`BETWEEN 0.90 AND 1`.** `BETWEEN` includes both ends, so it also keeps loans at exactly 90%, which the question excludes. On this tape the result is the same; the habit is still wrong.

#### Trade-offs and going further

- **A list or a strat.** A list is right when someone will review loans one by one; a report needs the LTV strat, which shows the same information in six rows. Give the list a summary line so both readers are served.
- **`TOP` for a long list.** `SELECT TOP 20 …` (SQL Server) or `LIMIT 20` (SQLite) shows the twenty largest; say in the output that the list is cut.
- **Going further.** Add `indexed_ltv` and the filter `AND indexed_ltv > 0.80`: the high-LTV loans that are still high today, the real risk.
- **Parameters instead of typed values.** In a stored procedure or a script, write the threshold as a parameter (`@max_ltv = 0.90`) so the same query serves 85% or 95% without editing; typed values are fine in an interview answer.

### Exercise 3: a balance-size strat with CASE

#### What the question asks

> Using CASE, build a balance-size strat with the buckets of Chapter 16, exercise 2.

In plain words: put every loan of the tape into one of five balance bands (£100,000 or less; over £100,000 to £200,000; over £200,000 to £300,000; over £300,000 to £500,000; over £500,000), then show, for each band, the number of loans and their total balance. This is the table that appears in every investor report and prospectus under the name "stratification by current balance", and the interviewer wants to see you build it without Excel.

The exercise uses three ideas from this chapter: `CASE` to turn a number into a label (Section 17.4), a subquery in `FROM` (Section 17.4, query 3.1), and `GROUP BY` with `COUNT` and `SUM` (Section 17.3). The bands themselves come from Chapter 16, Exercise 2, so you can compare the SQL result with the Excel one.

#### The plan

1. **Write the `CASE` expression on its own and test it on a few loans.** It is the only new piece of logic; if it is wrong, every total is wrong.
2. **Put the `CASE` in a subquery** that returns one row per loan with its band. `GROUP BY` cannot easily group on a long expression written in the same query, and the subquery keeps the logic in one place.
3. **Group the subquery by band** and count and sum.
4. **Check that the bands add up to the tape**: 1,200 loans and £240,000,000. A strat that does not tie to the pool is not finished.

#### Step by step

**Step 1: the `CASE` expression.** Start with three loans so that you can check the labels by eye:

```sql
SELECT loan_id, current_balance,
       CASE
         WHEN current_balance <= 100000 THEN '1 £100k or less'
         WHEN current_balance <= 200000 THEN '2 >£100k to £200k'
         WHEN current_balance <= 300000 THEN '3 >£200k to £300k'
         WHEN current_balance <= 500000 THEN '4 >£300k to £500k'
         ELSE '5 Over £500k'
       END AS size_bucket
FROM dbo.loan_tape
WHERE loan_id IN ('ASH100001', 'ASH100002', 'ASH100003');
```

- `CASE` opens the expression and `END` closes it; `AS size_bucket` names the new column.
- Each `WHEN … THEN …` is a test and the label to return if the test is true.
- SQL tests the `WHEN` lines **from the top and stops at the first true one**. That is why each line needs only the upper edge: a loan of £150,000 fails the first test (it is not ≤ 100,000) and passes the second, so it never reaches the third.
- `ELSE` catches every loan that passed none of the tests: here, the loans over £500,000.
- The number at the start of each label (`1`, `2`…) is there for sorting in Step 3: text sorts character by character, so "Over £500k" would otherwise come before "£100k or less".
- The `WHERE` line limits the test to three loans.

The result:

| loan_id | current_balance | size_bucket |
|---|---:|---|
| ASH100001 | 152,661 | 2 >£100k to £200k |
| ASH100002 | 252,510 | 3 >£200k to £300k |
| ASH100003 | 424,354 | 4 >£300k to £500k |

Each label is right: £152,661 is over £100,000 and not over £200,000, and so on.

**Step 2: the subquery.** Remove the `WHERE`, keep only the two columns needed, and wrap the query in brackets:

```sql
FROM (
  SELECT current_balance,
         CASE … END AS size_bucket
  FROM dbo.loan_tape
) AS b
```

- The inner query returns 1,200 rows, one per loan, each with its balance and its band.
- `AS b` names the result of the brackets. SQL Server requires a name for every subquery in `FROM`, even when you never use it.

**Step 3: group and aggregate.** The full query:

```sql
SELECT size_bucket,
       COUNT(*) AS loans,
       SUM(current_balance) AS balance
FROM (
  SELECT current_balance,
         CASE
           WHEN current_balance <= 100000 THEN '1 £100k or less'
           WHEN current_balance <= 200000 THEN '2 >£100k to £200k'
           WHEN current_balance <= 300000 THEN '3 >£200k to £300k'
           WHEN current_balance <= 500000 THEN '4 >£300k to £500k'
           ELSE '5 Over £500k'
         END AS size_bucket
  FROM dbo.loan_tape
) AS b
GROUP BY size_bucket
ORDER BY size_bucket;
```

- `GROUP BY size_bucket` makes one group per band.
- `COUNT(*)` counts the rows (loans) in each group; `SUM(current_balance)` adds their balances.
- `ORDER BY size_bucket` sorts the labels, which the leading digits put in size order.

The result:

| size_bucket | loans | balance |
|---|---:|---:|
| 1 £100k or less | 125 | 10,205,405 |
| 2 >£100k to £200k | 581 | 87,927,905 |
| 3 >£200k to £300k | 340 | 82,154,579 |
| 4 >£300k to £500k | 137 | 49,632,662 |
| 5 Over £500k | 17 | 10,079,449 |

**Step 4: the share of the pool.** Investors read percentages, so add one column. A window function over the aggregate gives the pool total on every row:

```sql
       100.0 * SUM(current_balance)
         / SUM(SUM(current_balance)) OVER () AS pct_of_pool
```

- The inner `SUM` is the band's balance; the outer `SUM(...) OVER ()` adds those band totals across all rows of the result, which is the pool.
- `100.0 *` turns the ratio into a percentage with decimals.

The shares are 4.25%, 36.64%, 34.23%, 20.68% and 4.20%.

#### Reading the result

- **The middle of the pool is £100,000 to £300,000**: 921 loans and £170,082,484, 70.9% of the balance. This is a typical UK prime pool: most loans are mid-sized.
- **The tails are small**: 125 loans of £100,000 or less make up 4.25% of the balance, because small loans contribute little money even when there are many of them.
- **17 loans over £500,000 hold 4.20%** of the pool. Analysts look at this band for concentration: one large default here costs as much as several average ones.
- The figures are identical to the Excel strat of Chapter 16, Exercise 2: two tools, one answer.

#### Checking your answer

Run a second query that adds the bands back up:

```sql
SELECT COUNT(*) AS loans, SUM(current_balance) AS balance
FROM dbo.loan_tape;
```

It returns 1,200 loans and £240,000,000. Now add the strat's columns by hand: 125 + 581 + 340 + 137 + 17 = 1,200, and £10,205,405 + £87,927,905 + £82,154,579 + £49,632,662 + £10,079,449 = £240,000,000. Every loan is in exactly one band.

A second check concerns the edges. A loan of exactly £100,000 must fall in band 1 ("£100k or less"), not band 2. Test the edges directly:

```sql
SELECT COUNT(*) FROM dbo.loan_tape
WHERE current_balance IN (100000, 200000, 300000, 500000);
```

It returns 0: no loan in this tape sits exactly on an edge, so the edge rule does not change today's figures. It would on another tape, which is why the `<=` matters.

#### Mistakes people make on this exercise

**Writing the tests in the wrong order.** If the widest test comes first:

```sql
CASE WHEN current_balance <= 500000 THEN '4 >£300k to £500k'
     WHEN current_balance <= 300000 THEN '3 …'
```

every loan up to £500,000 stops at the first line. The result has two rows: 1,183 loans in band 4 and 17 in band 5. The symptom is a strat with empty bands and one enormous one. The fix: order the tests from the smallest upper edge to the largest.

**Using `<` instead of `<=`.** `WHEN current_balance < 100000` puts a loan of exactly £100,000 in band 2, which contradicts its label "£100k or less". Nothing changes on this tape, so the error is silent until the month a loan lands on an edge. Match the operator to the label: "or less" means `<=`.

**Grouping without the subquery and forgetting part of the `CASE`.** `GROUP BY` on the expression works only if the whole `CASE` is repeated identically in `GROUP BY`; a one-character difference gives SQL Server's Msg 8120 ("not contained in either an aggregate function or the GROUP BY clause"). The subquery avoids writing the expression twice.

**Labels without a sort key.** Without the leading digits, `ORDER BY size_bucket` sorts "Over £500k" first and "£100k or less" somewhere in the middle, and the table reads in a random order.

#### Trade-offs and going further

- **Edges in the query or in a table.** Typing the edges into the `CASE` is quick and clear for one report. If the bands change often, or the same bands serve several reports, store them in a small table (`band_label, lower_edge, upper_edge`) and join with `current_balance > lower_edge AND current_balance <= upper_edge`. The query then never changes; only the table does.
- **Subquery or CTE.** A CTE (`WITH b AS (SELECT …) SELECT … FROM b GROUP BY …`, Section 17.6) does exactly the same as the subquery and reads top to bottom. Use whichever your team uses; in an interview, either is right.
- **Going further.** Add a total row with `GROUP BY ROLLUP(size_bucket)` (Section 17.14) and label it with `GROUPING(size_bucket)`. You then have the complete investor-report table in one query, total included.

### Exercise 4: WA interest rate by rate type

#### What the question asks

> Write a query that returns, for each `rate_type`, the balance-weighted average interest rate.

In plain words: one row for each rate type (Fixed, SVR, Tracker) with the average interest rate weighted by balance, so that large loans count more than small ones.

The exercise uses `GROUP BY` and aggregates (Section 17.3), the weighted average of Chapter 10 (Section 10.1), and the 53.7% keying error on ASH100602 found in Chapter 15.

#### The plan

1. **Write the weighted average as two sums**: Σ(rate × balance) ÷ Σ(balance). SQL has no weighted-average function, but two sums do the job.
2. **Group by `rate_type`**, so each sum is computed per group.
3. **Round for display**, not inside the calculation.
4. **Check the effect of the known error** by recomputing with the corrected rate.

#### Step by step

```sql
SELECT rate_type,
       COUNT(*) AS loans,
       SUM(interest_rate * current_balance)
         / SUM(current_balance) AS wa_rate
FROM dbo.loan_tape
GROUP BY rate_type
ORDER BY rate_type;
```

- `interest_rate * current_balance` is computed row by row: the rate weighted by the loan's size.
- `SUM(...)` adds those products within each group; dividing by `SUM(current_balance)` turns the sum into an average.
- Both sums are over the same rows, so the division is safe: no group has a zero balance.
- `COUNT(*)` adds the number of loans, which helps the reader judge each figure.

The result:

| rate_type | loans | wa_rate |
|---|---:|---:|
| Fixed | 853 | **5.175%** |
| SVR | 144 | **7.247%** |
| Tracker | 203 | **5.245%** |

#### Reading the result

- **SVR loans pay the most, 7.25%.** The standard variable rate is the lender's own rate, charged when a fixed or tracker deal ends; borrowers on it are usually those who did not or could not remortgage.
- **Fixed and Tracker are close.** Both are deal rates offered to win business.
- **The Fixed figure is overstated.** It includes ASH100602, keyed as 53.7% instead of 5.37%. That one £218,596 loan lifts Fixed's WA rate by 0.062 percentage points.
- **The ranges tell the same story.** SVR rates run from 6.91% to 7.59%, a narrow band set by the lender; Fixed rates run from 4.26% to 53.7%, and the top of that range is the error. Looking at `MIN` and `MAX` next to an average is the fastest way to spot a value that does not belong.

#### Checking your answer

- **Recompute with the correction**, without changing the table:

```sql
SELECT SUM(CASE WHEN loan_id = 'ASH100602' THEN 0.0537
                ELSE interest_rate END * current_balance)
       / SUM(current_balance) AS wa_rate_fixed_corrected
FROM dbo.loan_tape
WHERE rate_type = 'Fixed';
```

Result: **5.112%**. Unrounded, the two figures are 5.1747% and 5.1124%: the difference, 0.0623 percentage points, equals (0.537 − 0.0537) × £218,596 ÷ £169,638,911.

- **The groups average to the pool.** Weighted by group balance, (5.175% × £169.6m + 7.247% × £29.8m + 5.245% × £40.6m) ÷ £240m = 5.444%, the pool's WA rate in Section 17.3.
- **Count the loans behind each figure.** 853 + 144 + 203 = 1,200: no loan has a NULL or unexpected `rate_type`; an extra group would appear as a fourth row.

#### Mistakes people make on this exercise

- **`AVG(interest_rate)`.** It gives the simple average (Fixed 5.171%): close here, but a different measure, and the one interviewers ask you to avoid.
- **`SUM(interest_rate) * SUM(current_balance)`.** Multiplying the sums instead of summing the products gives a meaningless number.
- **Integer arithmetic.** If rates were stored as whole basis points (`INT`), SQL Server would divide integers and truncate. Multiply by `1.0` first when in doubt.
- **Rounding inside the sum.** `SUM(ROUND(interest_rate, 2) * current_balance)` rounds each rate to whole percents before weighting, and the Fixed figure moves by several basis points. Round only the final result.
- **NULL rates.** `SUM(interest_rate * current_balance)` skips rows where the rate is NULL, but `SUM(current_balance)` still counts their balances, so the average is too low. Use `SUM(CASE WHEN interest_rate IS NOT NULL THEN current_balance END)` as the denominator when the column can be blank. Here no rate is NULL, so both forms agree.

#### Trade-offs and going further

- **Correct the data or exclude the loan.** Excluding ASH100602 gives 5.112% too, but drops a real loan from the pool; correcting it keeps every balance. The report needs the corrected figure, with an exceptions log entry.
- **Ratios in SQL or in the report.** Computing the division in SQL keeps one source of truth; exporting the two sums lets Excel recompute any grouping. For a monthly report, keep it in SQL.
- **Going further.** Add `GROUP BY rate_type, repayment_type`: nine rows, and SVR interest-only loans show the highest rate of all.
- **Display precision.** `ROUND(…, 5)` shows 0.05175; `FORMAT(…, 'P3')` in SQL Server shows 5.175% but returns text, which Excel cannot add. Keep numbers numeric until the last step.
- **Current or original balance as the weight.** Reports weight by current balance, because that is the money earning the rate today; weighting by original balance gives old, largely repaid loans too much weight.

### Exercise 5: the three largest loans in each region

#### What the question asks

> Using a window function, list the **three** largest loans in each region.

In plain words: for every region, the three loans with the highest balance, with their rank. It is the "top N per group" question, one of the most common in SQL interviews.

The exercise uses window functions, `ROW_NUMBER()` with `PARTITION BY` and `ORDER BY` (Section 17.7), and subqueries (Section 17.6). It also meets the dirty region values of Chapter 15.

#### The plan

1. **Number the loans within each region** from largest to smallest, with `ROW_NUMBER()`.
2. **Filter on that number in an outer query**, because a window's result cannot be used in the same query's `WHERE`.
3. **Sort the output** by region and rank.
4. **Count the rows** and explain the count from the number of regions.

#### Step by step

```sql
SELECT region, loan_id, current_balance, rn
FROM (
    SELECT region, loan_id, current_balance,
           ROW_NUMBER() OVER (PARTITION BY region
                              ORDER BY current_balance DESC) AS rn
    FROM dbo.loan_tape
) AS x
WHERE rn <= 3
ORDER BY region, rn;
```

- The inner query reads every loan and adds `rn`.
- `PARTITION BY region` restarts the numbering at 1 for each region.
- `ORDER BY current_balance DESC` inside `OVER` gives 1 to the largest loan of the region.
- `AS x` names the subquery; SQL Server requires a name.
- The outer `WHERE rn <= 3` keeps the first three of each region; `ORDER BY region, rn` lists them in order.

The first rows in SQL Server:

| region | loan_id | current_balance | rn |
|---|---|---:|---:|
| East Midlands | ASH101197 | 495,966 | 1 |
| East Midlands | ASH101044 | 440,807 | 2 |
| East Midlands | ASH101027 | 375,282 | 3 |
| East of England | ASH100772 | 758,161 | 1 |

In total, **34 rows** in SQL Server.

#### Reading the result

- **Why 34.** The tape has eleven standard regions, plus "Greater London" with one loan: 11 × 3 + 1 = 34. SQL Server's default collation ignores case and trailing spaces, so "London", "london" and `"London "` form one partition.
- **The largest loan in the pool, ASH100881 (£840,940), heads London**, and the second-largest, ASH100772, heads the East of England. The top of each region is where concentration risk sits.
- **A one-loan "region" is a data finding.** "Greater London" appears as its own partition; it should be mapped to London (Chapter 15, Section 15.7).
- **The top three per region are 6.9% of the pool.** It is a quick concentration measure by region; a region whose three largest loans held, say, a fifth of its balance would need a closer look.

#### Checking your answer

- **Each region has at most three rows**, numbered 1, 2, 3 with no gaps.
- **One region by hand.** `SELECT TOP 3 loan_id, current_balance FROM dbo.loan_tape WHERE region = 'South East' ORDER BY current_balance DESC` returns the same three loans as the South East rows of the result.
- **SQLite gives 36 rows.** SQLite compares text exactly, so "london" and `"London "` are separate one-loan partitions: 34 + 2 = 36. The difference between the two engines is itself a check that the region field is dirty.
- **Three per region.** `GROUP BY region` on the result, with `COUNT(*)`, shows 3 for every region except Greater London (1).

#### Mistakes people make on this exercise

- **Filtering `rn` in the same query.** `WHERE ROW_NUMBER() OVER (…) <= 3` fails: window functions are computed after `WHERE`. The subquery (or a CTE) is required.
- **Forgetting `PARTITION BY`.** The numbering then runs over the whole pool, and `rn <= 3` returns the three largest loans overall.
- **`ORDER BY current_balance` without `DESC` inside `OVER`.** The three smallest loans of each region come back.
- **Ordering the outer result by balance only.** `ORDER BY current_balance DESC` mixes the regions; sort by region first, then `rn`, so each region's three loans sit together.
- **`TOP 3` instead of a window.** `SELECT TOP 3 … ORDER BY current_balance DESC` returns the three largest loans of the whole pool, not of each region. Top N *per group* needs `PARTITION BY`.

#### Trade-offs and going further

- **`ROW_NUMBER`, `RANK` or `DENSE_RANK`.** `ROW_NUMBER` always returns three rows and breaks ties arbitrarily; `RANK` keeps tied loans and can return four. For a top-three list, `ROW_NUMBER` with a tie-breaker (`ORDER BY current_balance DESC, loan_id`) is repeatable.
- **Subquery or CTE.** A CTE (`WITH ranked AS (…) SELECT … FROM ranked WHERE rn <= 3`) reads top to bottom and is easier to extend; the result is the same.
- **Going further.** Clean the region inside the query, `PARTITION BY UPPER(TRIM(region))`, and SQLite returns 34 rows as SQL Server does.
- **Without a window function.** A correlated subquery (`WHERE 3 > (SELECT COUNT(*) FROM dbo.loan_tape b WHERE b.region = a.region AND b.current_balance > a.current_balance)`) gives the same rows in engines without window functions, but runs once per loan and is far slower on a large tape. Interviewers sometimes ask for it to see whether you know why window functions exist.

### Exercise 6: arrears differences between tape and servicer

#### What the question asks

> Write a query that finds loans whose `arrears_months` differ between the tape and the servicer's table.

In plain words: compare the months in arrears of each loan in two sources, the loan tape and the servicer's extract, and list the loans where they disagree.

The exercise uses joins (Section 17.5), the reconciliation method of Chapter 15 (Section 15.3: keys first, then values), and `NULL` behaviour (Section 17.12). The servicer's table is `dbo.servicer_balances`, with `loan_id`, `current_balance` and `arrears_months`.

#### The plan

1. **Join the two tables on `loan_id`**, so each loan's two values sit on one row.
2. **Keep rows where the values differ.**
3. **Read an empty result with care**: check how many rows were compared before concluding they all agree.
4. **Remember the keys**: an inner join silently drops loans that are in one table only.

#### Step by step

```sql
SELECT t.loan_id,
       t.arrears_months AS tape_arrears,
       s.arrears_months AS servicer_arrears
FROM dbo.loan_tape AS t
JOIN dbo.servicer_balances AS s
  ON s.loan_id = t.loan_id
WHERE t.arrears_months <> s.arrears_months;
```

- `t` and `s` are short names (aliases) for the two tables; every column is then written with its table, so there is no doubt which `arrears_months` is which.
- `JOIN … ON s.loan_id = t.loan_id` pairs each tape row with the servicer row for the same loan.
- `WHERE t.arrears_months <> s.arrears_months` keeps only disagreements.

Result: **no rows**.

Then count what was compared:

```sql
SELECT COUNT(*) AS rows_compared
FROM dbo.loan_tape AS t
JOIN dbo.servicer_balances AS s
  ON s.loan_id = t.loan_id;
```

Result: **1,200** rows.

#### Reading the result

- **Arrears agree for every matched loan.** The differences between the two sources found in Chapter 15 are in balances (ASH100500 and ASH100501, ±£1,250) and in keys (ASH100213 used twice), not in arrears.
- **1,200 compared rows do not mean 1,200 loans.** The tape has ASH100213 twice; both rows join to the one servicer row, and ASH100888, in the servicer's file only, is not compared at all. The comparison is complete only after the key reconciliation (Section 17.5, query 4.3).
- **The keys explain the count.** A `LEFT JOIN` from the tape finds no tape loan missing from the servicer's file; a `LEFT JOIN` from the servicer finds one, ASH100888. Those two numbers, 0 and 1, are what make "1,200 rows compared" readable.

#### Checking your answer

- **Reverse the condition.** With `=` instead of `<>` the count is 1,200: every compared row agrees.
- **NULLs.** `SELECT COUNT(*) FROM dbo.loan_tape WHERE arrears_months IS NULL` and the same on the servicer's table both return 0, so `<>` missed nothing.
- **Break it on purpose.** In a transaction, `UPDATE dbo.servicer_balances SET arrears_months = 2 WHERE loan_id = 'ASH100001'`, rerun the query (one row appears), then `ROLLBACK`.
- **Arrears distribution.** `SELECT arrears_months, COUNT(*) FROM dbo.loan_tape GROUP BY arrears_months` and the same on the servicer's table give identical counts (1,102 up to date, 51 at 1 month, 23 at 2 months, and so on): two sources that agree loan by loan must also agree in total.

#### Mistakes people make on this exercise

- **Concluding "the files agree" from an empty result.** The inner join hides ASH100888 and doubles ASH100213; say "arrears agree for every loan in both files".
- **`<>` with NULLs.** `2 <> NULL` is not true, it is unknown, so a loan blank on one side is not listed. On a tape with blanks, add `OR (t.arrears_months IS NULL AND s.arrears_months IS NOT NULL) OR (t.arrears_months IS NOT NULL AND s.arrears_months IS NULL)`.
- **Joining without aliases.** `WHERE arrears_months <> arrears_months` fails as ambiguous, or worse, compares a column with itself.
- **Comparing balances with `<>` when one side is computed.** Arrears months are whole numbers, so `<>` is exact. For balances that come from a calculation (interest accrued, say), compare with a tolerance, `WHERE ABS(t.x - s.x) > 0.01`, or rounding differences fill the list.

#### Trade-offs and going further

- **Column by column or all at once.** This query checks one field. `SELECT loan_id, current_balance, arrears_months FROM dbo.servicer_balances EXCEPT SELECT loan_id, current_balance, arrears_months FROM dbo.loan_tape` checks every shared field at once (Section 17.14) and treats NULLs as equal, but does not say which field differs.
- **`IS DISTINCT FROM`.** SQL Server 2022 and SQLite accept `WHERE t.arrears_months IS DISTINCT FROM s.arrears_months`, which handles NULLs in one condition; older SQL Server versions do not.
- **Going further.** Combine both checks in one query with a `FULL OUTER JOIN` and a `CASE` that labels each row "tape only", "servicer only", "balance differs" or "arrears differ".
- **Which source is right.** When the two disagree, the servicer's system is usually the record of what the borrower paid, and the tape is an extract of it; a difference points to the extract. Say which you would ask first, and why, in an interview.
- **Make it a monthly check.** Saved as a view (`CREATE VIEW dbo.v_arrears_differences AS …`), the query becomes part of the month-end routine: zero rows is the expected result, and any row is an exception for the log (Chapter 15).

### Exercise 7: why the query fails

#### What the question asks

> Explain why `SELECT region, SUM(current_balance) FROM dbo.loan_tape` fails, and fix it.

In plain words: this query asks for a region and a total in the same row, without saying how to group. Explain the rule it breaks, show the error, and write the query the author meant.

The exercise uses the rule of aggregation (Section 17.3): in a query with an aggregate, every selected column must be either grouped or aggregated. It is one of the questions asked most often in SQL interviews.

#### The plan

1. **Read what the query asks for**: one total over the whole table, and a region next to it.
2. **Find the conflict**: there are 14 region values and one total; SQL cannot know which region to show.
3. **Read the error message** SQL Server gives.
4. **Fix it** by deciding what the author meant: a total per region.

#### Step by step

**Step 1: run it.** In SQL Server:

```
Msg 8120, Level 16, State 1
Column 'dbo.loan_tape.region' is invalid in the select list because
it is not contained in either an aggregate function or the GROUP BY clause.
```

- `SUM(current_balance)` without `GROUP BY` collapses all 1,200 rows into **one** row.
- `region` has a different value on almost every row; SQL Server refuses to pick one.

**Step 2: the fix.**

```sql
SELECT region, SUM(current_balance) AS balance
FROM dbo.loan_tape
GROUP BY region
ORDER BY balance DESC;
```

- `GROUP BY region` makes one row per region, and the sum is computed within each.
- `ORDER BY balance DESC` puts the largest region first; ordering by the alias is allowed because `ORDER BY` runs after `SELECT`.

The first rows (SQL Server):

| region | balance |
|---|---:|
| South East | 46,352,048 |
| London | 39,115,642 |
| North West | 24,407,347 |

SQL Server returns **12 rows**: the case-insensitive collation joins "London", "london" and `"London "` into one group, so London shows £39,115,642. "Greater London" (£293,586) stays separate.

#### Reading the result

- **The rule protects you from a wrong number.** An engine that picked a region at random would print a pool total next to one region's name, a figure that looks plausible and is false.
- **SQLite does not stop you.** In SQLite the original query runs and returns one row: `London | 240000000.0`, the pool total next to an arbitrary region. That is the dangerous case: no error, wrong meaning.
- **The fixed query is the region strat**: the South East is the largest region (19.3% of the pool), then London.
- **The order SQL runs in explains the rule.** SQL evaluates `FROM`, then `WHERE`, then `GROUP BY`, then `HAVING`, then `SELECT`, then `ORDER BY`. By the time `SELECT` runs, the rows have been collapsed into groups (or, with no `GROUP BY`, into one), so only the grouped columns and aggregates still have a single value per row.

#### Checking your answer

- **The groups add up.** `SELECT SUM(balance) FROM (…) AS r` around the fixed query returns £240,000,000.
- **Row count.** 12 rows in SQL Server, 14 in SQLite (where "london" and `"London "` are separate groups); `SELECT COUNT(DISTINCT region) FROM dbo.loan_tape` returns the same number in each engine.
- **London in SQLite.** The exact value "London" holds £38,749,038; adding "london" (£222,329) and `"London "` (£144,275) gives SQL Server's £39,115,642.
- **A grouped column without an aggregate is fine.** `SELECT region FROM dbo.loan_tape GROUP BY region` runs: it is the same as `SELECT DISTINCT region`. The error appears only when an aggregate and an ungrouped column meet.

#### Mistakes people make on this exercise

- **Fixing it with `MAX(region)`.** The query runs, but shows "Yorkshire and the Humber" next to the pool total: an answer to a question nobody asked.
- **Putting the condition in `WHERE`.** `WHERE region = 'London'` with no `GROUP BY` gives London's total, but only because the select list then shows a constant; it does not answer "by region".
- **Explaining the error as a syntax error.** The syntax is valid; the meaning is not. Interviewers want the rule: grouped or aggregated.
- **Adding `DISTINCT`.** `SELECT DISTINCT region, SUM(current_balance) FROM dbo.loan_tape` fails with the same Msg 8120: `DISTINCT` removes duplicate output rows, it does not group.

#### Trade-offs and going further

- **Strict engines or lenient ones.** SQL Server and PostgreSQL refuse the query; SQLite and older MySQL versions accept it. Write queries that are valid in the strict engines, and they run correctly everywhere.
- **Clean before grouping.** `GROUP BY UPPER(TRIM(region))` gives the same 12 groups in every engine, but displays upper-case names; a mapping table gives clean names.
- **Going further.** Add `HAVING SUM(current_balance) > 20000000` to list only regions above £20m, and explain why that condition cannot go in `WHERE`.
- **Window instead of group.** If the author wanted each loan with the pool total beside it, the answer is a window: `SELECT loan_id, region, SUM(current_balance) OVER () AS pool_total FROM dbo.loan_tape` keeps every row and adds the total. Asking "one row per region, or one row per loan?" is the right first question.

### Exercise 8: up to date in April, 2+ behind in June

#### What the question asks

> Using `dbo.loan_history`, write a query for the number of loans that were up to date in April and 2 or more months behind in June.

In plain words: the history table has one row per loan per month. You must find the loans whose April row shows no arrears and whose June row shows 2 or more months in arrears, and count them. These are the loans that went wrong quickly: two months ago they were paying normally.

The exercise uses the history table and its columns `loan_id`, `month_end`, `arrears_months` and `status` (Section 17.10, *Working with history*), the JOIN of Section 17.5, and the difference between a condition in `ON` and a condition in `WHERE` (Section 17.14).

#### The plan

1. **See why one copy of the table is not enough.** April and June are different rows; a single `WHERE` cannot test two rows of the same loan at once.
2. **Join the history table to itself** on `loan_id`: one copy supplies each loan's April row, the other its June row.
3. **Filter each copy to its month and condition,** then count.
4. **List the loans before counting,** so that the result can be checked by eye.

#### Step by step

**Step 1: why one table fails.** A first attempt:

```sql
SELECT COUNT(*) FROM dbo.loan_history
WHERE month_end = '2026-04-30' AND arrears_months = 0
  AND month_end = '2026-06-30' AND arrears_months >= 2;
```

It returns **0**: no single row can have two month-ends at once. The two conditions belong to two different rows of the same loan.

**Step 2: two copies of the table.** Give each copy its own name (an alias):

```sql
FROM dbo.loan_history a
JOIN dbo.loan_history j
  ON j.loan_id = a.loan_id
```

- `a` will hold the April rows, `j` the June rows.
- `ON j.loan_id = a.loan_id` pairs each loan's April row with its rows in `j`, so the conditions can look at both months side by side.

**Step 3: the month conditions.** The June conditions go in `ON`, so that each April row is paired only with its own June row; the April conditions go in `WHERE`:

```sql
SELECT a.loan_id, a.arrears_months AS apr_arrears,
       j.arrears_months AS jun_arrears, j.current_balance
FROM dbo.loan_history a
JOIN dbo.loan_history j
  ON j.loan_id = a.loan_id
 AND j.month_end = '2026-06-30'
 AND j.status = 'Active'
WHERE a.month_end = '2026-04-30'
  AND a.arrears_months = 0
  AND j.arrears_months >= 2
ORDER BY a.loan_id;
```

- `j.month_end = '2026-06-30'` keeps only the June row of each loan.
- `j.status = 'Active'` excludes loans that redeemed in June; their arrears are 0 anyway, but the condition states the intent.
- `a.month_end = '2026-04-30' AND a.arrears_months = 0` keeps the loans that were up to date in April.
- `j.arrears_months >= 2` keeps those 2 or more months behind in June.

The list has **12 loans**, from ASH100073 to ASH100990, every one 2 months behind in June, with a total balance of **£2,898,113**.

**Step 4: the count.** Replace the column list with `COUNT(*) AS loans` and remove `ORDER BY`. Result: **12**.

#### Reading the result

- **Twelve loans, £2.9 million, went from up to date to 2 months behind in two months.** They missed both the May and the June payment.
- **None has reached 3 months yet**, the usual definition of default. If they miss July too, they move into the bucket that the 3+ month arrears trigger counts.
- **For the monthly report**, this list is the early warning: surveillance analysts watch loans entering arrears, not only loans already deep in them, because the roll rate from 2 to 3 months decides next month's arrears ratio.

- **These loans are the next month's risk.** A loan 2 months behind in June will be 3 months behind in July if it misses one more payment, and will then count in the arrears ratio that triggers test. Twelve loans of £2.9 million is 1.2% of the pool: if all of them rolled, the 3+ ratio would rise from 1.94% to over 3%.

#### Checking your answer

- **Check the path through May.** Join a third copy for May (`m.month_end = '2026-05-31'`) and group by its arrears: all 12 loans show **1 month** in May. That is exactly the path expected: 0 in April, 1 in May, 2 in June.
- **Check with another tool.** The same 12 loans come out of a pandas merge of the April and June rows (Chapter 18), and out of two SUMIFS columns in Excel (Chapter 16's Movements sheet extended to April).
- **Check the population.** April has 1,234 rows, 1,158 of them up to date. Twelve of 1,158 (1.0%) deteriorating this fast is plausible for a pool whose arrears are rising.

#### Mistakes people make on this exercise

- **Forgetting the June month condition.** Without `j.month_end = '2026-06-30'`, each April row is paired with every month of the same loan, and any month with 2+ arrears counts. The query returns **32** rows, some of them the same loan counted twice. The symptom: a count larger than the list of distinct loans. The fix: fix the month of each copy.
- **Testing two months on one table.** As Step 1 shows, the result is 0, which looks like a real answer. Always ask: can one row satisfy all these conditions?
- **`> 2` instead of `>= 2`.** That asks for 3 or more months and returns none of the 12.
- **Putting the June conditions in `WHERE` with a LEFT JOIN.** With an inner join it makes no difference; with a LEFT JOIN, it silently turns the join into an inner one (Section 17.14). Keep the habit of putting each table's conditions in its own place.

#### Trade-offs and going further

- **A self-join or a window function.** For two months, the self-join is clear. For a path over all six months, `LAG(arrears_months, 2) OVER (PARTITION BY loan_id ORDER BY month_end)` (Section 17.7) gives each row the value two months earlier in one pass, and scales to any number of months.
- **Counting loans or balance.** The count shows how many borrowers are in difficulty; the balance (£2.9 million, 1.2% of the pool) shows how much money. Reports show both.
- **Going further.** Change the June condition to `>= 1` to count all loans that were up to date in April and behind in June: the answer is **55**, which adds the 43 loans that missed only one payment.

### Exercise 9: buy-to-let up to 75% indexed LTV in the pool cut

#### What the question asks

> Change the pool cut to allow buy-to-let loans up to 75% indexed LTV. How many loans and how much balance are now eligible?

In plain words: query 10.2 in Section 17.11 selects the loans that meet the eligibility criteria for a new deal, and one of its criteria excludes every buy-to-let loan. The new rule keeps owner-occupied loans as before but also lets in buy-to-let loans whose indexed LTV is 75% or less. You must change the query and report the new count and balance.

The exercise uses the `WHERE` clause with several conditions (Section 17.2), the pool cut (Section 17.11), and one rule of logic that catches many candidates: `AND` is applied before `OR` unless brackets say otherwise. The business meaning of eligibility criteria is in Chapter 4.

#### The plan

1. **Run the original pool cut** to know the starting point. You cannot explain a change without the "before".
2. **Write the new condition** as one bracketed `OR`: owner-occupied, or indexed LTV of 75% or less.
3. **Run the new cut** and compare with the original.
4. **Prove the difference** by counting the buy-to-let loans that the new rule lets in. The before, the after and the difference must agree.

#### Step by step

**Step 1: the original cut.** Query 10.2:

```sql
SELECT COUNT(*) AS eligible_loans,
       SUM(current_balance) AS eligible_balance
FROM dbo.loan_tape
WHERE arrears_months = 0
  AND possession_flag = 'N'
  AND seasoning_months >= 3
  AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
  AND occupancy = 'Owner-occupied';
```

- `COUNT(*)` and `SUM(current_balance)` return one row: the size of the eligible pool.
- Each `AND` adds one criterion; a loan is eligible only if all seven are true.
- `arrears_months = 0`: up to date. `possession_flag = 'N'`: not repossessed. `seasoning_months >= 3`: at least three payments made.
- `indexed_ltv <= 0.90`: LTVs are stored as decimals, so 90% is 0.90.
- `current_balance <= 750000` and `remaining_term_months <= 420`: the size and term limits.
- The last line is the one the exercise changes.

Result: **892 loans, £175,064,566**.

**Step 2: the new condition.** Replace the last line with:

```sql
  AND (occupancy = 'Owner-occupied' OR indexed_ltv <= 0.75);
```

- The brackets make the `OR` one criterion: "owner-occupied, or LTV at most 75%".
- An owner-occupied loan passes whatever its LTV (the 90% limit above still applies to it).
- A buy-to-let loan passes only if its indexed LTV is 0.75 or less.

**Step 3: run the new cut.** The query is the original with the new last line. Result: **1,082 loans, £215,298,938**.

**Step 4: count the loans that came in.** The difference should be the buy-to-let loans that meet the six other criteria and have an LTV of at most 75%:

```sql
SELECT COUNT(*) AS loans, SUM(current_balance) AS balance
FROM dbo.loan_tape
WHERE arrears_months = 0
  AND possession_flag = 'N'
  AND seasoning_months >= 3
  AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
  AND occupancy = 'Buy-to-let'
  AND indexed_ltv <= 0.75;
```

Result: **190 loans, £40,234,372**.

#### Reading the result

- **The eligible pool grows by 190 loans and £40.2 million**, from £175.1 million to £215.3 million: 23% more balance for the new deal.
- **Most landlords' loans qualify.** Of the 194 buy-to-let loans that pass the other six criteria, 190 have an indexed LTV of 75% or less; only 4 sit between 75% and 90%. Buy-to-let lenders usually lend at lower LTVs, so a 75% limit removes few loans.
- **The new pool is 18.69% buy-to-let by balance**, and its WA indexed LTV falls from 60.75% to 59.77%, because the buy-to-let loans that come in have low LTVs. A credit committee would see a larger pool with a lower LTV but a new risk type, landlords, whose income depends on rents.

- **The four excluded buy-to-let loans** are the ones with indexed LTVs between 75% and 90%. A query listing them (`AND occupancy = 'Buy-to-let' AND indexed_ltv > 0.75`) gives the arranger the exact loans a 75% limit removes, which is the first thing they will ask for.

#### Checking your answer

The before, the after and the difference must agree:

- Loans: 892 + 190 = 1,082. ✔
- Balance: £175,064,566 + £40,234,372 = £215,298,938. ✔

A second, independent check groups the six common criteria by occupancy:

```sql
SELECT occupancy, COUNT(*) AS loans,
       SUM(current_balance) AS balance
FROM dbo.loan_tape
WHERE arrears_months = 0 AND possession_flag = 'N'
  AND seasoning_months >= 3 AND indexed_ltv <= 0.90
  AND current_balance <= 750000
  AND remaining_term_months <= 420
GROUP BY occupancy;
```

It returns Owner-occupied 892 (£175,064,566) and Buy-to-let 194 (£40,991,479). The owner-occupied row is the original cut exactly, and the new rule admits 190 of the 194 buy-to-let loans.

#### Mistakes people make on this exercise

**Leaving out the brackets.** This is the commonest SQL logic error in interviews:

```sql
  AND occupancy = 'Owner-occupied' OR indexed_ltv <= 0.75;
```

`AND` binds before `OR`, so SQL reads it as "(all seven criteria) OR (LTV at most 75%)". Every loan with an LTV of 75% or less now passes, even if it is in arrears or in possession. The result is **1,161 loans, £231,800,402**, 79 loans too many. The symptom: loans in arrears appear in the eligible pool. The fix: brackets around the `OR`.

**Writing 75 instead of 0.75.** `indexed_ltv <= 75` is true for every loan (LTVs are below 1), so every buy-to-let loan passes the LTV part and the result has 194 buy-to-let loans instead of 190.

**Replacing the occupancy line instead of widening it.** `AND occupancy = 'Buy-to-let' AND indexed_ltv <= 0.75` returns only the 190 new loans, not the new pool. Read the question: "now eligible" means the whole eligible pool.

#### Trade-offs and going further

- **One query or a view.** Editing query 10.2 is fine for an interview. In a real team, eligibility criteria change with each deal; storing them in a view or a stored procedure with parameters (`@max_btl_ltv`) keeps one version of the rules and makes each change visible.
- **A larger pool against a new risk.** The cut grows by 23%, which helps fund the bank. But rating agencies assess buy-to-let separately (rental cover, portfolio landlords), so the credit enhancement for the deal can rise. The analyst's job is to show both sides with numbers.
- **A rule change is a decision, not a query.** In practice the analyst does not choose the 75% limit: the treasury team and the arranger agree it, often after asking the rating agencies what each option would cost in credit enhancement. The analyst's job is to give them the before, the after and the difference, quickly and correctly, for each option they consider: 70%, 75%, 80%.
- **Going further.** Rerun query 10.3 (one row per failed criterion) with the new rule. The "Buy-to-let" row must now count only the buy-to-let loans above 75%.
