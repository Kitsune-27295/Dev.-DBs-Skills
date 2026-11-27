# The runaway bill case and why budget alerts are not caps

Sources: The Register https://www.theregister.com/2020/12/10/google_cloud_over_run/; Firebase https://firebase.google.com/docs/projects/billing/avoid-surprise-bills · Last verified 2026-11-27

## What the article reports

Milkie Way, a startup, ran a web scraper on Google Cloud Run writing to Firestore. It had a US$7 billing budget alert. About 116 billion Firestore reads and 33 million writes followed; the bill was just short of US$72,000 (about US$69,600 of it Firestore reads, plus about 16,000 Cloud Run compute hours because services were not deleted). The free Firebase plan was upgraded automatically by activity in Google Cloud, which started the billing. Google waived the bill as a one-time gesture after a detailed incident write-up; the article stresses this cannot be counted on.

Contributing causes per the article: scraper code that could recurse endlessly when pages linked to each other; Cloud Run defaults of 1,000 maximum instances and concurrency 80 (the founder said values of 2 and 1 would have prevented it); services left running; and billing data and the Firebase dashboard lagging by about a day, so the founder saw it the next day and the dashboard showed usage within limits while it was far higher. Google's own docs say a budget does not automatically cap spending.

## What the Firebase page says about limits

- Alerts-only budgets send email at thresholds and do not stop any service.
- Spend-cap budgets pause a service at 100% for the rest of the month, but only for Firebase AI Logic, App Hosting, Cloud Functions for Firebase and Extensions. Firestore is not on the list.
- Other options listed: budget notifications that programmatically disable Cloud Billing on a project, Cloud Monitoring alerts, Pub/Sub-driven logic.
- Firestore usage is calculated daily (the page's wording), so a late alert is plausible; alert latency itself is the pack's inference.
- Add a limit to queries that could return millions of results, and test with the Local Emulator Suite and watch for fan-out or infinite loops.

## Layered defense (partly inference)

| Layer | Purpose | Limit |
|---|---|---|
| Fix the pattern (loops, listeners, offset, limits) | Prevent the runaway | Needs code review |
| Provider cap where it exists | Hard stop | Not available for Firestore per the page |
| Notification wired to a script that disables billing | Automatic cut | Delayed; disabling billing takes the app down |
| Lower provider defaults (instances, concurrency) | Bound blast radius | Per service |
| Fixed-price instance | Cost cannot scale with reads | Capacity limit instead |

## How an agent should apply this

- State plainly whether the provider has a real cap for the service in use; for Firestore say it does not, as of the page read on 2026-11-27.
- Propose a layered plan: pattern fixes, reduced provider defaults, a notification that triggers a controlled shutdown (and the downtime that implies), and a fixed-price alternative only as an option for the owner.
- Never present a budget alert as protection.
- Cite figures as "reported by The Register", and do not promise that a provider will waive a bill.
- Do not change the provider or business rules; deliver the plan first.
