# Chapter 4: What securitisation is, and why banks use it

## Corrections

### Exercise 1: Class A's share and its protection

#### What the question asks

> A bank sells £300,000,000 of loans to an SPV that issues £255,000,000 of Class A notes and £45,000,000 of Class B notes. What percentage of the deal is Class A, and what protects it?

In plain words: the deal has two classes of notes. You must say how large the senior class is as a share of the whole deal, and then list everything that stands between a loss on the loans and a loss for the Class A investors.

The exercise uses the four steps of a securitisation and the Ashcombe closing balance sheet (Section 4.2), the seniority of notes in the waterfall (Section 4.1: "the junior notes take losses first"), and the reserve fund (Section 4.2). Chapter 8 gives the full vocabulary of credit enhancement; this exercise is its first use.

#### The plan

1. **Check the deal adds up.** Notes against loans tells you whether there is overcollateralisation, which would be one more layer of protection.
2. **Compute Class A's share** of the notes.
3. **List the protection below Class A,** in the order losses would reach it, and size what can be sized.
4. **Test the answer with a loss** to see the protection work.

#### Step by step

**Step 1: notes against loans.**

Notes = £255,000,000 + £45,000,000 = £300,000,000, equal to the loans.

The deal is not overcollateralised: every pound of loans backs exactly one pound of notes, as in Ashcombe (£240,000,000 of loans, £240,000,000 of notes).

**Step 2: Class A's share.**

Class A share = £255,000,000 ÷ £300,000,000 = **85%**. Class B is the other 15%.

**Step 3: what protects Class A.** Losses on the loans are absorbed from the bottom of the structure up. Below Class A there are:

| Layer | What it is | Size |
|---|---|---|
| Excess spread | The pool's interest left over each month after fees and note interest | Depends on rates and costs; not a fixed amount |
| Reserve fund (if the deal has one) | Cash held by the SPV, used when revenue is short | Not given in this exercise |
| **Class B notes** | Paid after Class A; written down first | **£45,000,000, 15% of the deal** |

The 15% of the deal below Class A is called its **subordination**. Excess spread is used first, month by month; a reserve fund comes next; then Class B absorbs what is left. Only when all three are used up does Class A lose money.

**Step 4: test with a loss.** Suppose £20,000,000 of loans are lost over the life of the deal, and ignore excess spread and any reserve.

- Class B absorbs the £20,000,000 and is repaid £25,000,000 of its £45,000,000.
- Class A is repaid its full £255,000,000.

Class A would lose money only if losses exceeded £45,000,000 (plus whatever excess spread and the reserve fund absorbed first).

#### Reading the result

- **Class A is 85% of the deal and is protected by 15% subordination.** That is one point more than Ashcombe's 14%: this deal's senior notes are slightly better protected.
- **The protection explains the coupon.** Class A takes losses last, so it is the safest class, usually rated AAA, and pays the lowest coupon. Class B is paid more because it takes losses first.
- **For the interview**, say both the number and the mechanism: "Class A is 85% of the deal. It is protected by Class B, 15% of the deal, which absorbs losses first, plus excess spread and any reserve fund."

- **The same arithmetic answers the investor's first question.** An investor deciding whether to buy Class A asks how large a loss on the pool would reach it. Here the answer is simple: more than £45 million, 15% of the pool, before excess spread and any reserve. For a UK prime mortgage pool, where lifetime losses are usually well under 1%, that is a very large cushion, which is why such a class can be rated AAA.

#### Checking your answer

- **The shares add up.** 85% + 15% = 100%, and £255m + £45m = £300m.
- **Recompute the loss test the other way.** Class A's loss = MAX(0, loss − £45,000,000). For a loss of £20,000,000, MAX(0, −£25,000,000) = 0. For a loss of £50,000,000, Class A loses £5,000,000, 1.96% of its £255,000,000. The formula and the narrative give the same answer.
- **Compare with the chapter's example.** Ashcombe: £206.4m ÷ £240m = 86% Class A, 14% Class B. The same calculation on this deal gives 85% and 15%.

#### Mistakes people make on this exercise

- **Calling the 85% the "credit enhancement".** The 85% is Class A's size; its credit enhancement is the 15% below it (plus any reserve and excess spread). Confusing the two reverses the meaning: a larger Class A has *less* protection, not more.
- **Saying Class A is protected by "the loans".** Every class is backed by the same loans. What protects Class A specifically is that other money absorbs losses before it does.
- **Leaving out excess spread.** In a typical month it is the first line of defence: a small loss is absorbed by revenue and never reaches Class B at all.
- **Dividing by the wrong total.** £255m ÷ £45m = 5.67 compares the classes with each other; the question asks for a share of the deal.

#### Trade-offs and going further

- **More subordination costs the issuer.** Making Class B larger (say 20%) raises Class A's protection but means more notes pay Class B's higher coupon. Arrangers size Class B as the smallest amount that achieves the rating the issuer wants for Class A (Chapter 8, *How ratings are set*).
- **Other ways to protect Class A.** Overcollateralisation (loans worth more than the notes) and a reserve fund give similar protection at a different cost: overcollateralisation ties up loans, a reserve ties up cash. Chapter 8 compares them.
- **Going further.** If the deal also had a reserve fund of 1% of the pool, Class A's total credit enhancement, ignoring excess spread, would be 15% + 1% = **16%**, and Class B's would be **1%**.
