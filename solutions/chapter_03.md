# Chapter 3: Bonds and notes

## Corrections

### Exercise 1: estimating the discount margin

#### What the question asks

> A note of £50,000,000 pays SONIA + 0.75% and trades at 99.40. Its WAL is 4 years. Estimate its discount margin.

In plain words: an investor who buys this floating-rate note at 99.40 instead of 100 earns more than the 0.75% margin, because the note will be repaid at 100. You must estimate the total return over SONIA, the discount margin, using the quick formula of the chapter.

The exercise uses floating-rate coupons (SONIA plus a margin, Section 3.3), prices quoted per 100 of face value (Section 3.4), the discount margin and its approximation, and the weighted average life (WAL), the average time until the note's principal is repaid (Section 3.5; WAL is calculated in Chapter 10).

#### The plan

1. **Find the price gain.** A note bought below 100 and repaid at 100 earns the difference; that gain is part of the return.
2. **Spread the gain over the note's life.** A gain earned over four years is worth a quarter of it each year; the WAL is the life to use, because the note repays gradually.
3. **Add the yearly gain to the margin.** The result is the discount margin, the return over SONIA.
4. **Check the approximation** against a full discounting of the cash flows.

#### Step by step

**Step 1: the price gain.**

Gain = 100 − 99.40 = **0.60** points per 100 of face value.

On the whole £50,000,000 note, the investor pays £50,000,000 × 99.40% = £49,700,000 and receives £50,000,000 of principal back: £300,000 more than paid.

**Step 2: the gain per year.**

Gain per year = 0.60 ÷ 4 = **0.15** points, that is 0.15% of face value each year.

The note does not repay all at once at year 4; its principal comes back over time, on average after 4 years. The WAL is that average, so dividing by it spreads the gain over the time the money is actually invested.

**Step 3: the discount margin.**

DM ≈ margin + (100 − price) ÷ WAL = 0.75% + 0.60 ÷ 4 = 0.75% + 0.15% = **0.90%**, or **90 basis points**.

The formula is the one in Section 3.5. It reads: what the note pays over SONIA, plus what the investor gains each year from the discount.

**Step 4: the same in Excel.** With the margin in B1, the price in B2 and the WAL in B3:

```
B4: =B1+(100-B2)/B3/100
```

- `100-B2` is the discount in points (0.60).
- `/B3` spreads it over the WAL (0.15).
- `/100` turns points per 100 into a rate (0.0015), so that it can be added to the margin of 0.0075. Format B4 as a percentage: 0.90%.

#### Reading the result

- **The investor earns about 0.90% a year over SONIA**: 0.75% from the coupon and 0.15% from the discount.
- **The price tells you what the market thinks.** Investors pay below par for a note paying SONIA + 0.75% because they want more than 0.75% for its risk today: about 0.90%. In the language of the chapter, the required margin has risen above the note's margin, so the note trades at a discount.
- **The discount matters more for short notes.** The same 0.60 discount on a note with a WAL of 2 years adds 0.30% a year, because the gain is earned in half the time.

#### Checking your answer

The approximation ignores discounting. A full check discounts the note's cash flows. Take a simple version: SONIA flat at 4.00%, so the coupon is 4.75% a year, and the principal repaid at year 4 (a WAL of 4 years). The discount rate y that makes the cash flows worth 99.40 solves

99.40 = 4.75 ÷ (1 + y) + 4.75 ÷ (1 + y)<sup>2</sup> + 4.75 ÷ (1 + y)<sup>3</sup> + 104.75 ÷ (1 + y)<sup>4</sup>.

In Excel, `=RATE(4,4.75,-99.40,100)` returns **4.92%**. The discount margin is 4.92% − 4.00% = **0.92%**, two basis points above the approximation. With quarterly payments the result is 0.92% as well. So 0.90% is a good estimate, and slightly low, because a gain received later is worth a little less than a gain spread evenly.

#### Mistakes people make on this exercise

- **Subtracting the discount.** 0.75% − 0.15% = 0.60%. Buying below 100 raises the return; the DM must be above the margin. The quick test: at a price of 100, the DM equals the margin; below 100, it must be higher.
- **Forgetting to divide by the WAL.** 0.75% + 0.60% = 1.35% counts the whole four-year gain as if it were earned in one year.
- **Using the legal final maturity instead of the WAL.** A UK RMBS note can have a legal final maturity 40 years away; 0.60 ÷ 40 = 0.015% would make the discount almost worthless. Investors are repaid, on average, after the WAL, not at legal final.
- **Mixing points and percentages.** 0.60 ÷ 4 = 0.15 is in price points, which equal 0.15% of face value. Adding 0.15 (not 0.15%) to 0.0075 in Excel gives 15.75%.

#### Trade-offs and going further

- **Quick formula or full model.** The approximation is accurate to a few basis points for small discounts and WALs of a few years, which is why it is used in interviews and as a check. A trading desk uses the full cash flow model, because the error grows with larger discounts and longer lives.
- **The WAL is itself an assumption.** It depends on how fast the loans prepay. If prepayments speed up and the WAL falls to 3 years, the DM rises to 0.75% + 0.20% = 0.95%; if they slow and the WAL rises to 5 years, it falls to 0.87%. An investor who buys at a discount benefits from faster prepayment; one who buys at a premium loses from it.
- **Going further.** At what price would the DM be exactly 1.00% with a WAL of 4 years? Solve 0.75% + (100 − price) ÷ 4 = 1.00%: 100 − price = 1.00, so the price is **99.00**.
