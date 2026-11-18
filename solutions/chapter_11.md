# Chapter 11: Credit risk and expected loss

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
