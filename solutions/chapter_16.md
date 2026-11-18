# Chapter 16: Excel for structured finance: the formulas that matter

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

### Exercise 3: no-principal loans that are repayment loans

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
