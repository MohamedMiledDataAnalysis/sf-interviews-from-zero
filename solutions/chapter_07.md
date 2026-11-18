# Chapter 7: The life of a deal: dates and documents

## Corrections

### Exercise 1: a long first interest period on 30/360

#### What the question asks

> A deal closes on 10 March and its first payment date is 20 April. On 30/360, how many days is the first interest period? A note of £50,000,000 pays 5% fixed. What is the first interest payment?

In plain words: the first interest period of a deal runs from closing to the first payment date, and it is rarely a whole month. You must count its days on the 30/360 convention and then calculate the interest the note earns over that irregular period.

The exercise uses the interest period (Section 7.1, *The monthly cycle*), the irregular first period (the example in the same section), and the day-count conventions of Chapter 3 (Section 3.2, *The coupon*): on 30/360 every month counts as 30 days and the year as 360.

#### The plan

1. **Count the days on 30/360,** splitting the period into whole months and the days left over. The convention is what makes this different from counting days on a calendar.
2. **Calculate the interest** with the 30/360 formula: balance × rate × days ÷ 360.
3. **Compare with a regular month,** to see why the first payment is larger.
4. **Check the day count with Excel's `DAYS360`.**

#### Step by step

**Step 1: the 30/360 day count.**

- 10 March to 10 April: one whole month = **30 days** on 30/360 (March really has 31 days, but the convention counts every month as 30).
- 10 April to 20 April: **10 days**.
- Total: 30 + 10 = **40 days**.

The general formula, for dates D1/M1/Y1 to D2/M2/Y2, is 360 × (Y2 − Y1) + 30 × (M2 − M1) + (D2 − D1) = 0 + 30 × 1 + 10 = 40.

**Step 2: the first interest payment.**

Interest = balance × rate × days ÷ 360 = £50,000,000 × 5% × 40 ÷ 360 = **£277,777.78**, or **£277,778** to the nearest pound.

**Step 3: compare with a regular month.**

A regular 30-day month: £50,000,000 × 5% × 30 ÷ 360 = £208,333.33.

The first payment is 40 ÷ 30 = 1.33 times a regular month, because the first period is a third longer.

**Step 4: the same in Excel.**

```
B3: =DAYS360(DATE(2026,3,10),DATE(2026,4,20))
B4: =ROUND(50000000*5%*B3/360,0)
```

- `DAYS360(start, end)` returns the 30/360 day count: 40.
- `B4` applies the interest formula with the count from `B3` and rounds to the pound: 277,778.

#### Reading the result

- **The first interest period is 40 days**, ten days longer than a regular month, because the deal closed on the 10th and pays on the 20th.
- **Investors receive £277,778**, a third more than a regular monthly payment of £208,333. They are paid for every day their money has been invested since closing.
- **The waterfall must fund it.** The first payment draws on more than a month of collections: Ashcombe's first collection period runs from the day after the cut-off date, so it includes collections before closing (Section 7.1). A deal with a long first period checks that the first month's revenue covers the larger interest bill.

- **The same logic applies to every irregular period.** If the deal later moves its payment date, or a payment date falls on a weekend and the documents roll it to the next business day, the interest period changes length again. On 30/360 the day count is always calculated from the actual dates of the period, so the paying agent's notice for each period is the document to check.

#### Checking your answer

- **Scale a regular month.** £208,333.33 × 40 ÷ 30 = £277,777.78. Same answer by a different route.
- **Compare with actual days.** On a calendar, 10 March to 20 April is 41 days (21 left in March plus 20 in April). On ACT/365 the interest would be £50,000,000 × 5% × 41 ÷ 365 = £280,822. The 30/360 figure is lower because it counts March as 30 days, and divides by 360: the conventions differ, and the documents say which applies.
- **Excel.** `=DAYS360(DATE(2026,3,10),DATE(2026,4,20))` returns 40.

- **Count the months, then the days.** 10 March → 10 April is one month (30), 10 April → 20 April is ten days: writing the period in these two pieces is the fastest way to count 30/360 days by hand in an interview.

#### Mistakes people make on this exercise

- **Counting actual days on a 30/360 note.** 41 days gives £284,722 on 30/360 (41 ÷ 360), £6,944 too much. The symptom: the first payment does not match the paying agent's notice. The fix: use the note's convention, and `DAYS360` in Excel.
- **Paying a regular month.** £208,333 for the first period leaves 10 days of interest unpaid.
- **Dividing by 365 on a 30/360 note.** £50,000,000 × 5% × 40 ÷ 365 = £273,973. Days and denominator must come from the same convention.
- **Starting the period at the cut-off date.** Interest on the notes starts when investors pay for them, at closing, not when the pool was measured.

#### Trade-offs and going further

- **Long or short first period.** A long first period (closing to a payment date more than a month away) gives the deal time to collect cash before paying; a short one pays sooner but with less collected. The arranger chooses, and the prospectus states the first payment date and the first interest period.
- **30/360 against actual days.** 30/360 makes every regular month identical, which is simple to model and to check. Actual-day conventions follow the calendar exactly, which floating-rate notes need because SONIA is a daily rate.
- **Going further.** The same note, with closing on 10 March and the first payment on 20 March, has a short first period: `DAYS360` gives 10 days and the interest is £50,000,000 × 5% × 10 ÷ 360 = **£69,444**.

- **Which convention the investor sees.** A 30/360 note pays the same amount in every regular month, which is easy for investors to forecast; an ACT/365 note pays slightly more in 31-day months and less in February. Neither is better: the convention is set in the terms of the notes, and the analyst's job is to apply it exactly.
