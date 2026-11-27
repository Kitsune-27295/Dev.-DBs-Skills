# Sources — Database cost guard

Every URL below was re-checked on 2026-11-27 (fetched through a summarizing fetch tool; the page text was not read in full).

| Source | Retrieved status | What it contributed |
|---|---|---|
| The Register, 2020-12-10, https://www.theregister.com/2020/12/10/google_cloud_over_run/ | 200 | 116 billion reads, 33 million writes, just under US$72,000, US$7 budget, defaults, waiver |
| Firebase "Avoid surprise bills", https://firebase.google.com/docs/projects/billing/avoid-surprise-bills | 200 | Alerts do not pause services; spend caps for four services; options; daily Firestore usage; query limits |
| Firestore pricing, https://firebase.google.com/docs/firestore/pricing | 200 | What counts as a read, offset, listeners, 30-minute rule, free quota, rules reads |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe | 200, section "End-of-month scare" re-read | The prompt steps (billing model, loops/listeners/offset/unbounded, 10x estimate, fix, real cut-off) |
| Video "Banco de Dados / Fundamentos para Vibe Coders #EP2", mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI | Page content truncated; only the title was confirmed | Lesson framing (chapter 05); transcript from an earlier saved copy |

## Corrections made on 2026-11-27

1. The old case text said the founder had "a card with a US$100 limit"; the page read does not say so. Removed.
2. Added from the article: the free plan auto-upgrade, about 16,000 Cloud Run compute hours, the dashboard showing usage within limits, the founder's remark about instance and concurrency values.
3. SKILL.md said spend caps exist "for a few named services"; now names the four. The old "per-key limit" suggestion (the skill's own, absent from the Firebase page) was dropped in favor of listed options: billing shutdown by notification and lower provider defaults.
4. Pricing: added that deletes do not trigger listener reads, index-entry exception, 1 GiB and 10 GiB quotas, and the `getAfter()` rule reads; the offset, 30-minute and minimum-read claims were confirmed unchanged.
5. The cost formula no longer hard-codes per-100,000 pricing.

## Reading limits

Pages were read through a summarizing tool. The Firebase page says Firestore usage is calculated daily; any claim about alert latency is inference. Prices were not read or adopted. The video page returned only a title.

## Claims not adopted as fact

- The video's "2 hours, 116 billion reads" (the article says the bill built overnight after a day of testing).
- The video's "same thing happened at AWS" (unsourced).
- The US$100 card limit (not confirmed).
- That the vendor will waive a bill again.
