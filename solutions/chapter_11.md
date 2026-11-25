# Chapter 11: Credit risk and expected loss

> © 2026 Mohamed Miled. All rights reserved. This text is part of the book *Structured Finance Interviews from Zero* and may not be copied, republished or sold. The code blocks are under the MIT licence (see `LICENSE`); the explanations are not (see `LICENSE-TEXT.md`).

## Corrections

### Exercise 1: recovery, loss and LGD under a house price fall

#### What the question asks

> A loan of £210,000 is secured on a house with an indexed valuation of £280,000. House prices fall 30% and sale costs are 8%. Calculate the recovery, loss and LGD.

In plain words: the borrower defaults and the lender sells the house. Prices have fallen 30% and selling costs 8% of the sale price. You must find what the lender gets back, how much it loses, and the loss as a share of the loan (the loss given default, LGD).

The exercise uses the three building blocks PD, LGD and EAD (Section 11.2) and the formula of Section 11.3: recovery = indexed valuation × (1 − house price fall) × (1 − sale costs), and loss = MAX(0, EAD − recovery). The idea of a stress scenario is in Section 11.4.

#### The plan

1. **Find the starting position:** the loan's indexed LTV, which tells you how much equity protects the lender before any fall.
2. **Apply the house price fall** to the valuation.
3. **Apply the sale costs** to the reduced price, not to the original valuation.
4. **Compute loss and LGD,** and find the break-even fall to see how close the loan was to losing nothing.

#### Step by step

**Step 1: the starting position.**

Indexed LTV = £210,000 ÷ £280,000 = **75%**. The borrower's equity is £70,000, 25% of the house's value.

**Step 2: the house price fall.**

Stressed value = £280,000 × (1 − 30%) = £280,000 × 0.70 = **£196,000**.

**Step 3: the sale costs.**

Recovery = £196,000 × (1 − 8%) = £196,000 × 0.92 = **£180,320**.

The costs (estate agent, legal fees, repairs) are a share of the price actually achieved, so they apply after the fall.

**Step 4: loss and LGD.**

- Loss = MAX(0, EAD − recovery) = MAX(0, £210,000 − £180,320) = **£29,680**.
- LGD = loss ÷ EAD = £29,680 ÷ £210,000 = **14.1%**.

**Step 5: the same in Excel.** With the balance in B1, the valuation in B2, the fall in B3 and the costs in B4:

```
B5: =B2*(1-B3)*(1-B4)
B6: =MAX(0,B1-B5)
B7: =B6/B1
```

- `B5` is the recovery: valuation, then the fall, then the costs.
- `B6` is the loss; `MAX(0, …)` stops it going negative when the recovery exceeds the balance (the borrower keeps any surplus, so the lender's loss is zero, not a gain).
- `B7` is the LGD.

#### Reading the result

- **The lender recovers £180,320 and loses £29,680, 14.1% of the loan.** Put the other way, it gets back 86p in the pound.
- **The 25% equity was not enough** for a 30% fall plus costs. Equity of £70,000 absorbed most of the £84,000 fall, and the £15,680 of costs pushed the result into a loss.
- **LTV drives LGD.** The chapter's example shows the same mechanism: a 60% LTV loan loses 17.5% under a much harsher 45% fall, and an 85% LTV loan loses 41.8% under the same stress. The higher the LTV, the smaller the price fall needed to produce a loss.

- **The loss would fall on the deal through the PDL.** In a securitisation, this £29,680 would be debited to the principal deficiency ledger when the house is sold (Chapter 9) and cleared from excess spread if the deal has enough; if not, it would reduce the most junior notes. One loss of this size is small against Ashcombe's monthly excess spread of about £58,000, but a stress scenario applies the same arithmetic to hundreds of loans at once.

#### Checking your answer

- **The parts add up.** Recovery + loss = £180,320 + £29,680 = £210,000, the EAD.
- **Break-even fall.** The loss is zero when value × (1 − fall) × 0.92 = £210,000, so value × (1 − fall) = £228,261 and the fall = 1 − £228,261 ÷ £280,000 = **18.5%**. A 30% fall is well beyond that, so a loss is expected; a 15% fall would give none.
- **A milder case as a sense check.** With a 20% fall: £280,000 × 0.80 × 0.92 = £206,080, a loss of £3,920 (1.9%). Just past break-even, the loss is small, as it should be.

- **The chapter's own example as a template.** Section 11.3 works a 60% LTV loan under a 45% fall and 10% costs: recovery £148,500, loss £31,500, LGD 17.5%. Running that example through the same three Excel cells reproduces the chapter, which proves the cells before you trust them on this exercise.

#### Mistakes people make on this exercise

- **Adding the two percentages.** 30% + 8% = 38%: £280,000 × 0.62 = £173,600, a loss of £36,400 (17.3%). The costs apply to the reduced price, so the right factor is 0.70 × 0.92 = 0.644, not 0.62.
- **Applying the fall to the loan instead of the house.** Prices affect the security, not the debt: the borrower still owes £210,000.
- **Dividing the loss by the valuation.** £29,680 ÷ £280,000 = 10.6% is the loss as a share of the house; LGD is a share of the exposure, £210,000.
- **Leaving out `MAX(0, …)`.** For a low-LTV loan the recovery can exceed the balance; without the floor, the spreadsheet shows a negative loss, which overstates the pool's recoveries when the losses are added up.

#### Trade-offs and going further

- **A simple formula against a full model.** The formula ignores the months between default and sale, during which interest accrues unpaid and the property may need maintenance. Rating agencies add a foreclosure period and its costs to their stresses, which raises the LGD above this calculation.
- **Indexed valuation against a real sale.** The indexed valuation uses a regional price index, not a survey of this house. A repossessed house often sells below the index (a forced-sale discount), which is one reason stress scenarios use falls larger than any seen in history.
- **Going further.** Under the same 30% fall and 8% costs, what indexed LTV produces an LGD of exactly zero? 0.70 × 0.92 = 0.644, so any loan with an indexed LTV of **64.4%** or less loses nothing.

### Exercise 2: roll rate and cure rate

#### What the question asks

> Of 40 loans 2 months in arrears last month, 14 are now 3+ months in arrears and 18 are up to date. Calculate the roll rate and cure rate.

In plain words: follow one group of loans, the 40 that were two months behind last month, and say what share got worse (rolled to 3 months or more) and what share caught up completely (cured).

The exercise uses roll rates and cure rates, the measures of Section 11.8, *Monitoring credit risk each month*, and the arrears buckets of Chapter 10 (Section 10.6).

#### The plan

1. **Fix the starting group**: last month's 2-month bucket, 40 loans. Every rate is a share of this group.
2. **Roll rate** = loans that moved to the next worse bucket ÷ starting loans.
3. **Cure rate** = loans now up to date ÷ starting loans.
4. **Account for the rest**, so the three outcomes add up to 40.

#### Step by step

**Step 1: the starting group.** 40 loans were 2 months in arrears last month.

**Step 2: the roll rate.** 14 of them are now 3+ months in arrears: 14 ÷ 40 = **35%**.

**Step 3: the cure rate.** 18 are now up to date: 18 ÷ 40 = **45%**.

**Step 4: the rest.** 40 − 14 − 18 = **8 loans (20%)** are still 2 months behind or have improved to 1 month.

| Outcome this month | Loans | Share of the 40 |
|---|---:|---:|
| Rolled to 3+ months | 14 | 35% |
| Cured (up to date) | 18 | 45% |
| Still 1 or 2 months | 8 | 20% |
| **Total** | **40** | **100%** |

#### Reading the result

- **More loans cured than rolled**, which is common: many arrears are temporary (a late salary, a changed bank account).
- **A 35% roll from 2 to 3+ months is high.** Section 11.8's example shows a 21.6% roll from 1 to 2 months; roll rates usually rise in the deeper buckets, because a borrower who has missed two payments is more likely to be in real difficulty. At 3+ months, the loan is close to the point where the servicer starts possession proceedings.
- **For a forecast**, multiplying roll rates bucket by bucket estimates how many of today's 1-month cases will reach default: the roll-rate matrix of Chapter 16 (Section 16.15) and Chapter 18 (Section 18.8) does this with the whole history.
- **Ashcombe's own numbers.** In the June tape, 23 loans are 2 months in arrears and 24 are 3 months or more; applying a 35% roll to the 23 gives 8.05, so 8 loans would move to the 3+ bucket next month, before any cures among the 24.

#### Checking your answer

- **The outcomes add up.** 14 + 18 + 8 = 40, and 35% + 45% + 20% = 100%.
- **Same group, both rates.** Both rates divide by 40, last month's bucket. If a rate used this month's 3+ total (which also includes loans that were already 3+), the outcomes would not add to 100%.
- **In the data.** The history file gives the same calculation for Ashcombe: count the loans at 2 months in May and see where each one is in June (Chapter 17, Section 17.10).
- **A cure must be checked loan by loan.** A loan that was 2 months behind and is now up to date has paid two missed instalments plus the current one. If it shows up to date but its arrears balance has not fallen, ask whether the arrears were capitalised (added to the balance) rather than paid.

#### Mistakes people make on this exercise

- **Dividing by this month's 3+ bucket.** That bucket mixes loans that rolled in with loans already there; a roll rate always follows the same loans from one month to the next.
- **Counting cures as any improvement.** A loan that moved from 2 months to 1 month has improved but not cured; "cure" means back to up to date.
- **Reading a 45% cure rate as good news on its own.** It is good for those 18 loans; the 14 that rolled are the ones that drive losses.
- **Treating capitalised arrears as a cure.** A loan whose arrears are added to its balance shows 0 months behind without the borrower paying anything: in the data it cures, in substance it does not. Forbearance (Chapter 13) is the usual cause.

#### Trade-offs and going further

- **Loans or balance.** Counting loans is simple and stable; weighting by balance shows the money at risk. A few large loans can move a balance-weighted roll rate a lot, so reports often show both.
- **One month or an average.** A single month is noisy with 40 loans: one loan is 2.5 percentage points. Analysts average roll rates over three or six months before using them in a forecast.
- **Going further.** If 35% of 2-month loans roll to 3+, and 60% of 3+ loans eventually default, 21% of today's 2-month loans will default: 35% × 60%.
- **Roll rates and transition matrices.** A full matrix shows every move between buckets (up to date, 1, 2, 3+, possession) in one table; the roll and cure rates of this exercise are two cells of it.
