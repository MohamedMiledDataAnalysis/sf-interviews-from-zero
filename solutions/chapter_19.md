# Chapter 19: Practice test 1: a two-month waterfall

> © 2026 Mohamed Miled. All rights reserved. This text is part of the book *Structured Finance Interviews from Zero* and may not be copied, republished or sold. The code blocks are under the MIT licence (see `LICENSE`); the explanations are not (see `LICENSE-TEXT.md`).

## Solution

The answers below come from `test1_solution.xlsx`, whose layout follows *Building the workbook, step by step*. Excel rounds halves up, so £37,052.50 becomes £37,053. Each solution has the same seven parts as the chapter corrections.

### Question 1: month 1 revenue waterfall

#### What the question asks

> Run the revenue waterfall: for each item, show the amount due, the amount paid and the cash left. (10)

In plain words: take month 1's available revenue and pay the eight items of the revenue priority of payments in order. For each, the marker wants three numbers: what was owed, what was paid, and the cash remaining after it.

The question uses the revenue waterfall of Chapter 9 (Sections 9.2 and 9.4), the deal terms of Calder above (coupons, fee rate, expenses, reserve), and the MIN/cash-left pattern of Chapter 16 (Section 16.8).

#### The plan

1. **Find available revenue**: receipts plus the whole reserve, as the deal terms define it.
2. **Compute each item's amount due** from the opening balances and the deal terms, before paying anything.
3. **Pay each item the smaller of due and cash left**, top to bottom; whatever is left after item 7 is the residual.
4. **Check that the paid amounts plus residual equal available revenue.**

#### Step by step

**Step 1: available revenue.** £720,000 of receipts + £1,500,000 of reserve = **£2,220,000**. In the workbook, D25: `=C19+C18`.

**Step 2: amounts due.**

- Senior expenses: **£25,000**, from the deal terms (B26: `=$B$9`).
- Servicing fee: £150,000,000 × 0.30% ÷ 12 = **£37,500** on the opening pool (B27: `=ROUND(C15*$B$8/12,0)`).
- Class A interest: £129,000,000 × 4.75% ÷ 12 = **£510,625** (B28: `=ROUND(C16*$B$6/12,0)`).
- Class A PDL: only losses above Class B's balance; £90,000 is far below £21m, so **£0** (B29: `=MAX(0,C22-C17)`).
- Class B interest: £21,000,000 × 6.50% ÷ 12 = **£113,750** (B30).
- Class B PDL: the loss up to Class B's balance, **£90,000** (B31: `=MIN(C22,C17)`).
- Reserve: the required amount, **£1,500,000** (B32: `=$B$10`).

**Step 3: pay in order.** Each row's paid amount is `=MIN(due, cash left above)` and its cash left is `=cash left above − paid`:

| Item | Due | Paid | Cash left |
|---|---:|---:|---:|
| Available revenue: 720,000 + 1,500,000 | | | 2,220,000 |
| 1 Senior expenses | 25,000 | 25,000 | 2,195,000 |
| 2 Servicing fee | 37,500 | 37,500 | 2,157,500 |
| 3 Class A interest | 510,625 | 510,625 | 1,646,875 |
| 4 Class A PDL | 0 | 0 | 1,646,875 |
| 5 Class B interest | 113,750 | 113,750 | 1,533,125 |
| 6 Class B PDL | 90,000 | 90,000 | 1,443,125 |
| 7 Reserve fund | 1,500,000 | 1,443,125 | 0 |
| 8 Residual | | 0 | 0 |

**Step 4: the check cell.** In a yellow cell: `=SUM(C26:C33)-D25`, which returns **0**.

#### Reading the result

- **Every item is paid in full except the reserve.** The deal had enough cash for all its fees, interest and the loss, but not enough to refill the reserve to £1,500,000.
- **The reserve ends at £1,443,125**, £56,875 below target. Question 2 explains why.
- **Nothing goes to the residual holder**: the originator's income comes only after the reserve is full.

#### Checking your answer

- **Paid amounts add up.** £25,000 + £37,500 + £510,625 + £0 + £113,750 + £90,000 + £1,443,125 + £0 = £2,220,000, the available revenue.
- **Each cash-left figure** is the one above it minus the paid amount: for example £1,646,875 − £113,750 = £1,533,125.
- **Interest on a second route.** Class A: £129m × 4.75% = £6,127,500 a year, ÷ 12 = £510,625.
- **Python agrees.** `run_waterfall(150_000_000, 129_000_000, 21_000_000, 1_500_000, 720_000, 1_700_000, 90_000, expenses=25_000, fee_rate=0.003, coupon_a=0.0475, coupon_b=0.065, reserve_required=1_500_000)` returns the same eight paid amounts (Extension E4).

#### Mistakes people make on this question

- **Leaving the reserve out of available revenue.** With only £720,000, items 1 to 5 are paid (£686,875), the Class B PDL receives only £33,125 of its £90,000, and the reserve receives nothing: a deal with a £1.5 million reserve is shown leaving £56,875 of loss uncleared.
- **Charging the fee or interest on closing balances.** Interest is always on the opening balance of the period.
- **Typing amounts instead of linking them.** `=25000` in B26 works for month 1 but not when the deal terms change; markers check that the formulas refer to the input cells.
- **Putting the loss in Class A's PDL.** Losses go to Class B first, up to its balance.

#### Trade-offs and going further

- **One formula pattern or a formula per item.** The MIN/cash-left pattern copied down eight rows is quick to build and easy to mark; a separate hand-written formula per row is error-prone and slower.
- **Rounding each line or the total.** The deal says to round every interest and fee amount to the nearest pound; rounding only the totals would leave pence in the waterfall and break the reconciliation by small amounts.
- **Going further.** Change C19 to 600,000 and watch which item is first to be short: the reserve, still, because £600,000 + £1,500,000 covers items 1 to 6 easily.

### Question 2: excess spread

#### What the question asks

> Calculate the excess spread. Explain in one sentence why the reserve fund ends below its required amount. (5)

In plain words: compute what the month's interest receipts earned above the deal's fees and note interest, then explain, in one sentence, the reserve's shortfall found in Question 1.

The question uses the definition of excess spread (Chapter 8, Section 8.6), the reserve fund and its replenishment (Section 8.7), and Question 1's waterfall.

#### The plan

1. **Use the definition**: revenue receipts minus items 1, 2, 3 and 5 due. Do not include the PDL or the reserve.
2. **Compare excess spread with the loss** that item 6 had to clear.
3. **Write one sentence** with cause before result, and the numbers.

#### Step by step

**Step 1: excess spread.**

Excess spread = £720,000 − £25,000 − £37,500 − £510,625 − £113,750 = **£33,125**.

In the workbook, C36: `=C19-B26-B27-B28-ROUND(C17*$B$7/12,0)`. The last term is this month's Class B interest, written out so that a deferred amount from an earlier month would not be counted.

**Step 2: compare with the loss.** The month's loss was £90,000. Excess spread covered £33,125 of it; the other £90,000 − £33,125 = **£56,875** came from the reserve.

**Step 3: the sentence.** "The £90,000 loss was larger than the month's excess spread of £33,125, so the reserve fund paid the remaining £56,875 and ends at £1,443,125, below its £1,500,000 required amount."

#### Reading the result

- **The deal earns £33,125 a month above its costs**, about 0.26% a year on the pool. That is its first line of defence against losses.
- **One loss of £90,000 used almost three months of excess spread.** The reserve absorbed the gap, which is exactly its purpose; the noteholders noticed nothing.
- **The reserve will be refilled** from future excess spread, at item 7, before anything goes to the residual holder.

#### Checking your answer

- **Reserve movement = loss − excess spread.** £1,500,000 − £1,443,125 = £56,875 = £90,000 − £33,125. The two routes agree.
- **Excess spread from the cash-left column.** Cash left after item 5 (£1,533,125) minus the reserve at the start (£1,500,000) is £33,125: the same.

#### Mistakes people make on this question

- **Subtracting the PDL.** £33,125 − £90,000 = −£56,875 is the reserve draw, not the excess spread. Excess spread is measured before items 6 and 7.
- **Including the reserve in the revenue.** £2,220,000 minus costs is £1,533,125, not excess spread: the reserve is not income.
- **An explanation without the cause.** "The reserve went down" restates the result. The marks are for "because the loss exceeded the excess spread".

#### Trade-offs and going further

- **Monthly or annualised.** £33,125 a month is what the waterfall uses; 0.26% a year is how investors compare deals. Give the first in a test answer and the second if asked to comment.
- **Excess spread as protection or income.** Excess spread that is not needed for losses goes to the residual holder, often the originator. A larger excess spread protects investors more but costs the borrower more; the deal's structure balances the two.
- **Going further.** If every month earned £33,125 and had no losses, how many months would refill the reserve? £56,875 ÷ £33,125 = 1.7, so **2 months**.

### Question 3: principal and closing balances

#### What the question asks

> Run the principal waterfall and give the closing balances of the pool, Class A, Class B and the reserve fund. (6)

In plain words: add the principal collected and the PDL credit, pay it to the notes in order, and roll the pool, both classes and the reserve forward to the end of month 1.

The question uses the principal waterfall and the PDL credit (Chapter 9, Sections 9.3 and 9.4), the sequential payment rule of Calder's terms, and Question 1's results.

#### The plan

1. **Compute available principal**: scheduled principal plus prepayments plus the PDL paid at items 4 and 6.
2. **Pay Class A first**, up to its balance, then Class B with any remainder.
3. **Roll forward each balance**: pool by principal receipts and losses; notes by principal paid; reserve from item 7.

#### Step by step

**Step 1: available principal.**

| Item | Amount |
|---|---:|
| Scheduled principal | 520,000 |
| Prepayments | 1,180,000 |
| Principal receipts | 1,700,000 |
| + Class B PDL credited (item 6) | 90,000 |
| **Available principal** | **1,790,000** |

In the workbook, C38: `=C20+C21+C29+C31`.

**Step 2: pay the notes.** Class A: `=MIN(C38,C16)` = **£1,790,000**; Class B: `=MIN(C38-C39,C17)` = **£0**.

**Step 3: closing balances.**

| | Closing |
|---|---:|
| Pool: 150,000,000 − 1,700,000 − 90,000 | **148,210,000** |
| Class A: 129,000,000 − 1,790,000 | **127,210,000** |
| Class B | **21,000,000** |
| Reserve fund | **1,443,125** |

#### Reading the result

- **Class A falls by more than the principal collected.** The £90,000 PDL credit moved revenue into the principal pot: the loss reduced the pool, so the notes must fall by the same amount for notes and pool to stay equal.
- **Class B is untouched**, as sequential payment requires: it receives nothing until Class A is repaid.
- **The pool falls by principal and by the loss**, £1,790,000 in total, exactly as much as the notes.

#### Checking your answer

- **Notes against pool.** £127,210,000 + £21,000,000 = £148,210,000 = the pool. With no PDL outstanding, the two must be equal (Question 4).
- **Principal paid = available principal.** £1,790,000 + £0 = £1,790,000.

#### Mistakes people make on this question

- **Forgetting the PDL credit.** Class A would close at £127,300,000 and the notes would exceed the pool by £90,000 with no PDL to explain it.
- **Paying principal pro rata.** Calder is sequential; splitting £1,790,000 by balance (Extension E1) is a different deal.
- **Reducing the pool by the PDL credit as well as the loss.** The credit moves cash between pots; it does not reduce the pool a second time.

#### Trade-offs and going further

- **Sequential or pro rata.** Sequential payment builds up Class A's protection; pro rata repays Class B sooner and lowers the deal's cost. Extension E1 shows the split.
- **Going further.** Class A's credit enhancement at the end of month 1 is £21,000,000 ÷ £148,210,000 = **14.17%** plus the reserve, up from 14.00% at closing.

### Question 4: reconciliation

#### What the question asks

> Show that the notes reconcile to the pool. (4)

In plain words: prove, with numbers, that after month 1 the notes outstanding and the pool agree, taking any PDL into account.

The question uses the reconciliation identity notes − pool = PDL outstanding (Chapter 9, Section 9.4; check 7 of Chapter 14, Section 14.4).

#### The plan

1. **Add the note balances.**
2. **Subtract the pool.**
3. **Compare the difference with the PDL outstanding**; they must be equal.

#### Step by step

1. Notes = £127,210,000 + £21,000,000 = **£148,210,000**.
2. Notes − pool = £148,210,000 − £148,210,000 = **£0**.
3. PDL outstanding = losses debited − PDL credited = £90,000 − £90,000 = **£0**.

Notes − pool = 0 = PDL outstanding. ✔

In the workbook, a yellow check cell: `=C48+C49-C47-C52`, which returns 0.

#### Reading the result

- **The deal is whole.** Every pound of loss this month was covered by revenue (excess spread plus reserve), so the notes still equal the pool.
- **The identity is the waterfall's central check.** If it fails, either a loss was not debited, principal was not paid, or a balance was keyed wrongly (Chapter 14, Exercise 1).

#### Checking your answer

- **Break it on purpose.** Delete the PDL credit from available principal: Class A closes at £127,300,000, notes − pool = £90,000, and PDL outstanding is still £0. The check cell shows £90,000, proving that it catches the error.

#### Mistakes people make on this question

- **Showing only that the totals are equal.** The identity includes the PDL: in month 2 the notes and pool differ, and the check still passes.
- **A check cell the marker cannot see.** Put it next to the closing balances, labelled "should be 0".

#### Trade-offs and going further

- **One identity or many checks.** This one check catches the commonest waterfall errors; adding "revenue paid = available" and "principal paid = available" catches the rest. Three yellow cells take a minute to build.
- **Going further.** Write the same check for month 2 before running it: it must equal the PDL left after item 6.

### Question 5: month 2 waterfalls

#### What the question asks

> Run the revenue and principal waterfalls for month 2, starting from your month 1 closing balances. (14)

In plain words: repeat Questions 1 and 3 for month 2, with month 2's receipts and its £1.6 million loss, starting from where month 1 ended. The marker wants every line of both waterfalls.

The question uses the same waterfall as month 1 (Chapter 9, Sections 9.2 to 9.4), the month 1 closing balances from Question 3, and the deal's rule that unpaid Class B interest and any PDL left uncleared are carried forward.

#### The plan

1. **Link the opening balances** to month 1's closing balances, never retyping them.
2. **Recompute the amounts due** on the new opening balances.
3. **Run the revenue waterfall** with available revenue = receipts + the reserve left after month 1.
4. **Run the principal waterfall** with the PDL actually paid.

#### Step by step

**Step 1: opening balances.** Pool £148,210,000, Class A £127,210,000, Class B £21,000,000, reserve £1,443,125. In the workbook G15:G18 link to C47:C50.

**Step 2: amounts due.**

- Servicing fee: £148,210,000 × 0.30% ÷ 12 = £37,052.50, rounded half up to **£37,053**.
- Class A interest: £127,210,000 × 4.75% ÷ 12 = £503,539.58, so **£503,540**.
- Class B interest: **£113,750** (balance unchanged), plus any deferred interest from month 1 (none).
- Class B PDL: the £1,600,000 loss, below Class B's £21,000,000, so **£1,600,000**; Class A PDL **£0**.

**Step 3: the revenue waterfall.** Available revenue = £640,000 + £1,443,125 = £2,083,125.

| Item | Due | Paid | Cash left |
|---|---:|---:|---:|
| Available revenue: 640,000 + 1,443,125 | | | 2,083,125 |
| 1 Senior expenses | 25,000 | 25,000 | 2,058,125 |
| 2 Servicing fee | 37,053 | 37,053 | 2,021,072 |
| 3 Class A interest | 503,540 | 503,540 | 1,517,532 |
| 4 Class A PDL | 0 | 0 | 1,517,532 |
| 5 Class B interest | 113,750 | 113,750 | 1,403,782 |
| 6 Class B PDL | 1,600,000 | **1,403,782** | 0 |
| 7 Reserve fund | 1,500,000 | 0 | 0 |
| 8 Residual | | 0 | 0 |

**Step 4: the principal waterfall.** Principal receipts = £515,000 + £1,350,000 = £1,865,000; PDL credited = £1,403,782; available principal = **£3,268,782**, all to Class A.

#### Reading the result

- **All interest was paid in full, but only with the reserve's help.** Revenue receipts (£640,000) did not even cover fees and note interest (£679,343); the reserve paid the gap.
- **The reserve was then used up clearing the loss.** Item 6 took everything left, £1,403,782, and item 7 received nothing.
- **£196,218 of the loss stays on the Class B PDL**: Question 6 shows its effect on the notes.

#### Checking your answer

- **Revenue paid out = available.** £25,000 + £37,053 + £503,540 + £113,750 + £1,403,782 = £2,083,125.
- **Principal paid = available.** £3,268,782 to Class A, £0 to Class B.
- **Python gives a £1 difference** on the servicing fee (£37,052) because `round()` rounds halves to even; Extension E4 explains it. The deal says amounts are rounded to the nearest pound, and Excel's half-up rounding is the convention a trustee uses.

#### Mistakes people make on this question

- **Using month 1's opening balances for month 2's interest.** The fee becomes £37,500 and Class A interest £510,625; every line after them is wrong.
- **Forgetting the reserve in available revenue.** Available revenue of £640,000 leaves Class B interest short (Question 8) in a deal that has a reserve to pay it.
- **Paying the reserve before the PDL.** Item 6 comes before item 7; refilling the reserve while a PDL is outstanding reverses the priority.

#### Trade-offs and going further

- **Copying the month 1 block or rebuilding it.** Copying the waterfall block keeps the logic identical; only the inputs change. Rebuilding by hand invites small differences that are hard to find under time pressure.
- **Going further.** At what month 2 loss would the PDL have been cleared exactly? Excess spread (−£39,343) + reserve (£1,443,125) = **£1,403,782**: any loss up to that is cleared.

### Question 6: month 2 closing balances

#### What the question asks

> Give the closing balances, including any PDL outstanding. (6)

In plain words: roll the pool, both classes, the reserve and the PDL forward to the end of month 2, and show that they still reconcile.

The question uses the roll-forward of Question 3 and the reconciliation identity of Question 4 (Chapter 9, Section 9.4).

#### The plan

1. **Roll each balance forward** from its month 2 opening value.
2. **Compute the PDL outstanding**: losses debited minus PDL credited.
3. **Reconcile**: notes − pool must equal the PDL outstanding.

#### Step by step

| | Closing |
|---|---:|
| Pool: 148,210,000 − 1,865,000 − 1,600,000 | **144,745,000** |
| Class A: 127,210,000 − 3,268,782 | **123,941,218** |
| Class B | **21,000,000** |
| Reserve fund | **0** |
| Class B PDL outstanding: 1,600,000 − 1,403,782 | **196,218** |

Reconciliation: notes = £144,941,218; notes − pool = £196,218 = PDL outstanding. ✔

#### Reading the result

- **The notes now exceed the pool by £196,218.** That is the loss not yet covered by revenue: Class B's investors are exposed to it until future excess spread clears it.
- **The reserve is empty**, so next month any shortfall in revenue will fall directly on Class B interest.
- **Class A is still protected**: Class B's £21,000,000 sits below it.

#### Checking your answer

- **The workbook check** `=G48+G49-G47-G52` returns 0, as in month 1, even though notes and pool differ: the PDL explains the gap.
- **The PDL from the other side.** Losses £1,600,000 − cleared £1,403,782 = £196,218.

#### Mistakes people make on this question

- **Writing the PDL off against Class B's balance.** The PDL stays on the ledger until cleared or until the deal ends; Class B's balance is still £21,000,000.
- **Reducing the pool by the PDL credit.** The pool falls by principal receipts and losses only.

#### Trade-offs and going further

- **PDL or write-down.** Some deals write notes down at once; Calder, like Ashcombe, keeps a PDL that future excess spread can clear. A PDL gives Class B a chance to be made whole; a write-down makes the loss final immediately.
- **Going further.** Class A's credit enhancement is now (£21,000,000 − £196,218) ÷ £144,745,000 = **14.37%**: still higher than at closing.

### Question 7: what happened in month 2

#### What the question asks

> In three or four sentences, explain what happened in month 2, giving the cause before the result. (10)

In plain words: a short written explanation for someone who did not run the waterfall: what went wrong, what the deal did about it, and where it leaves the investors.

The question uses Questions 5 and 6 and the commentary method of Chapter 14 (Section 14.7): direction, size, cause, consequence.

#### The plan

1. **Name the two causes**: lower revenue and a large loss.
2. **Say what the waterfall did**: interest paid from the reserve, the reserve used on the PDL.
3. **Give the consequence** for the noteholders, with the numbers.

#### Step by step

> "Revenue fell to £640,000, so the deal's income no longer covered its fees and note interest: excess spread was negative at −£39,343. At the same time a £1.6m loss was debited to the Class B PDL. All interest was paid in full using the reserve fund, which was then used to clear £1,403,782 of the PDL and is now empty. £196,218 of the PDL remains uncleared, so the notes now exceed the pool by that amount, and Class B is exposed if future excess spread does not clear it."

Excess spread: £640,000 − £25,000 − £37,053 − £503,540 − £113,750 = −£39,343.

#### Reading the result

- **Four sentences, four ideas**: two causes, the reserve's role, the consequence.
- **Every number comes from the workbook**, so the manager can trace each one.

#### Checking your answer

- **Check each number** against the cells: −£39,343 (excess spread), £1.6m (loss), £1,403,782 (item 6 paid), £196,218 (PDL outstanding).
- **Read it aloud** to someone outside the team: they should be able to say what is wrong and who is affected.

#### Mistakes people make on this question

- **Result before cause.** "The reserve is empty" first, then the reasons, reads as alarm without explanation.
- **Saying the shortfall caused the loss**, or the other way round: they are separate events in the same month.
- **Numbers without meaning.** "Item 6 was 1,403,782" tells the reader nothing; "the reserve cleared £1.4m of the loss" does.

#### Trade-offs and going further

- **Four sentences or a table.** Sentences explain; a table lists. The marking rewards cause before result, so write sentences and put the figures in them.
- **Going further.** Add a fifth sentence on what to watch next month: whether revenue recovers and whether excess spread starts to clear the PDL.

### Question 8: month 2 with no reserve fund

#### What the question asks

> Recalculate month 2 assuming the deal had **no reserve fund** (zero at the start of month 2; everything else as in your month 1 results). Give the Class B interest paid, any shortfall, the PDL outstanding and Class A's closing balance. (12)

In plain words: rerun month 2 as if the reserve did not exist, to see what the reserve protected the investors from.

The question uses the same waterfall (Chapter 9, Section 9.6, *When revenue is not enough to pay interest*) and Calder's rule that unpaid Class B interest is deferred.

#### The plan

1. **Set available revenue to receipts only**: £640,000.
2. **Run the eight items**; the cash runs out somewhere.
3. **Find the shortfall, the PDL and the principal** that follow.

#### Step by step

| Item | Due | Paid | Cash left |
|---|---:|---:|---:|
| Available revenue | | | 640,000 |
| 1 Senior expenses | 25,000 | 25,000 | 615,000 |
| 2 Servicing fee | 37,053 | 37,053 | 577,947 |
| 3 Class A interest | 503,540 | 503,540 | 74,407 |
| 4 Class A PDL | 0 | 0 | 74,407 |
| 5 Class B interest | 113,750 | **74,407** | 0 |
| 6 Class B PDL | 1,600,000 | 0 | 0 |

- Class B interest paid **£74,407**; shortfall **£39,343**, deferred to month 3.
- Class B PDL outstanding: the whole **£1,600,000**.
- Available principal = receipts only, **£1,865,000**; Class A closes at £127,210,000 − £1,865,000 = **£125,345,000**.
- Check: notes £146,345,000 − pool £144,745,000 = £1,600,000 = PDL outstanding. ✔

In the workbook, the block copied to column J with K18 = 0 gives these figures.

#### Reading the result

- **The shortfall equals the negative excess spread** (£39,343): revenue did not cover the costs, so the most junior interest was short.
- **None of the loss is cleared**, so Class B carries the whole £1.6m PDL.
- **The comparison shows what the reserve bought**: £39,343 of Class B interest paid on time and £1,403,782 of loss cleared.

#### Checking your answer

- **Shortfall = −excess spread.** £113,750 − £74,407 = £39,343.
- **Reconciliation**, as above: the gap between notes and pool equals the PDL.

#### Mistakes people make on this question

- **Saying the shortfall causes the negative excess spread.** It is the other way round.
- **Paying the PDL before Class B interest.** Item 5 comes before item 6.
- **Calling the shortfall a default.** Class B interest is deferred; it is not an event of default under Calder's terms.

#### Trade-offs and going further

- **The cost of a reserve.** The £1.5m reserve was lent by the originator and earns little; this question shows what it is worth in a bad month.
- **Going further.** With no reserve, how much month 3 revenue is needed to pay the deferred interest as well as the month's costs? Month 3's costs plus £39,343.

### Question 9: CPR

#### What the question asks

> Calculate the annualised CPR for each month. (6)

In plain words: express each month's prepayments as an annual rate.

The question uses SMM and CPR (Chapter 10, Section 10.7).

#### The plan

1. **SMM** = prepayments ÷ (opening pool − scheduled principal).
2. **CPR** = 1 − (1 − SMM)<sup>12</sup>.

#### Step by step

- Month 1: SMM = £1,180,000 ÷ (£150,000,000 − £520,000) = 0.789%; CPR = 1 − (1 − 0.00789)<sup>12</sup> = **9.1%**.
- Month 2: SMM = £1,350,000 ÷ (£148,210,000 − £515,000) = 0.914%; CPR = **10.4%**.

Workbook: C41 `=1-(1-C21/(C15-C20))^12`, copied to month 2.

#### Reading the result

Prepayments sped up from 9.1% to 10.4% a year: a typical speed for a UK prime pool, and faster prepayment shortens the notes' life.

#### Checking your answer

Convert back: 1 − (1 − 0.091)<sup>1/12</sup> ≈ 0.79%, month 1's SMM. And 12 × SMM (9.5% and 11.0%) is above each CPR, as it must be.

#### Mistakes people make on this question

- **12 × SMM**, which overstates the CPR.
- **Dividing by the full opening pool**: a small difference here, but the wrong definition.

#### Trade-offs and going further

One month's CPR is noisy; reports add a three-month average. Going further: the average of the two SMMs (0.852%), compounded, gives a CPR of 9.8%.

### Question 10: cumulative losses and the trigger

#### What the question asks

> Calculate cumulative losses as a percentage of the original pool after each month. Is the trigger breached? (6)

In plain words: add up the losses so far, divide by the pool at closing, and compare with Calder's 0.50% trigger.

The question uses the cumulative loss measure and triggers (Chapter 9, Section 9.8).

#### The plan

1. **Add the losses month by month.**
2. **Divide by the original pool**, £150,000,000.
3. **Compare with 0.50%.**

#### Step by step

- After month 1: £90,000 ÷ £150,000,000 = **0.06%**: not breached.
- After month 2: (£90,000 + £1,600,000) ÷ £150,000,000 = **1.13%**: above 0.50%, so the trigger **is breached**.

Workbook: C42 `=C22/$B$5`, G42 `=(C22+G22)/$B$5`, and C43 `=C42>$B$11`.

#### Reading the result

The deal is already sequential, so the breach changes no payment here; depending on the documents it could trap residual cash or raise the reserve's required amount. It must be reported in the investor report.

#### Checking your answer

The denominator is fixed: £150,000,000 for every month. Month 2's loss alone is 1.07%; cumulative must be higher, and 1.13% is.

#### Mistakes people make on this question

- **Dividing by the current pool**, which makes the ratio drift upward as the pool shrinks.
- **Using month 2's loss alone** (1.07%).

#### Trade-offs and going further

A cumulative trigger never resets, so a breach is permanent; an arrears trigger can cure. Deals use both. Going further: how large a month 1 loss would have breached the trigger on its own? Anything above £750,000.

### Question 11: checks

#### What the question asks

> Name three checks you built into your workbook and their results. (6)

In plain words: show the marker that your numbers were proved, not hoped for.

The question uses the twelve checks of Chapter 14 (Section 14.4) and the check cells of Chapter 16 (Section 16.17).

#### The plan

Choose three checks that would fail if a common error were made, and show their results in each scenario.

#### Step by step

| Check | Month 1 | Month 2 | No reserve |
|---|---:|---:|---:|
| Revenue paid − available | 0 | 0 | 0 |
| Principal paid − available | 0 | 0 | 0 |
| Notes − pool − PDL | 0 | 0 | 0 |

Others accepted: opening month 2 = closing month 1; interest paid ≤ interest due; no negative numbers.

#### Reading the result

All checks show 0 in every scenario: the workbook is internally consistent.

#### Checking your answer

Break one cell on purpose: type 127,300,000 over the Class A closing balance (C48), as if the PDL credit had been forgotten. The notes − pool − PDL check becomes 90,000 at once. Undo the change. A check that never moves when something is broken is not a check.

#### Mistakes people make on this question

Checks hidden on another sheet; checks that compare a cell with itself; naming a check without showing its result.

#### Trade-offs and going further

Three checks score the marks; a real workbook has a check for every total. Colour them yellow so a reviewer sees them at once.

### Question 12: the email

#### What the question asks

> Write a short email (no more than 120 words) to your manager summarising the month 2 results and what you would watch next month. (15)

In plain words: the manager will read it in under a minute; it must say what happened, why, and what is next.

The question uses the commentary method of Chapter 14 (Section 14.7) and the communication advice of Chapter 22.

#### The plan

1. **Result and reconciliation first.**
2. **Causes and effects**, with the key numbers.
3. **What to watch next month.**

#### Step by step

> **Subject:** Calder No. 1, October payment date: results
>
> Hi [name],
>
> October's waterfall is done and reconciles. Revenue fell to £640k, so excess spread was negative (−£39k). A £1.6m loss was debited to the Class B PDL. All note interest was paid, but the reserve fund was fully used and £196k of the PDL remains outstanding. Cumulative losses are now 1.13%, above the 0.50% trigger, which needs to be reported.
>
> Next month I'll watch whether revenue recovers, any further losses, and whether excess spread starts to clear the PDL. Workbook attached.
>
> Thanks, [your name]

#### Reading the result

Under 100 words: the manager learns that the numbers are checked, what went wrong, the consequence for Class B, the trigger breach and the plan.

#### Checking your answer

Count the words; check every number against the workbook; read it as the manager would: is there anything to do? Yes: report the trigger.

#### Mistakes people make on this question

Opening with process ("I have completed the waterfall for month 2…"); numbers without units; no next step.

#### Trade-offs and going further

Brevity against completeness: the workbook carries the detail; the email carries the decision. Going further: rewrite it for an investor, without internal terms like "item 6".

## Extension questions

For readers who finish early, or want more practice. These go beyond what most tests ask.

**E1.** If Calder paid principal **pro rata** in month 1, how much would each class receive?

**E2.** Starting month 3 with the month 2 closing position and no new losses, how much revenue would the deal need in month 3 to clear the PDL and refill the reserve fund in one month?

**E3.** At month 1's level of excess spread, how long would the deal take to clear the PDL and refill the reserve?

**E4.** Rebuild month 1 in Python with the `run_waterfall` function of Chapter 18, changing its default inputs to Calder's terms. Do your results match?

### Solutions to the extension questions

#### E1: pro rata principal in month 1

##### What the question asks

> If Calder paid principal **pro rata** in month 1, how much would each class receive?

In plain words: how month 1's available principal would be split if the classes were paid in proportion to their balances.

##### The plan

Each class receives available principal × its share of the opening notes.

##### Step by step

Available principal is £1,790,000; opening notes £150,000,000. Class A: 1,790,000 × 129 ÷ 150 = **£1,539,400**. Class B: 1,790,000 × 21 ÷ 150 = **£250,600**.

##### Reading the result

Class B is repaid alongside Class A, so its share of the notes stays at 14% instead of rising.

##### Checking your answer

£1,539,400 + £250,600 = £1,790,000.

##### Mistakes people make on this question

Splitting by the original sizes once the classes have amortised.

##### Trade-offs and going further

Pro rata lowers the deal's cost (Class B's higher coupon is paid on a smaller balance) but stops Class A's credit enhancement from building up; deals allow it only while triggers are met, and Calder's loss trigger would switch it off after month 2.

#### E2: revenue to clear the PDL and refill the reserve in month 3

##### What the question asks

> Starting month 3 with the month 2 closing position and no new losses, how much revenue would the deal need in month 3 to clear the PDL and refill the reserve fund in one month?

In plain words: the month 3 revenue that would pay all costs, clear the PDL and refill the reserve at once.

##### The plan

Add month 3's items 1, 2, 3 and 5 due, the PDL outstanding and the reserve target.

##### Step by step

Senior expenses £25,000; servicing fee 144,745,000 × 0.30% ÷ 12 = £36,186; Class A interest 123,941,218 × 4.75% ÷ 12 = £490,601; Class B interest £113,750. Costs: **£665,537**. Plus PDL £196,218 and reserve £1,500,000: **£2,361,755**.

##### Reading the result

More than three times a normal month's revenue: it will not happen in one month.

##### Checking your answer

Put £2,361,755 as month 3 revenue in the workbook: the PDL clears, the reserve ends at £1,500,000 and the residual is 0.

##### Mistakes people make on this question

Using month 2's opening balances for the fee and interest.

##### Trade-offs and going further

In practice, the PDL and the reserve are rebuilt from excess spread over many months (E3); the one-month figure shows the size of the hole.

#### E3: how long excess spread takes to repair the damage

##### What the question asks

> At month 1's level of excess spread, how long would the deal take to clear the PDL and refill the reserve?

In plain words: the months needed to clear the PDL and refill the reserve at month 1's excess spread.

##### The plan

Months = (PDL + reserve shortfall) ÷ monthly excess spread, rounded up.

##### Step by step

(196,218 + 1,500,000) ÷ 33,125 = 51.2, so **52 months**, more than four years, assuming no further losses.

##### Reading the result

A large loss early in a deal's life weighs on it for years.

##### Checking your answer

52 × 33,125 = £1,722,500, just above £1,696,218; 51 months gives £1,689,375, just below.

##### Mistakes people make on this question

Rounding 51.2 down: 51 months is not enough.

##### Trade-offs and going further

Excess spread will not stay at £33,125: it shrinks as the pool repays and as Class A interest falls with its balance. A month-by-month projection gives a more exact answer.

#### E4: month 1 in Python

##### What the question asks

> Rebuild month 1 in Python with the `run_waterfall` function of Chapter 18, changing its default inputs to Calder's terms. Do your results match?

In plain words: the same month 1 waterfall from Chapter 18's `run_waterfall`, with Calder's terms.

##### The plan

Pass Calder's opening balances and receipts, and override the default deal terms.

##### Step by step

```python
import sys
sys.path.append("python")   # notebook only
from ch18_05_waterfall import run_waterfall

r = run_waterfall(150_000_000, 129_000_000, 21_000_000,
                  1_500_000, 720_000, 1_700_000, 90_000,
                  expenses=25_000, fee_rate=0.003,
                  coupon_a=0.0475, coupon_b=0.065,
                  reserve_required=1_500_000)
```

Excess spread £33,125, closing reserve £1,443,125, Class A £127,210,000: the same as the workbook.

##### Reading the result

Two independent tools agree, which is the strongest check a test answer can carry.

##### Checking your answer

Compare every line of `r` with column C of the workbook.

##### Mistakes people make on this question

Running month 2 and expecting a perfect match: Python gives a servicing fee of £37,052 and a PDL of £196,217, £1 different, because `round()` rounds halves to the even number (37,052.5 becomes 37,052) while Excel rounds them up.

##### Trade-offs and going further

Use `int(x + 0.5)` for positive amounts to match Excel, or the `decimal` module with `ROUND_HALF_UP`; matching a trustee's figures to the penny matters more than the method.

## Marking guide

| Part | Full marks need |
|---|---|
| A (25) | Every waterfall line right; excess spread and reserve explained; closing balances; reconciliation shown |
| B (30) | Month 2 opening balances linked to month 1; PDL partly cleared; explanation gives cause then result |
| C (30) | Shortfall equals negative excess spread; whole PDL outstanding without reserve; CPR not 12 × SMM; trigger on the original pool |
| D (15) | Short, numbers right, says what happened, why, and what next |

**Score guide:** 85+ is interview-ready; 70 to 84, review Chapter 9 and redo Part C; below 70, rebuild the Ashcombe waterfall in Chapter 16's workbook first, then retake the test.

> **Common beginner mistakes**
>
> - **Using closing balances for interest** (always the opening balance).
> - **Forgetting the reserve** in available revenue in month 2.
> - **Typing month 2 opening balances by hand** instead of linking them to month 1's results.
> - **Saying the shortfall causes negative excess spread.** It is the other way round.
> - **Dividing cumulative losses by the current pool.**
> - **No checks**, or checks that are not visible to the marker.

> **Tips**
>
> - Build month 1 completely, check it, then copy the block across for month 2 and change only the inputs.
> - Put your written answers in a text box or a separate sheet next to the numbers they explain.
> - If you run out of time, a fully correct month 1 with checks scores better than two half-finished months.
