# Chapter 21: Practice test 3: the timed Excel skills test

## Solution

### Task 1: links

#### What the question asks

> Task 1: Make each task name in the list a link to its sheet

In plain words: every task name on the task list must open its sheet with one click.

#### The plan

1. **Choose the method**: Insert → Link for a few rows, `HYPERLINK` for many.
2. **Point each link at its sheet** with `#` and the sheet name in quotes.
3. **Click each link once** to test it.

#### Step by step

Click the cell for a task, press **Ctrl + K** (Mac: **Cmd + K**), choose **Place in This Document** (Mac: **This Document**) and pick the sheet; repeat for each row. A formula is faster for twelve rows:

```
=HYPERLINK("#'2 Lists'!A1", "2 Lists")
```

`#` means "a place in this workbook". Each task sheet already has a "Back to the task list" link in A3, so the marker can move around the file in both directions. (Chapter 16, *Ranking, links and red, amber and green*.)

#### Reading the result

Twelve links that open the right sheet; each sheet links back from A3.

#### Checking your answer

Click every link once; a wrong sheet name gives "Reference isn't valid".

#### Mistakes people make on this question

- Leaving out `#`, which makes Excel look for a file instead of a sheet; quotes missing around a sheet name with a space.
- **Linking to a cell on the wrong sheet** because the sheet was renamed after the link was made; test every link at the end.

#### Trade-offs and going further

Insert → Link shows the marker you know the menu; HYPERLINK is faster and survives copying rows.

### Task 2: drop-down lists

#### What the question asks

> Task 2: Drop-down lists: Y or N in column H; a status from the table K5:K8 in column I

In plain words: two columns that accept only values from a list, one typed and one taken from a range.

#### The plan

1. **Select the input range** before opening Data Validation, so the rule covers every cell.
2. **Type the short list; point the long list at its range**, so it can grow.
3. **Set the Error Alert to Stop** and test a wrong entry.

#### Step by step

Select H5:H14, **Data → Data Validation → Allow: List**, Source `Y,N`. Select I5:I14, Allow: List, Source `=$K$5:$K$8`. Fill the ten rows. Test each rule: typing "Yes" in H5 must be refused.

The second list points to a range rather than a typed list, so a new status added in K9 needs only the range changed. A marker checks this by opening the rule.

#### Reading the result

Every cell in H5:I14 offers its list and refuses other entries.

#### Checking your answer

Type "Yes" in H5: Excel must refuse it. Then open the rule to show the source.

#### Mistakes people make on this question

- The Error Alert set to Warning or Information, which lets wrong values in.
- **Selecting one cell before setting the rule**, so only H5 is validated.

#### Trade-offs and going further

A typed list is quick; a range list can be extended without editing the rule, which a marker notices.

### Task 3: PivotTable

#### What the question asks

> Task 3: PivotTable: count of loans by region (rows) and rate type (columns); copy the counts into the grid

In plain words: a count of loans by region and rate type, copied into the grid, with a total check.

#### The plan

1. **Insert the PivotTable** on the data range, below the data.
2. **Rows, Columns, Values**: region, rate type, count of loan IDs.
3. **Fill the grid** with COUNTIFS (or links to the pivot) and check the total.

#### Step by step

Click inside A4:D44, **Insert → PivotTable → Existing worksheet**, choose a cell below the data (for example A47). Drag `region` to Rows, `rate_type` to Columns and `loan_id` to Values (Count). Then copy the counts into the green grid, or link to them.

| Region | Fixed | SVR | Tracker | Total |
|---|---:|---:|---:|---:|
| East Midlands | 2 | 0 | 0 | 2 |
| East of England | 1 | 0 | 1 | 2 |
| Greater London | 0 | 1 | 0 | 1 |
| London | 3 | 0 | 0 | 3 |
| North East | 2 | 0 | 0 | 2 |
| North West | 4 | 1 | 0 | 5 |
| Scotland | 3 | 1 | 0 | 4 |
| South East | 5 | 1 | 1 | 7 |
| South West | 4 | 1 | 1 | 6 |
| Wales | 2 | 0 | 0 | 2 |
| West Midlands | 1 | 0 | 0 | 1 |
| Yorkshire and the Humber | 2 | 1 | 2 | 5 |
| **Total** | **29** | **6** | **5** | **40** |

The solution file fills the grid with `=COUNTIFS($B$5:$B$44,$G5,$C$5:$C$44,H$4)`, which gives the same numbers and updates without a refresh. A PivotTable does not update when the data changes until you click **Refresh**: say so in a note next to it. The check cell (grand total − number of loans) must be 0.

"Greater London" appears as its own row. Do not fix it silently in a test: note it ("Greater London is not an allowed region; it should be mapped to London").

#### Reading the result

40 loans: Fixed 29, SVR 6, Tracker 5; "Greater London" stands out as a separate row.

#### Checking your answer

Grand total − 40 = 0 in the check cell.

#### Mistakes people make on this question

- Count of `region` instead of `loan_id` when a region is blank; fixing the data silently in a test.
- **Copying the pivot's numbers as values** without a note that they need refreshing when the data change.

#### Trade-offs and going further

A PivotTable is fastest; COUNTIFS updates without Refresh. In a test, build the PivotTable and say in a note that it needs refreshing.

### Task 4: the chart

#### What the question asks

> Task 4: Line chart of pool balance and 3+ months arrears, January to June 2026, with a title and both axes named

In plain words: a chart showing the pool balance and the 3+ months arrears ratio over six months, readable at a glance.

#### The plan

1. **Choose a line chart**: a trend over months.
2. **Put the ratio on a secondary axis**, because it is in percent and the balance in pounds.
3. **Title the point, name both axes**, remove clutter.

#### Step by step

Select A4:C10, **Insert → Line chart**. Right-click the arrears line, **Format Data Series → Series Options → Secondary Axis**. Add the chart title and both axis titles, and format the right-hand axis as `0.0%`. (Chapter 16, *Charts that explain*.)

A title that states the point earns full marks: "Ashcombe pool: balance down from £255.4m to £240.0m, 3+ months arrears up from 0.74% to 1.94%". The marks go to:

- a line chart, not a column chart (a trend over time);
- the second measure on a secondary axis, so the arrears line is not flat along the bottom;
- a title and two named axes with units;
- no 3-D, no gridline clutter, months in date order.

#### Reading the result

The pool shrinks while serious arrears more than double: the title says so.

#### Checking your answer

Both lines move visibly; the right axis shows percentages.

#### Mistakes people make on this question

- A column chart for a time series; the arrears line flat along the bottom on the same axis as balances.
- **Months as text out of order**; use real dates or a fixed order.

#### Trade-offs and going further

Two axes can mislead if the scales exaggerate a trend; start both at sensible values and say what each measures.

### Task 5: VLOOKUP

#### What the question asks

> Task 5: The collections team for each loan's region; "Not mapped" where the region is not in the table

In plain words: each loan's collections team from a lookup table, and "Not mapped" where its region is missing.

#### The plan

1. **Write VLOOKUP with an exact match** and a fixed table.
2. **Wrap it in IFNA** for regions not in the table.
3. **Answer the follow-up with SUMIFS** on the team and arrears.

#### Step by step

In E5, copied down to E44:

```
=IFNA(VLOOKUP(B5, $H$5:$I$15, 2, FALSE), "Not mapped")
```

- `$H$5:$I$15` is fixed with $ signs, so it does not move when copied.
- `2` returns the table's second column, the team.
- `FALSE` asks for an exact match. Without it, VLOOKUP assumes the table is sorted and can return a wrong team with no error.
- `IFNA` replaces only the not-found error (`#N/A`) with "Not mapped".

One loan is not mapped: ASH101151, "Greater London". The balance in arrears handled by the North team is **£672,585** (`=SUMIFS(C5:C44, E5:E44, "North", D5:D44, ">0")`).

#### Reading the result

One loan cannot be mapped ("Greater London"); North's arrears balance is £672,585.

#### Checking your answer

Filter the team column for "Not mapped": one row.

#### Mistakes people make on this question

- Leaving out FALSE; IFERROR, which hides every error, not only #N/A.
- **A table range without `$`**, which moves when copied and returns #N/A lower down.

#### Trade-offs and going further

XLOOKUP is simpler where available; the test asks for VLOOKUP, so use it and know its limits.

### Task 6: HLOOKUP

#### What the question asks

> Task 6: Months in arrears for five loan and month pairs

In plain words: the arrears of five loan and month pairs, read from a table with months across the top.

#### The plan

1. **HLOOKUP finds the month** along the header row.
2. **MATCH finds the row** of the loan inside the table.
3. **Check one result by eye.**

#### Step by step

In K5, copied down:

```
=HLOOKUP(J5, $A$4:$G$44, MATCH(I5, $A$4:$A$44, 0), FALSE)
```

The month in J5 is found along the header row; MATCH gives the row of the loan inside the table (the header row counts as row 1).

| Loan | Month end | Months in arrears |
|---|---|---:|
| ASH100019 | June 2026 | 3 |
| ASH100019 | March 2026 | 0 |
| ASH101151 | June 2026 | 0 |
| ASH100190 | February 2026 | 2 |
| ASH100063 | May 2026 | 1 |

ASH100019 went from up to date in March to 3 months behind in June: a loan to name in the commentary.

#### Reading the result

ASH100019 moved from up to date in March to 3 months behind in June.

#### Checking your answer

Look up one result by eye in the table.

#### Mistakes people make on this question

- Counting the row number from the sheet's row 1 instead of the table's first row.
- **Mixing up HLOOKUP's row index**: the header row counts as row 1.

#### Trade-offs and going further

INDEX/MATCH/MATCH does the same in any direction; HLOOKUP is what the test asks and is fine for a fixed table.

### Task 7: SUMIF and SUMIFS

#### What the question asks

> Task 7: Balance by region, and by region and rate type, with two checks

In plain words: balances by region and by region and rate type, each with a check against the data.

#### The plan

1. **SUMIF for one condition, SUMIFS for two.**
2. **Mixed references** so one formula fills the whole grid.
3. **Two checks**: regions against the data, rate types against regions.

#### Step by step

H5 (balance by region) and I5 (by region and rate type), copied across and down:

```
=SUMIF($B$5:$B$44, G5, $D$5:$D$44)
=SUMIFS($D$5:$D$44, $B$5:$B$44, $G5, $C$5:$C$44, I$4)
```

The mixed references do the work: `$G5` keeps the region column fixed when copied across, and `I$4` keeps the header row fixed when copied down. The totals are £9,294,430, of which Fixed £7,115,395, SVR £1,297,739 and Tracker £881,296. Both checks are 0: the region total equals the data, and the three rate types add up to the region total.

#### Reading the result

Total £9,294,430: Fixed £7,115,395, SVR £1,297,739, Tracker £881,296.

#### Checking your answer

Both check cells are 0.

#### Mistakes people make on this question

- Absolute references everywhere, so the copied formula repeats the same cell.
- **Typing the region names inside the formulas** instead of referring to the cells.

#### Trade-offs and going further

One formula copied across the grid is fast to write and to audit; a separate formula in each cell invites inconsistency.

### Task 8: COUNTIF and COUNTIFS

#### What the question asks

> Task 8: Loans and balance in each arrears bucket; a check on the total

In plain words: counts and balances for four arrears buckets, with a total check.

#### The plan

1. **Limits in cells**, joined to operators with `&`.
2. **COUNTIFS and SUMIFS** with two conditions each.
3. **A total and a check** against the data.

#### Step by step

With each bucket's limits in G and H:

```
=COUNTIFS($C$5:$C$44, ">="&G5, $C$5:$C$44, "<="&H5)
```

| Bucket | Loans | Balance (£) |
|---|---:|---:|
| Up to date | 33 | 7,337,873 |
| 1 month | 2 | 436,214 |
| 2 months | 2 | 720,983 |
| 3+ months | 3 | 799,360 |
| **Total** | **40** | **9,294,430** |

`">="&G5` joins the operator to the cell's value; typing `">=G5"` would compare with the text "G5" and count nothing. The loans in arrears, `=COUNTIF($C$5:$C$44,">0")`, are 7.

#### Reading the result

7 of the 40 loans are in arrears, 3 of them 3+ months.

#### Checking your answer

Total: 40 loans and £9,294,430.

#### Mistakes people make on this question

- Typing `">=G5"`, which compares with the text "G5".
- **Overlapping buckets** (`>=` on both ends), which count a loan twice; the total check catches it.

#### Trade-offs and going further

Limits in cells let the buckets change without editing formulas; typed limits are quicker but brittle.

### Task 9: IF and bands

#### What the question asks

> Task 9: Flag loans above the LTV limit; label five LTV bands and count the loans in each

In plain words: a flag for loans above an LTV limit, and a band label and count for each loan.

#### The plan

1. **IF against an input cell** for the flag.
2. **Band labels built from the limits** with TEXT.
3. **INDEX/MATCH with approximate match** for each loan's band, then COUNTIF and a check.

#### Step by step

The flag, in E5: `=IF(C5>$K$2, "High", "OK")`. The limit sits in its own input cell, K2 (80%), so changing it updates every flag: five loans are above 80%, and at 70% the count rises to 12.

The band labels are built from the limits, so they cannot disagree with them:

```
=IF(H5=0, "Up to "&TEXT(I5,"0%"),
    "Over "&TEXT(H5,"0%")&" to "&TEXT(I5,"0%"))
```

Each loan's band, in F5:

```
=INDEX($J$5:$J$9, MATCH(C5-0.0000001, $H$5:$H$9, 1))
```

MATCH with 1 finds the largest lower limit that is **below** the value. Subtracting a tiny amount puts a loan at exactly 60% into "Over 50% to 60%", which matches the band rule "over the lower limit, up to the upper". The counts are 13, 11, 4, 7 and 5, and the check (total − 40) is 0. A nested IF works too, but it is longer and harder for a marker to read.

#### Reading the result

Five loans above 80%; the bands hold 13, 11, 4, 7 and 5 loans.

#### Checking your answer

Change K2 to 70%: the flag count rises to 12. The band check (total − 40) is 0.

#### Mistakes people make on this question

- Typing 0.8 inside the IF formula; a loan at exactly a limit put into the higher band.
- **Nested IFs that disagree with the band table** after a limit changes.

#### Trade-offs and going further

INDEX/MATCH is short and follows the limit table; a nested IF is easier for some readers but grows with every band.

### Task 10: ROUND

#### What the question asks

> Task 10: Balances in £000s; compare the sum of rounded figures with the rounded total, and explain

In plain words: rounded balances, their sum against the rounded total, and a written explanation of the difference.

#### The plan

1. **ROUND each balance** to £000.
2. **Compare** the sum of the rounded figures with the total rounded once.
3. **Explain** why they differ and how a report shows it.

#### Step by step

C5: `=ROUND(B5/1000, 0)`. The sum of the rounded figures is **9,295** (£000); the total rounded once is **9,294**. The difference is 1.

Written answer: each figure is rounded on its own, so the small errors add up. A report shows the rounded total of the exact figures, and a footnote says that rows may not add up to the total because of rounding. Never adjust one row to force the total.

#### Reading the result

9,295 against 9,294: rounding each row adds small errors.

#### Checking your answer

Recompute the exact total: £9,294,430 → 9,294.

#### Mistakes people make on this question

- Forcing one row so the table adds up.
- **Rounding the total from the rounded rows** and hiding the difference.

#### Trade-offs and going further

A rounding footnote keeps every figure honest; reports that must add exactly round the components with a documented method.

### Task 11: RANK

#### What the question asks

> Task 11: Rank the loans by balance; list the top 10 so that it updates by itself

In plain words: a rank for every loan and a top-ten list that updates when the data change.

#### The plan

1. **RANK.EQ** for each loan, descending.
2. **INDEX/MATCH on the rank** to list the top ten.
3. **Shares of the extract** for each.

#### Step by step

C5: `=RANK.EQ(B5, $B$5:$B$44, 0)`. The top 10, in G5 and H5:

```
=INDEX($A$5:$A$44, MATCH(F5, $C$5:$C$44, 0))
=INDEX($B$5:$B$44, MATCH(F5, $C$5:$C$44, 0))
```

| Rank | Loan | Balance (£) | % of extract |
|---:|---|---:|---:|
| 1 | ASH100063 | 527,026 | 5.7% |
| 2 | ASH100027 | 456,397 | 4.9% |
| 3 | ASH100024 | 454,106 | 4.9% |
| 4 | ASH100003 | 424,354 | 4.6% |
| 5 | ASH100030 | 406,752 | 4.4% |
| 6 | ASH100019 | 367,870 | 4.0% |
| 7 | ASH100026 | 360,180 | 3.9% |
| 8 | ASH100012 | 321,429 | 3.5% |
| 9 | ASH100011 | 316,993 | 3.4% |
| 10 | ASH100175 | 308,246 | 3.3% |

The ten largest loans are 42.4% of the extract: in a pool of 40 loans, concentration is high. There are no ties here; say in a note how you would handle them (Chapter 16).

#### Reading the result

The ten largest loans are 42.4% of the extract: high concentration in 40 loans.

#### Checking your answer

The ranks run 1 to 40 with no gaps (no ties).

#### Mistakes people make on this question

- Ranking in ascending order (last argument 1).
- **A top ten typed as values**, which does not update when the data change.

#### Trade-offs and going further

With ties, RANK.EQ repeats a rank and MATCH finds only the first; add COUNTIF on the rows above to break ties.

### Task 12: the dashboard

#### What the question asks

> Task 12: Four indicators, three of them with a red, amber or green status coloured by conditional formatting

In plain words: a four-line dashboard with values linked to the task sheets and a coloured status.

#### The plan

1. **Link each value** to the sheet that computes it.
2. **One status formula** comparing the value with the thresholds.
3. **Three conditional formatting rules** for the colours.

#### Step by step

| Indicator | Value (B) | Amber from (C) | Status (D) | Red from (E) |
|----------------------------------|-----------:|--------------:|-----------|------------:|
| Balance of the extract | £9,294,430 | | n/a | |
| WA indexed LTV | 57.82% | 65.0% | Green | 70.0% |
| Largest loan as % of the extract | 5.67% | 5.0% | Amber | 7.0% |
| Balance 3+ months in arrears | 8.60% | 2.0% | Red | 4.0% |

The values link to the other sheets (`=MAX('11 RANK'!B5:B44)/SUM('11 RANK'!B5:B44)`, `='8 COUNTIFS'!J8/'8 COUNTIFS'!J9`), so the dashboard updates with the data. The status uses one formula, `=IF(B7>=E7,"Red",IF(B7>=C7,"Amber","Green"))`, and three conditional formatting rules colour it. Arrears are red because the extract was chosen to contain them: 8.60% against 1.94% for the whole pool. Say this in a note; a dashboard number without context misleads.

#### Reading the result

LTV is green, the largest loan amber and arrears red, because the extract was chosen to contain arrears.

#### Checking your answer

Change a threshold and watch the status and colour move.

#### Mistakes people make on this question

- Typed values that do not update; colours set by hand.
- **One rule for all three colours**, which paints every status the same; each colour needs its own rule with its own condition.

#### Trade-offs and going further

A dashboard without context misleads: a one-line note on how the extract was chosen is worth the marks.

## Marking guide

| Task | Full marks | Typical lost marks |
|---|---|---|
| 1 | Every link works, in both directions | Links typed as text; one sheet missed |
| 2 | Both rules refuse other entries; the status list points to the range | List typed into the rule instead of referring to K5:K8 |
| 3 | Counts correct; total checked; note on Refresh and on "Greater London" | Sum of balance instead of count of loans; no total |
| 4 | Line chart, secondary axis, title and named axes | Arrears flat on the main axis; no title |
| 5 | Exact match, fixed range, "Not mapped" | Fourth argument left out; `#N/A` left showing |
| 6 | HLOOKUP with MATCH for the row | Row number typed by hand, so it breaks for other loans |
| 7 | Mixed references; both checks 0 | Typed totals; checks missing |
| 8 | Operator joined with `&`; total checked | `">=G5"` in quotes; a bucket missed |
| 9 | Limit in an input cell; labels built from limits; boundaries right | Limit typed inside the formula; a loan at exactly 60% in the wrong band |
| 10 | Both totals and a sensible written answer | Answer forces one row to fit |
| 11 | RANK.EQ and an INDEX/MATCH list that updates | List sorted by hand |
| 12 | Linked values, formula status, colours by rule | Colours painted by hand; values typed |

As a guide, 85 or more is a strong pass; 60 to 84, redo the tasks you lost marks on; below 60, reread the Chapter 16 sections named above, then retake the whole test.

> **Tips**
>
> - Keep a small "Notes" box on each sheet for assumptions and anything odd in the data ("Greater London not mapped"). Markers give marks for spotting problems they planted.
> - Leave formulas, not values. A marker who changes one balance and sees nothing move assumes the answer was typed.
> - Use the same layout on every sheet: inputs in blue, answers in green, checks in yellow showing 0.
> - Save a copy every ten minutes with the time in the file name, and send the file in the format asked for (`.xlsx`, not `.xlsm` or a PDF).

> **Common beginner mistakes**
>
> - **VLOOKUP without FALSE**, which returns the nearest match without warning.
> - **COUNTIFS with the cell inside the quotes** (`">=G5"`).
> - **A PivotTable that is not refreshed** after the data changes.
> - **Hard-coded limits** inside IF formulas.
> - **Colours painted by hand** on a dashboard, which do not change when the numbers do.
> - **Spending 25 minutes on the chart** and leaving formula tasks blank.

> **interview**
>
> **"The test asked for VLOOKUP. What would you use at work?"**
>
> > "XLOOKUP, or INDEX with MATCH in older versions, because they don't break when someone inserts a column and they can look to the left. But I used VLOOKUP with FALSE and IFNA as asked, and the result is the same."
>
> **"Your dashboard shows arrears at red. What do you do?"**
>
> > "First I check the number: it's 8.6% of a 40-loan extract chosen to include arrears, against 1.94% for the whole pool, so it's the sample, not the deal. On a real dashboard I'd check the data, look at which loans moved into 3+ months, and send a short note to the owner of the limit with the loans named before anyone asks."

> **Essential to keep in mind**
>
> - Screening tests check speed and tidiness with everyday functions: lookups, SUMIFS and COUNTIFS, IF, ROUND, RANK.EQ, a PivotTable, a chart, data validation and conditional formatting.
> - Read every sheet first; do the formula tasks before the chart and the dashboard.
> - Every answer is a formula, every limit is in an input cell, every total has a check, and anything odd in the data is noted.
