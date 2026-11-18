# Chapter 6: Asset classes and deal types

## Corrections

### Exercise 1: credit card excess spread

#### What the question asks

> A credit card pool has a portfolio yield of 18%, a charge-off rate of 5%, and note interest plus servicing costs of 6%, all annual. What is the excess spread?

In plain words: a credit card pool earns interest and fees, loses part of its balances when cardholders cannot pay, and must pay its noteholders and its servicer. You must find what is left each year, as a percentage of the pool.

The exercise uses the four card metrics of Section 6.4 (payment rate, portfolio yield, charge-off rate, excess spread) and the definition given there: excess spread is yield minus charge-offs minus note interest and servicing costs. The early amortisation trigger is in the same section; the general idea of excess spread is developed in Chapter 8.

#### The plan

1. **Check that the three rates are on the same basis.** All are annual percentages of the same balance, so they can be added and subtracted directly.
2. **Subtract the losses and the costs from the yield.**
3. **Translate the rate into pounds** for a pool size, because a rate alone is hard to feel.
4. **Find how far charge-offs could rise** before the excess spread disappears: that is the cushion investors care about.

#### Step by step

**Step 1: the basis.** The question says "all annual" and all three are percentages of the pool balance. A yield of 18% means the pool earns £18 a year per £100 of balances; a charge-off rate of 5% means £5 per £100 is written off; costs of 6% mean £6 per £100 goes to the notes and the servicer. Because the base is the same, the three can be combined by subtraction.

**Step 2: the excess spread.**

Excess spread = yield − charge-offs − costs = 18% − 5% − 6% = **7%** a year.

**Step 3: in pounds.** For a pool of £1,000,000,000 (a typical UK card master trust is larger):

- Yield: £180,000,000 a year.
- Charge-offs: £50,000,000.
- Note interest and servicing: £60,000,000.
- Excess spread: £70,000,000 a year, about £5,833,000 a month.

In Excel, with the yield in B1, the charge-off rate in B2, the costs in B3 and the pool in B4:

```
B5: =B1-B2-B3
B6: =B5*B4/12
```

- `B5` is the excess spread rate, 7%.
- `B6` turns it into pounds a month: the rate times the pool, divided by 12.

**Step 4: the cushion.** Excess spread reaches zero when charge-offs rise by the whole 7%:

18% − charge-offs − 6% = 0, so charge-offs = **12%**.

Charge-offs could more than double, from 5% to 12%, before the pool stops covering its costs.

#### Reading the result

- **The pool earns 7% a year more than it needs.** That surplus is the first protection for noteholders: losses are paid from income before any note is touched.
- **Cards need a large excess spread.** Card balances are unsecured: when a cardholder defaults, almost nothing is recovered, so charge-offs of 4% to 6% a year are normal. The high yield (interest at 20% or more plus fees) pays for them. A mortgage pool earns far less, but its losses are far smaller.
- **The cushion is what investors watch.** Card deals set a trigger on the three-month average excess spread: if it falls below the trigger level, revolving stops and the notes are repaid early (Section 6.4).

- **A mortgage comparison.** Ashcombe's excess spread is 0.29% a year (Chapter 8), less than a twentieth of this card pool's. The mortgage pool needs far less, because its losses are far smaller and recovered in part from the sale of the house; but a small cushion also means a small rise in costs or fall in yield can wipe it out.

#### Checking your answer

- **Add back.** Charge-offs + costs + excess spread = 5% + 6% + 7% = 18%, the yield.
- **Limiting case.** If charge-offs were 0%, excess spread would be 18% − 6% = 12%; if costs were 0%, 13%. The answer, 7%, lies below both, as it must.
- **Monthly check.** £70,000,000 ÷ 12 = £5,833,333 a month, matching `B6`.

- **Per £100 of balances.** Out of every £100 the pool earns £18; £5 is written off, £6 goes to the notes and the servicer, and £7 is left. Writing the four amounts side by side is the quickest way to explain excess spread to someone outside finance, and to see at once that 5 + 6 + 7 = 18.

#### Mistakes people make on this exercise

- **Applying the charge-off rate to the yield.** 18% × (1 − 5%) = 17.1%, then 17.1% − 6% = 11.1%. That treats charge-offs as a share of income; they are a share of the balance, like the yield, so they are subtracted directly.
- **Forgetting the servicing cost.** 18% − 5% = 13% is the pool's net yield, not excess spread: the notes and the servicer must be paid first.
- **Mixing monthly and annual rates.** Card reports often show monthly charge-offs (for example 0.42% a month). Annualise them (× 12) before subtracting them from an annual yield, or the excess spread looks far larger than it is.

#### Trade-offs and going further

- **High yield against high losses.** A higher yield gives a bigger cushion but usually comes from riskier cardholders, whose charge-offs are also higher and more volatile. Investors judge the cushion against how much charge-offs can move, not only against today's level.
- **Annual against three-month average.** One month's excess spread can be distorted by seasonal spending or a one-off write-off; deals test the three-month average for that reason. The average is steadier but reacts later to a real deterioration.
- **Going further.** If the trigger is a three-month average excess spread of 0%, and charge-offs rise by 1 percentage point a month from 5%, in which month does the single-month excess spread first reach zero? It reaches 0% when charge-offs are 12%, which is 7 months later. The three-month average reaches zero one month after that.
