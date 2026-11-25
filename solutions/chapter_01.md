# Chapter 1: Analyst and data roles in structured finance

> © 2026 Mohamed Miled. All rights reserved. This text is part of the book *Structured Finance Interviews from Zero* and may not be copied, republished or sold. The code blocks are under the MIT licence (see `LICENSE`); the explanations are not (see `LICENSE-TEXT.md`).

## Corrections

### Exercise 1: sorting a job advert into the five skills

#### What the question asks

> A job advert says: "Produce monthly investor reports; reconcile collections to the waterfall; liaise with the servicer on data issues; advanced Excel; VBA an advantage." Sort each part into the five skills, and say which two chapters you would study first.

In plain words: the advert is a list of duties and tools. You must take each phrase, decide which of the five skills of an analyst role it tests, and then use the result to plan your preparation: which two chapters of this book give you the most for this particular job.

The exercise uses the five skills of Section 1.4, *What the jobs have in common* (structured finance knowledge, data handling, Excel, reconciliation and control, communication) and the method of *Reading a job description* in Section 1.5: sort every line, then count. It also uses the chapter map of the "Where in this book" column of the skills table.

#### The plan

1. **Split the advert into separate phrases.** Each phrase is one duty or one tool; a phrase that mixes two ideas is sorted twice. Without this step, "produce monthly investor reports" is easily filed under one skill when it tests two.
2. **Tag each phrase with one or two skills,** using the definitions of the skills table: what the skill means in practice, not the words it contains.
3. **Count the tags and rank the phrases** by how central they are to the job. The count tells you what the interview will test; the ranking tells you what the job is.
4. **Choose two chapters** that cover the highest-ranked phrases, and say why the others come later.

#### Step by step

**Step 1: split the advert.** The semicolons already separate it into five phrases:

1. "Produce monthly investor reports"
2. "reconcile collections to the waterfall"
3. "liaise with the servicer on data issues"
4. "advanced Excel"
5. "VBA an advantage"

Phrases 1 to 3 describe work: things you do every month. Phrases 4 and 5 describe tools. That split matters: interviews test the work through the tools, not the other way round.

**Step 2: tag each phrase.**

| Advert phrase | Skill | Why |
|---|---|---|
| Produce monthly investor reports | Structured finance knowledge; communication | You must know what each number in the report means (the waterfall, arrears, triggers), and the report is written for investors |
| Reconcile collections to the waterfall | Reconciliation and control | Proving that the cash collected equals the cash the waterfall distributes is the definition of a reconciliation |
| Liaise with the servicer on data issues | Data handling; communication | You find the data problem, then explain it to another company and agree the fix |
| Advanced Excel | Excel | The waterfall and the report tables are usually built in Excel |
| VBA an advantage | Excel | VBA automates Excel; "an advantage" means it is not required |

**Step 3: count and rank.** The tags give: structured finance knowledge 1, reconciliation 1, data handling 1, communication 2, Excel 2. Counting alone would put Excel and communication first. But the ranking by centrality is different: phrases 1 and 2 are the job itself (every month, a report and a reconciliation), phrase 3 is how problems get solved, and phrases 4 and 5 are the tools used for all three.

**Step 4: choose two chapters.** The two phrases at the centre of the job are the investor report and the reconciliation to the waterfall. The chapters that teach them are:

- **Chapter 9, The waterfall, step by step**: how revenue and principal are distributed, the PDL, and the checks that prove the waterfall is right. You cannot reconcile collections to a waterfall you cannot run.
- **Chapter 14, Investor reporting and surveillance**: what the report contains, the twelve monthly checks, and how to write the commentary.

Then Chapter 16 (Excel), because the advert asks for "advanced Excel" and an Excel test is likely.

#### Reading the result

The advert describes an **investor reporting analyst**, at a bank or at a trustee. The job is a monthly cycle: data arrives, the waterfall runs, the cash and the pool are reconciled, the report goes out. The interview will almost certainly ask you to walk through a waterfall, to explain a reconciliation break, and to build something in Excel under time pressure. Chapter 1's "A day in four jobs" table for the investor reporting analyst matches this advert line by line, which confirms the reading.

What the advert does not mention is also informative: no SQL, no Python. Keep those to one sentence each in the interview ("I have used SQL to extract data from a loan database"), and spend the preparation time on the waterfall.

#### Checking your answer

Two checks, one on the sorting and one on the choice.

- **Every phrase has at least one skill, and every skill you used appears in the skills table.** Five phrases, eight tags, five skills used: nothing is left unsorted.
- **The two chapters cover the two central phrases.** Read the "Before you start" box of each chapter: Chapter 9 ends with "check that the result reconciles", and Chapter 14 with "build and check an investor report". Both match the advert's first two phrases.

A third, practical check: search the job title on a recruitment site and read three similar adverts. If they all mention the waterfall and reconciliation, your reading is right.

#### Mistakes people make on this exercise

- **Starting with VBA because it is the most technical word.** The advert says "an advantage": it is the last thing to prepare. A candidate who spends a week on VBA and cannot explain a PDL fails the interview.
- **Filing "produce monthly investor reports" under communication only.** The report is communication, but every number in it comes from the waterfall and the pool data; without structured finance knowledge the report is wrong, however well it is written.
- **Counting tags and stopping there.** The count says Excel and communication are mentioned most, but the job's centre is the report and the reconciliation. Rank by what the job is, then use the count to decide what else to revise.
- **Choosing Chapter 16 first.** It is defensible if your Excel is weak, but the interview will open with "walk me through a waterfall", not with a formula.

#### Trade-offs and going further

- **The advert against your own gaps.** The two chapters chosen fit the advert. If your Excel is weak, you may need Chapter 16 early, because an Excel test can end the process before any interview. Decide from the advert and from your own weaknesses together.
- **Depth against breadth.** Preparing two chapters deeply beats skimming ten. Interviewers follow up until they reach the edge of what you know; a deep answer on the waterfall survives three follow-ups, a broad answer does not survive one.
- **Going further.** Take a real advert for a role you want, sort it with the same table, and write the two chapters you would study first. Then compare with the "Interview focus" line of the matching role in Section 1.3.
