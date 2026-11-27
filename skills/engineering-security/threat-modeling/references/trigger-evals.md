# Trigger evals

Should trigger (`threat-modeling`):
1. "We are adding a payment webhook and a partner API. What can go wrong before we build it?"
2. "Draw the data flow and trust boundaries for our multi-tenant export feature."
3. "Walk STRIDE over this new admin service and tell me what to do about each threat."

Near misses (another skill):
1. "Scan this repo for leaked keys and missing owner checks." -> `security-audit`
2. "A scanner flagged CVE-2026-xxxx in our image; is it real and how urgent?" -> `vulnerability-triage`
3. "Move the price calculation off the client." -> `never-trust-the-client`
