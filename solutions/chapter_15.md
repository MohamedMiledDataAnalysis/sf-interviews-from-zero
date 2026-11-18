# Chapter 15: Data quality and reconciliation

## Corrections

### Exercise 1: a stored LTV that does not match

#### What the question asks

> A loan has a current balance of £150,000, an indexed valuation of £250,000 and a stored indexed LTV of 0.63. Does it pass rule 9? What would you do?

In plain words: the loan tape stores a ready-made indexed LTV for each loan, and rule 9 checks that it agrees with the balance and valuation on the same row. You must apply the rule to this loan, decide whether it passes, and say what happens next.

The exercise uses the six dimensions of data quality (Section 15.1: this is a **consistency** rule), rule 9 of the loan tape checklist and its tolerance of 0.005 (Section 15.2, *Why tolerances matter*), the indexed LTV of Chapter 10 (Section 10.3), and the exceptions log (Section 15.3).

#### The plan

1. **Recalculate the LTV** from the fields it is made of. A stored ratio can only be checked against its inputs.
2. **Measure the difference and compare it with the tolerance.** The tolerance exists because stored values are rounded; the question is whether this difference is rounding or an error.
3. **Decide which value is wrong** before changing anything, because three fields are involved and any one of them can be the culprit.
4. **Run the same rule on the whole tape,** since a rule that is right for one loan should be applied to all of them.

#### Step by step

**Step 1: recalculate.**

Recalculated indexed LTV = current balance ÷ indexed valuation = £150,000 ÷ £250,000 = **0.60**.

**Step 2: the difference and the tolerance.**

Difference = |0.63 − 0.60| = **0.03**, that is 3 percentage points.

Tolerance = 0.005 (0.5 percentage points). 0.03 > 0.005, so the loan **fails** rule 9: the difference is six times the tolerance, far beyond rounding.

**Step 3: which value is wrong?** Three explanations fit:

| If this were wrong | It would need to be | How to check |
|---|---|---|
| The stored LTV | 0.60 | Ask how the LTV field is produced (copied or calculated) |
| The indexed valuation | £150,000 ÷ 0.63 = £238,095 | Compare with the valuation system and the index date |
| The balance | 0.63 × £250,000 = £157,500 | Compare with the servicing system's balance |

Search the source systems for £238,095 or £157,500: a stale valuation or an old balance often matches one of them exactly.

**Step 4: the same rule on the whole Ashcombe tape**, in pandas:

```python
import pandas as pd
tape = pd.read_csv("data/ashcombe_loan_tape.csv")
recalc = tape["current_balance"] / tape["indexed_valuation"]
diff = (tape["indexed_ltv"] - recalc).abs()
```

- `recalc` divides the two columns row by row: the recalculated LTV of every loan.
- `diff` is the absolute difference from the stored LTV; `.abs()` makes it positive whichever value is larger.

```python
fails = tape[diff > 0.005]
print(fails[["loan_id", "current_balance",
             "indexed_valuation", "indexed_ltv"]])
print(tape["indexed_valuation"].isna().sum())
```

- `tape[diff > 0.005]` keeps the loans that fail the rule.
- The first `print` shows them: one loan, **ASH100357**, balance £217,068, valuation £468,000, stored LTV 0.64 against a recalculated 0.4638.
- The second `print` counts blank valuations: **1** (ASH101045), which the rule cannot test at all.

**Step 5: the exceptions log entry.** "DQ-03 · Loan [ID] · Rule 9 (stored LTV) · Stored indexed LTV 0.63; balance ÷ valuation = 0.60 · Wrong LTV band in the strat · Owner: data team · Action: confirm the three source values, correct at source, recalculate LTV in the tape build."

#### Reading the result

- **The loan fails.** Its stored LTV puts it in the ">60% to 70%" band of the strat, but its real LTV of 60% belongs in ">50% to 60%". One band shift on one loan is small, but investors read the strat, and the regulatory file carries the stored value.
- **On the Ashcombe tape, rule 9 finds exactly one such loan**, ASH100357, where the gap is much larger (64% stored against 46.38%). It is error 2 of Practice test 2.
- **A blank valuation is a separate problem.** ASH101045 cannot be checked; it needs a completeness rule, not a consistency rule.

#### Checking your answer

- **Check the arithmetic both ways.** 0.60 × £250,000 = £150,000, the balance: the recalculated LTV reproduces its inputs; 0.63 × £250,000 = £157,500 does not.
- **Check the rule with a loan that should pass.** For a loan stored at 0.6022 whose balance and valuation give 0.6020, the difference is 0.0002, below 0.005: it passes. A rule should fail errors and pass rounding.
- **Check that the code catches what it should.** On the Ashcombe tape the rule returns ASH100357 alone; Chapter 15's checklist and Practice test 2 name the same loan.

#### Mistakes people make on this exercise

- **No tolerance.** Testing `stored == recalculated` fails almost every loan, because stored LTVs are rounded to a few decimals; the exceptions log fills with noise and the real error is lost.
- **Comparing without `abs()`.** `stored − recalculated > 0.005` catches stored values that are too high but not those that are too low.
- **Missing the blank.** In pandas, a comparison with a blank (NaN) is False, so ASH101045 silently passes rule 9. Always pair a consistency rule with a completeness check on its inputs.
- **Overwriting the stored LTV and moving on.** The next tape will carry the same error; fix the source, and log it.

#### Trade-offs and going further

- **Tolerance width.** 0.005 suits values rounded to two or three decimals. A tighter tolerance catches smaller errors but flags rounding; a wider one lets real errors through. Set it from how the field is stored, and write the reason next to the rule.
- **Store or calculate.** If every report recalculated LTV from balance and valuation, a wrong stored value would never reach a strat. But the stored field is still sent to investors and regulators in loan-level files, so it must be correct even if your own reports do not use it.
- **Going further.** Rule 9 also applies to the **original** LTV: `original_balance ÷ original_valuation`. On the Ashcombe tape that version of the rule finds **no** failures.
