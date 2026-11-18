# Chapter 12: Interest rate, liquidity and counterparty risk

## Corrections

### Exercise 1: the net swap payment

#### What the question asks

> Under a swap on a £50,000,000 notional, the SPV pays Bank Rate and receives 3.75%. Bank Rate is 3.25%. What is the monthly net payment, and who pays?

In plain words: the SPV has agreed to exchange interest with a bank. Each month the SPV owes Bank Rate on £50 million and is owed a fixed 3.75% on the same amount. Only the difference changes hands. You must find that difference for one month and say which side pays it.

The exercise uses the interest rate mismatch of Section 12.1 and the swap of Section 12.2: a notional on which no principal changes hands, two interest legs, and a single net payment. The Ashcombe example in Section 12.2 has the same structure at a 4.00% fixed rate.

#### The plan

1. **Compute each leg's monthly amount**: what the SPV pays and what it receives. Seeing both makes the direction obvious.
2. **Net the two legs**: only the difference is paid.
3. **State who pays**: the side that owes the larger leg pays the difference.
4. **Explain what the payment does for the deal,** because an interviewer will ask why the SPV has a swap at all.

#### Step by step

**Step 1: the two legs.** Monthly interest on the notional is notional × rate ÷ 12.

- SPV pays Bank Rate: £50,000,000 × 3.25% ÷ 12 = **£135,416.67**.
- SPV receives fixed: £50,000,000 × 3.75% ÷ 12 = **£156,250.00**.

**Step 2: net the legs.**

Net = £156,250.00 − £135,416.67 = **£20,833.33**, or **£20,833** to the nearest pound.

The same in one step: (3.75% − 3.25%) × £50,000,000 ÷ 12 = 0.50% × £50,000,000 ÷ 12 = £20,833.

**Step 3: who pays.** The SPV receives more than it pays, so the **swap counterparty pays £20,833 to the SPV**.

**Step 4: the same in Excel.** With the notional in B1, the fixed rate in B2 and Bank Rate in B3:

```
B4: =B1*(B2-B3)/12
B5: =IF(B4>0,"Counterparty pays the SPV","SPV pays the counterparty")
```

- `B4` is the net payment from the SPV's point of view: positive means the SPV receives.
- `B5` turns the sign into words, which is what a report reader needs.

#### Reading the result

- **The counterparty pays the SPV £20,833 a month** while Bank Rate stays at 3.25%.
- **The payment replaces lost income.** Suppose the £50 million notional matches £50 million of tracker loans in the pool. When Bank Rate is below 3.75%, those loans earn less than the deal assumed; the swap pays the gap. With the trackers earning Bank Rate plus their margin, the SPV's income on them is the same as if Bank Rate were 3.75%.
- **The swap works both ways.** If Bank Rate rose to 4.25%, the SPV would pay the counterparty 0.50% × £50,000,000 ÷ 12 = £20,833 a month, but its tracker loans would earn that much more. The SPV gives up the upside to remove the downside, which is exactly what fixed-rate noteholders want.

- **The swap payment sits near the top of the waterfall.** When the SPV owes the counterparty, the net payment is made before Class A interest (Section 12.2); when the counterparty owes the SPV, as here, the £20,833 is added to the month's available revenue.

#### Checking your answer

- **Gross legs against the net.** £156,250.00 − £135,416.67 = £20,833.33, the same as the one-step calculation.
- **A neutral point.** At Bank Rate 3.75%, both legs are £156,250 and the net is zero. The answer must change sign around 3.75%, and it does.
- **A second rate.** At Bank Rate 3.00% the net is 0.75% × £50,000,000 ÷ 12 = £31,250 to the SPV: each 0.25% fall in Bank Rate adds £10,417 a month, so the net is a straight line in Bank Rate.

- **Against the hedged loans.** If £50,000,000 of tracker loans pay Bank Rate + 1.00%, they earn 4.25% today, £177,083 a month. Adding the swap's net £20,833 gives £197,917, which is exactly what they would earn at Bank Rate 3.75% (4.75% × £50,000,000 ÷ 12). The swap has fixed the income at the level the deal was structured for.

#### Mistakes people make on this exercise

- **Paying both legs in full.** Writing that the SPV pays £135,417 and receives £156,250 is not wrong as a description, but swaps settle the net amount on each payment date; reporting two gross flows in a waterfall double counts the cash.
- **Getting the direction wrong.** The SPV pays the floating rate and receives the fixed one; with Bank Rate below the fixed rate, the SPV is owed money. Reversing the legs gives the right amount with the wrong payer.
- **Forgetting to divide by 12.** £250,000 is the annual net, not the monthly payment.
- **Treating the notional as money exchanged.** The £50,000,000 never moves; it only sizes the interest.

- **Using the loans' rate instead of Bank Rate.** The swap's floating leg is Bank Rate itself, not the tracker loans' rate (Bank Rate plus their margin). The margin stays with the loans and is not swapped.

#### Trade-offs and going further

- **Hedged against unhedged.** The swap removes rate risk from the deal, which protects the junior notes' excess spread. It costs a spread built into the fixed rate, and it adds **counterparty risk**: if the bank fails while it owes the SPV, the protection disappears. Deals require the counterparty to post collateral or be replaced if its rating falls below a set level (Section 12.5).
- **A fixed notional against a balance-guaranteed swap.** A fixed notional of £50,000,000 stays the same while the tracker loans repay, so after a year the swap may hedge more than the deal owns. A balance-guaranteed swap follows the loans' balance, which fits better but costs more.
- **Going further.** With the notional reduced to £45,000,000 as loans repay, the net payment at Bank Rate 3.25% is 0.50% × £45,000,000 ÷ 12 = **£18,750** a month.

- **Interest rate risk on the other side.** Most UK deals hedge the opposite way (fixed loans, SONIA notes, Section 12.2): the SPV pays fixed and receives SONIA. The arithmetic is the same; only the legs swap places.
