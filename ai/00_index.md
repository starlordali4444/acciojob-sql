# AI + SQL - Using AI the Right Way

AI can make you a better SQL developer or it can make sure you never become
one. The difference is HOW you use it.

**The rule: First think. Then write. Then ask AI to review.**

## The 80-20 rule

| 80% YOU | 20% AI |
| :------ | :----- |
| Understand the problem | Explain errors |
| Design the logic | Review your query |
| Write the SQL | Give hints when stuck |
| Predict the output | Generate practice questions |
| Run it yourself | Explain how queries execute |

## What is in this folder

| File | Purpose |
| :--- | :------ |
| [setup_tools.md](./setup_tools.md) | Install an AI tool (Antigravity recommended - free) |
| [prompts_cheatsheet.md](./prompts_cheatsheet.md) | Copy-paste prompt templates that make AI tutor you, not solve for you |

## How it works with this repo

This repository contains an `AGENTS.md` file at its root. When you open
your cloned repo folder in an AI coding tool (Antigravity, Claude Code,
Codex, Cursor), the tool reads that file automatically and switches into
TUTOR MODE: it will hint instead of solve, review instead of write, and it
knows exactly where the RetailMart schema lives.

So the workflow is:

1. Open your cloned repo folder in the AI tool
2. Write your SQL yourself in psql / pgAdmin / VS Code
3. Ask the AI to review it, debug it, or quiz you (see the cheatsheet)
4. You run every query yourself - the AI never touches your database

## Never do this

- "Write SQL for this question" - you learn nothing
- Pasting practice questions and asking for solutions
- Copy-pasting AI output you do not understand
- Letting an AI agent run queries against your database

## Always do this

- "Here is my query and what I expected. Why is the output different?"
- "Give me ONE hint, not the answer"
- "Rate my query: correctness, performance, readability, alternative"
- "Ask me interview questions one by one, do not reveal answers"
