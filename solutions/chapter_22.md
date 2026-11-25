# Chapter 22: Behavioural questions: telling your own stories

> © 2026 Mohamed Miled. All rights reserved. This text is part of the book *Structured Finance Interviews from Zero* and may not be copied, republished or sold. The code blocks are under the MIT licence (see `LICENSE`); the explanations are not (see `LICENSE-TEXT.md`).

## Corrections

### Exercise 1: your best data story in STAR bullets

#### What the question asks

> Choose your best data story and write it as STAR bullet points, with at least three numbers.

In plain words: from the experiences on your story worksheet, pick the one where you dealt best with data (an error you found, a check you built, a number you questioned), and write it in the four parts of STAR, as short bullet points rather than a script, with at least three concrete numbers.

The exercise uses the STAR method and its proportions (Section 22.2: situation and task 10% to 15% each, action 50% to 60%, result 15% to 20%), the worksheet and "Make each story measurable" (Section 22.3), and the qualities interviewers look for (Section 22.1), especially accuracy, problem solving and working with data.

The story must be yours. The working below uses a fictional candidate, Priya, a graduate with two years in a lender's finance team, to show the method; do not copy her story, because interviewers ask follow-up questions that only a real story survives.

#### The plan

1. **Choose the story** by testing each candidate against three questions: did I find a cause, did I act myself, is there a number in the result?
2. **Write the four parts as bullets**, situation and task short, action long.
3. **Add the numbers**: how much, how many, how long, how often.
4. **Check the proportions and the "I"s**, then cut.

#### Step by step

**Step 1: choose the story.** Priya's worksheet has three data candidates:

| Candidate | Cause found? | My actions? | Number in the result? |
|---|---|---|---|
| Spotted a wrong total in a colleague's report | No: the colleague fixed it | Few | No |
| Arrears report did not tie to the ledger | Yes: duplicated loans from a new join | Yes: I traced and fixed it | Yes: the check caught a repeat |
| Cleaned survey data for my dissertation | Partly | Yes | No |

The second passes all three tests. It also matches the job: securitisation reporting is about totals that must tie.

**Step 2: the four parts, as bullets.**

- **Situation.** Monthly arrears report for the credit committee, built from an extract of the loan system; I prepared it on my own.
- **Task.** The total was above the general ledger, the day before the committee; I had to find why and deliver a report that tied.
- **Action.**
  - Reconciled the totals by product: the whole difference sat in buy-to-let.
  - Compared buy-to-let loan by loan with the previous month: some loans appeared twice.
  - Traced the duplicates to a change in the extract: a new join to a table with two addresses for some customers.
  - Removed the duplicates for this month's report and wrote down the cause and the fix.
  - Added a check to the report: rows must equal distinct loan IDs, or the report stops.
- **Result.** Report delivered on time and tied to the ledger; the check caught a similar problem later; I now reconcile at loan level by default.

**Step 3: add the numbers.** Go back through each bullet and ask "how much, how many, how long?":

- Task: the total was **£180,000** above the ledger, **one day** before the committee.
- Action: **12 loans** appeared twice.
- Result: the check caught a similar problem **three months later**.

Four numbers, three of them in the first half of the story, where they make the problem concrete.

**Step 4: proportions and "I".** Count the words: situation 21, task 23, action 76, result 24, out of 144; the action is 53%, inside the 50% to 60% of Section 22.2. Every action bullet starts with a verb Priya did herself.

#### Reading the result

- **The story shows four qualities at once**: accuracy (she noticed the total did not tie), problem solving (product, then loan, then cause), working with data (the join), and ownership (a check that lasts).
- **The numbers make it believable.** "A difference" is vague; "£180,000, 12 loans, one day before the committee" is a real event an interviewer can probe.
- **The lasting check is the strongest part.** Fixing the report is expected; making sure the error cannot recur is what separates a good analyst from an adequate one, and it is the part interviewers remember.

#### Checking your answer

Use the checklist of the chapter on your own story:

- Does the action section use "I" and describe at least three steps? Priya's has five.
- Is there at least one number in the situation or task, and one in the result? Yes: £180,000 and one day; three months later.
- Did you find a cause, not just fix a symptom? Yes: the join.
- Is there a lesson or lasting change? Yes: the check, and the habit of loan-level reconciliation.
- Can you answer "What would you do differently?" Priya: "I'd have asked to be told about changes to the extract before month-end, so I could test them first." Write your own answer down before the interview.

Then test it aloud: record yourself, and cut until it takes under two minutes (Section 22.9, *Practising*).

#### Mistakes people make on this exercise

- **"We" instead of "I".** "We found the problem" tells the interviewer nothing about you. Use "we" only for what the team did and "I" for what you did.
- **A long situation.** Three sentences about the company, the system and the committee push the action into the last thirty seconds. Two short bullets are enough.
- **No cause.** "I fixed the total" is a symptom fixed; an interviewer will ask "why was it wrong?" and the story collapses.
- **Invented or rounded-up numbers.** If you do not know a number exactly, give a fair estimate and say so ("about £180,000"). A number you cannot defend under questioning does more harm than no number.

#### Trade-offs and going further

- **Technical detail against clarity.** "A join on a table with two addresses per customer" impresses a data interviewer and loses a general manager. Keep one sentence of it, and offer more if asked.
- **One story for many questions.** This story also answers "a mistake you found", "a time you worked under pressure" and "something you improved". Reusing a strong story is fine, but prepare six to eight, so that you do not tell the same one twice in one interview.
- **Going further.** Write the same story for the question "Tell me about a process you improved": the situation and task shrink to one bullet, and the check becomes the centre of the action.
