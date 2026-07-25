# AI Prompt Cheatsheet for SQL

Copy-paste templates. In a coding tool (Antigravity etc.) opened on this
repo, just use them directly - the tool already knows the schema. In a
browser chat, paste the schema file first (see setup_tools.md, Option 5).

The pattern in all of them: YOU did the thinking first, AI reacts to YOUR
work.

## 1. Debug my query (the most useful one)

```
Here is my query and what I expected it to return.

Expected: <one line: what you thought you would get>

Query:
<paste your SQL>

It gives <the error / the wrong output - paste it>.

Do NOT give me the corrected query. Tell me which clause the problem
is in and give me ONE hint. I will try to fix it myself.
```

## 2. Review my working query

```
This query works. Review it like a senior engineer:

<paste your SQL>

Rate it on:
- Correctness (edge cases I missed? NULLs? duplicates?)
- Performance (would this survive 10 million rows?)
- Readability (naming, formatting, structure)
- Alternative (is there a cleaner approach? name it, do not write it)
```

## 3. Explain this error

```
psql gave me this error:

<paste the full error message>

Explain what it means in simple words and WHY PostgreSQL raises it.
Do not rewrite my query - just explain the concept.
```

## 4. Interview me

```
You are a SQL interviewer. Ask me questions one at a time about
<topic, e.g. JOINs and GROUP BY>. Wait for my answer before revealing
anything. Tell me honestly if my answer is wrong and why. Increase
difficulty gradually. Start now.
```

## 5. Generate fresh practice

```
Generate 10 NEW practice questions on <topics> using the RetailMart
schema. Difficulty: <beginner / intermediate / hard>. Real column and
table names only - check the schema. Questions only, NO answers.
I will paste my attempts one by one for review.
```

## 6. Be my database (practice without psql)

```
Pretend you are PostgreSQL with the RetailMart schema loaded, with a
few realistic rows per table. I will type SQL. Reply with ONLY the
result table or the exact error - no explanations unless I ask.
```

## 7. Explain a concept

```
Explain <concept, e.g. LEFT JOIN vs INNER JOIN> like I am 12, using a
small example with two tiny tables shown as text. Then show me the
one-line rule to remember.
```

## 8. Check my logic BEFORE I write SQL

```
Question I am solving: <paste question>

My plan in plain English:
<e.g. "join orders to customers, filter to 2025, group by tier,
then keep tiers with avg above overall avg">

Is my LOGIC correct? Do not write any SQL. Point out flaws in the
plan only.
```

## The anti-patterns (do not be this person)

| If you type this | You get |
| :--- | :--- |
| "Write SQL for this question" | A grade you did not earn and a skill you do not have |
| "Solve my assignment" | Caught in the interview round |
| "Fix my query" (without trying) | Dependency |

| Type this instead | You get |
| :--- | :--- |
| "Give me one hint" | A working brain |
| "Check if my logic is correct" | Design skills |
| "Why is this wrong? Don't solve it" | Debugging skills - the highest paid skill |
