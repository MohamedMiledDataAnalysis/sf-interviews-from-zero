# Chapter 10: Pool metrics: describing a pool of loans

## Corrections

### Exercise 1: SMM and CPR

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
