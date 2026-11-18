# Chapter 9: The waterfall, step by step

## Corrections

### Exercise 1: month 1 with less revenue

#### What the question asks

> Recalculate month 1 with revenue receipts of £1,000,000 instead of £1,045,000. What are excess spread, the reserve fund at the end, and Class A's closing balance?

In plain words: rerun the chapter's month 1 waterfall for Ashcombe with £45,000 less interest collected, everything else unchanged, and report three numbers: the month's excess spread, where the reserve fund ends, and Class A's balance after the principal waterfall.

The exercise uses the two pots of cash (Section 9.1), the eight items of the revenue waterfall (Section 9.2), the principal waterfall and the PDL credit (Sections 9.3 and 9.4), and the month 1 inputs of the worked example (Section 9.5): opening pool £236,900,000, Class A £203,300,000, Class B £33,600,000, reserve £2,400,000, principal receipts £2,880,000, loss £52,000.

#### The plan

1. **Work out available revenue**, receipts plus the reserve, because in Ashcombe the reserve is part of the revenue pot.
2. **Run the eight revenue items** in order, each paid the smaller of what is due and the cash left. The items before the PDL are unchanged; the lower revenue shows at the bottom.
3. **Compute excess spread** from receipts and items 1, 2, 3 and 5.
4. **Run the principal waterfall**, with the PDL credit from item 6, and roll Class A forward.
5. **Reconcile the notes to the pool.**

#### Step by step

**Step 1: available revenue.**

Available revenue = revenue receipts + reserve = £1,000,000 + £2,400,000 = **£3,400,000**.

**Step 2: the revenue waterfall.** Amounts due are the chapter's month 1 amounts, which depend on the opening balances, not on revenue:

- Senior expenses: £30,000.
- Servicing fee: £236,900,000 × 0.25% ÷ 12 = £49,354.
- Class A interest: £203,300,000 × 4.50% ÷ 12 = £762,375.
- Class B interest: £33,600,000 × 6.00% ÷ 12 = £168,000.
- Class B PDL: the £52,000 loss.

| Item | Due | Paid | Cash left |
|---|---:|---:|---:|
| Available revenue | | | 3,400,000 |
| 1 Senior expenses | 30,000 | 30,000 | 3,370,000 |
| 2 Servicing fee | 49,354 | 49,354 | 3,320,646 |
| 3 Class A interest | 762,375 | 762,375 | 2,558,271 |
| 4 Class A PDL | 0 | 0 | 2,558,271 |
| 5 Class B interest | 168,000 | 168,000 | 2,390,271 |
| 6 Class B PDL | 52,000 | 52,000 | 2,338,271 |
| 7 Reserve fund (target 2,400,000) | 2,400,000 | **2,338,271** | 0 |
| 8 Residual | | 0 | 0 |

Every item is paid in full except the reserve, which receives everything left: **£2,338,271**.

**Step 3: excess spread.**

Excess spread = receipts − items 1, 2, 3 and 5 = £1,000,000 − £30,000 − £49,354 − £762,375 − £168,000 = **−£9,729**.

Revenue receipts did not cover fees and note interest: the reserve paid the £9,729 gap.

**Step 4: the principal waterfall.**

Available principal = principal receipts + PDL credited = £2,880,000 + £52,000 = £2,932,000, all to Class A.

Class A closing = £203,300,000 − £2,932,000 = **£200,368,000**.

**Step 5: the same with Python.** The companion's `run_waterfall` (Chapter 18) takes the month's inputs in the order pool, Class A, Class B, reserve, revenue, principal, losses:

```python
import sys
sys.path.append("python")   # notebook only
from ch18_05_waterfall import run_waterfall
```

```python
r = run_waterfall(236_900_000, 203_300_000, 33_600_000,
                  2_400_000, 1_000_000, 2_880_000, 52_000)
print(r["Excess spread"], r["Closing reserve"],
      r["Closing Class A"])
```

- The first block makes the script importable from a notebook and imports the function.
- The call passes month 1's inputs with the new revenue.
- The `print` shows the three answers: −9729, 2338271 and 200368000.

#### Reading the result

- **Excess spread is −£9,729**: the month's interest receipts fell short of fees and note interest. No noteholder notices, because the reserve fund is part of available revenue and paid the gap.
- **The reserve ends at £2,338,271**, £61,729 below its £2,400,000 target. It paid for two things: the £9,729 shortfall and the £52,000 loss that item 6 cleared.
- **Class A closes at £200,368,000, exactly as in the chapter's month 1** with £1,045,000 of revenue. The cost of the lower revenue sits entirely in the reserve. That is the reserve doing its job: protecting the notes from a bad month.

#### Checking your answer

- **The reserve's fall equals the shortfall plus the loss.** £2,400,000 − £2,338,271 = £61,729 = £9,729 + £52,000.
- **The revenue side adds up.** Paid amounts: £30,000 + £49,354 + £762,375 + £0 + £168,000 + £52,000 + £2,338,271 + £0 = £3,400,000, the available revenue.
- **Notes reconcile to the pool.** Pool closing = £236,900,000 − £2,880,000 − £52,000 = £233,968,000. Notes = £200,368,000 + £33,600,000 = £233,968,000. Notes − pool = 0 = PDL outstanding.
- **Python agrees** with every figure, as shown in Step 5.

#### Mistakes people make on this exercise

- **Leaving the reserve out of available revenue.** With only £1,000,000, items 1 to 5 take £1,009,729 and Class B interest is £9,729 short; the PDL gets nothing and Class A closes £52,000 higher, at £200,420,000. That is the answer for a deal without a reserve, not for Ashcombe.
- **Skipping the PDL because excess spread is negative.** Item 6 is paid from available revenue, which includes the reserve, so the loss is still cleared.
- **Calling −£9,729 a loss.** It is a revenue shortfall. A loss reduces the pool; a shortfall reduces cash. Only losses go to the PDL.
- **Recomputing the due amounts from the revenue.** Fees and interest depend on the opening balances and the rates, not on how much was collected.

#### Trade-offs and going further

- **A reserve in revenue, or a separate reserve.** Ashcombe adds the reserve to available revenue, so it can pay anything above it in the waterfall, including the PDL. Some deals let the reserve pay only senior fees and senior interest (a liquidity reserve); then the loss would stay on the PDL and Class A would close higher. Read the definition of Available Revenue in the documents.
- **One bad month against a trend.** One shortfall of £9,729 is harmless. Repeated shortfalls drain the reserve and leave nothing for the next loss. Surveillance analysts watch the reserve balance against its target for exactly that reason.
- **Going further.** What revenue would make excess spread exactly zero in this month? Revenue = £30,000 + £49,354 + £762,375 + £168,000 = **£1,009,729**.

### Exercise 2: clearing a PDL with excess spread

#### What the question asks

> In month 2 without a reserve fund, the £220,123 Class B PDL is outstanding. In month 3, excess spread is £45,000 and there are no new losses. How much of the PDL is cleared, and what is left?

In plain words: in the version of month 2 with no reserve fund (Section 9.6), revenue could clear only £39,877 of the £260,000 loss, so £220,123 stayed on the Class B PDL. In month 3 there is £45,000 left after items 1 to 5. Follow that money down the waterfall and say what happens to the PDL.

The exercise uses the revenue waterfall's order (Section 9.2), the PDL and how it is cleared (Section 9.4), the no-reserve example (Section 9.6), and excess spread (Chapter 8, Section 8.6): revenue left after senior costs and note interest.

#### The plan

1. **Find what reaches item 6.** With no reserve and no new loss, items 4 (Class A PDL) and the new part of item 6 are zero; the £45,000 left after items 1 to 5 all reaches the Class B PDL.
2. **Apply it to the outstanding PDL.**
3. **Follow the cleared amount into the principal waterfall**, because a PDL credit is principal.
4. **Check** with the gap between notes and pool.

#### Step by step

**Step 1: what reaches item 6.**

- Items 1 to 5 (expenses, fee, Class A interest, Class A PDL, Class B interest) are paid in full from revenue.
- £45,000 is left. Item 4 is £0, because Class A has no PDL.
- Item 6 is due £220,123: the PDL carried from month 2, plus £0 of new losses.

**Step 2: clear it.**

- Paid to item 6: the smaller of £45,000 and £220,123 = **£45,000**.
- PDL outstanding after month 3: £220,123 − £45,000 = **£175,123**.
- Item 7 (reserve) and item 8 (residual) receive nothing; in this version there is no reserve to refill.

**Step 3: where the £45,000 goes.** It is credited to the principal waterfall, alongside month 3's principal receipts, and repays **Class A**: the deal is sequential, so all principal goes to Class A first.

**Step 4: months to clear.** At £45,000 a month with no new losses: £175,123 ÷ £45,000 = 3.9, so **four more months**; month 7 clears the last £40,123.

#### Reading the result

- **Excess spread is the first defence and also the repair.** In month 2 it was too small to absorb the loss; from month 3 it rebuilds the protection, £45,000 a month.
- **Class B is not paid less interest.** Item 5 is paid in full in month 3; the PDL is a gap in principal backing, not a missed coupon.
- **The originator waits.** The residual holder receives nothing until the PDL is cleared: the investors are made whole first.
- **The PDL is a signal to investors.** An outstanding Class B PDL appears in the investor report every month until it is cleared; a PDL that grows instead of shrinking is one of the first things a surveillance analyst flags.

#### Checking your answer

- **Notes minus pool.** Before month 3, notes exceed the pool by £220,123, the PDL. In month 3 the pool falls by principal receipts only (no losses); the notes fall by principal receipts plus the £45,000 credit. The gap shrinks to **£175,123**, exactly the PDL still outstanding.
- **The waterfall pays out what it has.** Items 1 to 5 plus £45,000 to item 6 equal available revenue; nothing is left over.
- **In the workbook.** On the Chapter 16 Waterfall sheet, set B6 (reserve) to 0, B7 (revenue) to 1,043,123 so that D22 shows £45,000 after items 1 to 5, and B9 to 220,123 to stand for the PDL brought forward: C23 pays £45,000 and C41 shows £175,123.

#### Mistakes people make on this exercise

- **Writing the PDL off against Class B's balance.** In Ashcombe, a PDL is a ledger, not a write-down; Class B's balance stays £33.6m, and the PDL is cleared over time or, at the end of the deal, written off.
- **Paying the £45,000 to Class B.** The cleared amount enters the principal waterfall, and principal is sequential: it goes to Class A.
- **Refilling a reserve.** The question removes the reserve; with one, item 7 would still come after item 6, so the PDL would be cleared first anyway.

#### Trade-offs and going further

- **Who pays for the repair.** The £45,000 would otherwise go to the residual holder, often the originator. Clearing the PDL first is the price of the investors' protection, and part of why originators prefer to keep the reserve funded.
- **Reserve or no reserve.** With the £2,383,271 reserve of the main example, the PDL never appeared; without it, the deal needs about five months of excess spread to recover. The reserve buys time.
- **Going further.** If month 4 brings a new £60,000 loss and £45,000 of excess spread, the PDL rises to £175,123 + £60,000 − £45,000 = £190,123: losses faster than excess spread make the PDL grow.
