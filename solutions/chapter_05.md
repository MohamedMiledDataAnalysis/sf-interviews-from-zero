# Chapter 5: The counterparties and how the cash flows

> © 2026 Mohamed Miled. All rights reserved. This text is part of the book *Structured Finance Interviews from Zero* and may not be copied, republished or sold. The code blocks are under the MIT licence (see `LICENSE`); the explanations are not (see `LICENSE-TEXT.md`).

## Corrections

### Exercise 1: reconciling the servicer report to the bank

#### What the question asks

> The servicer's report shows £1,284,000 of interest collected and £3,120,000 of principal. The bank statement shows £4,398,000 received in the transaction account. What is the difference, and name two possible causes.

In plain words: two documents describe the same month's collections. The servicer says how much borrowers paid; the bank statement says how much arrived in the SPV's account. You must measure the gap between them, say which side is higher, and give two realistic explanations.

The exercise uses the roles of the servicer and the account bank (Sections 5.1 and 5.2), the collection account and the transaction account (Section 5.5), and the path of one pound from borrower to investor (Section 5.6). The reconciliation method itself is developed in Chapter 15.

#### The plan

1. **Put both sources on the same basis.** The servicer splits collections into interest and principal; the bank shows one total. Add the servicer's two figures first.
2. **Subtract and state the direction.** A difference without a sign is useless: "£6,000" could mean cash is missing or cash is unexplained.
3. **List the places money can be between the borrower and the transaction account,** and the ways a report can be wrong. Each is a candidate cause.
4. **Say how you would confirm each cause.** An interviewer wants the next action, not only the theory.

#### Step by step

**Step 1: the servicer's total.**

Servicer total = interest + principal = £1,284,000 + £3,120,000 = **£4,404,000**.

**Step 2: the difference.**

Bank − servicer = £4,398,000 − £4,404,000 = **−£6,000**.

The bank received **£6,000 less** than the servicer reports as collected. Stated as a share of collections: £6,000 ÷ £4,404,000 = 0.14%.

**Step 3: where £6,000 can be.** Follow the path of Section 5.6: borrower → collection account (run by the servicer, held on trust for the SPV) → sweep → transaction account (the SPV's account at the account bank). The gap can arise at each step:

| Possible cause | Where | What it would look like |
|---|---|---|
| **Timing**: collections on the last day of the period not yet swept | Collection account | £6,000 arrives in the transaction account in the first days of the next month |
| **A reversed payment**: a direct debit counted as collected, then returned unpaid | Collection account | A £6,000 reversal on the collection account statement |
| **A report error**: an amount keyed or classified wrongly | Servicer report | The loan-level data does not add up to the report's totals |
| **Fees deducted before the transfer** when the documents do not allow it | Sweep | The servicer's fee netted off the sweep |

Any two of these answer the question; timing and a reversed payment are the commonest.

**Step 4: confirm the cause.** For each candidate there is a test:

- Timing: compare the collection account statement for the last two days of the period with the sweep dates.
- Reversal: ask the servicer for the list of returned direct debits in the period.
- Report error: add the loan-level collections in the servicer's data and compare with £4,404,000.
- Netting: compare the sweep amounts with the gross collections day by day.

#### Reading the result

- **£6,000 is small but not ignorable.** It is 0.14% of the month's collections, but the cash manager can pay out only the cash that is in the account. If the waterfall were run on the servicer's £4,404,000, it would instruct payments of £6,000 more than the SPV has.
- **The sign points to the kind of cause.** Cash *short* in the bank suggests money still on its way (timing) or money that never arrived (reversal). Cash *above* the report would suggest unreported collections, which leads to different questions.
- **Every difference must be explained before the waterfall runs**, and the explanation recorded. That is the habit an interviewer is testing.

#### Checking your answer

- **Recompute from the other side.** £4,398,000 − £1,284,000 = £3,114,000. If interest is correct, the principal actually received is £3,114,000, £6,000 below the report: consistent with the difference.
- **Check the sign with a one-line formula.** In Excel, `=4398000-(1284000+3120000)` returns −6000: negative means the bank is lower.
- **Check that the causes can produce exactly £6,000.** A timing difference or a reversal of one or a few payments can; rounding cannot (rounding is pence or pounds, not thousands).

#### Mistakes people make on this exercise

- **Giving the difference without the direction.** "The difference is £6,000" leaves the reader not knowing whether cash is missing. Write "the bank received £6,000 less than reported".
- **Calling it rounding.** Rounding differences are a few pounds at most; £6,000 needs a cause.
- **Comparing only one component.** Comparing interest (£1,284,000) with the bank total makes no sense: the bank statement is one figure for both, so the servicer's two figures must be added first.
- **Correcting the report to match the bank.** Changing the servicer's numbers to force a match hides the cause. If it is timing, the cash arrives next month and the difference reverses; if it is an error, the servicer corrects its report.

#### Trade-offs and going further

- **Log or correct.** A timing difference is logged and followed up next month; an error is corrected by the servicer at source. Deciding which it is needs evidence from the servicer, so ask before changing anything.
- **Tolerances.** Some teams accept small differences below a threshold (for example £100) without investigation. A tolerance saves time but must be documented and agreed with the trustee; £6,000 is above any sensible threshold.
- **Going further.** If next month's bank statement shows £6,000 more than the servicer reports, and the servicer confirms a late sweep, write the exceptions log entry: what was found, its impact (none on the waterfall once the cash arrived), the owner (the servicer) and the status (closed, timing).
