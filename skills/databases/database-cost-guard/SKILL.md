---
name: database-cost-guard
description: Use when a database or backend-as-a-service bills by reads, writes or traffic and the monthly bill could explode - find queries inside loops (N+1), real-time listeners, offset pagination and unbounded queries, estimate reads per user per day at ten times the users, fix the simplest way, and set a spending limit that really cuts. Also use before launching on Firestore, Supabase or any usage-priced database. Not for slow queries on a fixed-price instance (use query-performance) or a whole-application slowdown (use application-performance).
---

# Database cost guard

A usage-priced database is a taxi meter: it does not know your code entered a loop. The lesson's case is a startup billed a little short of US$72,000 on Firestore and Cloud Run against a US$7 budget alert (The Register, December 2020; Google waived it once as a one-time gesture). A **budget alert is not a cap**: Firebase's billing guide says alerts-only budgets do not pause services, and spend-cap budgets exist only for four named services (Firestore is not one), so check what your provider offers for the service you use. Database rules shared by every database skill: `database-audit`. Sources, status and limits: [references/sources.md](references/sources.md).

## 1. Steps (list and plan first, change nothing yet)

1. **Billing model.** Which database and how it charges: a fixed price per instance, or per read, write and traffic. If the code does not say, ask.
2. **Find the heavy spots:** every query inside a loop (N+1), every real-time listener or subscription, every pagination by offset, every query **without a row limit**. Done when each has `file:line`.
3. **Cost each one:** estimate the **reads per user per day** it produces and what that costs with **10 times** the users, showing the arithmetic and citing the provider's current pricing page.
4. **Simplest fix for each:** a `JOIN` or `IN` instead of the loop, a listener restricted to what the screen shows, a **cursor** instead of offset, a limit on rows.
5. **A limit that really cuts.** Show how to configure one at the provider, beyond the budget alert. If the provider has no automatic cut-off for the service, say so plainly and propose an alternative (a quota, a budget notification wired to a controlled billing shutdown, lower provider defaults such as maximum instances).

## 2. Rules

- Show the list and the plan before changing any file.
- Does not switch database or provider, and does not change business rules.
- Read patterns also matter on a per-instance database: the index side is `query-performance`; this skill is about the meter.
- A figure from a post-mortem or a pricing page is a claim until read at its source; prices change.

Source: the handout of the second database lesson of mano deyvin (prompt "end-of-month scare").

## Quick Decision Checklist

- [ ] Do I know the billing model: fixed per instance, or per read, write and traffic?
- [ ] Have I listed every query in a loop, real-time listener, offset pagination and unlimited query, each with file:line?
- [ ] Did I estimate reads per user per day, and the cost at 10 times the users, showing the arithmetic?
- [ ] Did I propose the simplest fix for each: JOIN or IN, narrower listener, cursor, row limit?
- [ ] Is there a limit that really cuts at the provider, beyond a budget alert, or did I say plainly there is none?
- [ ] Have I shown the list and plan before changing any file?
- [ ] Am I leaving the database, provider and business rules unchanged?

## Deep references

- [Sources and caveats](references/sources.md) — when you must check which claims were verified and which are the lesson's own
- [Usage pricing mechanics](references/usage-pricing-mechanics.md) — when you estimate reads per user or cost at 10x users
- [Runaway bill case and budget limits](references/runaway-bill-case-and-budget-limits.md) — when you must say what a budget alert does and does not stop
- [Trigger evals](references/trigger-evals.md) — when you tune this skill's description
