# Sources — Idempotency fix

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Fundamentos de Engenharia de Software para Vibe Coders", channel "mano deyvin", published 2026-10-27, https://www.youtube.com/watch?v=G8SeOH0qerk, chapter "Idempotência: garantindo ações únicas" (7:11-13:26) | Page 200 OK; transcript read in full (local export), but the export has a gap between about 11:33 and 13:21 (only music markers), so the end of the chapter is not available | The payment-webhook retry story (slow or deploying receiver, gateway retries up to a configured count), the processed-events table (event id plus timestamp), "answer 200 when already processed", and why an in-process `if` is not enough |
| Author's handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, section "2. Idempotência" and its prompt | Page 200 OK; handout read in full (local export) | Signature check on the raw body, insert-id-first, no reliance on arrival order, fast 2xx, idempotency keys on outbound calls, `Idempotency-Key` header on own endpoints, duplicate and concurrent tests, no personal data as a key |

## Claims and caveats

- Video claims: that a webhook can be retried "10 times" is the speaker's illustrative configuration, not a gateway default; the multiplication-by-thousands loss story is rhetorical, not measured.
- The video says the table holds only the event id and a timestamp; the handout says the id is a unique key. SKILL.md combines both ("id plus timestamp"); consistent.
- Gap: the video's explanation of why an `if` is insufficient is cut off in the export; SKILL.md's wording (process memory is not shared, state not persisted) matches the visible part and the handout rationale.
- Items in SKILL.md that come only from the handout prompt, not the video: raw-body signature verification, not relying on arrival order, outbound idempotency keys, the `Idempotency-Key` header, not using personal data as key.
- No external pages are cited for this topic; the gateway's own idempotency documentation was not consulted, so nothing here is verified against a vendor spec.
