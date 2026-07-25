# AI Tool Setup - Pick One

All of these tools read the `AGENTS.md` tutor rules at the root of this
repo automatically when you open your cloned folder in them. Pick ONE.

> Pricing and quotas below are approximate as of mid-2026 and change
> often - check each tool's pricing page for current limits.

## Option 1: Google Antigravity (RECOMMENDED - free)

Free with any Google account. Includes Gemini 3 at no cost. This is the
one we demo in class.

**Setup (about 5 minutes):**

1. Download from `https://antigravity.google` (Windows / Mac / Linux)
2. Install and sign in with your Gmail account
3. File -> Open Folder -> select your cloned `postgresql` repo folder
4. Open the chat side panel and ask: `What are the tutor rules here?`
   If it mentions hints-not-solutions, AGENTS.md loaded correctly.

**Limits:** free quota is generous but not unlimited - it resets every
few hours. If you hit the limit, take a break and run your queries
yourself (which is the point anyway).

**Important:** use the CHAT panel, not the autonomous agent mode. You are
here to think with a tutor, not to watch a robot type.

## Option 2: Claude Code

Anthropic's terminal-based coding agent. Excellent quality.

1. Install: `npm install -g @anthropic-ai/claude-code`
2. `cd` into your cloned repo folder, run `claude`, sign in

**Limits:** meaningful use needs a paid Claude plan (roughly USD 20 per
month). The free allowance is small. Only choose this if you already pay
for Claude.

## Option 3: OpenAI Codex

OpenAI's coding agent (CLI and IDE extension).

**Limits:** requires a paid ChatGPT plan (Plus or higher) for real usage.
Not recommended unless you already subscribe.

## Option 4: Cursor

An AI code editor (VS Code fork).

1. Download from `https://cursor.com`, install, create an account
2. Open your cloned repo folder

**Limits:** the free Hobby tier has a small monthly request allowance;
serious use needs Pro (roughly USD 20 per month). The free tier is enough
to try it, not enough for daily use.

## Option 5: No install - browser chat (always works)

If you cannot install anything, plain ChatGPT / Gemini / Claude in the
browser works fine. The only difference: the chat cannot read your repo
files, so YOU provide the schema.

1. Open `datasets/v3/sql/setup_accio_retailmart.sql` from your clone
2. Copy the whole file
3. Start a new chat and paste it with this first message:

```
This is the schema of my PostgreSQL training database (RetailMart).
You are my SQL tutor. Never write complete queries for me - review my
queries, explain errors, and give hints only. I run everything myself.
```

4. Then use the prompts from [prompts_cheatsheet.md](./prompts_cheatsheet.md)

## One warning that applies to ALL tools

Never give any AI tool your database password, and never let an agent
connect to or run queries against your database. The AI reads the schema
file. YOU run the SQL. That separation is what makes you learn.
