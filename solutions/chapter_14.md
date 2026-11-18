# Chapter 14: Investor reporting and surveillance

## Corrections

### Exercise 1: the checks that catch a loss not debited to the PDL

#### What the question asks

> Which three of the twelve checks would catch a loss that was recorded in the pool but not debited to the PDL?

In plain words: a defaulted loan has been sold at a loss, and the loan data shows the pool smaller by that loss. But whoever ran the waterfall forgot to enter the loss on the principal deficiency ledger. You must say which of the analyst's twelve monthly checks would reveal the error, and why.

The exercise uses the twelve checks of Section 14.4, the PDL and how it is cleared (Chapter 9, Sections 9.4 and 9.5), and the Ashcombe report of 20 October 2026 (Section 14.3), whose month had a £260,000 loss.

#### The plan

1. **Rerun the month with the error,** so that the checks are tested on real numbers, not on intuition.
2. **Follow the error through the waterfall:** what changes in revenue, in principal, in the note balances.
3. **Go through the twelve checks** and keep those whose two sides no longer agree.
4. **Rank them:** the one that catches the error directly, and those that show where the two sides diverge.

#### Step by step

**Step 1: the October month, right and wrong.** The companion's `run_waterfall` (Chapter 18) runs the month. The correct run debits the £260,000 loss; the wrong run passes a loss of 0, as if the PDL entry had been forgotten:

```python
import sys
sys.path.append("python")   # notebook only
from ch18_05_waterfall import run_waterfall

m1 = run_waterfall(236_900_000, 203_300_000, 33_600_000,
                   2_400_000, 1_045_000, 2_880_000, 52_000)
```

```python
args = (m1["Closing pool"], m1["Closing Class A"],
        m1["Closing Class B"], m1["Closing reserve"],
        1_038_000, 3_150_000)
ok = run_waterfall(*args, 260_000)
bad = run_waterfall(*args, 0)
```

- `m1` is September, the month before; its closing balances open October.
- `args` collects October's inputs except the loss; `*args` passes them to the function in order.
- `ok` debits the £260,000 loss; `bad` forgets it.

**Step 2: what the error changes.**

| | Correct | Loss not debited |
|---|---:|---:|
| 6 Class B PDL paid | 260,000 | 0 |
| 7 Reserve fund paid | 2,163,148 | 2,400,000 |
| 8 Residual to originator | 0 | **23,148** |
| Class A principal | 3,410,000 | 3,150,000 |
| Class A closing | 196,958,000 | 197,218,000 |

Without the PDL debit, item 6 pays nothing, so the excess spread refills the reserve to its target and £23,148 leaks out to the originator as residual. On the principal side, Class A receives £260,000 less, because no revenue was moved into the principal pot.

Meanwhile the loan data, which did record the loss, shows the pool at **£230,558,000**.

**Step 3: the twelve checks against the wrong run.**

- **Check 7, notes − pool = PDL outstanding.** Notes = £197,218,000 + £33,600,000 = £230,818,000; pool = £230,558,000; notes − pool = **£260,000**, but PDL outstanding = **£0**. **Fails** by exactly the loss.
- **Check 2 with check 6, the pool roll-forward against the notes' roll-forward.** The pool roll-forward includes the loss: £233,968,000 − £690,000 − £2,460,000 − £260,000 = £230,558,000. The notes fall only by the principal paid, £3,150,000. The pool has fallen £260,000 more than the notes, with nothing on the PDL to explain it. **Fails** when the two are compared.
- **Check 11, large movements explained.** Losses of £260,000 appear in the pool's movements but nowhere in the waterfall, and the residual jumps from £0 to £23,148. An unexplained movement. **Fails.**

The other checks pass: revenue paid out still equals available revenue (check 4), principal paid still equals available principal (check 5), and interest is unaffected (check 9). Each side is internally consistent; only comparing the two sides reveals the error.

#### Reading the result

- **Check 7 is the one that catches the error directly.** It is the identity that ties the liability side (notes) to the asset side (pool) through the PDL. An unexplained gap of exactly £260,000 points straight at the missing debit.
- **Checks 2 and 6, compared, and check 11 confirm where it happened.** They show the pool and the notes moving by different amounts, and a loss that has no counterpart in the waterfall.
- **The cost of missing it is real.** £23,148 would be paid to the originator that belongs to the noteholders, and Class A would be repaid £260,000 too slowly. Both are hard to reverse once the payment instructions have gone.

#### Checking your answer

- **Test the check, not only the answer.** Rerun the correct month: notes = £196,958,000 + £33,600,000 = £230,558,000 = pool, PDL outstanding £0: check 7 passes. The check fails only when the error is present, which is what a good check does.
- **The size of the failure equals the size of the error.** £230,818,000 − £230,558,000 = £260,000, the loss. A check that fails by an unrelated amount would point to a different problem.
- **The leak adds up.** In the wrong run, the reserve needed £2,400,000 − £2,383,271 = £16,729 to reach target; excess spread of £39,877 minus £16,729 = £23,148, the residual paid.

#### Mistakes people make on this exercise

- **Choosing check 4 or check 5.** Both pass: the waterfall pays out exactly what it believes is available. Internal consistency is not correctness.
- **Choosing check 9 (interest).** Interest depends on opening balances and coupons, not on this month's loss.
- **Naming check 7 without saying why.** The interviewer wants the mechanism: the notes did not fall with the pool, and the PDL that should explain the gap is zero.
- **Assuming the reserve shows the problem.** In the wrong run the reserve ends *full*, which looks healthy; the error makes the deal look better than it is.

#### Trade-offs and going further

- **Many checks or one.** Check 7 alone would catch this error, but not, for example, a keying error in an opening balance (check 1) or an arrears table that does not tie to the pool (check 8). Each check catches a different kind of mistake, which is why all twelve are run every month.
- **Manual or automated.** Twelve checks by hand take time each month; built as formulas or code that show 0 when right (Chapters 16 to 18), they take seconds and leave a record that the trustee can review.
- **Going further.** Which check would catch the opposite error: a loss debited to the PDL but not removed from the pool? Check 7 again (the notes would now be £260,000 *below* the pool shown in the loan data, with no PDL to explain it), and check 3, because the pool balance in the waterfall would no longer equal the sum of the loan balances on the tape.
