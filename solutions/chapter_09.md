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
