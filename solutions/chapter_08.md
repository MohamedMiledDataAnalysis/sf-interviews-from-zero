# Chapter 8: Tranches, ratings and credit enhancement

## Corrections

### Exercise 1: overcollateralisation, subordination and credit enhancement

#### What the question asks

> A deal has a £500m pool and notes of Class A £420m, Class B £30m, Class C £25m and Class D £15m. Is there overcollateralisation, and how much? Calculate the subordination of each class, and Class A's credit enhancement including the OC.

In plain words: a four-class deal backed by a £500 million pool. You must find whether the pool is larger than the notes, measure how much of the structure sits below each class, and add the overcollateralisation to Class A's protection.

The exercise uses the four forms of credit enhancement and their order (Section 8.3), the formulas for subordination and credit enhancement in *Calculating subordination* (Section 8.3), and the idea that losses are absorbed from the bottom of the structure up (Section 8.4).

#### The plan

1. **Compare the notes with the pool.** Any excess of pool over notes is overcollateralisation (OC), a layer of protection below every class.
2. **Compute each class's subordination**: the classes below it, divided by the pool.
3. **Add the OC to Class A's subordination** to get its credit enhancement.
4. **Check the structure** with a loss test.

#### Step by step

**Step 1: the notes and the OC.**

Notes = £420m + £30m + £25m + £15m = **£490m**.

OC = pool − notes = £500m − £490m = **£10m**, which is £10m ÷ £500m = **2%** of the pool. Yes, the deal is overcollateralised.

**Step 2: subordination of each class.** Subordination = sum of the classes below ÷ pool. The pool is the base because it is the pool that must absorb the losses.

| Class | Classes below it | Subordination |
|---|---|---:|
| A | B + C + D = £30m + £25m + £15m = £70m | £70m ÷ £500m = **14.0%** |
| B | C + D = £40m | **8.0%** |
| C | D = £15m | **3.0%** |
| D | none | **0%** |

**Step 3: Class A's credit enhancement including the OC.**

CE (A) = (classes below + OC) ÷ pool = (£70m + £10m) ÷ £500m = **16.0%**.

The same addition for the other classes gives B 10.0%, C 5.0% and D 2.0%: every class, even the most junior, is protected by the OC.

**Step 4: in Excel.** With the class sizes in B2:B5 (A to D) and the pool in B7:

```
B6: =SUM(B2:B5)
B8: =B7-B6
C2: =SUM(B3:$B$5)/$B$7
D2: =C2+$B$8/$B$7
```

- `B6` is the note total; `B8` the OC.
- `C2` adds the classes below Class A (rows 3 to 5) and divides by the pool. Copied down to C4, the range shrinks (`B4:$B$5`, `B5:$B$5`) because only its end is fixed with `$`; set C5 to 0 for Class D, which has nothing below it.
- `D2` adds the OC share to the subordination: credit enhancement.

#### Reading the result

- **Class A can absorb losses of £80m, 16% of the pool, before losing a penny**: the £10m OC first, then Classes D, C and B.
- **Even Class D has protection**: the £10m OC. A loss of up to 2% of the pool reaches no note at all.
- **The structure is typical of a prime deal**: a thick senior class (84% of the notes) and thin junior classes, each a few percent, rated progressively lower.

- **The class sizes follow the ratings.** Each class's credit enhancement is set so that it survives the stressed losses of its target rating: 16% for AAA, 10%, 5% and 2% for the lower classes. Reading the CE column from the bottom up is reading the rating scale from the bottom up.

#### Checking your answer

- **The structure adds up.** Notes + OC = £490m + £10m = £500m, the pool.
- **The CE steps match the class sizes.** The difference between consecutive classes' CE equals the size of the class between them: A's 16.0% − B's 10.0% = 6.0% = £30m ÷ £500m, Class B's size. Likewise B − C = 5.0% (Class C, £25m) and C − D = 3.0% (Class D, £15m).
- **A loss test.** Apply a loss of £45m from the bottom up: the OC takes £10m, Class D £15m, Class C £20m. Class B is untouched, as its CE of 10% (£50m) predicts, and Class A even more so.

#### Mistakes people make on this exercise

- **Dividing by the notes instead of the pool.** £70m ÷ £490m = 14.3% for Class A. The losses happen in the pool, so the pool is the base; using the notes overstates protection whenever there is OC.
- **Forgetting the OC in Class A's CE.** 14% is subordination only; the question asks for CE including OC, 16%.
- **Counting a class in its own subordination.** Class A's subordination is the classes *below* it, not including itself; (£420m + £70m) ÷ £500m = 98% is not a protection measure.
- **Treating OC as cash.** OC is extra loans, not money in a bank account. It absorbs losses because, after a loss, the remaining loans still cover the notes.

#### Trade-offs and going further

- **OC against a thicker junior class.** £10m of OC and £10m more of Class D give Class A the same protection. OC costs the originator, who sells £500m of loans but receives only £490m from investors; a larger Class D costs the deal its higher coupon every month. The arranger chooses the cheaper mix for the target ratings.
- **CE grows over time.** If Class A is paid first (sequential payment), the junior classes and the OC become a larger share of a smaller pool, so Class A's CE rises (Section 8.5). Many deals switch to pro rata payment once CE has doubled, to stop the protection, and the cost, growing further.
- **Going further.** After £20m of Class A has been repaid and no losses have occurred, the pool is £480m and Class A's CE is (£70m + £10m) ÷ £480m = **16.7%**, up from 16.0%.
