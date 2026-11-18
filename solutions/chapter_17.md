# Chapter 17: SQL for structured finance: the queries that matter

## Corrections

### Exercise 1: a balance-size strat with CASE

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

### Exercise 2: up to date in April, 2+ behind in June

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

### Exercise 3: buy-to-let up to 75% indexed LTV in the pool cut

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
