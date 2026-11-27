# The runaway bill case and why budget alerts are not caps

Sources: The Register https://www.theregister.com/2020/12/10/google_cloud_over_run/; Firebase https://firebase.google.com/docs/projects/billing/avoid-surprise-bills; video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 05 21:28-24:10 · Last verified 2026-11-24

## What the article reports

Milkie Way, a startup, ran a web scraper on Google Cloud Run writing to Firebase. It had a US$7 budget alert, a Firebase free plan and a card with a US$100 limit. About 116 billion Firestore reads and 33 million writes followed; the bill was around US$72,000 (about US$69,600 of it reads, by the article's estimate). Google waived it as a one-time gesture; the article stresses this cannot be counted on.

Contributing causes per the article: the scraper did not handle pages linking to each other (endless recursion); Cloud Run defaults were high (max 1,000 instances, concurrency 80); services kept running in the background; and billing data lagged by about a day, so the founder saw it the next morning. Google's own docs say a billing budget does not cap spending.

The video compresses this into "a scraper entered a loop and hit 116 billion reads in two hours"; the article's timeline is "overnight, after a day of testing". Use the article.

## What the Firebase page says about limits

- Alerts-only budgets send email at thresholds; "Budget alerts do not pause services".
- Spend-cap budgets exist, pausing a service at 100% for the rest of the month, but only for Firebase AI Logic, App Hosting, Cloud Functions for Firebase and Extensions. Firestore and Realtime Database are not on the list.
- Options listed: use budget notifications to disable billing on a project (with a how-to link), Cloud Monitoring custom alerts, Pub/Sub-driven logic.
- Usage for Firestore and Cloud Storage is calculated daily, so even an alert can arrive late (inference from the daily calculation; the page does not state alert latency).
- Query limits and the Local Emulator Suite for testing are recommended.

## Layered defense (partly inference)

| Layer | Purpose | Limit |
|---|---|---|
| Fix the pattern (loops, listeners, offset, limits) | Prevent the runaway | Needs code review |
| Provider cap where it exists | Hard stop | Not available for Firestore per the page |
| Alert wired to script that disables billing or the key | Automatic cut | Delayed; disabling billing takes the app down |
| Lower provider defaults (instances, concurrency) | Bound blast radius | Per service |
| Fixed-price instance | Cost cannot scale with reads | Capacity limit instead |

## How an agent should apply this

- State plainly whether the provider has a real cap for the service in use; for Firestore say it does not, as of the page read.
- Propose a layered plan: pattern fixes, reduced provider defaults, an alert that triggers a controlled shutdown (and the downtime that implies), and a fixed-price alternative only as an option for the owner.
- Never present a budget alert as protection.
- Cite figures as "reported by The Register", and do not promise that a provider will waive a bill.
- Do not change the provider or business rules; deliver the plan first.
