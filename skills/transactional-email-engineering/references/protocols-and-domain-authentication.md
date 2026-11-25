# Protocols and Domain Authentication

Sources: https://www.rfc-editor.org/info/rfc5321 · https://www.rfc-editor.org/info/rfc5322 · https://www.rfc-editor.org/info/rfc6409 · https://www.rfc-editor.org/rfc/rfc7208.html · https://www.rfc-editor.org/rfc/rfc6376.html · https://www.rfc-editor.org/info/rfc7489 · https://www.rfc-editor.org/info/rfc9989 · https://www.rfc-editor.org/info/rfc9990 · https://www.rfc-editor.org/info/rfc9991

Last verified 2026-11-25

## Transport and format

- RFC 5321 (SMTP, Draft Standard, 2008) obsoletes RFC 2821 and is updated by RFC 7504; the RFC Editor page lists no replacement. A "bis" draft exists in the user's candidate list but was not fetched, so treat 5321 as current.
- RFC 5322 (message format, Draft Standard, 2008) is updated by RFC 6854. It says lines must not exceed 998 characters (excluding CRLF) and should not exceed 78. Both limits are about the wire format of the message, which is why quoted-printable or base64 encoding exists for long content.
- RFC 6409 separates submission from relay. Submission is its own service, with its own security and policy rules, reserved port 587; relay between servers stays on port 25. RFC 6409 is later updated by RFC 8314 (not fetched).
- Consequence for an application: your code is a submission client or an API client, not a relay. It authenticates to the provider, and the provider relays.

## SPF (RFC 7208)

SPF lets a domain publish which hosts may send for it. The spec requires evaluators to limit DNS-lookup terms to 10; `include`, `a`, `mx`, `ptr`, `exists` and the `redirect` modifier count, while `all`, `ip4`, `ip6` and `exp` do not. Exceeding the limit is a permanent error, which means the domain's SPF is effectively broken, and it needs the DNS owner to fix it. A SHOULD limits "void" lookups (queries that return nothing) to two.

Practical meaning: each SaaS you authorize with an `include` spends budget. Adding a new email provider can silently break SPF for the whole domain.

## DKIM (RFC 6376)

- A DKIM signature has a body hash and a header hash; the headers covered are those listed in `h=`. The `From` header must be signed.
- The public key lives in a TXT record at `<selector>._domainkey.<domain>`. Selectors allow several keys at once, which is what makes rotation and per-provider keys possible; do not reuse a selector for a new key.
- Signers must use RSA keys of at least 1024 bits; verifiers must handle 512 to 2048 bits. Large keys may not fit a 512-byte UDP DNS response, so check how your DNS host publishes them.

## DMARC status (verified)

- RFC 7489 (Informational, March 2015) is marked obsolete on the RFC Editor page and points to RFC 9989, 9990 and 9991.
- RFC 9989, "DMARC", Proposed Standard, May 2026, obsoletes RFCs 7489 and 9091.
- RFC 9990, aggregate reporting, Proposed Standard, May 2026, obsoletes RFC 7489.
- RFC 9991, failure reporting, Proposed Standard, May 2026, obsoletes RFC 7489 and updates RFC 6591.
- The body of RFC 9989 was not read in full here. Do not describe new tags, defaults or alignment changes from memory; read the RFC for any detail beyond status.
- Mailbox providers' pages (see `provider-requirements-and-list-hygiene.md`) still describe a minimal policy of `p=none` with a working From-domain alignment to SPF or DKIM.

## Examples (own, illustrative)

- Staging DNS check, pseudo-steps: resolve the SPF record, count lookup terms recursively, fail the check at more than 10; resolve each DKIM selector; resolve `_dmarc` and confirm `rua` is set.
- Per-stream subdomains: `mail.<domain>` for transactional, `news.<domain>` for marketing, each with its own DKIM selector and DMARC reports reviewed separately.

## How an agent should apply this

1. Cite RFC 9989/9990/9991 for DMARC, not 7489, and say only what status pages support.
2. When adding a provider, recount SPF lookups and publish the provider's DKIM records; test with a real message and read the authentication results in its headers.
3. Never suggest hand-rolled SMTP over port 25 from application code; use submission or a provider API.
4. Report DNS changes as proposals for the DNS owner; do not claim they are live.
