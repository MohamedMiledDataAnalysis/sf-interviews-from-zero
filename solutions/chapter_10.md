# Chapter 10: Pool metrics: describing a pool of loans

## Corrections

### Exercise 1: original, current and indexed LTV

#### What the question asks

> A loan of £270,000 was made on a house valued at £300,000. The balance is now £240,000 and the house price index has risen 25% since. Calculate the original, current and indexed LTVs.

In plain words: three versions of the loan-to-value ratio for one loan. Each one pairs a balance (at origination or today) with a value (at origination or updated by the index).

The exercise uses the three LTVs of Section 10.3, *Loan-to-value (LTV): three versions*: original LTV = original balance ÷ original value; current LTV = current balance ÷ original value; indexed LTV = current balance ÷ indexed value.

#### The plan

1. **Write the four inputs** with their dates: balance then and now, value then and now.
2. **Compute the indexed value** from the index change, since it is not given directly.
3. **Pair each balance with its value** for the three ratios.
4. **Check the order** of the three results against what happened to the balance and to prices.

#### Step by step

**Step 1: inputs.** Original balance £270,000; current balance £240,000; original valuation £300,000; house prices up 25% since origination.

**Step 2: the indexed value.** £300,000 × 1.25 = **£375,000**. The index rose 25%, so the property's estimated value is 125% of its original value.

**Step 3: the three ratios.**

| LTV | Balance | Value | Result |
|---|---:|---:|---:|
| Original | 270,000 | 300,000 | **90.0%** |
| Current | 240,000 | 300,000 | **80.0%** |
| Indexed | 240,000 | 375,000 | **64.0%** |

- Original: £270,000 ÷ £300,000 = 0.90.
- Current: £240,000 ÷ £300,000 = 0.80.
- Indexed: £240,000 ÷ £375,000 = 0.64.

#### Reading the result

- **The borrower's equity has grown from 10% to 36% of today's value.** At origination it was £30,000 (£300,000 − £270,000); today it is £135,000 (£375,000 − £240,000).
- **Two causes, each visible in one step.** Repayments of £30,000 take the LTV from 90% to 80% (original to current); the 25% price rise takes it from 80% to 64% (current to indexed).
- **Indexed LTV is the one that measures risk today.** If the loan defaulted now, the sale would be based on today's price, not the price at origination. Chapter 11 uses it to estimate the loss (LGD from LTV, Section 11.3).
- **Three numbers, three questions.** Original LTV answers "how much did the lender risk at the start?"; current LTV, "how much has the borrower repaid?"; indexed LTV, "how much equity is there today?". Name the question before you quote the number.

#### Checking your answer

- **The order makes sense.** Indexed ≤ current ≤ original here, because the balance fell and prices rose. If prices had fallen, indexed LTV would be above current LTV.
- **Indexed LTV by another route.** Current LTV ÷ index factor = 80% ÷ 1.25 = 64%.
- **On the tape.** The tape's stored `indexed_ltv` must equal `current_balance ÷ indexed_valuation`; Chapter 15's consistency rule checks exactly this, and finds ASH100357 where it does not.
- **Equity adds up.** Equity today = indexed value − balance = £375,000 − £240,000 = £135,000; as a share, 1 − 64% = 36%. The two routes agree.
- **Ashcombe's pool.** The same pattern holds for the whole pool: WA original LTV 69.2%, WA indexed LTV 60.3% (Section 10.2).

#### Mistakes people make on this exercise

- **Calling £240,000 ÷ £375,000 the current LTV.** "Current" refers to the balance only; the value is still the original one.
- **Dividing the original balance by the indexed value** (£270,000 ÷ £375,000 = 72%): a ratio of two figures from different dates that measures nothing.
- **Adding 25 percentage points to the value instead of 25%.** The index rose by 25%, so the value is multiplied by 1.25, not increased by a fixed amount.
- **Rounding the index.** A rise of 25% is a factor of 1.25; using an index level (say 125.0 against 100.0) gives the same factor, but mixing two index dates (the month of origination and the month of the valuation) changes it. Check which index months the tape uses.
- **Indexing the balance.** The index applies to the property's value, not to the loan: the balance is what the borrower owes, whatever happens to house prices.

#### Trade-offs and going further

- **Index or valuation.** The indexed value uses a regional house price index, not a valuation of this house. It is cheap and updated every month, but can be wrong for one property; across a pool of 1,200 loans the errors average out, which is why reports use it.
- **Which LTV to report.** Prospectuses show original and indexed LTV strats; current LTV is rarely shown, because it mixes today's balance with an old value.
- **Going further.** If prices now fall 20% from today's level, the indexed value becomes £300,000 and the indexed LTV returns to 80%: the borrower's gain from the rise is wiped out, but the loan is still below its original 90%.
- **Regional or national index.** A regional index tracks local prices better than a national one; for a pool concentrated in one region, the choice can move the WA indexed LTV by several points.

### Exercise 2: SMM and CPR

#### What the question asks

> A month's prepayments are £1,500,000. The opening balance is £200,000,000 and scheduled principal is £500,000. Calculate SMM and CPR.

In plain words: in one month borrowers repaid £1.5 million more than their scheduled payments required. You must express that as a monthly prepayment rate (SMM) and then as the equivalent annual rate (CPR), the figure investor reports and interviewers use.

The exercise uses the two formulas of Section 10.7: SMM = prepayments ÷ (opening balance − scheduled principal), and CPR = 1 − (1 − SMM)<sup>12</sup>. The worked Ashcombe example in the same section follows the same steps.

#### The plan

1. **Find the balance that could have prepaid.** Scheduled principal is repaid anyway, so it cannot also be prepaid; it comes out of the denominator.
2. **Divide the prepayments by that balance** to get the SMM.
3. **Annualise by compounding,** not by multiplying by 12, because each month's rate applies to a balance that the earlier months have already reduced.
4. **Check by converting back** from CPR to SMM.

#### Step by step

**Step 1: the balance that could prepay.**

£200,000,000 − £500,000 = **£199,500,000**.

**Step 2: the SMM.**

SMM = £1,500,000 ÷ £199,500,000 = 0.0075188 = **0.752%**.

In one month, 0.752% of the balance that could prepay did prepay.

**Step 3: the CPR.**

- Share that did *not* prepay in the month: 1 − 0.0075188 = 0.9924812.
- Share that would survive twelve such months: 0.9924812<sup>12</sup> = 0.913414.
- Share that would prepay over the year: CPR = 1 − 0.913414 = 0.0866 = **8.7%**.

**Step 4: the same in Excel.** With prepayments in B1, the opening balance in B2 and scheduled principal in B3:

```
B4: =B1/(B2-B3)
B5: =1-(1-B4)^12
```

- `B4` is the SMM: the brackets make Excel subtract before dividing.
- `B5` compounds the monthly survival twelve times with `^12` and subtracts from 1. Format both as percentages: 0.75% and 8.66%.

And the same in Python:

```python
smm = 1_500_000 / (200_000_000 - 500_000)
cpr = 1 - (1 - smm) ** 12
print(f"SMM {smm:.3%}  CPR {cpr:.1%}")
```

- The underscores in the numbers are only for reading; Python ignores them.
- `**` is Python's power operator.
- The output is `SMM 0.752%  CPR 8.7%`.

#### Reading the result

- **The pool is prepaying at 8.7% a year.** If this month's pace continued, about 8.7% of the balance would be repaid early over the next twelve months, on top of scheduled repayments.
- **That is a moderate speed for a UK prime pool**, where CPRs of 10% to 20% are common; Ashcombe's month 1 was 10.5%.
- **For investors**, a higher CPR returns their money sooner, shortens the notes' WAL and reduces the excess spread the deal will earn over its life (Section 10.7).

- **The SMM is the number a model uses.** Cash flow models step month by month, so they apply the SMM to each month's balance: of £199.5 million that can prepay, 0.752% (£1.5 million) prepays this month. The CPR is how people talk about it: "the pool is prepaying at 8.7%". Being able to move between the two in both directions is a standard interview question.
- **A small change in SMM is a large change in CPR.** One extra £100,000 of prepayments in the month raises the SMM to 0.802% and the CPR to 9.2%. That sensitivity is why one large redemption can move a single month's CPR noticeably.

#### Checking your answer

- **Convert back.** SMM from CPR = 1 − (1 − 0.0866)<sup>1/12</sup> = 1 − 0.99248 = 0.752%. The round trip returns the starting SMM.
- **Compare with 12 × SMM.** 12 × 0.752% = 9.0%, slightly above 8.7%. It must be above, because 12 × SMM ignores the shrinking balance; if your CPR came out above 9.0%, the compounding is wrong.
- **Order of magnitude.** £1.5 million of £200 million is 0.75% a month; a year of that is "a little under 9%". The answer fits.

- **Python agrees.** The three lines of Step 4 print `SMM 0.752%  CPR 8.7%`, the same figures as the hand calculation and the spreadsheet.

#### Mistakes people make on this exercise

- **Multiplying by 12.** 0.752% × 12 = 9.0% overstates the CPR by 0.3 points. On a large pool that error changes the projected WAL and the cash flows investors are shown.
- **Using the full opening balance.** £1,500,000 ÷ £200,000,000 = 0.750%, CPR 8.6%. The difference is small here, but it is the wrong definition, and in an interview the definition is what is being tested.
- **Counting scheduled principal as prepayment.** (£1,500,000 + £500,000) ÷ £200,000,000 = 1.0% SMM, CPR 11.4%: a third too high. Scheduled repayments are not early repayments.
- **Writing (1 − SMM) × 12.** The power, not the multiplication: `(1-B4)^12`, not `(1-B4)*12`.

- **Reporting the CPR as a share of the original pool.** The CPR is a rate on the current balance; dividing prepayments by the pool at closing understates it more and more as the pool shrinks.

- **Formatting the SMM with no decimals.** Shown as 1%, an SMM of 0.752% hides the precision the CPR needs; display at least three decimals of a percentage for monthly rates.

#### Trade-offs and going further

- **One month against an average.** A single month's CPR is noisy: a few large redemptions move it. Investor reports often show one-month, three-month and life-to-date CPRs together; the longer averages are steadier but slower to show a change.
- **What counts as prepayment.** UK deals differ on product switches and repurchased loans (Section 10.7). Two deals with the same borrower behaviour can report different CPRs; check the definition before comparing.
- **Going further.** At what monthly prepayment amount would this pool show a CPR of exactly 10%? SMM = 1 − 0.90<sup>1/12</sup> = 0.8742%, so prepayments = 0.8742% × £199,500,000 = **£1,744,000** (to the nearest thousand).

- **CPR or an absolute amount.** Treasury teams planning the bank's funding often prefer pounds: "£1.5 million a month of prepayments". Investors prefer the CPR, because it compares pools of different sizes. Report the rate and keep the pounds in the working.
