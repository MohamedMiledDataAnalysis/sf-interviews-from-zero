# Chapter 2: Loans, interest and principal

## Corrections

### Exercise 1: month 4 of the £150,000 loan

#### What the question asks

> For the £150,000 loan in this chapter, calculate the interest, principal and closing balance in month 4. Start from the month 3 closing balance of £149,218.40 and a payment of £859.50.

In plain words: the chapter's example splits the first three monthly payments of a £150,000 repayment mortgage at 4.8% over 25 years into interest and principal. You must produce the next row of that table: how much of month 4's payment is interest, how much repays the loan, and what the borrower owes afterwards.

The exercise uses the monthly rate (annual rate ÷ 12, Section 2.1), the level payment of a repayment mortgage (the annuity formula and `PMT`, Section 2.3), and the split of each payment into interest on the opening balance and principal (the worked example of Section 2.3 and the explanation of Section 2.4).

#### The plan

1. **Find the monthly rate.** Interest is charged monthly, so the annual 4.8% must be converted first.
2. **Charge interest on the opening balance.** The opening balance of month 4 is the closing balance of month 3; interest is always on what is owed at the start of the month.
3. **Take the rest of the payment as principal.** The payment is fixed; whatever is not interest repays the loan.
4. **Roll the balance forward** and check the row against the pattern of months 1 to 3.

#### Step by step

**Step 1: the monthly rate.**

r = 4.8% ÷ 12 = 0.4% = 0.004.

The bank quotes an annual rate, but the borrower pays every month, so each month carries one twelfth of the annual rate. This is the convention for UK mortgages.

**Step 2: interest for month 4.**

Interest = opening balance × r = £149,218.40 × 0.004 = £596.8736, which rounds to **£596.87**.

The opening balance is £149,218.40, the month 3 closing balance from the chapter's table. Interest is calculated on it, not on the original £150,000, because the borrower has already repaid £781.60 of principal in the first three months and pays no interest on money no longer owed.

**Step 3: principal for month 4.**

Principal = payment − interest = £859.50 − £596.87 = **£262.63**.

The payment is the same every month (£859.50); interest takes its share first, and everything left reduces the balance.

**Step 4: closing balance.**

Closing balance = opening balance − principal = £149,218.40 − £262.63 = **£148,955.77**.

The completed row, with the three rows of the chapter above it:

| Month | Opening balance | Interest | Principal | Closing balance |
|---:|---:|---:|---:|---:|
| 1 | 150,000.00 | 600.00 | 259.50 | 149,740.50 |
| 2 | 149,740.50 | 598.96 | 260.53 | 149,479.97 |
| 3 | 149,479.97 | 597.92 | 261.58 | 149,218.40 |
| **4** | **149,218.40** | **596.87** | **262.63** | **148,955.77** |

**Step 5: the same row in Excel.** With the opening balance in B5, the monthly rate in $B$1 and the payment in $B$2:

```
C5: =ROUND(B5*$B$1,2)
D5: =$B$2-C5
E5: =B5-D5
```

- `C5` multiplies the opening balance by the monthly rate and rounds to pence, as a bank statement does.
- `D5` subtracts the interest from the fixed payment; the `$` signs keep the payment cell fixed when the row is copied down.
- `E5` gives the closing balance, which becomes the next row's opening balance (`B6: =E5`).

#### Reading the result

- **Most of the payment is still interest.** Of £859.50, £596.87 (69%) pays interest and £262.63 (31%) repays the loan. Four months into a 25-year mortgage, the split has hardly moved from month 1 (70% and 30%).
- **The principal grows by about £1 a month**: £259.50, £260.53, £261.58, £262.63. Each month the balance is a little lower, so the interest is a little lower, so a little more of the fixed payment goes to principal. Section 2.4 explains why this snowball starts slowly and accelerates in the later years.
- **For an investor**, this is scheduled principal: the part of the pool's repayments that can be forecast exactly. Prepayments come on top.

#### Checking your answer

Three independent checks.

- **The row adds up.** Interest + principal = £596.87 + £262.63 = £859.50, the payment.
- **The pattern holds.** The principal must be slightly above month 3's £261.58, and it is.
- **Excel's own functions agree.** `=IPMT(4.8%/12,4,300,-150000)` returns 596.87 for the interest of month 4, and `=PPMT(4.8%/12,4,300,-150000)` returns 262.62 for the principal. The £0.01 difference from 262.63 comes from the payment: `PPMT` uses the exact payment, £859.4954, while the exercise rounds it to £859.50. `=-FV(4.8%/12,4,-859.4954443,150000)` gives the closing balance after month 4 as £148,955.77, the same to the penny.

#### Mistakes people make on this exercise

- **Charging interest on the original balance.** £150,000 × 0.004 = £600.00, which gives principal of £259.50 and a closing balance of £148,958.90, £3.13 too high. The symptom is a principal that never grows. The fix: always use the opening balance of the month.
- **Using the annual rate.** £149,218.40 × 4.8% = £7,162.48 of "interest", more than eight times the payment, which makes the principal negative. The fix: divide by 12 first.
- **Subtracting the whole payment from the balance.** £149,218.40 − £859.50 = £148,358.90. That treats the interest as if it repaid the loan; the balance then falls far too fast.
- **Rounding too early.** Rounding the monthly rate to 0.4% is exact here, but rounding a rate like 5.25% ÷ 12 = 0.4375% to 0.44% changes every row. Keep full precision and round only the money amounts you show.

#### Trade-offs and going further

- **Rounded or exact payment.** The exercise uses £859.50, as the borrower's statement would. A model that uses the exact £859.4954 gives £262.62 of principal. Both are accepted; what matters is to use one convention consistently and say which.
- **Monthly or daily interest.** UK mortgages usually charge one twelfth of the annual rate. Some lenders charge daily interest (actual days ÷ 365), which makes each month's interest slightly different. Read the product terms before reconciling a servicer's figures to the penny.
- **Going further.** Copy the Excel row down to month 300. The closing balance of month 300 should be zero (within a few pence from rounding), and the total interest over the life is 300 × £859.50 − £150,000 = £107,850.
