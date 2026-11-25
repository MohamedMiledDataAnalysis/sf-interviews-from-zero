# Chapter 16: Excel for structured finance: the formulas that matter

> © 2026 Mohamed Miled. All rights reserved. This text is part of the book *Structured Finance Interviews from Zero* and may not be copied, republished or sold. The code blocks are under the MIT licence (see `LICENSE`); the explanations are not (see `LICENSE-TEXT.md`).

## Corrections

### Exercise 1: WA original LTV of buy-to-let loans

#### What the question asks

> On the Metrics sheet, add the WA **original** LTV for **buy-to-let** loans only, using SUMPRODUCT with a condition.

In plain words: the Metrics sheet already shows the pool's balance-weighted original LTV. You must add a new row with the same measure for one group only, the buy-to-let loans, using a single SUMPRODUCT formula that switches the other loans off.

The exercise uses SUMPRODUCT for a weighted average (Section 16.4), SUMIFS for the total of a group (Section 16.5), the `$` signs of absolute references (Section 16.2), and the original LTV of Chapter 10 (Section 10.3). The `Tape` sheet holds `original_ltv` in column K, `current_balance` in H and `occupancy` in P, rows 2 to 1201.

#### The plan

1. **Recall the pool formula** in Metrics!B8: SUMPRODUCT(LTV, balance) ÷ SUM(balance). The group version is the same formula with a condition.
2. **Build the condition** as an array of 1s and 0s that is 1 only for buy-to-let loans.
3. **Divide by the buy-to-let balance**, not the pool's, so that the average is over the group.
4. **Check the result** against the pool figure and against a second method.

Write the formula in one go only once each part has been tested: in a timed test, a formula built in pieces and checked is faster than a long formula debugged at the end.

#### Step by step

**Step 1: the label.** In A20 type "WA original LTV, buy-to-let", so the marker finds the answer at once.

**Step 2: the numerator.** In B20 start the formula:

```
=SUMPRODUCT((Tape!$P$2:$P$1201="Buy-to-let")
  *Tape!$K$2:$K$1201*Tape!$H$2:$H$1201)
```

- `(Tape!$P$2:$P$1201="Buy-to-let")` compares each loan's occupancy with "Buy-to-let" and returns TRUE or FALSE for each of the 1,200 rows.
- Multiplying by the LTV column turns TRUE into 1 and FALSE into 0, so the other loans contribute nothing.
- `*Tape!$H$2:$H$1201` weights each LTV by its balance; SUMPRODUCT adds the 1,200 products. For buy-to-let the sum is £28,695,274 (LTV × balance, in pounds).
- The `$` signs keep the ranges fixed if the formula is copied.

**Step 3: the denominator.** Complete the formula:

```
 /SUMIFS(Tape!$H$2:$H$1201,Tape!$P$2:$P$1201,"Buy-to-let")
```

- SUMIFS adds the balances where occupancy is "Buy-to-let": **£46,245,021**, the same as Metrics!B12.
- Dividing the weighted sum by it gives the weighted average.

**Step 4: the format.** Format B20 as a percentage with two decimals: **62.05%**.

#### Reading the result

- **Buy-to-let loans were made at 62.05% LTV on average, weighted by balance.** The pool as a whole was made at 69.19%, and owner-occupied loans at 70.89%.
- **The difference is expected.** Lenders ask landlords for larger deposits, typically 25% or more, because the loan is repaid from rents rather than from the borrower's salary. The range in this pool confirms it: buy-to-let original LTVs run from 49.96% to 74.87%, never above 75%.
- **For a pool cut or a rating**, a lower LTV means a smaller loss if the loan defaults (Chapter 11), which partly offsets the extra risk of rental income.

- **The figure belongs in the pool summary.** Investor reports and prospectuses show WA LTV for the whole pool and often by product. A buy-to-let line with a lower LTV than owner-occupied is what investors expect; a buy-to-let line with a *higher* LTV would be a question for the originator's lending policy.

- **Original or indexed.** The original LTV describes the lender's decision at origination; the indexed LTV (column L) describes today's risk. Reports show both, and an analyst should be able to say why they differ: repayments and house price movements since origination.

#### Checking your answer

- **A second formula.** Replace the SUMIFS with a reference to B12: `=SUMPRODUCT(...)/B12`. Same result, 62.05%.
- **Range check.** A weighted average can never fall outside the values it averages. The answer must lie between the group's lowest and highest LTV: `=MINIFS(Tape!K2:K1201,Tape!P2:P1201,"Buy-to-let")` returns 49.96% and `MAXIFS` 74.87%. 62.05% lies between.
- **The pool decomposes.** Balance-weighted, the two groups must average to the pool: (62.05% × £46.25m + 70.89% × £193.75m) ÷ £240m = 69.19%, Metrics!B8.

- **A PivotTable check.** Insert a PivotTable with `occupancy` in Rows and two values: Sum of a helper column `=K2*H2` and Sum of `current_balance`. Dividing the first by the second in the Buy-to-let row gives 62.05% again. A different tool reaching the same number is the strongest check available in a workbook.

#### Mistakes people make on this exercise

- **Dividing by the whole pool.** `/SUM(Tape!H2:H1201)` gives 11.96%: the buy-to-let weighted LTV spread over £240m. The symptom is an "average LTV" far below every individual LTV, which is impossible.
- **Using column L.** `indexed_ltv` gives today's LTV, not the LTV at origination; the question asks for original.
- **Ranges of different sizes.** `Tape!K2:K1200` against `H2:H1201` returns `#VALUE!` in SUMPRODUCT.
- **AVERAGEIFS.** `=AVERAGEIFS(Tape!K2:K1201,Tape!P2:P1201,"Buy-to-let")` returns the simple average, 62.04%. Close here, but it is a different measure, and on another pool the gap can be large.

- **Typing the result as a number.** Writing 62.05% in B20 instead of the formula gives the right answer today and a wrong one next month, when the tape changes. Markers check that the cell contains a formula.

#### Trade-offs and going further

- **One formula or a helper column.** A helper column with LTV × balance, then `SUMIFS(helper, occupancy, "Buy-to-let") / SUMIFS(balance, …)`, is easier to audit and to extend to several groups. The single SUMPRODUCT is faster to write in a timed test.
- **Typed condition or input cell.** Writing "Buy-to-let" in the formula is quick; pointing to a cell (`=Tape!$P$2:$P$1201=$A$21`) lets you change the group without editing the formula, which is better in a model others will use.
- **Going further.** Add the same row for owner-occupied loans: **70.89%**. Then the WA *indexed* LTV for buy-to-let, with column L.

- **Weighted or simple, said aloud.** In an interview, name the measure: "the balance-weighted original LTV of buy-to-let loans is 62.05%". Saying only "the average" invites the follow-up "weighted by what?", which you then answer from a position of strength.

### Exercise 2: a balance-size strat

#### What the question asks

> Add a balance-size strat to the Strats sheet: £100,000 or less; over £100,000 to £200,000; over £200,000 to £300,000; over £300,000 to £500,000; over £500,000. Include a total and a check.

In plain words: build a stratification table, the standard table of every investor report, that counts the loans and adds their balances in five size bands, with a total row and a check that the table ties to the tape.

The exercise uses COUNTIFS and SUMIFS with conditions built from cells (Section 16.5), absolute and mixed references (Section 16.2), and the layout of the indexed LTV strat already on the Strats sheet (rows 2 to 10).

#### The plan

1. **Copy the layout of the existing strat**: band label, lower edge, upper edge, loans, balance, share. A layout the reader already knows is easier to check.
2. **Put the band edges in cells**, so that formulas refer to them and never contain typed numbers.
3. **Write one row of formulas, check it, then copy it down.**
4. **Add a total row and a check row** that compares the totals with the tape.

#### Step by step

**Step 1: the layout.** Below the region strat, from row 38: A38 "Balance-size stratification"; headers in row 39 (Bucket, From (>), To (<=), Loans, Balance (£), % of pool); the bands in rows 40 to 44:

| Row | A | B (From >) | C (To <=) |
|---|---|---:|---:|
| 40 | £100,000 or less | 0 | 100000 |
| 41 | >£100,000 to £200,000 | 100000 | 200000 |
| 42 | >£200,000 to £300,000 | 200000 | 300000 |
| 43 | >£300,000 to £500,000 | 300000 | 500000 |
| 44 | Over £500,000 | 500000 | 99999999 |

The last "To" is a number larger than any loan, so the same formula works on every row.

**Step 2: count the loans.** In D40:

```
=COUNTIFS(Tape!$H$2:$H$1201,">"&B40,
          Tape!$H$2:$H$1201,"<="&C40)
```

- `">"&B40` joins the operator to the value in B40, giving the condition "> 0" on this row.
- `"<="&C40` gives "<= 100000". A loan is counted when both are true.
- `$` signs keep the Tape range fixed; `B40` and `C40` have none, so they move down when copied.

**Step 3: add the balances.** In E40:

```
=SUMIFS(Tape!$H$2:$H$1201,Tape!$H$2:$H$1201,">"&B40,
        Tape!$H$2:$H$1201,"<="&C40)
```

- The first argument is the column to add; the next pairs are the same two conditions.

**Step 4: the share.** In F40: `=E40/$E$45`, formatted as a percentage. `$E$45` (the total, built next) stays fixed when copied.

**Step 5: copy and total.** Copy D40:F40 down to row 44. In row 45: "Total", `=SUM(D40:D44)`, `=SUM(E40:E44)`, `=SUM(F40:F44)`. In row 46: "Check (should be 0)", `=D45-COUNTA(Tape!$A$2:$A$1201)` and `=E45-SUM(Tape!$H$2:$H$1201)`. Colour the check cells yellow.

The result:

| Bucket | Loans | Balance (£) | % of pool |
|---|---:|---:|---:|
| £100,000 or less | 125 | 10,205,405 | 4.25% |
| >£100,000 to £200,000 | 581 | 87,927,905 | 36.64% |
| >£200,000 to £300,000 | 340 | 82,154,579 | 34.23% |
| >£300,000 to £500,000 | 137 | 49,632,662 | 20.68% |
| Over £500,000 | 17 | 10,079,449 | 4.20% |
| **Total** | **1,200** | **240,000,000** | **100.00%** |

#### Reading the result

- **70.9% of the balance sits between £100,000 and £300,000**: a typical UK prime pool, built of mid-sized loans.
- **17 loans over £500,000 hold 4.20%.** Each is about three times the average loan of £200,000; a default there costs as much as several ordinary ones, which is why investors look at this band for concentration.
- **125 loans of £100,000 or less are 10% of the loans but only 4.25% of the balance**: counts and balances tell different stories, and reports show both.

#### Checking your answer

- **The check cells show 0.** 1,200 − 1,200 and £240,000,000 − £240,000,000.
- **No loan sits on an edge.** `=COUNTIFS(Tape!H2:H1201,100000)` and the same for 200,000, 300,000 and 500,000 all return 0, so the choice of `>` and `<=` does not change today's figures, though it would on another tape.
- **Another tool agrees.** The SQL strat of Chapter 17 (Exercise 1) and the pandas strat of Chapter 18 return the same five rows.

#### Mistakes people make on this exercise

- **`>=` on the lower edge.** `">="&B41` counts a loan of exactly £100,000 in both band 1 and band 2; the total then exceeds 1,200 and the check shows it.
- **Typed numbers in the formula.** `">100000"` works once, but changing the bands means editing every formula, and a typing slip in one is invisible.
- **Missing `$` signs.** Without them, copying the formula down shifts the Tape range to H3:H1202, then H4:H1203, and one loan falls out of the table per row.
- **A last band with no upper edge.** Leaving C44 blank makes `"<="&C44` mean "<= 0", so band 5 shows zero loans and the check fails by 17.

#### Trade-offs and going further

- **Formulas or a PivotTable.** A PivotTable with grouped balances builds the same table in seconds, but its bands are harder to set exactly and it needs a refresh when the data change. The COUNTIFS table updates by itself and keeps the layout identical every month, which is what a report needs.
- **A large number or a separate formula** for the last band. 99,999,999 keeps every row identical; a separate `">"&B44`-only formula is purer but breaks the pattern. Keep the pattern and label the band clearly.
- **Going further.** Add a sixth column, the average balance per band (`=E40/D40`), and a seventh, the WA indexed LTV per band with SUMPRODUCT and two conditions. In this pool the bands range from 58.0% to 62.2%, with no steady pattern by size.

- **Counts and balances in one table.** Some reports show only balances; investors also like the count, which reveals whether a band's balance comes from many small loans or a few large ones. Keeping both columns costs nothing and answers the follow-up question before it is asked.

### Exercise 3: TRIM on the Lookup sheet

#### What the question asks

> On the Lookup sheet, add a row that returns the loan's **region** with extra spaces removed by TRIM.

In plain words: the Lookup sheet finds a loan by its ID and shows its balance, rate, region, arrears and LTV. Add one more row that shows the same region, cleaned of stray spaces, so that a loan typed as `"London "` reads `"London"`.

The exercise uses the INDEX/MATCH lookup already on the sheet (Section 16.6), TRIM and the other text functions (Section 16.11), and the region errors found in Chapter 15 (Section 15.5): the tape has `"London "` with a trailing space, `"london"` in lower case and `"Greater London"`, besides the 188 loans spelled `"London"`.

#### The plan

1. **Reuse the region the sheet already finds** in B6, instead of writing a second lookup. One lookup, cleaned, is easier to check than two lookups.
2. **Wrap it in TRIM**, which removes spaces at both ends and turns repeated inner spaces into one.
3. **Test it on the loans that matter**: a clean region, the loan with the trailing space, and the loans TRIM cannot fix.
4. **Prove the space was removed** with LEN, because a trailing space is invisible on screen.

#### Step by step

**Step 1: the label.** In A9 type "Region (TRIM)". Row 9 is empty; row 10 already holds the duplicate-ID check.

**Step 2: the formula.** In B9:

```
=TRIM(B6)
```

- B6 holds `=IFNA(INDEX(Tape!$Q$2:$Q$1201,MATCH($B$2,Tape!$A$2:$A$1201,0)),"Not found")`: the raw region of the loan typed in B2.
- `TRIM(B6)` returns the same text without leading or trailing spaces. Inner single spaces, as in "South East", are kept.
- If B6 shows "Not found", TRIM returns "Not found" unchanged, so no extra error handling is needed.

**Step 3: test three loans.** Type each ID in B2 and read B6 and B9:

| Loan in B2 | B6 (raw) | B9 (TRIM) |
|---|---|---|
| ASH100602 | London | London |
| ASH100411 | London␣ (trailing space) | London |
| ASH100096 | london | london |

The ␣ marks the space, which Excel does not show.

**Step 4: show the space.** In C9 (or any free cell) type `=LEN(B6)` and `=LEN(B9)`. For ASH100411 they return **7** and **6**: the trailing space is gone. For ASH100602 both return 6.

#### Reading the result

- **TRIM fixes one kind of error only: spaces.** It turns `"London "` into `"London"`, so a SUMIFS that compares exactly would now count that loan with London.
- **It does not fix case.** ASH100096 stays `"london"`. Excel's own comparisons ignore case (SUMIFS with "London" already counts it), but SQL Server with a case-sensitive collation, pandas and Python do not. `=PROPER(TRIM(B6))` returns "London" for both loans.
- **It cannot fix a different name.** "Greater London" (ASH101151) is a valid-looking text that is not in the allowed list. Only a mapping table (Chapter 15, Section 15.7) turns it into "London", and someone must decide that the mapping is right.
- **So the lookup row is a display fix.** It shows the reader the clean value of one loan; it does not change the region used by the Metrics and Strats sheets, which still read column Q of the Tape.
- **Why this matters in a lookup.** A lookup by region (a mapping table of collections teams, say) uses an exact match: `"London "` finds nothing and returns `#N/A`. Cleaning the key before the lookup is what makes it match; that is the practical reason TRIM is the first function analysts reach for on a new file.

#### Checking your answer

- **LEN before and after**, as in Step 4: 7 and 6 for ASH100411.
- **An exact comparison.** `=EXACT(B9,"London")` returns TRUE for ASH100411 and FALSE for ASH100096; `=EXACT(B6,"London")` returns FALSE for both. EXACT compares case and spaces, unlike `=`.
- **Count the whole column.** In a spare cell, `=SUMPRODUCT(--(Tape!Q2:Q1201<>TRIM(Tape!Q2:Q1201)))` returns **1**: only one region in the tape has extra spaces, which matches Chapter 15's finding.

#### Mistakes people make on this exercise

- **Writing a second lookup inside TRIM.** `=TRIM(INDEX(Tape!Q2:Q1201,MATCH(B2,Tape!A2:A1201,0)))` works, but without `$` signs and without IFNA it shows `#N/A` for an unknown ID, and the sheet now has two lookups to keep in step.
- **Expecting TRIM to remove every space-like character.** Data pasted from a web page or a PDF often contains the non-breaking space, CHAR(160), which TRIM ignores. Clean it first: `=TRIM(SUBSTITUTE(B6,CHAR(160)," "))`. The symptom is a LEN that stays one character too long after TRIM.
- **Calling the region "fixed".** B9 changes what the reader sees on the Lookup sheet only; the strats still split London into four lines.

#### Trade-offs and going further

- **Where to clean.** Cleaning in a lookup row is quick and local. Cleaning a helper column on the Tape sheet (`=PROPER(TRIM(Q2))`, copied down) fixes every formula that uses it, but the workbook now has two region columns and every formula must point to the right one. Cleaning at source, in the servicer's system or in the SQL load, fixes the problem for every user; that is the professional answer, and the exceptions log (Chapter 15) is how you ask for it.
- **TRIM or a mapping table.** TRIM and PROPER fix spelling mechanically; a mapping table fixes meaning ("Greater London" → "London"). Real tapes need both, in that order.
- **Going further.** Add B11 `=IF(EXACT(B6,B9),"Clean","Spaces removed")`, so the sheet tells the user when the raw value was dirty.

### Exercise 4: the largest loss the reserve can absorb

#### What the question asks

> On the Waterfall sheet, what is the largest loss (in B9) for which the reserve fund ends **above zero** and the Class B PDL is cleared in full? Find it by changing B9, then explain it with arithmetic.

In plain words: the Waterfall sheet runs Chapter 9's month 2 with a loss of £260,000. Raise the loss in B9 until the reserve fund is used up, find the turning point, and show with a short calculation why it falls exactly there.

The exercise uses the revenue waterfall built with MIN (Section 16.8), the order of items in Ashcombe's revenue waterfall (Chapter 9, Section 9.2), the PDL (Section 9.4) and excess spread (Chapter 8, Section 8.6).

#### The plan

1. **Read what does not move.** Items 1 to 5 (expenses, fee, Class A interest, Class A PDL, Class B interest) do not depend on the loss while it is below Class B's balance, so the cash left after item 5 is fixed.
2. **Follow the loss down the waterfall.** Item 6 (Class B PDL) takes the loss first; item 7 (the reserve) gets what is left.
3. **Find the turning point by trial**, then confirm it with arithmetic and with Goal Seek.
4. **Check the rest of the sheet** at that loss: principal, closing balances and the three check cells.

#### Step by step

**Step 1: the cash left after item 5.** With the inputs as given, D22 shows **£2,423,148**. It comes from:

- available revenue D17 = revenue receipts £1,038,000 + reserve £2,383,271 = £3,421,271;
- minus items 1 to 5: £30,000 + £48,743 + £751,380 + £0 + £168,000 = £998,123;
- £3,421,271 − £998,123 = £2,423,148.

Equivalently: excess spread B27 (£39,877) + the opening reserve (£2,383,271) = £2,423,148.

**Step 2: how the loss uses it.** B23 (item 6 due) is `=MIN(B9,B5)`, the loss up to Class B's balance. C23 pays `=MIN(B23,D22)`. C24 (item 7) pays what is left, `=MIN(B24,D23)`, and B28 shows it as the closing reserve. So:

- while the loss is below £2,423,148, item 6 is paid in full and the reserve keeps the difference;
- at £2,423,148 the reserve ends at exactly £0;
- above it, item 6 is short and the gap stays on the PDL (C41).

**Step 3: trial in B9.**

| B9 (loss) | C23 PDL cleared | B28 reserve | C41 PDL outstanding |
|---:|---:|---:|---:|
| 260,000 | 260,000 | 2,163,148 | 0 |
| 2,423,000 | 2,423,000 | **148** | 0 |
| 2,423,148 | 2,423,148 | 0 | 0 |
| 2,424,000 | 2,423,148 | 0 | **852** |

The largest whole-pound loss that leaves the reserve **above zero** is **£2,423,147** (reserve £1); in round numbers, any loss below **£2,423,148**.

**Step 4: confirm with Goal Seek.** In E22 type `=D22-B9` (cash left after item 5 minus the loss). Data → What-If Analysis → Goal Seek: set E22 to 0 by changing B9. Excel returns **2,423,148**. A helper cell is needed because B28 itself is flat at zero for every loss above the turning point, and Goal Seek can stop anywhere on a flat line.

#### Reading the result

- **In one month the deal can absorb a £2.42m loss without touching any note**: 1.04% of the £233,968,000 pool. That capacity is this month's excess spread plus the whole reserve.
- **The reserve is the larger part.** Excess spread contributes only £39,877; the reserve contributes £2,383,271. A month like this shows why rating agencies look at the reserve's size relative to the pool.
- **Above the turning point, Class B carries the loss.** At £2,424,000, £852 of PDL is outstanding: notes exceed the pool by £852, and the deal relies on future excess spread to clear it.
- **Even the given £260,000 loss leaves the reserve short of its £2,400,000 target** (closing £2,163,148): item 7 is never filled this month.

#### Checking your answer

- **The checks still show 0.** At B9 = 2,423,148 the three cells C44:C46 are 0: the waterfall pays out exactly what is available, and notes − pool − PDL = 0.
- **Principal at the turning point.** Available principal C33 = £3,150,000 + £2,423,148 = £5,573,148, all to Class A. Closing pool C38 = £233,968,000 − £3,150,000 − £2,423,148 = £228,394,852; closing notes = (£200,368,000 − £5,573,148) + £33,600,000 = £228,394,852. Notes equal pool, with no PDL.
- **The chapter's breakeven example.** Section 16.21 sets B28 to 1 with Goal Seek and gets £2,423,147: one pound below the turning point, as Step 3's table shows.
- **The same answer in Python.** Chapter 18, Exercise 4 runs the same month with `run_waterfall` and finds the reserve at £148 for a £2,423,000 loss.

#### Mistakes people make on this exercise

- **Answering the reserve alone, £2,383,271.** This month's excess spread also clears PDL before the reserve is touched, so the answer is £39,877 higher.
- **Goal Seek on B28 directly.** Asking for B28 = 0 can return any loss above the turning point, for example 2,500,000, because the reserve stays at 0 from there on.
- **Changing the loss above £33,600,000.** Beyond Class B's balance, item 4 (Class A PDL) starts to apply; the question is about Class B's PDL, so the arithmetic of Step 1 no longer holds.

#### Trade-offs and going further

- **Trial or Goal Seek.** Trial shows the reader how the sheet behaves on both sides of the turning point; Goal Seek gives the exact figure. In a test, do both: the table proves you understood, the exact number scores the mark.
- **One month or the life of the deal.** The month's capacity is excess spread plus reserve; over several months it is the reserve plus every month's excess spread. That is why agencies credit excess spread over time, and why a deal with thin excess spread relies on its reserve.
- **Going further.** Set B7 (revenue) to £998,123: excess spread becomes 0, and the largest absorbable loss falls to the reserve alone, £2,383,271.

### Exercise 5: actual days and ACT/365 interest

#### What the question asks

> On the Dates sheet, add a column that shows how many **actual** days each period has, and the Class A interest it would have on ACT/365.

In plain words: the Dates sheet counts each interest period on 30/360, where every regular month has 30 days. Add the real number of calendar days in each period, and the Class A interest that a note paying on ACT/365 (actual days over a 365-day year) would pay.

The exercise uses date arithmetic and DAYS360 (Section 16.9), the day count conventions of Chapter 3 (Section 3.2), and the Dates sheet's inputs: closing on 15 July 2026, the first payment on 20 August 2026, Class A of £206,400,000 at 4.5%.

#### The plan

1. **Count actual days** as the difference between consecutive dates: Excel stores dates as day numbers, so subtraction gives days.
2. **Treat the first period separately**, because it starts at closing, not at a payment date.
3. **Compute interest** as balance × coupon × days ÷ 365, rounded to the pound, next to the 30/360 column.
4. **Compare the two columns** and check the totals.

#### Step by step

**Step 1: headers.** F7 "Actual days"; H7 "Interest ACT/365 (£)". Column G holds notes, so leave it.

**Step 2: the first period.** In F8:

```
=B8-$B$2
```

- B8 is the first payment date, 20 August 2026; B2 is the closing date, 15 July 2026.
- The difference is **36** days. The 30/360 column C8 shows 35, because DAYS360 treats July as 30 days.

**Step 3: the other periods.** In F9:

```
=B9-B8
```

Copy F9 down to F19. Each row counts from the previous payment date: 20 August to 20 September is **31**; 20 January to 20 February 2027 is 31; 20 February to 20 March is **28**.

**Step 4: the interest.** In H8:

```
=ROUND($B$4*$B$5*F8/365,0)
```

- `$B$4` (balance) and `$B$5` (coupon) are fixed with `$`; F8 moves when copied.
- `/365` is the ACT/365 year. Copy H8 down to H19.

The first four rows:

| Period | Payment date | 30/360 days | 30/360 interest | Actual days | ACT/365 interest |
|---:|---|---:|---:|---:|---:|
| 1 | 20 Aug 2026 | 35 | 903,000 | 36 | **916,077** |
| 2 | 20 Sep 2026 | 30 | 774,000 | 31 | **788,844** |
| 3 | 20 Oct 2026 | 30 | 774,000 | 30 | 763,397 |
| 8 | 20 Mar 2027 | 30 | 774,000 | 28 | 712,504 |

#### Reading the result

- **On ACT/365 the coupon changes every month**: £712,504 for February's 28 days, £788,844 for a 31-day month. On 30/360 every regular month pays the same £774,000.
- **Over the year the two are close.** The twelve ACT/365 payments add up to **£9,415,233**; the twelve 30/360 payments to £9,417,000. The difference is £1,767, because the year covered has 370 actual days, about 1.4% more than 365.
- **This is why SONIA notes never pay the same amount twice.** Sterling floating-rate notes count actual days, so even with a flat rate the cash changes with the calendar; an analyst checking a payment must count the days first.
- **The first period is long on both conventions.** Closing on 15 July and paying on 20 August gives a first period of more than a month (35 days on 30/360, 36 actual). Deals often have a long or short first period, and its interest is the one most often mis-stated in a model, because it does not follow the monthly pattern.

#### Checking your answer

- **Days add up to the span.** `=SUM(F8:F19)` returns **370**, and `=B19-B2` (20 July 2027 − 15 July 2026) also returns 370.
- **Interest from the total.** £206,400,000 × 4.5% × 370 ÷ 365 = £9,415,233, the sum of H8:H19 (`=SUM(H8:H19)`). The rounding of each row happens to cancel exactly here; on other dates the two can differ by a pound or two.
- **One row by hand.** Period 2: 206,400,000 × 0.045 = 9,288,000 a year; × 31 ÷ 365 = £788,843.84, rounded to £788,844.
- **February.** Period 8 (20 February to 20 March 2027) is the shortest, 28 days, and its interest the smallest, £712,504. If your column shows the same amount every month, the days are not being picked up.

#### Mistakes people make on this exercise

- **Copying F8 down.** `=B9-$B$2` measures every period from closing: 67, 97, and so on. The `$` is what keeps B2 fixed, so the first-period formula cannot be copied.
- **Dividing by 360 on the actual-days column.** ACT/360 is a real convention (used for euro and dollar notes), but it is not the one asked: period 2 would show £799,800.
- **Formatting the days as dates.** A difference of two dates sometimes inherits a date format and displays as 05/02/1900. Format F8:F19 as General or Number.
- **Using DAYS360 for the actual column.** `=DAYS360(B8,B9)` gives 30 for every regular month; actual days need plain subtraction (or `=DAYS(B9,B8)`, which is the same).

#### Trade-offs and going further

- **One sheet, two conventions.** Showing both columns side by side is the clearest way to explain a coupon to someone used to one convention. The cost is a wider sheet, and the risk that a reader takes the wrong column; label them precisely.
- **ACT/365 or ACT/365F.** UK documents write "Actual/365 (Fixed)": always 365, even in a leap year. This exercise uses that convention; ACT/ACT would divide by 366 for periods in 2028.
- **Going further.** Add column I with `=H8-E8`, the monthly difference between the two conventions. It is positive in 31-day months and negative in February.
- **Hard-coded 365 or an input cell.** Writing the year basis in a labelled input cell (say B6 = 365) lets the same column compute ACT/360 by changing one number, and shows the reader which convention is in use.

### Exercise 6: PivotTable of rate type by repayment type

#### What the question asks

> Build a PivotTable showing balance by **rate_type** (rows) and **repayment_type** (columns).

In plain words: a two-way table of the pool balance, with the three rate types (Fixed, SVR, Tracker) down the side and the three repayment types (Interest-only, Part and part, Repayment) across the top, with totals.

The exercise uses PivotTables (Section 16.12), the rate and product types of Chapter 10 (Section 10.4), and SUMIFS with two conditions (Section 16.5) as a check.

#### The plan

1. **Insert the PivotTable** on the whole tape, on a new sheet, so the data stays untouched.
2. **Place the fields**: rows, columns, values.
3. **Make the values a sum, formatted**, because a pivot sometimes defaults to a count.
4. **Check the grand total and one cell** with a formula.

#### Step by step

**Step 1: insert.** Click any cell inside the Tape data (A1:W1201). Insert → PivotTable → New Worksheet → OK. Excel selects the whole block because it has no blank rows or columns; check that the range reads `Tape!$A$1:$W$1201`.

**Step 2: place the fields.** In the PivotTable Fields pane:

- drag `rate_type` to **Rows**;
- drag `repayment_type` to **Columns**;
- drag `current_balance` to **Values**.

**Step 3: sum and format.** The Values box must read "Sum of current_balance". If it reads "Count of …", click it → Value Field Settings → Sum. In the same dialog, Number Format → Number, 0 decimals, with the thousands separator.

The result:

| | Interest-only | Part and part | Repayment | Total |
|---|---:|---:|---:|---:|
| Fixed | 35,955,572 | 8,512,035 | 125,171,304 | 169,638,911 |
| SVR | 8,351,507 | 1,801,365 | 19,644,330 | 29,797,202 |
| Tracker | 8,731,952 | 2,430,520 | 29,401,415 | 40,563,887 |
| **Total** | 53,039,031 | 12,743,920 | 174,217,049 | **240,000,000** |

**Step 4: name the sheet.** Rename it "Pivot_rate_repay" so a reviewer finds it.

#### Reading the result

- **Fixed-rate loans are 70.7% of the pool** (£169.6m of £240m), and repayment loans 72.6%. A UK prime pool is usually dominated by both.
- **The largest cell, fixed-rate repayment loans, holds £125.2m: 52.2% of the pool.** It is the "typical" Ashcombe loan.
- **Interest-only is 22.1% of the pool.** Investors watch it because the whole balance is due at maturity; a cross-table shows whether those loans are also on SVR (£8.4m), the most expensive rate.
- **SVR is the smallest rate type (12.4%)** but pays the highest WA rate (Chapter 17, Exercise 4): borrowers who did not remortgage.
- **Cross-tables answer "and" questions.** "How much is fixed *and* interest-only?" (£36.0m) is the kind of follow-up an interviewer asks after a one-way strat. A pivot answers it without a new formula; a one-way strat cannot.
- **Reading across and down.** Across a row, the shares tell you the product mix of each rate type (interest-only is 21% of Fixed, 28% of SVR); down a column, the rate mix of each product. Say which way you read before you quote a percentage.

#### Checking your answer

- **The grand total is £240,000,000**, the pool balance on the Metrics sheet.
- **One cell by formula.** `=SUMIFS(Tape!H2:H1201,Tape!N2:N1201,"Fixed",Tape!O2:O1201,"Repayment")` returns £125,171,304, the Fixed/Repayment cell.
- **Counts.** Change the value to Count: the totals are 853, 144 and 203 loans by rate type, and 245, 64 and 891 by repayment type, which add to 1,200.
- **Row and column totals.** The row totals (Fixed £169,638,911, SVR £29,797,202, Tracker £40,563,887) must equal the WA-rate denominators of Chapter 17, Exercise 4; the column totals must match a SUMIFS on `repayment_type` alone.

#### Mistakes people make on this exercise

- **Leaving Values on Count.** The table then shows 1,200 in the corner and looks right; only the sizes reveal it is a count.
- **Selecting one column before inserting.** The pivot then covers only that column and the other fields are missing from the list.
- **Not refreshing after the data change.** A pivot is a snapshot: when the tape changes, PivotTable Analyze → Refresh is needed. A formula grid (SUMIFS) updates by itself.
- **Building the pivot on a range that stops short.** If the source was selected as A1:W1000, 201 loans are missing, and the grand total shows less than £240m. Check the source range under PivotTable Analyze → Change Data Source.
- **Typing numbers into the pivot.** A pivot cell cannot be edited; people copy the pivot as values and then edit, which breaks the link to the data. Corrections belong in the source.

#### Trade-offs and going further

- **Pivot or SUMIFS grid.** A pivot takes thirty seconds and lets you swap fields; a SUMIFS grid takes longer to build but updates by itself and sits inside a report layout. Use the pivot to explore, the grid for a monthly report.
- **Pounds or percentages.** Value Field Settings → Show Values As → % of Grand Total turns the same table into shares (52.2% in the largest cell). Keep two pivots, one in each, rather than switching one back and forth.
- **Going further.** Add `occupancy` to the Filters area and select Buy-to-let: interest-only is a much larger share of landlords' loans than of the pool.
- **A pivot on a Table.** Converting the data to an Excel Table (Ctrl+T) before inserting the pivot makes the source grow automatically when rows are added; a plain range does not.

### Exercise 7: no-principal loans that are repayment loans

#### What the question asks

> On the Movements sheet, how many loans that paid no principal in June are **repayment** loans? (Bring in `repayment_type` with INDEX/MATCH.)

In plain words: the Movements sheet already classifies each loan's May-to-June movement, and 293 loans show "No principal". Interest-only loans are expected there; repayment loans are not, because every normal payment on a repayment loan repays some principal. You must bring each loan's repayment type from the Tape sheet and count the repayment loans among the 293.

The exercise uses INDEX with MATCH (Section 16.6), IFNA for loans not found, COUNTIFS with two conditions (Section 16.5), and the Movements sheet of *Real task 1: month-on-month movements* (Section 16.14).

#### The plan

1. **Add a column with each loan's repayment type**, looked up from the Tape sheet by loan ID.
2. **Handle loans that are not on the tape**, which would otherwise show `#N/A`.
3. **Count with two conditions**: movement "No principal" and type "Repayment".
4. **Look at the loans found** to explain why they paid no principal.

#### Step by step

**Step 1: the header.** In J11 type "Repayment type".

**Step 2: the lookup.** In J12:

```
=IFNA(INDEX(Tape!$O$2:$O$1201,
  MATCH(A12,Tape!$A$2:$A$1201,0)),"Not in tape")
```

- `MATCH(A12, Tape!$A$2:$A$1201, 0)` finds the position of the loan ID in A12 within the tape's ID column; the `0` asks for an exact match.
- `INDEX(Tape!$O$2:$O$1201, position)` returns the repayment type from the same position in column O.
- `IFNA(…, "Not in tape")` replaces the `#N/A` that MATCH returns when the ID is not found.
- Copy J12 down to J1222.

**Step 3: the count.** In E9, with the label "Repayment loans, no principal" in D9:

```
=COUNTIFS(G12:G1222,"No principal",
          J12:J1222,"Repayment")
```

- The first pair keeps the rows whose movement (column G) is "No principal".
- The second keeps those whose repayment type (column J) is "Repayment".
- Result: **49**.

**Step 4: the breakdown.** The same COUNTIFS with "Interest-only" and "Part and part" gives **239** and **5**: 49 + 239 + 5 = 293.

#### Reading the result

- **239 of the 293 are interest-only loans**: they pay only interest every month, so "no principal" is normal for them.
- **49 are repayment loans, and every one of them is a loan whose arrears rose in June.** Comparing columns E and F (May and June arrears) for these rows shows the June arrears higher in all 49; 25 of them were already behind in May. A repayment loan that pays no principal has missed a payment.
- **For the monthly report**, the 49 repayment loans are an early-warning list: borrowers who have just started to miss payments, or who keep missing them.

- **Where the 49 sit.** All 49 are in the arrears bucket of their June row, and their total balance is part of the pool's £19.9 million of loans in arrears. Listing them by loan ID, with their May and June arrears side by side, gives the servicer a short, concrete list to work on, which is more useful than a percentage.

- **Part-and-part loans.** The 5 part-and-part loans repay part of their balance over the term; a month with no principal is unusual for them too, and they belong on the same watch list as the 49.

#### Checking your answer

- **The three types add up.** 49 + 239 + 5 = 293, equal to E7 ("Loans with no principal").
- **Filter and look.** Filter column G for "No principal" and column J for "Repayment": 49 rows. Their June arrears (column F) are all higher than May's (column E).
- **Not-found loans are visible.** Filter J for "Not in tape": ASH100888 (the loan mislabelled in the tape, Chapter 15) and the 11 loans that redeemed in June. None of them is "No principal", so the count is not affected.

- **Spot-check two loans.** Pick one repayment loan from the filtered list and look it up in the History sheet: its May and June balances are equal and its arrears rose from May to June. Then pick one interest-only loan: equal balances and unchanged arrears, as expected.

#### Mistakes people make on this exercise

- **No IFNA.** The `#N/A` rows do not break COUNTIFS, but any SUM or AVERAGE over column J would fail, and the marker sees errors on the sheet.
- **MATCH without the 0.** `MATCH(A12, …)` defaults to an approximate match on an unsorted list and returns the wrong row for many loans, silently.
- **VLOOKUP to the left.** The repayment type (column O) is to the right of the ID (column A), so VLOOKUP works here, but its column number (15) breaks if a column is inserted in the tape. INDEX/MATCH names both columns.
- **Counting "No principal" alone.** 293 includes interest-only loans, for which no principal is normal; the question is about repayment loans.

- **Absolute references missing on the lookup ranges.** Without `$`, copying J12 down shifts `Tape!A2:A1201` to `A3:A1202`, and the first loan of the tape can no longer be found.

#### Trade-offs and going further

- **INDEX/MATCH, XLOOKUP or a join.** XLOOKUP (`=XLOOKUP(A12,Tape!A:A,Tape!O:O,"Not in tape")`) is shorter in Excel 365; INDEX/MATCH works in every version and in older test environments. In SQL or pandas this is a join (Chapter 17 and 18).
- **A lookup column or a COUNTIFS with SUMPRODUCT.** A single SUMPRODUCT can count without the helper column, but the helper column is visible, reusable for other questions and easier for a reviewer to check.
- **Going further.** Count the repayment loans with no principal whose June arrears are 2 months or more: add a third condition, `F12:F1222,">=2"`.

- **Monthly or permanent.** A lookup column added for one question is easy to forget; if the question is asked every month, build it into the Movements sheet's layout, with a heading and a check, so that next month's file answers it automatically.

- **Sheet of answers or extra columns.** Adding the lookup as column J keeps the answer next to the data it explains; a separate answers sheet keeps the original layout untouched. In a test, follow the instruction "put each answer on a new sheet" when it is given.

### Exercise 8: CDR 2% and severity 30% on the Projection sheet

#### What the question asks

> On the Projection sheet, set the CDR to 2% and the severity to 30%. What happens to Class A's WAL and to lifetime losses? Why does the WAL change at all?

In plain words: the Projection sheet runs the pool forward with 10% CPR, 0.5% CDR and 20% severity, and pays Class A from the principal. Raise defaults to 2% a year and severity to 30%, read the two results, and explain why a credit assumption changes the timing of Class A's repayment.

The exercise uses the projection of Section 16.16, CDR and severity (Chapter 10, Section 10.8) and the WAL (Section 10.9).

#### The plan

1. **Record the base results** before changing anything: WAL in F5, losses in F6.
2. **Change the two inputs** and read the new results.
3. **Separate the two effects**: change CDR and severity one at a time to see which one moves the WAL.
4. **Explain** from the sheet's formulas why defaults shorten the WAL.

#### Step by step

**Step 1: base.** With C5 = 10%, C6 = 0.5%, C7 = 20%: F5 shows **4.91 years** and F6 **£1,589,745**. The last month with Class A principal (filter column J for values above 0) is month **159**.

**Step 2: the stress.** Set C6 = 2% and C7 = 30%:

- F5 (Class A WAL): **4.46 years**;
- F6 (lifetime losses): **£8,851,784**;
- Class A's last payment moves to month **146**.

**Step 3: one input at a time.**

| CDR | Severity | Class A WAL | Lifetime losses (£) |
|---:|---:|---:|---:|
| 0.5% | 20% | 4.91 | 1,589,745 |
| 0.5% | 30% | 4.91 | 2,384,617 |
| 2.0% | 20% | 4.46 | 5,901,189 |
| 2.0% | 30% | 4.46 | 8,851,784 |

Severity changes the losses but not the WAL; CDR changes both.

**Step 4: read the formulas.** In row 12:

- E12 (defaults) is `=(B12-D12)*$F$3`: F3 is the monthly default rate, `=1-(1-C6)^(1/12)`, which rises from 0.042% to **0.168%**.
- J12 (Class A principal) is `=MIN(D12+E12+F12,I12)`: scheduled principal **plus defaults** plus prepayments.
- G12 (losses) is `=E12*$C$7`: defaults × severity, which never enters column J.

#### Reading the result

- **The WAL shortens because defaulted balances leave the pool and are paid to Class A.** The sheet assumes (note in A9) that recoveries and excess spread cover each default in full, so a default acts like a prepayment for Class A: its principal comes back early. Lifetime defaults rise from £7.9m to £29.5m, and Class A is repaid 13 months sooner.
- **Severity is only a loss figure here.** It splits each default into recovery and loss, but the model pays Class A the whole defaulted balance either way, so severity cannot move the WAL.
- **Losses rise more than fivefold**: four times more defaults, each losing 1.5 times more.
- **For Class A this is not good news.** In a real deal, losses beyond excess spread go to the reserve and then to the PDL; the projection's simplification hides the point at which Class B, and then Class A, would lose principal.
- **Prepayments still dominate.** Over the life of the pool, £153.1m is prepaid against £29.5m defaulted: even a 2% CDR is a small part of what repays Class A, which is why the WAL moves by under half a year.

#### Checking your answer

- **F7 still shows 0**: the model still repays all £206.4m of Class A, as its assumption guarantees.
- **The direction is right.** More defaults → more principal sooner → shorter WAL, the same direction as a higher CPR (Section 16.16 shows WAL falling as CPR rises).
- **The same model in Python.** `project(cpr=0.10, cdr=0.02, severity=0.30)` in `ch18_08_cashflow_projection.py` gives the same WAL and losses.
- **Severity alone.** Set C6 back to 0.5% and C7 to 30%: F5 stays at 4.91 years while F6 rises to £2,384,617. A change in one input that moves only the result it should move is a check on the model's logic.

#### Mistakes people make on this exercise

- **Typing 2 instead of 2%.** C6 = 2 means a 200% CDR: F3 becomes an error, because 1 − 2 is negative and its twelfth root is not a number.
- **Concluding that defaults are good for Class A.** The model shortens Class A's life only because it assumes every default is fully covered; it is a timing model, not a loss model.
- **Saying severity shortens the WAL.** Step 3 shows it does not; the change comes from CDR alone.

#### Trade-offs and going further

- **Simple projection or full waterfall.** A pool-level projection is fast, transparent and good for timing (WAL, final payment); it cannot show who bears losses. For that, run each month through the waterfall, as Chapter 18's `run_waterfall` does for one month.
- **Constant CDR or a curve.** A flat 2% a year is easy to explain; real defaults peak a few years after origination. Agencies use default curves; a flat CDR is the interview standard.
- **Going further.** Find the CDR at which lifetime losses reach £24,000,000 (10% of the pool) with 30% severity, by trying values in C6. Then say whether Class B, at £33.6m, would still be protected.
- **One stress or a grid.** A single scenario answers the question asked; a small grid of CDR (0.5%, 1%, 2%, 4%) against severity (20%, 30%, 40%) with a Data Table (What-If Analysis → Data Table) shows the whole surface in one view and is what a reviewer asks for next.
